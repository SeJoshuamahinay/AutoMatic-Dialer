import '../commons/models/call_contact_model.dart';

class TestDataService {
  // Test phone numbers for automatic dialing
  static List<CallContact> getTestContacts() {
    final testNumbers = [
      '09177167362',
      '09171765207',
      '09177027370',
      '09171351660',
      '09171501060',
      '09171432723',
      '09177017389',
      '09177127437',
    ];

    return testNumbers
        .asMap()
        .entries
        .map(
          (entry) => CallContact(
            id: entry.key + 1,
            borrowerName: 'Test Name ${entry.key + 1}',
            borrowerPhone: entry.value,
            status: 'pending',
            note: 'Test contact ${entry.key + 1}',
          ),
        )
        .toList();
  }

  // Simplified test data for development
  static List<CallContact> getSimpleTestContacts() {
    return [
      const CallContact(
        id: 1,
        borrowerName: 'Test Name 1',
        borrowerPhone: '09177167362',
        status: 'pending',
        note: 'Test contact 1',
      ),
      const CallContact(
        id: 2,
        borrowerName: 'Test Name 2',
        borrowerPhone: '09171765207',
        status: 'pending',
        note: 'Test contact 2',
      ),
      const CallContact(
        id: 3,
        borrowerName: 'Test Name 3',
        borrowerPhone: '09177027370',
        status: 'pending',
        note: 'Test contact 3',
      ),
      const CallContact(
        id: 4,
        borrowerName: 'Test Name 4',
        borrowerPhone: '09171351660',
        status: 'pending',
        note: 'Test contact 4',
      ),
      const CallContact(
        id: 5,
        borrowerName: 'Test Name 5',
        borrowerPhone: '09171501060',
        status: 'pending',
        note: 'Test contact 5',
      ),
      const CallContact(
        id: 6,
        borrowerName: 'Test Name 6',
        borrowerPhone: '09171432723',
        status: 'pending',
        note: 'Test contact 6',
      ),
      const CallContact(
        id: 7,
        borrowerName: 'Test Name 7',
        borrowerPhone: '09177017389',
        status: 'pending',
        note: 'Test contact 7',
      ),
      const CallContact(
        id: 8,
        borrowerName: 'Test Name 8',
        borrowerPhone: '09177127437',
        status: 'pending',
        note: 'Test contact 8',
      ),
    ];
  }
}
