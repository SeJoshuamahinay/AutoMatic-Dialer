import 'package:equatable/equatable.dart';
import '../../commons/models/call_log_model.dart';
import '../../commons/models/break_session_model.dart';
import '../../commons/models/loan_models.dart';
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
  final AssignmentData? assignmentData;
  final bool isLoadingData;
  final bool isRequestingAssignments;

  const DashboardLoaded({
    required this.selectedDate,
    required this.callLogs,
    required this.breakSessions,
    required this.dailyStats,
    this.userSession,
    this.assignmentData,
    this.isLoadingData = false,
    this.isRequestingAssignments = false,
  });

  @override
  List<Object?> get props => [
    selectedDate,
    callLogs,
    breakSessions,
    dailyStats,
    userSession,
    assignmentData,
    isLoadingData,
    isRequestingAssignments,
  ];

  /// Create a copy of this state with some fields changed
  DashboardLoaded copyWith({
    DateTime? selectedDate,
    List<CallLog>? callLogs,
    List<BreakSession>? breakSessions,
    Map<String, dynamic>? dailyStats,
    UserSession? userSession,
    AssignmentData? assignmentData,
    bool? isLoadingData,
    bool? isRequestingAssignments,
  }) {
    return DashboardLoaded(
      selectedDate: selectedDate ?? this.selectedDate,
      callLogs: callLogs ?? this.callLogs,
      breakSessions: breakSessions ?? this.breakSessions,
      dailyStats: dailyStats ?? this.dailyStats,
      userSession: userSession ?? this.userSession,
      assignmentData: assignmentData ?? this.assignmentData,
      isLoadingData: isLoadingData ?? this.isLoadingData,
      isRequestingAssignments:
          isRequestingAssignments ?? this.isRequestingAssignments,
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
  final AssignmentData? assignmentData;

  const DashboardError({
    required this.message,
    required this.selectedDate,
    this.callLogs = const [],
    this.breakSessions = const [],
    this.dailyStats = const {},
    this.userSession,
    this.assignmentData,
  });

  @override
  List<Object?> get props => [
    message,
    selectedDate,
    callLogs,
    breakSessions,
    dailyStats,
    userSession,
    assignmentData,
  ];
}

/// State when assignment request is successful
class DashboardAssignmentSuccess extends DashboardState {
  final String message;
  final AssignmentData assignmentData;
  final DateTime selectedDate;
  final List<CallLog> callLogs;
  final List<BreakSession> breakSessions;
  final Map<String, dynamic> dailyStats;
  final UserSession? userSession;

  const DashboardAssignmentSuccess({
    required this.message,
    required this.assignmentData,
    required this.selectedDate,
    required this.callLogs,
    required this.breakSessions,
    required this.dailyStats,
    this.userSession,
  });

  @override
  List<Object?> get props => [
    message,
    assignmentData,
    selectedDate,
    callLogs,
    breakSessions,
    dailyStats,
    userSession,
  ];
}

/// State when assignment request fails
class DashboardAssignmentError extends DashboardState {
  final String message;
  final DateTime selectedDate;
  final List<CallLog> callLogs;
  final List<BreakSession> breakSessions;
  final Map<String, dynamic> dailyStats;
  final UserSession? userSession;
  final AssignmentData? assignmentData;

  const DashboardAssignmentError({
    required this.message,
    required this.selectedDate,
    this.callLogs = const [],
    this.breakSessions = const [],
    this.dailyStats = const {},
    this.userSession,
    this.assignmentData,
  });

  @override
  List<Object?> get props => [
    message,
    selectedDate,
    callLogs,
    breakSessions,
    dailyStats,
    userSession,
    assignmentData,
  ];
}
