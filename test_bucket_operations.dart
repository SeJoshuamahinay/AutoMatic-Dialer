import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/commons/models/loan_models.dart';
import 'lib/commons/services/accounts_bucket_service.dart';

void main() async {
  await testBucketOperations();
}

Future<void> testBucketOperations() async {
  print('Testing bucket operations...');

  try {
    // Get API response
    final url = Uri.parse(
      'http://localhost:8000/api/lenderly/dialer/assign-loans',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': 65}),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final assignmentResponse = AssignmentResponse.fromJson(jsonData);

      if (assignmentResponse.data != null) {
        final data = assignmentResponse.data!;
        print('✓ Assignment data parsed successfully');

        // Test bucket operations
        print('\n--- Testing Bucket Operations ---');

        for (final bucketType in BucketType.values) {
          print('\n${bucketType.displayName} Bucket:');

          try {
            // Test getLoansByBucket
            final loans = AccountsBucketService.getLoansByBucket(
              data,
              bucketType,
            );
            print('  ✓ getLoansByBucket: ${loans.length} loans');

            // Test getCoMakerPrioritizedLoansByBucket
            final prioritizedLoans =
                AccountsBucketService.getCoMakerPrioritizedLoansByBucket(
                  data,
                  bucketType,
                );
            print(
              '  ✓ getCoMakerPrioritizedLoansByBucket: ${prioritizedLoans.length} loans',
            );

            // Test getBucketStatistics
            final stats = AccountsBucketService.getBucketStatistics(
              data,
              bucketType,
            );
            print('  ✓ getBucketStatistics:');
            print('    - Total loans: ${stats['total_loans']}');
            print('    - Dialable count: ${stats['dialable_count']}');
            print('    - Co-maker phones: ${stats['co_maker_phone_count']}');
            print('    - Borrower phones: ${stats['borrower_phone_count']}');
            print('    - No phone: ${stats['no_phone_count']}');
            print(
              '    - Co-maker percentage: ${stats['co_maker_percentage']}%',
            );

            // Test individual loan properties
            if (loans.isNotEmpty) {
              final firstLoan = loans.first;
              print('  ✓ First loan details:');
              print('    - ID: ${firstLoan.loanId}');
              print('    - Borrower: ${firstLoan.borrower?.borrowerName}');
              print('    - Co-maker: ${firstLoan.borrower?.coMakerName}');
              print('    - Due amount: ${firstLoan.outstandingBalance}');
              print('    - Has phone: ${firstLoan.hasValidPhone}');
              print('    - Preferred phone: ${firstLoan.preferredPhone}');
              print('    - Bucket type: ${firstLoan.bucketType}');
            }
          } catch (e) {
            print(
              '  ✗ Error in ${bucketType.displayName} bucket operations: $e',
            );
            print('  Stack trace: ${StackTrace.current}');
          }
        }

        print('\n--- Testing Assignment Data Methods ---');
        try {
          print('Total loans count: ${data.totalLoansCount}');
          print('Dialable loans count: ${data.dialableLoans.length}');

          for (final bucketType in BucketType.values) {
            print(
              '${bucketType.displayName}: ${data.getCountForBucket(bucketType)} total, ${data.getDialableCountForBucket(bucketType)} dialable',
            );
          }
        } catch (e) {
          print('✗ Error in assignment data methods: $e');
        }
      }
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}
