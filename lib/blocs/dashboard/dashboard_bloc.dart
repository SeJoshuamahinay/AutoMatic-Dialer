import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../commons/models/call_log_model.dart';
// import '../../commons/models/break_session_model.dart';
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
    on<RequestLoanAssignments>(_onRequestLoanAssignments);
  }

  /// Initialize dashboard services
  Future<void> _onInitializeDashboardServices(
    InitializeDashboardServices event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await _callLogService.initialize();
      debugPrint('✅ Dashboard services initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing dashboard services: $e');
      // Don't emit error state here, let the dashboard continue
      // The individual data loading will handle service errors
    }
  }

  /// Load user session data
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
        // If not in loaded state, emit loaded state with minimal data
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
      // Don't emit error state for user session failures
    }
  }

  /// Load dashboard data for a specific date
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    // Preserve current data if we're already in a loaded state
    final currentUserSession = state is DashboardLoaded
        ? (state as DashboardLoaded).userSession
        : null;
    final currentAssignmentData = state is DashboardLoaded
        ? (state as DashboardLoaded).assignmentData
        : null;

    // Emit loading state with current data preserved
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(isLoadingData: true));
    } else {
      emit(const DashboardLoading());
    }

    try {
      // Initialize service if needed
      try {
        await _callLogService.initialize();
      } catch (e) {
        debugPrint('❌ Failed to initialize CallLogService: $e');
      }

      final userId = currentUserSession?.userId ?? 1;

      // Prepare date range for selected date
      final startOfDay = DateTime(
        event.selectedDate.year,
        event.selectedDate.month,
        event.selectedDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Load call logs
      List<CallLog> callLogs = [];
      try {
        callLogs = await _callLogService
            .getCallHistory(
              userId: userId,
              startDate: startOfDay,
              endDate: endOfDay,
            )
            .timeout(const Duration(seconds: 5));
        debugPrint(
          '✅ Loaded ${callLogs.length} call logs for ${event.selectedDate.toIso8601String().split('T')[0]}',
        );
      } catch (e) {
        debugPrint('❌ Call history failed: $e');
        callLogs = [];
      }

      // Load daily stats
      Map<String, dynamic> dailyStats = {};
      try {
        dailyStats = await _callLogService
            .getStatsForDate(userId, event.selectedDate)
            .timeout(const Duration(seconds: 5));
        debugPrint('✅ Loaded daily stats: $dailyStats');
      } catch (e) {
        debugPrint('❌ Daily stats failed: $e');
        // Fallback to today's stats if selected date stats fail
        try {
          dailyStats = await _callLogService
              .getTodaysStats(userId)
              .timeout(const Duration(seconds: 5));
          debugPrint('✅ Loaded fallback today stats: $dailyStats');
        } catch (e2) {
          debugPrint('❌ Fallback stats also failed: $e2');
          dailyStats = {};
        }
      }

      // Load break sessions for the selected date
      // For now, use a default user ID of 1 - in real app this would come from auth
      final breakSessions = await _breakService.getBreakSessionsForDate(
        1,
        event.selectedDate,
      );

      // Emit successful loaded state
      emit(
        DashboardLoaded(
          selectedDate: event.selectedDate,
          callLogs: callLogs,
          breakSessions: breakSessions,
          dailyStats: dailyStats,
          userSession: currentUserSession,
          assignmentData: currentAssignmentData,
          isLoadingData: false,
        ),
      );

      debugPrint(
        '✅ Dashboard data loaded successfully: ${callLogs.length} calls, stats: $dailyStats',
      );
    } catch (e) {
      debugPrint('❌ Dashboard data loading failed: $e');
      emit(
        DashboardError(
          message: 'Failed to load dashboard data: $e',
          selectedDate: event.selectedDate,
          userSession: currentUserSession,
          assignmentData: currentAssignmentData,
        ),
      );
    }
  }

  /// Refresh dashboard data
  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final selectedDate = state is DashboardLoaded
        ? (state as DashboardLoaded).selectedDate
        : DateTime.now();

    add(LoadDashboardData(selectedDate: selectedDate));
  }

  /// Change the selected date and load data for that date
  Future<void> _onChangeDashboardDate(
    ChangeDashboardDate event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadDashboardData(selectedDate: event.selectedDate));
  }

  /// Request new loan assignments
  Future<void> _onRequestLoanAssignments(
    RequestLoanAssignments event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) {
      emit(
        DashboardAssignmentError(
          message: 'Dashboard not ready for assignment requests',
          selectedDate: DateTime.now(),
        ),
      );
      return;
    }

    final currentState = state as DashboardLoaded;

    if (currentState.userSession?.userId == null) {
      emit(
        DashboardAssignmentError(
          message: 'Please log in to request account data',
          selectedDate: currentState.selectedDate,
          callLogs: currentState.callLogs,
          breakSessions: currentState.breakSessions,
          dailyStats: currentState.dailyStats,
          userSession: currentState.userSession,
          assignmentData: currentState.assignmentData,
        ),
      );
      return;
    }

    if (currentState.isRequestingAssignments) {
      return; // Already requesting
    }

    // Emit loading state for assignments
    emit(currentState.copyWith(isRequestingAssignments: true));

    try {
      final response = await AccountsBucketService.assignLoansToUser(
        currentState.userSession!.userId.toString(),
      );

      if (response.success && response.data != null) {
        emit(
          DashboardAssignmentSuccess(
            message:
                'Successfully assigned ${response.data!.totalLoansCount} accounts',
            assignmentData: response.data!,
            selectedDate: currentState.selectedDate,
            callLogs: currentState.callLogs,
            breakSessions: currentState.breakSessions,
            dailyStats: currentState.dailyStats,
            userSession: currentState.userSession,
          ),
        );
      } else {
        emit(
          DashboardAssignmentError(
            message: 'Failed to assign accounts: ${response.message}',
            selectedDate: currentState.selectedDate,
            callLogs: currentState.callLogs,
            breakSessions: currentState.breakSessions,
            dailyStats: currentState.dailyStats,
            userSession: currentState.userSession,
            assignmentData: currentState.assignmentData,
          ),
        );
      }
    } catch (e) {
      emit(
        DashboardAssignmentError(
          message: 'Error requesting account data: $e',
          selectedDate: currentState.selectedDate,
          callLogs: currentState.callLogs,
          breakSessions: currentState.breakSessions,
          dailyStats: currentState.dailyStats,
          userSession: currentState.userSession,
          assignmentData: currentState.assignmentData,
        ),
      );
    }
  }
}
