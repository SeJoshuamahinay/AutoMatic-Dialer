import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:lenderly_dialer/blocs/bucket_list/bucket_list_bloc.dart';
import 'package:lenderly_dialer/commons/widgets/bucket_loan_card.dart';
import 'package:lenderly_dialer/blocs/bucket_list/bucket_list_event.dart';
import 'package:lenderly_dialer/blocs/bucket_list/bucket_list_state.dart';
import 'package:lenderly_dialer/commons/services/accounts_bucket_service.dart';
import 'package:lenderly_dialer/commons/services/call_log_service.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';
import 'package:lenderly_dialer/views/follow_up_form_view.dart';
import 'package:lenderly_dialer/views/loan_detail_view.dart';

class FrontEndView extends StatelessWidget {
  const FrontEndView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BucketListBloc(),
      child: const _FrontEndViewBody(),
    );
  }
}

class _FrontEndViewBody extends StatefulWidget {
  const _FrontEndViewBody();

  @override
  State<_FrontEndViewBody> createState() => _FrontEndViewBodyState();
}

class _FrontEndViewBodyState extends State<_FrontEndViewBody> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CallLogService _callLogService = CallLogService();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final session = await SharedPrefsStorageService.getUserSession();
    if (!mounted) return;
    context.read<BucketListBloc>().add(
      BucketListLoad(
        bucket: 'frontend',
        userId: session?.userId.toString() ?? '0',
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<BucketListBloc>().add(const BucketListLoadMore());
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      context.read<BucketListBloc>().add(
        BucketListSearch(_searchController.text),
      );
    });
  }

  void _openLoanDetail(DialerLoanRecord r) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LoanDetailView(loanId: r.loanId)));
  }

  Future<void> _openFollowUp(DialerLoanRecord r) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Loading follow-up form...'),
        duration: Duration(seconds: 10),
      ),
    );
    try {
      final borrowerId =
          r.borrowerId ??
          await AccountsBucketService.getBorrowerIdForLoan(r.loanId);
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FollowUpFormView(
            loanId: r.loanId,
            borrowerId: borrowerId,
            borrowerName: r.fullName,
          ),
        ),
      );
      if (result == true && mounted) _loadInitial();
    } catch (e) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not open follow-up form: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(
    String phone,
    String name, {
    required int loanId,
    int? borrowerId,
  }) async {
    if (!mounted) return;
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final called = await FlutterPhoneDirectCaller.callNumber(phone);
      if (called == true) {
        await _logManualCall(loanId: loanId, borrowerId: borrowerId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              called == true
                  ? 'Calling $name at $phone'
                  : 'Unable to call $phone',
            ),
            backgroundColor: called == true ? null : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logManualCall({required int loanId, int? borrowerId}) async {
    try {
      final session = await SharedPrefsStorageService.getUserSession();
      if (session == null) return;
      final resolvedBorrowerId =
          borrowerId ??
          await AccountsBucketService.getBorrowerIdForLoan(loanId);
      await _callLogService.createRemoteCallLog(
        userId: session.userId,
        borrowerId: resolvedBorrowerId,
        loanId: loanId,
        timeRendered: DateTime.now(),
        callStatus: 'called',
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frontend Bucket',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Early intervention accounts',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade100,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 70,
      ),
      body: BlocBuilder<BucketListBloc, BucketListState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _loadInitial,
            color: Colors.blue,
            child: SafeArea(child: _buildBody(state)),
          );
        },
      ),
    );
  }

  Widget _buildBody(BucketListState state) {
    if (state is BucketListInitial || state is BucketListLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (state is BucketListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitial,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final s = state as BucketListLoaded;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or account number',
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
              suffixIcon: s.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.blue),
                      onPressed: () {
                        _searchController.clear();
                        context.read<BucketListBloc>().add(
                          const BucketListSearch(''),
                        );
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _statTile(
                    Icons.folder,
                    'Total',
                    '${s.totalCount}',
                    Colors.blue.shade400,
                  ),
                  _statTile(
                    Icons.phone,
                    'Dialable',
                    '${s.records.where((r) => r.hasValidPhone).length}',
                    Colors.green.shade400,
                  ),
                  _statTile(
                    Icons.download_outlined,
                    'Loaded',
                    '${s.records.length}',
                    Colors.orange.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: s.records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        s.searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.searchQuery.isNotEmpty
                            ? 'No accounts matching "${s.searchQuery}"'
                            : 'No frontend accounts',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false, // RepaintBoundary inside card
                  itemCount:
                      s.records.length + (s.hasMore || s.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, i) => i < s.records.length - 1
                      ? const SizedBox(height: 8)
                      : const SizedBox.shrink(),
                  itemBuilder: (context, i) {
                    if (i == s.records.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    final r = s.records[i];
                    return BucketLoanCard(
                      key: ValueKey(r.loanId),
                      record: r,
                      index: i,
                      themeColor: Colors.blue,
                      secondaryColor: Colors.green,
                      onViewDetails: () => _openLoanDetail(r),
                      onFollowUp: () => _openFollowUp(r),
                      onCallPhone: r.hasPhone
                          ? () => _makePhoneCall(
                              r.phone!,
                              r.fullName,
                              loanId: r.loanId,
                              borrowerId: r.borrowerId,
                            )
                          : null,
                      onCallMobile: r.hasMobile
                          ? () => _makePhoneCall(
                              r.mobile!,
                              r.fullName,
                              loanId: r.loanId,
                              borrowerId: r.borrowerId,
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _statTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
