// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CallLogsTable extends CallLogs
    with TableInfo<$CallLogsTable, CallLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<int> loanId = GeneratedColumn<int>(
    'loan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _borrowerNameMeta = const VerificationMeta(
    'borrowerName',
  );
  @override
  late final GeneratedColumn<String> borrowerName = GeneratedColumn<String>(
    'borrower_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _borrowerPhoneMeta = const VerificationMeta(
    'borrowerPhone',
  );
  @override
  late final GeneratedColumn<String> borrowerPhone = GeneratedColumn<String>(
    'borrower_phone',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coMakerNameMeta = const VerificationMeta(
    'coMakerName',
  );
  @override
  late final GeneratedColumn<String> coMakerName = GeneratedColumn<String>(
    'co_maker_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coMakerPhoneMeta = const VerificationMeta(
    'coMakerPhone',
  );
  @override
  late final GeneratedColumn<String> coMakerPhone = GeneratedColumn<String>(
    'co_maker_phone',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _callStartTimeMeta = const VerificationMeta(
    'callStartTime',
  );
  @override
  late final GeneratedColumn<DateTime> callStartTime =
      GeneratedColumn<DateTime>(
        'call_start_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _callEndTimeMeta = const VerificationMeta(
    'callEndTime',
  );
  @override
  late final GeneratedColumn<DateTime> callEndTime = GeneratedColumn<DateTime>(
    'call_end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _callDurationSecondsMeta =
      const VerificationMeta('callDurationSeconds');
  @override
  late final GeneratedColumn<int> callDurationSeconds = GeneratedColumn<int>(
    'call_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _callStatusMeta = const VerificationMeta(
    'callStatus',
  );
  @override
  late final GeneratedColumn<String> callStatus = GeneratedColumn<String>(
    'call_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callOutcomeMeta = const VerificationMeta(
    'callOutcome',
  );
  @override
  late final GeneratedColumn<String> callOutcome = GeneratedColumn<String>(
    'call_outcome',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 1000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _agentNameMeta = const VerificationMeta(
    'agentName',
  );
  @override
  late final GeneratedColumn<String> agentName = GeneratedColumn<String>(
    'agent_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasSuccessfulMeta = const VerificationMeta(
    'wasSuccessful',
  );
  @override
  late final GeneratedColumn<bool> wasSuccessful = GeneratedColumn<bool>(
    'was_successful',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_successful" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _requiresFollowUpMeta = const VerificationMeta(
    'requiresFollowUp',
  );
  @override
  late final GeneratedColumn<bool> requiresFollowUp = GeneratedColumn<bool>(
    'requires_follow_up',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_follow_up" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nextCallScheduledMeta = const VerificationMeta(
    'nextCallScheduled',
  );
  @override
  late final GeneratedColumn<DateTime> nextCallScheduled =
      GeneratedColumn<DateTime>(
        'next_call_scheduled',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    loanId,
    borrowerName,
    borrowerPhone,
    coMakerName,
    coMakerPhone,
    callStartTime,
    callEndTime,
    callDurationSeconds,
    callStatus,
    callOutcome,
    notes,
    bucket,
    sessionId,
    createdAt,
    updatedAt,
    userId,
    agentName,
    wasSuccessful,
    requiresFollowUp,
    nextCallScheduled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('loan_id')) {
      context.handle(
        _loanIdMeta,
        loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta),
      );
    }
    if (data.containsKey('borrower_name')) {
      context.handle(
        _borrowerNameMeta,
        borrowerName.isAcceptableOrUnknown(
          data['borrower_name']!,
          _borrowerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_borrowerNameMeta);
    }
    if (data.containsKey('borrower_phone')) {
      context.handle(
        _borrowerPhoneMeta,
        borrowerPhone.isAcceptableOrUnknown(
          data['borrower_phone']!,
          _borrowerPhoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_borrowerPhoneMeta);
    }
    if (data.containsKey('co_maker_name')) {
      context.handle(
        _coMakerNameMeta,
        coMakerName.isAcceptableOrUnknown(
          data['co_maker_name']!,
          _coMakerNameMeta,
        ),
      );
    }
    if (data.containsKey('co_maker_phone')) {
      context.handle(
        _coMakerPhoneMeta,
        coMakerPhone.isAcceptableOrUnknown(
          data['co_maker_phone']!,
          _coMakerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('call_start_time')) {
      context.handle(
        _callStartTimeMeta,
        callStartTime.isAcceptableOrUnknown(
          data['call_start_time']!,
          _callStartTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_callStartTimeMeta);
    }
    if (data.containsKey('call_end_time')) {
      context.handle(
        _callEndTimeMeta,
        callEndTime.isAcceptableOrUnknown(
          data['call_end_time']!,
          _callEndTimeMeta,
        ),
      );
    }
    if (data.containsKey('call_duration_seconds')) {
      context.handle(
        _callDurationSecondsMeta,
        callDurationSeconds.isAcceptableOrUnknown(
          data['call_duration_seconds']!,
          _callDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('call_status')) {
      context.handle(
        _callStatusMeta,
        callStatus.isAcceptableOrUnknown(data['call_status']!, _callStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_callStatusMeta);
    }
    if (data.containsKey('call_outcome')) {
      context.handle(
        _callOutcomeMeta,
        callOutcome.isAcceptableOrUnknown(
          data['call_outcome']!,
          _callOutcomeMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('agent_name')) {
      context.handle(
        _agentNameMeta,
        agentName.isAcceptableOrUnknown(data['agent_name']!, _agentNameMeta),
      );
    }
    if (data.containsKey('was_successful')) {
      context.handle(
        _wasSuccessfulMeta,
        wasSuccessful.isAcceptableOrUnknown(
          data['was_successful']!,
          _wasSuccessfulMeta,
        ),
      );
    }
    if (data.containsKey('requires_follow_up')) {
      context.handle(
        _requiresFollowUpMeta,
        requiresFollowUp.isAcceptableOrUnknown(
          data['requires_follow_up']!,
          _requiresFollowUpMeta,
        ),
      );
    }
    if (data.containsKey('next_call_scheduled')) {
      context.handle(
        _nextCallScheduledMeta,
        nextCallScheduled.isAcceptableOrUnknown(
          data['next_call_scheduled']!,
          _nextCallScheduledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      ),
      loanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loan_id'],
      ),
      borrowerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}borrower_name'],
      )!,
      borrowerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}borrower_phone'],
      )!,
      coMakerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co_maker_name'],
      ),
      coMakerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co_maker_phone'],
      ),
      callStartTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}call_start_time'],
      )!,
      callEndTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}call_end_time'],
      ),
      callDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_duration_seconds'],
      ),
      callStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_status'],
      )!,
      callOutcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_outcome'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      agentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_name'],
      ),
      wasSuccessful: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_successful'],
      )!,
      requiresFollowUp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_follow_up'],
      )!,
      nextCallScheduled: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_call_scheduled'],
      ),
    );
  }

  @override
  $CallLogsTable createAlias(String alias) {
    return $CallLogsTable(attachedDatabase, alias);
  }
}

