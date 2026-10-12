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

  /// Whether the GPS timer is running (admin or working hours started it).
  final bool reporting;

  /// When the last location reached the server.
  final DateTime? lastUploadAt;

  /// Set while the task can't reach the server and is retrying.
  final String? error;

  const TrackingActive({
    this.intervalSeconds,
    this.socketConnected = false,
    this.reporting = false,
    this.lastUploadAt,
    this.error,
  });

  @override
  List<Object> get props => [
        intervalSeconds ?? -1,
        socketConnected,
        reporting,
        lastUploadAt?.millisecondsSinceEpoch ?? -1,
        error ?? '',
      ];
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
