import 'package:equatable/equatable.dart';

abstract class RcbcPostingState extends Equatable {
  const RcbcPostingState();

  @override
  List<Object?> get props => [];
}

class RcbcPostingInitial extends RcbcPostingState {
  const RcbcPostingInitial();
}

class RcbcPostingLoading extends RcbcPostingState {
  const RcbcPostingLoading();
}

class RcbcPostingLoaded extends RcbcPostingState {
  final List<dynamic> records;
  final String? searchQuery;
  final String? status;
  final String? verification;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isLoading;
  final int page;
  final int perPage;
  final int total;
  final int lastPage;
  final bool hasMore;

  const RcbcPostingLoaded({
    required this.records,
    this.searchQuery,
    this.status,
    this.verification,
    this.dateFrom,
    this.dateTo,
    this.isLoading = false,
    this.page = 1,
    this.perPage = 50,
    this.total = 0,
    this.lastPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [
    records,
    searchQuery,
    status,
    verification,
    dateFrom,
    dateTo,
    isLoading,
    page,
    perPage,
    total,
    lastPage,
    hasMore,
  ];

  RcbcPostingLoaded copyWith({
    List<dynamic>? records,
    String? searchQuery,
    String? status,
    String? verification,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isLoading,
    int? page,
    int? perPage,
    int? total,
    int? lastPage,
    bool? hasMore,
  }) {
    return RcbcPostingLoaded(
      records: records ?? this.records,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      verification: verification ?? this.verification,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class RcbcPostingError extends RcbcPostingState {
  final String message;

  const RcbcPostingError(this.message);

  @override
  List<Object?> get props => [message];
}
