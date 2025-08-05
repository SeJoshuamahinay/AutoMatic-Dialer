import 'package:equatable/equatable.dart';
import '../../commons/models/break_session_model.dart';

abstract class BreakState extends Equatable {
  const BreakState();

  @override
  List<Object?> get props => [];
}

class BreakInitial extends BreakState {
  const BreakInitial();
}

class BreakLoading extends BreakState {
  const BreakLoading();
}

class BreakActive extends BreakState {
  final BreakSession activeBreak;

  const BreakActive(this.activeBreak);

  @override
  List<Object> get props => [activeBreak];
}

class BreakInactive extends BreakState {
  final List<BreakSession> breakHistory;

  const BreakInactive(this.breakHistory);

  @override
  List<Object> get props => [breakHistory];
}

class BreakError extends BreakState {
  final String message;

  const BreakError(this.message);

  @override
  List<Object> get props => [message];
}
