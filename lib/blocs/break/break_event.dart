import 'package:equatable/equatable.dart';
import '../../commons/models/break_session_model.dart';

abstract class BreakEvent extends Equatable {
  const BreakEvent();

  @override
  List<Object> get props => [];
}

class StartBreak extends BreakEvent {
  final BreakType type;
  final String? reason;

  const StartBreak(this.type, {this.reason});

  @override
  List<Object> get props => [type, reason ?? ''];
}

class EndBreak extends BreakEvent {
  const EndBreak();
}

class LoadBreakHistory extends BreakEvent {
  final DateTime? date;

  const LoadBreakHistory({this.date});

  @override
  List<Object> get props => [date ?? DateTime.now()];
}

class LoadBreakStatistics extends BreakEvent {
  final DateTime? date;

  const LoadBreakStatistics({this.date});

  @override
  List<Object> get props => [date ?? DateTime.now()];
}

class CheckActiveBreak extends BreakEvent {
  const CheckActiveBreak();
}
