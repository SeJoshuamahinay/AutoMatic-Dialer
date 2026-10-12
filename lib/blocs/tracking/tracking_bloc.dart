import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import '../../commons/services/shared_prefs_storage_service.dart';
import '../../commons/services/tracking_log.dart';
import '../../commons/services/tracking_task_handler.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

/// Starts and stops the tracking foreground service. The tracking itself runs
/// in the service's isolate (TrackingTaskHandler); this bloc only mirrors the
/// status the task reports so the settings screen can show it.
class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc() : super(const TrackingInitial()) {
    on<StartTrackingRequested>(_onStartTrackingRequested);
    on<StopTrackingRequested>(_onStopTrackingRequested);
    on<TrackingStatusReceived>(_onTrackingStatusReceived);

    FlutterForegroundTask.addTaskDataCallback(_onTaskData);

    // Connecting is now driven by auth (always-on while logged in), not a
    // persisted user toggle — see the auth bridge in main.dart.
  }

  void _onTaskData(Object data) {
    final status = TrackingStatus.fromData(data);
    if (status != null) add(TrackingStatusReceived(status));
  }

  void _onTrackingStatusReceived(
    TrackingStatusReceived event,
    Emitter<TrackingState> emit,
  ) {
    if (state is! TrackingActive && state is! TrackingStarting) return;
    final status = event.status;
    emit(TrackingActive(
      intervalSeconds: status.intervalSeconds,
      socketConnected: status.socketConnected,
      reporting: status.reporting,
      lastUploadAt: status.lastUploadAt,
      error: status.error,
    ));
  }

  @override
  Future<void> close() {
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    return super.close();
  }

  Future<void> _onStartTrackingRequested(
    StartTrackingRequested event,
    Emitter<TrackingState> emit,
  ) async {
    // Already connected/connecting — ignore repeat triggers (auth state can
    // re-emit AuthAuthenticated without an actual login).
    if (state is TrackingActive || state is TrackingStarting) {
      debugPrint('[TrackingBloc] start ignored — already ${state.runtimeType}');
      return;
    }

    debugPrint('[TrackingBloc] start requested');
    emit(const TrackingStarting());

    var locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
    }
    debugPrint('[TrackingBloc] location permission: $locationPermission');
    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      emit(const TrackingError('Location permission is required to start tracking.'));
      return;
    }

    // "Allow all the time" lets Android restart tracking by itself after a
    // reboot or an app update. Without it a location service can't start
    // from the background, so auto-restart stays off.
    if (Platform.isAndroid && locationPermission == LocationPermission.whileInUse) {
      locationPermission = await Geolocator.requestPermission();
      TrackingLog.info('TrackingBloc', 'background location permission: $locationPermission');
    }
    final autoRestart = Platform.isAndroid && locationPermission == LocationPermission.always;

    final notificationPermission = await FlutterForegroundTask.checkNotificationPermission();
    debugPrint('[TrackingBloc] notification permission: $notificationPermission');
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    // OEM battery savers (Xiaomi, Oppo, Vivo, Samsung) kill background apps
    // even with a foreground service running unless the app is exempted.
    if (Platform.isAndroid && !await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      final exempted = await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      TrackingLog.info('TrackingBloc', 'battery optimization exemption: $exempted');
    }

    _initForegroundTask(autoRestart: autoRestart);

    // A previous attempt (e.g. one that failed after the service started)
    // can leave the foreground service running — starting it again throws
    // ServiceAlreadyStartedException instead of just being a no-op.
    //
    // It is also what keeps tracking alive when the app is swiped away: on the
    // next launch the service (and its task) is still running, so just ask it
    // for its status.
    if (await FlutterForegroundTask.isRunningService) {
      TrackingLog.info('TrackingBloc', 'foreground service already running, reusing it');
      FlutterForegroundTask.sendDataToTask(trackingStatusRequest);
    } else {
      final serviceResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Lenderly Dialer',
        notificationText: 'Location tracking is active',
        callback: startTrackingCallback,
      );
      TrackingLog.info('TrackingBloc', 'foreground service result: $serviceResult');
      if (serviceResult is ServiceRequestFailure) {
        emit(TrackingError('Could not start the background service: ${serviceResult.error}'));
        return;
      }
    }

    await SharedPrefsStorageService.saveTrackingEnabled(true);
    // Stays TrackingStarting until the task's first status report arrives.
  }

  Future<void> _onStopTrackingRequested(
    StopTrackingRequested event,
    Emitter<TrackingState> emit,
  ) async {
    debugPrint('[TrackingBloc] stop requested');
    // The task's onDestroy tells the server this device went offline.
    await FlutterForegroundTask.stopService();
    await SharedPrefsStorageService.saveTrackingEnabled(false);
    emit(const TrackingInactive());
  }

  void _initForegroundTask({required bool autoRestart}) {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'lenderly_dialer_tracking',
        channelName: 'Location Tracking',
        channelDescription: 'Shows a persistent notification while location tracking is active.',
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: autoRestart,
        autoRunOnMyPackageReplaced: autoRestart,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }
}
