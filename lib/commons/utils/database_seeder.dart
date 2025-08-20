import 'dart:math';
import '../services/call_log_service.dart';
import '../services/dialer_database_integration.dart';
import '../models/call_log_model.dart';
import '../models/call_contact_model.dart';

/// Database seeder to populate test data for development and testing
class DatabaseSeeder {
  static final CallLogService _callLogService = CallLogService();
  static final DialerDatabaseIntegration _dbIntegration =
      DialerDatabaseIntegration();
  static final Random _random = Random();

  /// Initialize services
  static Future<void> initialize() async {
    await _callLogService.initialize();
    await _dbIntegration.initialize();
  }

  /// Clear all existing data
  static Future<void> clearAllData() async {
    await _callLogService.clearAllData();
    print('🗑️ Cleared all existing database data');
  }

  /// Seed the database with comprehensive test data
  static Future<void> seedDatabase({
    int userId = 1,
    String agentName = 'Test Agent',
    int daysOfHistory = 7,
    int callsPerDay = 15,
  }) async {
    try {
      await initialize();

      print('🌱 Starting database seeding...');
      print('📊 Parameters:');
      print('   - User ID: $userId');
      print('   - Agent Name: $agentName');
      print('   - Days of history: $daysOfHistory');
      print('   - Calls per day: $callsPerDay');

      // Generate test data for the last N days
      final now = DateTime.now();
      int totalCalls = 0;
      int totalSessions = 0;

      for (int dayOffset = 0; dayOffset < daysOfHistory; dayOffset++) {
        final date = now.subtract(Duration(days: dayOffset));
        final isToday = dayOffset == 0;

        print(
          '\n📅 Seeding data for ${_formatDate(date)}${isToday ? " (today)" : ""}',
        );

        // Create 2-3 dialing sessions per day
        final sessionsPerDay = _random.nextInt(3) + 1; // 1-3 sessions

        for (
          int sessionIndex = 0;
          sessionIndex < sessionsPerDay;
          sessionIndex++
        ) {
          // Create test contacts for this session
          final contacts = _generateTestContacts(callsPerDay ~/ sessionsPerDay);

          // Start session
          final sessionId = await _dbIntegration.startDialingSession(
            userId: userId,
            sessionType: _getRandomSessionType(),
            contacts: contacts,
            agentName: agentName,
            bucket: _getRandomBucket(),
          );

          totalSessions++;

          // Generate calls for this session
          final callsInSession = contacts.length;
          int successfulCalls = 0;
          int failedCalls = 0;
          int noAnswerCalls = 0;
          int hangUpCalls = 0;

          for (int callIndex = 0; callIndex < callsInSession; callIndex++) {
            final contact = contacts[callIndex];

            // Start the call
            final callLogId = await _dbIntegration.logCallStart(
              contact: contact,
              sessionId: sessionId,
              userId: userId,
              agentName: agentName,
            );

            // Determine call outcome
            final status = _getRandomCallStatus();
            final callDuration = _getCallDuration(status);
            final outcome = _getCallOutcome(status);
            final notes = _generateCallNotes(status);

            // End the call
            await _dbIntegration.logCallEnd(
              callLogId: callLogId,
              callDuration: callDuration,
              status: status,
              notes: notes,
              outcome: outcome,
            );

            // Update counters
            switch (status) {
              case CallStatus.complete:
                successfulCalls++;
                break;
              case CallStatus.hangUp:
                hangUpCalls++;
                break;
              case CallStatus.noAnswer:
                noAnswerCalls++;
                break;
              default:
                failedCalls++;
                break;
            }

            totalCalls++;
          }

          // End session with statistics
          final stats = DialerDatabaseIntegration.createSessionStats(
            totalContacts: callsInSession,
            attempted: callsInSession,
            completed: callsInSession,
            successful: successfulCalls,
            failed: failedCalls,
            noAnswer: noAnswerCalls,
            hangUp: hangUpCalls,
          );

          await _dbIntegration.endDialingSession(sessionId, stats);

          print(
            '   📞 Session ${sessionIndex + 1}: $callsInSession calls ($successfulCalls successful, ${failedCalls + noAnswerCalls + hangUpCalls} failed)',
          );
        }

        // Add some break sessions for variety (randomly)
        if (_random.nextBool() && dayOffset < 3) {
          // Only recent days
          await _createRandomBreakSessions(userId, date);
        }
      }

      print('\n✅ Database seeding completed!');
      print('📈 Summary:');
      print('   - Total calls: $totalCalls');
      print('   - Total sessions: $totalSessions');
      print('   - Days seeded: $daysOfHistory');

      // Display today's stats
      final todaysStats = await _callLogService.getTodaysStats(userId);
      print('\n📊 Today\'s Statistics:');
      print('   - Total calls: ${todaysStats['total_calls']}');
      print('   - Successful: ${todaysStats['successful_calls']}');
      print(
        '   - Success rate: ${todaysStats['success_rate'].toStringAsFixed(1)}%',
      );
      print(
        '   - Avg duration: ${todaysStats['average_call_duration'].toStringAsFixed(1)}s',
      );
    } catch (e) {
      print('❌ Error during database seeding: $e');
      rethrow;
    }
  }

