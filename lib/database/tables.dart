import 'package:drift/drift.dart';

// Call Logs Table - Store detailed call information for statistics
@DataClassName('CallLogEntry')
class CallLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Foreign key to contacts table
  IntColumn get contactId => integer().nullable()();

  // Call details
  IntColumn get loanId => integer().nullable()();
  TextColumn get borrowerName => text().withLength(min: 1, max: 255)();
  TextColumn get borrowerPhone => text().withLength(min: 1, max: 50)();
  TextColumn get coMakerName =>
      text().nullable().withLength(min: 1, max: 255)();
  TextColumn get coMakerPhone =>
      text().nullable().withLength(min: 1, max: 50)();

  // Call timing and duration
  DateTimeColumn get callStartTime => dateTime()();
  DateTimeColumn get callEndTime => dateTime().nullable()();
  IntColumn get callDurationSeconds =>
      integer().nullable()(); // Duration in seconds

  // Call outcome and status
  TextColumn get callStatus => text().withLength(
    min: 1,
    max: 50,
  )(); // pending, complete, no_answer, hang_up, called
  TextColumn get callOutcome => text().nullable().withLength(
    min: 1,
    max: 100,
  )(); // successful, failed, busy, etc.

  // Notes and comments
  TextColumn get notes => text().nullable().withLength(min: 0, max: 1000)();

  // Bucket and assignment info
  TextColumn get bucket => text().nullable().withLength(
    min: 1,
    max: 50,
  )(); // frontend, middlecore, hardcore
  IntColumn get sessionId => integer().nullable()(); // Link to dialing session

  // System fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // User tracking
  IntColumn get userId => integer().nullable()();
  TextColumn get agentName => text().nullable().withLength(min: 1, max: 255)();

  // Additional metadata for analytics
  BoolColumn get wasSuccessful =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get requiresFollowUp =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get nextCallScheduled => dateTime().nullable()();
}

// Call Contacts Table - Store contact information
@DataClassName('CallContactEntry')
class CallContacts extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Loan and contact details
  IntColumn get loanId => integer().nullable()();
  TextColumn get borrowerName => text().withLength(min: 1, max: 255)();
  TextColumn get borrowerPhone => text().withLength(min: 1, max: 50)();
  TextColumn get coMakerName =>
      text().nullable().withLength(min: 1, max: 255)();
  TextColumn get coMakerPhone =>
      text().nullable().withLength(min: 1, max: 50)();

  // Status and priority
  TextColumn get status => text()
      .withLength(min: 1, max: 50)
      .withDefault(const Constant('pending'))();
  TextColumn get bucket => text().nullable().withLength(min: 1, max: 50)();
  IntColumn get priority =>
      integer().withDefault(const Constant(0))(); // 0=normal, 1=high, 2=urgent

  // Last contact information
  DateTimeColumn get lastCallDate => dateTime().nullable()();
  TextColumn get lastCallStatus =>
      text().nullable().withLength(min: 1, max: 50)();
  IntColumn get callAttempts => integer().withDefault(const Constant(0))();

  // System fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Assignment and user tracking
  IntColumn get assignedUserId => integer().nullable()();
  DateTimeColumn get assignedAt => dateTime().nullable()();

  // Additional notes
  TextColumn get notes => text().nullable().withLength(min: 0, max: 1000)();

  // Flags for management
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get doNotCall => boolean().withDefault(const Constant(false))();
}

// Call Sessions Table - Store dialing session information for analytics
@DataClassName('CallSessionEntry')
class CallSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Session details
  DateTimeColumn get sessionStart => dateTime()();
  DateTimeColumn get sessionEnd => dateTime().nullable()();
  IntColumn get sessionDurationMinutes => integer().nullable()();

  // User and bucket info
  IntColumn get userId => integer()();
  TextColumn get agentName => text().nullable().withLength(min: 1, max: 255)();
  TextColumn get bucket => text().nullable().withLength(min: 1, max: 50)();

  // Session statistics
  IntColumn get totalContacts => integer().withDefault(const Constant(0))();
  IntColumn get contactsAttempted => integer().withDefault(const Constant(0))();
  IntColumn get contactsCompleted => integer().withDefault(const Constant(0))();
  IntColumn get successfulCalls => integer().withDefault(const Constant(0))();
  IntColumn get failedCalls => integer().withDefault(const Constant(0))();
  IntColumn get noAnswerCalls => integer().withDefault(const Constant(0))();
  IntColumn get hangUpCalls => integer().withDefault(const Constant(0))();

  // Session type and mode
  TextColumn get sessionType => text().withLength(
    min: 1,
    max: 50,
  )(); // auto_dialing, manual, co_maker_only, borrower_only
  BoolColumn get wasCompleted => boolean().withDefault(const Constant(false))();

  // System fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Additional analytics
  RealColumn get successRate =>
      real().nullable()(); // Percentage of successful calls
  IntColumn get averageCallDurationSeconds => integer().nullable()();
  TextColumn get sessionNotes =>
      text().nullable().withLength(min: 0, max: 500)();
}

