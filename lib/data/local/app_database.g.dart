// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CallContactsTable extends CallContacts
    with TableInfo<$CallContactsTable, CallContact> {
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
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, phoneNumber, status, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallContact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $CallContactsTable createAlias(String alias) {
    return $CallContactsTable(attachedDatabase, alias);
  }
}

class CallContact extends DataClass implements Insertable<CallContact> {
  final int id;
  final String phoneNumber;
  final String status;
  final String? note;
  const CallContact({
    required this.id,
    required this.phoneNumber,
    required this.status,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  CallContactsCompanion toCompanion(bool nullToAbsent) {
    return CallContactsCompanion(
      id: Value(id),
      phoneNumber: Value(phoneNumber),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory CallContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallContact(
      id: serializer.fromJson<int>(json['id']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
    };
  }

  CallContact copyWith({
    int? id,
    String? phoneNumber,
    String? status,
    Value<String?> note = const Value.absent(),
  }) => CallContact(
    id: id ?? this.id,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
  );
  CallContact copyWithCompanion(CallContactsCompanion data) {
    return CallContact(
      id: data.id.present ? data.id.value : this.id,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallContact(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('status: $status, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, phoneNumber, status, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallContact &&
          other.id == this.id &&
          other.phoneNumber == this.phoneNumber &&
          other.status == this.status &&
          other.note == this.note);
}

class CallContactsCompanion extends UpdateCompanion<CallContact> {
  final Value<int> id;
  final Value<String> phoneNumber;
  final Value<String> status;
  final Value<String?> note;
  const CallContactsCompanion({
    this.id = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
  });
  CallContactsCompanion.insert({
    this.id = const Value.absent(),
    required String phoneNumber,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
  }) : phoneNumber = Value(phoneNumber);
  static Insertable<CallContact> custom({
    Expression<int>? id,
    Expression<String>? phoneNumber,
    Expression<String>? status,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
    });
  }

  CallContactsCompanion copyWith({
    Value<int>? id,
    Value<String>? phoneNumber,
    Value<String>? status,
    Value<String?>? note,
  }) {
    return CallContactsCompanion(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallContactsCompanion(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('status: $status, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CallContactsTable callContacts = $CallContactsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [callContacts];
}

typedef $$CallContactsTableCreateCompanionBuilder =
    CallContactsCompanion Function({
      Value<int> id,
      required String phoneNumber,
      Value<String> status,
      Value<String?> note,
    });
typedef $$CallContactsTableUpdateCompanionBuilder =
    CallContactsCompanion Function({
      Value<int> id,
      Value<String> phoneNumber,
      Value<String> status,
      Value<String?> note,
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

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$CallContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallContactsTable,
          CallContact,
          $$CallContactsTableFilterComposer,
          $$CallContactsTableOrderingComposer,
          $$CallContactsTableAnnotationComposer,
          $$CallContactsTableCreateCompanionBuilder,
          $$CallContactsTableUpdateCompanionBuilder,
          (
            CallContact,
            BaseReferences<_$AppDatabase, $CallContactsTable, CallContact>,
          ),
          CallContact,
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
                Value<String> phoneNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => CallContactsCompanion(
                id: id,
                phoneNumber: phoneNumber,
                status: status,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String phoneNumber,
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => CallContactsCompanion.insert(
                id: id,
                phoneNumber: phoneNumber,
                status: status,
                note: note,
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
      CallContact,
      $$CallContactsTableFilterComposer,
      $$CallContactsTableOrderingComposer,
      $$CallContactsTableAnnotationComposer,
      $$CallContactsTableCreateCompanionBuilder,
      $$CallContactsTableUpdateCompanionBuilder,
      (
        CallContact,
        BaseReferences<_$AppDatabase, $CallContactsTable, CallContact>,
      ),
      CallContact,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CallContactsTableTableManager get callContacts =>
      $$CallContactsTableTableManager(_db, _db.callContacts);
}
