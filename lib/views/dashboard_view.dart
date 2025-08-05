import 'package:flutter/material.dart';
import '../commons/models/call_log_model.dart';
import '../commons/models/break_session_model.dart';
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

  @override
  void initState() {
    super.initState();
    _generateMockData();
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
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
          IconButton(
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
              _buildOverallAnalytics(),
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

  Widget _buildOverallAnalytics() {
    final todaysCalls = _mockCallLogs
        .where(
          (log) =>
              log.callTime.day == selectedDate.day &&
              log.callTime.month == selectedDate.month &&
              log.callTime.year == selectedDate.year,
        )
        .toList();

    final totalCalls = todaysCalls.length;
    final finishedCalls = todaysCalls
        .where((log) => log.status == CallStatus.finished)
        .length;
    final noAnswerCalls = todaysCalls
        .where((log) => log.status == CallStatus.noAnswer)
        .length;
    final hangUpCalls = todaysCalls
        .where((log) => log.status == CallStatus.hangUp)
        .length;

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
                  _formatDate(selectedDate),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    title: 'Total Calls',
                    value: totalCalls.toString(),
                    icon: Icons.phone,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    title: 'Finished',
                    value: finishedCalls.toString(),
                    icon: Icons.check_circle,
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
                    title: 'No Answer',
                    value: noAnswerCalls.toString(),
                    icon: Icons.phone_missed,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    title: 'Hang Ups',
                    value: hangUpCalls.toString(),
                    icon: Icons.call_end,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
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
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
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
}
