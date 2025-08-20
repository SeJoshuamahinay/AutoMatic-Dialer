import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/break/break_bloc.dart';
import '../blocs/break/break_event.dart';
import '../blocs/break/break_state.dart';
import '../commons/models/break_session_model.dart';

class BreakManagementView extends StatefulWidget {
  const BreakManagementView({super.key});

  @override
  State<BreakManagementView> createState() => _BreakManagementViewState();
}

class _BreakManagementViewState extends State<BreakManagementView> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load current break status when view initializes
    context.read<BreakBloc>().add(const CheckActiveBreak());
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Break Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showStatistics(context),
            tooltip: 'View Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(context),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<BreakBloc, BreakState>(
        listener: (context, state) {
          if (state is BreakError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BreakLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshData(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current break status card
                  _buildCurrentBreakCard(state),

                  const SizedBox(height: 16),

                  // Break actions
                  if (state is BreakActive)
                    _buildActiveBreakActions(state)
                  else
                    _buildInactiveBreakActions(),

                  const SizedBox(height: 24),

                  // Today's break history
                  _buildBreakHistory(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentBreakCard(BreakState state) {
    if (state is BreakActive) {
      final activeBreak = state.activeBreak;
      final duration = activeBreak.actualDuration;

      return Card(
        elevation: 4,
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.timer, size: 48, color: Colors.orange.shade600),
              const SizedBox(height: 12),
              Text(
                'Currently on ${activeBreak.type.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Started: ${_formatTime(activeBreak.startTime)}',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${_formatDuration(duration)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              if (activeBreak.reason?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  'Reason: ${activeBreak.reason}',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.work, size: 48, color: Colors.green.shade600),
              const SizedBox(height: 12),
              const Text(
                'Currently Working',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No active break session',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActiveBreakActions(BreakActive state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Break Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _endBreak(context),
              icon: const Icon(Icons.stop),
              label: const Text('End Break', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInactiveBreakActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Start Break',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Enter reason for break',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBreakTypeButton(
                    BreakType.shortBreak,
                    Icons.coffee,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBreakTypeButton(
                    BreakType.lunch,
                    Icons.restaurant,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildBreakTypeButton(
                    BreakType.meeting,
                    Icons.meeting_room,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBreakTypeButton(
                    BreakType.customerSupportBreak,
                    Icons.support_agent,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakTypeButton(BreakType type, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _startBreak(context, type),
      icon: Icon(icon, size: 20),
      label: Text(
        type.name,
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildBreakHistory(BreakState state) {
    List<BreakSession> history = [];

    if (state is BreakActive) {
      history = state.breakHistory;
    } else if (state is BreakInactive) {
      history = state.breakHistory;
    } else if (state is BreakStatisticsLoaded) {
      history = state.breakHistory;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Break History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showStatistics(context),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('Stats'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No breaks taken today',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final breakSession = history[index];
                  return _buildBreakHistoryItem(breakSession);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakHistoryItem(BreakSession breakSession) {
    final isActive = breakSession.isActive;
    final duration = breakSession.actualDuration;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive ? Colors.orange : Colors.grey.shade300,
        child: Icon(
          _getBreakTypeIcon(breakSession.type),
          color: isActive ? Colors.white : Colors.grey.shade600,
          size: 20,
        ),
      ),
      title: Text(
        breakSession.type.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.orange.shade700 : Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatTime(breakSession.startTime)} - '
            '${breakSession.endTime != null ? _formatTime(breakSession.endTime!) : 'Ongoing'}',
          ),
          if (breakSession.reason?.isNotEmpty == true)
            Text(
              'Reason: ${breakSession.reason}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatDuration(duration),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.orange.shade700 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _startBreak(BuildContext context, BreakType type) {
    final reason = _reasonController.text.trim();
    context.read<BreakBloc>().add(
      StartBreak(type, reason: reason.isEmpty ? null : reason),
    );
    _reasonController.clear();
  }

  void _endBreak(BuildContext context) {
    context.read<BreakBloc>().add(const EndBreak());
  }

  void _refreshData(BuildContext context) {
    context.read<BreakBloc>().add(const LoadBreakHistory());
  }

  void _showStatistics(BuildContext context) {
    context.read<BreakBloc>().add(const LoadBreakStatistics());

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<BreakBloc, BreakState>(
        builder: (context, state) {
          if (state is BreakStatisticsLoaded) {
            final stats = state.statistics;
            return AlertDialog(
              title: const Text('Today\'s Break Statistics'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem('Total Breaks', '${stats['total_breaks']}'),
                    _buildStatItem(
                      'Total Break Time',
                      '${stats['total_break_time_minutes']} minutes',
                    ),
                    _buildStatItem('Short Breaks', '${stats['short_breaks']}'),
                    _buildStatItem('Lunch Breaks', '${stats['lunch_breaks']}'),
                    _buildStatItem('Meetings', '${stats['meetings']}'),
                    _buildStatItem(
                      'Support Breaks',
                      '${stats['customer_support_breaks']}',
                    ),
                    _buildStatItem(
                      'Active Breaks',
                      '${stats['active_breaks']}',
                    ),
                    _buildStatItem(
                      'Average Duration',
                      '${stats['average_break_duration']?.toStringAsFixed(1)} minutes',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          }
          return const AlertDialog(
            title: Text('Loading Statistics'),
            content: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
}
