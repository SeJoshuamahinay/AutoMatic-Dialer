import 'package:equatable/equatable.dart';

abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object> get props => [];
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

class TrackingStarting extends TrackingState {
  const TrackingStarting();
}

class TrackingActive extends TrackingState {
  /// Admin-set interval in seconds, or null until the admin starts a schedule.
  final int? intervalSeconds;

  /// Whether the live WebSocket (Reverb) is currently connected.
  final bool socketConnected;

  const TrackingActive({this.intervalSeconds, this.socketConnected = false});

  @override
  List<Object> get props => [intervalSeconds ?? -1, socketConnected];
}

class TrackingInactive extends TrackingState {
  const TrackingInactive();
}

class TrackingError extends TrackingState {
  final String message;

  const TrackingError(this.message);

  @override
  List<Object> get props => [message];
}
