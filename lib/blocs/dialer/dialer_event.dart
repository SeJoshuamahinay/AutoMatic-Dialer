import 'package:equatable/equatable.dart';

abstract class DialerEvent extends Equatable {
  const DialerEvent();

  @override
  List<Object?> get props => [];
}

class StartDialing extends DialerEvent {
  const StartDialing();
}

class NextCall extends DialerEvent {
  const NextCall();
}

class StopDialing extends DialerEvent {
  const StopDialing();
}

class SaveNote extends DialerEvent {
  final int contactId;
  final String note;

  const SaveNote({required this.contactId, required this.note});

  @override
  List<Object?> get props => [contactId, note];
}

class FetchNumbers extends DialerEvent {
  const FetchNumbers();
}

class CallEnded extends DialerEvent {
  final int contactId;

  const CallEnded({required this.contactId});

  @override
  List<Object?> get props => [contactId];
}

class RefreshNumbers extends DialerEvent {
  const RefreshNumbers();
}
