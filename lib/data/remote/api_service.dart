import 'package:http/http.dart' as http;
import '../../commons/models/call_contact_model.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // Mock API endpoint - using JSONPlaceholder users endpoint for demo
  // In a real app, this would be your actual API endpoint
  Future<List<CallContact>> fetchborrowerPhones() async {
    // Always return mock test numbers for development
    return _getMockborrowerPhones();
  }

  // Mock data for testing when API is not available
  List<CallContact> _getMockborrowerPhones() {
    return [
      const CallContact(
        borrowerName: 'test 1',
        borrowerPhone: '09177167362',
        status: 'pending',
      ),
      const CallContact(
        borrowerName: 'test 1',
        borrowerPhone: '09171765207',
        status: 'pending',
      ),
      const CallContact(
        borrowerName: 'test 1',
        borrowerPhone: '09177027370',
        status: 'pending',
      ),
      const CallContact(
        borrowerName: 'test 1',
        borrowerPhone: '09171351660',
        status: 'pending',
      ),
      const CallContact(
        borrowerName: 'test 1',
        borrowerPhone: '09171501060',
        status: 'pending',
      ),
      const CallContact(
        borrowerName: 'test 1',
        borrowerPhone: '09171432723',
        status: 'pending',
      ),
      const CallContact(
        borrowerName: 'test 1',
        borrowerPhone: '09177017389',
        status: 'pending',
      ),
      const CallContact(
        borrowerName: 'test 1',
        borrowerPhone: '09177127437',
        status: 'pending',
      ),
    ];
  }

  // Method to test API connectivity
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
