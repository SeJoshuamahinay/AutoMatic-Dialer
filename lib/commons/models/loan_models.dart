class Borrower {
  final String? borrowerName;
  final String? borrowerPhone;
  final String? coMakerName;
  final String? coMakerPhone;

  Borrower({
    this.borrowerName,
    this.borrowerPhone,
    this.coMakerName,
    this.coMakerPhone,
  });

  factory Borrower.fromJson(Map<String, dynamic> json) {
    // Handle the new API format where borrower and co_maker are separate objects
    String? borrowerName;
    String? borrowerPhone;
    String? coMakerName;
    String? coMakerPhone;

    // Check if this is the new API format with separate borrower/co_maker objects
    if (json.containsKey('borrower') && json['borrower'] is Map) {
      final borrowerData = json['borrower'] as Map<String, dynamic>;
      borrowerName = borrowerData['name']?.toString();
      borrowerPhone = borrowerData['phone']?.toString();
    }

    if (json.containsKey('co_maker') && json['co_maker'] is Map) {
      final coMakerData = json['co_maker'] as Map<String, dynamic>;
      coMakerName = coMakerData['name']?.toString();
      coMakerPhone = coMakerData['phone']?.toString();
    }

    // Fallback to old format for backward compatibility
    borrowerName ??= json['borrower_name']?.toString();
    borrowerPhone ??= json['borrower_phone']?.toString();
    coMakerName ??= json['co_maker_name']?.toString();
    coMakerPhone ??= json['co_maker_phone']?.toString();

    return Borrower(
      borrowerName: borrowerName,
      borrowerPhone: borrowerPhone,
      coMakerName: coMakerName,
      coMakerPhone: coMakerPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borrower_name': borrowerName,
      'borrower_phone': borrowerPhone,
      'co_maker_name': coMakerName,
      'co_maker_phone': coMakerPhone,
    };
  }

  /// Get the preferred phone number for dialing (prioritize co-maker)
  String? get preferredPhone => coMakerPhone ?? borrowerPhone;

  /// Get the preferred contact name for dialing
  String? get preferredContactName =>
      coMakerPhone != null ? coMakerName : borrowerName;

  /// Check if there's a valid phone number to dial
  bool get hasValidPhone =>
      preferredPhone != null && preferredPhone!.isNotEmpty;
}

class LoanRecord {
  final String? loanId;
  final String? loanAccountNumber;
  final double? principalAmount;
  final double? outstandingBalance;
  final String? loanStatus;
  final DateTime? dueDate;
  final String? bucket;
  final Borrower? borrower;
  final int? arrearsDays;
  final String? taskStatus;
  final int? taskOfficer;
  final String? scheduleStatus;
  final Map<String, dynamic>? additionalData;

  LoanRecord({
    this.loanId,
    this.loanAccountNumber,
    this.principalAmount,
    this.outstandingBalance,
    this.loanStatus,
    this.dueDate,
    this.bucket,
    this.borrower,
    this.arrearsDays,
    this.taskStatus,
    this.taskOfficer,
    this.scheduleStatus,
    this.additionalData,
  });

  factory LoanRecord.fromJson(Map<String, dynamic> json) {
    // Parse the new API format
    final borrower = Borrower.fromJson(json);

    return LoanRecord(
      loanId: json['loan_id']?.toString(),
      loanAccountNumber: json['loan_account_number']?.toString(),
      principalAmount: ApiParser.parseDouble(json['principal_amount']),
      outstandingBalance:
          ApiParser.parseDouble(json['due_amount_numeric']) ??
          ApiParser.parseDouble(json['outstanding_balance']),
      loanStatus:
          json['loan_status']?.toString() ??
          json['schedule_status']?.toString(),
      dueDate: ApiParser.parseDateTime(json['due_date']),
      bucket: json['bucket']?.toString(),
      borrower: borrower,
      arrearsDays: ApiParser.parseInt(json['arrears_days']),
      taskStatus: json['task_status']?.toString(),
      taskOfficer: ApiParser.parseInt(json['task_officer']),
      scheduleStatus: json['schedule_status']?.toString(),
      additionalData: {
        'due_amount': json['due_amount']?.toString(),
        'due_amount_numeric': json['due_amount_numeric'],
        'date_today': json['date_today']?.toString(),
        ...?json['additional_data'] as Map<String, dynamic>?,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loan_id': loanId,
      'loan_account_number': loanAccountNumber,
      'principal_amount': principalAmount,
      'outstanding_balance': outstandingBalance,
      'loan_status': loanStatus,
      'due_date': dueDate?.toIso8601String(),
      'bucket': bucket,
      'borrower': borrower?.toJson(),
      'arrears_days': arrearsDays,
      'task_status': taskStatus,
      'task_officer': taskOfficer,
      'schedule_status': scheduleStatus,
      'additional_data': additionalData,
    };
  }

  /// Check if this loan has a valid phone number for dialing
  bool get hasValidPhone => borrower?.hasValidPhone ?? false;

  /// Get the preferred phone number for dialing
  String? get preferredPhone => borrower?.preferredPhone;

  /// Get the preferred contact name
  String? get preferredContactName => borrower?.preferredContactName;

  /// Get a display-friendly account identifier
  String get displayAccountNumber =>
      loanAccountNumber ?? loanId ?? 'Unknown Account';

  /// Get bucket type enum
  BucketType? get bucketType {
    switch (bucket?.toLowerCase()) {
      case 'frontend':
        return BucketType.frontend;
      case 'middlecore':
        return BucketType.middlecore;
      case 'hardcore':
        return BucketType.hardcore;
      default:
        return null;
    }
  }
}

enum BucketType { frontend, middlecore, hardcore }

extension BucketTypeExtension on BucketType {
  String get displayName {
    switch (this) {
      case BucketType.frontend:
        return 'Frontend';
      case BucketType.middlecore:
        return 'Middlecore';
      case BucketType.hardcore:
        return 'Hardcore';
    }
  }

