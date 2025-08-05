import 'package:equatable/equatable.dart';
import '../../commons/models/call_contact_model.dart';

abstract class DialerState extends Equatable {
  const DialerState();

  @override
  List<Object?> get props => [];
}

class DialerInitial extends DialerState {
  const DialerInitial();
}

class DialerLoading extends DialerState {
  const DialerLoading();
}

class DialerLoaded extends DialerState {
  final List<CallContact> contacts;
  final List<CallContact> pendingContacts;
  final int totalContacts;
  final int calledContacts;

  const DialerLoaded({
    required this.contacts,
    required this.pendingContacts,
    required this.totalContacts,
    required this.calledContacts,
  });

  @override
  List<Object?> get props => [
    contacts,
    pendingContacts,
    totalContacts,
    calledContacts,
  ];

  DialerLoaded copyWith({
    List<CallContact>? contacts,
    List<CallContact>? pendingContacts,
    int? totalContacts,
    int? calledContacts,
  }) {
    return DialerLoaded(
      contacts: contacts ?? this.contacts,
      pendingContacts: pendingContacts ?? this.pendingContacts,
      totalContacts: totalContacts ?? this.totalContacts,
      calledContacts: calledContacts ?? this.calledContacts,
    );
  }
}

class DialingInProgress extends DialerState {
  final CallContact currentContact;
  final List<CallContact> remainingContacts;
  final int totalContacts;
  final int calledContacts;

  const DialingInProgress({
    required this.currentContact,
    required this.remainingContacts,
    required this.totalContacts,
    required this.calledContacts,
  });

  @override
  List<Object?> get props => [
    currentContact,
    remainingContacts,
    totalContacts,
    calledContacts,
  ];
}

class CallEnded extends DialerState {
  final CallContact contact;
  final List<CallContact> remainingContacts;
  final int totalContacts;
  final int calledContacts;

  const CallEnded({
    required this.contact,
    required this.remainingContacts,
    required this.totalContacts,
    required this.calledContacts,
  });

  @override
  List<Object?> get props => [
    contact,
    remainingContacts,
    totalContacts,
    calledContacts,
  ];
}

class QueueCompleted extends DialerState {
  final int totalContacts;
  final int calledContacts;

  const QueueCompleted({
    required this.totalContacts,
    required this.calledContacts,
  });

  @override
  List<Object?> get props => [totalContacts, calledContacts];
}

class DialerError extends DialerState {
  final String message;

  const DialerError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NoteSaved extends DialerState {
  final CallContact contact;
  final List<CallContact> remainingContacts;
  final int totalContacts;
  final int calledContacts;

  const NoteSaved({
    required this.contact,
    required this.remainingContacts,
    required this.totalContacts,
    required this.calledContacts,
  });

  @override
  List<Object?> get props => [
    contact,
    remainingContacts,
    totalContacts,
    calledContacts,
  ];
}
