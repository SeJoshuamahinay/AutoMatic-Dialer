import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:lenderly_dialer/commons/repositories/base_repository.dart';
import '../../commons/models/call_contact_model.dart';
import '../../commons/models/loan_models.dart';
import '../../commons/models/call_log_model.dart';
import '../../commons/services/accounts_bucket_service.dart';
import '../../commons/services/dialer_database_integration.dart';
import '../../commons/services/shared_prefs_storage_service.dart';
import 'dialer_event.dart';
import 'dialer_state.dart' as state;

class DialerBloc extends Bloc<DialerEvent, state.DialerState> {
  final BaseRepository _repository;
  final DialerDatabaseIntegration _dbIntegration = DialerDatabaseIntegration();

  List<CallContact> _currentQueue = [];
  int _currentIndex = 0;
  int? _currentSessionId;
  int? _currentCallLogId;
  DateTime? _currentCallStartTime;

  // User session data
  int _userId = 1; // Default fallback
  String _agentName = 'System Agent'; // Default fallback

  DialerBloc({required BaseRepository repository})
    : _repository = repository,
      super(const state.DialerInitial()) {
    on<FetchNumbers>(_onFetchNumbers);
    on<StartDialing>(_onStartDialing);
    on<NextCall>(_onNextCall);
    on<StopDialing>(_onStopDialing);
    on<SaveNote>(_onSaveNote);
    on<CallEnded>(_onCallEnded);
    on<RefreshNumbers>(_onRefreshNumbers);
    on<StartCoMakerDialingForBucket>(_onStartCoMakerDialingForBucket);
    on<StartAllContactsDialingForBucket>(_onStartAllContactsDialingForBucket);
    on<StartBorrowerDialingForBucket>(_onStartBorrowerDialingForBucket);

    // Initialize database integration and load user session
    _initializeDatabase();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final userSession = await SharedPrefsStorageService.getUserSession();
      if (userSession != null) {
        _userId = userSession.userId;
        _agentName = userSession.fullName;
      }
    } catch (e) {
      print('Failed to load user session: $e');
      // Keep defaults if loading fails
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      await _dbIntegration.initialize();
    } catch (e) {
      // Handle initialization errors gracefully
      print('Failed to initialize database integration: $e');
    }
  }

  Future<void> _onFetchNumbers(
    FetchNumbers event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      emit(const state.DialerLoading());

      // Check if we have contacts in the database
      final hasContacts = await _repository.hasContacts();

      List<CallContact> contacts;
      if (!hasContacts) {
        // Fetch from API and store
        contacts = await _repository.fetchAndStoreContacts();
      } else {
        // Get from local database
        contacts = await _repository.getAllContacts();
        if (contacts.isEmpty) {
          // If no contacts found, emit an error state
          contacts = [];
          emit(
            state.DialerError(message: 'No contacts found in the database.'),
          );
        }
      }

      final pendingContacts = await _repository.getPendingContacts();
      final totalCount = await _repository.getContactsCount();
      final calledCount = await _repository.getCalledContactsCount();

      emit(
        state.DialerLoaded(
          contacts: contacts,
          pendingContacts: pendingContacts,
          totalContacts: totalCount,
          calledContacts: calledCount,
        ),
      );
    } catch (e) {
      emit(
        state.DialerError(message: 'Failed to fetch numbers: ${e.toString()}'),
      );
    }
  }

  Future<void> _onRefreshNumbers(
    RefreshNumbers event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      emit(const state.DialerLoading());

      // Force fetch from API
      final contacts = await _repository.fetchAndStoreContacts();
      final pendingContacts = await _repository.getPendingContacts();
      final totalCount = await _repository.getContactsCount();
      final calledCount = await _repository.getCalledContactsCount();

      emit(
        state.DialerLoaded(
          contacts: contacts,
          pendingContacts: pendingContacts,
          totalContacts: totalCount,
          calledContacts: calledCount,
        ),
      );
    } catch (e) {
      emit(
        state.DialerError(
          message: 'Failed to refresh numbers: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onStartDialing(
    StartDialing event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      // Get pending contacts
      _currentQueue = await _repository.getPendingContacts();

      if (_currentQueue.isEmpty) {
        emit(const state.DialerError(message: 'No pending contacts to call'));
        return;
      }

      // Start database session
      try {
        _currentSessionId = await _dbIntegration.startDialingSession(
          userId: _userId,
          sessionType: 'manual',
          contacts: _currentQueue,
          agentName: _agentName,
        );
      } catch (e) {
        print('Failed to start database session: $e');
        // Continue without database tracking if it fails
      }

      _currentIndex = 0;
      await _makeCall(emit);
    } catch (e) {
      emit(
        state.DialerError(message: 'Failed to start dialing: ${e.toString()}'),
      );
    }
  }

  Future<void> _onNextCall(
    NextCall event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      _currentIndex++;
      if (_currentIndex >= _currentQueue.length) {
        // Queue completed
        final totalCount = _currentQueue.length;
        final calledCount = _currentQueue.length;
        emit(
          state.QueueCompleted(
            totalContacts: totalCount,
            calledContacts: calledCount,
          ),
        );
        return;
      }
      await _makeCall(emit);
    } catch (e) {
      emit(
        state.DialerError(message: 'Failed to make next call: ${e.toString()}'),
      );
    }
  }

  Future<void> _makeCall(Emitter<state.DialerState> emit) async {
    if (_currentIndex >= _currentQueue.length) return;

    final contact = _currentQueue[_currentIndex];
    final remainingContacts = _currentQueue.sublist(_currentIndex + 1);
    final totalCount = _currentQueue.length;
    final calledCount = _currentIndex;

    // Log call start to database
    _currentCallStartTime = DateTime.now();
    try {
      _currentCallLogId = await _dbIntegration.logCallStart(
        contact: contact,
        sessionId: _currentSessionId,
        userId: _userId,
        agentName: _agentName,
      );
    } catch (e) {
      print('Failed to log call start: $e');
      // Continue without database logging if it fails
    }

    emit(
      state.DialingInProgress(
        currentContact: contact,
        remainingContacts: remainingContacts,
        totalContacts: totalCount,
        calledContacts: calledCount,
      ),
    );

    // Make the actual call using flutter_phone_direct_caller
    try {
      await FlutterPhoneDirectCaller.callNumber(contact.borrowerPhone);
    } catch (e) {
      emit(
        state.DialerError(
          message:
              'Failed to open dialer for ${contact.borrowerPhone}: ${e.toString()}',
        ),
      );
      return;
    }
  }

  Future<void> _onCallEnded(
    CallEnded event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      if (_currentIndex >= _currentQueue.length) return;

      final contact = _currentQueue[_currentIndex];

      // Log call end to database
      if (_currentCallLogId != null && _currentCallStartTime != null) {
        try {
          final callDuration = DateTime.now().difference(
            _currentCallStartTime!,
          );
          await _dbIntegration.logCallEnd(
            callLogId: _currentCallLogId!,
            callDuration: callDuration,
            status: CallStatus.called, // Assume successful if not specified
            notes: null,
            outcome: 'called',
          );
        } catch (e) {
          print('Failed to log call end: $e');
          // Continue even if database logging fails
        }
      }

      // Mark contact as called in repository
      await _repository.updateContact(contact.id!, 'called', null);

      final remainingContacts = _currentQueue.sublist(_currentIndex + 1);
      final totalCount = _currentQueue.length;
      final calledCount = _currentIndex + 1;

      emit(
        state.CallEnded(
          contact: contact,
          remainingContacts: remainingContacts,
          totalContacts: totalCount,
          calledContacts: calledCount,
        ),
      );
    } catch (e) {
      emit(
        state.DialerError(
          message: 'Failed to process call end: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSaveNote(
    SaveNote event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      print(
        '📝 Saving note for contact ${event.contactId} with status: ${event.status.value}',
      );

      // Update the contact with the note in repository
      await _repository.updateContact(
        event.contactId,
        event.status.value,
        event.note,
      );

      // Update call log in database with note
      if (_currentCallLogId != null && _currentCallStartTime != null) {
        try {
          print(
            '📞 Updating call log $_currentCallLogId with status: ${event.status.value}',
          );
          final callDuration = DateTime.now().difference(
            _currentCallStartTime!,
          );
          await _dbIntegration.logCallEnd(
            callLogId: _currentCallLogId!,
            callDuration: callDuration,
            status: event.status,
            notes: event.note,
            outcome: 'completed_with_note',
          );
          print('✅ Successfully updated call log $_currentCallLogId');
        } catch (e) {
          print('❌ Failed to update call log with note: $e');
          // Continue even if database update fails
        }
      } else {
        print(
          '⚠️ No current call log ID or start time found: callLogId=$_currentCallLogId, startTime=$_currentCallStartTime',
        );
      }

      if (_currentIndex >= _currentQueue.length) return;

      final contact = _currentQueue[_currentIndex].copyWith(
        status: event.status.value,
        note: event.note,
      );

      final remainingContacts = _currentQueue.sublist(_currentIndex + 1);
      final totalCount = _currentQueue.length;
      final calledCount = _currentIndex + 1;

      emit(
        state.NoteSaved(
          contact: contact,
          remainingContacts: remainingContacts,
          totalContacts: totalCount,
          calledContacts: calledCount,
        ),
      );
    } catch (e) {
      emit(state.DialerError(message: 'Failed to save note: ${e.toString()}'));
    }
  }

  Future<void> _onStopDialing(
    StopDialing event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      // End database session if active
      if (_currentSessionId != null) {
        try {
          final totalContacts = _currentQueue.length;
          final attempted = _currentIndex;
          final completed = _currentIndex; // Calls that were made

          final stats = DialerDatabaseIntegration.createSessionStats(
            totalContacts: totalContacts,
            attempted: attempted,
            completed: completed,
            successful: completed, // Assume completed calls were successful
            failed: 0,
            noAnswer: 0,
            hangUp: 0,
          );

          await _dbIntegration.endDialingSession(_currentSessionId!, stats);
        } catch (e) {
          print('Failed to end database session: $e');
          // Continue even if database session end fails
        }
      }

      // Reset state
      _currentQueue.clear();
      _currentIndex = 0;
      _currentSessionId = null;
      _currentCallLogId = null;
      _currentCallStartTime = null;

      // Reload the current state
      final contacts = await _repository.getAllContacts();
      final pendingContacts = await _repository.getPendingContacts();
      final totalCount = await _repository.getContactsCount();
      final calledCount = await _repository.getCalledContactsCount();

      emit(
        state.DialerLoaded(
          contacts: contacts,
          pendingContacts: pendingContacts,
          totalContacts: totalCount,
          calledContacts: calledCount,
        ),
      );
    } catch (e) {
      emit(
        state.DialerError(message: 'Failed to stop dialing: ${e.toString()}'),
      );
    }
  }

  Future<void> _onStartCoMakerDialingForBucket(
    StartCoMakerDialingForBucket event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      // Get co-maker prioritized loans from the bucket
      final loans = AccountsBucketService.getCoMakerPrioritizedLoansByBucket(
        event.assignmentData,
        event.bucketType,
      );

      // Filter only loans with co-maker phones
      final coMakerLoans = loans
          .where(
            (loan) =>
                loan.borrower?.coMakerPhone != null &&
                loan.borrower!.coMakerPhone!.isNotEmpty,
          )
          .toList();

      if (coMakerLoans.isEmpty) {
        emit(
          state.DialerError(
            message:
                'No co-maker contacts found in ${event.bucketType.displayName} bucket',
          ),
        );
        return;
      }

      // Convert loans to CallContact objects for co-makers
      _currentQueue = coMakerLoans
          .map(
            (loan) => CallContact(
              id: int.tryParse(loan.loanId ?? '0') ?? 0,
              loanId: int.tryParse(loan.loanId ?? '0') ?? 0,
              borrowerName: loan.borrower?.coMakerName ?? 'Unknown Co-Maker',
              borrowerPhone: loan.borrower?.coMakerPhone ?? '',
              coMakerName: loan.borrower?.borrowerName,
              coMakerPhone: loan.borrower?.borrowerPhone,
              bucket: event.bucketType.apiValue,
              status: 'pending',
            ),
          )
          .toList();

      // Start database session for bucket dialing
      try {
        _currentSessionId = await _dbIntegration.startDialingSession(
          userId: _userId,
          sessionType: 'bucket_comaker',
          contacts: _currentQueue,
          agentName: _agentName,
          bucket: event.bucketType.apiValue,
        );
      } catch (e) {
        print('Failed to start database session for bucket dialing: $e');
        // Continue without database tracking if it fails
      }

      _currentIndex = 0;
      await _makeCall(emit);
    } catch (e) {
      emit(
        state.DialerError(
          message: 'Failed to start co-maker dialing: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onStartAllContactsDialingForBucket(
    StartAllContactsDialingForBucket event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      // Get co-maker prioritized loans from the bucket
      final loans = AccountsBucketService.getCoMakerPrioritizedLoansByBucket(
        event.assignmentData,
        event.bucketType,
      );

      // Filter only loans with valid phone numbers
      final dialableLoans = loans.where((loan) => loan.hasValidPhone).toList();

      if (dialableLoans.isEmpty) {
        emit(
          state.DialerError(
            message:
                'No dialable contacts found in ${event.bucketType.displayName} bucket',
          ),
        );
        return;
      }

      // Convert loans to CallContact objects prioritizing co-makers
      _currentQueue = dialableLoans.map((loan) {
        final borrower = loan.borrower;
        final hasCoMaker =
            borrower?.coMakerPhone != null &&
            borrower!.coMakerPhone!.isNotEmpty;

        if (hasCoMaker) {
          // Use co-maker as primary contact
          return CallContact(
            id: int.tryParse(loan.loanId ?? '0') ?? 0,
            loanId: int.tryParse(loan.loanId ?? '0') ?? 0,
            borrowerName: borrower.coMakerName ?? 'Unknown Co-Maker',
            borrowerPhone: borrower.coMakerPhone!,
            coMakerName: borrower.borrowerName,
            coMakerPhone: borrower.borrowerPhone,
            bucket: event.bucketType.apiValue,
            status: 'pending',
          );
        } else {
          // Use borrower as primary contact
          return CallContact(
            id: int.tryParse(loan.loanId ?? '0') ?? 0,
            loanId: int.tryParse(loan.loanId ?? '0') ?? 0,
            borrowerName: borrower?.borrowerName ?? 'Unknown Borrower',
            borrowerPhone: borrower?.borrowerPhone ?? '',
            coMakerName: borrower?.coMakerName,
            coMakerPhone: borrower?.coMakerPhone,
            bucket: event.bucketType.apiValue,
            status: 'pending',
          );
        }
      }).toList();

      // Start database session for bucket dialing
      try {
        _currentSessionId = await _dbIntegration.startDialingSession(
          userId: _userId,
          sessionType: 'bucket_all',
          contacts: _currentQueue,
          agentName: _agentName,
          bucket: event.bucketType.apiValue,
        );
      } catch (e) {
        print('Failed to start database session for bucket dialing: $e');
        // Continue without database tracking if it fails
      }

      _currentIndex = 0;
      await _makeCall(emit);
    } catch (e) {
      emit(
        state.DialerError(
          message: 'Failed to start bucket dialing: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onStartBorrowerDialingForBucket(
    StartBorrowerDialingForBucket event,
    Emitter<state.DialerState> emit,
  ) async {
    try {
      // Get loans from the bucket
      final loans = AccountsBucketService.getLoansByBucket(
        event.assignmentData,
        event.bucketType,
      );

      // Filter only loans with borrower phones (excluding co-maker only loans)
      final borrowerLoans = loans
          .where(
            (loan) =>
                loan.borrower?.borrowerPhone != null &&
                loan.borrower!.borrowerPhone!.isNotEmpty,
          )
          .toList();

      if (borrowerLoans.isEmpty) {
        emit(
          state.DialerError(
            message:
                'No borrower contacts found in ${event.bucketType.displayName} bucket',
          ),
        );
        return;
      }

      // Convert loans to CallContact objects for borrowers
      _currentQueue = borrowerLoans
          .map(
            (loan) => CallContact(
              id: int.tryParse(loan.loanId ?? '0') ?? 0,
              loanId: int.tryParse(loan.loanId ?? '0') ?? 0,
              borrowerName: loan.borrower?.borrowerName ?? 'Unknown Borrower',
              borrowerPhone: loan.borrower?.borrowerPhone ?? '',
              coMakerName: loan.borrower?.coMakerName,
              coMakerPhone: loan.borrower?.coMakerPhone,
              bucket: event.bucketType.apiValue,
              status: 'pending',
            ),
          )
          .toList();

      // Start database session for bucket dialing
      try {
        _currentSessionId = await _dbIntegration.startDialingSession(
          userId: _userId,
          sessionType: 'bucket_borrower',
          contacts: _currentQueue,
          agentName: _agentName,
          bucket: event.bucketType.apiValue,
        );
      } catch (e) {
        print('Failed to start database session for bucket dialing: $e');
        // Continue without database tracking if it fails
      }

      _currentIndex = 0;
      await _makeCall(emit);
    } catch (e) {
      emit(
        state.DialerError(
          message: 'Failed to start borrower dialing: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    // Clean up database integration
    try {
      await _dbIntegration.dispose();
    } catch (e) {
      print('Failed to dispose database integration: $e');
    }
    return super.close();
  }
}
