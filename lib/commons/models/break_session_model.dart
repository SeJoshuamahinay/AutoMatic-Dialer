import 'package:equatable/equatable.dart';

enum BreakType { shortBreak, lunch, meeting, customerSupportBreak }

extension BreakTypeExtension on BreakType {
  String get name {
    switch (this) {
      case BreakType.shortBreak:
        return 'Short Break';
      case BreakType.lunch:
        return 'Lunch';
      case BreakType.meeting:
        return 'Meeting';
      case BreakType.customerSupportBreak:
        return 'Customer Support Break';
    }
  }

  Duration get duration {
    switch (this) {
      case BreakType.shortBreak:
        return const Duration(minutes: 15);
      case BreakType.lunch:
        return const Duration(hours: 1);
      case BreakType.meeting:
      case BreakType.customerSupportBreak:
        return const Duration(hours: 24); // No fixed duration
    }
  }
}

class BreakSession extends Equatable {
  final int? id;
  final BreakType type;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime date; // Date when the break occurred (for easier filtering)
  final String? reason;
  final bool isActive;

  const BreakSession({
    this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.date,
    this.reason,
    this.isActive = true,
  });

  BreakSession copyWith({
    int? id,
    BreakType? type,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? date,
    String? reason,
    bool? isActive,
  }) {
    return BreakSession(
      id: id ?? this.id,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      isActive: isActive ?? this.isActive,
    );
  }

  Duration get actualDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'date': date.toIso8601String(),
      'reason': reason,
      'isActive': isActive,
    };
  }

  factory BreakSession.fromJson(Map<String, dynamic> json) {
    return BreakSession(
      id: json['id'] as int?,
      type: BreakType.values[json['type'] as int],
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      date: DateTime.parse(json['date'] as String),
      reason: json['reason'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    startTime,
    endTime,
    date,
    reason,
    isActive,
  ];
}