  /// Generate test contacts
  static List<CallContact> _generateTestContacts(int count) {
    final contacts = <CallContact>[];

    for (int i = 0; i < count; i++) {
      contacts.add(
        CallContact(
          id: 1000 + i,
          loanId: 2000 + i,
          borrowerName: _generateRandomName(),
          borrowerPhone: _generateRandomPhone(),
          coMakerName: _random.nextBool() ? _generateRandomName() : null,
          coMakerPhone: _random.nextBool() ? _generateRandomPhone() : null,
          bucket: _getRandomBucket(),
          status: 'pending',
        ),
      );
    }

    return contacts;
  }

  /// Create random break sessions
  static Future<void> _createRandomBreakSessions(
    int userId,
    DateTime date,
  ) async {
    final breakTypes = ['short_break', 'lunch', 'meeting'];
    final breakCount = _random.nextInt(3) + 1; // 1-3 breaks per day

    for (int i = 0; i < breakCount; i++) {
      final duration = _getBreakDuration(
        breakTypes[_random.nextInt(breakTypes.length)],
      );

      // Create break session in database
      // Note: You may need to implement this method in your database integration
      print(
        '   ☕ Break: ${breakTypes[_random.nextInt(breakTypes.length)]} (${duration.inMinutes}m)',
      );
    }
  }

  /// Get random call status
  static CallStatus _getRandomCallStatus() {
    final statuses = [
      CallStatus.complete,
      CallStatus.noAnswer,
      CallStatus.hangUp,
      CallStatus.complete, // Higher chance of success
      CallStatus.complete,
    ];
    return statuses[_random.nextInt(statuses.length)];
  }

  /// Get call duration based on status
  static Duration _getCallDuration(CallStatus status) {
    switch (status) {
      case CallStatus.complete:
        return Duration(seconds: 120 + _random.nextInt(300)); // 2-7 minutes
      case CallStatus.hangUp:
        return Duration(seconds: 30 + _random.nextInt(90)); // 30s-2m
      case CallStatus.noAnswer:
        return Duration(seconds: 20 + _random.nextInt(40)); // 20s-1m
      default:
        return Duration(seconds: 15 + _random.nextInt(45)); // 15s-1m
    }
  }

  /// Get call outcome based on status
  static String _getCallOutcome(CallStatus status) {
    switch (status) {
      case CallStatus.complete:
        final outcomes = [
          'Payment promise received',
          'Contact information updated',
          'Dispute resolved',
          'Partial payment arranged',
          'Follow-up scheduled',
        ];
        return outcomes[_random.nextInt(outcomes.length)];
      case CallStatus.hangUp:
        return 'Customer hung up';
      case CallStatus.noAnswer:
        return 'No answer, voicemail left';
      default:
        return 'Call unsuccessful';
    }
  }

