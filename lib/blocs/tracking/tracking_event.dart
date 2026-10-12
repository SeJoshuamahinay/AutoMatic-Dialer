import 'package:equatable/equatable.dart';

import '../../commons/services/tracking_task_handler.dart';

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

/// Fired when the foreground task reports its status (interval, socket,
/// whether the GPS timer is running, last upload).
class TrackingStatusReceived extends TrackingEvent {
  final TrackingStatus status;

  const TrackingStatusReceived(this.status);

  @override
  List<Object> get props => [status.toMap().toString()];
}
