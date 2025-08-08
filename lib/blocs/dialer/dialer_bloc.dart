import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:lenderly_dialer/commons/repositories/base_repository.dart';
import '../../commons/models/call_contact_model.dart';
import '../../commons/models/loan_models.dart';
import '../../commons/services/accounts_bucket_service.dart';
import 'dialer_event.dart';
import 'dialer_state.dart' as state;

class DialerBloc extends Bloc<DialerEvent, state.DialerState> {
  final BaseRepository _repository;
  List<CallContact> _currentQueue = [];
  int _currentIndex = 0;

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
      // Skip permission request for web platform
      // On web, url_launcher will handle permission prompts

      // Get pending contacts
      _currentQueue = await _repository.getPendingContacts();

      if (_currentQueue.isEmpty) {
        emit(const state.DialerError(message: 'No pending contacts to call'));
        return;
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

      // Mark contact as called
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
      // Update the contact with the note
      await _repository.updateContact(event.contactId, 'called', event.note);

      if (_currentIndex >= _currentQueue.length) return;

      final contact = _currentQueue[_currentIndex].copyWith(
        status: 'called',
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
      _currentQueue.clear();
      _currentIndex = 0;

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
}