  /// Generate call notes based on status
  static String? _generateCallNotes(CallStatus status) {
    if (_random.nextInt(3) == 0) return null; // 33% chance of no notes

    switch (status) {
      case CallStatus.complete:
        final notes = [
          'Customer was cooperative and agreed to payment plan',
          'Updated contact information and verified employment',
          'Discussed payment options, customer needs time to decide',
          'Partial payment of \$150 promised by end of week',
          'Customer experiencing temporary financial difficulty',
        ];
        return notes[_random.nextInt(notes.length)];
      case CallStatus.hangUp:
        final notes = [
          'Customer hung up immediately',
          'Customer was hostile and refused to discuss',
          'Wrong number, customer hung up',
        ];
        return notes[_random.nextInt(notes.length)];
      case CallStatus.noAnswer:
        final notes = [
          'Left voicemail with callback number',
          'Phone went straight to voicemail',
          'Busy signal, will try again later',
        ];
        return notes[_random.nextInt(notes.length)];
      default:
        return 'Standard call notes';
    }
  }

  /// Generate random name
  static String _generateRandomName() {
    final firstNames = [
      'John',
      'Jane',
      'Michael',
      'Sarah',
      'David',
      'Emma',
      'Chris',
      'Lisa',
      'Robert',
      'Maria',
      'James',
      'Jennifer',
      'William',
      'Amanda',
      'Mark',
      'Jessica',
    ];
    final lastNames = [
      'Smith',
      'Johnson',
      'Williams',
      'Brown',
      'Jones',
      'Garcia',
      'Miller',
      'Davis',
      'Rodriguez',
      'Martinez',
      'Hernandez',
      'Lopez',
      'Gonzalez',
      'Wilson',
      'Anderson',
      'Thomas',
    ];

    return '${firstNames[_random.nextInt(firstNames.length)]} ${lastNames[_random.nextInt(lastNames.length)]}';
  }

  /// Generate random phone number
  static String _generateRandomPhone() {
    return '+1${_random.nextInt(900) + 100}${_random.nextInt(900) + 100}${_random.nextInt(9000) + 1000}';
  }

  /// Get random session type
  static String _getRandomSessionType() {
    final types = ['manual', 'bucket_borrower', 'bucket_comaker', 'bucket_all'];
    return types[_random.nextInt(types.length)];
  }

  /// Get random bucket
  static String _getRandomBucket() {
    final buckets = ['frontend', 'middlecore', 'hardcore'];
    return buckets[_random.nextInt(buckets.length)];
  }

  /// Get break duration based on type
  static Duration _getBreakDuration(String breakType) {
    switch (breakType) {
      case 'short_break':
        return Duration(minutes: 10 + _random.nextInt(10)); // 10-20 minutes
      case 'lunch':
        return Duration(minutes: 30 + _random.nextInt(30)); // 30-60 minutes
      case 'meeting':
        return Duration(minutes: 15 + _random.nextInt(30)); // 15-45 minutes
      default:
        return const Duration(minutes: 15);
    }
  }

  /// Format date for display
  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Quick seed for development (less data)
  static Future<void> quickSeed({
    int userId = 1,
    String agentName = 'Dev User',
  }) async {
    await seedDatabase(
      userId: userId,
      agentName: agentName,
      daysOfHistory: 3,
      callsPerDay: 8,
    );
  }

  /// Full seed for comprehensive testing
  static Future<void> fullSeed({
    int userId = 1,
    String agentName = 'Test User',
  }) async {
    await seedDatabase(
      userId: userId,
      agentName: agentName,
      daysOfHistory: 14,
      callsPerDay: 25,
    );
  }
}
