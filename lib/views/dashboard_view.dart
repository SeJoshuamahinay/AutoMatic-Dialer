import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/blocs/auth/auth_bloc.dart';
import 'package:lenderly_dialer/blocs/auth/auth_event.dart';
import 'package:lenderly_dialer/blocs/dashboard/dashboard_bloc.dart';
import 'package:lenderly_dialer/blocs/dashboard/dashboard_event.dart';
import 'package:lenderly_dialer/blocs/dashboard/dashboard_state.dart';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/models/break_session_model.dart';
import 'package:lenderly_dialer/commons/models/call_log_model.dart';
import 'package:lenderly_dialer/commons/reusables/toast.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final NumberFormat _amountFmt = NumberFormat('#,##0.00', 'en_PH');
  late DateTime _now;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });

    final bloc = context.read<DashboardBloc>();
    bloc
      ..add(const InitializeDashboardServices())
      ..add(const LoadUserSession())
      ..add(LoadDashboardData(selectedDate: DateTime.now()));
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _onStateChanged(
    BuildContext context,
    DashboardState state,
  ) async {
    if (state is DashboardError) {
      toast(context, state.message, ShowToast.error);
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }

  DateTime _selectedDate(DashboardState state) {
    if (state is DashboardLoaded) return state.selectedDate;
    if (state is DashboardError) return state.selectedDate;
    return DateTime.now();
  }

  Future<void> _pickDate(DashboardState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate(state),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      context.read<DashboardBloc>().add(
        ChangeDashboardDate(selectedDate: picked),
      );
    }
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
  })
  _data(DashboardState state) {
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
    }

    if (state is DashboardError) {
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
    }

    return (
      selectedDate: DateTime.now(),
      callLogs: const <CallLog>[],
      breakSessions: const <BreakSession>[],
      dailyStats: const <String, dynamic>{},
      userSession: null,
      dialerStats: null,
      isLoadingData: state is DashboardLoading,
      isLoadingStats: false,
    );
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value) ?? double.tryParse(value)?.toInt();
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0F3D3E),
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) => IconButton(
              tooltip: 'Select Date',
              icon: const Icon(Icons.calendar_month),
              onPressed: () => _pickDate(state),
            ),
          ),
          IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<DashboardBloc>().add(const RefreshDashboardData()),
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: _onStateChanged,
        builder: (context, state) {
          final d = _data(state);
          final totalCalls = _asInt(
            d.dailyStats['total_calls'],
            fallback: d.callLogs.length,
          );
          final connected = _asInt(
            d.dailyStats['successful_calls'],
            fallback: d.callLogs
                .where((e) => e.status == CallStatus.complete)
                .length,
          );
          final noAnswer = _asInt(
            d.dailyStats['no_answer_calls'],
            fallback: d.callLogs
                .where((e) => e.status == CallStatus.noAnswer)
                .length,
          );
          final breakTime = d.breakSessions.fold<Duration>(
            Duration.zero,
            (sum, s) => sum + s.actualDuration,
          );

          final totalLoans = _asInt(d.dialerStats?['total_loans']);
          final totalOutstanding = _asDouble(
            d.dialerStats?['total_outstanding'],
          );

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const RefreshDashboardData());
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              children: [
                _timeHero(d.userSession, d.selectedDate),
                const SizedBox(height: 12),
                _kpiGrid(
                  totalCalls,
                  connected,
                  noAnswer,
                  _formatDuration(breakTime),
                  d.isLoadingData,
                ),
                const SizedBox(height: 12),
                _portfolioCard(
                  totalLoans,
                  totalOutstanding,
                  d.dialerStats,
                  d.isLoadingStats,
                ),
                const SizedBox(height: 12),
                _activityCard(d.callLogs),
                const SizedBox(height: 12),
                _latestCallsCard(d.callLogs),
                const SizedBox(height: 12),
                _breakSummaryCard(d.breakSessions, d.selectedDate),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _timeHero(UserSession? user, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3D3E), Color(0xFF2A9D8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Operations',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.fullName ?? 'Dialer Agent',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('hh:mm:ss a').format(_now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                DateFormat('EEEE, MMMM d').format(_now),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Selected: ${DateFormat('EEE, MMM d, y').format(selectedDate)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiGrid(
    int totalCalls,
    int connected,
    int noAnswer,
    String breakTime,
    bool isLoading,
  ) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _kpiTile(
          'Total Calls',
          '$totalCalls',
          Icons.call,
          const Color(0xFF3B82F6),
        ),
        _kpiTile(
          'Connected',
          '$connected',
          Icons.check_circle,
          const Color(0xFF16A34A),
        ),
        _kpiTile(
          'No Answer',
          '$noAnswer',
          Icons.phone_missed,
          const Color(0xFFF59E0B),
        ),
        _kpiTile(
          'Break Time',
          breakTime,
          Icons.free_breakfast,
          const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _kpiTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _portfolioCard(
    int totalLoans,
    double totalOutstanding,
    Map<String, dynamic>? stats,
    bool isLoading,
  ) {
    final frontend =
        (stats?['buckets']?['frontend'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final hardcore =
        (stats?['buckets']?['hardcore'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF0F3D3E),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Portfolio',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Loans: $totalLoans',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            'Outstanding: P${_amountFmt.format(totalOutstanding)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _bucketLine('Frontend', frontend),
          const SizedBox(height: 8),
          _bucketLine('Hardcore', hardcore),
        ],
      ),
    );
  }

  Widget _bucketLine(String title, Map<String, dynamic> bucket) {
    final count = _asInt(bucket['count']);
    final outstanding = _asDouble(bucket['total_outstanding']);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF8FAFC),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$title: $count accounts',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'P${_amountFmt.format(outstanding)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(List<CallLog> callLogs) {
    final complete = callLogs
        .where((c) => c.status == CallStatus.complete)
        .length;
    final noAnswer = callLogs
        .where((c) => c.status == CallStatus.noAnswer)
        .length;
    final hangUp = callLogs.where((c) => c.status == CallStatus.hangUp).length;
    final total = callLogs.isEmpty ? 1 : callLogs.length;

    Widget line(String title, int value, Color color) {
      final ratio = (value / total).clamp(0, 1).toDouble();
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text('$value'),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Call Activity',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          line('Complete', complete, const Color(0xFF16A34A)),
          line('No Answer', noAnswer, const Color(0xFFF59E0B)),
          line('Hang Up', hangUp, const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _latestCallsCard(List<CallLog> callLogs) {
    final latest = callLogs.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Calls',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (latest.isEmpty)
            const Text(
              'No recent calls yet',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            ...latest.map(
              (log) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.teal.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.borrowerName?.isNotEmpty == true
                            ? log.borrowerName!
                            : 'Loan #${log.loanID ?? '-'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(log.callTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _breakSummaryCard(List<BreakSession> sessions, DateTime selectedDate) {
    final today = sessions.where(
      (s) =>
          s.startTime.year == selectedDate.year &&
          s.startTime.month == selectedDate.month &&
          s.startTime.day == selectedDate.day,
    );
    final total = today.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + s.actualDuration,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.pause_circle_filled, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Break Summary: ${today.length} sessions, ${_formatDuration(total)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
