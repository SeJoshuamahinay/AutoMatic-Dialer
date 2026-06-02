import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../commons/models/call_log_model.dart';
import '../../commons/services/call_log_service.dart';
import '../../commons/services/break_service.dart';
import '../../commons/services/shared_prefs_storage_service.dart';
import '../../commons/services/accounts_bucket_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final CallLogService _callLogService = CallLogService();
  final BreakService _breakService;

  DashboardBloc(this._breakService) : super(const DashboardInitial()) {
    on<InitializeDashboardServices>(_onInitializeDashboardServices);
    on<LoadUserSession>(_onLoadUserSession);
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<ChangeDashboardDate>(_onChangeDashboardDate);
    on<RefreshDialerStats>(_onRefreshDialerStats);
  }

  Future<void> _onInitializeDashboardServices(
    InitializeDashboardServices event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await _callLogService.initialize();
      debugPrint('✅ Dashboard services initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing dashboard services: $e');
    }
  }

  Future<void> _onLoadUserSession(
    LoadUserSession event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final userSession = await SharedPrefsStorageService.getUserSession();

      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        emit(currentState.copyWith(userSession: userSession));
      } else {
        emit(
          DashboardLoaded(
            selectedDate: DateTime.now(),
            callLogs: const [],
            breakSessions: const [],
            dailyStats: const {},
            userSession: userSession,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading user session: $e');
    }
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final currentUserSession = state is DashboardLoaded
        ? (state as DashboardLoaded).userSession
        : null;
    final currentDialerStats = state is DashboardLoaded
        ? (state as DashboardLoaded).dialerStats
        : null;

    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(isLoadingData: true));
    } else {
      emit(const DashboardLoading());
    }

    try {
      final userId = currentUserSession?.userId ?? 1;

      final startOfDay = DateTime(
        event.selectedDate.year,
        event.selectedDate.month,
        event.selectedDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      List<CallLog> callLogs = [];
      try {
        callLogs = await _callLogService
            .getCallHistory(
              userId: userId,
              startDate: startOfDay,
              endDate: endOfDay,
            )
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('❌ Call history failed: $e');
      }

      Map<String, dynamic> dailyStats = {};
      try {
        dailyStats = await _callLogService
            .getStatsForDate(userId, event.selectedDate)
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('❌ Daily stats failed: $e');
        try {
          dailyStats = await _callLogService
              .getTodaysStats(userId)
              .timeout(const Duration(seconds: 5));
        } catch (_) {}
      }

      final breakSessions = await _breakService.getBreakSessionsForDate(
        1,
        event.selectedDate,
      );

      emit(
        DashboardLoaded(
          selectedDate: event.selectedDate,
          callLogs: callLogs,
          breakSessions: breakSessions,
          dailyStats: dailyStats,
          userSession: currentUserSession,
          dialerStats: currentDialerStats,
          isLoadingData: false,
        ),
      );

      // Load dialer stats in the same async event handler so emit stays valid.
      await _loadDialerStats(currentUserSession?.userId, emit);
    } catch (e) {
      debugPrint('❌ Dashboard data loading failed: $e');
      emit(
        DashboardError(
          message: 'Failed to load dashboard data: $e',
          selectedDate: event.selectedDate,
          userSession: currentUserSession,
          dialerStats: currentDialerStats,
        ),
      );
    }
  }

  Future<void> _loadDialerStats(
    int? userId,
    Emitter<DashboardState> emit,
  ) async {
    if (userId == null) return;
    if (state is! DashboardLoaded) return;
    if (emit.isDone) return;

    final currentState = state as DashboardLoaded;
    emit(currentState.copyWith(isLoadingStats: true));

    try {
      final stats = await AccountsBucketService.getDialerStats(
        userId.toString(),
      );
      if (!emit.isDone && state is DashboardLoaded) {
        emit(
          (state as DashboardLoaded).copyWith(
            dialerStats: stats,
            isLoadingStats: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to load dialer stats: $e');
      if (!emit.isDone && state is DashboardLoaded) {
        emit((state as DashboardLoaded).copyWith(isLoadingStats: false));
      }
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final selectedDate = state is DashboardLoaded
        ? (state as DashboardLoaded).selectedDate
        : DateTime.now();
    add(LoadDashboardData(selectedDate: selectedDate));
  }

  Future<void> _onChangeDashboardDate(
    ChangeDashboardDate event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadDashboardData(selectedDate: event.selectedDate));
  }

  Future<void> _onRefreshDialerStats(
    RefreshDialerStats event,
    Emitter<DashboardState> emit,
  ) async {
    final userId = state is DashboardLoaded
        ? (state as DashboardLoaded).userSession?.userId
        : null;
    if (userId == null) return;

    if (emit.isDone) return;
    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(isLoadingStats: true));
    }

    try {
      final stats = await AccountsBucketService.getDialerStats(
        userId.toString(),
      );
      if (!emit.isDone && state is DashboardLoaded) {
        emit(
          (state as DashboardLoaded).copyWith(
            dialerStats: stats,
            isLoadingStats: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to refresh dialer stats: $e');
      if (!emit.isDone && state is DashboardLoaded) {
        emit((state as DashboardLoaded).copyWith(isLoadingStats: false));
      }
    }
  }
}
