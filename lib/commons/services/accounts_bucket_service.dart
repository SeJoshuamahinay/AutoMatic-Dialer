import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';

class AccountsBucketService {
  static const String _assignLoansEndpoint =
      '/api/lenderly/dialer/assign-loans';
  static const String _userLoansEndpoint = '/api/lenderly/dialer/user-loans';
  static const String _dialerDataEndpoint = '/api/lenderly/dialer/data';
  static const String _dialerStatsEndpoint = '/api/lenderly/dialer/stats';
  static const String _loanDetailEndpoint =
      '/api/lenderly/dialer/get-loan-details';

  /// Assign loans to a user by posting user_id to the assign-loans endpoint
  static Future<AssignmentResponse> assignLoansToUser(String userId) async {
    try {
      final request = AssignLoansRequest(userId: userId);

      if (EnvironmentConfig.enableLogging) {}

      final response = await ApiClient.post(
        _assignLoansEndpoint,
        body: request.toJson(),
        timeout: const Duration(seconds: 30),
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
    } on AuthSessionExpiredException {
      return AssignmentResponse(
        success: false,
        message: 'Session expired. Please log in again.',
        error: 'Session expired',
      );
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
      if (EnvironmentConfig.enableLogging) {}

      final response = await ApiClient.get(
        '$_userLoansEndpoint?user_id=${Uri.encodeQueryComponent(userId)}',
        timeout: const Duration(seconds: 30),
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
    } on AuthSessionExpiredException {
      return AssignmentResponse(
        success: false,
        message: 'Session expired. Please log in again.',
        error: 'Session expired',
      );
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

  /// Get loans for a specific bucket with pagination + optional search.
  /// Calls GET /api/lenderly/dialer/data/{bucket}?user_id={id}&page={n}&per_page={n}&search={q}
  /// Returns { 'records': List<DialerLoanRecord>, 'pagination': Map?, 'total': int? }
  static Future<Map<String, dynamic>> getDialerDataByBucketPaged(
    String userId,
    String bucket, {
    int page = 1,
    int perPage = 50,
    String? search,
  }) async {
    try {
      final buffer = StringBuffer(
        '$_dialerDataEndpoint/$bucket?user_id=${Uri.encodeQueryComponent(userId)}&page=$page&per_page=$perPage',
      );
      if (search != null && search.isNotEmpty) {
        buffer.write('&search=${Uri.encodeQueryComponent(search)}');
      }

      final url = buffer.toString();
      debugPrint(
        '[BucketService] ▶ FETCH  bucket=$bucket page=$page perPage=$perPage search=$search',
      );
      debugPrint('[BucketService]   URL: $url');
      final t0 = DateTime.now();

      final response = await ApiClient.get(
        url,
        timeout: const Duration(seconds: 60),
      );

      final elapsed = DateTime.now().difference(t0).inMilliseconds;
      debugPrint(
        '[BucketService] ◀ RESPONSE  status=${response.statusCode}  elapsed=${elapsed}ms  bodyLen=${response.body.length}',
      );

      if (response.statusCode == 200) {
        final t1 = DateTime.now();
        final jsonData = jsonDecode(response.body);
        final inner = jsonData is Map ? jsonData['data'] : null;
        List<DialerLoanRecord> records = [];
        Map<String, dynamic>? pagination;
        int? total;

        if (inner is Map) {
          if (inner['records'] is List) {
            records = (inner['records'] as List)
                .map(
                  (e) => DialerLoanRecord.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
          if (inner['pagination'] is Map) {
            pagination = Map<String, dynamic>.from(inner['pagination'] as Map);
          }
          total = inner['total'] as int?;
        }

        final parseMs = DateTime.now().difference(t1).inMilliseconds;
        debugPrint(
          '[BucketService] ✔ PARSED  records=${records.length}  total=$total  hasMore=${pagination?['has_more']}  parseMs=${parseMs}ms',
        );

        return {'records': records, 'pagination': pagination, 'total': total};
      } else {
        debugPrint(
          '[BucketService] ✖ HTTP ERROR ${response.statusCode}: ${response.body}',
        );
        throw Exception('HTTP ${response.statusCode}');
      }
    } on AuthSessionExpiredException {
      rethrow;
    } catch (e) {
      debugPrint('[BucketService] ✖ EXCEPTION: $e');
      rethrow;
    }
  }

  /// Get loans for a specific bucket from the new dialer API
  /// Calls GET /api/lenderly/dialer/data/{bucket}?user_id={userId}
  static Future<List<DialerLoanRecord>> getDialerDataByBucket(
    String userId,
    String bucket,
  ) async {
    try {
      final response = await ApiClient.get(
        '$_dialerDataEndpoint/$bucket?user_id=${Uri.encodeQueryComponent(userId)}',
        timeout: const Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // Response: {success: true, data: {records: [...]}}
        List<dynamic> records;
        if (jsonData is List) {
          records = jsonData;
        } else if (jsonData is Map) {
          final inner = jsonData['data'];
          if (inner is List) {
            records = inner;
          } else if (inner is Map && inner['records'] is List) {
            records = inner['records'] as List<dynamic>;
          } else {
            records = [];
          }
        } else {
          records = [];
        }
        return records
            .map((e) => DialerLoanRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on AuthSessionExpiredException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Get loan statistics from the new dialer stats API
  /// Calls GET /api/lenderly/dialer/stats?user_id={userId}
  static Future<Map<String, dynamic>> getDialerStats(String userId) async {
    try {
      final response = await ApiClient.get(
        '$_dialerStatsEndpoint?user_id=${Uri.encodeQueryComponent(userId)}',
        timeout: const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        // Unwrap {success: true, data: {...}} envelope
        if (jsonData['data'] is Map) {
          return jsonData['data'] as Map<String, dynamic>;
        }
        return jsonData;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on AuthSessionExpiredException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch borrower_id for a given loan from the loan detail endpoint.
  static Future<int> getBorrowerIdForLoan(int loanId) async {
    final response = await ApiClient.get(
      '$_loanDetailEndpoint/$loanId',
      timeout: const Duration(seconds: 15),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;
      final loan = data?['loan'] as Map<String, dynamic>?;
      final id = loan?['borrower_id'];
      if (id != null) return (id as num).toInt();
      throw Exception('borrower_id not found in loan detail');
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }
}
