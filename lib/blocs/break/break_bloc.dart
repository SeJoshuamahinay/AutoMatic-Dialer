import 'package:flutter_bloc/flutter_bloc.dart';
import '../../commons/models/break_session_model.dart';
import '../../commons/services/break_service.dart';
import 'break_event.dart';
import 'break_state.dart';

class BreakBloc extends Bloc<BreakEvent, BreakState> {
  final BreakService _breakService;
  final int _userId;
  final String? _agentName;

  BreakBloc({
    required BreakService breakService,
    required int userId,
    String? agentName,
  }) : _breakService = breakService,
       _userId = userId,
       _agentName = agentName,
       super(const BreakInitial()) {
    on<StartBreak>(_onStartBreak);
    on<EndBreak>(_onEndBreak);
    on<LoadBreakHistory>(_onLoadBreakHistory);
    on<LoadBreakStatistics>(_onLoadBreakStatistics);
    on<CheckActiveBreak>(_onCheckActiveBreak);
  }

  void _onStartBreak(StartBreak event, Emitter<BreakState> emit) async {
    try {
      emit(const BreakLoading());

      final breakSession = await _breakService.startBreakSession(
        type: event.type,
        userId: _userId,
        reason: event.reason,
        agentName: _agentName,
      );

      final history = await _breakService.getTodaysBreakSessions(_userId);
      emit(BreakActive(breakSession, breakHistory: history));
    } catch (e) {
      emit(BreakError('Failed to start break: ${e.toString()}'));
    }
  }

  void _onEndBreak(EndBreak event, Emitter<BreakState> emit) async {
    try {
      emit(const BreakLoading());

      final endedBreak = await _breakService.endActiveBreakSession(_userId);

      if (endedBreak != null) {
        final history = await _breakService.getTodaysBreakSessions(_userId);
        emit(BreakInactive(history));
      } else {
        emit(const BreakError('No active break session to end'));
      }
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

      final date = event.date ?? DateTime.now();
      final history = await _breakService.getBreakSessionsForDate(
        _userId,
        date,
      );
      final activeBreak = await _breakService.getActiveBreakSession(_userId);

      if (activeBreak != null) {
        emit(BreakActive(activeBreak, breakHistory: history));
      } else {
        emit(BreakInactive(history));
      }
    } catch (e) {
      emit(BreakError('Failed to load break history: ${e.toString()}'));
    }
  }

  void _onLoadBreakStatistics(
    LoadBreakStatistics event,
    Emitter<BreakState> emit,
  ) async {
    try {
      emit(const BreakLoading());

      final date = event.date ?? DateTime.now();
      final history = await _breakService.getBreakSessionsForDate(
        _userId,
        date,
      );
      final statistics = await _breakService.getBreakStatisticsForDate(
        _userId,
        date,
      );
      final activeBreak = await _breakService.getActiveBreakSession(_userId);

      emit(
        BreakStatisticsLoaded(
          breakHistory: history,
          statistics: statistics,
          activeBreak: activeBreak,
        ),
      );
    } catch (e) {
      emit(BreakError('Failed to load break statistics: ${e.toString()}'));
    }
  }

  void _onCheckActiveBreak(
    CheckActiveBreak event,
    Emitter<BreakState> emit,
  ) async {
    try {
      emit(const BreakLoading());

      final activeBreak = await _breakService.getActiveBreakSession(_userId);
      final history = await _breakService.getTodaysBreakSessions(_userId);

      if (activeBreak != null) {
        emit(BreakActive(activeBreak, breakHistory: history));
      } else {
        emit(BreakInactive(history));
      }
    } catch (e) {
      emit(BreakError('Failed to check active break: ${e.toString()}'));
    }
  }

  bool get isOnBreak {
    final currentState = state;
    return currentState is BreakActive;
  }

  BreakSession? get currentBreak {
    final currentState = state;
    if (currentState is BreakActive) {
      return currentState.activeBreak;
    } else if (currentState is BreakStatisticsLoaded) {
      return currentState.activeBreak;
    }
    return null;
  }

  Duration? get currentBreakDuration {
    final activeBreak = currentBreak;
    if (activeBreak != null && activeBreak.isActive) {
      return activeBreak.actualDuration;
    }
    return null;
  }
}
