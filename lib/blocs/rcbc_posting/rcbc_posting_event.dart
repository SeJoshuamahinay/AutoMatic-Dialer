import 'package:equatable/equatable.dart';

abstract class RcbcPostingEvent extends Equatable {
  const RcbcPostingEvent();

  @override
  List<Object?> get props => [];
}

class FetchRcbcPostings extends RcbcPostingEvent {
  final String? searchQuery;
  final String? status;
  final String? verification;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int page;
  final int perPage;

  const FetchRcbcPostings({
    this.searchQuery,
    this.status,
    this.verification,
    this.dateFrom,
    this.dateTo,
    this.page = 1,
    this.perPage = 50,
  });

  @override
  List<Object?> get props => [
    searchQuery,
    status,
    verification,
    dateFrom,
    dateTo,
    page,
    perPage,
  ];
}

class RcbcPostingSearchChanged extends RcbcPostingEvent {
  final String query;

  const RcbcPostingSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class RcbcPostingFiltersChanged extends RcbcPostingEvent {
  final String? status;
  final String? verification;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const RcbcPostingFiltersChanged({
    this.status,
    this.verification,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [status, verification, dateFrom, dateTo];
}

class ClearRcbcPostingFilters extends RcbcPostingEvent {
  const ClearRcbcPostingFilters();
}
