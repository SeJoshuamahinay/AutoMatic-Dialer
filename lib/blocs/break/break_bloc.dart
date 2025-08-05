import 'package:flutter_bloc/flutter_bloc.dart';
import '../../commons/models/break_session_model.dart';
import 'break_event.dart';
import 'break_state.dart';

class BreakBloc extends Bloc<BreakEvent, BreakState> {
  final List<BreakSession> _breakHistory = [];
  BreakSession? _activeBreak;

  BreakBloc() : super(const BreakInitial()) {
    on<StartBreak>(_onStartBreak);
    on<EndBreak>(_onEndBreak);
    on<LoadBreakHistory>(_onLoadBreakHistory);
    on<ClearBreakHistory>(_onClearBreakHistory);
  }

  void _onStartBreak(StartBreak event, Emitter<BreakState> emit) async {
    try {
      emit(const BreakLoading());

      // End any existing break first
      if (_activeBreak != null) {
        final endedBreak = _activeBreak!.copyWith(
          endTime: DateTime.now(),
          isActive: false,
        );
        _breakHistory.add(endedBreak);
      }

      // Start new break
      _activeBreak = BreakSession(
        id: DateTime.now().millisecondsSinceEpoch,
        type: event.type,
        startTime: DateTime.now(),
        reason: event.reason,
        isActive: true,
      );

      emit(BreakActive(_activeBreak!));
    } catch (e) {
      emit(BreakError('Failed to start break: ${e.toString()}'));
    }
  }

  void _onEndBreak(EndBreak event, Emitter<BreakState> emit) async {
    try {
      emit(const BreakLoading());

      if (_activeBreak != null) {
        final endedBreak = _activeBreak!.copyWith(
          endTime: DateTime.now(),
          isActive: false,
        );
        _breakHistory.add(endedBreak);
        _activeBreak = null;
      }

      emit(BreakInactive(List.from(_breakHistory)));
    } catch (e) {
      emit(BreakError('Failed to end break: ${e.toString()}'));
    }
  }

  void _onLoadBreakHistory(
    LoadBreakHistory event,
    Emitter<BreakState> emit,
  ) async {
    try {
      emit(const BreakLoading());

      if (_activeBreak != null) {
        emit(BreakActive(_activeBreak!));
      } else {
        emit(BreakInactive(List.from(_breakHistory)));
      }
    } catch (e) {
      emit(BreakError('Failed to load break history: ${e.toString()}'));
    }
  }

  void _onClearBreakHistory(
    ClearBreakHistory event,
    Emitter<BreakState> emit,
  ) async {
    try {
      emit(const BreakLoading());
      _breakHistory.clear();

      if (_activeBreak != null) {
        emit(BreakActive(_activeBreak!));
      } else {
        emit(const BreakInactive([]));
      }
    } catch (e) {
      emit(BreakError('Failed to clear break history: ${e.toString()}'));
    }
  }

  // Getters for current break info
  bool get isOnBreak => _activeBreak != null;
  BreakSession? get currentBreak => _activeBreak;
  List<BreakSession> get breakHistory => List.from(_breakHistory);

  // Get total break time for today
  Duration get todaysTotalBreakTime {
    final today = DateTime.now();
    final todaysBreaks = _breakHistory
        .where(
          (breakSession) =>
              breakSession.startTime.day == today.day &&
              breakSession.startTime.month == today.month &&
              breakSession.startTime.year == today.year,
        )
        .toList();

    Duration total = Duration.zero;
    for (final breakSession in todaysBreaks) {
      total += breakSession.actualDuration;
    }

    // Add current break if active
    if (_activeBreak != null &&
        _activeBreak!.startTime.day == today.day &&
        _activeBreak!.startTime.month == today.month &&
        _activeBreak!.startTime.year == today.year) {
      total += _activeBreak!.actualDuration;
    }

    return total;
  }
}
