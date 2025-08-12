import 'package:flutter/material.dart';
import '../commons/models/call_log_model.dart';
import '../commons/models/break_session_model.dart';
import '../commons/models/loan_models.dart';
import '../commons/models/auth_models.dart';
import '../commons/services/accounts_bucket_service.dart';
import '../commons/services/shared_prefs_storage_service.dart';
import '../commons/utils/gesture_error_handler.dart';
import 'front_end_view.dart';
import 'mid_range_view.dart';
import 'hardcore_view.dart';
import 'dart:math' as math;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  DateTime selectedDate = DateTime.now();

  // Mock data - in real app, this would come from your data source
  final List<CallLog> _mockCallLogs = [];
  final List<BreakSession> _mockBreakSessions = [];

  // Loan assignment data
  UserSession? userSession;
  AssignmentData? assignmentData;
  bool _isRequestingData = false;

  @override
  void initState() {
    super.initState();
    _generateMockData();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final session = await SharedPrefsStorageService.getUserSession();
      if (mounted) {
        setState(() {
          userSession = session;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _requestAccountData() async {
    if (_isRequestingData) return;

    if (userSession?.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to request account data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isRequestingData = true;
    });

    try {
      final response = await AccountsBucketService.assignLoansToUser(
        userSession!.userId.toString(),
      );

      if (mounted) {
        setState(() {
          _isRequestingData = false;
        });

        if (response.success && response.data != null) {
          setState(() {
            assignmentData = response.data;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully assigned ${response.data!.totalLoansCount} accounts',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to assign accounts: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRequestingData = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting account data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _generateMockData() {
    final random = math.Random();
    final now = DateTime.now();

    // Generate mock call logs for today
    for (int i = 0; i < 15; i++) {
      _mockCallLogs.add(
        CallLog(
          id: i,
          contactId: i + 1,
          callTime: now.subtract(Duration(hours: random.nextInt(8))),
          callDuration: Duration(minutes: random.nextInt(10) + 1),
          status: CallStatus.values[random.nextInt(CallStatus.values.length)],
          notes: random.nextBool() ? 'Follow up required' : null,
        ),
      );
    }

    // Generate mock break sessions
    _mockBreakSessions.add(
      BreakSession(
        id: 1,
        type: BreakType.shortBreak,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 2, minutes: -15)),
        isActive: false,
      ),
    );

    _mockBreakSessions.add(
      BreakSession(
        id: 2,
        type: BreakType.lunch,
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 3)),
        isActive: false,
      ),
    );
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
          GestureErrorHandler.safeIconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
          GestureErrorHandler.safeIconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentTimeCard(),
              const SizedBox(height: 16),
              _buildLoanAssignmentCard(),
              const SizedBox(height: 16),
              _buildOverallAnalytics(),
              const SizedBox(height: 16),
              _buildBucketBreakdown(),
              const SizedBox(height: 16),
              _buildCallStatusBreakdown(),
              const SizedBox(height: 16),
              _buildBreakTimeAnalysis(),
              const SizedBox(height: 16),
              _buildRecentCallLogs(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildLoanAssignmentCard() {
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
                if (_isRequestingData)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (assignmentData == null) ...[
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
                      child: GestureErrorHandler.safeElevatedButton(
                        onPressed: _isRequestingData
                            ? null
                            : _requestAccountData,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh),
                            const SizedBox(width: 8),
                            Text(
                              _isRequestingData
                                  ? 'Requesting...'
                                  : 'Request Data',
                            ),
                          ],
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
              // Assignment overview
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
                          'Total',
                          '${assignmentData!.totalLoansCount}',
                          Icons.assignment,
                          Colors.blue,
                        ),
                        _buildAssignmentStat(
                          'Dialable',
                          '${assignmentData!.dialableLoans.length}',
                          Icons.phone,
                          Colors.green,
                        ),
                        _buildAssignmentStat(
                          'Assigned',
                          _formatDateTime(assignmentData!.assignedAt),
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
                      assignmentData!.getCountForBucket(BucketType.frontend),
                      assignmentData!.getDialableCountForBucket(
                        BucketType.frontend,
                      ),
                      Colors.green,
                      Icons.trending_up,
                      BucketType.frontend,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildBucketButton(
                      'Middlecore',
                      assignmentData!.getCountForBucket(BucketType.middlecore),
                      assignmentData!.getDialableCountForBucket(
                        BucketType.middlecore,
                      ),
                      Colors.orange,
                      Icons.warning,
                      BucketType.middlecore,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildBucketButton(
                      'Hardcore',
                      assignmentData!.getCountForBucket(BucketType.hardcore),
                      assignmentData!.getDialableCountForBucket(
                        BucketType.hardcore,
                      ),
                      Colors.red,
                      Icons.priority_high,
                      BucketType.hardcore,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Refresh button
              SizedBox(
                width: double.infinity,
                child: GestureErrorHandler.wrapWithErrorHandler(
                  child: OutlinedButton.icon(
                    onPressed: _isRequestingData ? null : _requestAccountData,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      _isRequestingData
                          ? 'Refreshing...'
                          : 'Refresh Assignments',
                    ),
                  ),
                  fallbackWidget: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _isRequestingData
                              ? 'Refreshing...'
                              : 'Refresh Assignments',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
  ) {
    return GestureErrorHandler.wrapWithErrorHandler(
      child: Material(
        color: totalCount > 0
            ? color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: GestureErrorHandler.safeInkWell(
          onTap: totalCount > 0 && assignmentData != null
              ? () => _navigateToBucket(bucketType)
              : null,
          borderRadius: BorderRadius.circular(8),
          splashColor: color.withValues(alpha: 0.2),
          highlightColor: color.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: totalCount > 0 ? color : Colors.grey,
                  size: 24,
                ),
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
      ),
      fallbackWidget: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$totalCount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallAnalytics() {
    // If no assignment data, show empty state
    if (assignmentData == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.grey),
                  const SizedBox(width: 8),
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
                child: Column(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.grey[400], size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No data available',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Request account assignments to view analytics',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
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
      assignmentData!,
      BucketType.frontend,
    );
    final midRangeStats = AccountsBucketService.getBucketStatistics(
      assignmentData!,
      BucketType.middlecore,
    );
    final hardcoreStats = AccountsBucketService.getBucketStatistics(
      assignmentData!,
      BucketType.hardcore,
    );

    final totalContacts = assignmentData!.totalLoansCount;
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
                const Icon(Icons.analytics, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Overall Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'Last updated: ${_formatTime(assignmentData!.assignedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                    icon: Icons.contacts,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    title: 'Dialable',
                    value: totalDialable.toString(),
                    icon: Icons.phone,
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
                    title: 'Co-Makers',
                    value: totalCoMakers.toString(),
                    icon: Icons.people,
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

  Widget _buildBucketBreakdown() {
    if (assignmentData == null) {
      return const SizedBox.shrink();
    }

    final frontendStats = AccountsBucketService.getBucketStatistics(
      assignmentData!,
      BucketType.frontend,
    );
    final midRangeStats = AccountsBucketService.getBucketStatistics(
      assignmentData!,
      BucketType.middlecore,
    );
    final hardcoreStats = AccountsBucketService.getBucketStatistics(
      assignmentData!,
      BucketType.hardcore,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Bucket Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Frontend Bucket
            _buildBucketBreakdownRow(
              'Frontend',
              frontendStats,
              Colors.green,
              Icons.trending_up,
              BucketType.frontend,
            ),
            const SizedBox(height: 12),

            // Mid-range Bucket
            _buildBucketBreakdownRow(
              'Mid-range',
              midRangeStats,
              Colors.orange,
              Icons.warning,
              BucketType.middlecore,
            ),
            const SizedBox(height: 12),

            // Hardcore Bucket
            _buildBucketBreakdownRow(
              'Hardcore',
              hardcoreStats,
              Colors.red,
              Icons.priority_high,
              BucketType.hardcore,
            ),
          ],
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
  ) {
    final totalContacts = stats['total_loans'] ?? 0;
    final dialableCount = stats['dialable_count'] ?? 0;
    final coMakerCount = stats['co_maker_phone_count'] ?? 0;
    final borrowerCount = stats['borrower_phone_count'] ?? 0;

    return GestureDetector(
      onTap: totalContacts > 0 ? () => _navigateToBucket(bucketType) : null,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: totalContacts > 0 ? color : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Total: $totalContacts',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Dialable: $dialableCount',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$coMakerCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$borrowerCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (totalContacts > 0) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCallStatusBreakdown() {
    final todaysCalls = _mockCallLogs
        .where(
          (log) =>
              log.callTime.day == selectedDate.day &&
              log.callTime.month == selectedDate.month &&
              log.callTime.year == selectedDate.year,
        )
        .toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Call Status Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...CallStatus.values.map((status) {
              final count = todaysCalls
                  .where((log) => log.status == status)
                  .length;
              final percentage = todaysCalls.isEmpty
                  ? 0.0
                  : (count / todaysCalls.length);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildStatusRow(status, count, percentage),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakTimeAnalysis() {
    final todaysBreaks = _mockBreakSessions
        .where(
          (session) =>
              session.startTime.day == selectedDate.day &&
              session.startTime.month == selectedDate.month &&
              session.startTime.year == selectedDate.year,
        )
        .toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Break Time Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (todaysBreaks.isEmpty)
              const Center(
                child: Text(
                  'No breaks recorded today',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...todaysBreaks.map(
                (breakSession) => _buildBreakSessionTile(breakSession),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCallLogs() {
    final recentCalls = _mockCallLogs.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Recent Call Logs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentCalls.isEmpty)
              const Center(
                child: Text(
                  'No calls recorded yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...recentCalls.map((callLog) => _buildCallLogTile(callLog)),
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
              fontSize: 24,
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
            backgroundColor: Colors.grey.shade200,
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
    return ListTile(
      leading: Icon(
        _getCallStatusIcon(callLog.status),
        color: _getCallStatusColor(callLog.status),
      ),
      title: Text('Contact #${callLog.contactId}'),
      subtitle: Text(_formatTime(callLog.callTime)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            callLog.status.displayName,
            style: TextStyle(
              color: _getCallStatusColor(callLog.status),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (callLog.callDuration != null)
            Text(
              _formatDuration(callLog.callDuration!),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _refreshData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _generateMockData();
    });
  }

  void _navigateToBucket(BucketType bucketType) {
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
}
