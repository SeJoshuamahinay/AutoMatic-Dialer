class UserInfo {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? fullName;

  const UserInfo({
    required this.id,
    this.firstName,
    this.lastName,
    this.fullName,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final fn = json['first_name']?.toString();
    final ln = json['last_name']?.toString();
    return UserInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      firstName: fn,
      lastName: ln,
      fullName: json['full_name']?.toString() ?? [fn, ln].where((n) => n != null).join(' '),
    );
  }

  String get displayName => fullName ?? 'User #$id';
}

class LoanInfo {
  final int id;
  final String? uniqueNumber;
  final String? borrowerName;
  final String? borrowerFirstName;
  final String? borrowerLastName;

  const LoanInfo({
    required this.id,
    this.uniqueNumber,
    this.borrowerName,
    this.borrowerFirstName,
    this.borrowerLastName,
  });

  factory LoanInfo.fromJson(Map<String, dynamic> json) {
    String? bName;
    String? bFn;
    String? bLn;
    if (json['borrower'] is Map<String, dynamic>) {
      final b = json['borrower'] as Map<String, dynamic>;
      bFn = b['first_name']?.toString();
      bLn = b['last_name']?.toString();
      bName = b['full_name']?.toString() ?? [bFn, bLn].where((n) => n != null).join(' ');
    }
    return LoanInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      uniqueNumber: json['unique_number']?.toString(),
      borrowerName: bName,
      borrowerFirstName: bFn,
      borrowerLastName: bLn,
    );
  }

  String get displayBorrower => borrowerName ?? '—';
  String get displayUnique => uniqueNumber ?? '—';
}

class RcbcPaymentPosting {
  final int id;
  final int? loanId;
  final int? loanScheduleId;
  final String? dueDate;
  final String? paymentDate;
  final String? referenceNumber;
  final double? amount;
  final bool? multipleLoanRepayment;
  final double? multipleLoanRepaymentAmount;
  final String? status;
  final String? remarks;
  final UserInfo? submittedBy;
  final String? submittedAt;
  final bool? isVerified;
  final String? verifiedAt;
  final UserInfo? approvedBy;
  final String? approvedAt;
  final String? approvedRemarks;
  final int? disapprovedBy;
  final String? disapprovedAt;
  final String? disapprovedRemarks;
  final int? postedBy;
  final String? postedAt;
  final String? postedRemarks;
  final int? reversedBy;
  final String? reversedAt;
  final String? reversedRemarks;
  final int? undisbursedBy;
  final String? undisbursedAt;
  final String? undisbursedRemarks;
  final int? archivedBy;
  final String? archivedAt;
  final String? archivedRemarks;
  final String? rcbcTransactionId;
  final String? createdAt;
  final String? updatedAt;
  final LoanInfo? loan;

  const RcbcPaymentPosting({
    required this.id,
    this.loanId,
    this.loanScheduleId,
    this.dueDate,
    this.paymentDate,
    this.referenceNumber,
    this.amount,
    this.multipleLoanRepayment,
    this.multipleLoanRepaymentAmount,
    this.status,
    this.remarks,
    this.submittedBy,
    this.submittedAt,
    this.isVerified,
    this.verifiedAt,
    this.approvedBy,
    this.approvedAt,
    this.approvedRemarks,
    this.disapprovedBy,
    this.disapprovedAt,
    this.disapprovedRemarks,
    this.postedBy,
    this.postedAt,
    this.postedRemarks,
    this.reversedBy,
    this.reversedAt,
    this.reversedRemarks,
    this.undisbursedBy,
    this.undisbursedAt,
    this.undisbursedRemarks,
    this.archivedBy,
    this.archivedAt,
    this.archivedRemarks,
    this.rcbcTransactionId,
    this.createdAt,
    this.updatedAt,
    this.loan,
  });

  factory RcbcPaymentPosting.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    bool? parseBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is String) return v == '1' || v.toLowerCase() == 'true';
      return null;
    }

    UserInfo? parseUser(dynamic v) {
      if (v is Map<String, dynamic>) return UserInfo.fromJson(v);
      return null;
    }

    LoanInfo? parseLoan(dynamic v) {
      if (v is Map<String, dynamic>) return LoanInfo.fromJson(v);
      return null;
    }

    return RcbcPaymentPosting(
      id: parseInt(json['id']) ?? 0,
      loanId: parseInt(json['loan_id']),
      loanScheduleId: parseInt(json['loan_schedule_id']),
      dueDate: json['due_date']?.toString(),
      paymentDate: json['payment_date']?.toString(),
      referenceNumber: json['reference_number']?.toString(),
      amount: parseDouble(json['amount']),
      multipleLoanRepayment: parseBool(json['multiple_loan_repayment']),
      multipleLoanRepaymentAmount: parseDouble(
        json['multiple_loan_repayment_amount'],
      ),
      status: json['status']?.toString(),
      remarks: json['remarks']?.toString(),
      submittedBy: parseUser(json['submitted_by']),
      submittedAt: json['submitted_at']?.toString(),
      isVerified: parseBool(json['is_verified']),
      verifiedAt: json['verified_at']?.toString(),
      approvedBy: parseUser(json['approved_by']),
      approvedAt: json['approved_at']?.toString(),
      approvedRemarks: json['approved_remarks']?.toString(),
      disapprovedBy: parseInt(json['disapproved_by']),
      disapprovedAt: json['disapproved_at']?.toString(),
      disapprovedRemarks: json['disapproved_remarks']?.toString(),
      postedBy: parseInt(json['posted_by']),
      postedAt: json['posted_at']?.toString(),
      postedRemarks: json['posted_remarks']?.toString(),
      reversedBy: parseInt(json['reversed_by']),
      reversedAt: json['reversed_at']?.toString(),
      reversedRemarks: json['reversed_remarks']?.toString(),
      undisbursedBy: parseInt(json['undisbursed_by']),
      undisbursedAt: json['undisbursed_at']?.toString(),
      undisbursedRemarks: json['undisbursed_remarks']?.toString(),
      archivedBy: parseInt(json['archived_by']),
      archivedAt: json['archived_at']?.toString(),
      archivedRemarks: json['archived_remarks']?.toString(),
      rcbcTransactionId: json['rcbc_transaction_id']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      loan: parseLoan(json['loan']),
    );
  }
}
