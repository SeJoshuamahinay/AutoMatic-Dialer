import 'package:drift/drift.dart';
import '../../commons/models/call_contact_model.dart' as model;
import 'database_native.dart' if (dart.library.html) 'database_web.dart';

part 'app_database.g.dart';

class CallContacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get phoneNumber => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get note => text().nullable()();
}

@DriftDatabase(tables: [CallContacts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect());

  @override
  int get schemaVersion => 1;

  // Get all contacts
  Future<List<model.CallContact>> getAllContacts() async {
    final results = await select(callContacts).get();
    return results
        .map(
          (row) => model.CallContact(
            id: row.id,
            borrowerName: 'test datas',
            borrowerPhone: row.phoneNumber,
            status: row.status,
            note: row.note,
          ),
        )
        .toList();
  }

  // Get pending contacts
  Future<List<model.CallContact>> getPendingContacts() async {
    final results = await (select(
      callContacts,
    )..where((tbl) => tbl.status.equals('pending'))).get();
    return results
        .map(
          (row) => model.CallContact(
            id: row.id,
            borrowerPhone: row.phoneNumber,
            borrowerName: 'test datas',
            status: row.status,
            note: row.note,
          ),
        )
        .toList();
  }

  // Insert contact
  Future<int> insertContact(model.CallContact contact) async {
    return await into(callContacts).insert(
      CallContactsCompanion(
        phoneNumber: Value(contact.borrowerPhone),
        status: Value(contact.status),
        note: Value(contact.note),
      ),
    );
  }

  // Update contact status and note
  Future<bool> updateContact(int id, String status, String? note) async {
    final updated =
        await (update(callContacts)..where((tbl) => tbl.id.equals(id))).write(
          CallContactsCompanion(status: Value(status), note: Value(note)),
        );
    return updated > 0;
  }

  // Clear all contacts
  Future<void> clearAllContacts() async {
    await delete(callContacts).go();
  }

  // Get contact by id
  Future<model.CallContact?> getContactById(int id) async {
    final result = await (select(
      callContacts,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (result == null) return null;

    return model.CallContact(
      id: result.id,
      borrowerName: 'test datas',
      borrowerPhone: result.phoneNumber,
      status: result.status,
      note: result.note,
    );
  }
}
