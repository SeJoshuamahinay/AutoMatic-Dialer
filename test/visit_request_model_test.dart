import 'package:flutter_test/flutter_test.dart';
import 'package:lenderly_dialer/commons/models/visit_request_model.dart';

Map<String, dynamic> _json({String status = 'pending', String? due}) => {
      'id': 7,
      'type': 'Credit Investigation',
      'status': status,
      'loan_id': 4236,
      'loan_number': 'LOAN-4240',
      'borrower_id': 10511,
      'borrower_name': 'AGNES MANDIGMA',
      'borrower_phone': '+639632407485',
      'address': 'Salawag, DASMARIÑAS, CAVITE',
      'requested_by': 'Ana Cruz',
      'instructions': 'Verify residence',
      'due_date': due,
      'created_at': '2026-10-12 09:00:00',
      'completed_at': null,
      'cancel_reason': null,
    };

void main() {
  test('parses the Symphony payload', () {
    final r = VisitRequest.fromJson(_json(due: '2026-10-20'));
    expect(r.id, 7);
    expect(r.loanNumber, 'LOAN-4240');
    expect(r.borrowerPhone, '+639632407485');
    expect(r.dueDate, DateTime(2026, 10, 20));
    expect(r.isOpen, isTrue);
    expect(r.isPending, isTrue);
    expect(r.statusLabel, 'Pending');
  });

  test('open request past its due date is overdue', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final due = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    expect(VisitRequest.fromJson(_json(status: 'in_progress', due: due)).isOverdue, isTrue);
    expect(VisitRequest.fromJson(_json(status: 'completed', due: due)).isOverdue, isFalse);
  });

  test('due today is not overdue', () {
    final now = DateTime.now();
    final due = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    expect(VisitRequest.fromJson(_json(due: due)).isOverdue, isFalse);
  });
}
