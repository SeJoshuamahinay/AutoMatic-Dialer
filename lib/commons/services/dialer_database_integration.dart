import 'package:flutter/foundation.dart';
import '../services/call_log_service.dart';
import '../models/call_contact_model.dart';
import '../models/call_log_model.dart';

/// Helper class to integrate the existing dialer system with the new call log database
class DialerDatabaseIntegration {
  static final DialerDatabaseIntegration _instance =
      DialerDatabaseIntegration._internal();
  factory DialerDatabaseIntegration() => _instance;
  DialerDatabaseIntegration._internal();

  final CallLogService _callLogService = CallLogService();
  bool _initialized = false;

  /// Initialize the database integration
  Future<void> initialize() async {
    if (!_initialized) {
      await _callLogService.initialize();
      _initialized = true;
      debugPrint('✅ Dialer Database Integration initialized');
    }
  }

  /// Import existing contacts to the database for tracking
  Future<void> importContacts(List<CallContact> contacts, {int? userId}) async {
    await _ensureInitialized();
    await _callLogService.importContacts(contacts, userId: userId);
    debugPrint('📋 Imported ${contacts.length} contacts to database');
  }

  /// Start a new dialing session and return session ID
  Future<int> startDialingSession({
    required int userId,
    required String sessionType,
    required List<CallContact> contacts,
    String? agentName,
    String? bucket,
  }) async {
    await _ensureInitialized();

    // Import contacts if not already in database
    await importContacts(contacts, userId: userId);

    final sessionId = await _callLogService.startDialingSession(
      userId: userId,
      sessionType: sessionType,
      totalContacts: contacts.length,
      agentName: agentName,
      bucket: bucket,
    );

    debugPrint(
      '🚀 Started dialing session $sessionId with ${contacts.length} contacts',
    );
    return sessionId;
  }

  /// Log a call start
  Future<int> logCallStart({
    required CallContact contact,
    int? sessionId,
    int? userId,
    String? agentName,
  }) async {
    await _ensureInitialized();

    final callLogId = await _callLogService.logCall(
      contactId: contact.id ?? 0,
      loanId: contact.loanId ?? 0,
      borrowerName: contact.borrowerName,
      borrowerPhone: contact.borrowerPhone,
      coMakerName: contact.coMakerName,
      coMakerPhone: contact.coMakerPhone,
      callStartTime: DateTime.now(),
      status: CallStatus.pending,
      bucket: contact.bucket,
      sessionId: sessionId,
      userId: userId,
      agentName: agentName,
    );

    debugPrint('📞 Started call log $callLogId for ${contact.borrowerName}');
    return callLogId;
  }

  /// Update call end with results
  Future<void> logCallEnd({
    required int callLogId,
    required CallStatus status,
    required Duration callDuration,
    String? notes,
    String? outcome,
  }) async {
    await _ensureInitialized();

    await _callLogService.updateCallEnd(
      callLogId: callLogId,
      endTime: DateTime.now(),
      durationSeconds: callDuration.inSeconds,
      finalStatus: status,
      finalNotes: notes,
      outcome: outcome,
    );

    debugPrint(
      '✅ Completed call log $callLogId with status: ${status.displayName}',
    );
  }

  /// End a dialing session with statistics
  Future<void> endDialingSession(int sessionId, Map<String, int> stats) async {
    await _ensureInitialized();

    await _callLogService.endDialingSession(sessionId, stats);
    debugPrint('🏁 Ended dialing session $sessionId');
  }

  /// Get today's statistics for dashboard
  Future<Map<String, dynamic>> getTodaysStats(int userId) async {
    await _ensureInitialized();
    return await _callLogService.getTodaysStats(userId);
  }

  /// Get call history for display
  Future<List<CallLog>> getRecentCallHistory({
    int? userId,
    int limit = 20,
    String? bucket,
  }) async {
    await _ensureInitialized();

    return await _callLogService.getCallHistory(
      userId: userId,
      limit: limit,
      bucket: bucket,
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
  }

  /// Get weekly performance summary
  Future<Map<String, dynamic>> getWeeklyPerformance(int userId) async {
    await _ensureInitialized();
    return await _callLogService.getWeeklyPerformance(userId);
  }

  /// Start a break session
  Future<int> startBreak({
    required int userId,
    required String breakType,
    String? reason,
    String? agentName,
    int? callSessionId,
  }) async {
    await _ensureInitialized();

    final breakId = await _callLogService.startBreak(
      userId: userId,
      breakType: breakType,
      reason: reason,
      agentName: agentName,
      callSessionId: callSessionId,
    );

    debugPrint('☕ Started break session $breakId (type: $breakType)');
    return breakId;
  }

  /// End a break session
  Future<void> endBreak(int breakId) async {
    await _ensureInitialized();

    await _callLogService.endBreak(breakId);
    debugPrint('✅ Ended break session $breakId');
  }

  /// Get database statistics for debugging
  Future<Map<String, int>> getDatabaseStats() async {
    await _ensureInitialized();
    return await _callLogService.getDatabaseStats();
  }

  /// Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    await _ensureInitialized();
    await _callLogService.clearAllData();
    debugPrint('🗑️ Cleared all database data');
  }

  // ===== INTEGRATION HELPERS =====

  /// Convert CallStatus from the existing model to the database enum
  static CallStatus mapCallStatus(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return CallStatus.complete;
      case 'no_answer':
        return CallStatus.noAnswer;
      case 'hang_up':
        return CallStatus.hangUp;
      case 'called':
        return CallStatus.called;
      default:
        return CallStatus.pending;
    }
  }

  /// Create session statistics from dialer state
  static Map<String, int> createSessionStats({
    required int totalContacts,
    required int attempted,
    required int completed,
    required int successful,
    required int failed,
    required int noAnswer,
    required int hangUp,
    int? avgDuration,
  }) {
    return {
      'total': totalContacts,
      'attempted': attempted,
      'completed': completed,
      'successful': successful,
      'failed': failed,
      'no_answer': noAnswer,
      'hang_up': hangUp,
      'avg_duration': avgDuration ?? 0,
    };
  }

  /// Extract user info from session or context
  static Map<String, dynamic> extractUserInfo({
    int? userId,
    String? agentName,
  }) {
    return {'user_id': userId ?? 0, 'agent_name': agentName ?? 'Unknown Agent'};
  }

  // ===== PRIVATE METHODS =====

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Close all database connections
  Future<void> dispose() async {
    if (_initialized) {
      await _callLogService.close();
      _initialized = false;
      debugPrint('🔒 Dialer Database Integration disposed');
    }
  }
}

/// Extension methods for easier integration with existing models
extension CallContactExtension on CallContact {
  /// Convert to database entry format
  Map<String, dynamic> toDatabaseFormat() {
    return {
      'id': id,
      'loan_id': loanId,
      'borrower_name': borrowerName,
      'borrower_phone': borrowerPhone,
      'co_maker_name': coMakerName,
      'co_maker_phone': coMakerPhone,
      'status': status,
      'bucket': bucket,
      'note': note,
    };
  }
}

/// Extension methods for call status integration
extension CallStatusIntegration on CallStatus {
  /// Convert to string format used in existing system
  String get legacyValue {
    switch (this) {
      case CallStatus.pending:
        return 'pending';
      case CallStatus.complete:
        return 'complete';
      case CallStatus.noAnswer:
        return 'no_answer';
      case CallStatus.hangUp:
        return 'hang_up';
      case CallStatus.called:
        return 'called';
    }
  }
}
