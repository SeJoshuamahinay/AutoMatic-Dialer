import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CallLogs,
    CallContacts,
    CallSessions,
    BreakSessions,
    DailyStats,
    CallAttempts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle database migrations here when schema changes
        // For example:
        // if (from < 2) {
        //   await m.addColumn(callLogs, callLogs.newColumn);
        // }
      },
    );
  }

  // ===== CALL LOGS QUERIES =====

  /// Insert a new call log entry
  Future<int> insertCallLog(CallLogsCompanion callLog) =>
      into(callLogs).insert(callLog);

  /// Update an existing call log entry
  Future<bool> updateCallLog(int id, CallLogsCompanion callLog) =>
      update(callLogs).replace(callLog.copyWith(id: Value(id)));

  /// Get all call logs for a specific date range
  Future<List<CallLogEntry>> getCallLogsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(callLogs)
          ..where((log) => log.callStartTime.isBetweenValues(start, end))
          ..orderBy([(log) => OrderingTerm.desc(log.callStartTime)]))
        .get();
  }

  /// Get call logs for a specific user
  Future<List<CallLogEntry>> getCallLogsByUser(int userId) {
    return (select(callLogs)
          ..where((log) => log.userId.equals(userId))
          ..orderBy([(log) => OrderingTerm.desc(log.callStartTime)]))
        .get();
  }

  /// Get call logs by status
  Future<List<CallLogEntry>> getCallLogsByStatus(String status) {
    return (select(callLogs)
          ..where((log) => log.callStatus.equals(status))
          ..orderBy([(log) => OrderingTerm.desc(log.callStartTime)]))
        .get();
  }

  /// Get today's call logs for a user
  Future<List<CallLogEntry>> getTodaysCallLogs(int userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(callLogs)
          ..where(
            (log) =>
                log.userId.equals(userId) &
                log.callStartTime.isBetweenValues(startOfDay, endOfDay),
          )
          ..orderBy([(log) => OrderingTerm.desc(log.callStartTime)]))
        .get();
  }

  // ===== CALL CONTACTS QUERIES =====

  /// Insert a new contact
  Future<int> insertContact(CallContactsCompanion contact) =>
      into(callContacts).insert(contact);

  /// Update an existing contact
  Future<bool> updateContact(int id, CallContactsCompanion contact) =>
      update(callContacts).replace(contact.copyWith(id: Value(id)));

  /// Get all pending contacts
  Future<List<CallContactEntry>> getPendingContacts() {
    return (select(callContacts)
          ..where((contact) => contact.status.equals('pending'))
          ..orderBy([(contact) => OrderingTerm.asc(contact.priority)]))
        .get();
  }

  /// Get contacts by bucket
  Future<List<CallContactEntry>> getContactsByBucket(String bucket) {
    return (select(callContacts)
          ..where((contact) => contact.bucket.equals(bucket))
          ..orderBy([(contact) => OrderingTerm.asc(contact.priority)]))
        .get();
  }

  /// Get contacts assigned to a user
  Future<List<CallContactEntry>> getContactsByUser(int userId) {
    return (select(callContacts)
          ..where((contact) => contact.assignedUserId.equals(userId))
          ..orderBy([(contact) => OrderingTerm.asc(contact.priority)]))
        .get();
  }

  /// Update contact status and last call info
  Future<bool> updateContactStatus(
    int contactId,
    String status, {
    String? lastCallStatus,
    String? notes,
  }) async {
    final companion = CallContactsCompanion(
      status: Value(status),
      lastCallDate: Value(DateTime.now()),
      lastCallStatus: Value(lastCallStatus),
      callAttempts: Value.absent(), // Will be updated separately
      updatedAt: Value(DateTime.now()),
      notes: notes != null ? Value(notes) : const Value.absent(),
    );

    return await (update(
          callContacts,
        )..where((contact) => contact.id.equals(contactId))).write(companion) >
        0;
  }

  /// Increment call attempts for a contact
  Future<void> incrementCallAttempts(int contactId) async {
    final contact = await (select(
      callContacts,
    )..where((c) => c.id.equals(contactId))).getSingleOrNull();

    if (contact != null) {
      await (update(callContacts)..where((c) => c.id.equals(contactId))).write(
        CallContactsCompanion(
          callAttempts: Value(contact.callAttempts + 1),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ===== CALL SESSIONS QUERIES =====

  /// Start a new call session
  Future<int> startCallSession(CallSessionsCompanion session) =>
      into(callSessions).insert(session);

  /// End a call session with statistics
  Future<bool> endCallSession(
    int sessionId, {
    required DateTime endTime,
    required int contactsAttempted,
    required int contactsCompleted,
    required int successfulCalls,
    required int failedCalls,
    required int noAnswerCalls,
    required int hangUpCalls,
    double? successRate,
    int? averageCallDuration,
    String? notes,
  }) async {
    final sessionDuration = endTime
        .difference((await getCallSession(sessionId))!.sessionStart)
        .inMinutes;

    final companion = CallSessionsCompanion(
      sessionEnd: Value(endTime),
      sessionDurationMinutes: Value(sessionDuration),
      contactsAttempted: Value(contactsAttempted),
      contactsCompleted: Value(contactsCompleted),
      successfulCalls: Value(successfulCalls),
      failedCalls: Value(failedCalls),
      noAnswerCalls: Value(noAnswerCalls),
      hangUpCalls: Value(hangUpCalls),
      wasCompleted: const Value(true),
      successRate: Value(successRate),
      averageCallDurationSeconds: Value(averageCallDuration),
      sessionNotes: Value(notes),
      updatedAt: Value(DateTime.now()),
    );

    return await (update(
          callSessions,
        )..where((session) => session.id.equals(sessionId))).write(companion) >
        0;
  }

  /// Get a specific call session
  Future<CallSessionEntry?> getCallSession(int sessionId) {
    return (select(
      callSessions,
    )..where((session) => session.id.equals(sessionId))).getSingleOrNull();
  }

  /// Get sessions for a user in a date range
  Future<List<CallSessionEntry>> getUserSessions(
    int userId,
    DateTime start,
    DateTime end,
  ) {
    return (select(callSessions)
          ..where(
            (session) =>
                session.userId.equals(userId) &
                session.sessionStart.isBetweenValues(start, end),
          )
          ..orderBy([(session) => OrderingTerm.desc(session.sessionStart)]))
        .get();
  }

  // ===== BREAK SESSIONS QUERIES =====

  /// Start a break session
  Future<int> startBreakSession(BreakSessionsCompanion breakSession) =>
      into(breakSessions).insert(breakSession);

  /// End a break session
  Future<bool> endBreakSession(int breakId, DateTime endTime) async {
    final breakEntry = await (select(
      breakSessions,
    )..where((b) => b.id.equals(breakId))).getSingleOrNull();

    if (breakEntry != null) {
      final duration = endTime.difference(breakEntry.breakStart).inMinutes;
      return await (update(
            breakSessions,
          )..where((b) => b.id.equals(breakId))).write(
            BreakSessionsCompanion(
              breakEnd: Value(endTime),
              breakDurationMinutes: Value(duration),
            ),
          ) >
          0;
    }
    return false;
  }

  /// Get break sessions for a user today
  Future<List<BreakSessionEntry>> getTodaysBreaks(int userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(breakSessions)
          ..where(
            (breakSession) =>
                breakSession.userId.equals(userId) &
                breakSession.breakStart.isBetweenValues(startOfDay, endOfDay),
          )
          ..orderBy([
            (breakSession) => OrderingTerm.desc(breakSession.breakStart),
          ]))
        .get();
  }

  // ===== STATISTICS QUERIES =====

  /// Get or create daily stats for a user and date
  Future<DailyStatEntry> getOrCreateDailyStats(
    int userId,
    DateTime date,
  ) async {
    final statDate = DateTime(date.year, date.month, date.day);

    var stats =
        await (select(dailyStats)..where(
              (stat) =>
                  stat.userId.equals(userId) & stat.statDate.equals(statDate),
            ))
            .getSingleOrNull();

    if (stats == null) {
      final id = await into(dailyStats).insert(
        DailyStatsCompanion(
          userId: Value(userId),
          statDate: Value(statDate),
          agentName: const Value.absent(), // Will be set when first updated
        ),
      );

      stats = await (select(
        dailyStats,
      )..where((stat) => stat.id.equals(id))).getSingle();
    }

    return stats;
  }

  /// Update daily statistics
  Future<void> updateDailyStats(
    int userId,
    DateTime date, {
    int? totalCalls,
    int? successfulCalls,
    int? failedCalls,
    int? noAnswerCalls,
    int? hangUpCalls,
    int? totalWorkMinutes,
    int? totalBreakMinutes,
    int? totalCallTimeMinutes,
    int? contactsProcessed,
    int? frontendCalls,
    int? middlecoreCalls,
    int? hardcoreCalls,
    String? agentName,
  }) async {
    final stats = await getOrCreateDailyStats(userId, date);

    // Calculate success rate if we have new call data
    double? successRate;
    if (totalCalls != null && totalCalls > 0) {
      successRate = (successfulCalls ?? 0) / totalCalls;
    }

    // Calculate average call duration
    double? avgDuration;
    if (totalCallTimeMinutes != null && totalCalls != null && totalCalls > 0) {
      avgDuration = totalCallTimeMinutes / totalCalls;
    }

    await (update(dailyStats)..where((stat) => stat.id.equals(stats.id))).write(
      DailyStatsCompanion(
        totalCalls: totalCalls != null
            ? Value(totalCalls)
            : const Value.absent(),
        successfulCalls: successfulCalls != null
            ? Value(successfulCalls)
            : const Value.absent(),
        failedCalls: failedCalls != null
            ? Value(failedCalls)
            : const Value.absent(),
        noAnswerCalls: noAnswerCalls != null
            ? Value(noAnswerCalls)
            : const Value.absent(),
        hangUpCalls: hangUpCalls != null
            ? Value(hangUpCalls)
            : const Value.absent(),
        totalWorkMinutes: totalWorkMinutes != null
            ? Value(totalWorkMinutes)
            : const Value.absent(),
        totalBreakMinutes: totalBreakMinutes != null
            ? Value(totalBreakMinutes)
            : const Value.absent(),
        totalCallTimeMinutes: totalCallTimeMinutes != null
            ? Value(totalCallTimeMinutes)
            : const Value.absent(),
        contactsProcessed: contactsProcessed != null
            ? Value(contactsProcessed)
            : const Value.absent(),
        frontendCalls: frontendCalls != null
            ? Value(frontendCalls)
            : const Value.absent(),
        middlecoreCalls: middlecoreCalls != null
            ? Value(middlecoreCalls)
            : const Value.absent(),
        hardcoreCalls: hardcoreCalls != null
            ? Value(hardcoreCalls)
            : const Value.absent(),
        successRate: successRate != null
            ? Value(successRate)
            : const Value.absent(),
        averageCallDuration: avgDuration != null
            ? Value(avgDuration)
            : const Value.absent(),
        agentName: agentName != null ? Value(agentName) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get daily stats for a date range
  Future<List<DailyStatEntry>> getDailyStatsRange(
    int userId,
    DateTime start,
    DateTime end,
  ) {
    return (select(dailyStats)
          ..where(
            (stat) =>
                stat.userId.equals(userId) &
                stat.statDate.isBetweenValues(start, end),
          )
          ..orderBy([(stat) => OrderingTerm.desc(stat.statDate)]))
        .get();
  }

  // ===== CALL ATTEMPTS QUERIES =====

  /// Record a call attempt
  Future<int> recordCallAttempt(CallAttemptsCompanion attempt) =>
      into(callAttempts).insert(attempt);

  /// Get call attempts for a contact
  Future<List<CallAttemptEntry>> getCallAttempts(int contactId) {
    return (select(callAttempts)
          ..where((attempt) => attempt.contactId.equals(contactId))
          ..orderBy([(attempt) => OrderingTerm.desc(attempt.attemptTime)]))
        .get();
  }

  /// Get the latest attempt number for a contact
  Future<int> getLatestAttemptNumber(int contactId) async {
    final result =
        await (select(callAttempts)
              ..where((attempt) => attempt.contactId.equals(contactId))
              ..orderBy([(attempt) => OrderingTerm.desc(attempt.attemptNumber)])
              ..limit(1))
            .getSingleOrNull();

    return result?.attemptNumber ?? 0;
  }

  // ===== UTILITY METHODS =====

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await delete(callAttempts).go();
    await delete(dailyStats).go();
    await delete(breakSessions).go();
    await delete(callSessions).go();
    await delete(callLogs).go();
    await delete(callContacts).go();
  }

  /// Get database size information
  Future<Map<String, int>> getDatabaseStats() async {
    final results = <String, int>{};

    results['call_logs'] =
        await (selectOnly(callLogs)..addColumns([callLogs.id.count()]))
            .getSingle()
            .then((row) => row.read(callLogs.id.count()) ?? 0);

    results['call_contacts'] =
        await (selectOnly(callContacts)..addColumns([callContacts.id.count()]))
            .getSingle()
            .then((row) => row.read(callContacts.id.count()) ?? 0);

    results['call_sessions'] =
        await (selectOnly(callSessions)..addColumns([callSessions.id.count()]))
            .getSingle()
            .then((row) => row.read(callSessions.id.count()) ?? 0);

    return results;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'lenderly_dialer.db'));

    // Make sure to initialize sqlite3 on some platforms
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