  String get apiValue {
    switch (this) {
      case BucketType.frontend:
        return 'frontend';
      case BucketType.middlecore:
        return 'middlecore';
      case BucketType.hardcore:
        return 'hardcore';
    }
  }
}

class AssignmentData {
  final int userId;
  final String totalAssignedAmount;
  final double totalAssignedAmountNumeric;
  final String maxAmountLimit;
  final String remainingCapacity;
  final int totalRecords;
  final Map<String, List<LoanRecord>> byBucket;
  final List<LoanRecord> allRecords;
  final DateTime assignedAt;

  AssignmentData({
    required this.userId,
    required this.totalAssignedAmount,
    required this.totalAssignedAmountNumeric,
    required this.maxAmountLimit,
    required this.remainingCapacity,
    required this.totalRecords,
    required this.byBucket,
    required this.allRecords,
    required this.assignedAt,
  });

  factory AssignmentData.fromJson(Map<String, dynamic> json) {
    // Parse the new API response format
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final byBucketData = data['by_bucket'] as Map<String, dynamic>? ?? {};
    final byBucket = <String, List<LoanRecord>>{};

    // Parse each bucket
    for (final entry in byBucketData.entries) {
      final bucketName = entry.key;
      final loansData = entry.value as List<dynamic>? ?? [];
      byBucket[bucketName] = loansData
          .map((loan) => LoanRecord.fromJson(loan as Map<String, dynamic>))
          .toList();
    }

    // Parse all records
    final allRecordsData = data['all_records'] as List<dynamic>? ?? [];
    final allRecords = allRecordsData
        .map((loan) => LoanRecord.fromJson(loan as Map<String, dynamic>))
        .toList();

    // Parse timestamp
    final timestamp = data['timestamp'] ?? json['timestamp'];
    final assignedAt = timestamp != null
        ? DateTime.tryParse(timestamp.toString()) ?? DateTime.now()
        : DateTime.now();

    return AssignmentData(
      userId: ApiParser.parseInt(data['user_id']) ?? 0,
      totalAssignedAmount: data['total_assigned_amount']?.toString() ?? '0',
      totalAssignedAmountNumeric:
          (data['total_assigned_amount_numeric'] as num?)?.toDouble() ?? 0.0,
      maxAmountLimit: data['max_amount_limit']?.toString() ?? '0',
      remainingCapacity: data['remaining_capacity']?.toString() ?? '0',
      totalRecords: ApiParser.parseInt(data['total_records']) ?? 0,
      byBucket: byBucket,
      allRecords: allRecords,
      assignedAt: assignedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_assigned_amount': totalAssignedAmount,
      'total_assigned_amount_numeric': totalAssignedAmountNumeric,
      'max_amount_limit': maxAmountLimit,
      'remaining_capacity': remainingCapacity,
      'total_records': totalRecords,
      'by_bucket': byBucket.map(
        (key, value) =>
            MapEntry(key, value.map((loan) => loan.toJson()).toList()),
      ),
      'all_records': allRecords.map((loan) => loan.toJson()).toList(),
      'timestamp': assignedAt.toIso8601String(),
    };
  }

  /// Get loans by bucket type
  List<LoanRecord> getLoansByBucket(BucketType bucketType) {
    return byBucket[bucketType.apiValue] ?? [];
  }

  /// Get count of loans by bucket
  int getCountForBucket(BucketType bucketType) {
    return byBucket[bucketType.apiValue]?.length ?? 0;
  }

  /// Get dialable count for bucket (loans with valid phone numbers)
  int getDialableCountForBucket(BucketType bucketType) {
    return getLoansByBucket(
      bucketType,
    ).where((loan) => loan.hasValidPhone).length;
  }

  /// Get total number of assigned loans
  int get totalLoansCount => allRecords.length;

  /// Get loans with valid phone numbers for dialing
  List<LoanRecord> get dialableLoans =>
      allRecords.where((loan) => loan.hasValidPhone).toList();
}

class AssignmentResponse {
  final bool success;
  final String message;
  final AssignmentData? data;
  final String? error;

  AssignmentResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory AssignmentResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? AssignmentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

/// Request model for assign-loans endpoint
class AssignLoansRequest {
  final String userId;

  AssignLoansRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {'user_id': userId};
  }
}

/// Utility class for safe parsing of API response values
class ApiParser {
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
