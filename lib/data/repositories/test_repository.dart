import '../../commons/models/call_contact_model.dart';
import '../test_data_service.dart';
import 'base_repository.dart';

class TestRepository implements BaseRepository {
  List<CallContact> _contacts = TestDataService.getTestContacts();

  // Get all contacts
  @override
  Future<List<CallContact>> getAllContacts() async {
    return _contacts;
  }

  // Get pending contacts
  @override
  Future<List<CallContact>> getPendingContacts() async {
    return _contacts.where((c) => c.status == 'pending').toList();
  }

  // Simulate fetching and storing contacts
  @override
  Future<List<CallContact>> fetchAndStoreContacts() async {
    _contacts = TestDataService.getTestContacts();
    return _contacts;
  }

  // Update contact status and note
  @override
  Future<bool> updateContact(int id, String status, String? note) async {
    final idx = _contacts.indexWhere((c) => c.id == id);
    if (idx == -1) return false;
    _contacts[idx] = CallContact(
      id: _contacts[idx].id,
      borrowerName: _contacts[idx].borrowerName,
      borrowerPhone: _contacts[idx].borrowerPhone,
      status: status,
      note: note ?? _contacts[idx].note,
    );
    return true;
  }

  // Get contact by id
  @override
  Future<CallContact?> getContactById(int id) async {
    try {
      return _contacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Check if there are any contacts
  @override
  Future<bool> hasContacts() async {
    return _contacts.isNotEmpty;
  }

  // Simulate API connection test
  @override
  Future<bool> testApiConnection() async {
    return true;
  }

  // Clear all contacts
  @override
  Future<void> clearAllContacts() async {
    _contacts.clear();
  }

  // Get contacts count
  @override
  Future<int> getContactsCount() async {
    return _contacts.length;
  }

  // Get called contacts count
  @override
  Future<int> getCalledContactsCount() async {
    return _contacts.where((contact) => contact.status == 'called').length;
  }
}
