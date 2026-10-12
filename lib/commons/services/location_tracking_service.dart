import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../database/app_database.dart';
import 'api_client.dart';
import 'device_id_service.dart';
import 'tracking_log.dart';
import 'tracking_socket_service.dart';

const _minIntervalSeconds = 1;
const _tag = 'LocationTracking';

/// Without a limit getCurrentPosition can wait forever for a fix (indoors,
/// weak GPS). That kept _uploadInFlight stuck at true, so every later tick
/// returned early and the device silently stopped sending.
const _gpsTimeout = Duration(seconds: 30);

/// Queued fixes sent per request when draining the offline queue (server max 100).
const _flushBatchSize = 50;

/// Drives the location-tracking pseudocode: connect, react to server
/// commands, poll GPS on an interval, upload each fix, and retry anything
/// that failed to upload once the network is back.
///
/// Runs inside the foreground service's isolate (see TrackingTaskHandler), so
/// it keeps going when the app's screen is closed or swiped away.
class LocationTrackingService {
  final _socket = TrackingSocketService();
  final _db = AppDatabase();

  Timer? _scheduleTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? _deviceId;
  bool _uploadInFlight = false;
  bool _flushInFlight = false;
  bool _tracking = false;
  bool _socketConnected = false;
  int? _currentInterval;
  DateTime? _lastUploadAt;
  String? _lastReportedHealth;

  bool get isTracking => _tracking;

  /// Whether the GPS timer is running (an admin or the working-hours
  /// schedule has started tracking for this device).
  bool get isReporting => _scheduleTimer != null;

  DateTime? get lastUploadAt => _lastUploadAt;

  /// Whether the live WebSocket (Reverb) is currently connected.
  bool get isSocketConnected => _socketConnected;

  /// The interval (seconds) the admin last set for this device, or null if the
  /// admin hasn't started a schedule yet. Set by the start_tracking /
  /// change_interval socket commands.
  int? get currentInterval => _currentInterval;

  /// Fired whenever something the UI shows changes: interval, schedule
  /// running, socket connected, last upload.
  void Function()? onStatusChanged;

  /// Fired on the admin's stop_service command. The owner stops the whole
  /// foreground service, which in turn calls [stop].
  void Function()? onStopServiceRequested;

  /// Fired when the server rejects the login token, so the owner can stop.
  void Function()? onSessionExpired;

