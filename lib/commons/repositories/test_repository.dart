import 'package:lenderly_dialer/commons/models/call_contact_model.dart';
import 'package:lenderly_dialer/commons/repositories/base_repository.dart';

/// Test repository implementation for development and testing
class TestRepository implements BaseRepository {
  final List<CallContact> _contacts = [
    CallContact(
      id: 1,
      loanId: 101,
      borrowerName: 'John Doe',
      borrowerPhone: '+1234567890',
      coMakerName: null,
      coMakerPhone: null,
      status: 'pending',
      note: null,
    ),
    CallContact(
      id: 2,
      loanId: 102,
      borrowerName: 'Jane Smith',
      borrowerPhone: '+1234567891',
      coMakerName: null,
      coMakerPhone: null,
      status: 'pending',
      note: null,
    ),
    CallContact(
      id: 3,
      loanId: 103,
      borrowerName: 'Bob Johnson',
      borrowerPhone: '+1234567892',
      coMakerName: null,
      coMakerPhone: null,
      status: 'called',
      note: 'Completed call',
    ),
  ];

  @override
  Future<List<CallContact>> getAllContacts() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API delay
    return List.from(_contacts);
  }

  @override
  Future<List<CallContact>> getPendingContacts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _contacts.where((contact) => contact.status == 'pending').toList();
  }

  @override
  Future<List<CallContact>> fetchAndStoreContacts() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return List.from(_contacts);
  }

  @override
  Future<bool> updateContact(int id, String status, String? note) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _contacts.indexWhere((contact) => contact.id == id);
    if (index != -1) {
      _contacts[index] = _contacts[index].copyWith(status: status, note: note);
      return true;
    }
    return false;
  }

  @override
  Future<CallContact?> getContactById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> hasContacts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _contacts.isNotEmpty;
  }

  @override
  Future<bool> testApiConnection() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Always return true for testing
  }

  @override
  Future<void> clearAllContacts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _contacts.clear();
  }

  @override
  Future<int> getContactsCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _contacts.length;
  }

  @override
  Future<int> getCalledContactsCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _contacts.where((contact) => contact.status == 'called').length;
  }
}
