import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load initial dashboard data
class LoadDashboardData extends DashboardEvent {
  final DateTime selectedDate;

  const LoadDashboardData({required this.selectedDate});

  @override
  List<Object?> get props => [selectedDate];
}

/// Event to refresh all dashboard data
class RefreshDashboardData extends DashboardEvent {
  const RefreshDashboardData();
}

/// Event to change the selected date
class ChangeDashboardDate extends DashboardEvent {
  final DateTime selectedDate;

  const ChangeDashboardDate({required this.selectedDate});

  @override
  List<Object?> get props => [selectedDate];
}

/// Event to request new loan assignments
class RequestLoanAssignments extends DashboardEvent {
  const RequestLoanAssignments();
}

/// Event to load user session data
class LoadUserSession extends DashboardEvent {
  const LoadUserSession();
}

/// Event to initialize dashboard services
class InitializeDashboardServices extends DashboardEvent {
  const InitializeDashboardServices();
}
