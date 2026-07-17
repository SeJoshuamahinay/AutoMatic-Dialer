import 'package:equatable/equatable.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object> get props => [];
}

class StartTrackingRequested extends TrackingEvent {
  const StartTrackingRequested();
}

class StopTrackingRequested extends TrackingEvent {
  const StopTrackingRequested();
}

/// Fired when the admin-set interval changes while tracking is active.
class TrackingIntervalUpdated extends TrackingEvent {
  final int intervalSeconds;

  const TrackingIntervalUpdated(this.intervalSeconds);

  @override
  List<Object> get props => [intervalSeconds];
}

/// Fired when the WebSocket connects or drops.
class TrackingSocketStateChanged extends TrackingEvent {
  final bool connected;

  const TrackingSocketStateChanged(this.connected);

  @override
  List<Object> get props => [connected];
}
