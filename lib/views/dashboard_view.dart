import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/blocs/auth/auth_bloc.dart';
import 'package:lenderly_dialer/blocs/auth/auth_event.dart';
import 'package:lenderly_dialer/commons/reusables/toast.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import '../commons/models/call_log_model.dart';
import '../commons/models/break_session_model.dart';
import '../commons/models/auth_models.dart';
import '../commons/utils/gesture_error_handler.dart';
import '../commons/widgets/database_seeder_widget.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/dashboard/dashboard_event.dart';
import '../blocs/dashboard/dashboard_state.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool get _isInTestEnvironment => EnvironmentConfig.isDevelopment;

  final _amtFmt = NumberFormat('#,##0.00', 'en_PH');

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

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
        listener: (context, state) => _handleStateChange(context, state),
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
                  _buildBucketSummaryCard(context, state),
                  const SizedBox(height: 16),
                  _buildCallStatusBreakdown(state),
                  const SizedBox(height: 16),
                  _buildRecentCallLogs(state),
                  const SizedBox(height: 16),
                  _buildBreakTimeAnalysis(state),
                  const SizedBox(height: 16),
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

  Future<void> _handleStateChange(
      BuildContext context, DashboardState state) async {
    if (state is DashboardError) {
      toast(context, state.message, ShowToast.error);
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }

  Future<void> _selectDate(BuildContext context, DashboardState state) async {
    final currentDate = _getSelectedDate(state);
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != currentDate && context.mounted) {
      context.read<DashboardBloc>().add(ChangeDashboardDate(selectedDate: picked));
    }
  }

  void _refreshData(BuildContext context) {
    context.read<DashboardBloc>().add(const RefreshDashboardData());
  }

  DateTime _getSelectedDate(DashboardState state) {
    if (state is DashboardLoaded) return state.selectedDate;
    if (state is DashboardError) return state.selectedDate;
    return DateTime.now();
  }

  ({
    DateTime selectedDate,
    List<CallLog> callLogs,
    List<BreakSession> breakSessions,
    Map<String, dynamic> dailyStats,
    UserSession? userSession,
    Map<String, dynamic>? dialerStats,
    bool isLoadingData,
    bool isLoadingStats,
  }) _getStateData(DashboardState state) {
    if (state is DashboardLoaded) {
      return (
        selectedDate: state.selectedDate,
        callLogs: state.callLogs,
        breakSessions: state.breakSessions,
        dailyStats: state.dailyStats,
        userSession: state.userSession,
        dialerStats: state.dialerStats,
        isLoadingData: state.isLoadingData,
        isLoadingStats: state.isLoadingStats,
      );
    } else if (state is DashboardError) {
      return (
        selectedDate: state.selectedDate,
        callLogs: state.callLogs,
        breakSessions: state.breakSessions,
        dailyStats: state.dailyStats,
        userSession: state.userSession,
        dialerStats: state.dialerStats,
        isLoadingData: false,
        isLoadingStats: false,
      );
    } else {
      return (
        selectedDate: DateTime.now(),
        callLogs: <CallLog>[],
        breakSessions: <BreakSession>[],
        dailyStats: <String, dynamic>{},
        userSession: null,
        dialerStats: null,
        isLoadingData: state is DashboardLoading,
        isLoadingStats: false,
      );
    }
  }

  // ==================
  // UI BUILDERS
  // ==================

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
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
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

  Widget _buildTodaysCallStatsCard(DashboardState state) {
    final d = _getStateData(state);

    if (d.isLoadingData) {
      return Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final totalCalls =
        d.dailyStats['total_calls'] ?? d.callLogs.length;
    final successfulCalls =
        d.dailyStats['successful_calls'] ??
        d.callLogs.where((log) => log.status == CallStatus.complete).length;
    final failedCalls =
        d.dailyStats['failed_calls'] ??
        d.callLogs.where((log) => log.status == CallStatus.hangUp).length;
    final noAnswerCalls =
        d.dailyStats['no_answer_calls'] ??
        d.callLogs.where((log) => log.status == CallStatus.noAnswer).length;
    final totalBreakTime = d.dailyStats['total_break_time_minutes'] ?? 0;

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
              children: const [
                Icon(Icons.phone, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
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
                  child: _statItem('Total Calls', totalCalls.toString(),
                      Icons.call, Colors.white),
                ),
                Expanded(
                  child: _statItem('Successful', successfulCalls.toString(),
                      Icons.check_circle, Colors.green.shade200),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _statItem('Failed/Hung Up', failedCalls.toString(),
                      Icons.call_end, Colors.red.shade200),
                ),
                Expanded(
                  child: _statItem('No Answer', noAnswerCalls.toString(),
                      Icons.phone_missed, Colors.orange.shade200),
                ),
              ],
            ),
            if (totalBreakTime > 0) ...[
              const SizedBox(height: 16),
              _statItem('Break Time', '${totalBreakTime}m', Icons.timer,
                  Colors.yellow.shade200),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBucketSummaryCard(BuildContext context, DashboardState state) {
    final d = _getStateData(state);
    final stats = d.dialerStats;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_open, color: Colors.indigo, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Loan Portfolio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (d.isLoadingStats)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  GestureErrorHandler.safeIconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => context
                        .read<DashboardBloc>()
                        .add(const RefreshDialerStats()),
                    tooltip: 'Refresh Stats',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats == null && !d.isLoadingStats) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Loading portfolio data...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ] else if (stats != null) ...[
              // Overall summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.indigo.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _portfolioStat(
                      'Total Loans',
                      '${stats['total_loans'] ?? 0}',
                      Icons.folder,
                      Colors.indigo,
                    ),
                    _portfolioStat(
                      'Total Balance',
                      '₱${_amtFmt.format((stats['total_outstanding'] as num?)?.toDouble() ?? 0.0)}',
                      Icons.account_balance_wallet,
                      Colors.deepPurple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Bucket breakdown
              _buildBucketRow(
                context,
                'Frontend',
                (stats['buckets']?['frontend'] as Map<String, dynamic>?) ?? {},
                Colors.green,
                Icons.trending_up,
              ),
              const SizedBox(height: 8),
              _buildBucketRow(
                context,
                'Hardcore',
                (stats['buckets']?['hardcore'] as Map<String, dynamic>?) ?? {},
                Colors.red,
                Icons.priority_high,
              ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBucketRow(
    BuildContext context,
    String label,
    Map<String, dynamic> bucket,
    Color color,
    IconData icon,
  ) {
    final count = bucket['count'] ?? 0;
    final balance = (bucket['total_outstanding'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color)),
                Text(
                  '$count accounts',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '₱${_amtFmt.format(balance)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _portfolioStat(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCallStatusBreakdown(DashboardState state) {
    final d = _getStateData(state);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.assessment, color: Colors.teal, size: 28),
                SizedBox(width: 12),
                Text('Call Status Breakdown',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (d.isLoadingData)
              const Center(child: CircularProgressIndicator())
            else
              ..._buildCallStatusRows(d),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCallLogs(DashboardState state) {
    final d = _getStateData(state);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.history, color: Colors.cyan, size: 28),
                SizedBox(width: 12),
                Text('Recent Call Logs',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (d.isLoadingData)
              const Center(child: CircularProgressIndicator())
            else
              ..._buildRecentCallsList(d),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakTimeAnalysis(DashboardState state) {
    final d = _getStateData(state);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.pause_circle, color: Colors.amber, size: 28),
                SizedBox(width: 12),
                Text('Break Time Analysis',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (d.isLoadingData)
              const Center(child: CircularProgressIndicator())
            else
              ..._buildBreakSessionsList(d),
          ],
        ),
      ),
    );
  }

  // ==================
  // HELPER WIDGETS
  // ==================

  Widget _statItem(
      String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center),
      ],
    );
  }

  List<Widget> _buildCallStatusRows(
    ({
      DateTime selectedDate,
      List<CallLog> callLogs,
      List<BreakSession> breakSessions,
      Map<String, dynamic> dailyStats,
      UserSession? userSession,
      Map<String, dynamic>? dialerStats,
      bool isLoadingData,
      bool isLoadingStats,
    })
    d,
  ) {
    final todaysCalls = d.callLogs
        .where(
          (log) =>
              log.callTime.day == d.selectedDate.day &&
              log.callTime.month == d.selectedDate.month &&
              log.callTime.year == d.selectedDate.year,
        )
        .toList();

    if (todaysCalls.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No calls made today',
                style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }

    return CallStatus.values.map((status) {
      final count = todaysCalls.where((log) => log.status == status).length;
      final percentage =
          todaysCalls.isEmpty ? 0.0 : (count / todaysCalls.length);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _buildStatusRow(status, count, percentage),
      );
    }).toList();
  }

  Widget _buildStatusRow(CallStatus status, int count, double percentage) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case CallStatus.complete:
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
        Text(count.toString(),
            style:
                TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: percentage,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(percentage * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  List<Widget> _buildBreakSessionsList(
    ({
      DateTime selectedDate,
      List<CallLog> callLogs,
      List<BreakSession> breakSessions,
      Map<String, dynamic> dailyStats,
      UserSession? userSession,
      Map<String, dynamic>? dialerStats,
      bool isLoadingData,
      bool isLoadingStats,
    })
    d,
  ) {
    final todaysBreaks = d.breakSessions
        .where(
          (s) =>
              s.startTime.day == d.selectedDate.day &&
              s.startTime.month == d.selectedDate.month &&
              s.startTime.year == d.selectedDate.year,
        )
        .toList();

    if (todaysBreaks.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No break sessions today',
                style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }

    return todaysBreaks.map(_buildBreakSessionTile).toList();
  }

  Widget _buildBreakSessionTile(BreakSession s) {
    return ListTile(
      leading: Icon(_getBreakTypeIcon(s.type), color: Colors.orange),
      title: Text(s.type.name),
      subtitle: Text(
        '${_formatTime(s.startTime)} - ${s.endTime != null ? _formatTime(s.endTime!) : 'Ongoing'}',
      ),
      trailing: Text(_formatDuration(s.actualDuration),
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  List<Widget> _buildRecentCallsList(
    ({
      DateTime selectedDate,
      List<CallLog> callLogs,
      List<BreakSession> breakSessions,
      Map<String, dynamic> dailyStats,
      UserSession? userSession,
      Map<String, dynamic>? dialerStats,
      bool isLoadingData,
      bool isLoadingStats,
    })
    d,
  ) {
    final recent = d.callLogs.take(5).toList();

    if (recent.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No recent calls',
                style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }

    return recent.map(_buildCallLogTile).toList();
  }

  Widget _buildCallLogTile(CallLog callLog) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
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
            color:
                _getCallStatusColor(callLog.status).withValues(alpha: 0.1),
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
      ),
    );
  }

  // ==================
  // FORMATTING
  // ==================

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
      case CallStatus.complete:
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
      case CallStatus.complete:
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

  String _formatTime(DateTime dt) {
    final hour12 =
        dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour12.toString()}:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
