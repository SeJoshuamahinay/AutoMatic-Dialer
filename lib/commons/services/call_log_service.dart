import 'package:drift/drift.dart';

import '../../db/app_database.dart';
import '../models/call_contact_model.dart';
import '../models/call_log_model.dart';

/// Service for managing call logs and statistics using the local Drift database
class CallLogService {
  static final CallLogService _instance = CallLogService._internal();
  factory CallLogService() => _instance;
  CallLogService._internal();

  late final AppDatabase _database;
  bool _initialized = false;

  /// Initialize the database
  Future<void> initialize() async {
    if (!_initialized) {
      _database = AppDatabase();
      _initialized = true;
    }
  }

  /// Ensure database is initialized
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'CallLogService not initialized. Call initialize() first.',
      );
    }
  }

  // ===== CALL LOG MANAGEMENT =====

  /// Log a new call attempt
  Future<int> logCall({
    required int contactId,
    required int loanId,
    required String borrowerName,
    required String borrowerPhone,
    String? coMakerName,
    String? coMakerPhone,
    required DateTime callStartTime,
    DateTime? callEndTime,
    int? callDurationSeconds,
    required CallStatus status,
    String? outcome,
    String? notes,
    String? bucket,
    int? sessionId,
    int? userId,
    String? agentName,
  }) async {
    _ensureInitialized();

    final callLog = CallLogsCompanion.insert(
      contactId: Value(contactId),
      loanId: Value(loanId),
      borrowerName: borrowerName,
      borrowerPhone: borrowerPhone,
      coMakerName: Value(coMakerName),
      coMakerPhone: Value(coMakerPhone),
      callStartTime: callStartTime,
      callEndTime: Value(callEndTime),
      callDurationSeconds: Value(callDurationSeconds),
      callStatus: status.value,
      callOutcome: Value(outcome),
      notes: Value(notes),
      bucket: Value(bucket),
      sessionId: Value(sessionId),
      userId: Value(userId),
      agentName: Value(agentName),
      wasSuccessful: Value(status == CallStatus.finished),
      requiresFollowUp: Value(status != CallStatus.finished),
    );

    final logId = await _database.insertCallLog(callLog);

    // Update contact information
    await _updateContactAfterCall(contactId, status, notes);

    // Record call attempt
    await _recordCallAttempt(
      contactId,
      logId,
      borrowerPhone,
      'borrower',
      status,
      callDurationSeconds,
    );

    // Update daily statistics
    if (userId != null) {
      await _updateDailyStatsAfterCall(
        userId,
        DateTime.now(),
        status,
        bucket,
        agentName,
      );
    }

    return logId;
  }

  /// Update a call log when call ends
  Future<bool> updateCallEnd({
    required int callLogId,
    required DateTime endTime,
    required int durationSeconds,
    required CallStatus finalStatus,
    String? finalNotes,
    String? outcome,
  }) async {
    _ensureInitialized();

    final companion = CallLogsCompanion(
      id: Value(callLogId),
      callEndTime: Value(endTime),
      callDurationSeconds: Value(durationSeconds),
      callStatus: Value(finalStatus.value),
      callOutcome: Value(outcome),
      notes: Value(finalNotes),
      wasSuccessful: Value(finalStatus == CallStatus.finished),
      updatedAt: Value(DateTime.now()),
    );

    return await _database.updateCallLog(callLogId, companion);
  }

  // ===== CONTACT MANAGEMENT =====

  /// Import contacts from CallContact model to database
  Future<void> importContacts(List<CallContact> contacts, {int? userId}) async {
    _ensureInitialized();

    for (final contact in contacts) {
      final dbContact = CallContactsCompanion.insert(
        loanId: Value(contact.loanId),
        borrowerName: contact.borrowerName,
        borrowerPhone: contact.borrowerPhone,
        coMakerName: Value(contact.coMakerName),
        coMakerPhone: Value(contact.coMakerPhone),
        status: Value(contact.status ?? 'pending'),
        bucket: Value(contact.bucket),
        assignedUserId: Value(userId),
        assignedAt: Value(userId != null ? DateTime.now() : null),
      );

      await _database.insertContact(dbContact);
    }
  }

  /// Get pending contacts as CallContact models for compatibility
  Future<List<CallContact>> getPendingContacts({String? bucket}) async {
    _ensureInitialized();

    List<CallContactEntry> dbContacts;
    if (bucket != null) {
      dbContacts = await _database.getContactsByBucket(bucket);
    } else {
      dbContacts = await _database.getPendingContacts();
    }

    return dbContacts
        .map(
          (entry) => CallContact(
            id: entry.id,
            loanId: entry.loanId,
            borrowerName: entry.borrowerName,
            borrowerPhone: entry.borrowerPhone,
            coMakerName: entry.coMakerName,
            coMakerPhone: entry.coMakerPhone,
            status: entry.status,
            bucket: entry.bucket,
            note: entry.notes,
          ),
        )
        .toList();
  }

  // ===== SESSION MANAGEMENT =====

  /// Start a new dialing session
  Future<int> startDialingSession({
    required int userId,
    required String
    sessionType, // 'auto_dialing', 'manual', 'co_maker_only', 'borrower_only'
    required int totalContacts,
    String? agentName,
    String? bucket,
  }) async {
    _ensureInitialized();

    final session = CallSessionsCompanion.insert(
      userId: userId,
      sessionStart: DateTime.now(),
      sessionType: sessionType,
      totalContacts: Value(totalContacts),
      agentName: Value(agentName),
      bucket: Value(bucket),
    );

    return await _database.startCallSession(session);
  }

  /// End a dialing session with final statistics
  Future<bool> endDialingSession(int sessionId, Map<String, int> stats) async {
    _ensureInitialized();

    return await _database.endCallSession(
      sessionId,
      endTime: DateTime.now(),
      contactsAttempted: stats['attempted'] ?? 0,
      contactsCompleted: stats['completed'] ?? 0,
      successfulCalls: stats['successful'] ?? 0,
      failedCalls: stats['failed'] ?? 0,
      noAnswerCalls: stats['no_answer'] ?? 0,
      hangUpCalls: stats['hang_up'] ?? 0,
      successRate: _calculateSuccessRate(stats),
      averageCallDuration: stats['avg_duration'],
    );
  }

  // ===== STATISTICS AND ANALYTICS =====

  /// Get today's call statistics for a user
  Future<Map<String, dynamic>> getTodaysStats(int userId) async {
    _ensureInitialized();

    final callLogs = await _database.getTodaysCallLogs(userId);
    final breaks = await _database.getTodaysBreaks(userId);

    final totalCalls = callLogs.length;
    final successfulCalls = callLogs.where((log) => log.wasSuccessful).length;
    final noAnswerCalls = callLogs
        .where((log) => log.callStatus == 'no_answer')
        .length;
    final hangUpCalls = callLogs
        .where((log) => log.callStatus == 'hang_up')
        .length;
    final failedCalls = totalCalls - successfulCalls;

    final totalCallTime = callLogs
        .where((log) => log.callDurationSeconds != null)
        .fold<int>(0, (sum, log) => sum + (log.callDurationSeconds ?? 0));

    final totalBreakTime = breaks
        .where((b) => b.breakDurationMinutes != null)
        .fold<int>(0, (sum, b) => sum + (b.breakDurationMinutes ?? 0));

    return {
      'total_calls': totalCalls,
      'successful_calls': successfulCalls,
      'failed_calls': failedCalls,
      'no_answer_calls': noAnswerCalls,
      'hang_up_calls': hangUpCalls,
      'success_rate': totalCalls > 0
          ? (successfulCalls / totalCalls) * 100
          : 0.0,
      'total_call_time_minutes': (totalCallTime / 60).round(),
      'total_break_time_minutes': totalBreakTime,
      'average_call_duration': totalCalls > 0 ? totalCallTime / totalCalls : 0,
      'calls_by_bucket': _groupCallsByBucket(callLogs),
    };
  }

  /// Get statistics for a specific date
  Future<Map<String, dynamic>> getStatsForDate(
    int userId,
    DateTime date,
  ) async {
    _ensureInitialized();

    // Create date range for the specific day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Get call logs for the specified date
    final callLogs = await _database.getCallLogsByDateRange(
      startOfDay,
      endOfDay,
    );
    final userCallLogs = callLogs.where((log) => log.userId == userId).toList();

    // For break sessions, use today's data if the date is today, otherwise return 0
    List<BreakSessionEntry> userBreaks = [];
    final isToday = DateTime.now().difference(date).inDays == 0;
    if (isToday) {
      final breaks = await _database.getTodaysBreaks(userId);
      userBreaks = breaks;
    }

    final totalCalls = userCallLogs.length;
    final successfulCalls = userCallLogs
        .where((log) => log.wasSuccessful)
        .length;
    final noAnswerCalls = userCallLogs
        .where((log) => log.callStatus == 'no_answer')
        .length;
    final hangUpCalls = userCallLogs
        .where((log) => log.callStatus == 'hang_up')
        .length;
    final failedCalls = totalCalls - successfulCalls;

    final totalCallTime = userCallLogs
        .where((log) => log.callDurationSeconds != null)
        .fold<int>(0, (sum, log) => sum + (log.callDurationSeconds ?? 0));

    final totalBreakTime = userBreaks
        .where((b) => b.breakDurationMinutes != null)
        .fold<int>(0, (sum, b) => sum + (b.breakDurationMinutes ?? 0));

    return {
      'total_calls': totalCalls,
      'successful_calls': successfulCalls,
      'failed_calls': failedCalls,
      'no_answer_calls': noAnswerCalls,
      'hang_up_calls': hangUpCalls,
      'success_rate': totalCalls > 0
          ? (successfulCalls / totalCalls) * 100
          : 0.0,
      'total_call_time_minutes': (totalCallTime / 60).round(),
      'total_break_time_minutes': totalBreakTime,
      'average_call_duration': totalCalls > 0 ? totalCallTime / totalCalls : 0,
      'calls_by_bucket': _groupCallsByBucket(userCallLogs),
    };
  }

  /// Get call history with optional filters
  Future<List<CallLog>> getCallHistory({
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? bucket,
    int limit = 100,
  }) async {
    _ensureInitialized();

    List<CallLogEntry> logs;

    if (startDate != null && endDate != null) {
      logs = await _database.getCallLogsByDateRange(startDate, endDate);
    } else if (userId != null) {
      logs = await _database.getCallLogsByUser(userId);
    } else if (status != null) {
      logs = await _database.getCallLogsByStatus(status);
    } else {
      // Get recent logs (you might want to add a general method for this)
      logs = await _database.getCallLogsByDateRange(
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );
    }

    // Apply additional filters
    if (bucket != null) {
      logs = logs.where((log) => log.bucket == bucket).toList();
    }

    // Limit results
    if (logs.length > limit) {
      logs = logs.take(limit).toList();
    }

    // Convert to CallLog models
    return logs
        .map(
          (entry) => CallLog(
            id: entry.id,
            loanID: entry.contactId ?? 0,
            callTime: entry.callStartTime,
            callDuration: entry.callDurationSeconds != null
                ? Duration(seconds: entry.callDurationSeconds!)
                : null,
            status: CallStatusExtension.fromString(entry.callStatus),
            notes: entry.notes,
          ),
        )
        .toList();
  }

  /// Get weekly performance summary
  Future<Map<String, dynamic>> getWeeklyPerformance(int userId) async {
    _ensureInitialized();

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final stats = await _database.getDailyStatsRange(
      userId,
      weekStart,
      weekEnd,
    );

    final totalCalls = stats.fold<int>(0, (sum, stat) => sum + stat.totalCalls);
    final totalSuccessful = stats.fold<int>(
      0,
      (sum, stat) => sum + stat.successfulCalls,
    );
    final totalWorkMinutes = stats.fold<int>(
      0,
      (sum, stat) => sum + stat.totalWorkMinutes,
    );

    return {
      'week_start': weekStart,
      'week_end': weekEnd,
      'total_calls': totalCalls,
      'successful_calls': totalSuccessful,
      'success_rate': totalCalls > 0
          ? (totalSuccessful / totalCalls) * 100
          : 0.0,
      'total_work_hours': (totalWorkMinutes / 60).round(),
      'daily_breakdown': stats
          .map(
            (stat) => {
              'date': stat.statDate,
              'calls': stat.totalCalls,
              'success_rate': stat.successRate ?? 0.0,
              'work_minutes': stat.totalWorkMinutes,
            },
          )
          .toList(),
    };
  }

  // ===== BREAK MANAGEMENT =====

  /// Start a break session
  Future<int> startBreak({
    required int userId,
    required String
    breakType, // 'short_break', 'lunch', 'meeting', 'technical_issue'
    String? reason,
    String? agentName,
    int? callSessionId,
  }) async {
    _ensureInitialized();

    final breakSession = BreakSessionsCompanion.insert(
      userId: userId,
      breakStart: DateTime.now(),
      breakType: breakType,
      breakReason: Value(reason),
      agentName: Value(agentName),
      callSessionId: Value(callSessionId),
    );

    return await _database.startBreakSession(breakSession);
  }

  /// End a break session
  Future<bool> endBreak(int breakId) async {
    _ensureInitialized();
    return await _database.endBreakSession(breakId, DateTime.now());
  }

  // ===== UTILITY METHODS =====

  /// Get database statistics for debugging
  Future<Map<String, int>> getDatabaseStats() async {
    _ensureInitialized();
    return await _database.getDatabaseStats();
  }

  /// Clear all data (use with caution!)
  Future<void> clearAllData() async {
    _ensureInitialized();
    await _database.clearAllData();
  }

  /// Close database connection
  Future<void> close() async {
    if (_initialized) {
      // Drift databases don't need explicit closing in most cases
      // The connection will be closed automatically when the app terminates
      _initialized = false;
    }
  }

  // ===== PRIVATE HELPER METHODS =====

  Future<void> _updateContactAfterCall(
    int contactId,
    CallStatus status,
    String? notes,
  ) async {
    await _database.updateContactStatus(
      contactId,
      status.value,
      lastCallStatus: status.value,
      notes: notes,
    );
    await _database.incrementCallAttempts(contactId);
  }

  Future<void> _recordCallAttempt(
    int contactId,
    int callLogId,
    String phoneNumber,
    String phoneType,
    CallStatus status,
    int? durationSeconds,
  ) async {
    final attemptNumber = await _database.getLatestAttemptNumber(contactId) + 1;

    final attempt = CallAttemptsCompanion.insert(
      contactId: contactId,
      callLogId: Value(callLogId),
      attemptTime: DateTime.now(),
      attemptNumber: attemptNumber,
      phoneNumberCalled: phoneNumber,
      phoneType: phoneType,
      outcome: status.value,
      callDurationSeconds: Value(durationSeconds),
    );

    await _database.recordCallAttempt(attempt);
  }

  Future<void> _updateDailyStatsAfterCall(
    int userId,
    DateTime date,
    CallStatus status,
    String? bucket,
    String? agentName,
  ) async {
    // Get current stats to increment
    final currentStats = await _database.getOrCreateDailyStats(userId, date);

    final increment = <String, int>{'totalCalls': currentStats.totalCalls + 1};

    switch (status) {
      case CallStatus.finished:
        increment['successfulCalls'] = currentStats.successfulCalls + 1;
        break;
      case CallStatus.noAnswer:
        increment['noAnswerCalls'] = currentStats.noAnswerCalls + 1;
        break;
      case CallStatus.hangUp:
        increment['hangUpCalls'] = currentStats.hangUpCalls + 1;
        break;
      default:
        increment['failedCalls'] = currentStats.failedCalls + 1;
    }

    // Update bucket-specific counts
    if (bucket != null) {
      switch (bucket.toLowerCase()) {
        case 'frontend':
          increment['frontendCalls'] = currentStats.frontendCalls + 1;
          break;
        case 'middlecore':
          increment['middlecoreCalls'] = currentStats.middlecoreCalls + 1;
          break;
        case 'hardcore':
          increment['hardcoreCalls'] = currentStats.hardcoreCalls + 1;
          break;
      }
    }

    await _database.updateDailyStats(
      userId,
      date,
      totalCalls: increment['totalCalls'],
      successfulCalls: increment['successfulCalls'],
      failedCalls: increment['failedCalls'],
      noAnswerCalls: increment['noAnswerCalls'],
      hangUpCalls: increment['hangUpCalls'],
      frontendCalls: increment['frontendCalls'],
      middlecoreCalls: increment['middlecoreCalls'],
      hardcoreCalls: increment['hardcoreCalls'],
      agentName: agentName,
    );
  }

  double? _calculateSuccessRate(Map<String, int> stats) {
    final total = stats['attempted'] ?? 0;
    final successful = stats['successful'] ?? 0;
    return total > 0 ? (successful / total) * 100 : null;
  }

  Map<String, int> _groupCallsByBucket(List<CallLogEntry> logs) {
    final groups = <String, int>{};
    for (final log in logs) {
      if (log.bucket != null) {
        groups[log.bucket!] = (groups[log.bucket!] ?? 0) + 1;
      }
    }
    return groups;
  }
}
