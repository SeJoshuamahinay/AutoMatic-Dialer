import 'package:equatable/equatable.dart';

enum CallStatus { pending, finished, noAnswer, hangUp, called }

extension CallStatusExtension on CallStatus {
  String get displayName {
    switch (this) {
      case CallStatus.pending:
        return 'Pending';
      case CallStatus.finished:
        return 'Finished';
      case CallStatus.noAnswer:
        return 'No Answer';
      case CallStatus.hangUp:
        return 'Hang Up';
      case CallStatus.called:
        return 'Called';
    }
  }

  String get value {
    switch (this) {
      case CallStatus.pending:
        return 'pending';
      case CallStatus.finished:
        return 'finished';
      case CallStatus.noAnswer:
        return 'no_answer';
      case CallStatus.hangUp:
        return 'hang_up';
      case CallStatus.called:
        return 'called';
    }
  }

  static CallStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return CallStatus.pending;
      case 'finished':
        return CallStatus.finished;
      case 'no_answer':
        return CallStatus.noAnswer;
      case 'hang_up':
        return CallStatus.hangUp;
      case 'called':
        return CallStatus.called;
      default:
        return CallStatus.pending;
    }
  }
}

class CallLog extends Equatable {
  final int? id;
  final int contactId;
  final DateTime callTime;
  final Duration? callDuration;
  final CallStatus status;
  final String? notes;

  const CallLog({
    this.id,
    required this.contactId,
    required this.callTime,
    this.callDuration,
    required this.status,
    this.notes,
  });

  CallLog copyWith({
    int? id,
    int? contactId,
    DateTime? callTime,
    Duration? callDuration,
    CallStatus? status,
    String? notes,
  }) {
    return CallLog(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      callTime: callTime ?? this.callTime,
      callDuration: callDuration ?? this.callDuration,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'callTime': callTime.toIso8601String(),
      'callDuration': callDuration?.inSeconds,
      'status': status.value,
      'notes': notes,
    };
  }

  factory CallLog.fromJson(Map<String, dynamic> json) {
    return CallLog(
      id: json['id'] as int?,
      contactId: json['contactId'] as int,
      callTime: DateTime.parse(json['callTime'] as String),
      callDuration: json['callDuration'] != null
          ? Duration(seconds: json['callDuration'] as int)
          : null,
      status: CallStatusExtension.fromString(json['status'] as String),
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    contactId,
    callTime,
    callDuration,
    status,
    notes,
  ];
}
