import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';
import 'package:lenderly_dialer/commons/services/accounts_bucket_service.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'bucket_list_event.dart';
import 'bucket_list_state.dart';

class BucketListBloc extends Bloc<BucketListEvent, BucketListState> {
  static const int _perPage = 50;

  // Keep track of current context so LoadMore knows bucket/userId/search.
  String _bucket = '';
  String _userId = '';
  String _searchQuery = '';

  BucketListBloc() : super(const BucketListInitial()) {
    on<BucketListLoad>(_onLoad);
    on<BucketListLoadMore>(_onLoadMore);
    on<BucketListSearch>(_onSearch);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoad(
    BucketListLoad event,
    Emitter<BucketListState> emit,
  ) async {
    _bucket = event.bucket;
    _userId = event.userId;
    _searchQuery = event.search ?? '';

    if (_userId.trim().isEmpty || _userId == '0') {
      emit(const BucketListError('No active session. Please log in again.'));
      return;
    }

    emit(const BucketListLoading());

    try {
      final t0 = DateTime.now();
      debugPrint(
        '[BucketListBloc] ▶ LOAD  bucket=$_bucket  userId=$_userId  page=1  search="$_searchQuery"',
      );

      List<DialerLoanRecord> records = const [];
      int total = 0;
      bool hasMore = false;

      try {
        final result = await AccountsBucketService.getDialerDataByBucketPaged(
          _userId,
          _bucket,
          page: 1,
          perPage: _perPage,
          search: _searchQuery.isEmpty ? null : _searchQuery,
        ).timeout(const Duration(seconds: 12));

        records = (result['records'] as List<DialerLoanRecord>?) ?? const [];
        final pagination = result['pagination'] as Map<String, dynamic>?;
        total = (result['total'] as int?) ?? records.length;
        hasMore = pagination?['has_more'] == true;
      } on TimeoutException {
        // Fallback keeps UI usable when paged endpoint stalls.
        debugPrint(
          '[BucketListBloc] ⏱ PAGED TIMEOUT - falling back to legacy endpoint',
        );
        var all = await AccountsBucketService.getDialerDataByBucket(
          _userId,
          _bucket,
        ).timeout(const Duration(seconds: 12));

        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          all = all
              .where(
                (r) =>
                    r.fullName.toLowerCase().contains(q) ||
                    r.accountNumber.toLowerCase().contains(q),
              )
              .toList();
        }

        total = all.length;
        records = all.take(_perPage).toList(growable: false);
        hasMore = all.length > _perPage;
      }

      final elapsedMs = DateTime.now().difference(t0).inMilliseconds;

      debugPrint(
        '[BucketListBloc] ✔ LOAD DONE  records=${records.length}  total=$total  hasMore=$hasMore  totalMs=${elapsedMs}ms',
      );

      emit(
        BucketListLoaded(
          records: records,
          totalCount: total,
          currentPage: 1,
          hasMore: hasMore,
          searchQuery: _searchQuery,
        ),
      );
    } on AuthSessionExpiredException {
      debugPrint('[BucketListBloc] ✖ SESSION EXPIRED during load');
      emit(const BucketListError('Session expired. Please log in again.'));
    } catch (e) {
      debugPrint('[BucketListBloc] ✖ LOAD ERROR: $e');
      emit(BucketListError('Failed to load $_bucket accounts: $e'));
    }
  }

  Future<void> _onLoadMore(
    BucketListLoadMore event,
    Emitter<BucketListState> emit,
  ) async {
    final current = state;
    if (current is! BucketListLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;

    try {
      final t0 = DateTime.now();
      debugPrint(
        '[BucketListBloc] ▶ LOAD MORE  bucket=$_bucket  page=$nextPage  search="$_searchQuery"',
      );

      final result = await AccountsBucketService.getDialerDataByBucketPaged(
        _userId,
        _bucket,
        page: nextPage,
        perPage: _perPage,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      final elapsedMs = DateTime.now().difference(t0).inMilliseconds;
      final newRecords = result['records'] as List<DialerLoanRecord>;
      final pagination = result['pagination'] as Map<String, dynamic>?;
      final hasMore = pagination?['has_more'] == true;

      debugPrint(
        '[BucketListBloc] ✔ LOAD MORE DONE  page=$nextPage  newRecords=${newRecords.length}  hasMore=$hasMore  totalMs=${elapsedMs}ms',
      );

      emit(
        current.copyWith(
          records: [...current.records, ...newRecords],
          currentPage: nextPage,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } on AuthSessionExpiredException {
      debugPrint('[BucketListBloc] ✖ SESSION EXPIRED during loadMore');
      emit(current.copyWith(isLoadingMore: false));
    } catch (e) {
      debugPrint('[BucketListBloc] ✖ LOAD MORE ERROR page=$nextPage: $e');
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSearch(
    BucketListSearch event,
    Emitter<BucketListState> emit,
  ) async {
    if (event.query == _searchQuery) return;
    debugPrint('[BucketListBloc] 🔍 SEARCH  query="${event.query}"');
    add(BucketListLoad(bucket: _bucket, userId: _userId, search: event.query));
  }
}
