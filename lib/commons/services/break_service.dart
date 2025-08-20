import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../models/break_session_model.dart';

class BreakService {
  final AppDatabase _database;

  BreakService(this._database);

  /// Start a new break session
  Future<BreakSession> startBreakSession({
    required BreakType type,
    required int userId,
    String? reason,
    String? agentName,
  }) async {
    try {
      // End any active break sessions first
      await _endActiveBreakSessions(userId);

      final now = DateTime.now();
      final breakDate = DateTime(now.year, now.month, now.day); // Date without time
      final breakId = await _database.startBreakSession(
        BreakSessionsCompanion(
          breakStart: Value(now),
          breakDate: Value(breakDate),
          breakType: Value(_mapBreakTypeToString(type)),
          breakReason: Value(reason),
          userId: Value(userId),
          agentName: Value(agentName),
        ),
      );

      return BreakSession(
        id: breakId,
        type: type,
        startTime: now,
        date: breakDate,
        reason: reason,
        isActive: true,
      );
    } catch (e) {
      throw Exception('Failed to start break session: $e');
    }
  }

  /// End the current active break session
  Future<BreakSession?> endActiveBreakSession(int userId) async {
    try {
      final activeBreak = await getActiveBreakSession(userId);
      if (activeBreak == null) return null;

      final endTime = DateTime.now();
      final success = await _database.endBreakSession(activeBreak.id!, endTime);

      if (success) {
        return activeBreak.copyWith(endTime: endTime, isActive: false);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to end break session: $e');
    }
  }

  /// Get the current active break session for a user
  Future<BreakSession?> getActiveBreakSession(int userId) async {
    try {
      final breaks = await _database.getTodaysBreaks(userId);
      final activeBreak = breaks.where((b) => b.breakEnd == null).firstOrNull;

      if (activeBreak != null) {
        return BreakSession(
          id: activeBreak.id,
          type: _mapStringToBreakType(activeBreak.breakType),
          startTime: activeBreak.breakStart,
          endTime: activeBreak.breakEnd,
          date: activeBreak.breakDate,
          reason: activeBreak.breakReason,
          isActive: activeBreak.breakEnd == null,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get active break session: $e');
    }
  }

  /// Get all break sessions for a user on a specific date
  Future<List<BreakSession>> getBreakSessionsForDate(
    int userId,
    DateTime date,
  ) async {
    try {
      final targetDate = DateTime(date.year, date.month, date.day);

      final query = _database.select(_database.breakSessions)
        ..where(
          (session) =>
              session.userId.equals(userId) &
              session.breakDate.equals(targetDate),
        )
        ..orderBy([(session) => OrderingTerm.desc(session.breakStart)]);

      final breaks = await query.get();

      return breaks.map((break_) {
        return BreakSession(
          id: break_.id,
          type: _mapStringToBreakType(break_.breakType),
          startTime: break_.breakStart,
          endTime: break_.breakEnd,
          date: break_.breakDate,
          reason: break_.breakReason,
          isActive: break_.breakEnd == null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get break sessions for date: $e');
    }
  }

  /// Get today's break sessions for a user
  Future<List<BreakSession>> getTodaysBreakSessions(int userId) async {
    return getBreakSessionsForDate(userId, DateTime.now());
  }

  /// Get break statistics for a user on a specific date
  Future<Map<String, dynamic>> getBreakStatisticsForDate(
    int userId,
    DateTime date,
  ) async {
    try {
      final breaks = await getBreakSessionsForDate(userId, date);

      int totalBreakTime = 0;
      int shortBreaks = 0;
      int lunchBreaks = 0;
      int meetings = 0;
      int customerSupportBreaks = 0;
      int activeBreaks = 0;

      for (final breakSession in breaks) {
        // Count break types
        switch (breakSession.type) {
          case BreakType.shortBreak:
            shortBreaks++;
            break;
          case BreakType.lunch:
            lunchBreaks++;
            break;
          case BreakType.meeting:
            meetings++;
            break;
          case BreakType.customerSupportBreak:
            customerSupportBreaks++;
            break;
        }

        // Calculate total break time
        if (breakSession.endTime != null) {
          totalBreakTime += breakSession.actualDuration.inMinutes;
        } else {
          activeBreaks++;
          // For active breaks, calculate time so far
          totalBreakTime += breakSession.actualDuration.inMinutes;
        }
      }

      return {
        'total_breaks': breaks.length,
        'total_break_time_minutes': totalBreakTime,
        'short_breaks': shortBreaks,
        'lunch_breaks': lunchBreaks,
        'meetings': meetings,
        'customer_support_breaks': customerSupportBreaks,
        'active_breaks': activeBreaks,
        'average_break_duration': breaks.isNotEmpty
            ? totalBreakTime / breaks.length
            : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get break statistics: $e');
    }
  }

  /// End all active break sessions for a user (cleanup method)
  Future<void> _endActiveBreakSessions(int userId) async {
    try {
      final activeBreak = await getActiveBreakSession(userId);
      if (activeBreak != null) {
        await endActiveBreakSession(userId);
      }
    } catch (e) {
      // Log error but don't throw, as this is a cleanup operation
    }
  }

  /// Map BreakType enum to database string
  String _mapBreakTypeToString(BreakType type) {
    switch (type) {
      case BreakType.shortBreak:
        return 'short_break';
      case BreakType.lunch:
        return 'lunch';
      case BreakType.meeting:
        return 'meeting';
      case BreakType.customerSupportBreak:
        return 'customer_support_break';
    }
  }

  /// Map database string to BreakType enum
  BreakType _mapStringToBreakType(String type) {
    switch (type) {
      case 'short_break':
        return BreakType.shortBreak;
      case 'lunch':
        return BreakType.lunch;
      case 'meeting':
        return BreakType.meeting;
      case 'customer_support_break':
        return BreakType.customerSupportBreak;
      default:
        return BreakType.shortBreak; // Default fallback
    }
  }
}
