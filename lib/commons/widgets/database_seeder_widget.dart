import 'package:flutter/material.dart';
import '../utils/database_seeder.dart';
import '../services/shared_prefs_storage_service.dart';
import '../services/call_log_service.dart';
import '../models/call_log_model.dart';

/// Widget to manage database seeding from within the app
class DatabaseSeederWidget extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const DatabaseSeederWidget({super.key, this.onDataChanged});

  @override
  State<DatabaseSeederWidget> createState() => _DatabaseSeederWidgetState();
}

class _DatabaseSeederWidgetState extends State<DatabaseSeederWidget> {
  bool _isSeeding = false;
  String _lastOperation = '';
  bool _showCallLogs = false;
  List<CallLog> _callLogs = [];
  bool _isLoadingLogs = false;
  final CallLogService _callLogService = CallLogService();

  Future<void> _runSeeder({
    required String operation,
    required Future<void> Function() seederFunction,
  }) async {
    if (_isSeeding) return;

    setState(() {
      _isSeeding = true;
      _lastOperation = operation;
    });
    try {
      await seederFunction();

      // Call the data changed callback
      if (widget.onDataChanged != null) {
        widget.onDataChanged!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$operation completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$operation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  Future<void> _quickSeed() async {
    await _runSeeder(
      operation: 'Quick Seed',
      seederFunction: () async {
        final userSession = await SharedPrefsStorageService.getUserSession();
        await DatabaseSeeder.quickSeed(
          userId: userSession?.userId ?? 1,
          agentName: userSession?.fullName ?? 'Dev User',
        );
      },
    );
  }

  Future<void> _fullSeed() async {
    await _runSeeder(
      operation: 'Full Seed',
      seederFunction: () async {
        final userSession = await SharedPrefsStorageService.getUserSession();
        await DatabaseSeeder.fullSeed(
          userId: userSession?.userId ?? 1,
          agentName: userSession?.fullName ?? 'Test User',
        );
      },
    );
  }

  Future<void> _clearData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all call logs, sessions, and statistics. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _runSeeder(
        operation: 'Clear Data',
        seederFunction: () async {
          await DatabaseSeeder.clearAllData();
        },
      );
    }
  }

  Future<void> _loadCallLogs() async {
    setState(() {
      _isLoadingLogs = true;
    });

    try {
      await _callLogService.initialize();
      final userSession = await SharedPrefsStorageService.getUserSession();
      final userId = userSession?.userId ?? 1;

      // Get all call logs for the user (get a broad date range to include all logs)
      final startDate = DateTime.now().subtract(const Duration(days: 365));
      final endDate = DateTime.now().add(const Duration(days: 1));

      final logs = await _callLogService.getCallHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        setState(() {
          _callLogs = logs;
          _showCallLogs = true;
          _isLoadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLogs = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load call logs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleCallLogsView() {
    if (_showCallLogs) {
      setState(() {
        _showCallLogs = false;
        _callLogs.clear();
      });
    } else {
      _loadCallLogs();
    }
  }

  Widget _buildCallLogsList() {
    if (_isLoadingLogs) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_callLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'No call logs found in database',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 400, // Fixed height for the list
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Call Logs (${_callLogs.length} records)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _callLogs.length,
              itemBuilder: (context, index) {
                final log = _callLogs[index];
                return _buildCallLogTile(log);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallLogTile(CallLog log) {
    Color statusColor;
    IconData statusIcon;

    switch (log.status) {
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
      case CallStatus.called:
        statusColor = Colors.grey;
        statusIcon = Icons.phone;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text('Loan #${log.loanID ?? 'N/A'}'),
        subtitle: Text(
          'Date: ${_formatDateTime(log.callTime)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            log.status.displayName,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCallDetailRow('Call ID', log.id?.toString() ?? 'N/A'),
                _buildCallDetailRow('Loan ID', log.loanID?.toString() ?? 'N/A'),
                _buildCallDetailRow(
                  'Full Date & Time',
                  _formatFullDateTime(log.callTime),
                ),
                _buildCallDetailRow('Status', log.status.displayName),
                if (log.callDuration != null)
                  _buildCallDetailRow(
                    'Duration',
                    _formatDuration(log.callDuration!),
                  ),
                if (log.notes != null && log.notes!.isNotEmpty)
                  _buildCallDetailRow('Agent Notes', log.notes!),

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Call Status: ${log.status.displayName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            Text(
                              _getCallStatusDescription(log.status),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getCallStatusDescription(CallStatus status) {
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
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
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

    final dayName = days[dateTime.weekday - 1];
    final monthName = months[dateTime.month - 1];
    final hour12 = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$dayName, $monthName ${dateTime.day}, ${dateTime.year} at ${hour12.toString()}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Database Seeder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isSeeding)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generate test data to populate the dashboard',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            if (_isSeeding) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      'Running $_lastOperation...',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This may take a few seconds',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _quickSeed,
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Quick Seed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _fullSeed,
                      icon: const Icon(Icons.dataset),
                      label: const Text('Full Seed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _clearData,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Clear All Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seed Options:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Quick Seed: 3 days, ~8 calls/day',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const Text(
                      '• Full Seed: 14 days, ~25 calls/day',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const Text(
                      '• Uses your current user ID and name',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Call Logs Section
            Row(
              children: [
                const Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Call Logs Database',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _toggleCallLogsView,
                  icon: Icon(
                    _showCallLogs ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                  tooltip: _showCallLogs ? 'Hide Call Logs' : 'Show Call Logs',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_showCallLogs) _buildCallLogsList(),
          ],
        ),
      ),
    );
  }
}
