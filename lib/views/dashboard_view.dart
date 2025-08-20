import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import '../commons/models/call_log_model.dart';
import '../commons/models/break_session_model.dart';
import '../commons/models/loan_models.dart';
import '../commons/models/auth_models.dart';
import '../commons/services/accounts_bucket_service.dart';
import '../commons/utils/gesture_error_handler.dart';
import '../commons/widgets/database_seeder_widget.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/dashboard/dashboard_event.dart';
import '../blocs/dashboard/dashboard_state.dart';
import 'front_end_view.dart';
import 'mid_range_view.dart';
import 'hardcore_view.dart';

/// Dashboard View using Bloc pattern with BlocConsumer
///
/// This widget demonstrates the proper use of Bloc for state management:
/// - BlocConsumer handles both UI updates and side effects
/// - State is managed entirely through the DashboardBloc
/// - Business logic is separated from UI logic
/// - Events are dispatched to trigger state changes
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Flag to detect if we're in test environment
  bool get _isInTestEnvironment => EnvironmentConfig.isDevelopment;

  @override
  void initState() {
    super.initState();
    // Initialize dashboard using Bloc events
    _initializeDashboard();
  }

  /// Initialize dashboard by dispatching events to the bloc
  void _initializeDashboard() {
    final bloc = context.read<DashboardBloc>();
    bloc
      ..add(const InitializeDashboardServices())
      ..add(const LoadUserSession())
      ..add(LoadDashboardData(selectedDate: DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return GestureErrorHandler.safeIconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context, state),
                tooltip: 'Select Date',
              );
            },
          ),
          GestureErrorHandler.safeIconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(context),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          // Handle side effects based on state changes
          _handleStateChange(context, state);
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => _refreshData(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentTimeCard(),
                  const SizedBox(height: 16),
                  _buildTodaysCallStatsCard(state),
                  const SizedBox(height: 16),
                  _buildLoanAssignmentCard(context, state),
                  const SizedBox(height: 16),
                  _buildOverallAnalytics(state),
                  const SizedBox(height: 16),
                  _buildBucketBreakdown(context, state),
                  const SizedBox(height: 16),
                  _buildCallStatusBreakdown(state),
                  const SizedBox(height: 16),
                  _buildRecentCallLogs(state),
                  const SizedBox(height: 16),
                  _buildBreakTimeAnalysis(state),
                  const SizedBox(height: 16),
                  // Show database seeder in debug mode only
                  if (kDebugMode && _isInTestEnvironment) ...[
                    DatabaseSeederWidget(
                      onDataChanged: () => _refreshData(context),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Handle state changes and show appropriate UI feedback
  void _handleStateChange(BuildContext context, DashboardState state) {
    if (state is DashboardAssignmentSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.green),
      );
    } else if (state is DashboardAssignmentError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    } else if (state is DashboardError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Select a date and trigger data loading for that date
  Future<void> _selectDate(BuildContext context, DashboardState state) async {
    final currentDate = _getSelectedDate(state);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != currentDate) {
      context.read<DashboardBloc>().add(
        ChangeDashboardDate(selectedDate: picked),
      );
    }
  }

  /// Refresh dashboard data
  void _refreshData(BuildContext context) {
    context.read<DashboardBloc>().add(const RefreshDashboardData());
  }

  /// Request new loan assignments
  void _requestAccountData(BuildContext context) {
    context.read<DashboardBloc>().add(const RequestLoanAssignments());
  }

  /// Navigate to bucket view
  void _navigateToBucket(
    BuildContext context,
    BucketType bucketType,
    AssignmentData? assignmentData,
  ) {
    if (assignmentData == null) return;

    Widget targetView;
    switch (bucketType) {
      case BucketType.frontend:
        targetView = FrontEndView(assignmentData: assignmentData);
        break;
      case BucketType.middlecore:
        targetView = MidRangeView(assignmentData: assignmentData);
        break;
      case BucketType.hardcore:
        targetView = HardcoreView(assignmentData: assignmentData);
        break;
    }

    GestureErrorHandler.safeNavigate(context, targetView);
  }

  /// Extract selected date from state
  DateTime _getSelectedDate(DashboardState state) {
    if (state is DashboardLoaded) return state.selectedDate;
    if (state is DashboardError) return state.selectedDate;
    if (state is DashboardAssignmentSuccess) return state.selectedDate;
    if (state is DashboardAssignmentError) return state.selectedDate;
    return DateTime.now();
  }

  /// Extract data from state for UI building
  ({
    DateTime selectedDate,
    List<CallLog> callLogs,
    List<BreakSession> breakSessions,
    Map<String, dynamic> dailyStats,
    UserSession? userSession,
    AssignmentData? assignmentData,
    bool isLoadingData,
    bool isRequestingAssignments,
  })
  _getStateData(DashboardState state) {
    if (state is DashboardLoaded) {
      return (
        selectedDate: state.selectedDate,
        callLogs: state.callLogs,
        breakSessions: state.breakSessions,
        dailyStats: state.dailyStats,
        userSession: state.userSession,
        assignmentData: state.assignmentData,
        isLoadingData: state.isLoadingData,
        isRequestingAssignments: state.isRequestingAssignments,
      );
    } else if (state is DashboardError) {
      return (
        selectedDate: state.selectedDate,
        callLogs: state.callLogs,
        breakSessions: state.breakSessions,
        dailyStats: state.dailyStats,
        userSession: state.userSession,
        assignmentData: state.assignmentData,
        isLoadingData: false,
        isRequestingAssignments: false,
      );
    } else if (state is DashboardAssignmentSuccess) {
      return (
        selectedDate: state.selectedDate,
        callLogs: state.callLogs,
        breakSessions: state.breakSessions,
        dailyStats: state.dailyStats,
        userSession: state.userSession,
        assignmentData: state.assignmentData,
        isLoadingData: false,
        isRequestingAssignments: false,
      );
    } else if (state is DashboardAssignmentError) {
      return (
        selectedDate: state.selectedDate,
        callLogs: state.callLogs,
        breakSessions: state.breakSessions,
        dailyStats: state.dailyStats,
        userSession: state.userSession,
        assignmentData: state.assignmentData,
        isLoadingData: false,
        isRequestingAssignments: false,
      );
    } else {
      // Default fallback for DashboardInitial or DashboardLoading
      return (
        selectedDate: DateTime.now(),
        callLogs: <CallLog>[],
        breakSessions: <BreakSession>[],
        dailyStats: <String, dynamic>{},
        userSession: null,
        assignmentData: null,
        isLoadingData: state is DashboardLoading,
        isRequestingAssignments: false,
      );
    }
  }

  // ===================
  // UI BUILDING METHODS
  // ===================

  /// Build current time card
  Widget _buildCurrentTimeCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.access_time, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                final now = DateTime.now();
                final hour12 = now.hour == 0
                    ? 12
                    : (now.hour > 12 ? now.hour - 12 : now.hour);
                final amPm = now.hour >= 12 ? 'PM' : 'AM';

                return Column(
                  children: [
                    Text(
                      '${hour12.toString()}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $amPm',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_getDayName(now.weekday)}, ${_getMonthName(now.month)} ${now.day}, ${now.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build today's call stats card using state data
  Widget _buildTodaysCallStatsCard(DashboardState state) {
    final stateData = _getStateData(state);

    if (stateData.isLoadingData) {
      return Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Calculate stats from daily statistics or call logs
    final totalCalls =
        stateData.dailyStats['total_calls'] ?? stateData.callLogs.length;
    final successfulCalls =
        stateData.dailyStats['successful_calls'] ??
        stateData.callLogs
            .where((log) => log.status == CallStatus.finished)
            .length;
    final failedCalls =
        stateData.dailyStats['failed_calls'] ??
        stateData.callLogs
            .where((log) => log.status == CallStatus.hangUp)
            .length;
    final noAnswerCalls =
        stateData.dailyStats['no_answer_calls'] ??
        stateData.callLogs
            .where((log) => log.status == CallStatus.noAnswer)
            .length;
    final totalBreakTime =
        stateData.dailyStats['total_break_time_minutes'] ?? 0;

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text(
                  "Today's Call Activity",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Calls',
                    totalCalls.toString(),
                    Icons.call,
                    Colors.white,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Successful',
                    successfulCalls.toString(),
                    Icons.check_circle,
                    Colors.green.shade200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Failed/Hung Up',
                    failedCalls.toString(),
                    Icons.call_end,
                    Colors.red.shade200,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'No Answer',
                    noAnswerCalls.toString(),
                    Icons.phone_missed,
                    Colors.orange.shade200,
                  ),
                ),
              ],
            ),
            if (totalBreakTime > 0) ...[
              const SizedBox(height: 16),
              _buildStatItem(
                'Break Time',
                '${totalBreakTime}m',
                Icons.timer,
                Colors.yellow.shade200,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build loan assignment card using state data
  Widget _buildLoanAssignmentCard(BuildContext context, DashboardState state) {
    final stateData = _getStateData(state);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Account Assignments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (stateData.isRequestingAssignments)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (stateData.assignmentData == null) ...[
              // No assignments yet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_download,
                      color: Colors.blue,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No accounts assigned yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Request new account assignments to start dialing',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: stateData.isRequestingAssignments
                            ? null
                            : () => _requestAccountData(context),
                        icon: Icon(
                          stateData.isRequestingAssignments
                              ? Icons.hourglass_top
                              : Icons.download,
                        ),
                        label: Text(
                          stateData.isRequestingAssignments
                              ? 'Requesting...'
                              : 'Request Assignments',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show assignment data
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAssignmentStat(
                          'Total Loans',
                          '${stateData.assignmentData!.totalLoansCount}',
                          Icons.folder,
                          Colors.blue,
                        ),
                        _buildAssignmentStat(
                          'Dialable',
                          '${stateData.assignmentData!.dialableLoans.length}',
                          Icons.phone,
                          Colors.green,
                        ),
                        _buildAssignmentStat(
                          'Assigned',
                          _formatDateTime(stateData.assignmentData!.assignedAt),
                          Icons.schedule,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Bucket navigation
              Row(
                children: [
                  Expanded(
                    child: _buildBucketButton(
                      'Frontend',
                      stateData.assignmentData!.getCountForBucket(
                        BucketType.frontend,
                      ),
                      stateData.assignmentData!.getDialableCountForBucket(
                        BucketType.frontend,
                      ),
                      Colors.green,
                      Icons.trending_up,
                      BucketType.frontend,
                      context,
                      stateData.assignmentData,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildBucketButton(
                      'Middlecore',
                      stateData.assignmentData!.getCountForBucket(
                        BucketType.middlecore,
                      ),
                      stateData.assignmentData!.getDialableCountForBucket(
                        BucketType.middlecore,
                      ),
                      Colors.orange,
                      Icons.warning,
                      BucketType.middlecore,
                      context,
                      stateData.assignmentData,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildBucketButton(
                      'Hardcore',
                      stateData.assignmentData!.getCountForBucket(
                        BucketType.hardcore,
                      ),
                      stateData.assignmentData!.getDialableCountForBucket(
                        BucketType.hardcore,
                      ),
                      Colors.red,
                      Icons.priority_high,
                      BucketType.hardcore,
                      context,
                      stateData.assignmentData,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Refresh button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: stateData.isRequestingAssignments
                      ? null
                      : () => _requestAccountData(context),
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    stateData.isRequestingAssignments
                        ? 'Requesting...'
                        : 'Refresh Assignments',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build overall analytics section
  Widget _buildOverallAnalytics(DashboardState state) {
    final stateData = _getStateData(state);

    if (stateData.assignmentData == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.purple, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Overall Analytics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Analytics will be available once you have account assignments',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate real statistics from assignment data
    final frontendStats = AccountsBucketService.getBucketStatistics(
      stateData.assignmentData!,
      BucketType.frontend,
    );
    final midRangeStats = AccountsBucketService.getBucketStatistics(
      stateData.assignmentData!,
      BucketType.middlecore,
    );
    final hardcoreStats = AccountsBucketService.getBucketStatistics(
      stateData.assignmentData!,
      BucketType.hardcore,
    );

    final totalContacts = stateData.assignmentData!.totalLoansCount;
    final totalDialable =
        (frontendStats['dialable_count'] ?? 0) +
        (midRangeStats['dialable_count'] ?? 0) +
        (hardcoreStats['dialable_count'] ?? 0);
    final totalCoMakers =
        (frontendStats['co_maker_phone_count'] ?? 0) +
        (midRangeStats['co_maker_phone_count'] ?? 0) +
        (hardcoreStats['co_maker_phone_count'] ?? 0);
    final totalBorrowers =
        (frontendStats['borrower_phone_count'] ?? 0) +
        (midRangeStats['borrower_phone_count'] ?? 0) +
        (hardcoreStats['borrower_phone_count'] ?? 0);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Overall Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    title: 'Total Contacts',
                    value: totalContacts.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    title: 'Dialable',
                    value: totalDialable.toString(),
                    icon: Icons.phone_enabled,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    title: 'Co-makers',
                    value: totalCoMakers.toString(),
                    icon: Icons.person_add,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    title: 'Borrowers',
                    value: totalBorrowers.toString(),
                    icon: Icons.person,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build bucket breakdown section
  Widget _buildBucketBreakdown(BuildContext context, DashboardState state) {
    final stateData = _getStateData(state);

    if (stateData.assignmentData == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_open, color: Colors.indigo, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Bucket Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildBucketBreakdownRow(
                  'Frontend',
                  AccountsBucketService.getBucketStatistics(
                    stateData.assignmentData!,
                    BucketType.frontend,
                  ),
                  Colors.green,
                  Icons.trending_up,
                  BucketType.frontend,
                  context,
                  stateData.assignmentData,
                ),
                const SizedBox(height: 12),
                _buildBucketBreakdownRow(
                  'Middlecore',
                  AccountsBucketService.getBucketStatistics(
                    stateData.assignmentData!,
                    BucketType.middlecore,
                  ),
                  Colors.orange,
                  Icons.warning,
                  BucketType.middlecore,
                  context,
                  stateData.assignmentData,
                ),
                const SizedBox(height: 12),
                _buildBucketBreakdownRow(
                  'Hardcore',
                  AccountsBucketService.getBucketStatistics(
                    stateData.assignmentData!,
                    BucketType.hardcore,
                  ),
                  Colors.red,
                  Icons.priority_high,
                  BucketType.hardcore,
                  context,
                  stateData.assignmentData,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build call status breakdown section
  Widget _buildCallStatusBreakdown(DashboardState state) {
    final stateData = _getStateData(state);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment, color: Colors.teal, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Call Status Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stateData.isLoadingData)
              const Center(child: CircularProgressIndicator())
            else ...[
              ..._buildCallStatusRows(stateData),
            ],
          ],
        ),
      ),
    );
  }

  /// Build break time analysis section
  Widget _buildBreakTimeAnalysis(DashboardState state) {
    final stateData = _getStateData(state);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pause_circle, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Break Time Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stateData.isLoadingData)
              const Center(child: CircularProgressIndicator())
            else ...[
              ..._buildBreakSessionsList(stateData),
            ],
          ],
        ),
      ),
    );
  }

  /// Build recent call logs section
  Widget _buildRecentCallLogs(DashboardState state) {
    final stateData = _getStateData(state);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.cyan, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Recent Call Logs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stateData.isLoadingData)
              const Center(child: CircularProgressIndicator())
            else ...[
              ..._buildRecentCallsList(stateData),
            ],
          ],
        ),
      ),
    );
  }

  // =================
  // HELPER METHODS
  // =================

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAssignmentStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBucketButton(
    String title,
    int totalCount,
    int dialableCount,
    Color color,
    IconData icon,
    BucketType bucketType,
    BuildContext context,
    AssignmentData? assignmentData,
  ) {
    return Material(
      color: totalCount > 0
          ? color.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: totalCount > 0 && assignmentData != null
            ? () => _navigateToBucket(context, bucketType, assignmentData)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: totalCount > 0 ? color : Colors.grey, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: totalCount > 0 ? color : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: totalCount > 0 ? color : Colors.grey,
                ),
              ),
              if (dialableCount > 0)
                Text(
                  '($dialableCount dialable)',
                  style: const TextStyle(fontSize: 10, color: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBucketBreakdownRow(
    String title,
    Map<String, dynamic> stats,
    Color color,
    IconData icon,
    BucketType bucketType,
    BuildContext context,
    AssignmentData? assignmentData,
  ) {
    final totalContacts = stats['total_loans'] ?? 0;
    final dialableCount = stats['dialable_count'] ?? 0;
    final coMakerCount = stats['co_maker_phone_count'] ?? 0;
    final borrowerCount = stats['borrower_phone_count'] ?? 0;

    return GestureDetector(
      onTap: totalContacts > 0
          ? () => _navigateToBucket(context, bucketType, assignmentData)
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: totalContacts > 0
              ? color.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: totalContacts > 0
                ? color.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: totalContacts > 0 ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: totalContacts > 0 ? color : Colors.grey,
                    ),
                  ),
                  Text(
                    'Total: $totalContacts | Dialable: $dialableCount',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'CM: $coMakerCount',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'B: $borrowerCount',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (totalContacts > 0) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCallStatusRows(
    ({
      DateTime selectedDate,
      List<CallLog> callLogs,
      List<BreakSession> breakSessions,
      Map<String, dynamic> dailyStats,
      UserSession? userSession,
      AssignmentData? assignmentData,
      bool isLoadingData,
      bool isRequestingAssignments,
    })
    stateData,
  ) {
    final todaysCalls = stateData.callLogs
        .where(
          (log) =>
              log.callTime.day == stateData.selectedDate.day &&
              log.callTime.month == stateData.selectedDate.month &&
              log.callTime.year == stateData.selectedDate.year,
        )
        .toList();

    if (todaysCalls.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No calls made today',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return CallStatus.values.map((status) {
      final count = todaysCalls.where((log) => log.status == status).length;
      final percentage = todaysCalls.isEmpty
          ? 0.0
          : (count / todaysCalls.length);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _buildStatusRow(status, count, percentage),
      );
    }).toList();
  }

  List<Widget> _buildBreakSessionsList(
    ({
      DateTime selectedDate,
      List<CallLog> callLogs,
      List<BreakSession> breakSessions,
      Map<String, dynamic> dailyStats,
      UserSession? userSession,
      AssignmentData? assignmentData,
      bool isLoadingData,
      bool isRequestingAssignments,
    })
    stateData,
  ) {
    final todaysBreaks = stateData.breakSessions
        .where(
          (session) =>
              session.startTime.day == stateData.selectedDate.day &&
              session.startTime.month == stateData.selectedDate.month &&
              session.startTime.year == stateData.selectedDate.year,
        )
        .toList();

    if (todaysBreaks.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No break sessions today',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return todaysBreaks
        .map((breakSession) => _buildBreakSessionTile(breakSession))
        .toList();
  }

  List<Widget> _buildRecentCallsList(
    ({
      DateTime selectedDate,
      List<CallLog> callLogs,
      List<BreakSession> breakSessions,
      Map<String, dynamic> dailyStats,
      UserSession? userSession,
      AssignmentData? assignmentData,
      bool isLoadingData,
      bool isRequestingAssignments,
    })
    stateData,
  ) {
    final recentCalls = stateData.callLogs.take(5).toList();

    if (recentCalls.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No recent calls',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return recentCalls.map((callLog) => _buildCallLogTile(callLog)).toList();
  }

  Widget _buildStatusRow(CallStatus status, int count, double percentage) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case CallStatus.finished:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case CallStatus.noAnswer:
        statusColor = Colors.orange;
        statusIcon = Icons.phone_missed;
        break;
      case CallStatus.hangUp:
        statusColor = Colors.red;
        statusIcon = Icons.call_end;
        break;
      case CallStatus.pending:
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.phone;
    }

    return Row(
      children: [
        Icon(statusIcon, color: statusColor, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(status.displayName)),
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: percentage,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(percentage * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBreakSessionTile(BreakSession breakSession) {
    return ListTile(
      leading: Icon(_getBreakTypeIcon(breakSession.type), color: Colors.orange),
      title: Text(breakSession.type.name),
      subtitle: Text(
        '${_formatTime(breakSession.startTime)} - ${breakSession.endTime != null ? _formatTime(breakSession.endTime!) : 'Ongoing'}',
      ),
      trailing: Text(
        _formatDuration(breakSession.actualDuration),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCallLogTile(CallLog callLog) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: Icon(
          _getCallStatusIcon(callLog.status),
          color: _getCallStatusColor(callLog.status),
        ),
        title: Text(
          callLog.borrowerName?.isNotEmpty == true
              ? callLog.borrowerName!
              : 'Loan #${callLog.loanID}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loan #${callLog.loanID}'),
            Text(_formatTime(callLog.callTime)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCallStatusColor(callLog.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            callLog.status.displayName,
            style: TextStyle(
              color: _getCallStatusColor(callLog.status),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Call ID', callLog.id?.toString() ?? 'N/A'),
                _buildDetailRow('Loan ID', callLog.loanID?.toString() ?? 'N/A'),
                if (callLog.borrowerName?.isNotEmpty == true)
                  _buildDetailRow('Borrower Name', callLog.borrowerName!),
                if (callLog.borrowerPhone?.isNotEmpty == true)
                  _buildDetailRow('Phone Number', callLog.borrowerPhone!),
                _buildDetailRow(
                  'Call Time',
                  _formatFullDateTime(callLog.callTime),
                ),
                _buildDetailRow(
                  'Duration',
                  callLog.callDuration != null
                      ? _formatDetailedDuration(callLog.callDuration!)
                      : 'N/A',
                ),
                _buildDetailRow(
                  'Status',
                  _getStatusDescription(callLog.status),
                ),
                if (callLog.notes?.isNotEmpty == true)
                  _buildDetailRow('Notes', callLog.notes!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // =====================
  // FORMATTING UTILITIES
  // =====================

  String _getStatusDescription(CallStatus status) {
    switch (status) {
      case CallStatus.finished:
        return 'Call completed successfully';
      case CallStatus.noAnswer:
        return 'No one answered the call';
      case CallStatus.hangUp:
        return 'Call was ended or hung up';
      case CallStatus.pending:
        return 'Call is scheduled or waiting';
      case CallStatus.called:
        return 'Call was made';
    }
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${_getDayName(dateTime.weekday)}, ${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year} at ${_formatTime(dateTime)}';
  }

  String _formatDetailedDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  IconData _getBreakTypeIcon(BreakType type) {
    switch (type) {
      case BreakType.shortBreak:
        return Icons.coffee;
      case BreakType.lunch:
        return Icons.restaurant;
      case BreakType.meeting:
        return Icons.meeting_room;
      case BreakType.customerSupportBreak:
        return Icons.support_agent;
    }
  }

  IconData _getCallStatusIcon(CallStatus status) {
    switch (status) {
      case CallStatus.finished:
        return Icons.check_circle;
      case CallStatus.noAnswer:
        return Icons.phone_missed;
      case CallStatus.hangUp:
        return Icons.call_end;
      case CallStatus.pending:
        return Icons.pending;
      default:
        return Icons.phone;
    }
  }

  Color _getCallStatusColor(CallStatus status) {
    switch (status) {
      case CallStatus.finished:
        return Colors.green;
      case CallStatus.noAnswer:
        return Colors.orange;
      case CallStatus.hangUp:
        return Colors.red;
      case CallStatus.pending:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour12 = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour12.toString()}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