  Future<void> start() async {
    _deviceId = await DeviceIdService.getOrCreate();
    TrackingLog.info(_tag, 'starting, device_id=$_deviceId');

    final response = await ApiClient.post(
      '/api/tracking/connect',
      body: {'device_id': _deviceId},
    );
    if (response.statusCode != 200) {
      TrackingLog.error(_tag, 'connect failed (HTTP ${response.statusCode})', response.body);
      throw Exception(
        'Failed to register device (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    // start_tracking is only broadcast when the server flips tracking_active
    // on. If the app was killed, restarted or offline at that moment it never
    // hears it, and the server won't send it again. So resume from the state
    // the server already has instead of waiting for a command.
    int? resumeInterval;
    try {
      final data = jsonDecode(response.body)['data'];
      final interval = (data?['tracking_interval'] as num?)?.toInt();
      if (interval != null) {
        _currentInterval = interval;
        onStatusChanged?.call();
      }
      if (data?['tracking_active'] == true && interval != null) {
        resumeInterval = interval;
      }
      TrackingLog.info(
        _tag,
        'connected, tracking_active=${data?['tracking_active']}, interval=$interval',
      );
    } catch (e, st) {
      // Non-fatal — the interval will still arrive on the next socket command.
      TrackingLog.error(_tag, 'could not read connect response', e, st);
    }

    _socket.onStartTracking = (interval) => startLocationSchedule(interval);
    _socket.onChangeInterval = (interval) => startLocationSchedule(interval);
    _socket.onRequestLocation = (_) => getAndUploadLocation();
    _socket.onStopTracking = stopLocationSchedule;
    _socket.onStopService = onStopServiceRequested ?? stop;
    _socket.onRequestLogs = uploadLogs;
    _socket.onConnectionStateChange = (connected) {
      _socketConnected = connected;
      onStatusChanged?.call();
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

    if (resumeInterval != null) {
      TrackingLog.info(_tag, 'resuming schedule from server state, every ${resumeInterval}s');
      startLocationSchedule(resumeInterval);
    }

    // Upload anything left in the queue from a previous session.
    flushPendingLocations();
  }

  Future<void> stop() async {
    TrackingLog.info(_tag, 'stopping');
    stopLocationSchedule();
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    // Tell the backend we're going offline so the admin command center flips
    // this device to Offline immediately, instead of waiting for the
    // server-side stale sweep. Best-effort: never block stopping on it.
    final deviceId = _deviceId ?? await DeviceIdService.getOrCreate();
    try {
      await ApiClient.post('/api/tracking/disconnect', body: {'device_id': deviceId});
    } catch (e) {
      // Offline / no network — the server's stale sweep will catch it later.
      TrackingLog.warn(_tag, 'disconnect call failed: $e');
    }

    await _socket.disconnect();
    _tracking = false;
    _socketConnected = false;
    onStatusChanged?.call();
  }

  void startLocationSchedule(int intervalSeconds) {
    final interval = intervalSeconds < _minIntervalSeconds
        ? _minIntervalSeconds
        : intervalSeconds;

    _currentInterval = interval;
    TrackingLog.info(_tag, 'schedule started, every ${interval}s');

    _scheduleTimer?.cancel();
    getAndUploadLocation();
    _scheduleTimer = Timer.periodic(
      Duration(seconds: interval),
      (_) => getAndUploadLocation(),
    );
    onStatusChanged?.call();
  }

  void stopLocationSchedule() {
    if (_scheduleTimer != null) TrackingLog.info(_tag, 'schedule stopped');
    _scheduleTimer?.cancel();
    _scheduleTimer = null;
    onStatusChanged?.call();
  }

  Future<void> getAndUploadLocation() async {
    if (_deviceId == null) return;
    if (_uploadInFlight) {
      TrackingLog.warn(_tag, 'tick skipped, previous fix still in flight');
      return;
    }
    _uploadInFlight = true;

    try {
      final gpsEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();
      if (gpsEnabled && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      unawaited(_reportHealth(gpsEnabled, permission));

      if (!gpsEnabled) {
        TrackingLog.warn(_tag, 'tick skipped, GPS is turned off');
        return;
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        TrackingLog.warn(_tag, 'tick skipped, location permission $permission');
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: _gpsTimeout,
        );
      } on TimeoutException {
        position = await Geolocator.getLastKnownPosition();
        TrackingLog.warn(
          _tag,
          'no GPS fix within ${_gpsTimeout.inSeconds}s, '
          '${position == null ? 'no last known position, tick skipped' : 'using last known position'}',
        );
        if (position == null) return;
      }
      TrackingLog.info(
        _tag,
        'fix: ${position.latitude}, ${position.longitude} (±${position.accuracy}m)',
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
    } on AuthSessionExpiredException {
      TrackingLog.warn(_tag, 'login expired, stopping tracking');
      onSessionExpired?.call();
    } catch (e, st) {
      TrackingLog.error(_tag, 'tick failed', e, st);
    } finally {
      _uploadInFlight = false;
    }
  }

  /// Tell the server when GPS or permission state changes, so the dashboard
  /// can show why this phone stopped sending. Only sent on change.
  Future<void> _reportHealth(bool gpsEnabled, LocationPermission permission) async {
    final health = '$gpsEnabled|${permission.name}';
    if (health == _lastReportedHealth) return;

    try {
      final response = await ApiClient.post(
        '/api/tracking/status',
        body: {
          'device_id': _deviceId,
          'gps_enabled': gpsEnabled,
          'location_permission': permission.name,
        },
      );
      if (response.statusCode == 200) {
        _lastReportedHealth = health;
        TrackingLog.info(_tag, 'health reported: gps=$gpsEnabled, permission=${permission.name}');
      } else {
        TrackingLog.warn(_tag, 'health report failed (HTTP ${response.statusCode})');
      }
    } catch (e) {
      // Retried on the next tick, since _lastReportedHealth is unchanged.
      TrackingLog.warn(_tag, 'health report failed: $e');
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
        TrackingLog.info(_tag, 'uploaded: $latitude, $longitude');
        _lastUploadAt = DateTime.now();
        onStatusChanged?.call();
        // The server is reachable again, so drain anything queued earlier.
        // Connectivity events alone miss outages where the network stayed up
        // but the server failed (5xx, timeouts).
        unawaited(flushPendingLocations());
      } else {
        TrackingLog.warn(
          _tag,
          'upload failed (HTTP ${response.statusCode}), queued locally: ${response.body}',
        );
        await _queueLocation(payload, recordedAt);
      }
    } on AuthSessionExpiredException {
      rethrow;
    } catch (e) {
      TrackingLog.warn(_tag, 'upload error, queued locally: $e');
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
  ///
  /// Sends [_flushBatchSize] fixes per request: after hours offline the queue
  /// can hold thousands of rows. Only one flush runs at a time, since
  /// connectivity changes fire in bursts and overlapping flushes would send the
  /// same rows twice. A network error ends the flush; the remaining rows wait
  /// for the next trigger.
  Future<void> flushPendingLocations() async {
    if (_flushInFlight) return;
    _flushInFlight = true;

    var sent = 0;
    try {
      final pending = await _db.getPendingLocations();
      if (pending.isEmpty) return;
      TrackingLog.info(_tag, 'flushing ${pending.length} queued location(s)');

      for (var i = 0; i < pending.length; i += _flushBatchSize) {
        final batch = pending.sublist(i, min(i + _flushBatchSize, pending.length));
        final response = await ApiClient.post(
          '/api/tracking/locations/batch',
          body: {
            'device_id': _deviceId,
            'locations': batch.map(_queuedFixPayload).toList(),
          },
        );

        if (response.statusCode == 201) {
          await _db.deletePendingLocations(batch.map((l) => l.id).toList());
          sent += batch.length;
        } else if (response.statusCode == 422) {
          // One bad row rejects the whole batch. Send these one at a time so
          // the good rows still go through and only the bad one is dropped.
          TrackingLog.warn(_tag, 'batch rejected, retrying ${batch.length} row(s) one by one');
          final ok = await _flushOneByOne(batch);
          if (ok < 0) break;
          sent += ok;
        } else {
          TrackingLog.warn(_tag, 'flush stopped, HTTP ${response.statusCode} on batch upload');
          break;
        }
      }
    } catch (e) {
      TrackingLog.warn(_tag, 'flush stopped, network error: $e');
    } finally {
      _flushInFlight = false;
      if (sent > 0) TrackingLog.info(_tag, 'flushed $sent queued location(s)');
    }
  }

  /// Returns how many rows were sent, or -1 if the server stopped accepting.
  Future<int> _flushOneByOne(List<PendingLocationEntry> rows) async {
    var sent = 0;
    for (final location in rows) {
      final response = await ApiClient.post(
        '/api/tracking/locations',
        body: {'device_id': _deviceId, ..._queuedFixPayload(location)},
      );

      if (response.statusCode == 201) {
        await _db.deletePendingLocation(location.id);
        sent++;
      } else if (response.statusCode == 422) {
        TrackingLog.warn(_tag, 'dropping rejected queued location #${location.id}: ${response.body}');
        await _db.deletePendingLocation(location.id);
      } else {
        TrackingLog.warn(
          _tag,
          'flush stopped, HTTP ${response.statusCode} on queued location #${location.id}',
        );
        return -1;
      }
    }
    return sent;
  }

  Map<String, dynamic> _queuedFixPayload(PendingLocationEntry location) => {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
        'speed': location.speed,
        'heading': location.heading,
        'altitude': location.altitude,
        'recorded_at': location.recordedAt.toIso8601String(),
      };

  /// Upload tracking.log for the admin's request_logs command.
  Future<void> uploadLogs() async {
    try {
      final path = await TrackingLog.path();
      final response = await ApiClient.postMultipart(
        '/api/tracking/logs',
        fields: {'device_id': _deviceId!},
        files: [await http.MultipartFile.fromPath('log', path)],
      );
      if (response.statusCode == 201) {
        TrackingLog.info(_tag, 'log uploaded');
      } else {
        TrackingLog.warn(_tag, 'log upload failed (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      TrackingLog.warn(_tag, 'log upload failed: $e');
    }
  }
}
