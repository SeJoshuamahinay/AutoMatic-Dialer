import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/blocs/rcbc_posting/rcbc_posting_event.dart';
import 'package:lenderly_dialer/blocs/rcbc_posting/rcbc_posting_state.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:intl/intl.dart';

class RcbcPostingBloc extends Bloc<RcbcPostingEvent, RcbcPostingState> {
  Timer? _debounce;

  RcbcPostingBloc() : super(const RcbcPostingInitial()) {
    on<FetchRcbcPostings>(_onFetch);
    on<RcbcPostingSearchChanged>(_onSearchChanged);
    on<RcbcPostingFiltersChanged>(_onFiltersChanged);
    on<ClearRcbcPostingFilters>(_onClearFilters);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void _debouncedFetch(String query) {
    final current = state is RcbcPostingLoaded ? state as RcbcPostingLoaded : null;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      add(FetchRcbcPostings(
        searchQuery: query.isEmpty ? null : query,
        status: current?.status,
        verification: current?.verification,
        dateFrom: current?.dateFrom,
        dateTo: current?.dateTo,
      ));
    });
  }

  Future<void> _onSearchChanged(
    RcbcPostingSearchChanged event,
    Emitter<RcbcPostingState> emit,
  ) async {
    if (state is RcbcPostingLoaded) {
      final current = state as RcbcPostingLoaded;
      final searchQuery = event.query.isEmpty ? null : event.query;
      emit(current.copyWith(searchQuery: searchQuery));
    }
    _debouncedFetch(event.query);
  }

  Future<void> _onFiltersChanged(
    RcbcPostingFiltersChanged event,
    Emitter<RcbcPostingState> emit,
  ) async {
    final currentSearch = state is RcbcPostingLoaded
        ? (state as RcbcPostingLoaded).searchQuery
        : null;
    if (state is RcbcPostingLoaded) {
      final current = state as RcbcPostingLoaded;
      emit(
        current.copyWith(
          status: event.status,
          verification: event.verification,
          dateFrom: event.dateFrom,
          dateTo: event.dateTo,
        ),
      );
    }
    add(
      FetchRcbcPostings(
        searchQuery: currentSearch,
        status: event.status,
        verification: event.verification,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ),
    );
  }

  Future<void> _onClearFilters(
    ClearRcbcPostingFilters event,
    Emitter<RcbcPostingState> emit,
  ) async {
    add(const FetchRcbcPostings(status: 'all', verification: 'all'));
  }

  String _buildQueryString({
    String? searchQuery,
    String? status,
    String? verification,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int perPage = 50,
  }) {
    final params = <String, String>{};
    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['filter[search]'] = searchQuery;
    }
    if (status != null && status != 'all') {
      params['status'] = status;
    }
    if (verification != null && verification != 'all') {
      params['verification'] = verification;
    }
    if (dateFrom != null) {
      params['filter[date_from]'] = DateFormat('yyyy-MM-dd').format(dateFrom);
    }
    if (dateTo != null) {
      params['filter[date_to]'] = DateFormat('yyyy-MM-dd').format(dateTo);
    }
    if (page > 1) {
      params['page'] = page.toString();
    }
    if (perPage != 50) {
      params['per_page'] = perPage.toString();
    }
    if (params.isEmpty) return '';
    return '?${params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&')}';
  }

  Future<void> _onFetch(
    FetchRcbcPostings event,
    Emitter<RcbcPostingState> emit,
  ) async {
    if (state is RcbcPostingLoaded && event.page > 1) {
      emit((state as RcbcPostingLoaded).copyWith(isLoading: true));
    } else if (state is! RcbcPostingLoaded || event.page == 1) {
      emit(const RcbcPostingLoading());
    }

    final status = event.status ?? 'pending';
    final verification = event.verification;

    try {
      final session = await SharedPrefsStorageService.getUserSession();
      final userId = session?.userId;

      final query = _buildQueryString(
        searchQuery: event.searchQuery,
        status: status,
        verification: verification,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        page: event.page,
        perPage: event.perPage,
      );

      final endpoint = userId != null
          ? '/api/rcbc-payment-verifications/submitted-by?submitted_by=$userId${query.replaceFirst('?', '&')}'
          : '/api/rcbc-payment-verifications/submitted-by$query';

      final response = await ApiClient.get(endpoint);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        List<dynamic> rawList;
        int total = 0;
        int lastPage = 1;
        bool hasMore = false;

        if (body is Map && body['success'] == true && body['records'] is List) {
          rawList = body['records'] as List<dynamic>;
          final pagination = body['pagination'] as Map<String, dynamic>?;
          if (pagination != null) {
            total = pagination['total'] as int? ?? 0;
            lastPage = pagination['last_page'] as int? ?? 1;
            hasMore = pagination['has_more'] as bool? ?? false;
          }
        } else if (body is Map && body['success'] == true && body['posting'] is List) {
          rawList = body['posting'] as List<dynamic>;
        } else if (body is List) {
          rawList = body;
        } else if (body is Map && body['data'] is List) {
          rawList = body['data'] as List<dynamic>;
        } else {
          rawList = [];
        }

        final mergedRecords = event.page > 1 && state is RcbcPostingLoaded
            ? [...(state as RcbcPostingLoaded).records, ...rawList]
            : rawList;

        emit(
          RcbcPostingLoaded(
            records: mergedRecords,
            searchQuery: event.searchQuery,
            status: status,
            verification: verification,
            dateFrom: event.dateFrom,
            dateTo: event.dateTo,
            page: event.page,
            perPage: event.perPage,
            total: total,
            lastPage: lastPage,
            hasMore: hasMore,
          ),
        );
      } else {
        String msg = 'Failed to load records (HTTP ${response.statusCode})';
        try {
          final b = jsonDecode(response.body) as Map<String, dynamic>;
          if (b['message'] != null) msg = b['message'].toString();
        } catch (_) {}
        emit(RcbcPostingError(msg));
      }
    } catch (e) {
      emit(RcbcPostingError('Network error: $e'));
    }
  }
}
