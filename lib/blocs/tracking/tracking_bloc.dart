import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import '../../commons/services/location_tracking_service.dart';
import '../../commons/services/shared_prefs_storage_service.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final LocationTrackingService _trackingService;

  TrackingBloc({LocationTrackingService? trackingService})
      : _trackingService = trackingService ?? LocationTrackingService(),
        super(const TrackingInitial()) {
    on<StartTrackingRequested>(_onStartTrackingRequested);
    on<StopTrackingRequested>(_onStopTrackingRequested);
    on<TrackingIntervalUpdated>(_onTrackingIntervalUpdated);
    on<TrackingSocketStateChanged>(_onTrackingSocketStateChanged);

    // Surface admin-set interval changes into the UI.
    _trackingService.onIntervalChanged =
        (interval) => add(TrackingIntervalUpdated(interval));

    // Surface live WebSocket connect/disconnect into the UI.
    _trackingService.onConnectionChanged =
        (connected) => add(TrackingSocketStateChanged(connected));

    // Connecting is now driven by auth (always-on while logged in), not a
    // persisted user toggle — see the auth bridge in main.dart.
  }

  void _onTrackingIntervalUpdated(
    TrackingIntervalUpdated event,
    Emitter<TrackingState> emit,
  ) {
    debugPrint('[TrackingBloc] interval updated: ${event.intervalSeconds}s');
    if (state is TrackingActive || state is TrackingStarting) {
      emit(TrackingActive(
        intervalSeconds: event.intervalSeconds,
        socketConnected: _trackingService.isSocketConnected,
      ));
    }
  }

  void _onTrackingSocketStateChanged(
    TrackingSocketStateChanged event,
    Emitter<TrackingState> emit,
  ) {
    debugPrint('[TrackingBloc] socket connected: ${event.connected}');
    if (state is TrackingActive || state is TrackingStarting) {
      emit(TrackingActive(
        intervalSeconds: _trackingService.currentInterval,
        socketConnected: event.connected,
      ));
    }
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

    final notificationPermission = await FlutterForegroundTask.checkNotificationPermission();
    debugPrint('[TrackingBloc] notification permission: $notificationPermission');
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    _initForegroundTask();

    // A previous attempt (e.g. one that failed after the service started)
    // can leave the foreground service running — starting it again throws
    // ServiceAlreadyStartedException instead of just being a no-op.
    if (await FlutterForegroundTask.isRunningService) {
      debugPrint('[TrackingBloc] foreground service already running, reusing it');
    } else {
      final serviceResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Lenderly Dialer',
        notificationText: 'Location tracking is active',
      );
      debugPrint('[TrackingBloc] foreground service result: $serviceResult');
      if (serviceResult is ServiceRequestFailure) {
        emit(TrackingError('Could not start the background service: ${serviceResult.error}'));
        return;
      }
    }

    try {
      await _trackingService.start();
      debugPrint('[TrackingBloc] tracking active');
      await SharedPrefsStorageService.saveTrackingEnabled(true);
      emit(TrackingActive(
        intervalSeconds: _trackingService.currentInterval,
        socketConnected: _trackingService.isSocketConnected,
      ));
    } catch (e) {
      debugPrint('[TrackingBloc] failed to start tracking: $e');
      await FlutterForegroundTask.stopService();
      emit(TrackingError('Failed to start tracking: $e'));
    }
  }

  Future<void> _onStopTrackingRequested(
    StopTrackingRequested event,
    Emitter<TrackingState> emit,
  ) async {
    debugPrint('[TrackingBloc] stop requested');
    await _trackingService.stop();
    await FlutterForegroundTask.stopService();
    await SharedPrefsStorageService.saveTrackingEnabled(false);
    emit(const TrackingInactive());
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'lenderly_dialer_tracking',
        channelName: 'Location Tracking',
        channelDescription: 'Shows a persistent notification while location tracking is active.',
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );
  }
}
