import 'package:equatable/equatable.dart';

abstract class BucketListEvent extends Equatable {
  const BucketListEvent();

  @override
  List<Object?> get props => [];
}

/// Load first page — clears existing list. Called on init or search change.
class BucketListLoad extends BucketListEvent {
  final String bucket;
  final String userId;
  final String? search;

  const BucketListLoad({
    required this.bucket,
    required this.userId,
    this.search,
  });

  @override
  List<Object?> get props => [bucket, userId, search];
}

/// Append next page (triggered by scroll near bottom).
class BucketListLoadMore extends BucketListEvent {
  const BucketListLoadMore();
}

/// Search text changed — resets and re-fetches page 1.
class BucketListSearch extends BucketListEvent {
  final String query;

  const BucketListSearch(this.query);

  @override
  List<Object?> get props => [query];
}
