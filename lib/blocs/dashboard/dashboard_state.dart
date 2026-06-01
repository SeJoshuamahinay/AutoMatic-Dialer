import 'package:equatable/equatable.dart';
import '../../commons/models/call_log_model.dart';
import '../../commons/models/break_session_model.dart';
import '../../commons/models/auth_models.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state when dashboard is first created
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// State when dashboard is loading data
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// State when dashboard data is loaded successfully
class DashboardLoaded extends DashboardState {
  final DateTime selectedDate;
  final List<CallLog> callLogs;
  final List<BreakSession> breakSessions;
  final Map<String, dynamic> dailyStats;
  final UserSession? userSession;
  /// Dialer stats from GET /api/lenderly/dialer/stats
  /// Shape: {total_loans, total_outstanding, buckets: {frontend: {count, total_outstanding}, ...}}
  final Map<String, dynamic>? dialerStats;
  final bool isLoadingData;
  final bool isLoadingStats;

  const DashboardLoaded({
    required this.selectedDate,
    required this.callLogs,
    required this.breakSessions,
    required this.dailyStats,
    this.userSession,
    this.dialerStats,
    this.isLoadingData = false,
    this.isLoadingStats = false,
  });

  @override
  List<Object?> get props => [
    selectedDate,
    callLogs,
    breakSessions,
    dailyStats,
    userSession,
    dialerStats,
    isLoadingData,
    isLoadingStats,
  ];

  DashboardLoaded copyWith({
    DateTime? selectedDate,
    List<CallLog>? callLogs,
    List<BreakSession>? breakSessions,
    Map<String, dynamic>? dailyStats,
    UserSession? userSession,
    Map<String, dynamic>? dialerStats,
    bool? isLoadingData,
    bool? isLoadingStats,
  }) {
    return DashboardLoaded(
      selectedDate: selectedDate ?? this.selectedDate,
      callLogs: callLogs ?? this.callLogs,
      breakSessions: breakSessions ?? this.breakSessions,
      dailyStats: dailyStats ?? this.dailyStats,
      userSession: userSession ?? this.userSession,
      dialerStats: dialerStats ?? this.dialerStats,
      isLoadingData: isLoadingData ?? this.isLoadingData,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
    );
  }
}

/// State when there's an error loading dashboard data
class DashboardError extends DashboardState {
  final String message;
  final DateTime selectedDate;
  final List<CallLog> callLogs;
  final List<BreakSession> breakSessions;
  final Map<String, dynamic> dailyStats;
  final UserSession? userSession;
  final Map<String, dynamic>? dialerStats;

  const DashboardError({
    required this.message,
    required this.selectedDate,
    this.callLogs = const [],
    this.breakSessions = const [],
    this.dailyStats = const {},
    this.userSession,
    this.dialerStats,
  });

  @override
  List<Object?> get props => [
    message,
    selectedDate,
    callLogs,
    breakSessions,
    dailyStats,
    userSession,
    dialerStats,
  ];
}
