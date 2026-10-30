/// A field visit request (e.g. Credit Investigation) assigned to the collector.
/// Filed in Symphony from the pending loans list; worked here.
class VisitRequest {
  final int id;
  final String type;
  final String status; // pending | in_progress | completed | cancelled
  final int loanId;
  final String? loanNumber;
  final int borrowerId;
  final String borrowerName;
  final String? borrowerPhone;
  final String? address;
  final String? requestedBy;
  final String? instructions;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final String? cancelReason;

  const VisitRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.loanId,
    required this.borrowerId,
    required this.borrowerName,
    this.loanNumber,
    this.borrowerPhone,
    this.address,
    this.requestedBy,
    this.instructions,
    this.dueDate,
    this.createdAt,
    this.completedAt,
    this.cancelReason,
  });

  bool get isOpen => status == 'pending' || status == 'in_progress';
  bool get isPending => status == 'pending';

  bool get isOverdue {
    if (!isOpen || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate!.isBefore(today);
  }

  String get statusLabel => switch (status) {
        'pending' => 'Pending',
        'in_progress' => 'In Progress',
        'completed' => 'Completed',
        'cancelled' => 'Cancelled',
        _ => status,
      };

  static DateTime? _date(dynamic v) =>
      v == null || v.toString().isEmpty ? null : DateTime.tryParse(v.toString());

  factory VisitRequest.fromJson(Map<String, dynamic> json) {
    return VisitRequest(
      id: (json['id'] as num).toInt(),
      type: (json['type'] ?? 'Credit Investigation').toString(),
      status: (json['status'] ?? 'pending').toString(),
      loanId: (json['loan_id'] as num).toInt(),
      loanNumber: json['loan_number']?.toString(),
      borrowerId: (json['borrower_id'] as num).toInt(),
      borrowerName: (json['borrower_name'] ?? '').toString(),
      borrowerPhone: json['borrower_phone']?.toString(),
      address: json['address']?.toString(),
      requestedBy: json['requested_by']?.toString(),
      instructions: json['instructions']?.toString(),
      dueDate: _date(json['due_date']),
      createdAt: _date(json['created_at']),
      completedAt: _date(json['completed_at']),
      cancelReason: json['cancel_reason']?.toString(),
    );
  }
}
