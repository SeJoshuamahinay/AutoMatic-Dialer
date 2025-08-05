import 'package:equatable/equatable.dart';

class CallContact extends Equatable {
  final int? id;
  final int? loanId;
  final String borrowerName;
  final String borrowerPhone;
  final String? coMakerName;
  final String? coMakerPhone;
  final String status;
  final String? note;

  const CallContact({
    this.id,
    this.loanId,
    required this.borrowerName,
    required this.borrowerPhone,
    this.coMakerName,
    this.coMakerPhone,
    this.status = 'pending',
    this.note,
  });

  CallContact copyWith({
    int? id,
    int? loanId,
    String? borrowerName,
    String? borrowerPhone,
    String? coMakerName,
    String? coMakerPhone,
    String? status,
    String? note,
  }) {
    return CallContact(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerPhone: borrowerPhone ?? this.borrowerPhone,
      coMakerName: coMakerName ?? this.coMakerName,
      coMakerPhone: coMakerPhone ?? this.coMakerPhone,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loanId': loanId,
      'borrowerName': borrowerName,
      'borrowerPhone': borrowerPhone,
      'coMakerName': coMakerName,
      'coMakerPhone': coMakerPhone,
      'status': status,
      'note': note,
    };
  }

  factory CallContact.fromJson(Map<String, dynamic> json) {
    return CallContact(
      id: json['id'],
      loanId: json['loanId'],
      borrowerName: json['borrowerName'] ?? '',
      borrowerPhone: json['borrowerPhone'] ?? '',
      coMakerName: json['coMakerName'],
      coMakerPhone: json['coMakerPhone'],
      status: json['status'] ?? 'pending',
      note: json['note'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    loanId,
    borrowerName,
    borrowerPhone,
    coMakerName,
    coMakerPhone,
    status,
    note,
  ];
}
