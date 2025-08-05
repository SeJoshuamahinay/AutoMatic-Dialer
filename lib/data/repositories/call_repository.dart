import '../../commons/models/call_contact_model.dart';
import '../local/app_database.dart' hide CallContact;
import '../remote/api_service.dart';
import 'base_repository.dart';

class CallRepository implements BaseRepository {
  final AppDatabase _database;
  final ApiService _apiService;

  CallRepository({
    required AppDatabase database,
    required ApiService apiService,
  }) : _database = database,
       _apiService = apiService;

  // Get all contacts from local database
  @override
  Future<List<CallContact>> getAllContacts() async {
    return await _database.getAllContacts();
  }

  // Get pending contacts from local database
  @override
  Future<List<CallContact>> getPendingContacts() async {
    return await _database.getPendingContacts();
  }

  // Fetch contacts from API and store locally
  @override
  Future<List<CallContact>> fetchAndStoreContacts() async {
    try {
      final contacts = await _apiService.fetchborrowerPhones();

      // Clear existing contacts and insert new ones
      await _database.clearAllContacts();

      for (final contact in contacts) {
        await _database.insertContact(contact);
      }

      return contacts;
    } catch (e) {
      throw Exception('Failed to fetch and store contacts: $e');
    }
  }

  // Update contact status and note
  @override
  Future<bool> updateContact(int id, String status, String? note) async {
    return await _database.updateContact(id, status, note);
  }

  // Get contact by id
  @override
  Future<CallContact?> getContactById(int id) async {
    return await _database.getContactById(id);
  }

  // Check if there are any contacts in the database
  @override
  Future<bool> hasContacts() async {
    final contacts = await _database.getAllContacts();
    return contacts.isNotEmpty;
  }

  // Test API connection
  @override
  Future<bool> testApiConnection() async {
    return await _apiService.testConnection();
  }

  // Clear all contacts
  @override
  Future<void> clearAllContacts() async {
    await _database.clearAllContacts();
  }

  // Get contacts count
  @override
  Future<int> getContactsCount() async {
    final contacts = await _database.getAllContacts();
    return contacts.length;
  }

  // Get called contacts count
  @override
  Future<int> getCalledContactsCount() async {
    final allContacts = await _database.getAllContacts();
    return allContacts.where((contact) => contact.status == 'called').length;
  }
}
