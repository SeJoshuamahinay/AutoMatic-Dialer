import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'api_client.dart';
import 'environment_config.dart';
import 'location_tracking_service.dart';
import 'tracking_log.dart';

const _tag = 'TrackingTask';

/// Message the UI sends to ask the task for a fresh [TrackingStatus].
const trackingStatusRequest = 'status';

/// Entry point of the foreground service's isolate.
///
/// Tracking used to run in the UI isolate, which Android destroys when the
/// app is swiped away; the notification stayed up but the GPS timer was gone.
/// The foreground service's own isolate lives as long as the service does.
@pragma('vm:entry-point')
void startTrackingCallback() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  FlutterForegroundTask.setTaskHandler(TrackingTaskHandler());
}

/// What the task reports back to the UI (sent as a plain map across isolates).
class TrackingStatus {
  final bool connected;
  final bool socketConnected;
  final bool reporting;
  final int? intervalSeconds;
  final DateTime? lastUploadAt;
  final String? error;

  const TrackingStatus({
    required this.connected,
    required this.socketConnected,
    required this.reporting,
    this.intervalSeconds,
    this.lastUploadAt,
    this.error,
  });

  Map<String, Object?> toMap() => {
        'connected': connected,
        'socket': socketConnected,
        'reporting': reporting,
        'interval': intervalSeconds,
        'last_upload_at': lastUploadAt?.millisecondsSinceEpoch,
        'error': error,
      };

  static TrackingStatus? fromData(Object data) {
    if (data is! Map) return null;
    final lastUpload = data['last_upload_at'] as int?;
    return TrackingStatus(
      connected: data['connected'] == true,
      socketConnected: data['socket'] == true,
      reporting: data['reporting'] == true,
      intervalSeconds: data['interval'] as int?,
      lastUploadAt: lastUpload == null ? null : DateTime.fromMillisecondsSinceEpoch(lastUpload),
      error: data['error'] as String?,
    );
  }
}

class TrackingTaskHandler extends TaskHandler {
  final _service = LocationTrackingService();
  Timer? _retryTimer;
  int _retryAttempt = 0;
  String? _lastError;
  bool _destroyed = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    TrackingLog.info(_tag, 'task started (${starter.name})');

    try {
      await EnvironmentConfig.initialize(environment: Environment.dev);
    } catch (e, st) {
      TrackingLog.error(_tag, 'could not load environment, tracking disabled', e, st);
      _report(error: 'Could not load app settings.');
      return;
    }

    _service.onStatusChanged = _report;
    _service.onStopServiceRequested = _stopService;
    _service.onSessionExpired = _stopService;

    await _connect();
  }

  /// A phone that starts tracking while offline (or while the server is down)
  /// used to give up for good. Keep retrying with backoff, capped at 5 minutes.
  Future<void> _connect() async {
    if (_destroyed) return;
    try {
      await _service.start();
      _retryAttempt = 0;
      _lastError = null;
      _report();
    } on AuthSessionExpiredException {
      TrackingLog.warn(_tag, 'login expired, stopping service');
      _stopService();
    } catch (e, st) {
      _retryAttempt++;
      final delay = Duration(seconds: min(300, 15 * pow(2, _retryAttempt - 1).toInt()));
      TrackingLog.error(_tag, 'start failed, retrying in ${delay.inSeconds}s', e, st);
      _lastError = 'Could not reach the server. Retrying in ${delay.inSeconds}s.';
      _report();
      _retryTimer?.cancel();
      _retryTimer = Timer(delay, _connect);
    }
  }

  void _report({String? error}) {
    FlutterForegroundTask.sendDataToMain(TrackingStatus(
      connected: _service.isTracking,
      socketConnected: _service.isSocketConnected,
      reporting: _service.isReporting,
      intervalSeconds: _service.currentInterval,
      lastUploadAt: _service.lastUploadAt,
      error: error ?? _lastError,
    ).toMap());
  }

  void _stopService() {
    TrackingLog.info(_tag, 'stopping foreground service');
    FlutterForegroundTask.stopService();
  }

  @override
  void onReceiveData(Object data) {
    if (data == trackingStatusRequest) _report();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    TrackingLog.info(_tag, 'task destroyed');
    _destroyed = true;
    _retryTimer?.cancel();
    if (_service.isTracking) await _service.stop();
  }
}
