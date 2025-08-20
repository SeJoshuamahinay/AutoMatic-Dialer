import 'package:lenderly_dialer/commons/models/call_log_model.dart';

import '../models/call_contact_model.dart';
import '../models/loan_models.dart';
import '../../blocs/dialer/dialer_bloc.dart';
import '../../blocs/dialer/dialer_event.dart';
import '../../blocs/dialer/dialer_state.dart' as state;

class DialerPresenter {
  final DialerBloc _dialerBloc;

  DialerPresenter(this._dialerBloc);

  // Initialize and fetch numbers
  void initialize() {
    _dialerBloc.add(const FetchNumbers());
  }

  // Start dialing process
  void startDialing() {
    _dialerBloc.add(const StartDialing());
  }

  // Stop dialing process
  void stopDialing() {
    _dialerBloc.add(const StopDialing());
  }

  // Move to next call
  void nextCall() {
    _dialerBloc.add(const NextCall());
  }

  // Save note for a contact
  void saveNote(int contactId, String note, CallStatus status) {
    _dialerBloc.add(SaveNote(contactId: contactId, note: note, status: status));
  }

  // Refresh numbers from API
  void refreshNumbers() {
    _dialerBloc.add(const RefreshNumbers());
  }

  // Mark call as ended
  void markCallEnded(int contactId) {
    _dialerBloc.add(CallEnded(contactId: contactId));
  }

  // Start auto-dialing co-makers for a specific bucket
  void startCoMakerDialingForBucket(
    BucketType bucketType,
    AssignmentData assignmentData,
  ) {
    _dialerBloc.add(
      StartCoMakerDialingForBucket(
        bucketType: bucketType,
        assignmentData: assignmentData,
      ),
    );
  }

  // Start auto-dialing all contacts for a specific bucket
  void startAllContactsDialingForBucket(
    BucketType bucketType,
    AssignmentData assignmentData,
  ) {
    _dialerBloc.add(
      StartAllContactsDialingForBucket(
        bucketType: bucketType,
        assignmentData: assignmentData,
      ),
    );
  }

  // Start auto-dialing borrowers for a specific bucket
  void startBorrowerDialingForBucket(
    BucketType bucketType,
    AssignmentData assignmentData,
  ) {
    _dialerBloc.add(
      StartBorrowerDialingForBucket(
        bucketType: bucketType,
        assignmentData: assignmentData,
      ),
    );
  }

  // Get the current state stream
  Stream<state.DialerState> get stateStream => _dialerBloc.stream;

  // Get the current state
  state.DialerState get currentState => _dialerBloc.state;

  // Check if dialing is in progress
  bool get isDialingInProgress => currentState is state.DialingInProgress;

  // Get current contact if dialing
  CallContact? get currentContact {
    final currentState = this.currentState;
    if (currentState is state.DialingInProgress) {
      return currentState.currentContact;
    }
    return null;
  }

  // Get remaining contacts count
  int get remainingContactsCount {
    final currentState = this.currentState;
    if (currentState is state.DialingInProgress) {
      return currentState.remainingContacts.length;
    }
    if (currentState is state.DialerLoaded) {
      return currentState.pendingContacts.length;
    }
    return 0;
  }

  // Get total contacts count
  int get totalContactsCount {
    final currentState = this.currentState;
    if (currentState is state.DialerLoaded) {
      return currentState.totalContacts;
    }
    if (currentState is state.DialingInProgress) {
      return currentState.totalContacts;
    }
    if (currentState is state.QueueCompleted) {
      return currentState.totalContacts;
    }
    return 0;
  }

  // Get called contacts count
  int get calledContactsCount {
    final currentState = this.currentState;
    if (currentState is state.DialerLoaded) {
      return currentState.calledContacts;
    }
    if (currentState is state.DialingInProgress) {
      return currentState.calledContacts;
    }
    if (currentState is state.QueueCompleted) {
      return currentState.calledContacts;
    }
    return 0;
  }

  // Get all contacts
  List<CallContact> get allContacts {
    final currentState = this.currentState;
    if (currentState is state.DialerLoaded) {
      return currentState.contacts;
    }
    return [];
  }

  // Get pending contacts
  List<CallContact> get pendingContacts {
    final currentState = this.currentState;
    if (currentState is state.DialerLoaded) {
      return currentState.pendingContacts;
    }
    if (currentState is state.DialingInProgress) {
      return currentState.remainingContacts;
    }
    return [];
  }

  // Check if queue is completed
  bool get isQueueCompleted => currentState is state.QueueCompleted;

  // Check if there's an error
  bool get hasError => currentState is state.DialerError;

  // Get error message
  String get errorMessage {
    final currentState = this.currentState;
    if (currentState is state.DialerError) {
      return currentState.message;
    }
    return '';
  }

  // Check if loading
  bool get isLoading => currentState is state.DialerLoading;

  // Check if call ended and waiting for note
  bool get isCallEnded => currentState is state.CallEnded;

  // Get the contact for which call ended
  CallContact? get endedCallContact {
    final currentState = this.currentState;
    if (currentState is state.CallEnded) {
      return currentState.contact;
    }
    return null;
  }

  // Check if note was saved
  bool get isNoteSaved => currentState is state.NoteSaved;

  // Dispose resources
  void dispose() {
    _dialerBloc.close();
  }
}
