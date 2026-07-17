import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Value;
import 'package:geolocator/geolocator.dart';

import '../../database/app_database.dart';
import 'api_client.dart';
import 'device_id_service.dart';
import 'tracking_socket_service.dart';

const _minIntervalSeconds = 1;

/// Drives the location-tracking pseudocode: connect, react to server
/// commands, poll GPS on an interval, upload each fix, and retry anything
/// that failed to upload once the network is back.
class LocationTrackingService {
  final _socket = TrackingSocketService();
  final _db = AppDatabase();

  Timer? _scheduleTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? _deviceId;
  bool _uploadInFlight = false;
  bool _tracking = false;
  bool _socketConnected = false;
  int? _currentInterval;

  bool get isTracking => _tracking;

  /// Whether the live WebSocket (Reverb) is currently connected.
  bool get isSocketConnected => _socketConnected;

  /// The interval (seconds) the admin last set for this device, or null if the
  /// admin hasn't started a schedule yet. Set by the start_tracking /
  /// change_interval socket commands.
  int? get currentInterval => _currentInterval;

  /// Fired whenever the admin-set interval changes, so the UI can show it.
  void Function(int intervalSeconds)? onIntervalChanged;

  /// Fired whenever the WebSocket connects or drops, so the UI can show it.
  void Function(bool connected)? onConnectionChanged;

  Future<void> start() async {
    _deviceId = await DeviceIdService.getOrCreate();

    final response = await ApiClient.post(
      '/api/tracking/connect',
      body: {'device_id': _deviceId},
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to register device (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    // Seed the interval the admin already had configured for this device so the
    // UI can show it immediately, instead of waiting for the next command.
    try {
      final interval = (jsonDecode(response.body)['data']?['tracking_interval']) as int?;
      if (interval != null) {
        _currentInterval = interval;
        onIntervalChanged?.call(interval);
      }
    } catch (_) {
      // Non-fatal — the interval will still arrive on the next socket command.
    }

    _socket.onStartTracking = (interval) => startLocationSchedule(interval);
    _socket.onChangeInterval = (interval) => startLocationSchedule(interval);
    _socket.onRequestLocation = (_) => getAndUploadLocation();
    _socket.onStopTracking = stopLocationSchedule;
    _socket.onStopService = stop;
    _socket.onConnectionStateChange = (connected) {
      _socketConnected = connected;
      onConnectionChanged?.call(connected);
    };

    await _socket.connect(_deviceId!);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (!results.contains(ConnectivityResult.none)) {
        flushPendingLocations();
      }
    });

    _tracking = true;
  }

  Future<void> stop() async {
    stopLocationSchedule();
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    // Tell the backend we're going offline so the admin command center flips
    // this device to Offline immediately, instead of waiting for the
    // server-side stale sweep. Best-effort: never block stopping on it.
    final deviceId = _deviceId ?? await DeviceIdService.getOrCreate();
    try {
      await ApiClient.post('/api/tracking/disconnect', body: {'device_id': deviceId});
    } catch (_) {
      // Offline / no network — the server's stale sweep will catch it later.
    }

    await _socket.disconnect();
    _tracking = false;
    _socketConnected = false;
    onConnectionChanged?.call(false);
  }

  void startLocationSchedule(int intervalSeconds) {
    final interval = intervalSeconds < _minIntervalSeconds
        ? _minIntervalSeconds
        : intervalSeconds;

    _currentInterval = interval;
    onIntervalChanged?.call(interval);

    _scheduleTimer?.cancel();
    getAndUploadLocation();
    _scheduleTimer = Timer.periodic(
      Duration(seconds: interval),
      (_) => getAndUploadLocation(),
    );
  }

  void stopLocationSchedule() {
    _scheduleTimer?.cancel();
    _scheduleTimer = null;
  }

  Future<void> getAndUploadLocation() async {
    if (_uploadInFlight || _deviceId == null) return;
    _uploadInFlight = true;

    try {
      final gpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (!gpsEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint(
        '[LocationTracking] fix: ${position.latitude}, ${position.longitude} (±${position.accuracy}m)',
      );

      await _uploadOrQueue(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        altitude: position.altitude,
        recordedAt: position.timestamp,
      );
    } finally {
      _uploadInFlight = false;
    }
  }

  Future<void> _uploadOrQueue({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
    required double altitude,
    required DateTime recordedAt,
  }) async {
    final payload = {
      'device_id': _deviceId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'altitude': altitude,
      'recorded_at': recordedAt.toIso8601String(),
    };

    try {
      final response = await ApiClient.post(
        '/api/tracking/locations',
        body: payload,
      );
      if (response.statusCode == 201) {
        debugPrint('[LocationTracking] uploaded: $latitude, $longitude');
      } else {
        debugPrint(
          '[LocationTracking] upload failed (HTTP ${response.statusCode}), queued locally',
        );
        await _queueLocation(payload, recordedAt);
      }
    } catch (e) {
      debugPrint('[LocationTracking] upload error: $e, queued locally');
      await _queueLocation(payload, recordedAt);
    }
  }

  Future<void> _queueLocation(
    Map<String, dynamic> payload,
    DateTime recordedAt,
  ) async {
    await _db.insertPendingLocation(
      PendingLocationsCompanion.insert(
        deviceId: _deviceId!,
        latitude: payload['latitude'] as double,
        longitude: payload['longitude'] as double,
        accuracy: Value(payload['accuracy'] as double?),
        speed: Value(payload['speed'] as double?),
        heading: Value(payload['heading'] as double?),
        altitude: Value(payload['altitude'] as double?),
        recordedAt: recordedAt,
      ),
    );
  }

  /// Flush anything queued while the network was down. Call this from a
  /// connectivity-restored listener.
  Future<void> flushPendingLocations() async {
    final pending = await _db.getPendingLocations();

    for (final location in pending) {
      final response = await ApiClient.post(
        '/api/tracking/locations',
        body: {
          'device_id': location.deviceId,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracy': location.accuracy,
          'speed': location.speed,
          'heading': location.heading,
          'altitude': location.altitude,
          'recorded_at': location.recordedAt.toIso8601String(),
        },
      );

      if (response.statusCode == 201) {
        await _db.deletePendingLocation(location.id);
      }
    }
  }
}
