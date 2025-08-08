import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lenderly_dialer/commons/models/loan_models.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

class AccountsBucketService {
  static const String _assignLoansEndpoint =
      '/api/lenderly/dialer/assign-loans';
  static const String _userLoansEndpoint = '/api/lenderly/dialer/user-loans';

  /// Assign loans to a user by posting user_id to the assign-loans endpoint
  static Future<AssignmentResponse> assignLoansToUser(String userId) async {
    try {
      await EnvironmentConfig.initialize();

      final baseUrl = EnvironmentConfig.apiBaseUrl;
      if (baseUrl.isEmpty) {
        throw Exception('API base URL is not configured');
      }

      final url = Uri.parse('$baseUrl$_assignLoansEndpoint');
      final token = await SharedPrefsStorageService.getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing');
      }

      final request = AssignLoansRequest(userId: userId);

      if (EnvironmentConfig.enableLogging) {}

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final assignmentResponse = AssignmentResponse.fromJson(jsonData);

        return assignmentResponse;
      } else {
        String errorMessage = 'Failed to assign loans';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              'HTTP ${response.statusCode}';
        } catch (e) {
          errorMessage =
              'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        }

        if (EnvironmentConfig.enableLogging) {}

        return AssignmentResponse(
          success: false,
          message: errorMessage,
          error: errorMessage,
        );
      }
    } on SocketException catch (e) {
      final errorMessage = 'Network error: ${e.message}';
      if (EnvironmentConfig.enableLogging) {}
      return AssignmentResponse(
        success: false,
        message: errorMessage,
        error: errorMessage,
      );
    } on FormatException catch (e) {
      final errorMessage = 'Invalid response format: ${e.message}';
      if (EnvironmentConfig.enableLogging) {}
      return AssignmentResponse(
        success: false,
        message: errorMessage,
        error: errorMessage,
      );
    } catch (e) {
      final errorMessage = 'Unexpected error: $e';
      if (EnvironmentConfig.enableLogging) {}
      return AssignmentResponse(
        success: false,
        message: errorMessage,
        error: errorMessage,
      );
    }
  }

  /// Get assigned loans for a user from the user-loans endpoint
  static Future<AssignmentResponse> getUserAssignedLoans(String userId) async {
    try {
      await EnvironmentConfig.initialize();

      final baseUrl = EnvironmentConfig.apiBaseUrl;
      if (baseUrl.isEmpty) {
        throw Exception('API base URL is not configured');
      }

      final url = Uri.parse('$baseUrl$_userLoansEndpoint?user_id=$userId');
      final token = await SharedPrefsStorageService.getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing');
      }

      if (EnvironmentConfig.enableLogging) {}

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (EnvironmentConfig.enableLogging) {}

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final assignmentResponse = AssignmentResponse.fromJson(jsonData);

        if (EnvironmentConfig.enableLogging) {}

        return assignmentResponse;
      } else {
        String errorMessage = 'Failed to get assigned loans';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              'HTTP ${response.statusCode}';
        } catch (e) {
          errorMessage =
              'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        }

        if (EnvironmentConfig.enableLogging) {}

        return AssignmentResponse(
          success: false,
          message: errorMessage,
          error: errorMessage,
        );
      }
    } on SocketException catch (e) {
      final errorMessage = 'Network error: ${e.message}';
      if (EnvironmentConfig.enableLogging) {}
      return AssignmentResponse(
        success: false,
        message: errorMessage,
        error: errorMessage,
      );
    } catch (e) {
      final errorMessage = 'Unexpected error: $e';
      if (EnvironmentConfig.enableLogging) {}
      return AssignmentResponse(
        success: false,
        message: errorMessage,
        error: errorMessage,
      );
    }
  }

  /// Get loans by bucket type from assignment data
  static List<LoanRecord> getLoansByBucket(
    AssignmentData assignmentData,
    BucketType bucketType,
  ) {
    return assignmentData.getLoansByBucket(bucketType);
  }

  /// Get dialable loans (those with valid phone numbers) by bucket type
  static List<LoanRecord> getDialableLoansByBucket(
    AssignmentData assignmentData,
    BucketType bucketType,
  ) {
    return assignmentData
        .getLoansByBucket(bucketType)
        .where((loan) => loan.hasValidPhone)
        .toList();
  }

  /// Get co-maker prioritized loans by bucket type
  /// This method prioritizes loans that have co-maker phone numbers
  static List<LoanRecord> getCoMakerPrioritizedLoansByBucket(
    AssignmentData assignmentData,
    BucketType bucketType,
  ) {
    final bucketLoans = assignmentData.getLoansByBucket(bucketType);

    // Separate loans with co-maker phones and those without
    final coMakerLoans = <LoanRecord>[];
    final borrowerOnlyLoans = <LoanRecord>[];

    for (final loan in bucketLoans) {
      if (loan.borrower?.coMakerPhone != null &&
          loan.borrower!.coMakerPhone!.isNotEmpty) {
        coMakerLoans.add(loan);
      } else if (loan.borrower?.borrowerPhone != null &&
          loan.borrower!.borrowerPhone!.isNotEmpty) {
        borrowerOnlyLoans.add(loan);
      }
    }

    // Return co-maker loans first, then borrower-only loans
    return [...coMakerLoans, ...borrowerOnlyLoans];
  }

  /// Get bucket statistics including co-maker vs borrower phone counts
  static Map<String, dynamic> getBucketStatistics(
    AssignmentData assignmentData,
    BucketType bucketType,
  ) {
    final bucketLoans = assignmentData.getLoansByBucket(bucketType);

    int totalLoans = bucketLoans.length;
    int coMakerPhoneCount = 0;
    int borrowerPhoneCount = 0;
    int noPhoneCount = 0;

    for (final loan in bucketLoans) {
      if (loan.borrower?.coMakerPhone != null &&
          loan.borrower!.coMakerPhone!.isNotEmpty) {
        coMakerPhoneCount++;
      } else if (loan.borrower?.borrowerPhone != null &&
          loan.borrower!.borrowerPhone!.isNotEmpty) {
        borrowerPhoneCount++;
      } else {
        noPhoneCount++;
      }
    }

    return {
      'bucket_type': bucketType.displayName,
      'total_loans': totalLoans,
      'co_maker_phone_count': coMakerPhoneCount,
      'borrower_phone_count': borrowerPhoneCount,
      'no_phone_count': noPhoneCount,
      'dialable_count': coMakerPhoneCount + borrowerPhoneCount,
      'co_maker_percentage': totalLoans > 0
          ? (coMakerPhoneCount / totalLoans * 100).round()
          : 0,
    };
  }
}
