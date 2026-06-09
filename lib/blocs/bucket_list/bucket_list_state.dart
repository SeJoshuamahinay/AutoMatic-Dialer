import 'package:equatable/equatable.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';

abstract class BucketListState extends Equatable {
  const BucketListState();

  @override
  List<Object?> get props => [];
}

/// Initial / not yet loaded.
class BucketListInitial extends BucketListState {
  const BucketListInitial();
}

/// Loading page 1 (full-screen spinner).
class BucketListLoading extends BucketListState {
  const BucketListLoading();
}

/// Data loaded — both initial load and after appending more pages.
class BucketListLoaded extends BucketListState {
  final List<DialerLoanRecord> records;
  final int totalCount;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;

  const BucketListLoaded({
    required this.records,
    required this.totalCount,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.searchQuery = '',
  });

  BucketListLoaded copyWith({
    List<DialerLoanRecord>? records,
    int? totalCount,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
  }) {
    return BucketListLoaded(
      records: records ?? this.records,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    records,
    totalCount,
    currentPage,
    hasMore,
    isLoadingMore,
    searchQuery,
  ];
}

/// Error state.
class BucketListError extends BucketListState {
  final String message;

  const BucketListError(this.message);

  @override
  List<Object?> get props => [message];
}