// Break Sessions Table - Track agent break times for productivity analytics
@DataClassName('BreakSessionEntry')
class BreakSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Break details
  DateTimeColumn get breakStart => dateTime()();
  DateTimeColumn get breakEnd => dateTime().nullable()();
  DateTimeColumn get breakDate => dateTime()(); // Date when the break occurred (for easier querying)
  IntColumn get breakDurationMinutes => integer().nullable()();

  // Break type
  TextColumn get breakType => text().withLength(
    min: 1,
    max: 50,
  )(); // short_break, lunch, meeting, technical_issue
  TextColumn get breakReason =>
      text().nullable().withLength(min: 0, max: 255)();

  // User tracking
  IntColumn get userId => integer()();
  TextColumn get agentName => text().nullable().withLength(min: 1, max: 255)();

  // System fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Optional session association
  IntColumn get callSessionId => integer().nullable()();
}

// Daily Statistics Table - Store daily performance metrics
@DataClassName('DailyStatEntry')
class DailyStats extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Date and user
  DateTimeColumn get statDate => dateTime()();
  IntColumn get userId => integer()();
  TextColumn get agentName => text().nullable().withLength(min: 1, max: 255)();

  // Daily call statistics
  IntColumn get totalCalls => integer().withDefault(const Constant(0))();
  IntColumn get successfulCalls => integer().withDefault(const Constant(0))();
  IntColumn get failedCalls => integer().withDefault(const Constant(0))();
  IntColumn get noAnswerCalls => integer().withDefault(const Constant(0))();
  IntColumn get hangUpCalls => integer().withDefault(const Constant(0))();

  // Time tracking
  IntColumn get totalWorkMinutes => integer().withDefault(const Constant(0))();
  IntColumn get totalBreakMinutes => integer().withDefault(const Constant(0))();
  IntColumn get totalCallTimeMinutes =>
      integer().withDefault(const Constant(0))();

  // Performance metrics
  RealColumn get successRate => real().nullable()();
  RealColumn get averageCallDuration => real().nullable()();
  IntColumn get contactsProcessed => integer().withDefault(const Constant(0))();

  // Bucket breakdown
  IntColumn get frontendCalls => integer().withDefault(const Constant(0))();
  IntColumn get middlecoreCalls => integer().withDefault(const Constant(0))();
  IntColumn get hardcoreCalls => integer().withDefault(const Constant(0))();

  // System fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Call Attempts Table - Track multiple attempts to the same contact
@DataClassName('CallAttemptEntry')
class CallAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Reference to contact and call log
  IntColumn get contactId => integer()();
  IntColumn get callLogId => integer().nullable()();

  // Attempt details
  DateTimeColumn get attemptTime => dateTime()();
  IntColumn get attemptNumber => integer()(); // 1, 2, 3, etc.
  TextColumn get phoneNumberCalled => text().withLength(min: 1, max: 50)();
  TextColumn get phoneType =>
      text().withLength(min: 1, max: 20)(); // borrower, co_maker

  // Attempt outcome
  TextColumn get outcome => text().withLength(
    min: 1,
    max: 50,
  )(); // connected, no_answer, busy, invalid_number, hang_up
  IntColumn get callDurationSeconds => integer().nullable()();

  // System fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get userId => integer().nullable()();

  // Notes for this specific attempt
  TextColumn get attemptNotes =>
      text().nullable().withLength(min: 0, max: 500)();
}