class CallLogEntry extends DataClass implements Insertable<CallLogEntry> {
  final int id;
  final int? contactId;
  final int? loanId;
  final String borrowerName;
  final String borrowerPhone;
  final String? coMakerName;
  final String? coMakerPhone;
  final DateTime callStartTime;
  final DateTime? callEndTime;
  final int? callDurationSeconds;
  final String callStatus;
  final String? callOutcome;
  final String? notes;
  final String? bucket;
  final int? sessionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? userId;
  final String? agentName;
  final bool wasSuccessful;
  final bool requiresFollowUp;
  final DateTime? nextCallScheduled;
  const CallLogEntry({
    required this.id,
    this.contactId,
    this.loanId,
    required this.borrowerName,
    required this.borrowerPhone,
    this.coMakerName,
    this.coMakerPhone,
    required this.callStartTime,
    this.callEndTime,
    this.callDurationSeconds,
    required this.callStatus,
    this.callOutcome,
    this.notes,
    this.bucket,
    this.sessionId,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.agentName,
    required this.wasSuccessful,
    required this.requiresFollowUp,
    this.nextCallScheduled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    if (!nullToAbsent || loanId != null) {
      map['loan_id'] = Variable<int>(loanId);
    }
    map['borrower_name'] = Variable<String>(borrowerName);
    map['borrower_phone'] = Variable<String>(borrowerPhone);
    if (!nullToAbsent || coMakerName != null) {
      map['co_maker_name'] = Variable<String>(coMakerName);
    }
    if (!nullToAbsent || coMakerPhone != null) {
      map['co_maker_phone'] = Variable<String>(coMakerPhone);
    }
    map['call_start_time'] = Variable<DateTime>(callStartTime);
    if (!nullToAbsent || callEndTime != null) {
      map['call_end_time'] = Variable<DateTime>(callEndTime);
    }
    if (!nullToAbsent || callDurationSeconds != null) {
      map['call_duration_seconds'] = Variable<int>(callDurationSeconds);
    }
    map['call_status'] = Variable<String>(callStatus);
    if (!nullToAbsent || callOutcome != null) {
      map['call_outcome'] = Variable<String>(callOutcome);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || bucket != null) {
      map['bucket'] = Variable<String>(bucket);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    if (!nullToAbsent || agentName != null) {
      map['agent_name'] = Variable<String>(agentName);
    }
    map['was_successful'] = Variable<bool>(wasSuccessful);
    map['requires_follow_up'] = Variable<bool>(requiresFollowUp);
    if (!nullToAbsent || nextCallScheduled != null) {
      map['next_call_scheduled'] = Variable<DateTime>(nextCallScheduled);
    }
    return map;
  }

  CallLogsCompanion toCompanion(bool nullToAbsent) {
    return CallLogsCompanion(
      id: Value(id),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      loanId: loanId == null && nullToAbsent
          ? const Value.absent()
          : Value(loanId),
      borrowerName: Value(borrowerName),
      borrowerPhone: Value(borrowerPhone),
      coMakerName: coMakerName == null && nullToAbsent
          ? const Value.absent()
          : Value(coMakerName),
      coMakerPhone: coMakerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(coMakerPhone),
      callStartTime: Value(callStartTime),
      callEndTime: callEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(callEndTime),
      callDurationSeconds: callDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(callDurationSeconds),
      callStatus: Value(callStatus),
      callOutcome: callOutcome == null && nullToAbsent
          ? const Value.absent()
          : Value(callOutcome),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      bucket: bucket == null && nullToAbsent
          ? const Value.absent()
          : Value(bucket),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      agentName: agentName == null && nullToAbsent
          ? const Value.absent()
          : Value(agentName),
      wasSuccessful: Value(wasSuccessful),
      requiresFollowUp: Value(requiresFollowUp),
      nextCallScheduled: nextCallScheduled == null && nullToAbsent
          ? const Value.absent()
          : Value(nextCallScheduled),
    );
  }

  factory CallLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallLogEntry(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      loanId: serializer.fromJson<int?>(json['loanId']),
      borrowerName: serializer.fromJson<String>(json['borrowerName']),
      borrowerPhone: serializer.fromJson<String>(json['borrowerPhone']),
      coMakerName: serializer.fromJson<String?>(json['coMakerName']),
      coMakerPhone: serializer.fromJson<String?>(json['coMakerPhone']),
      callStartTime: serializer.fromJson<DateTime>(json['callStartTime']),
      callEndTime: serializer.fromJson<DateTime?>(json['callEndTime']),
      callDurationSeconds: serializer.fromJson<int?>(
        json['callDurationSeconds'],
      ),
      callStatus: serializer.fromJson<String>(json['callStatus']),
      callOutcome: serializer.fromJson<String?>(json['callOutcome']),
      notes: serializer.fromJson<String?>(json['notes']),
      bucket: serializer.fromJson<String?>(json['bucket']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      userId: serializer.fromJson<int?>(json['userId']),
      agentName: serializer.fromJson<String?>(json['agentName']),
      wasSuccessful: serializer.fromJson<bool>(json['wasSuccessful']),
      requiresFollowUp: serializer.fromJson<bool>(json['requiresFollowUp']),
      nextCallScheduled: serializer.fromJson<DateTime?>(
        json['nextCallScheduled'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int?>(contactId),
      'loanId': serializer.toJson<int?>(loanId),
      'borrowerName': serializer.toJson<String>(borrowerName),
      'borrowerPhone': serializer.toJson<String>(borrowerPhone),
      'coMakerName': serializer.toJson<String?>(coMakerName),
      'coMakerPhone': serializer.toJson<String?>(coMakerPhone),
      'callStartTime': serializer.toJson<DateTime>(callStartTime),
      'callEndTime': serializer.toJson<DateTime?>(callEndTime),
      'callDurationSeconds': serializer.toJson<int?>(callDurationSeconds),
      'callStatus': serializer.toJson<String>(callStatus),
      'callOutcome': serializer.toJson<String?>(callOutcome),
      'notes': serializer.toJson<String?>(notes),
      'bucket': serializer.toJson<String?>(bucket),
      'sessionId': serializer.toJson<int?>(sessionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'userId': serializer.toJson<int?>(userId),
      'agentName': serializer.toJson<String?>(agentName),
      'wasSuccessful': serializer.toJson<bool>(wasSuccessful),
      'requiresFollowUp': serializer.toJson<bool>(requiresFollowUp),
      'nextCallScheduled': serializer.toJson<DateTime?>(nextCallScheduled),
    };
  }

  CallLogEntry copyWith({
    int? id,
    Value<int?> contactId = const Value.absent(),
    Value<int?> loanId = const Value.absent(),
    String? borrowerName,
    String? borrowerPhone,
    Value<String?> coMakerName = const Value.absent(),
    Value<String?> coMakerPhone = const Value.absent(),
    DateTime? callStartTime,
    Value<DateTime?> callEndTime = const Value.absent(),
    Value<int?> callDurationSeconds = const Value.absent(),
    String? callStatus,
    Value<String?> callOutcome = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> bucket = const Value.absent(),
    Value<int?> sessionId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<int?> userId = const Value.absent(),
    Value<String?> agentName = const Value.absent(),
    bool? wasSuccessful,
    bool? requiresFollowUp,
    Value<DateTime?> nextCallScheduled = const Value.absent(),
  }) => CallLogEntry(
    id: id ?? this.id,
    contactId: contactId.present ? contactId.value : this.contactId,
    loanId: loanId.present ? loanId.value : this.loanId,
    borrowerName: borrowerName ?? this.borrowerName,
    borrowerPhone: borrowerPhone ?? this.borrowerPhone,
    coMakerName: coMakerName.present ? coMakerName.value : this.coMakerName,
    coMakerPhone: coMakerPhone.present ? coMakerPhone.value : this.coMakerPhone,
    callStartTime: callStartTime ?? this.callStartTime,
    callEndTime: callEndTime.present ? callEndTime.value : this.callEndTime,
    callDurationSeconds: callDurationSeconds.present
        ? callDurationSeconds.value
        : this.callDurationSeconds,
    callStatus: callStatus ?? this.callStatus,
    callOutcome: callOutcome.present ? callOutcome.value : this.callOutcome,
    notes: notes.present ? notes.value : this.notes,
    bucket: bucket.present ? bucket.value : this.bucket,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    userId: userId.present ? userId.value : this.userId,
    agentName: agentName.present ? agentName.value : this.agentName,
    wasSuccessful: wasSuccessful ?? this.wasSuccessful,
    requiresFollowUp: requiresFollowUp ?? this.requiresFollowUp,
    nextCallScheduled: nextCallScheduled.present
        ? nextCallScheduled.value
        : this.nextCallScheduled,
  );
  CallLogEntry copyWithCompanion(CallLogsCompanion data) {
    return CallLogEntry(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      borrowerName: data.borrowerName.present
          ? data.borrowerName.value
          : this.borrowerName,
      borrowerPhone: data.borrowerPhone.present
          ? data.borrowerPhone.value
          : this.borrowerPhone,
      coMakerName: data.coMakerName.present
          ? data.coMakerName.value
          : this.coMakerName,
      coMakerPhone: data.coMakerPhone.present
          ? data.coMakerPhone.value
          : this.coMakerPhone,
      callStartTime: data.callStartTime.present
          ? data.callStartTime.value
          : this.callStartTime,
      callEndTime: data.callEndTime.present
          ? data.callEndTime.value
          : this.callEndTime,
      callDurationSeconds: data.callDurationSeconds.present
          ? data.callDurationSeconds.value
          : this.callDurationSeconds,
      callStatus: data.callStatus.present
          ? data.callStatus.value
          : this.callStatus,
      callOutcome: data.callOutcome.present
          ? data.callOutcome.value
          : this.callOutcome,
      notes: data.notes.present ? data.notes.value : this.notes,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      agentName: data.agentName.present ? data.agentName.value : this.agentName,
      wasSuccessful: data.wasSuccessful.present
          ? data.wasSuccessful.value
          : this.wasSuccessful,
      requiresFollowUp: data.requiresFollowUp.present
          ? data.requiresFollowUp.value
          : this.requiresFollowUp,
      nextCallScheduled: data.nextCallScheduled.present
          ? data.nextCallScheduled.value
          : this.nextCallScheduled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallLogEntry(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('loanId: $loanId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('borrowerPhone: $borrowerPhone, ')
          ..write('coMakerName: $coMakerName, ')
          ..write('coMakerPhone: $coMakerPhone, ')
          ..write('callStartTime: $callStartTime, ')
          ..write('callEndTime: $callEndTime, ')
          ..write('callDurationSeconds: $callDurationSeconds, ')
          ..write('callStatus: $callStatus, ')
          ..write('callOutcome: $callOutcome, ')
          ..write('notes: $notes, ')
          ..write('bucket: $bucket, ')
          ..write('sessionId: $sessionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('userId: $userId, ')
          ..write('agentName: $agentName, ')
          ..write('wasSuccessful: $wasSuccessful, ')
          ..write('requiresFollowUp: $requiresFollowUp, ')
          ..write('nextCallScheduled: $nextCallScheduled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    contactId,
    loanId,
    borrowerName,
    borrowerPhone,
    coMakerName,
    coMakerPhone,
    callStartTime,
    callEndTime,
    callDurationSeconds,
    callStatus,
    callOutcome,
    notes,
    bucket,
    sessionId,
    createdAt,
    updatedAt,
    userId,
    agentName,
    wasSuccessful,
    requiresFollowUp,
    nextCallScheduled,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallLogEntry &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.loanId == this.loanId &&
          other.borrowerName == this.borrowerName &&
          other.borrowerPhone == this.borrowerPhone &&
          other.coMakerName == this.coMakerName &&
          other.coMakerPhone == this.coMakerPhone &&
          other.callStartTime == this.callStartTime &&
          other.callEndTime == this.callEndTime &&
          other.callDurationSeconds == this.callDurationSeconds &&
          other.callStatus == this.callStatus &&
          other.callOutcome == this.callOutcome &&
          other.notes == this.notes &&
          other.bucket == this.bucket &&
          other.sessionId == this.sessionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.userId == this.userId &&
          other.agentName == this.agentName &&
          other.wasSuccessful == this.wasSuccessful &&
          other.requiresFollowUp == this.requiresFollowUp &&
          other.nextCallScheduled == this.nextCallScheduled);
}

class CallLogsCompanion extends UpdateCompanion<CallLogEntry> {
  final Value<int> id;
  final Value<int?> contactId;
  final Value<int?> loanId;
  final Value<String> borrowerName;
  final Value<String> borrowerPhone;
  final Value<String?> coMakerName;
  final Value<String?> coMakerPhone;
  final Value<DateTime> callStartTime;
  final Value<DateTime?> callEndTime;
  final Value<int?> callDurationSeconds;
  final Value<String> callStatus;
  final Value<String?> callOutcome;
  final Value<String?> notes;
  final Value<String?> bucket;
  final Value<int?> sessionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> userId;
  final Value<String?> agentName;
  final Value<bool> wasSuccessful;
  final Value<bool> requiresFollowUp;
  final Value<DateTime?> nextCallScheduled;
  const CallLogsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.loanId = const Value.absent(),
    this.borrowerName = const Value.absent(),
    this.borrowerPhone = const Value.absent(),
    this.coMakerName = const Value.absent(),
    this.coMakerPhone = const Value.absent(),
    this.callStartTime = const Value.absent(),
    this.callEndTime = const Value.absent(),
    this.callDurationSeconds = const Value.absent(),
    this.callStatus = const Value.absent(),
    this.callOutcome = const Value.absent(),
    this.notes = const Value.absent(),
    this.bucket = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.agentName = const Value.absent(),
    this.wasSuccessful = const Value.absent(),
    this.requiresFollowUp = const Value.absent(),
    this.nextCallScheduled = const Value.absent(),
  });
  CallLogsCompanion.insert({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.loanId = const Value.absent(),
    required String borrowerName,
    required String borrowerPhone,
    this.coMakerName = const Value.absent(),
    this.coMakerPhone = const Value.absent(),
    required DateTime callStartTime,
    this.callEndTime = const Value.absent(),
    this.callDurationSeconds = const Value.absent(),
    required String callStatus,
    this.callOutcome = const Value.absent(),
    this.notes = const Value.absent(),
    this.bucket = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.agentName = const Value.absent(),
    this.wasSuccessful = const Value.absent(),
    this.requiresFollowUp = const Value.absent(),
    this.nextCallScheduled = const Value.absent(),
  }) : borrowerName = Value(borrowerName),
       borrowerPhone = Value(borrowerPhone),
       callStartTime = Value(callStartTime),
       callStatus = Value(callStatus);
  static Insertable<CallLogEntry> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<int>? loanId,
    Expression<String>? borrowerName,
    Expression<String>? borrowerPhone,
    Expression<String>? coMakerName,
    Expression<String>? coMakerPhone,
    Expression<DateTime>? callStartTime,
    Expression<DateTime>? callEndTime,
    Expression<int>? callDurationSeconds,
    Expression<String>? callStatus,
    Expression<String>? callOutcome,
    Expression<String>? notes,
    Expression<String>? bucket,
    Expression<int>? sessionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? userId,
    Expression<String>? agentName,
    Expression<bool>? wasSuccessful,
    Expression<bool>? requiresFollowUp,
    Expression<DateTime>? nextCallScheduled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (loanId != null) 'loan_id': loanId,
      if (borrowerName != null) 'borrower_name': borrowerName,
      if (borrowerPhone != null) 'borrower_phone': borrowerPhone,
      if (coMakerName != null) 'co_maker_name': coMakerName,
      if (coMakerPhone != null) 'co_maker_phone': coMakerPhone,
      if (callStartTime != null) 'call_start_time': callStartTime,
      if (callEndTime != null) 'call_end_time': callEndTime,
      if (callDurationSeconds != null)
        'call_duration_seconds': callDurationSeconds,
      if (callStatus != null) 'call_status': callStatus,
      if (callOutcome != null) 'call_outcome': callOutcome,
      if (notes != null) 'notes': notes,
      if (bucket != null) 'bucket': bucket,
      if (sessionId != null) 'session_id': sessionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (userId != null) 'user_id': userId,
      if (agentName != null) 'agent_name': agentName,
      if (wasSuccessful != null) 'was_successful': wasSuccessful,
      if (requiresFollowUp != null) 'requires_follow_up': requiresFollowUp,
      if (nextCallScheduled != null) 'next_call_scheduled': nextCallScheduled,
    });
  }

  CallLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? contactId,
    Value<int?>? loanId,
    Value<String>? borrowerName,
    Value<String>? borrowerPhone,
    Value<String?>? coMakerName,
    Value<String?>? coMakerPhone,
    Value<DateTime>? callStartTime,
    Value<DateTime?>? callEndTime,
    Value<int?>? callDurationSeconds,
    Value<String>? callStatus,
    Value<String?>? callOutcome,
    Value<String?>? notes,
    Value<String?>? bucket,
    Value<int?>? sessionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int?>? userId,
    Value<String?>? agentName,
    Value<bool>? wasSuccessful,
    Value<bool>? requiresFollowUp,
    Value<DateTime?>? nextCallScheduled,
  }) {
    return CallLogsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      loanId: loanId ?? this.loanId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerPhone: borrowerPhone ?? this.borrowerPhone,
      coMakerName: coMakerName ?? this.coMakerName,
      coMakerPhone: coMakerPhone ?? this.coMakerPhone,
      callStartTime: callStartTime ?? this.callStartTime,
      callEndTime: callEndTime ?? this.callEndTime,
      callDurationSeconds: callDurationSeconds ?? this.callDurationSeconds,
      callStatus: callStatus ?? this.callStatus,
      callOutcome: callOutcome ?? this.callOutcome,
      notes: notes ?? this.notes,
      bucket: bucket ?? this.bucket,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      agentName: agentName ?? this.agentName,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      requiresFollowUp: requiresFollowUp ?? this.requiresFollowUp,
      nextCallScheduled: nextCallScheduled ?? this.nextCallScheduled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<int>(loanId.value);
    }
    if (borrowerName.present) {
      map['borrower_name'] = Variable<String>(borrowerName.value);
    }
    if (borrowerPhone.present) {
      map['borrower_phone'] = Variable<String>(borrowerPhone.value);
    }
    if (coMakerName.present) {
      map['co_maker_name'] = Variable<String>(coMakerName.value);
    }
    if (coMakerPhone.present) {
      map['co_maker_phone'] = Variable<String>(coMakerPhone.value);
    }
    if (callStartTime.present) {
      map['call_start_time'] = Variable<DateTime>(callStartTime.value);
    }
    if (callEndTime.present) {
      map['call_end_time'] = Variable<DateTime>(callEndTime.value);
    }
    if (callDurationSeconds.present) {
      map['call_duration_seconds'] = Variable<int>(callDurationSeconds.value);
    }
    if (callStatus.present) {
      map['call_status'] = Variable<String>(callStatus.value);
    }
    if (callOutcome.present) {
      map['call_outcome'] = Variable<String>(callOutcome.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (agentName.present) {
      map['agent_name'] = Variable<String>(agentName.value);
    }
    if (wasSuccessful.present) {
      map['was_successful'] = Variable<bool>(wasSuccessful.value);
    }
    if (requiresFollowUp.present) {
      map['requires_follow_up'] = Variable<bool>(requiresFollowUp.value);
    }
    if (nextCallScheduled.present) {
      map['next_call_scheduled'] = Variable<DateTime>(nextCallScheduled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallLogsCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('loanId: $loanId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('borrowerPhone: $borrowerPhone, ')
          ..write('coMakerName: $coMakerName, ')
          ..write('coMakerPhone: $coMakerPhone, ')
          ..write('callStartTime: $callStartTime, ')
          ..write('callEndTime: $callEndTime, ')
          ..write('callDurationSeconds: $callDurationSeconds, ')
          ..write('callStatus: $callStatus, ')
          ..write('callOutcome: $callOutcome, ')
          ..write('notes: $notes, ')
          ..write('bucket: $bucket, ')
          ..write('sessionId: $sessionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('userId: $userId, ')
          ..write('agentName: $agentName, ')
          ..write('wasSuccessful: $wasSuccessful, ')
          ..write('requiresFollowUp: $requiresFollowUp, ')
          ..write('nextCallScheduled: $nextCallScheduled')
          ..write(')'))
        .toString();
  }
}

class $CallContactsTable extends CallContacts
    with TableInfo<$CallContactsTable, CallContactEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<int> loanId = GeneratedColumn<int>(
    'loan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _borrowerNameMeta = const VerificationMeta(
    'borrowerName',
  );
  @override
  late final GeneratedColumn<String> borrowerName = GeneratedColumn<String>(
    'borrower_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _borrowerPhoneMeta = const VerificationMeta(
    'borrowerPhone',
  );
  @override
  late final GeneratedColumn<String> borrowerPhone = GeneratedColumn<String>(
    'borrower_phone',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coMakerNameMeta = const VerificationMeta(
    'coMakerName',
  );
  @override
  late final GeneratedColumn<String> coMakerName = GeneratedColumn<String>(
    'co_maker_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coMakerPhoneMeta = const VerificationMeta(
    'coMakerPhone',
  );
  @override
  late final GeneratedColumn<String> coMakerPhone = GeneratedColumn<String>(
    'co_maker_phone',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCallDateMeta = const VerificationMeta(
    'lastCallDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastCallDate = GeneratedColumn<DateTime>(
    'last_call_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCallStatusMeta = const VerificationMeta(
    'lastCallStatus',
  );
  @override
  late final GeneratedColumn<String> lastCallStatus = GeneratedColumn<String>(
    'last_call_status',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _callAttemptsMeta = const VerificationMeta(
    'callAttempts',
  );
  @override
  late final GeneratedColumn<int> callAttempts = GeneratedColumn<int>(
    'call_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _assignedUserIdMeta = const VerificationMeta(
    'assignedUserId',
  );
  @override
  late final GeneratedColumn<int> assignedUserId = GeneratedColumn<int>(
    'assigned_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedAtMeta = const VerificationMeta(
    'assignedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assignedAt = GeneratedColumn<DateTime>(
    'assigned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 1000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _doNotCallMeta = const VerificationMeta(
    'doNotCall',
  );
  @override
  late final GeneratedColumn<bool> doNotCall = GeneratedColumn<bool>(
    'do_not_call',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("do_not_call" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    loanId,
    borrowerName,
    borrowerPhone,
    coMakerName,
    coMakerPhone,
    status,
    bucket,
    priority,
    lastCallDate,
    lastCallStatus,
    callAttempts,
    createdAt,
    updatedAt,
    assignedUserId,
    assignedAt,
    notes,
    isActive,
    doNotCall,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallContactEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('loan_id')) {
      context.handle(
        _loanIdMeta,
        loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta),
      );
    }
    if (data.containsKey('borrower_name')) {
      context.handle(
        _borrowerNameMeta,
        borrowerName.isAcceptableOrUnknown(
          data['borrower_name']!,
          _borrowerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_borrowerNameMeta);
    }
    if (data.containsKey('borrower_phone')) {
      context.handle(
        _borrowerPhoneMeta,
        borrowerPhone.isAcceptableOrUnknown(
          data['borrower_phone']!,
          _borrowerPhoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_borrowerPhoneMeta);
    }
    if (data.containsKey('co_maker_name')) {
      context.handle(
        _coMakerNameMeta,
        coMakerName.isAcceptableOrUnknown(
          data['co_maker_name']!,
          _coMakerNameMeta,
        ),
      );
    }
    if (data.containsKey('co_maker_phone')) {
      context.handle(
        _coMakerPhoneMeta,
        coMakerPhone.isAcceptableOrUnknown(
          data['co_maker_phone']!,
          _coMakerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('last_call_date')) {
      context.handle(
        _lastCallDateMeta,
        lastCallDate.isAcceptableOrUnknown(
          data['last_call_date']!,
          _lastCallDateMeta,
        ),
      );
    }
    if (data.containsKey('last_call_status')) {
      context.handle(
        _lastCallStatusMeta,
        lastCallStatus.isAcceptableOrUnknown(
          data['last_call_status']!,
          _lastCallStatusMeta,
        ),
      );
    }
    if (data.containsKey('call_attempts')) {
      context.handle(
        _callAttemptsMeta,
        callAttempts.isAcceptableOrUnknown(
          data['call_attempts']!,
          _callAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('assigned_user_id')) {
      context.handle(
        _assignedUserIdMeta,
        assignedUserId.isAcceptableOrUnknown(
          data['assigned_user_id']!,
          _assignedUserIdMeta,
        ),
      );
    }
    if (data.containsKey('assigned_at')) {
      context.handle(
        _assignedAtMeta,
        assignedAt.isAcceptableOrUnknown(data['assigned_at']!, _assignedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('do_not_call')) {
      context.handle(
        _doNotCallMeta,
        doNotCall.isAcceptableOrUnknown(data['do_not_call']!, _doNotCallMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallContactEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallContactEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      loanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loan_id'],
      ),
      borrowerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}borrower_name'],
      )!,
      borrowerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}borrower_phone'],
      )!,
      coMakerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co_maker_name'],
      ),
      coMakerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co_maker_phone'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      lastCallDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_call_date'],
      ),
      lastCallStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_call_status'],
      ),
      callAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      assignedUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}assigned_user_id'],
      ),
      assignedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assigned_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      doNotCall: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}do_not_call'],
      )!,
    );
  }

  @override
  $CallContactsTable createAlias(String alias) {
    return $CallContactsTable(attachedDatabase, alias);
  }
}

class CallContactEntry extends DataClass
    implements Insertable<CallContactEntry> {
  final int id;
  final int? loanId;
  final String borrowerName;
  final String borrowerPhone;
  final String? coMakerName;
  final String? coMakerPhone;
  final String status;
  final String? bucket;
  final int priority;
  final DateTime? lastCallDate;
  final String? lastCallStatus;
  final int callAttempts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? assignedUserId;
  final DateTime? assignedAt;
  final String? notes;
  final bool isActive;
  final bool doNotCall;
  const CallContactEntry({
    required this.id,
    this.loanId,
    required this.borrowerName,
    required this.borrowerPhone,
    this.coMakerName,
    this.coMakerPhone,
    required this.status,
    this.bucket,
    required this.priority,
    this.lastCallDate,
    this.lastCallStatus,
    required this.callAttempts,
    required this.createdAt,
    required this.updatedAt,
    this.assignedUserId,
    this.assignedAt,
    this.notes,
    required this.isActive,
    required this.doNotCall,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || loanId != null) {
      map['loan_id'] = Variable<int>(loanId);
    }
    map['borrower_name'] = Variable<String>(borrowerName);
    map['borrower_phone'] = Variable<String>(borrowerPhone);
    if (!nullToAbsent || coMakerName != null) {
      map['co_maker_name'] = Variable<String>(coMakerName);
    }
    if (!nullToAbsent || coMakerPhone != null) {
      map['co_maker_phone'] = Variable<String>(coMakerPhone);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || bucket != null) {
      map['bucket'] = Variable<String>(bucket);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || lastCallDate != null) {
      map['last_call_date'] = Variable<DateTime>(lastCallDate);
    }
    if (!nullToAbsent || lastCallStatus != null) {
      map['last_call_status'] = Variable<String>(lastCallStatus);
    }
    map['call_attempts'] = Variable<int>(callAttempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || assignedUserId != null) {
      map['assigned_user_id'] = Variable<int>(assignedUserId);
    }
    if (!nullToAbsent || assignedAt != null) {
      map['assigned_at'] = Variable<DateTime>(assignedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['do_not_call'] = Variable<bool>(doNotCall);
    return map;
  }

  CallContactsCompanion toCompanion(bool nullToAbsent) {
    return CallContactsCompanion(
      id: Value(id),
      loanId: loanId == null && nullToAbsent
          ? const Value.absent()
          : Value(loanId),
      borrowerName: Value(borrowerName),
      borrowerPhone: Value(borrowerPhone),
      coMakerName: coMakerName == null && nullToAbsent
          ? const Value.absent()
          : Value(coMakerName),
      coMakerPhone: coMakerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(coMakerPhone),
      status: Value(status),
      bucket: bucket == null && nullToAbsent
          ? const Value.absent()
          : Value(bucket),
      priority: Value(priority),
      lastCallDate: lastCallDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCallDate),
      lastCallStatus: lastCallStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCallStatus),
      callAttempts: Value(callAttempts),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      assignedUserId: assignedUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedUserId),
      assignedAt: assignedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      doNotCall: Value(doNotCall),
    );
  }

  factory CallContactEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallContactEntry(
      id: serializer.fromJson<int>(json['id']),
      loanId: serializer.fromJson<int?>(json['loanId']),
      borrowerName: serializer.fromJson<String>(json['borrowerName']),
      borrowerPhone: serializer.fromJson<String>(json['borrowerPhone']),
      coMakerName: serializer.fromJson<String?>(json['coMakerName']),
      coMakerPhone: serializer.fromJson<String?>(json['coMakerPhone']),
      status: serializer.fromJson<String>(json['status']),
      bucket: serializer.fromJson<String?>(json['bucket']),
      priority: serializer.fromJson<int>(json['priority']),
      lastCallDate: serializer.fromJson<DateTime?>(json['lastCallDate']),
      lastCallStatus: serializer.fromJson<String?>(json['lastCallStatus']),
      callAttempts: serializer.fromJson<int>(json['callAttempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      assignedUserId: serializer.fromJson<int?>(json['assignedUserId']),
      assignedAt: serializer.fromJson<DateTime?>(json['assignedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      doNotCall: serializer.fromJson<bool>(json['doNotCall']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'loanId': serializer.toJson<int?>(loanId),
      'borrowerName': serializer.toJson<String>(borrowerName),
      'borrowerPhone': serializer.toJson<String>(borrowerPhone),
      'coMakerName': serializer.toJson<String?>(coMakerName),
      'coMakerPhone': serializer.toJson<String?>(coMakerPhone),
      'status': serializer.toJson<String>(status),
      'bucket': serializer.toJson<String?>(bucket),
      'priority': serializer.toJson<int>(priority),
      'lastCallDate': serializer.toJson<DateTime?>(lastCallDate),
      'lastCallStatus': serializer.toJson<String?>(lastCallStatus),
      'callAttempts': serializer.toJson<int>(callAttempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'assignedUserId': serializer.toJson<int?>(assignedUserId),
      'assignedAt': serializer.toJson<DateTime?>(assignedAt),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'doNotCall': serializer.toJson<bool>(doNotCall),
    };
  }

  CallContactEntry copyWith({
    int? id,
    Value<int?> loanId = const Value.absent(),
    String? borrowerName,
    String? borrowerPhone,
    Value<String?> coMakerName = const Value.absent(),
    Value<String?> coMakerPhone = const Value.absent(),
    String? status,
    Value<String?> bucket = const Value.absent(),
    int? priority,
    Value<DateTime?> lastCallDate = const Value.absent(),
    Value<String?> lastCallStatus = const Value.absent(),
    int? callAttempts,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<int?> assignedUserId = const Value.absent(),
    Value<DateTime?> assignedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    bool? doNotCall,
  }) => CallContactEntry(
    id: id ?? this.id,
    loanId: loanId.present ? loanId.value : this.loanId,
    borrowerName: borrowerName ?? this.borrowerName,
    borrowerPhone: borrowerPhone ?? this.borrowerPhone,
    coMakerName: coMakerName.present ? coMakerName.value : this.coMakerName,
    coMakerPhone: coMakerPhone.present ? coMakerPhone.value : this.coMakerPhone,
    status: status ?? this.status,
    bucket: bucket.present ? bucket.value : this.bucket,
    priority: priority ?? this.priority,
    lastCallDate: lastCallDate.present ? lastCallDate.value : this.lastCallDate,
    lastCallStatus: lastCallStatus.present
        ? lastCallStatus.value
        : this.lastCallStatus,
    callAttempts: callAttempts ?? this.callAttempts,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    assignedUserId: assignedUserId.present
        ? assignedUserId.value
        : this.assignedUserId,
    assignedAt: assignedAt.present ? assignedAt.value : this.assignedAt,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    doNotCall: doNotCall ?? this.doNotCall,
  );
  CallContactEntry copyWithCompanion(CallContactsCompanion data) {
    return CallContactEntry(
      id: data.id.present ? data.id.value : this.id,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      borrowerName: data.borrowerName.present
          ? data.borrowerName.value
          : this.borrowerName,
      borrowerPhone: data.borrowerPhone.present
          ? data.borrowerPhone.value
          : this.borrowerPhone,
      coMakerName: data.coMakerName.present
          ? data.coMakerName.value
          : this.coMakerName,
      coMakerPhone: data.coMakerPhone.present
          ? data.coMakerPhone.value
          : this.coMakerPhone,
      status: data.status.present ? data.status.value : this.status,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      priority: data.priority.present ? data.priority.value : this.priority,
      lastCallDate: data.lastCallDate.present
          ? data.lastCallDate.value
          : this.lastCallDate,
      lastCallStatus: data.lastCallStatus.present
          ? data.lastCallStatus.value
          : this.lastCallStatus,
      callAttempts: data.callAttempts.present
          ? data.callAttempts.value
          : this.callAttempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      assignedUserId: data.assignedUserId.present
          ? data.assignedUserId.value
          : this.assignedUserId,
      assignedAt: data.assignedAt.present
          ? data.assignedAt.value
          : this.assignedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      doNotCall: data.doNotCall.present ? data.doNotCall.value : this.doNotCall,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallContactEntry(')
          ..write('id: $id, ')
          ..write('loanId: $loanId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('borrowerPhone: $borrowerPhone, ')
          ..write('coMakerName: $coMakerName, ')
          ..write('coMakerPhone: $coMakerPhone, ')
          ..write('status: $status, ')
          ..write('bucket: $bucket, ')
          ..write('priority: $priority, ')
          ..write('lastCallDate: $lastCallDate, ')
          ..write('lastCallStatus: $lastCallStatus, ')
          ..write('callAttempts: $callAttempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('assignedUserId: $assignedUserId, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('doNotCall: $doNotCall')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    loanId,
    borrowerName,
    borrowerPhone,
    coMakerName,
    coMakerPhone,
    status,
    bucket,
    priority,
    lastCallDate,
    lastCallStatus,
    callAttempts,
    createdAt,
    updatedAt,
    assignedUserId,
    assignedAt,
    notes,
    isActive,
    doNotCall,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallContactEntry &&
          other.id == this.id &&
          other.loanId == this.loanId &&
          other.borrowerName == this.borrowerName &&
          other.borrowerPhone == this.borrowerPhone &&
          other.coMakerName == this.coMakerName &&
          other.coMakerPhone == this.coMakerPhone &&
          other.status == this.status &&
          other.bucket == this.bucket &&
          other.priority == this.priority &&
          other.lastCallDate == this.lastCallDate &&
          other.lastCallStatus == this.lastCallStatus &&
          other.callAttempts == this.callAttempts &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.assignedUserId == this.assignedUserId &&
          other.assignedAt == this.assignedAt &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.doNotCall == this.doNotCall);
}

class CallContactsCompanion extends UpdateCompanion<CallContactEntry> {
  final Value<int> id;
  final Value<int?> loanId;
  final Value<String> borrowerName;
  final Value<String> borrowerPhone;
  final Value<String?> coMakerName;
  final Value<String?> coMakerPhone;
  final Value<String> status;
  final Value<String?> bucket;
  final Value<int> priority;
  final Value<DateTime?> lastCallDate;
  final Value<String?> lastCallStatus;
  final Value<int> callAttempts;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> assignedUserId;
  final Value<DateTime?> assignedAt;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<bool> doNotCall;
  const CallContactsCompanion({
    this.id = const Value.absent(),
    this.loanId = const Value.absent(),
    this.borrowerName = const Value.absent(),
    this.borrowerPhone = const Value.absent(),
    this.coMakerName = const Value.absent(),
    this.coMakerPhone = const Value.absent(),
    this.status = const Value.absent(),
    this.bucket = const Value.absent(),
    this.priority = const Value.absent(),
    this.lastCallDate = const Value.absent(),
    this.lastCallStatus = const Value.absent(),
    this.callAttempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.assignedUserId = const Value.absent(),
    this.assignedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.doNotCall = const Value.absent(),
  });
  CallContactsCompanion.insert({
    this.id = const Value.absent(),
    this.loanId = const Value.absent(),
    required String borrowerName,
    required String borrowerPhone,
    this.coMakerName = const Value.absent(),
    this.coMakerPhone = const Value.absent(),
    this.status = const Value.absent(),
    this.bucket = const Value.absent(),
    this.priority = const Value.absent(),
    this.lastCallDate = const Value.absent(),
    this.lastCallStatus = const Value.absent(),
    this.callAttempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.assignedUserId = const Value.absent(),
    this.assignedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.doNotCall = const Value.absent(),
  }) : borrowerName = Value(borrowerName),
       borrowerPhone = Value(borrowerPhone);
  static Insertable<CallContactEntry> custom({
    Expression<int>? id,
    Expression<int>? loanId,
    Expression<String>? borrowerName,
    Expression<String>? borrowerPhone,
    Expression<String>? coMakerName,
    Expression<String>? coMakerPhone,
    Expression<String>? status,
    Expression<String>? bucket,
    Expression<int>? priority,
    Expression<DateTime>? lastCallDate,
    Expression<String>? lastCallStatus,
    Expression<int>? callAttempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? assignedUserId,
    Expression<DateTime>? assignedAt,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<bool>? doNotCall,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loanId != null) 'loan_id': loanId,
      if (borrowerName != null) 'borrower_name': borrowerName,
      if (borrowerPhone != null) 'borrower_phone': borrowerPhone,
      if (coMakerName != null) 'co_maker_name': coMakerName,
      if (coMakerPhone != null) 'co_maker_phone': coMakerPhone,
      if (status != null) 'status': status,
      if (bucket != null) 'bucket': bucket,
      if (priority != null) 'priority': priority,
      if (lastCallDate != null) 'last_call_date': lastCallDate,
      if (lastCallStatus != null) 'last_call_status': lastCallStatus,
      if (callAttempts != null) 'call_attempts': callAttempts,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (assignedUserId != null) 'assigned_user_id': assignedUserId,
      if (assignedAt != null) 'assigned_at': assignedAt,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (doNotCall != null) 'do_not_call': doNotCall,
    });
  }

  CallContactsCompanion copyWith({
    Value<int>? id,
    Value<int?>? loanId,
    Value<String>? borrowerName,
    Value<String>? borrowerPhone,
    Value<String?>? coMakerName,
    Value<String?>? coMakerPhone,
    Value<String>? status,
    Value<String?>? bucket,
    Value<int>? priority,
    Value<DateTime?>? lastCallDate,
    Value<String?>? lastCallStatus,
    Value<int>? callAttempts,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int?>? assignedUserId,
    Value<DateTime?>? assignedAt,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<bool>? doNotCall,
  }) {
    return CallContactsCompanion(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerPhone: borrowerPhone ?? this.borrowerPhone,
      coMakerName: coMakerName ?? this.coMakerName,
      coMakerPhone: coMakerPhone ?? this.coMakerPhone,
      status: status ?? this.status,
      bucket: bucket ?? this.bucket,
      priority: priority ?? this.priority,
      lastCallDate: lastCallDate ?? this.lastCallDate,
      lastCallStatus: lastCallStatus ?? this.lastCallStatus,
      callAttempts: callAttempts ?? this.callAttempts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedAt: assignedAt ?? this.assignedAt,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      doNotCall: doNotCall ?? this.doNotCall,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<int>(loanId.value);
    }
    if (borrowerName.present) {
      map['borrower_name'] = Variable<String>(borrowerName.value);
    }
    if (borrowerPhone.present) {
      map['borrower_phone'] = Variable<String>(borrowerPhone.value);
    }
    if (coMakerName.present) {
      map['co_maker_name'] = Variable<String>(coMakerName.value);
    }
    if (coMakerPhone.present) {
      map['co_maker_phone'] = Variable<String>(coMakerPhone.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (lastCallDate.present) {
      map['last_call_date'] = Variable<DateTime>(lastCallDate.value);
    }
    if (lastCallStatus.present) {
      map['last_call_status'] = Variable<String>(lastCallStatus.value);
    }
    if (callAttempts.present) {
      map['call_attempts'] = Variable<int>(callAttempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (assignedUserId.present) {
      map['assigned_user_id'] = Variable<int>(assignedUserId.value);
    }
    if (assignedAt.present) {
      map['assigned_at'] = Variable<DateTime>(assignedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (doNotCall.present) {
      map['do_not_call'] = Variable<bool>(doNotCall.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallContactsCompanion(')
          ..write('id: $id, ')
          ..write('loanId: $loanId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('borrowerPhone: $borrowerPhone, ')
          ..write('coMakerName: $coMakerName, ')
          ..write('coMakerPhone: $coMakerPhone, ')
          ..write('status: $status, ')
          ..write('bucket: $bucket, ')
          ..write('priority: $priority, ')
          ..write('lastCallDate: $lastCallDate, ')
          ..write('lastCallStatus: $lastCallStatus, ')
          ..write('callAttempts: $callAttempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('assignedUserId: $assignedUserId, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('doNotCall: $doNotCall')
          ..write(')'))
        .toString();
  }
}

class $CallSessionsTable extends CallSessions
    with TableInfo<$CallSessionsTable, CallSessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionStartMeta = const VerificationMeta(
    'sessionStart',
  );
  @override
  late final GeneratedColumn<DateTime> sessionStart = GeneratedColumn<DateTime>(
    'session_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionEndMeta = const VerificationMeta(
    'sessionEnd',
  );
  @override
  late final GeneratedColumn<DateTime> sessionEnd = GeneratedColumn<DateTime>(
    'session_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionDurationMinutesMeta =
      const VerificationMeta('sessionDurationMinutes');
  @override
  late final GeneratedColumn<int> sessionDurationMinutes = GeneratedColumn<int>(
    'session_duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agentNameMeta = const VerificationMeta(
    'agentName',
  );
  @override
  late final GeneratedColumn<String> agentName = GeneratedColumn<String>(
    'agent_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalContactsMeta = const VerificationMeta(
    'totalContacts',
  );
  @override
  late final GeneratedColumn<int> totalContacts = GeneratedColumn<int>(
    'total_contacts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _contactsAttemptedMeta = const VerificationMeta(
    'contactsAttempted',
  );
  @override
  late final GeneratedColumn<int> contactsAttempted = GeneratedColumn<int>(
    'contacts_attempted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _contactsCompletedMeta = const VerificationMeta(
    'contactsCompleted',
  );
  @override
  late final GeneratedColumn<int> contactsCompleted = GeneratedColumn<int>(
    'contacts_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successfulCallsMeta = const VerificationMeta(
    'successfulCalls',
  );
  @override
  late final GeneratedColumn<int> successfulCalls = GeneratedColumn<int>(
    'successful_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failedCallsMeta = const VerificationMeta(
    'failedCalls',
  );
  @override
  late final GeneratedColumn<int> failedCalls = GeneratedColumn<int>(
    'failed_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noAnswerCallsMeta = const VerificationMeta(
    'noAnswerCalls',
  );
  @override
  late final GeneratedColumn<int> noAnswerCalls = GeneratedColumn<int>(
    'no_answer_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hangUpCallsMeta = const VerificationMeta(
    'hangUpCalls',
  );
  @override
  late final GeneratedColumn<int> hangUpCalls = GeneratedColumn<int>(
    'hang_up_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionTypeMeta = const VerificationMeta(
    'sessionType',
  );
  @override
  late final GeneratedColumn<String> sessionType = GeneratedColumn<String>(
    'session_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasCompletedMeta = const VerificationMeta(
    'wasCompleted',
  );
  @override
  late final GeneratedColumn<bool> wasCompleted = GeneratedColumn<bool>(
    'was_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _successRateMeta = const VerificationMeta(
    'successRate',
  );
  @override
  late final GeneratedColumn<double> successRate = GeneratedColumn<double>(
    'success_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageCallDurationSecondsMeta =
      const VerificationMeta('averageCallDurationSeconds');
  @override
  late final GeneratedColumn<int> averageCallDurationSeconds =
      GeneratedColumn<int>(
        'average_call_duration_seconds',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sessionNotesMeta = const VerificationMeta(
    'sessionNotes',
  );
  @override
  late final GeneratedColumn<String> sessionNotes = GeneratedColumn<String>(
    'session_notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionStart,
    sessionEnd,
    sessionDurationMinutes,
    userId,
    agentName,
    bucket,
    totalContacts,
    contactsAttempted,
    contactsCompleted,
    successfulCalls,
    failedCalls,
    noAnswerCalls,
    hangUpCalls,
    sessionType,
    wasCompleted,
    createdAt,
    updatedAt,
    successRate,
    averageCallDurationSeconds,
    sessionNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallSessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_start')) {
      context.handle(
        _sessionStartMeta,
        sessionStart.isAcceptableOrUnknown(
          data['session_start']!,
          _sessionStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionStartMeta);
    }
    if (data.containsKey('session_end')) {
      context.handle(
        _sessionEndMeta,
        sessionEnd.isAcceptableOrUnknown(data['session_end']!, _sessionEndMeta),
      );
    }
    if (data.containsKey('session_duration_minutes')) {
      context.handle(
        _sessionDurationMinutesMeta,
        sessionDurationMinutes.isAcceptableOrUnknown(
          data['session_duration_minutes']!,
          _sessionDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('agent_name')) {
      context.handle(
        _agentNameMeta,
        agentName.isAcceptableOrUnknown(data['agent_name']!, _agentNameMeta),
      );
    }
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    }
    if (data.containsKey('total_contacts')) {
      context.handle(
        _totalContactsMeta,
        totalContacts.isAcceptableOrUnknown(
          data['total_contacts']!,
          _totalContactsMeta,
        ),
      );
    }
    if (data.containsKey('contacts_attempted')) {
      context.handle(
        _contactsAttemptedMeta,
        contactsAttempted.isAcceptableOrUnknown(
          data['contacts_attempted']!,
          _contactsAttemptedMeta,
        ),
      );
    }
    if (data.containsKey('contacts_completed')) {
      context.handle(
        _contactsCompletedMeta,
        contactsCompleted.isAcceptableOrUnknown(
          data['contacts_completed']!,
          _contactsCompletedMeta,
        ),
      );
    }
    if (data.containsKey('successful_calls')) {
      context.handle(
        _successfulCallsMeta,
        successfulCalls.isAcceptableOrUnknown(
          data['successful_calls']!,
          _successfulCallsMeta,
        ),
      );
    }
    if (data.containsKey('failed_calls')) {
      context.handle(
        _failedCallsMeta,
        failedCalls.isAcceptableOrUnknown(
          data['failed_calls']!,
          _failedCallsMeta,
        ),
      );
    }
    if (data.containsKey('no_answer_calls')) {
      context.handle(
        _noAnswerCallsMeta,
        noAnswerCalls.isAcceptableOrUnknown(
          data['no_answer_calls']!,
          _noAnswerCallsMeta,
        ),
      );
    }
    if (data.containsKey('hang_up_calls')) {
      context.handle(
        _hangUpCallsMeta,
        hangUpCalls.isAcceptableOrUnknown(
          data['hang_up_calls']!,
          _hangUpCallsMeta,
        ),
      );
    }
    if (data.containsKey('session_type')) {
      context.handle(
        _sessionTypeMeta,
        sessionType.isAcceptableOrUnknown(
          data['session_type']!,
          _sessionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('was_completed')) {
      context.handle(
        _wasCompletedMeta,
        wasCompleted.isAcceptableOrUnknown(
          data['was_completed']!,
          _wasCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('success_rate')) {
      context.handle(
        _successRateMeta,
        successRate.isAcceptableOrUnknown(
          data['success_rate']!,
          _successRateMeta,
        ),
      );
    }
    if (data.containsKey('average_call_duration_seconds')) {
      context.handle(
        _averageCallDurationSecondsMeta,
        averageCallDurationSeconds.isAcceptableOrUnknown(
          data['average_call_duration_seconds']!,
          _averageCallDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('session_notes')) {
      context.handle(
        _sessionNotesMeta,
        sessionNotes.isAcceptableOrUnknown(
          data['session_notes']!,
          _sessionNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallSessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallSessionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}session_start'],
      )!,
      sessionEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}session_end'],
      ),
      sessionDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_duration_minutes'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      agentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_name'],
      ),
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      ),
      totalContacts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_contacts'],
      )!,
      contactsAttempted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contacts_attempted'],
      )!,
      contactsCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contacts_completed'],
      )!,
      successfulCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}successful_calls'],
      )!,
      failedCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_calls'],
      )!,
      noAnswerCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}no_answer_calls'],
      )!,
      hangUpCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hang_up_calls'],
      )!,
      sessionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_type'],
      )!,
      wasCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      successRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}success_rate'],
      ),
      averageCallDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}average_call_duration_seconds'],
      ),
      sessionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_notes'],
      ),
    );
  }

  @override
  $CallSessionsTable createAlias(String alias) {
    return $CallSessionsTable(attachedDatabase, alias);
  }
}

class CallSessionEntry extends DataClass
    implements Insertable<CallSessionEntry> {
  final int id;
  final DateTime sessionStart;
  final DateTime? sessionEnd;
  final int? sessionDurationMinutes;
  final int userId;
  final String? agentName;
  final String? bucket;
  final int totalContacts;
  final int contactsAttempted;
  final int contactsCompleted;
  final int successfulCalls;
  final int failedCalls;
  final int noAnswerCalls;
  final int hangUpCalls;
  final String sessionType;
  final bool wasCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? successRate;
  final int? averageCallDurationSeconds;
  final String? sessionNotes;
  const CallSessionEntry({
    required this.id,
    required this.sessionStart,
    this.sessionEnd,
    this.sessionDurationMinutes,
    required this.userId,
    this.agentName,
    this.bucket,
    required this.totalContacts,
    required this.contactsAttempted,
    required this.contactsCompleted,
    required this.successfulCalls,
    required this.failedCalls,
    required this.noAnswerCalls,
    required this.hangUpCalls,
    required this.sessionType,
    required this.wasCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.successRate,
    this.averageCallDurationSeconds,
    this.sessionNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_start'] = Variable<DateTime>(sessionStart);
    if (!nullToAbsent || sessionEnd != null) {
      map['session_end'] = Variable<DateTime>(sessionEnd);
    }
    if (!nullToAbsent || sessionDurationMinutes != null) {
      map['session_duration_minutes'] = Variable<int>(sessionDurationMinutes);
    }
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || agentName != null) {
      map['agent_name'] = Variable<String>(agentName);
    }
    if (!nullToAbsent || bucket != null) {
      map['bucket'] = Variable<String>(bucket);
    }
    map['total_contacts'] = Variable<int>(totalContacts);
    map['contacts_attempted'] = Variable<int>(contactsAttempted);
    map['contacts_completed'] = Variable<int>(contactsCompleted);
    map['successful_calls'] = Variable<int>(successfulCalls);
    map['failed_calls'] = Variable<int>(failedCalls);
    map['no_answer_calls'] = Variable<int>(noAnswerCalls);
    map['hang_up_calls'] = Variable<int>(hangUpCalls);
    map['session_type'] = Variable<String>(sessionType);
    map['was_completed'] = Variable<bool>(wasCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || successRate != null) {
      map['success_rate'] = Variable<double>(successRate);
    }
    if (!nullToAbsent || averageCallDurationSeconds != null) {
      map['average_call_duration_seconds'] = Variable<int>(
        averageCallDurationSeconds,
      );
    }
    if (!nullToAbsent || sessionNotes != null) {
      map['session_notes'] = Variable<String>(sessionNotes);
    }
    return map;
  }

  CallSessionsCompanion toCompanion(bool nullToAbsent) {
    return CallSessionsCompanion(
      id: Value(id),
      sessionStart: Value(sessionStart),
      sessionEnd: sessionEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionEnd),
      sessionDurationMinutes: sessionDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionDurationMinutes),
      userId: Value(userId),
      agentName: agentName == null && nullToAbsent
          ? const Value.absent()
          : Value(agentName),
      bucket: bucket == null && nullToAbsent
          ? const Value.absent()
          : Value(bucket),
      totalContacts: Value(totalContacts),
      contactsAttempted: Value(contactsAttempted),
      contactsCompleted: Value(contactsCompleted),
      successfulCalls: Value(successfulCalls),
      failedCalls: Value(failedCalls),
      noAnswerCalls: Value(noAnswerCalls),
      hangUpCalls: Value(hangUpCalls),
      sessionType: Value(sessionType),
      wasCompleted: Value(wasCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      successRate: successRate == null && nullToAbsent
          ? const Value.absent()
          : Value(successRate),
      averageCallDurationSeconds:
          averageCallDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(averageCallDurationSeconds),
      sessionNotes: sessionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionNotes),
    );
  }

  factory CallSessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallSessionEntry(
      id: serializer.fromJson<int>(json['id']),
      sessionStart: serializer.fromJson<DateTime>(json['sessionStart']),
      sessionEnd: serializer.fromJson<DateTime?>(json['sessionEnd']),
      sessionDurationMinutes: serializer.fromJson<int?>(
        json['sessionDurationMinutes'],
      ),
      userId: serializer.fromJson<int>(json['userId']),
      agentName: serializer.fromJson<String?>(json['agentName']),
      bucket: serializer.fromJson<String?>(json['bucket']),
      totalContacts: serializer.fromJson<int>(json['totalContacts']),
      contactsAttempted: serializer.fromJson<int>(json['contactsAttempted']),
      contactsCompleted: serializer.fromJson<int>(json['contactsCompleted']),
      successfulCalls: serializer.fromJson<int>(json['successfulCalls']),
      failedCalls: serializer.fromJson<int>(json['failedCalls']),
      noAnswerCalls: serializer.fromJson<int>(json['noAnswerCalls']),
      hangUpCalls: serializer.fromJson<int>(json['hangUpCalls']),
      sessionType: serializer.fromJson<String>(json['sessionType']),
      wasCompleted: serializer.fromJson<bool>(json['wasCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      successRate: serializer.fromJson<double?>(json['successRate']),
      averageCallDurationSeconds: serializer.fromJson<int?>(
        json['averageCallDurationSeconds'],
      ),
      sessionNotes: serializer.fromJson<String?>(json['sessionNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionStart': serializer.toJson<DateTime>(sessionStart),
      'sessionEnd': serializer.toJson<DateTime?>(sessionEnd),
      'sessionDurationMinutes': serializer.toJson<int?>(sessionDurationMinutes),
      'userId': serializer.toJson<int>(userId),
      'agentName': serializer.toJson<String?>(agentName),
      'bucket': serializer.toJson<String?>(bucket),
      'totalContacts': serializer.toJson<int>(totalContacts),
      'contactsAttempted': serializer.toJson<int>(contactsAttempted),
      'contactsCompleted': serializer.toJson<int>(contactsCompleted),
      'successfulCalls': serializer.toJson<int>(successfulCalls),
      'failedCalls': serializer.toJson<int>(failedCalls),
      'noAnswerCalls': serializer.toJson<int>(noAnswerCalls),
      'hangUpCalls': serializer.toJson<int>(hangUpCalls),
      'sessionType': serializer.toJson<String>(sessionType),
      'wasCompleted': serializer.toJson<bool>(wasCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'successRate': serializer.toJson<double?>(successRate),
      'averageCallDurationSeconds': serializer.toJson<int?>(
        averageCallDurationSeconds,
      ),
      'sessionNotes': serializer.toJson<String?>(sessionNotes),
    };
  }

  CallSessionEntry copyWith({
    int? id,
    DateTime? sessionStart,
    Value<DateTime?> sessionEnd = const Value.absent(),
    Value<int?> sessionDurationMinutes = const Value.absent(),
    int? userId,
    Value<String?> agentName = const Value.absent(),
    Value<String?> bucket = const Value.absent(),
    int? totalContacts,
    int? contactsAttempted,
    int? contactsCompleted,
    int? successfulCalls,
    int? failedCalls,
    int? noAnswerCalls,
    int? hangUpCalls,
    String? sessionType,
    bool? wasCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<double?> successRate = const Value.absent(),
    Value<int?> averageCallDurationSeconds = const Value.absent(),
    Value<String?> sessionNotes = const Value.absent(),
  }) => CallSessionEntry(
    id: id ?? this.id,
    sessionStart: sessionStart ?? this.sessionStart,
    sessionEnd: sessionEnd.present ? sessionEnd.value : this.sessionEnd,
    sessionDurationMinutes: sessionDurationMinutes.present
        ? sessionDurationMinutes.value
        : this.sessionDurationMinutes,
    userId: userId ?? this.userId,
    agentName: agentName.present ? agentName.value : this.agentName,
    bucket: bucket.present ? bucket.value : this.bucket,
    totalContacts: totalContacts ?? this.totalContacts,
    contactsAttempted: contactsAttempted ?? this.contactsAttempted,
    contactsCompleted: contactsCompleted ?? this.contactsCompleted,
    successfulCalls: successfulCalls ?? this.successfulCalls,
    failedCalls: failedCalls ?? this.failedCalls,
    noAnswerCalls: noAnswerCalls ?? this.noAnswerCalls,
    hangUpCalls: hangUpCalls ?? this.hangUpCalls,
    sessionType: sessionType ?? this.sessionType,
    wasCompleted: wasCompleted ?? this.wasCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    successRate: successRate.present ? successRate.value : this.successRate,
    averageCallDurationSeconds: averageCallDurationSeconds.present
        ? averageCallDurationSeconds.value
        : this.averageCallDurationSeconds,
    sessionNotes: sessionNotes.present ? sessionNotes.value : this.sessionNotes,
  );
  CallSessionEntry copyWithCompanion(CallSessionsCompanion data) {
    return CallSessionEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionStart: data.sessionStart.present
          ? data.sessionStart.value
          : this.sessionStart,
      sessionEnd: data.sessionEnd.present
          ? data.sessionEnd.value
          : this.sessionEnd,
      sessionDurationMinutes: data.sessionDurationMinutes.present
          ? data.sessionDurationMinutes.value
          : this.sessionDurationMinutes,
      userId: data.userId.present ? data.userId.value : this.userId,
      agentName: data.agentName.present ? data.agentName.value : this.agentName,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      totalContacts: data.totalContacts.present
          ? data.totalContacts.value
          : this.totalContacts,
      contactsAttempted: data.contactsAttempted.present
          ? data.contactsAttempted.value
          : this.contactsAttempted,
      contactsCompleted: data.contactsCompleted.present
          ? data.contactsCompleted.value
          : this.contactsCompleted,
      successfulCalls: data.successfulCalls.present
          ? data.successfulCalls.value
          : this.successfulCalls,
      failedCalls: data.failedCalls.present
          ? data.failedCalls.value
          : this.failedCalls,
      noAnswerCalls: data.noAnswerCalls.present
          ? data.noAnswerCalls.value
          : this.noAnswerCalls,
      hangUpCalls: data.hangUpCalls.present
          ? data.hangUpCalls.value
          : this.hangUpCalls,
      sessionType: data.sessionType.present
          ? data.sessionType.value
          : this.sessionType,
      wasCompleted: data.wasCompleted.present
          ? data.wasCompleted.value
          : this.wasCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      successRate: data.successRate.present
          ? data.successRate.value
          : this.successRate,
      averageCallDurationSeconds: data.averageCallDurationSeconds.present
          ? data.averageCallDurationSeconds.value
          : this.averageCallDurationSeconds,
      sessionNotes: data.sessionNotes.present
          ? data.sessionNotes.value
          : this.sessionNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallSessionEntry(')
          ..write('id: $id, ')
          ..write('sessionStart: $sessionStart, ')
          ..write('sessionEnd: $sessionEnd, ')
          ..write('sessionDurationMinutes: $sessionDurationMinutes, ')
          ..write('userId: $userId, ')
          ..write('agentName: $agentName, ')
          ..write('bucket: $bucket, ')
          ..write('totalContacts: $totalContacts, ')
          ..write('contactsAttempted: $contactsAttempted, ')
          ..write('contactsCompleted: $contactsCompleted, ')
          ..write('successfulCalls: $successfulCalls, ')
          ..write('failedCalls: $failedCalls, ')
          ..write('noAnswerCalls: $noAnswerCalls, ')
          ..write('hangUpCalls: $hangUpCalls, ')
          ..write('sessionType: $sessionType, ')
          ..write('wasCompleted: $wasCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('successRate: $successRate, ')
          ..write('averageCallDurationSeconds: $averageCallDurationSeconds, ')
          ..write('sessionNotes: $sessionNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionStart,
    sessionEnd,
    sessionDurationMinutes,
    userId,
    agentName,
    bucket,
    totalContacts,
    contactsAttempted,
    contactsCompleted,
    successfulCalls,
    failedCalls,
    noAnswerCalls,
    hangUpCalls,
    sessionType,
    wasCompleted,
    createdAt,
    updatedAt,
    successRate,
    averageCallDurationSeconds,
    sessionNotes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallSessionEntry &&
          other.id == this.id &&
          other.sessionStart == this.sessionStart &&
          other.sessionEnd == this.sessionEnd &&
          other.sessionDurationMinutes == this.sessionDurationMinutes &&
          other.userId == this.userId &&
          other.agentName == this.agentName &&
          other.bucket == this.bucket &&
          other.totalContacts == this.totalContacts &&
          other.contactsAttempted == this.contactsAttempted &&
          other.contactsCompleted == this.contactsCompleted &&
          other.successfulCalls == this.successfulCalls &&
          other.failedCalls == this.failedCalls &&
          other.noAnswerCalls == this.noAnswerCalls &&
          other.hangUpCalls == this.hangUpCalls &&
          other.sessionType == this.sessionType &&
          other.wasCompleted == this.wasCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.successRate == this.successRate &&
          other.averageCallDurationSeconds == this.averageCallDurationSeconds &&
          other.sessionNotes == this.sessionNotes);
}

class CallSessionsCompanion extends UpdateCompanion<CallSessionEntry> {
  final Value<int> id;
  final Value<DateTime> sessionStart;
  final Value<DateTime?> sessionEnd;
  final Value<int?> sessionDurationMinutes;
  final Value<int> userId;
  final Value<String?> agentName;
  final Value<String?> bucket;
  final Value<int> totalContacts;
  final Value<int> contactsAttempted;
  final Value<int> contactsCompleted;
  final Value<int> successfulCalls;
  final Value<int> failedCalls;
  final Value<int> noAnswerCalls;
  final Value<int> hangUpCalls;
  final Value<String> sessionType;
  final Value<bool> wasCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<double?> successRate;
  final Value<int?> averageCallDurationSeconds;
  final Value<String?> sessionNotes;
  const CallSessionsCompanion({
    this.id = const Value.absent(),
    this.sessionStart = const Value.absent(),
    this.sessionEnd = const Value.absent(),
    this.sessionDurationMinutes = const Value.absent(),
    this.userId = const Value.absent(),
    this.agentName = const Value.absent(),
    this.bucket = const Value.absent(),
    this.totalContacts = const Value.absent(),
    this.contactsAttempted = const Value.absent(),
    this.contactsCompleted = const Value.absent(),
    this.successfulCalls = const Value.absent(),
    this.failedCalls = const Value.absent(),
    this.noAnswerCalls = const Value.absent(),
    this.hangUpCalls = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.wasCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.successRate = const Value.absent(),
    this.averageCallDurationSeconds = const Value.absent(),
    this.sessionNotes = const Value.absent(),
  });
  CallSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime sessionStart,
    this.sessionEnd = const Value.absent(),
    this.sessionDurationMinutes = const Value.absent(),
    required int userId,
    this.agentName = const Value.absent(),
    this.bucket = const Value.absent(),
    this.totalContacts = const Value.absent(),
    this.contactsAttempted = const Value.absent(),
    this.contactsCompleted = const Value.absent(),
    this.successfulCalls = const Value.absent(),
    this.failedCalls = const Value.absent(),
    this.noAnswerCalls = const Value.absent(),
    this.hangUpCalls = const Value.absent(),
    required String sessionType,
    this.wasCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.successRate = const Value.absent(),
    this.averageCallDurationSeconds = const Value.absent(),
    this.sessionNotes = const Value.absent(),
  }) : sessionStart = Value(sessionStart),
       userId = Value(userId),
       sessionType = Value(sessionType);
  static Insertable<CallSessionEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? sessionStart,
    Expression<DateTime>? sessionEnd,
    Expression<int>? sessionDurationMinutes,
    Expression<int>? userId,
    Expression<String>? agentName,
    Expression<String>? bucket,
    Expression<int>? totalContacts,
    Expression<int>? contactsAttempted,
    Expression<int>? contactsCompleted,
    Expression<int>? successfulCalls,
    Expression<int>? failedCalls,
    Expression<int>? noAnswerCalls,
    Expression<int>? hangUpCalls,
    Expression<String>? sessionType,
    Expression<bool>? wasCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<double>? successRate,
    Expression<int>? averageCallDurationSeconds,
    Expression<String>? sessionNotes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionStart != null) 'session_start': sessionStart,
      if (sessionEnd != null) 'session_end': sessionEnd,
      if (sessionDurationMinutes != null)
        'session_duration_minutes': sessionDurationMinutes,
      if (userId != null) 'user_id': userId,
      if (agentName != null) 'agent_name': agentName,
      if (bucket != null) 'bucket': bucket,
      if (totalContacts != null) 'total_contacts': totalContacts,
      if (contactsAttempted != null) 'contacts_attempted': contactsAttempted,
      if (contactsCompleted != null) 'contacts_completed': contactsCompleted,
      if (successfulCalls != null) 'successful_calls': successfulCalls,
      if (failedCalls != null) 'failed_calls': failedCalls,
      if (noAnswerCalls != null) 'no_answer_calls': noAnswerCalls,
      if (hangUpCalls != null) 'hang_up_calls': hangUpCalls,
      if (sessionType != null) 'session_type': sessionType,
      if (wasCompleted != null) 'was_completed': wasCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (successRate != null) 'success_rate': successRate,
      if (averageCallDurationSeconds != null)
        'average_call_duration_seconds': averageCallDurationSeconds,
      if (sessionNotes != null) 'session_notes': sessionNotes,
    });
  }

  CallSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? sessionStart,
    Value<DateTime?>? sessionEnd,
    Value<int?>? sessionDurationMinutes,
    Value<int>? userId,
    Value<String?>? agentName,
    Value<String?>? bucket,
    Value<int>? totalContacts,
    Value<int>? contactsAttempted,
    Value<int>? contactsCompleted,
    Value<int>? successfulCalls,
    Value<int>? failedCalls,
    Value<int>? noAnswerCalls,
    Value<int>? hangUpCalls,
    Value<String>? sessionType,
    Value<bool>? wasCompleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<double?>? successRate,
    Value<int?>? averageCallDurationSeconds,
    Value<String?>? sessionNotes,
  }) {
    return CallSessionsCompanion(
      id: id ?? this.id,
      sessionStart: sessionStart ?? this.sessionStart,
      sessionEnd: sessionEnd ?? this.sessionEnd,
      sessionDurationMinutes:
          sessionDurationMinutes ?? this.sessionDurationMinutes,
      userId: userId ?? this.userId,
      agentName: agentName ?? this.agentName,
      bucket: bucket ?? this.bucket,
      totalContacts: totalContacts ?? this.totalContacts,
      contactsAttempted: contactsAttempted ?? this.contactsAttempted,
      contactsCompleted: contactsCompleted ?? this.contactsCompleted,
      successfulCalls: successfulCalls ?? this.successfulCalls,
      failedCalls: failedCalls ?? this.failedCalls,
      noAnswerCalls: noAnswerCalls ?? this.noAnswerCalls,
      hangUpCalls: hangUpCalls ?? this.hangUpCalls,
      sessionType: sessionType ?? this.sessionType,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      successRate: successRate ?? this.successRate,
      averageCallDurationSeconds:
          averageCallDurationSeconds ?? this.averageCallDurationSeconds,
      sessionNotes: sessionNotes ?? this.sessionNotes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionStart.present) {
      map['session_start'] = Variable<DateTime>(sessionStart.value);
    }
    if (sessionEnd.present) {
      map['session_end'] = Variable<DateTime>(sessionEnd.value);
    }
    if (sessionDurationMinutes.present) {
      map['session_duration_minutes'] = Variable<int>(
        sessionDurationMinutes.value,
      );
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (agentName.present) {
      map['agent_name'] = Variable<String>(agentName.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (totalContacts.present) {
      map['total_contacts'] = Variable<int>(totalContacts.value);
    }
    if (contactsAttempted.present) {
      map['contacts_attempted'] = Variable<int>(contactsAttempted.value);
    }
    if (contactsCompleted.present) {
      map['contacts_completed'] = Variable<int>(contactsCompleted.value);
    }
    if (successfulCalls.present) {
      map['successful_calls'] = Variable<int>(successfulCalls.value);
    }
    if (failedCalls.present) {
      map['failed_calls'] = Variable<int>(failedCalls.value);
    }
    if (noAnswerCalls.present) {
      map['no_answer_calls'] = Variable<int>(noAnswerCalls.value);
    }
    if (hangUpCalls.present) {
      map['hang_up_calls'] = Variable<int>(hangUpCalls.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(sessionType.value);
    }
    if (wasCompleted.present) {
      map['was_completed'] = Variable<bool>(wasCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (successRate.present) {
      map['success_rate'] = Variable<double>(successRate.value);
    }
    if (averageCallDurationSeconds.present) {
      map['average_call_duration_seconds'] = Variable<int>(
        averageCallDurationSeconds.value,
      );
    }
    if (sessionNotes.present) {
      map['session_notes'] = Variable<String>(sessionNotes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionStart: $sessionStart, ')
          ..write('sessionEnd: $sessionEnd, ')
          ..write('sessionDurationMinutes: $sessionDurationMinutes, ')
          ..write('userId: $userId, ')
          ..write('agentName: $agentName, ')
          ..write('bucket: $bucket, ')
          ..write('totalContacts: $totalContacts, ')
          ..write('contactsAttempted: $contactsAttempted, ')
          ..write('contactsCompleted: $contactsCompleted, ')
          ..write('successfulCalls: $successfulCalls, ')
          ..write('failedCalls: $failedCalls, ')
          ..write('noAnswerCalls: $noAnswerCalls, ')
          ..write('hangUpCalls: $hangUpCalls, ')
          ..write('sessionType: $sessionType, ')
          ..write('wasCompleted: $wasCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('successRate: $successRate, ')
          ..write('averageCallDurationSeconds: $averageCallDurationSeconds, ')
          ..write('sessionNotes: $sessionNotes')
          ..write(')'))
        .toString();
  }
}

class $BreakSessionsTable extends BreakSessions
    with TableInfo<$BreakSessionsTable, BreakSessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BreakSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _breakStartMeta = const VerificationMeta(
    'breakStart',
  );
  @override
  late final GeneratedColumn<DateTime> breakStart = GeneratedColumn<DateTime>(
    'break_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breakEndMeta = const VerificationMeta(
    'breakEnd',
  );
  @override
  late final GeneratedColumn<DateTime> breakEnd = GeneratedColumn<DateTime>(
    'break_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breakDurationMinutesMeta =
      const VerificationMeta('breakDurationMinutes');
  @override
  late final GeneratedColumn<int> breakDurationMinutes = GeneratedColumn<int>(
    'break_duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breakTypeMeta = const VerificationMeta(
    'breakType',
  );
  @override
  late final GeneratedColumn<String> breakType = GeneratedColumn<String>(
    'break_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breakReasonMeta = const VerificationMeta(
    'breakReason',
  );
  @override
  late final GeneratedColumn<String> breakReason = GeneratedColumn<String>(
    'break_reason',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agentNameMeta = const VerificationMeta(
    'agentName',
  );
  @override
  late final GeneratedColumn<String> agentName = GeneratedColumn<String>(
    'agent_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _callSessionIdMeta = const VerificationMeta(
    'callSessionId',
  );
  @override
  late final GeneratedColumn<int> callSessionId = GeneratedColumn<int>(
    'call_session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    breakStart,
    breakEnd,
    breakDurationMinutes,
    breakType,
    breakReason,
    userId,
    agentName,
    createdAt,
    callSessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'break_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<BreakSessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('break_start')) {
      context.handle(
        _breakStartMeta,
        breakStart.isAcceptableOrUnknown(data['break_start']!, _breakStartMeta),
      );
    } else if (isInserting) {
      context.missing(_breakStartMeta);
    }
    if (data.containsKey('break_end')) {
      context.handle(
        _breakEndMeta,
        breakEnd.isAcceptableOrUnknown(data['break_end']!, _breakEndMeta),
      );
    }
    if (data.containsKey('break_duration_minutes')) {
      context.handle(
        _breakDurationMinutesMeta,
        breakDurationMinutes.isAcceptableOrUnknown(
          data['break_duration_minutes']!,
          _breakDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('break_type')) {
      context.handle(
        _breakTypeMeta,
        breakType.isAcceptableOrUnknown(data['break_type']!, _breakTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_breakTypeMeta);
    }
    if (data.containsKey('break_reason')) {
      context.handle(
        _breakReasonMeta,
        breakReason.isAcceptableOrUnknown(
          data['break_reason']!,
          _breakReasonMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('agent_name')) {
      context.handle(
        _agentNameMeta,
        agentName.isAcceptableOrUnknown(data['agent_name']!, _agentNameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('call_session_id')) {
      context.handle(
        _callSessionIdMeta,
        callSessionId.isAcceptableOrUnknown(
          data['call_session_id']!,
          _callSessionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BreakSessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BreakSessionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      breakStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}break_start'],
      )!,
      breakEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}break_end'],
      ),
      breakDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_duration_minutes'],
      ),
      breakType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}break_type'],
      )!,
      breakReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}break_reason'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      agentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      callSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_session_id'],
      ),
    );
  }

  @override
  $BreakSessionsTable createAlias(String alias) {
    return $BreakSessionsTable(attachedDatabase, alias);
  }
}

class BreakSessionEntry extends DataClass
    implements Insertable<BreakSessionEntry> {
  final int id;
  final DateTime breakStart;
  final DateTime? breakEnd;
  final int? breakDurationMinutes;
  final String breakType;
  final String? breakReason;
  final int userId;
  final String? agentName;
  final DateTime createdAt;
  final int? callSessionId;
  const BreakSessionEntry({
    required this.id,
    required this.breakStart,
    this.breakEnd,
    this.breakDurationMinutes,
    required this.breakType,
    this.breakReason,
    required this.userId,
    this.agentName,
    required this.createdAt,
    this.callSessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['break_start'] = Variable<DateTime>(breakStart);
    if (!nullToAbsent || breakEnd != null) {
      map['break_end'] = Variable<DateTime>(breakEnd);
    }
    if (!nullToAbsent || breakDurationMinutes != null) {
      map['break_duration_minutes'] = Variable<int>(breakDurationMinutes);
    }
    map['break_type'] = Variable<String>(breakType);
    if (!nullToAbsent || breakReason != null) {
      map['break_reason'] = Variable<String>(breakReason);
    }
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || agentName != null) {
      map['agent_name'] = Variable<String>(agentName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || callSessionId != null) {
      map['call_session_id'] = Variable<int>(callSessionId);
    }
    return map;
  }

  BreakSessionsCompanion toCompanion(bool nullToAbsent) {
    return BreakSessionsCompanion(
      id: Value(id),
      breakStart: Value(breakStart),
      breakEnd: breakEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(breakEnd),
      breakDurationMinutes: breakDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(breakDurationMinutes),
      breakType: Value(breakType),
      breakReason: breakReason == null && nullToAbsent
          ? const Value.absent()
          : Value(breakReason),
      userId: Value(userId),
      agentName: agentName == null && nullToAbsent
          ? const Value.absent()
          : Value(agentName),
      createdAt: Value(createdAt),
      callSessionId: callSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(callSessionId),
    );
  }

  factory BreakSessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BreakSessionEntry(
      id: serializer.fromJson<int>(json['id']),
      breakStart: serializer.fromJson<DateTime>(json['breakStart']),
      breakEnd: serializer.fromJson<DateTime?>(json['breakEnd']),
      breakDurationMinutes: serializer.fromJson<int?>(
        json['breakDurationMinutes'],
      ),
      breakType: serializer.fromJson<String>(json['breakType']),
      breakReason: serializer.fromJson<String?>(json['breakReason']),
      userId: serializer.fromJson<int>(json['userId']),
      agentName: serializer.fromJson<String?>(json['agentName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      callSessionId: serializer.fromJson<int?>(json['callSessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'breakStart': serializer.toJson<DateTime>(breakStart),
      'breakEnd': serializer.toJson<DateTime?>(breakEnd),
      'breakDurationMinutes': serializer.toJson<int?>(breakDurationMinutes),
      'breakType': serializer.toJson<String>(breakType),
      'breakReason': serializer.toJson<String?>(breakReason),
      'userId': serializer.toJson<int>(userId),
      'agentName': serializer.toJson<String?>(agentName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'callSessionId': serializer.toJson<int?>(callSessionId),
    };
  }

  BreakSessionEntry copyWith({
    int? id,
    DateTime? breakStart,
    Value<DateTime?> breakEnd = const Value.absent(),
    Value<int?> breakDurationMinutes = const Value.absent(),
    String? breakType,
    Value<String?> breakReason = const Value.absent(),
    int? userId,
    Value<String?> agentName = const Value.absent(),
    DateTime? createdAt,
    Value<int?> callSessionId = const Value.absent(),
  }) => BreakSessionEntry(
    id: id ?? this.id,
    breakStart: breakStart ?? this.breakStart,
    breakEnd: breakEnd.present ? breakEnd.value : this.breakEnd,
    breakDurationMinutes: breakDurationMinutes.present
        ? breakDurationMinutes.value
        : this.breakDurationMinutes,
    breakType: breakType ?? this.breakType,
    breakReason: breakReason.present ? breakReason.value : this.breakReason,
    userId: userId ?? this.userId,
    agentName: agentName.present ? agentName.value : this.agentName,
    createdAt: createdAt ?? this.createdAt,
    callSessionId: callSessionId.present
        ? callSessionId.value
        : this.callSessionId,
  );
  BreakSessionEntry copyWithCompanion(BreakSessionsCompanion data) {
    return BreakSessionEntry(
      id: data.id.present ? data.id.value : this.id,
      breakStart: data.breakStart.present
          ? data.breakStart.value
          : this.breakStart,
      breakEnd: data.breakEnd.present ? data.breakEnd.value : this.breakEnd,
      breakDurationMinutes: data.breakDurationMinutes.present
          ? data.breakDurationMinutes.value
          : this.breakDurationMinutes,
      breakType: data.breakType.present ? data.breakType.value : this.breakType,
      breakReason: data.breakReason.present
          ? data.breakReason.value
          : this.breakReason,
      userId: data.userId.present ? data.userId.value : this.userId,
      agentName: data.agentName.present ? data.agentName.value : this.agentName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      callSessionId: data.callSessionId.present
          ? data.callSessionId.value
          : this.callSessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BreakSessionEntry(')
          ..write('id: $id, ')
          ..write('breakStart: $breakStart, ')
          ..write('breakEnd: $breakEnd, ')
          ..write('breakDurationMinutes: $breakDurationMinutes, ')
          ..write('breakType: $breakType, ')
          ..write('breakReason: $breakReason, ')
          ..write('userId: $userId, ')
          ..write('agentName: $agentName, ')
          ..write('createdAt: $createdAt, ')
          ..write('callSessionId: $callSessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    breakStart,
    breakEnd,
    breakDurationMinutes,
    breakType,
    breakReason,
    userId,
    agentName,
    createdAt,
    callSessionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BreakSessionEntry &&
          other.id == this.id &&
          other.breakStart == this.breakStart &&
          other.breakEnd == this.breakEnd &&
          other.breakDurationMinutes == this.breakDurationMinutes &&
          other.breakType == this.breakType &&
          other.breakReason == this.breakReason &&
          other.userId == this.userId &&
          other.agentName == this.agentName &&
          other.createdAt == this.createdAt &&
          other.callSessionId == this.callSessionId);
}

class BreakSessionsCompanion extends UpdateCompanion<BreakSessionEntry> {
  final Value<int> id;
  final Value<DateTime> breakStart;
  final Value<DateTime?> breakEnd;
  final Value<int?> breakDurationMinutes;
  final Value<String> breakType;
  final Value<String?> breakReason;
  final Value<int> userId;
  final Value<String?> agentName;
  final Value<DateTime> createdAt;
  final Value<int?> callSessionId;
  const BreakSessionsCompanion({
    this.id = const Value.absent(),
    this.breakStart = const Value.absent(),
    this.breakEnd = const Value.absent(),
    this.breakDurationMinutes = const Value.absent(),
    this.breakType = const Value.absent(),
    this.breakReason = const Value.absent(),
    this.userId = const Value.absent(),
    this.agentName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.callSessionId = const Value.absent(),
  });
  BreakSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime breakStart,
    this.breakEnd = const Value.absent(),
    this.breakDurationMinutes = const Value.absent(),
    required String breakType,
    this.breakReason = const Value.absent(),
    required int userId,
    this.agentName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.callSessionId = const Value.absent(),
  }) : breakStart = Value(breakStart),
       breakType = Value(breakType),
       userId = Value(userId);
  static Insertable<BreakSessionEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? breakStart,
    Expression<DateTime>? breakEnd,
    Expression<int>? breakDurationMinutes,
    Expression<String>? breakType,
    Expression<String>? breakReason,
    Expression<int>? userId,
    Expression<String>? agentName,
    Expression<DateTime>? createdAt,
    Expression<int>? callSessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (breakStart != null) 'break_start': breakStart,
      if (breakEnd != null) 'break_end': breakEnd,
      if (breakDurationMinutes != null)
        'break_duration_minutes': breakDurationMinutes,
      if (breakType != null) 'break_type': breakType,
      if (breakReason != null) 'break_reason': breakReason,
      if (userId != null) 'user_id': userId,
      if (agentName != null) 'agent_name': agentName,
      if (createdAt != null) 'created_at': createdAt,
      if (callSessionId != null) 'call_session_id': callSessionId,
    });
  }

  BreakSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? breakStart,
    Value<DateTime?>? breakEnd,
    Value<int?>? breakDurationMinutes,
    Value<String>? breakType,
    Value<String?>? breakReason,
    Value<int>? userId,
    Value<String?>? agentName,
    Value<DateTime>? createdAt,
    Value<int?>? callSessionId,
  }) {
    return BreakSessionsCompanion(
      id: id ?? this.id,
      breakStart: breakStart ?? this.breakStart,
      breakEnd: breakEnd ?? this.breakEnd,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      breakType: breakType ?? this.breakType,
      breakReason: breakReason ?? this.breakReason,
      userId: userId ?? this.userId,
      agentName: agentName ?? this.agentName,
      createdAt: createdAt ?? this.createdAt,
      callSessionId: callSessionId ?? this.callSessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (breakStart.present) {
      map['break_start'] = Variable<DateTime>(breakStart.value);
    }
    if (breakEnd.present) {
      map['break_end'] = Variable<DateTime>(breakEnd.value);
    }
    if (breakDurationMinutes.present) {
      map['break_duration_minutes'] = Variable<int>(breakDurationMinutes.value);
    }
    if (breakType.present) {
      map['break_type'] = Variable<String>(breakType.value);
    }
    if (breakReason.present) {
      map['break_reason'] = Variable<String>(breakReason.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (agentName.present) {
      map['agent_name'] = Variable<String>(agentName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (callSessionId.present) {
      map['call_session_id'] = Variable<int>(callSessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BreakSessionsCompanion(')
          ..write('id: $id, ')
          ..write('breakStart: $breakStart, ')
          ..write('breakEnd: $breakEnd, ')
          ..write('breakDurationMinutes: $breakDurationMinutes, ')
          ..write('breakType: $breakType, ')
          ..write('breakReason: $breakReason, ')
          ..write('userId: $userId, ')
          ..write('agentName: $agentName, ')
          ..write('createdAt: $createdAt, ')
          ..write('callSessionId: $callSessionId')
          ..write(')'))
        .toString();
  }
}

class $DailyStatsTable extends DailyStats
    with TableInfo<$DailyStatsTable, DailyStatEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _statDateMeta = const VerificationMeta(
    'statDate',
  );
  @override
  late final GeneratedColumn<DateTime> statDate = GeneratedColumn<DateTime>(
    'stat_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agentNameMeta = const VerificationMeta(
    'agentName',
  );
  @override
  late final GeneratedColumn<String> agentName = GeneratedColumn<String>(
    'agent_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCallsMeta = const VerificationMeta(
    'totalCalls',
  );
  @override
  late final GeneratedColumn<int> totalCalls = GeneratedColumn<int>(
    'total_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successfulCallsMeta = const VerificationMeta(
    'successfulCalls',
  );
  @override
  late final GeneratedColumn<int> successfulCalls = GeneratedColumn<int>(
    'successful_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failedCallsMeta = const VerificationMeta(
    'failedCalls',
  );
  @override
  late final GeneratedColumn<int> failedCalls = GeneratedColumn<int>(
    'failed_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noAnswerCallsMeta = const VerificationMeta(
    'noAnswerCalls',
  );
  @override
  late final GeneratedColumn<int> noAnswerCalls = GeneratedColumn<int>(
    'no_answer_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hangUpCallsMeta = const VerificationMeta(
    'hangUpCalls',
  );
  @override
  late final GeneratedColumn<int> hangUpCalls = GeneratedColumn<int>(
    'hang_up_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalWorkMinutesMeta = const VerificationMeta(
    'totalWorkMinutes',
  );
  @override
  late final GeneratedColumn<int> totalWorkMinutes = GeneratedColumn<int>(
    'total_work_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBreakMinutesMeta = const VerificationMeta(
    'totalBreakMinutes',
  );
  @override
  late final GeneratedColumn<int> totalBreakMinutes = GeneratedColumn<int>(
    'total_break_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCallTimeMinutesMeta =
      const VerificationMeta('totalCallTimeMinutes');
  @override
  late final GeneratedColumn<int> totalCallTimeMinutes = GeneratedColumn<int>(
    'total_call_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successRateMeta = const VerificationMeta(
    'successRate',
  );
  @override
  late final GeneratedColumn<double> successRate = GeneratedColumn<double>(
    'success_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageCallDurationMeta =
      const VerificationMeta('averageCallDuration');
  @override
  late final GeneratedColumn<double> averageCallDuration =
      GeneratedColumn<double>(
        'average_call_duration',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _contactsProcessedMeta = const VerificationMeta(
    'contactsProcessed',
  );
  @override
  late final GeneratedColumn<int> contactsProcessed = GeneratedColumn<int>(
    'contacts_processed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _frontendCallsMeta = const VerificationMeta(
    'frontendCalls',
  );
  @override
  late final GeneratedColumn<int> frontendCalls = GeneratedColumn<int>(
    'frontend_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _middlecoreCallsMeta = const VerificationMeta(
    'middlecoreCalls',
  );
  @override
  late final GeneratedColumn<int> middlecoreCalls = GeneratedColumn<int>(
    'middlecore_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hardcoreCallsMeta = const VerificationMeta(
    'hardcoreCalls',
  );
  @override
  late final GeneratedColumn<int> hardcoreCalls = GeneratedColumn<int>(
    'hardcore_calls',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    statDate,
    userId,
    agentName,
    totalCalls,
    successfulCalls,
    failedCalls,
    noAnswerCalls,
    hangUpCalls,
    totalWorkMinutes,
    totalBreakMinutes,
    totalCallTimeMinutes,
    successRate,
    averageCallDuration,
    contactsProcessed,
    frontendCalls,
    middlecoreCalls,
    hardcoreCalls,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyStatEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stat_date')) {
      context.handle(
        _statDateMeta,
        statDate.isAcceptableOrUnknown(data['stat_date']!, _statDateMeta),
      );
    } else if (isInserting) {
      context.missing(_statDateMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('agent_name')) {
      context.handle(
        _agentNameMeta,
        agentName.isAcceptableOrUnknown(data['agent_name']!, _agentNameMeta),
      );
    }
    if (data.containsKey('total_calls')) {
      context.handle(
        _totalCallsMeta,
        totalCalls.isAcceptableOrUnknown(data['total_calls']!, _totalCallsMeta),
      );
    }
    if (data.containsKey('successful_calls')) {
      context.handle(
        _successfulCallsMeta,
        successfulCalls.isAcceptableOrUnknown(
          data['successful_calls']!,
          _successfulCallsMeta,
        ),
      );
    }
    if (data.containsKey('failed_calls')) {
      context.handle(
        _failedCallsMeta,
        failedCalls.isAcceptableOrUnknown(
          data['failed_calls']!,
          _failedCallsMeta,
        ),
      );
    }
    if (data.containsKey('no_answer_calls')) {
      context.handle(
        _noAnswerCallsMeta,
        noAnswerCalls.isAcceptableOrUnknown(
          data['no_answer_calls']!,
          _noAnswerCallsMeta,
        ),
      );
    }
    if (data.containsKey('hang_up_calls')) {
      context.handle(
        _hangUpCallsMeta,
        hangUpCalls.isAcceptableOrUnknown(
          data['hang_up_calls']!,
          _hangUpCallsMeta,
        ),
      );
    }
    if (data.containsKey('total_work_minutes')) {
      context.handle(
        _totalWorkMinutesMeta,
        totalWorkMinutes.isAcceptableOrUnknown(
          data['total_work_minutes']!,
          _totalWorkMinutesMeta,
        ),
      );
    }
    if (data.containsKey('total_break_minutes')) {
      context.handle(
        _totalBreakMinutesMeta,
        totalBreakMinutes.isAcceptableOrUnknown(
          data['total_break_minutes']!,
          _totalBreakMinutesMeta,
        ),
      );
    }
    if (data.containsKey('total_call_time_minutes')) {
      context.handle(
        _totalCallTimeMinutesMeta,
        totalCallTimeMinutes.isAcceptableOrUnknown(
          data['total_call_time_minutes']!,
          _totalCallTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('success_rate')) {
      context.handle(
        _successRateMeta,
        successRate.isAcceptableOrUnknown(
          data['success_rate']!,
          _successRateMeta,
        ),
      );
    }
    if (data.containsKey('average_call_duration')) {
      context.handle(
        _averageCallDurationMeta,
        averageCallDuration.isAcceptableOrUnknown(
          data['average_call_duration']!,
          _averageCallDurationMeta,
        ),
      );
    }
    if (data.containsKey('contacts_processed')) {
      context.handle(
        _contactsProcessedMeta,
        contactsProcessed.isAcceptableOrUnknown(
          data['contacts_processed']!,
          _contactsProcessedMeta,
        ),
      );
    }
    if (data.containsKey('frontend_calls')) {
      context.handle(
        _frontendCallsMeta,
        frontendCalls.isAcceptableOrUnknown(
          data['frontend_calls']!,
          _frontendCallsMeta,
        ),
      );
    }
    if (data.containsKey('middlecore_calls')) {
      context.handle(
        _middlecoreCallsMeta,
        middlecoreCalls.isAcceptableOrUnknown(
          data['middlecore_calls']!,
          _middlecoreCallsMeta,
        ),
      );
    }
    if (data.containsKey('hardcore_calls')) {
      context.handle(
        _hardcoreCallsMeta,
        hardcoreCalls.isAcceptableOrUnknown(
          data['hardcore_calls']!,
          _hardcoreCallsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyStatEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStatEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      statDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}stat_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      agentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_name'],
      ),
      totalCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_calls'],
      )!,
      successfulCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}successful_calls'],
      )!,
      failedCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_calls'],
      )!,
      noAnswerCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}no_answer_calls'],
      )!,
      hangUpCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hang_up_calls'],
      )!,
      totalWorkMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_work_minutes'],
      )!,
      totalBreakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_break_minutes'],
      )!,
      totalCallTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_call_time_minutes'],
      )!,
      successRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}success_rate'],
      ),
      averageCallDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_call_duration'],
      ),
      contactsProcessed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contacts_processed'],
      )!,
      frontendCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frontend_calls'],
      )!,
      middlecoreCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}middlecore_calls'],
      )!,
      hardcoreCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hardcore_calls'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyStatsTable createAlias(String alias) {
    return $DailyStatsTable(attachedDatabase, alias);
  }
}

class DailyStatEntry extends DataClass implements Insertable<DailyStatEntry> {
  final int id;
  final DateTime statDate;
  final int userId;
  final String? agentName;
  final int totalCalls;
  final int successfulCalls;
  final int failedCalls;
  final int noAnswerCalls;
  final int hangUpCalls;
  final int totalWorkMinutes;
  final int totalBreakMinutes;
  final int totalCallTimeMinutes;
  final double? successRate;
  final double? averageCallDuration;
  final int contactsProcessed;
  final int frontendCalls;
  final int middlecoreCalls;
  final int hardcoreCalls;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyStatEntry({
    required this.id,
    required this.statDate,
    required this.userId,
    this.agentName,
    required this.totalCalls,
    required this.successfulCalls,
    required this.failedCalls,
    required this.noAnswerCalls,
    required this.hangUpCalls,
    required this.totalWorkMinutes,
    required this.totalBreakMinutes,
    required this.totalCallTimeMinutes,
    this.successRate,
    this.averageCallDuration,
    required this.contactsProcessed,
    required this.frontendCalls,
    required this.middlecoreCalls,
    required this.hardcoreCalls,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['stat_date'] = Variable<DateTime>(statDate);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || agentName != null) {
      map['agent_name'] = Variable<String>(agentName);
    }
    map['total_calls'] = Variable<int>(totalCalls);
    map['successful_calls'] = Variable<int>(successfulCalls);
    map['failed_calls'] = Variable<int>(failedCalls);
    map['no_answer_calls'] = Variable<int>(noAnswerCalls);
    map['hang_up_calls'] = Variable<int>(hangUpCalls);
    map['total_work_minutes'] = Variable<int>(totalWorkMinutes);
    map['total_break_minutes'] = Variable<int>(totalBreakMinutes);
    map['total_call_time_minutes'] = Variable<int>(totalCallTimeMinutes);
    if (!nullToAbsent || successRate != null) {
      map['success_rate'] = Variable<double>(successRate);
    }
    if (!nullToAbsent || averageCallDuration != null) {
      map['average_call_duration'] = Variable<double>(averageCallDuration);
    }
    map['contacts_processed'] = Variable<int>(contactsProcessed);
    map['frontend_calls'] = Variable<int>(frontendCalls);
    map['middlecore_calls'] = Variable<int>(middlecoreCalls);
    map['hardcore_calls'] = Variable<int>(hardcoreCalls);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyStatsCompanion toCompanion(bool nullToAbsent) {
    return DailyStatsCompanion(
      id: Value(id),
      statDate: Value(statDate),
      userId: Value(userId),
      agentName: agentName == null && nullToAbsent
          ? const Value.absent()
          : Value(agentName),
      totalCalls: Value(totalCalls),
      successfulCalls: Value(successfulCalls),
      failedCalls: Value(failedCalls),
      noAnswerCalls: Value(noAnswerCalls),
      hangUpCalls: Value(hangUpCalls),
      totalWorkMinutes: Value(totalWorkMinutes),
      totalBreakMinutes: Value(totalBreakMinutes),
      totalCallTimeMinutes: Value(totalCallTimeMinutes),
      successRate: successRate == null && nullToAbsent
          ? const Value.absent()
          : Value(successRate),
      averageCallDuration: averageCallDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(averageCallDuration),
      contactsProcessed: Value(contactsProcessed),
      frontendCalls: Value(frontendCalls),
      middlecoreCalls: Value(middlecoreCalls),
      hardcoreCalls: Value(hardcoreCalls),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyStatEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStatEntry(
      id: serializer.fromJson<int>(json['id']),
      statDate: serializer.fromJson<DateTime>(json['statDate']),
      userId: serializer.fromJson<int>(json['userId']),
      agentName: serializer.fromJson<String?>(json['agentName']),
      totalCalls: serializer.fromJson<int>(json['totalCalls']),
      successfulCalls: serializer.fromJson<int>(json['successfulCalls']),
      failedCalls: serializer.fromJson<int>(json['failedCalls']),
      noAnswerCalls: serializer.fromJson<int>(json['noAnswerCalls']),
      hangUpCalls: serializer.fromJson<int>(json['hangUpCalls']),
      totalWorkMinutes: serializer.fromJson<int>(json['totalWorkMinutes']),
      totalBreakMinutes: serializer.fromJson<int>(json['totalBreakMinutes']),
      totalCallTimeMinutes: serializer.fromJson<int>(
        json['totalCallTimeMinutes'],
      ),
      successRate: serializer.fromJson<double?>(json['successRate']),
      averageCallDuration: serializer.fromJson<double?>(
        json['averageCallDuration'],
      ),
      contactsProcessed: serializer.fromJson<int>(json['contactsProcessed']),
      frontendCalls: serializer.fromJson<int>(json['frontendCalls']),
      middlecoreCalls: serializer.fromJson<int>(json['middlecoreCalls']),
      hardcoreCalls: serializer.fromJson<int>(json['hardcoreCalls']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'statDate': serializer.toJson<DateTime>(statDate),
      'userId': serializer.toJson<int>(userId),
      'agentName': serializer.toJson<String?>(agentName),
      'totalCalls': serializer.toJson<int>(totalCalls),
      'successfulCalls': serializer.toJson<int>(successfulCalls),
      'failedCalls': serializer.toJson<int>(failedCalls),
      'noAnswerCalls': serializer.toJson<int>(noAnswerCalls),
      'hangUpCalls': serializer.toJson<int>(hangUpCalls),
      'totalWorkMinutes': serializer.toJson<int>(totalWorkMinutes),
      'totalBreakMinutes': serializer.toJson<int>(totalBreakMinutes),
      'totalCallTimeMinutes': serializer.toJson<int>(totalCallTimeMinutes),
      'successRate': serializer.toJson<double?>(successRate),
      'averageCallDuration': serializer.toJson<double?>(averageCallDuration),
      'contactsProcessed': serializer.toJson<int>(contactsProcessed),
      'frontendCalls': serializer.toJson<int>(frontendCalls),
      'middlecoreCalls': serializer.toJson<int>(middlecoreCalls),
      'hardcoreCalls': serializer.toJson<int>(hardcoreCalls),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyStatEntry copyWith({
    int? id,
    DateTime? statDate,
    int? userId,
    Value<String?> agentName = const Value.absent(),
    int? totalCalls,
    int? successfulCalls,
    int? failedCalls,
    int? noAnswerCalls,
    int? hangUpCalls,
    int? totalWorkMinutes,
    int? totalBreakMinutes,
    int? totalCallTimeMinutes,
    Value<double?> successRate = const Value.absent(),
    Value<double?> averageCallDuration = const Value.absent(),
    int? contactsProcessed,
    int? frontendCalls,
    int? middlecoreCalls,
    int? hardcoreCalls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyStatEntry(
    id: id ?? this.id,
    statDate: statDate ?? this.statDate,
    userId: userId ?? this.userId,
    agentName: agentName.present ? agentName.value : this.agentName,
    totalCalls: totalCalls ?? this.totalCalls,
    successfulCalls: successfulCalls ?? this.successfulCalls,
    failedCalls: failedCalls ?? this.failedCalls,
    noAnswerCalls: noAnswerCalls ?? this.noAnswerCalls,
    hangUpCalls: hangUpCalls ?? this.hangUpCalls,
    totalWorkMinutes: totalWorkMinutes ?? this.totalWorkMinutes,
    totalBreakMinutes: totalBreakMinutes ?? this.totalBreakMinutes,
    totalCallTimeMinutes: totalCallTimeMinutes ?? this.totalCallTimeMinutes,
    successRate: successRate.present ? successRate.value : this.successRate,
    averageCallDuration: averageCallDuration.present
        ? averageCallDuration.value
        : this.averageCallDuration,
    contactsProcessed: contactsProcessed ?? this.contactsProcessed,
    frontendCalls: frontendCalls ?? this.frontendCalls,
    middlecoreCalls: middlecoreCalls ?? this.middlecoreCalls,
    hardcoreCalls: hardcoreCalls ?? this.hardcoreCalls,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyStatEntry copyWithCompanion(DailyStatsCompanion data) {
    return DailyStatEntry(
      id: data.id.present ? data.id.value : this.id,
      statDate: data.statDate.present ? data.statDate.value : this.statDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      agentName: data.agentName.present ? data.agentName.value : this.agentName,
      totalCalls: data.totalCalls.present
          ? data.totalCalls.value
          : this.totalCalls,
      successfulCalls: data.successfulCalls.present
          ? data.successfulCalls.value
          : this.successfulCalls,
      failedCalls: data.failedCalls.present
          ? data.failedCalls.value
          : this.failedCalls,
      noAnswerCalls: data.noAnswerCalls.present
          ? data.noAnswerCalls.value
          : this.noAnswerCalls,
      hangUpCalls: data.hangUpCalls.present
          ? data.hangUpCalls.value
          : this.hangUpCalls,
      totalWorkMinutes: data.totalWorkMinutes.present
          ? data.totalWorkMinutes.value
          : this.totalWorkMinutes,
      totalBreakMinutes: data.totalBreakMinutes.present
          ? data.totalBreakMinutes.value
          : this.totalBreakMinutes,
      totalCallTimeMinutes: data.totalCallTimeMinutes.present
          ? data.totalCallTimeMinutes.value
          : this.totalCallTimeMinutes,
      successRate: data.successRate.present
          ? data.successRate.value
          : this.successRate,
      averageCallDuration: data.averageCallDuration.present
          ? data.averageCallDuration.value
          : this.averageCallDuration,
      contactsProcessed: data.contactsProcessed.present
          ? data.contactsProcessed.value
          : this.contactsProcessed,
      frontendCalls: data.frontendCalls.present
          ? data.frontendCalls.value
          : this.frontendCalls,
      middlecoreCalls: data.middlecoreCalls.present
          ? data.middlecoreCalls.value
          : this.middlecoreCalls,
      hardcoreCalls: data.hardcoreCalls.present
          ? data.hardcoreCalls.value
          : this.hardcoreCalls,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatEntry(')
          ..write('id: $id, ')
          ..write('statDate: $statDate, ')
          ..write('userId: $userId, ')
          ..write('agentName: $agentName, ')
          ..write('totalCalls: $totalCalls, ')
          ..write('successfulCalls: $successfulCalls, ')
          ..write('failedCalls: $failedCalls, ')
          ..write('noAnswerCalls: $noAnswerCalls, ')
          ..write('hangUpCalls: $hangUpCalls, ')
          ..write('totalWorkMinutes: $totalWorkMinutes, ')
          ..write('totalBreakMinutes: $totalBreakMinutes, ')
          ..write('totalCallTimeMinutes: $totalCallTimeMinutes, ')
          ..write('successRate: $successRate, ')
          ..write('averageCallDuration: $averageCallDuration, ')
          ..write('contactsProcessed: $contactsProcessed, ')
          ..write('frontendCalls: $frontendCalls, ')
          ..write('middlecoreCalls: $middlecoreCalls, ')
          ..write('hardcoreCalls: $hardcoreCalls, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    statDate,
    userId,
    agentName,
    totalCalls,
    successfulCalls,
    failedCalls,
    noAnswerCalls,
    hangUpCalls,
    totalWorkMinutes,
    totalBreakMinutes,
    totalCallTimeMinutes,
    successRate,
    averageCallDuration,
    contactsProcessed,
    frontendCalls,
    middlecoreCalls,
    hardcoreCalls,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStatEntry &&
          other.id == this.id &&
          other.statDate == this.statDate &&
          other.userId == this.userId &&
          other.agentName == this.agentName &&
          other.totalCalls == this.totalCalls &&
          other.successfulCalls == this.successfulCalls &&
          other.failedCalls == this.failedCalls &&
          other.noAnswerCalls == this.noAnswerCalls &&
          other.hangUpCalls == this.hangUpCalls &&
          other.totalWorkMinutes == this.totalWorkMinutes &&
          other.totalBreakMinutes == this.totalBreakMinutes &&
          other.totalCallTimeMinutes == this.totalCallTimeMinutes &&
          other.successRate == this.successRate &&
          other.averageCallDuration == this.averageCallDuration &&
          other.contactsProcessed == this.contactsProcessed &&
          other.frontendCalls == this.frontendCalls &&
          other.middlecoreCalls == this.middlecoreCalls &&
          other.hardcoreCalls == this.hardcoreCalls &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyStatsCompanion extends UpdateCompanion<DailyStatEntry> {
  final Value<int> id;
  final Value<DateTime> statDate;
  final Value<int> userId;
  final Value<String?> agentName;
  final Value<int> totalCalls;
  final Value<int> successfulCalls;
  final Value<int> failedCalls;
  final Value<int> noAnswerCalls;
  final Value<int> hangUpCalls;
  final Value<int> totalWorkMinutes;
  final Value<int> totalBreakMinutes;
  final Value<int> totalCallTimeMinutes;
  final Value<double?> successRate;
  final Value<double?> averageCallDuration;
  final Value<int> contactsProcessed;
  final Value<int> frontendCalls;
  final Value<int> middlecoreCalls;
  final Value<int> hardcoreCalls;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DailyStatsCompanion({
    this.id = const Value.absent(),
    this.statDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.agentName = const Value.absent(),
    this.totalCalls = const Value.absent(),
    this.successfulCalls = const Value.absent(),
    this.failedCalls = const Value.absent(),
    this.noAnswerCalls = const Value.absent(),
    this.hangUpCalls = const Value.absent(),
    this.totalWorkMinutes = const Value.absent(),
    this.totalBreakMinutes = const Value.absent(),
    this.totalCallTimeMinutes = const Value.absent(),
    this.successRate = const Value.absent(),
    this.averageCallDuration = const Value.absent(),
    this.contactsProcessed = const Value.absent(),
    this.frontendCalls = const Value.absent(),
    this.middlecoreCalls = const Value.absent(),
    this.hardcoreCalls = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyStatsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime statDate,
    required int userId,
    this.agentName = const Value.absent(),
    this.totalCalls = const Value.absent(),
    this.successfulCalls = const Value.absent(),
    this.failedCalls = const Value.absent(),
    this.noAnswerCalls = const Value.absent(),
    this.hangUpCalls = const Value.absent(),
    this.totalWorkMinutes = const Value.absent(),
    this.totalBreakMinutes = const Value.absent(),
    this.totalCallTimeMinutes = const Value.absent(),
    this.successRate = const Value.absent(),
    this.averageCallDuration = const Value.absent(),
    this.contactsProcessed = const Value.absent(),
    this.frontendCalls = const Value.absent(),
    this.middlecoreCalls = const Value.absent(),
    this.hardcoreCalls = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : statDate = Value(statDate),
       userId = Value(userId);
  static Insertable<DailyStatEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? statDate,
    Expression<int>? userId,
    Expression<String>? agentName,
    Expression<int>? totalCalls,
    Expression<int>? successfulCalls,
    Expression<int>? failedCalls,
    Expression<int>? noAnswerCalls,
    Expression<int>? hangUpCalls,
    Expression<int>? totalWorkMinutes,
    Expression<int>? totalBreakMinutes,
    Expression<int>? totalCallTimeMinutes,
    Expression<double>? successRate,
    Expression<double>? averageCallDuration,
    Expression<int>? contactsProcessed,
    Expression<int>? frontendCalls,
    Expression<int>? middlecoreCalls,
    Expression<int>? hardcoreCalls,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (statDate != null) 'stat_date': statDate,
      if (userId != null) 'user_id': userId,
      if (agentName != null) 'agent_name': agentName,
      if (totalCalls != null) 'total_calls': totalCalls,
      if (successfulCalls != null) 'successful_calls': successfulCalls,
      if (failedCalls != null) 'failed_calls': failedCalls,
      if (noAnswerCalls != null) 'no_answer_calls': noAnswerCalls,
      if (hangUpCalls != null) 'hang_up_calls': hangUpCalls,
      if (totalWorkMinutes != null) 'total_work_minutes': totalWorkMinutes,
      if (totalBreakMinutes != null) 'total_break_minutes': totalBreakMinutes,
      if (totalCallTimeMinutes != null)
        'total_call_time_minutes': totalCallTimeMinutes,
      if (successRate != null) 'success_rate': successRate,
      if (averageCallDuration != null)
        'average_call_duration': averageCallDuration,
      if (contactsProcessed != null) 'contacts_processed': contactsProcessed,
      if (frontendCalls != null) 'frontend_calls': frontendCalls,
      if (middlecoreCalls != null) 'middlecore_calls': middlecoreCalls,
      if (hardcoreCalls != null) 'hardcore_calls': hardcoreCalls,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyStatsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? statDate,
    Value<int>? userId,
    Value<String?>? agentName,
    Value<int>? totalCalls,
    Value<int>? successfulCalls,
    Value<int>? failedCalls,
    Value<int>? noAnswerCalls,
    Value<int>? hangUpCalls,
    Value<int>? totalWorkMinutes,
    Value<int>? totalBreakMinutes,
    Value<int>? totalCallTimeMinutes,
    Value<double?>? successRate,
    Value<double?>? averageCallDuration,
    Value<int>? contactsProcessed,
    Value<int>? frontendCalls,
    Value<int>? middlecoreCalls,
    Value<int>? hardcoreCalls,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DailyStatsCompanion(
      id: id ?? this.id,
      statDate: statDate ?? this.statDate,
      userId: userId ?? this.userId,
      agentName: agentName ?? this.agentName,
      totalCalls: totalCalls ?? this.totalCalls,
      successfulCalls: successfulCalls ?? this.successfulCalls,
      failedCalls: failedCalls ?? this.failedCalls,
      noAnswerCalls: noAnswerCalls ?? this.noAnswerCalls,
      hangUpCalls: hangUpCalls ?? this.hangUpCalls,
      totalWorkMinutes: totalWorkMinutes ?? this.totalWorkMinutes,
      totalBreakMinutes: totalBreakMinutes ?? this.totalBreakMinutes,
      totalCallTimeMinutes: totalCallTimeMinutes ?? this.totalCallTimeMinutes,
      successRate: successRate ?? this.successRate,
      averageCallDuration: averageCallDuration ?? this.averageCallDuration,
      contactsProcessed: contactsProcessed ?? this.contactsProcessed,
      frontendCalls: frontendCalls ?? this.frontendCalls,
      middlecoreCalls: middlecoreCalls ?? this.middlecoreCalls,
      hardcoreCalls: hardcoreCalls ?? this.hardcoreCalls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (statDate.present) {
      map['stat_date'] = Variable<DateTime>(statDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (agentName.present) {
      map['agent_name'] = Variable<String>(agentName.value);
    }
    if (totalCalls.present) {
      map['total_calls'] = Variable<int>(totalCalls.value);
    }
    if (successfulCalls.present) {
      map['successful_calls'] = Variable<int>(successfulCalls.value);
    }
    if (failedCalls.present) {
      map['failed_calls'] = Variable<int>(failedCalls.value);
    }
    if (noAnswerCalls.present) {
      map['no_answer_calls'] = Variable<int>(noAnswerCalls.value);
    }
    if (hangUpCalls.present) {
      map['hang_up_calls'] = Variable<int>(hangUpCalls.value);
    }
    if (totalWorkMinutes.present) {
      map['total_work_minutes'] = Variable<int>(totalWorkMinutes.value);
    }
    if (totalBreakMinutes.present) {
      map['total_break_minutes'] = Variable<int>(totalBreakMinutes.value);
    }
    if (totalCallTimeMinutes.present) {
      map['total_call_time_minutes'] = Variable<int>(
        totalCallTimeMinutes.value,
      );
    }
    if (successRate.present) {
      map['success_rate'] = Variable<double>(successRate.value);
    }
    if (averageCallDuration.present) {
      map['average_call_duration'] = Variable<double>(
        averageCallDuration.value,
      );
    }
    if (contactsProcessed.present) {
      map['contacts_processed'] = Variable<int>(contactsProcessed.value);
    }
    if (frontendCalls.present) {
      map['frontend_calls'] = Variable<int>(frontendCalls.value);
    }
    if (middlecoreCalls.present) {
      map['middlecore_calls'] = Variable<int>(middlecoreCalls.value);
    }
    if (hardcoreCalls.present) {
      map['hardcore_calls'] = Variable<int>(hardcoreCalls.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatsCompanion(')
          ..write('id: $id, ')
          ..write('statDate: $statDate, ')
          ..write('userId: $userId, ')
          ..write('agentName: $agentName, ')
          ..write('totalCalls: $totalCalls, ')
          ..write('successfulCalls: $successfulCalls, ')
          ..write('failedCalls: $failedCalls, ')
          ..write('noAnswerCalls: $noAnswerCalls, ')
          ..write('hangUpCalls: $hangUpCalls, ')
          ..write('totalWorkMinutes: $totalWorkMinutes, ')
          ..write('totalBreakMinutes: $totalBreakMinutes, ')
          ..write('totalCallTimeMinutes: $totalCallTimeMinutes, ')
          ..write('successRate: $successRate, ')
          ..write('averageCallDuration: $averageCallDuration, ')
          ..write('contactsProcessed: $contactsProcessed, ')
          ..write('frontendCalls: $frontendCalls, ')
          ..write('middlecoreCalls: $middlecoreCalls, ')
          ..write('hardcoreCalls: $hardcoreCalls, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CallAttemptsTable extends CallAttempts
    with TableInfo<$CallAttemptsTable, CallAttemptEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callLogIdMeta = const VerificationMeta(
    'callLogId',
  );
  @override
  late final GeneratedColumn<int> callLogId = GeneratedColumn<int>(
    'call_log_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptTimeMeta = const VerificationMeta(
    'attemptTime',
  );
  @override
  late final GeneratedColumn<DateTime> attemptTime = GeneratedColumn<DateTime>(
    'attempt_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptNumberMeta = const VerificationMeta(
    'attemptNumber',
  );
  @override
  late final GeneratedColumn<int> attemptNumber = GeneratedColumn<int>(
    'attempt_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberCalledMeta = const VerificationMeta(
    'phoneNumberCalled',
  );
  @override
  late final GeneratedColumn<String> phoneNumberCalled =
      GeneratedColumn<String>(
        'phone_number_called',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 50,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _phoneTypeMeta = const VerificationMeta(
    'phoneType',
  );
  @override
  late final GeneratedColumn<String> phoneType = GeneratedColumn<String>(
    'phone_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callDurationSecondsMeta =
      const VerificationMeta('callDurationSeconds');
  @override
  late final GeneratedColumn<int> callDurationSeconds = GeneratedColumn<int>(
    'call_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptNotesMeta = const VerificationMeta(
    'attemptNotes',
  );
  @override
  late final GeneratedColumn<String> attemptNotes = GeneratedColumn<String>(
    'attempt_notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    callLogId,
    attemptTime,
    attemptNumber,
    phoneNumberCalled,
    phoneType,
    outcome,
    callDurationSeconds,
    createdAt,
    userId,
    attemptNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallAttemptEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('call_log_id')) {
      context.handle(
        _callLogIdMeta,
        callLogId.isAcceptableOrUnknown(data['call_log_id']!, _callLogIdMeta),
      );
    }
    if (data.containsKey('attempt_time')) {
      context.handle(
        _attemptTimeMeta,
        attemptTime.isAcceptableOrUnknown(
          data['attempt_time']!,
          _attemptTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptTimeMeta);
    }
    if (data.containsKey('attempt_number')) {
      context.handle(
        _attemptNumberMeta,
        attemptNumber.isAcceptableOrUnknown(
          data['attempt_number']!,
          _attemptNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptNumberMeta);
    }
    if (data.containsKey('phone_number_called')) {
      context.handle(
        _phoneNumberCalledMeta,
        phoneNumberCalled.isAcceptableOrUnknown(
          data['phone_number_called']!,
          _phoneNumberCalledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberCalledMeta);
    }
    if (data.containsKey('phone_type')) {
      context.handle(
        _phoneTypeMeta,
        phoneType.isAcceptableOrUnknown(data['phone_type']!, _phoneTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneTypeMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('call_duration_seconds')) {
      context.handle(
        _callDurationSecondsMeta,
        callDurationSeconds.isAcceptableOrUnknown(
          data['call_duration_seconds']!,
          _callDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('attempt_notes')) {
      context.handle(
        _attemptNotesMeta,
        attemptNotes.isAcceptableOrUnknown(
          data['attempt_notes']!,
          _attemptNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallAttemptEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallAttemptEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      )!,
      callLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_log_id'],
      ),
      attemptTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}attempt_time'],
      )!,
      attemptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_number'],
      )!,
      phoneNumberCalled: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number_called'],
      )!,
      phoneType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_type'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      callDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_duration_seconds'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      attemptNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_notes'],
      ),
    );
  }

  @override
  $CallAttemptsTable createAlias(String alias) {
    return $CallAttemptsTable(attachedDatabase, alias);
  }
}

class CallAttemptEntry extends DataClass
    implements Insertable<CallAttemptEntry> {
  final int id;
  final int contactId;
  final int? callLogId;
  final DateTime attemptTime;
  final int attemptNumber;
  final String phoneNumberCalled;
  final String phoneType;
  final String outcome;
  final int? callDurationSeconds;
  final DateTime createdAt;
  final int? userId;
  final String? attemptNotes;
  const CallAttemptEntry({
    required this.id,
    required this.contactId,
    this.callLogId,
    required this.attemptTime,
    required this.attemptNumber,
    required this.phoneNumberCalled,
    required this.phoneType,
    required this.outcome,
    this.callDurationSeconds,
    required this.createdAt,
    this.userId,
    this.attemptNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<int>(contactId);
    if (!nullToAbsent || callLogId != null) {
      map['call_log_id'] = Variable<int>(callLogId);
    }
    map['attempt_time'] = Variable<DateTime>(attemptTime);
    map['attempt_number'] = Variable<int>(attemptNumber);
    map['phone_number_called'] = Variable<String>(phoneNumberCalled);
    map['phone_type'] = Variable<String>(phoneType);
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || callDurationSeconds != null) {
      map['call_duration_seconds'] = Variable<int>(callDurationSeconds);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    if (!nullToAbsent || attemptNotes != null) {
      map['attempt_notes'] = Variable<String>(attemptNotes);
    }
    return map;
  }

  CallAttemptsCompanion toCompanion(bool nullToAbsent) {
    return CallAttemptsCompanion(
      id: Value(id),
      contactId: Value(contactId),
      callLogId: callLogId == null && nullToAbsent
          ? const Value.absent()
          : Value(callLogId),
      attemptTime: Value(attemptTime),
      attemptNumber: Value(attemptNumber),
      phoneNumberCalled: Value(phoneNumberCalled),
      phoneType: Value(phoneType),
      outcome: Value(outcome),
      callDurationSeconds: callDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(callDurationSeconds),
      createdAt: Value(createdAt),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      attemptNotes: attemptNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(attemptNotes),
    );
  }

  factory CallAttemptEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallAttemptEntry(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int>(json['contactId']),
      callLogId: serializer.fromJson<int?>(json['callLogId']),
      attemptTime: serializer.fromJson<DateTime>(json['attemptTime']),
      attemptNumber: serializer.fromJson<int>(json['attemptNumber']),
      phoneNumberCalled: serializer.fromJson<String>(json['phoneNumberCalled']),
      phoneType: serializer.fromJson<String>(json['phoneType']),
      outcome: serializer.fromJson<String>(json['outcome']),
      callDurationSeconds: serializer.fromJson<int?>(
        json['callDurationSeconds'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      userId: serializer.fromJson<int?>(json['userId']),
      attemptNotes: serializer.fromJson<String?>(json['attemptNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int>(contactId),
      'callLogId': serializer.toJson<int?>(callLogId),
      'attemptTime': serializer.toJson<DateTime>(attemptTime),
      'attemptNumber': serializer.toJson<int>(attemptNumber),
      'phoneNumberCalled': serializer.toJson<String>(phoneNumberCalled),
      'phoneType': serializer.toJson<String>(phoneType),
      'outcome': serializer.toJson<String>(outcome),
      'callDurationSeconds': serializer.toJson<int?>(callDurationSeconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'userId': serializer.toJson<int?>(userId),
      'attemptNotes': serializer.toJson<String?>(attemptNotes),
    };
  }

  CallAttemptEntry copyWith({
    int? id,
    int? contactId,
    Value<int?> callLogId = const Value.absent(),
    DateTime? attemptTime,
    int? attemptNumber,
    String? phoneNumberCalled,
    String? phoneType,
    String? outcome,
    Value<int?> callDurationSeconds = const Value.absent(),
    DateTime? createdAt,
    Value<int?> userId = const Value.absent(),
    Value<String?> attemptNotes = const Value.absent(),
  }) => CallAttemptEntry(
    id: id ?? this.id,
    contactId: contactId ?? this.contactId,
    callLogId: callLogId.present ? callLogId.value : this.callLogId,
    attemptTime: attemptTime ?? this.attemptTime,
    attemptNumber: attemptNumber ?? this.attemptNumber,
    phoneNumberCalled: phoneNumberCalled ?? this.phoneNumberCalled,
    phoneType: phoneType ?? this.phoneType,
    outcome: outcome ?? this.outcome,
    callDurationSeconds: callDurationSeconds.present
        ? callDurationSeconds.value
        : this.callDurationSeconds,
    createdAt: createdAt ?? this.createdAt,
    userId: userId.present ? userId.value : this.userId,
    attemptNotes: attemptNotes.present ? attemptNotes.value : this.attemptNotes,
  );
  CallAttemptEntry copyWithCompanion(CallAttemptsCompanion data) {
    return CallAttemptEntry(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      callLogId: data.callLogId.present ? data.callLogId.value : this.callLogId,
      attemptTime: data.attemptTime.present
          ? data.attemptTime.value
          : this.attemptTime,
      attemptNumber: data.attemptNumber.present
          ? data.attemptNumber.value
          : this.attemptNumber,
      phoneNumberCalled: data.phoneNumberCalled.present
          ? data.phoneNumberCalled.value
          : this.phoneNumberCalled,
      phoneType: data.phoneType.present ? data.phoneType.value : this.phoneType,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      callDurationSeconds: data.callDurationSeconds.present
          ? data.callDurationSeconds.value
          : this.callDurationSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      attemptNotes: data.attemptNotes.present
          ? data.attemptNotes.value
          : this.attemptNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallAttemptEntry(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('callLogId: $callLogId, ')
          ..write('attemptTime: $attemptTime, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('phoneNumberCalled: $phoneNumberCalled, ')
          ..write('phoneType: $phoneType, ')
          ..write('outcome: $outcome, ')
          ..write('callDurationSeconds: $callDurationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('userId: $userId, ')
          ..write('attemptNotes: $attemptNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contactId,
    callLogId,
    attemptTime,
    attemptNumber,
    phoneNumberCalled,
    phoneType,
    outcome,
    callDurationSeconds,
    createdAt,
    userId,
    attemptNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallAttemptEntry &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.callLogId == this.callLogId &&
          other.attemptTime == this.attemptTime &&
          other.attemptNumber == this.attemptNumber &&
          other.phoneNumberCalled == this.phoneNumberCalled &&
          other.phoneType == this.phoneType &&
          other.outcome == this.outcome &&
          other.callDurationSeconds == this.callDurationSeconds &&
          other.createdAt == this.createdAt &&
          other.userId == this.userId &&
          other.attemptNotes == this.attemptNotes);
}

class CallAttemptsCompanion extends UpdateCompanion<CallAttemptEntry> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<int?> callLogId;
  final Value<DateTime> attemptTime;
  final Value<int> attemptNumber;
  final Value<String> phoneNumberCalled;
  final Value<String> phoneType;
  final Value<String> outcome;
  final Value<int?> callDurationSeconds;
  final Value<DateTime> createdAt;
  final Value<int?> userId;
  final Value<String?> attemptNotes;
  const CallAttemptsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.callLogId = const Value.absent(),
    this.attemptTime = const Value.absent(),
    this.attemptNumber = const Value.absent(),
    this.phoneNumberCalled = const Value.absent(),
    this.phoneType = const Value.absent(),
    this.outcome = const Value.absent(),
    this.callDurationSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.attemptNotes = const Value.absent(),
  });
  CallAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    this.callLogId = const Value.absent(),
    required DateTime attemptTime,
    required int attemptNumber,
    required String phoneNumberCalled,
    required String phoneType,
    required String outcome,
    this.callDurationSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.attemptNotes = const Value.absent(),
  }) : contactId = Value(contactId),
       attemptTime = Value(attemptTime),
       attemptNumber = Value(attemptNumber),
       phoneNumberCalled = Value(phoneNumberCalled),
       phoneType = Value(phoneType),
       outcome = Value(outcome);
  static Insertable<CallAttemptEntry> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<int>? callLogId,
    Expression<DateTime>? attemptTime,
    Expression<int>? attemptNumber,
    Expression<String>? phoneNumberCalled,
    Expression<String>? phoneType,
    Expression<String>? outcome,
    Expression<int>? callDurationSeconds,
    Expression<DateTime>? createdAt,
    Expression<int>? userId,
    Expression<String>? attemptNotes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (callLogId != null) 'call_log_id': callLogId,
      if (attemptTime != null) 'attempt_time': attemptTime,
      if (attemptNumber != null) 'attempt_number': attemptNumber,
      if (phoneNumberCalled != null) 'phone_number_called': phoneNumberCalled,
      if (phoneType != null) 'phone_type': phoneType,
      if (outcome != null) 'outcome': outcome,
      if (callDurationSeconds != null)
        'call_duration_seconds': callDurationSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (userId != null) 'user_id': userId,
      if (attemptNotes != null) 'attempt_notes': attemptNotes,
    });
  }

  CallAttemptsCompanion copyWith({
    Value<int>? id,
    Value<int>? contactId,
    Value<int?>? callLogId,
    Value<DateTime>? attemptTime,
    Value<int>? attemptNumber,
    Value<String>? phoneNumberCalled,
    Value<String>? phoneType,
    Value<String>? outcome,
    Value<int?>? callDurationSeconds,
    Value<DateTime>? createdAt,
    Value<int?>? userId,
    Value<String?>? attemptNotes,
  }) {
    return CallAttemptsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      callLogId: callLogId ?? this.callLogId,
      attemptTime: attemptTime ?? this.attemptTime,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      phoneNumberCalled: phoneNumberCalled ?? this.phoneNumberCalled,
      phoneType: phoneType ?? this.phoneType,
      outcome: outcome ?? this.outcome,
      callDurationSeconds: callDurationSeconds ?? this.callDurationSeconds,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      attemptNotes: attemptNotes ?? this.attemptNotes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (callLogId.present) {
      map['call_log_id'] = Variable<int>(callLogId.value);
    }
    if (attemptTime.present) {
      map['attempt_time'] = Variable<DateTime>(attemptTime.value);
    }
    if (attemptNumber.present) {
      map['attempt_number'] = Variable<int>(attemptNumber.value);
    }
    if (phoneNumberCalled.present) {
      map['phone_number_called'] = Variable<String>(phoneNumberCalled.value);
    }
    if (phoneType.present) {
      map['phone_type'] = Variable<String>(phoneType.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (callDurationSeconds.present) {
      map['call_duration_seconds'] = Variable<int>(callDurationSeconds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (attemptNotes.present) {
      map['attempt_notes'] = Variable<String>(attemptNotes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('callLogId: $callLogId, ')
          ..write('attemptTime: $attemptTime, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('phoneNumberCalled: $phoneNumberCalled, ')
          ..write('phoneType: $phoneType, ')
          ..write('outcome: $outcome, ')
          ..write('callDurationSeconds: $callDurationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('userId: $userId, ')
          ..write('attemptNotes: $attemptNotes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CallLogsTable callLogs = $CallLogsTable(this);
  late final $CallContactsTable callContacts = $CallContactsTable(this);
  late final $CallSessionsTable callSessions = $CallSessionsTable(this);
  late final $BreakSessionsTable breakSessions = $BreakSessionsTable(this);
  late final $DailyStatsTable dailyStats = $DailyStatsTable(this);
  late final $CallAttemptsTable callAttempts = $CallAttemptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    callLogs,
    callContacts,
    callSessions,
    breakSessions,
    dailyStats,
    callAttempts,
  ];
}

typedef $$CallLogsTableCreateCompanionBuilder =
    CallLogsCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      Value<int?> loanId,
      required String borrowerName,
      required String borrowerPhone,
      Value<String?> coMakerName,
      Value<String?> coMakerPhone,
      required DateTime callStartTime,
      Value<DateTime?> callEndTime,
      Value<int?> callDurationSeconds,
      required String callStatus,
      Value<String?> callOutcome,
      Value<String?> notes,
      Value<String?> bucket,
      Value<int?> sessionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> userId,
      Value<String?> agentName,
      Value<bool> wasSuccessful,
      Value<bool> requiresFollowUp,
      Value<DateTime?> nextCallScheduled,
    });
typedef $$CallLogsTableUpdateCompanionBuilder =
    CallLogsCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      Value<int?> loanId,
      Value<String> borrowerName,
      Value<String> borrowerPhone,
      Value<String?> coMakerName,
      Value<String?> coMakerPhone,
      Value<DateTime> callStartTime,
      Value<DateTime?> callEndTime,
      Value<int?> callDurationSeconds,
      Value<String> callStatus,
      Value<String?> callOutcome,
      Value<String?> notes,
      Value<String?> bucket,
      Value<int?> sessionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> userId,
      Value<String?> agentName,
      Value<bool> wasSuccessful,
      Value<bool> requiresFollowUp,
      Value<DateTime?> nextCallScheduled,
    });

class $$CallLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CallLogsTable> {
  $$CallLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get borrowerName => $composableBuilder(
    column: $table.borrowerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get borrowerPhone => $composableBuilder(
    column: $table.borrowerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coMakerName => $composableBuilder(
    column: $table.coMakerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coMakerPhone => $composableBuilder(
    column: $table.coMakerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get callStartTime => $composableBuilder(
    column: $table.callStartTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get callEndTime => $composableBuilder(
    column: $table.callEndTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callDurationSeconds => $composableBuilder(
    column: $table.callDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callStatus => $composableBuilder(
    column: $table.callStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callOutcome => $composableBuilder(
    column: $table.callOutcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasSuccessful => $composableBuilder(
    column: $table.wasSuccessful,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresFollowUp => $composableBuilder(
    column: $table.requiresFollowUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextCallScheduled => $composableBuilder(
    column: $table.nextCallScheduled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CallLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallLogsTable> {
  $$CallLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borrowerName => $composableBuilder(
    column: $table.borrowerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borrowerPhone => $composableBuilder(
    column: $table.borrowerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coMakerName => $composableBuilder(
    column: $table.coMakerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coMakerPhone => $composableBuilder(
    column: $table.coMakerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get callStartTime => $composableBuilder(
    column: $table.callStartTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get callEndTime => $composableBuilder(
    column: $table.callEndTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callDurationSeconds => $composableBuilder(
    column: $table.callDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callStatus => $composableBuilder(
    column: $table.callStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callOutcome => $composableBuilder(
    column: $table.callOutcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasSuccessful => $composableBuilder(
    column: $table.wasSuccessful,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresFollowUp => $composableBuilder(
    column: $table.requiresFollowUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextCallScheduled => $composableBuilder(
    column: $table.nextCallScheduled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallLogsTable> {
  $$CallLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<int> get loanId =>
      $composableBuilder(column: $table.loanId, builder: (column) => column);

  GeneratedColumn<String> get borrowerName => $composableBuilder(
    column: $table.borrowerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get borrowerPhone => $composableBuilder(
    column: $table.borrowerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coMakerName => $composableBuilder(
    column: $table.coMakerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coMakerPhone => $composableBuilder(
    column: $table.coMakerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get callStartTime => $composableBuilder(
    column: $table.callStartTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get callEndTime => $composableBuilder(
    column: $table.callEndTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get callDurationSeconds => $composableBuilder(
    column: $table.callDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get callStatus => $composableBuilder(
    column: $table.callStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get callOutcome => $composableBuilder(
    column: $table.callOutcome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get agentName =>
      $composableBuilder(column: $table.agentName, builder: (column) => column);

  GeneratedColumn<bool> get wasSuccessful => $composableBuilder(
    column: $table.wasSuccessful,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requiresFollowUp => $composableBuilder(
    column: $table.requiresFollowUp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextCallScheduled => $composableBuilder(
    column: $table.nextCallScheduled,
    builder: (column) => column,
  );
}

class $$CallLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallLogsTable,
          CallLogEntry,
          $$CallLogsTableFilterComposer,
          $$CallLogsTableOrderingComposer,
          $$CallLogsTableAnnotationComposer,
          $$CallLogsTableCreateCompanionBuilder,
          $$CallLogsTableUpdateCompanionBuilder,
          (
            CallLogEntry,
            BaseReferences<_$AppDatabase, $CallLogsTable, CallLogEntry>,
          ),
          CallLogEntry,
          PrefetchHooks Function()
        > {
  $$CallLogsTableTableManager(_$AppDatabase db, $CallLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                Value<int?> loanId = const Value.absent(),
                Value<String> borrowerName = const Value.absent(),
                Value<String> borrowerPhone = const Value.absent(),
                Value<String?> coMakerName = const Value.absent(),
                Value<String?> coMakerPhone = const Value.absent(),
                Value<DateTime> callStartTime = const Value.absent(),
                Value<DateTime?> callEndTime = const Value.absent(),
                Value<int?> callDurationSeconds = const Value.absent(),
                Value<String> callStatus = const Value.absent(),
                Value<String?> callOutcome = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> bucket = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String?> agentName = const Value.absent(),
                Value<bool> wasSuccessful = const Value.absent(),
                Value<bool> requiresFollowUp = const Value.absent(),
                Value<DateTime?> nextCallScheduled = const Value.absent(),
              }) => CallLogsCompanion(
                id: id,
                contactId: contactId,
                loanId: loanId,
                borrowerName: borrowerName,
                borrowerPhone: borrowerPhone,
                coMakerName: coMakerName,
                coMakerPhone: coMakerPhone,
                callStartTime: callStartTime,
                callEndTime: callEndTime,
                callDurationSeconds: callDurationSeconds,
                callStatus: callStatus,
                callOutcome: callOutcome,
                notes: notes,
                bucket: bucket,
                sessionId: sessionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                userId: userId,
                agentName: agentName,
                wasSuccessful: wasSuccessful,
                requiresFollowUp: requiresFollowUp,
                nextCallScheduled: nextCallScheduled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                Value<int?> loanId = const Value.absent(),
                required String borrowerName,
                required String borrowerPhone,
                Value<String?> coMakerName = const Value.absent(),
                Value<String?> coMakerPhone = const Value.absent(),
                required DateTime callStartTime,
                Value<DateTime?> callEndTime = const Value.absent(),
                Value<int?> callDurationSeconds = const Value.absent(),
                required String callStatus,
                Value<String?> callOutcome = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> bucket = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String?> agentName = const Value.absent(),
                Value<bool> wasSuccessful = const Value.absent(),
                Value<bool> requiresFollowUp = const Value.absent(),
                Value<DateTime?> nextCallScheduled = const Value.absent(),
              }) => CallLogsCompanion.insert(
                id: id,
                contactId: contactId,
                loanId: loanId,
                borrowerName: borrowerName,
                borrowerPhone: borrowerPhone,
                coMakerName: coMakerName,
                coMakerPhone: coMakerPhone,
                callStartTime: callStartTime,
                callEndTime: callEndTime,
                callDurationSeconds: callDurationSeconds,
                callStatus: callStatus,
                callOutcome: callOutcome,
                notes: notes,
                bucket: bucket,
                sessionId: sessionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                userId: userId,
                agentName: agentName,
                wasSuccessful: wasSuccessful,
                requiresFollowUp: requiresFollowUp,
                nextCallScheduled: nextCallScheduled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CallLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallLogsTable,
      CallLogEntry,
      $$CallLogsTableFilterComposer,
      $$CallLogsTableOrderingComposer,
      $$CallLogsTableAnnotationComposer,
      $$CallLogsTableCreateCompanionBuilder,
      $$CallLogsTableUpdateCompanionBuilder,
      (
        CallLogEntry,
        BaseReferences<_$AppDatabase, $CallLogsTable, CallLogEntry>,
      ),
      CallLogEntry,
      PrefetchHooks Function()
    >;
typedef $$CallContactsTableCreateCompanionBuilder =
    CallContactsCompanion Function({
      Value<int> id,
      Value<int?> loanId,
      required String borrowerName,
      required String borrowerPhone,
      Value<String?> coMakerName,
      Value<String?> coMakerPhone,
      Value<String> status,
      Value<String?> bucket,
      Value<int> priority,
      Value<DateTime?> lastCallDate,
      Value<String?> lastCallStatus,
      Value<int> callAttempts,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> assignedUserId,
      Value<DateTime?> assignedAt,
      Value<String?> notes,
      Value<bool> isActive,
      Value<bool> doNotCall,
    });
typedef $$CallContactsTableUpdateCompanionBuilder =
    CallContactsCompanion Function({
      Value<int> id,
      Value<int?> loanId,
      Value<String> borrowerName,
      Value<String> borrowerPhone,
      Value<String?> coMakerName,
      Value<String?> coMakerPhone,
      Value<String> status,
      Value<String?> bucket,
      Value<int> priority,
      Value<DateTime?> lastCallDate,
      Value<String?> lastCallStatus,
      Value<int> callAttempts,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> assignedUserId,
      Value<DateTime?> assignedAt,
      Value<String?> notes,
      Value<bool> isActive,
      Value<bool> doNotCall,
    });

class $$CallContactsTableFilterComposer
    extends Composer<_$AppDatabase, $CallContactsTable> {
  $$CallContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get borrowerName => $composableBuilder(
    column: $table.borrowerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get borrowerPhone => $composableBuilder(
    column: $table.borrowerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coMakerName => $composableBuilder(
    column: $table.coMakerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coMakerPhone => $composableBuilder(
    column: $table.coMakerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCallDate => $composableBuilder(
    column: $table.lastCallDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastCallStatus => $composableBuilder(
    column: $table.lastCallStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callAttempts => $composableBuilder(
    column: $table.callAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get assignedUserId => $composableBuilder(
    column: $table.assignedUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get doNotCall => $composableBuilder(
    column: $table.doNotCall,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CallContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallContactsTable> {
  $$CallContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borrowerName => $composableBuilder(
    column: $table.borrowerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borrowerPhone => $composableBuilder(
    column: $table.borrowerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coMakerName => $composableBuilder(
    column: $table.coMakerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coMakerPhone => $composableBuilder(
    column: $table.coMakerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCallDate => $composableBuilder(
    column: $table.lastCallDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastCallStatus => $composableBuilder(
    column: $table.lastCallStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callAttempts => $composableBuilder(
    column: $table.callAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get assignedUserId => $composableBuilder(
    column: $table.assignedUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get doNotCall => $composableBuilder(
    column: $table.doNotCall,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallContactsTable> {
  $$CallContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get loanId =>
      $composableBuilder(column: $table.loanId, builder: (column) => column);

  GeneratedColumn<String> get borrowerName => $composableBuilder(
    column: $table.borrowerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get borrowerPhone => $composableBuilder(
    column: $table.borrowerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coMakerName => $composableBuilder(
    column: $table.coMakerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coMakerPhone => $composableBuilder(
    column: $table.coMakerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCallDate => $composableBuilder(
    column: $table.lastCallDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastCallStatus => $composableBuilder(
    column: $table.lastCallStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get callAttempts => $composableBuilder(
    column: $table.callAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get assignedUserId => $composableBuilder(
    column: $table.assignedUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get doNotCall =>
      $composableBuilder(column: $table.doNotCall, builder: (column) => column);
}

class $$CallContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallContactsTable,
          CallContactEntry,
          $$CallContactsTableFilterComposer,
          $$CallContactsTableOrderingComposer,
          $$CallContactsTableAnnotationComposer,
          $$CallContactsTableCreateCompanionBuilder,
          $$CallContactsTableUpdateCompanionBuilder,
          (
            CallContactEntry,
            BaseReferences<_$AppDatabase, $CallContactsTable, CallContactEntry>,
          ),
          CallContactEntry,
          PrefetchHooks Function()
        > {
  $$CallContactsTableTableManager(_$AppDatabase db, $CallContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> loanId = const Value.absent(),
                Value<String> borrowerName = const Value.absent(),
                Value<String> borrowerPhone = const Value.absent(),
                Value<String?> coMakerName = const Value.absent(),
                Value<String?> coMakerPhone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> bucket = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> lastCallDate = const Value.absent(),
                Value<String?> lastCallStatus = const Value.absent(),
                Value<int> callAttempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> assignedUserId = const Value.absent(),
                Value<DateTime?> assignedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> doNotCall = const Value.absent(),
              }) => CallContactsCompanion(
                id: id,
                loanId: loanId,
                borrowerName: borrowerName,
                borrowerPhone: borrowerPhone,
                coMakerName: coMakerName,
                coMakerPhone: coMakerPhone,
                status: status,
                bucket: bucket,
                priority: priority,
                lastCallDate: lastCallDate,
                lastCallStatus: lastCallStatus,
                callAttempts: callAttempts,
                createdAt: createdAt,
                updatedAt: updatedAt,
                assignedUserId: assignedUserId,
                assignedAt: assignedAt,
                notes: notes,
                isActive: isActive,
                doNotCall: doNotCall,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> loanId = const Value.absent(),
                required String borrowerName,
                required String borrowerPhone,
                Value<String?> coMakerName = const Value.absent(),
                Value<String?> coMakerPhone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> bucket = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> lastCallDate = const Value.absent(),
                Value<String?> lastCallStatus = const Value.absent(),
                Value<int> callAttempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> assignedUserId = const Value.absent(),
                Value<DateTime?> assignedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> doNotCall = const Value.absent(),
              }) => CallContactsCompanion.insert(
                id: id,
                loanId: loanId,
                borrowerName: borrowerName,
                borrowerPhone: borrowerPhone,
                coMakerName: coMakerName,
                coMakerPhone: coMakerPhone,
                status: status,
                bucket: bucket,
                priority: priority,
                lastCallDate: lastCallDate,
                lastCallStatus: lastCallStatus,
                callAttempts: callAttempts,
                createdAt: createdAt,
                updatedAt: updatedAt,
                assignedUserId: assignedUserId,
                assignedAt: assignedAt,
                notes: notes,
                isActive: isActive,
                doNotCall: doNotCall,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CallContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallContactsTable,
      CallContactEntry,
      $$CallContactsTableFilterComposer,
      $$CallContactsTableOrderingComposer,
      $$CallContactsTableAnnotationComposer,
      $$CallContactsTableCreateCompanionBuilder,
      $$CallContactsTableUpdateCompanionBuilder,
      (
        CallContactEntry,
        BaseReferences<_$AppDatabase, $CallContactsTable, CallContactEntry>,
      ),
      CallContactEntry,
      PrefetchHooks Function()
    >;
typedef $$CallSessionsTableCreateCompanionBuilder =
    CallSessionsCompanion Function({
      Value<int> id,
      required DateTime sessionStart,
      Value<DateTime?> sessionEnd,
      Value<int?> sessionDurationMinutes,
      required int userId,
      Value<String?> agentName,
      Value<String?> bucket,
      Value<int> totalContacts,
      Value<int> contactsAttempted,
      Value<int> contactsCompleted,
      Value<int> successfulCalls,
      Value<int> failedCalls,
      Value<int> noAnswerCalls,
      Value<int> hangUpCalls,
      required String sessionType,
      Value<bool> wasCompleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<double?> successRate,
      Value<int?> averageCallDurationSeconds,
      Value<String?> sessionNotes,
    });
typedef $$CallSessionsTableUpdateCompanionBuilder =
    CallSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> sessionStart,
      Value<DateTime?> sessionEnd,
      Value<int?> sessionDurationMinutes,
      Value<int> userId,
      Value<String?> agentName,
      Value<String?> bucket,
      Value<int> totalContacts,
      Value<int> contactsAttempted,
      Value<int> contactsCompleted,
      Value<int> successfulCalls,
      Value<int> failedCalls,
      Value<int> noAnswerCalls,
      Value<int> hangUpCalls,
      Value<String> sessionType,
      Value<bool> wasCompleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<double?> successRate,
      Value<int?> averageCallDurationSeconds,
      Value<String?> sessionNotes,
    });

class $$CallSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $CallSessionsTable> {
  $$CallSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sessionStart => $composableBuilder(
    column: $table.sessionStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sessionEnd => $composableBuilder(
    column: $table.sessionEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionDurationMinutes => $composableBuilder(
    column: $table.sessionDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalContacts => $composableBuilder(
    column: $table.totalContacts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contactsAttempted => $composableBuilder(
    column: $table.contactsAttempted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contactsCompleted => $composableBuilder(
    column: $table.contactsCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get successfulCalls => $composableBuilder(
    column: $table.successfulCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCalls => $composableBuilder(
    column: $table.failedCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get noAnswerCalls => $composableBuilder(
    column: $table.noAnswerCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hangUpCalls => $composableBuilder(
    column: $table.hangUpCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasCompleted => $composableBuilder(
    column: $table.wasCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get successRate => $composableBuilder(
    column: $table.successRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get averageCallDurationSeconds => $composableBuilder(
    column: $table.averageCallDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CallSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallSessionsTable> {
  $$CallSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sessionStart => $composableBuilder(
    column: $table.sessionStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sessionEnd => $composableBuilder(
    column: $table.sessionEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionDurationMinutes => $composableBuilder(
    column: $table.sessionDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalContacts => $composableBuilder(
    column: $table.totalContacts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactsAttempted => $composableBuilder(
    column: $table.contactsAttempted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactsCompleted => $composableBuilder(
    column: $table.contactsCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get successfulCalls => $composableBuilder(
    column: $table.successfulCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCalls => $composableBuilder(
    column: $table.failedCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get noAnswerCalls => $composableBuilder(
    column: $table.noAnswerCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hangUpCalls => $composableBuilder(
    column: $table.hangUpCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasCompleted => $composableBuilder(
    column: $table.wasCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get successRate => $composableBuilder(
    column: $table.successRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get averageCallDurationSeconds => $composableBuilder(
    column: $table.averageCallDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallSessionsTable> {
  $$CallSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get sessionStart => $composableBuilder(
    column: $table.sessionStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get sessionEnd => $composableBuilder(
    column: $table.sessionEnd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionDurationMinutes => $composableBuilder(
    column: $table.sessionDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get agentName =>
      $composableBuilder(column: $table.agentName, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<int> get totalContacts => $composableBuilder(
    column: $table.totalContacts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contactsAttempted => $composableBuilder(
    column: $table.contactsAttempted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contactsCompleted => $composableBuilder(
    column: $table.contactsCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get successfulCalls => $composableBuilder(
    column: $table.successfulCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedCalls => $composableBuilder(
    column: $table.failedCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get noAnswerCalls => $composableBuilder(
    column: $table.noAnswerCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hangUpCalls => $composableBuilder(
    column: $table.hangUpCalls,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasCompleted => $composableBuilder(
    column: $table.wasCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<double> get successRate => $composableBuilder(
    column: $table.successRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get averageCallDurationSeconds => $composableBuilder(
    column: $table.averageCallDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => column,
  );
}

class $$CallSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallSessionsTable,
          CallSessionEntry,
          $$CallSessionsTableFilterComposer,
          $$CallSessionsTableOrderingComposer,
          $$CallSessionsTableAnnotationComposer,
          $$CallSessionsTableCreateCompanionBuilder,
          $$CallSessionsTableUpdateCompanionBuilder,
          (
            CallSessionEntry,
            BaseReferences<_$AppDatabase, $CallSessionsTable, CallSessionEntry>,
          ),
          CallSessionEntry,
          PrefetchHooks Function()
        > {
  $$CallSessionsTableTableManager(_$AppDatabase db, $CallSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> sessionStart = const Value.absent(),
                Value<DateTime?> sessionEnd = const Value.absent(),
                Value<int?> sessionDurationMinutes = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String?> agentName = const Value.absent(),
                Value<String?> bucket = const Value.absent(),
                Value<int> totalContacts = const Value.absent(),
                Value<int> contactsAttempted = const Value.absent(),
                Value<int> contactsCompleted = const Value.absent(),
                Value<int> successfulCalls = const Value.absent(),
                Value<int> failedCalls = const Value.absent(),
                Value<int> noAnswerCalls = const Value.absent(),
                Value<int> hangUpCalls = const Value.absent(),
                Value<String> sessionType = const Value.absent(),
                Value<bool> wasCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<double?> successRate = const Value.absent(),
                Value<int?> averageCallDurationSeconds = const Value.absent(),
                Value<String?> sessionNotes = const Value.absent(),
              }) => CallSessionsCompanion(
                id: id,
                sessionStart: sessionStart,
                sessionEnd: sessionEnd,
                sessionDurationMinutes: sessionDurationMinutes,
                userId: userId,
                agentName: agentName,
                bucket: bucket,
                totalContacts: totalContacts,
                contactsAttempted: contactsAttempted,
                contactsCompleted: contactsCompleted,
                successfulCalls: successfulCalls,
                failedCalls: failedCalls,
                noAnswerCalls: noAnswerCalls,
                hangUpCalls: hangUpCalls,
                sessionType: sessionType,
                wasCompleted: wasCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                successRate: successRate,
                averageCallDurationSeconds: averageCallDurationSeconds,
                sessionNotes: sessionNotes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime sessionStart,
                Value<DateTime?> sessionEnd = const Value.absent(),
                Value<int?> sessionDurationMinutes = const Value.absent(),
                required int userId,
                Value<String?> agentName = const Value.absent(),
                Value<String?> bucket = const Value.absent(),
                Value<int> totalContacts = const Value.absent(),
                Value<int> contactsAttempted = const Value.absent(),
                Value<int> contactsCompleted = const Value.absent(),
                Value<int> successfulCalls = const Value.absent(),
                Value<int> failedCalls = const Value.absent(),
                Value<int> noAnswerCalls = const Value.absent(),
                Value<int> hangUpCalls = const Value.absent(),
                required String sessionType,
                Value<bool> wasCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<double?> successRate = const Value.absent(),
                Value<int?> averageCallDurationSeconds = const Value.absent(),
                Value<String?> sessionNotes = const Value.absent(),
              }) => CallSessionsCompanion.insert(
                id: id,
                sessionStart: sessionStart,
                sessionEnd: sessionEnd,
                sessionDurationMinutes: sessionDurationMinutes,
                userId: userId,
                agentName: agentName,
                bucket: bucket,
                totalContacts: totalContacts,
                contactsAttempted: contactsAttempted,
                contactsCompleted: contactsCompleted,
                successfulCalls: successfulCalls,
                failedCalls: failedCalls,
                noAnswerCalls: noAnswerCalls,
                hangUpCalls: hangUpCalls,
                sessionType: sessionType,
                wasCompleted: wasCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                successRate: successRate,
                averageCallDurationSeconds: averageCallDurationSeconds,
                sessionNotes: sessionNotes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CallSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallSessionsTable,
      CallSessionEntry,
      $$CallSessionsTableFilterComposer,
      $$CallSessionsTableOrderingComposer,
      $$CallSessionsTableAnnotationComposer,
      $$CallSessionsTableCreateCompanionBuilder,
      $$CallSessionsTableUpdateCompanionBuilder,
      (
        CallSessionEntry,
        BaseReferences<_$AppDatabase, $CallSessionsTable, CallSessionEntry>,
      ),
      CallSessionEntry,
      PrefetchHooks Function()
    >;
typedef $$BreakSessionsTableCreateCompanionBuilder =
    BreakSessionsCompanion Function({
      Value<int> id,
      required DateTime breakStart,
      Value<DateTime?> breakEnd,
      Value<int?> breakDurationMinutes,
      required String breakType,
      Value<String?> breakReason,
      required int userId,
      Value<String?> agentName,
      Value<DateTime> createdAt,
      Value<int?> callSessionId,
    });
typedef $$BreakSessionsTableUpdateCompanionBuilder =
    BreakSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> breakStart,
      Value<DateTime?> breakEnd,
      Value<int?> breakDurationMinutes,
      Value<String> breakType,
      Value<String?> breakReason,
      Value<int> userId,
      Value<String?> agentName,
      Value<DateTime> createdAt,
      Value<int?> callSessionId,
    });

class $$BreakSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $BreakSessionsTable> {
  $$BreakSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get breakStart => $composableBuilder(
    column: $table.breakStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get breakEnd => $composableBuilder(
    column: $table.breakEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakDurationMinutes => $composableBuilder(
    column: $table.breakDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breakType => $composableBuilder(
    column: $table.breakType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breakReason => $composableBuilder(
    column: $table.breakReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callSessionId => $composableBuilder(
    column: $table.callSessionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BreakSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $BreakSessionsTable> {
  $$BreakSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get breakStart => $composableBuilder(
    column: $table.breakStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get breakEnd => $composableBuilder(
    column: $table.breakEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakDurationMinutes => $composableBuilder(
    column: $table.breakDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breakType => $composableBuilder(
    column: $table.breakType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breakReason => $composableBuilder(
    column: $table.breakReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callSessionId => $composableBuilder(
    column: $table.callSessionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BreakSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BreakSessionsTable> {
  $$BreakSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get breakStart => $composableBuilder(
    column: $table.breakStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get breakEnd =>
      $composableBuilder(column: $table.breakEnd, builder: (column) => column);

  GeneratedColumn<int> get breakDurationMinutes => $composableBuilder(
    column: $table.breakDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get breakType =>
      $composableBuilder(column: $table.breakType, builder: (column) => column);

  GeneratedColumn<String> get breakReason => $composableBuilder(
    column: $table.breakReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get agentName =>
      $composableBuilder(column: $table.agentName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get callSessionId => $composableBuilder(
    column: $table.callSessionId,
    builder: (column) => column,
  );
}

class $$BreakSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BreakSessionsTable,
          BreakSessionEntry,
          $$BreakSessionsTableFilterComposer,
          $$BreakSessionsTableOrderingComposer,
          $$BreakSessionsTableAnnotationComposer,
          $$BreakSessionsTableCreateCompanionBuilder,
          $$BreakSessionsTableUpdateCompanionBuilder,
          (
            BreakSessionEntry,
            BaseReferences<
              _$AppDatabase,
              $BreakSessionsTable,
              BreakSessionEntry
            >,
          ),
          BreakSessionEntry,
          PrefetchHooks Function()
        > {
  $$BreakSessionsTableTableManager(_$AppDatabase db, $BreakSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BreakSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BreakSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BreakSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> breakStart = const Value.absent(),
                Value<DateTime?> breakEnd = const Value.absent(),
                Value<int?> breakDurationMinutes = const Value.absent(),
                Value<String> breakType = const Value.absent(),
                Value<String?> breakReason = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String?> agentName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> callSessionId = const Value.absent(),
              }) => BreakSessionsCompanion(
                id: id,
                breakStart: breakStart,
                breakEnd: breakEnd,
                breakDurationMinutes: breakDurationMinutes,
                breakType: breakType,
                breakReason: breakReason,
                userId: userId,
                agentName: agentName,
                createdAt: createdAt,
                callSessionId: callSessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime breakStart,
                Value<DateTime?> breakEnd = const Value.absent(),
                Value<int?> breakDurationMinutes = const Value.absent(),
                required String breakType,
                Value<String?> breakReason = const Value.absent(),
                required int userId,
                Value<String?> agentName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> callSessionId = const Value.absent(),
              }) => BreakSessionsCompanion.insert(
                id: id,
                breakStart: breakStart,
                breakEnd: breakEnd,
                breakDurationMinutes: breakDurationMinutes,
                breakType: breakType,
                breakReason: breakReason,
                userId: userId,
                agentName: agentName,
                createdAt: createdAt,
                callSessionId: callSessionId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BreakSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BreakSessionsTable,
      BreakSessionEntry,
      $$BreakSessionsTableFilterComposer,
      $$BreakSessionsTableOrderingComposer,
      $$BreakSessionsTableAnnotationComposer,
      $$BreakSessionsTableCreateCompanionBuilder,
      $$BreakSessionsTableUpdateCompanionBuilder,
      (
        BreakSessionEntry,
        BaseReferences<_$AppDatabase, $BreakSessionsTable, BreakSessionEntry>,
      ),
      BreakSessionEntry,
      PrefetchHooks Function()
    >;
typedef $$DailyStatsTableCreateCompanionBuilder =
    DailyStatsCompanion Function({
      Value<int> id,
      required DateTime statDate,
      required int userId,
      Value<String?> agentName,
      Value<int> totalCalls,
      Value<int> successfulCalls,
      Value<int> failedCalls,
      Value<int> noAnswerCalls,
      Value<int> hangUpCalls,
      Value<int> totalWorkMinutes,
      Value<int> totalBreakMinutes,
      Value<int> totalCallTimeMinutes,
      Value<double?> successRate,
      Value<double?> averageCallDuration,
      Value<int> contactsProcessed,
      Value<int> frontendCalls,
      Value<int> middlecoreCalls,
      Value<int> hardcoreCalls,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$DailyStatsTableUpdateCompanionBuilder =
    DailyStatsCompanion Function({
      Value<int> id,
      Value<DateTime> statDate,
      Value<int> userId,
      Value<String?> agentName,
      Value<int> totalCalls,
      Value<int> successfulCalls,
      Value<int> failedCalls,
      Value<int> noAnswerCalls,
      Value<int> hangUpCalls,
      Value<int> totalWorkMinutes,
      Value<int> totalBreakMinutes,
      Value<int> totalCallTimeMinutes,
      Value<double?> successRate,
      Value<double?> averageCallDuration,
      Value<int> contactsProcessed,
      Value<int> frontendCalls,
      Value<int> middlecoreCalls,
      Value<int> hardcoreCalls,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$DailyStatsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get statDate => $composableBuilder(
    column: $table.statDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCalls => $composableBuilder(
    column: $table.totalCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get successfulCalls => $composableBuilder(
    column: $table.successfulCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCalls => $composableBuilder(
    column: $table.failedCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get noAnswerCalls => $composableBuilder(
    column: $table.noAnswerCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hangUpCalls => $composableBuilder(
    column: $table.hangUpCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWorkMinutes => $composableBuilder(
    column: $table.totalWorkMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBreakMinutes => $composableBuilder(
    column: $table.totalBreakMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCallTimeMinutes => $composableBuilder(
    column: $table.totalCallTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get successRate => $composableBuilder(
    column: $table.successRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageCallDuration => $composableBuilder(
    column: $table.averageCallDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contactsProcessed => $composableBuilder(
    column: $table.contactsProcessed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frontendCalls => $composableBuilder(
    column: $table.frontendCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get middlecoreCalls => $composableBuilder(
    column: $table.middlecoreCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hardcoreCalls => $composableBuilder(
    column: $table.hardcoreCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get statDate => $composableBuilder(
    column: $table.statDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCalls => $composableBuilder(
    column: $table.totalCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get successfulCalls => $composableBuilder(
    column: $table.successfulCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCalls => $composableBuilder(
    column: $table.failedCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get noAnswerCalls => $composableBuilder(
    column: $table.noAnswerCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hangUpCalls => $composableBuilder(
    column: $table.hangUpCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWorkMinutes => $composableBuilder(
    column: $table.totalWorkMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBreakMinutes => $composableBuilder(
    column: $table.totalBreakMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCallTimeMinutes => $composableBuilder(
    column: $table.totalCallTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get successRate => $composableBuilder(
    column: $table.successRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageCallDuration => $composableBuilder(
    column: $table.averageCallDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactsProcessed => $composableBuilder(
    column: $table.contactsProcessed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frontendCalls => $composableBuilder(
    column: $table.frontendCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get middlecoreCalls => $composableBuilder(
    column: $table.middlecoreCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hardcoreCalls => $composableBuilder(
    column: $table.hardcoreCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get statDate =>
      $composableBuilder(column: $table.statDate, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get agentName =>
      $composableBuilder(column: $table.agentName, builder: (column) => column);

  GeneratedColumn<int> get totalCalls => $composableBuilder(
    column: $table.totalCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get successfulCalls => $composableBuilder(
    column: $table.successfulCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedCalls => $composableBuilder(
    column: $table.failedCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get noAnswerCalls => $composableBuilder(
    column: $table.noAnswerCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hangUpCalls => $composableBuilder(
    column: $table.hangUpCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalWorkMinutes => $composableBuilder(
    column: $table.totalWorkMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBreakMinutes => $composableBuilder(
    column: $table.totalBreakMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCallTimeMinutes => $composableBuilder(
    column: $table.totalCallTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get successRate => $composableBuilder(
    column: $table.successRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageCallDuration => $composableBuilder(
    column: $table.averageCallDuration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contactsProcessed => $composableBuilder(
    column: $table.contactsProcessed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frontendCalls => $composableBuilder(
    column: $table.frontendCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get middlecoreCalls => $composableBuilder(
    column: $table.middlecoreCalls,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hardcoreCalls => $composableBuilder(
    column: $table.hardcoreCalls,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyStatsTable,
          DailyStatEntry,
          $$DailyStatsTableFilterComposer,
          $$DailyStatsTableOrderingComposer,
          $$DailyStatsTableAnnotationComposer,
          $$DailyStatsTableCreateCompanionBuilder,
          $$DailyStatsTableUpdateCompanionBuilder,
          (
            DailyStatEntry,
            BaseReferences<_$AppDatabase, $DailyStatsTable, DailyStatEntry>,
          ),
          DailyStatEntry,
          PrefetchHooks Function()
        > {
  $$DailyStatsTableTableManager(_$AppDatabase db, $DailyStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> statDate = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String?> agentName = const Value.absent(),
                Value<int> totalCalls = const Value.absent(),
                Value<int> successfulCalls = const Value.absent(),
                Value<int> failedCalls = const Value.absent(),
                Value<int> noAnswerCalls = const Value.absent(),
                Value<int> hangUpCalls = const Value.absent(),
                Value<int> totalWorkMinutes = const Value.absent(),
                Value<int> totalBreakMinutes = const Value.absent(),
                Value<int> totalCallTimeMinutes = const Value.absent(),
                Value<double?> successRate = const Value.absent(),
                Value<double?> averageCallDuration = const Value.absent(),
                Value<int> contactsProcessed = const Value.absent(),
                Value<int> frontendCalls = const Value.absent(),
                Value<int> middlecoreCalls = const Value.absent(),
                Value<int> hardcoreCalls = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyStatsCompanion(
                id: id,
                statDate: statDate,
                userId: userId,
                agentName: agentName,
                totalCalls: totalCalls,
                successfulCalls: successfulCalls,
                failedCalls: failedCalls,
                noAnswerCalls: noAnswerCalls,
                hangUpCalls: hangUpCalls,
                totalWorkMinutes: totalWorkMinutes,
                totalBreakMinutes: totalBreakMinutes,
                totalCallTimeMinutes: totalCallTimeMinutes,
                successRate: successRate,
                averageCallDuration: averageCallDuration,
                contactsProcessed: contactsProcessed,
                frontendCalls: frontendCalls,
                middlecoreCalls: middlecoreCalls,
                hardcoreCalls: hardcoreCalls,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime statDate,
                required int userId,
                Value<String?> agentName = const Value.absent(),
                Value<int> totalCalls = const Value.absent(),
                Value<int> successfulCalls = const Value.absent(),
                Value<int> failedCalls = const Value.absent(),
                Value<int> noAnswerCalls = const Value.absent(),
                Value<int> hangUpCalls = const Value.absent(),
                Value<int> totalWorkMinutes = const Value.absent(),
                Value<int> totalBreakMinutes = const Value.absent(),
                Value<int> totalCallTimeMinutes = const Value.absent(),
                Value<double?> successRate = const Value.absent(),
                Value<double?> averageCallDuration = const Value.absent(),
                Value<int> contactsProcessed = const Value.absent(),
                Value<int> frontendCalls = const Value.absent(),
                Value<int> middlecoreCalls = const Value.absent(),
                Value<int> hardcoreCalls = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyStatsCompanion.insert(
                id: id,
                statDate: statDate,
                userId: userId,
                agentName: agentName,
                totalCalls: totalCalls,
                successfulCalls: successfulCalls,
                failedCalls: failedCalls,
                noAnswerCalls: noAnswerCalls,
                hangUpCalls: hangUpCalls,
                totalWorkMinutes: totalWorkMinutes,
                totalBreakMinutes: totalBreakMinutes,
                totalCallTimeMinutes: totalCallTimeMinutes,
                successRate: successRate,
                averageCallDuration: averageCallDuration,
                contactsProcessed: contactsProcessed,
                frontendCalls: frontendCalls,
                middlecoreCalls: middlecoreCalls,
                hardcoreCalls: hardcoreCalls,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyStatsTable,
      DailyStatEntry,
      $$DailyStatsTableFilterComposer,
      $$DailyStatsTableOrderingComposer,
      $$DailyStatsTableAnnotationComposer,
      $$DailyStatsTableCreateCompanionBuilder,
      $$DailyStatsTableUpdateCompanionBuilder,
      (
        DailyStatEntry,
        BaseReferences<_$AppDatabase, $DailyStatsTable, DailyStatEntry>,
      ),
      DailyStatEntry,
      PrefetchHooks Function()
    >;
typedef $$CallAttemptsTableCreateCompanionBuilder =
    CallAttemptsCompanion Function({
      Value<int> id,
      required int contactId,
      Value<int?> callLogId,
      required DateTime attemptTime,
      required int attemptNumber,
      required String phoneNumberCalled,
      required String phoneType,
      required String outcome,
      Value<int?> callDurationSeconds,
      Value<DateTime> createdAt,
      Value<int?> userId,
      Value<String?> attemptNotes,
    });
typedef $$CallAttemptsTableUpdateCompanionBuilder =
    CallAttemptsCompanion Function({
      Value<int> id,
      Value<int> contactId,
      Value<int?> callLogId,
      Value<DateTime> attemptTime,
      Value<int> attemptNumber,
      Value<String> phoneNumberCalled,
      Value<String> phoneType,
      Value<String> outcome,
      Value<int?> callDurationSeconds,
      Value<DateTime> createdAt,
      Value<int?> userId,
      Value<String?> attemptNotes,
    });

class $$CallAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $CallAttemptsTable> {
  $$CallAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callLogId => $composableBuilder(
    column: $table.callLogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get attemptTime => $composableBuilder(
    column: $table.attemptTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumberCalled => $composableBuilder(
    column: $table.phoneNumberCalled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneType => $composableBuilder(
    column: $table.phoneType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callDurationSeconds => $composableBuilder(
    column: $table.callDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attemptNotes => $composableBuilder(
    column: $table.attemptNotes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CallAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallAttemptsTable> {
  $$CallAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callLogId => $composableBuilder(
    column: $table.callLogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get attemptTime => $composableBuilder(
    column: $table.attemptTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumberCalled => $composableBuilder(
    column: $table.phoneNumberCalled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneType => $composableBuilder(
    column: $table.phoneType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callDurationSeconds => $composableBuilder(
    column: $table.callDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attemptNotes => $composableBuilder(
    column: $table.attemptNotes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallAttemptsTable> {
  $$CallAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<int> get callLogId =>
      $composableBuilder(column: $table.callLogId, builder: (column) => column);

  GeneratedColumn<DateTime> get attemptTime => $composableBuilder(
    column: $table.attemptTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNumberCalled => $composableBuilder(
    column: $table.phoneNumberCalled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneType =>
      $composableBuilder(column: $table.phoneType, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get callDurationSeconds => $composableBuilder(
    column: $table.callDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get attemptNotes => $composableBuilder(
    column: $table.attemptNotes,
    builder: (column) => column,
  );
}

class $$CallAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallAttemptsTable,
          CallAttemptEntry,
          $$CallAttemptsTableFilterComposer,
          $$CallAttemptsTableOrderingComposer,
          $$CallAttemptsTableAnnotationComposer,
          $$CallAttemptsTableCreateCompanionBuilder,
          $$CallAttemptsTableUpdateCompanionBuilder,
          (
            CallAttemptEntry,
            BaseReferences<_$AppDatabase, $CallAttemptsTable, CallAttemptEntry>,
          ),
          CallAttemptEntry,
          PrefetchHooks Function()
        > {
  $$CallAttemptsTableTableManager(_$AppDatabase db, $CallAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> contactId = const Value.absent(),
                Value<int?> callLogId = const Value.absent(),
                Value<DateTime> attemptTime = const Value.absent(),
                Value<int> attemptNumber = const Value.absent(),
                Value<String> phoneNumberCalled = const Value.absent(),
                Value<String> phoneType = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<int?> callDurationSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String?> attemptNotes = const Value.absent(),
              }) => CallAttemptsCompanion(
                id: id,
                contactId: contactId,
                callLogId: callLogId,
                attemptTime: attemptTime,
                attemptNumber: attemptNumber,
                phoneNumberCalled: phoneNumberCalled,
                phoneType: phoneType,
                outcome: outcome,
                callDurationSeconds: callDurationSeconds,
                createdAt: createdAt,
                userId: userId,
                attemptNotes: attemptNotes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int contactId,
                Value<int?> callLogId = const Value.absent(),
                required DateTime attemptTime,
                required int attemptNumber,
                required String phoneNumberCalled,
                required String phoneType,
                required String outcome,
                Value<int?> callDurationSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String?> attemptNotes = const Value.absent(),
              }) => CallAttemptsCompanion.insert(
                id: id,
                contactId: contactId,
                callLogId: callLogId,
                attemptTime: attemptTime,
                attemptNumber: attemptNumber,
                phoneNumberCalled: phoneNumberCalled,
                phoneType: phoneType,
                outcome: outcome,
                callDurationSeconds: callDurationSeconds,
                createdAt: createdAt,
                userId: userId,
                attemptNotes: attemptNotes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CallAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallAttemptsTable,
      CallAttemptEntry,
      $$CallAttemptsTableFilterComposer,
      $$CallAttemptsTableOrderingComposer,
      $$CallAttemptsTableAnnotationComposer,
      $$CallAttemptsTableCreateCompanionBuilder,
      $$CallAttemptsTableUpdateCompanionBuilder,
      (
        CallAttemptEntry,
        BaseReferences<_$AppDatabase, $CallAttemptsTable, CallAttemptEntry>,
      ),
      CallAttemptEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CallLogsTableTableManager get callLogs =>
      $$CallLogsTableTableManager(_db, _db.callLogs);
  $$CallContactsTableTableManager get callContacts =>
      $$CallContactsTableTableManager(_db, _db.callContacts);
  $$CallSessionsTableTableManager get callSessions =>
      $$CallSessionsTableTableManager(_db, _db.callSessions);
  $$BreakSessionsTableTableManager get breakSessions =>
      $$BreakSessionsTableTableManager(_db, _db.breakSessions);
  $$DailyStatsTableTableManager get dailyStats =>
      $$DailyStatsTableTableManager(_db, _db.dailyStats);
  $$CallAttemptsTableTableManager get callAttempts =>
      $$CallAttemptsTableTableManager(_db, _db.callAttempts);
}
