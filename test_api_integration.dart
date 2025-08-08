import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/commons/models/loan_models.dart';

void main() async {
  await testApiIntegration();
}

Future<void> testApiIntegration() async {
  print('Testing API integration...');

  try {
    // Test the actual API response
    final url = Uri.parse(
      'http://localhost:8000/api/lenderly/dialer/assign-loans',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': 65}),
    );

    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      print('Success: ${jsonData['success']}');
      print('Message: ${jsonData['message']}');

      // Test parsing the response with our models
      final assignmentResponse = AssignmentResponse.fromJson(jsonData);
      print('Parsed successfully: ${assignmentResponse.success}');

      if (assignmentResponse.data != null) {
        final data = assignmentResponse.data!;
        print('User ID: ${data.userId}');
        print('Total Records: ${data.totalRecords}');
        print('Total Amount: ${data.totalAssignedAmount}');

        // Test bucket parsing
        print('Frontend loans: ${data.getCountForBucket(BucketType.frontend)}');
        print(
          'Middlecore loans: ${data.getCountForBucket(BucketType.middlecore)}',
        );
        print('Hardcore loans: ${data.getCountForBucket(BucketType.hardcore)}');

        // Test loan parsing
        final frontendLoans = data.getLoansByBucket(BucketType.frontend);
        if (frontendLoans.isNotEmpty) {
          final firstLoan = frontendLoans.first;
          print('First loan ID: ${firstLoan.loanId}');
          print('Borrower: ${firstLoan.borrower?.borrowerName}');
          print('Co-maker: ${firstLoan.borrower?.coMakerName}');
          print('Due amount: ${firstLoan.outstandingBalance}');
          print('Has valid phone: ${firstLoan.hasValidPhone}');
          print('Preferred phone: ${firstLoan.preferredPhone}');
        }

        print('Total dialable loans: ${data.dialableLoans.length}');
      }
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
