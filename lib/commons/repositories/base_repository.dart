import 'package:lenderly_dialer/commons/models/call_contact_model.dart';

abstract class BaseRepository {
  Future<List<CallContact>> getAllContacts();
  Future<List<CallContact>> getPendingContacts();
  Future<List<CallContact>> fetchAndStoreContacts();
  Future<bool> updateContact(int id, String status, String? note);
  Future<CallContact?> getContactById(int id);
  Future<bool> hasContacts();
  Future<bool> testApiConnection();
  Future<void> clearAllContacts();
  Future<int> getContactsCount();
  Future<int> getCalledContactsCount();
}
