import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/blocs/rcbc_posting/rcbc_posting_bloc.dart';
import 'package:lenderly_dialer/blocs/rcbc_posting/rcbc_posting_event.dart';
import 'package:lenderly_dialer/blocs/rcbc_posting/rcbc_posting_state.dart';
import 'package:lenderly_dialer/commons/models/rcbc_posting_model.dart';
import 'package:lenderly_dialer/views/rcbc_posting_request_form.dart';

// ─────────────────────────────────────────────
// View
// ─────────────────────────────────────────────
class RcbcPostingRequestView extends StatefulWidget {
  const RcbcPostingRequestView({super.key});

  @override
  State<RcbcPostingRequestView> createState() => _RcbcPostingRequestViewState();
}

class _RcbcPostingRequestViewState extends State<RcbcPostingRequestView> {
  static const _accentColor = Color.fromARGB(255, 234, 58, 23);
  static const _bgColor = Color(0xFFF1F5F9);

  final NumberFormat _amountFmt = NumberFormat('#,##0.00', 'en_PH');
  final _searchCtrl = TextEditingController();
  final _bloc = RcbcPostingBloc();
  List<RcbcPaymentPosting> _records = [];

  @override
  void initState() {
    super.initState();
    _bloc.add(const FetchRcbcPostings());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _refreshWithCurrentFilters() async {
    final s = _bloc.state;
    if (s is RcbcPostingLoaded) {
      _bloc.add(
        FetchRcbcPostings(
          searchQuery: s.searchQuery,
          status: s.status,
          verification: s.verification,
          dateFrom: s.dateFrom,
          dateTo: s.dateTo,
        ),
      );
    } else {
      _bloc.add(const FetchRcbcPostings());
    }
  }

  bool _hasActiveFilters(RcbcPostingLoaded state) {
    return (state.searchQuery != null && state.searchQuery!.isNotEmpty) ||
        (state.status != null && state.status != 'all') ||
        (state.verification != null && state.verification != 'all') ||
        state.dateFrom != null ||
        state.dateTo != null;
  }

  // ─── Helpers ───────────────────────────────

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy  hh:mm a').format(dt.toLocal());
    } catch (_) {
      return raw;
    }
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
        return const Color(0xFF16A34A);
      case 'posted':
        return const Color(0xFF0369A1);
      case 'disapproved':
        return const Color(0xFFDC2626);
      case 'reversed':
        return const Color(0xFF9333EA);
      case 'archived':
        return const Color(0xFF78716C);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  // ─── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Posting Requests',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add, size: 22),
          label: const Text(
            'Request Posting',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          onPressed: () async {
            final result = await RcbcPostingRequestForm.open(context);
            if (result == true && mounted) {
              _refreshWithCurrentFilters();
            }
          },
        ),
        body: BlocConsumer<RcbcPostingBloc, RcbcPostingState>(
          listener: (context, state) {
            if (state is RcbcPostingLoaded) {
              _records = state.records
                  .map(
                    (e) =>
                        RcbcPaymentPosting.fromJson(e as Map<String, dynamic>),
                  )
                  .toList();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                if (state is RcbcPostingLoaded) _buildFilterBar(context, state),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, RcbcPostingLoaded state) {
    final bloc = context.read<RcbcPostingBloc>();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        children: [
          // Search row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search reference, loan ID, borrower…',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                bloc.add(const RcbcPostingSearchChanged(''));
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _accentColor),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    onSubmitted: (_) => bloc.add(
                      RcbcPostingSearchChanged(_searchCtrl.text.trim()),
                    ),
                    onChanged: (v) => bloc.add(RcbcPostingSearchChanged(v)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: Material(
                  color: _hasActiveFilters(state)
                      ? _accentColor.withValues(alpha: 0.1)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showFilterSheet(context, state),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.filter_list,
                        size: 22,
                        color: _accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Active filter chips
          if (_hasActiveFilters(state)) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (state.status != null && state.status != 'all')
                      _filterChip('Status: ${state.status!.toUpperCase()}', () {
                        bloc.add(
                          RcbcPostingFiltersChanged(
                            status: 'all',
                            verification: state.verification,
                            dateFrom: state.dateFrom,
                            dateTo: state.dateTo,
                          ),
                        );
                      }),
                    if (state.verification != null &&
                        state.verification != 'all')
                      _filterChip('Verification: ${state.verification}', () {
                        bloc.add(
                          RcbcPostingFiltersChanged(
                            status: state.status,
                            verification: 'all',
                            dateFrom: state.dateFrom,
                            dateTo: state.dateTo,
                          ),
                        );
                      }),
                    if (state.dateFrom != null)
                      _filterChip(
                        'From: ${DateFormat('MMM d').format(state.dateFrom!)}',
                        () {
                          bloc.add(
                            RcbcPostingFiltersChanged(
                              status: state.status,
                              verification: state.verification,
                              dateFrom: null,
                              dateTo: state.dateTo,
                            ),
                          );
                        },
                      ),
                    if (state.dateTo != null)
                      _filterChip(
                        'To: ${DateFormat('MMM d').format(state.dateTo!)}',
                        () {
                          bloc.add(
                            RcbcPostingFiltersChanged(
                              status: state.status,
                              verification: state.verification,
                              dateFrom: state.dateFrom,
                              dateTo: null,
                            ),
                          );
                        },
                      ),
                    if (state.searchQuery != null &&
                        state.searchQuery!.isNotEmpty)
                      _filterChip('Search: "${state.searchQuery}"', () {
                        _searchCtrl.clear();
                        bloc.add(const RcbcPostingSearchChanged(''));
                      }),
                    const SizedBox(width: 4),
                    ActionChip(
                      label: const Text(
                        'Clear all',
                        style: TextStyle(fontSize: 11),
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        bloc.add(const ClearRcbcPostingFilters());
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        backgroundColor: _accentColor.withValues(alpha: 0.08),
        side: BorderSide.none,
      ),
    );
  }

  void _showFilterSheet(BuildContext context, RcbcPostingLoaded currentState) {
    final bloc = context.read<RcbcPostingBloc>();
    String? localStatus = currentState.status;
    String? localVerification = currentState.verification;
    DateTime? localDateFrom = currentState.dateFrom;
    DateTime? localDateTo = currentState.dateTo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            localStatus = null;
                            localVerification = null;
                            localDateFrom = null;
                            localDateTo = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Status
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _filterDropdown(
                    value: localStatus,
                    items: const [
                      'all',
                      'pending',
                      'posted',
                      'reversed',
                      'disapproved',
                      'undisbursed',
                    ],
                    displayFn: (s) => s == 'all'
                        ? 'All'
                        : s[0].toUpperCase() + s.substring(1),
                    onChanged: (v) => setSheetState(() => localStatus = v),
                  ),
                  const SizedBox(height: 12),

                  // Verification
                  const Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _filterDropdown(
                    value: localVerification,
                    items: const ['all', 'verified', 'unverified'],
                    displayFn: (s) => s == 'all'
                        ? 'All'
                        : s[0].toUpperCase() + s.substring(1),
                    onChanged: (v) =>
                        setSheetState(() => localVerification = v),
                  ),
                  const SizedBox(height: 12),

                  // Date range
                  const Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate:
                                  localDateFrom ??
                                  DateTime.now().subtract(
                                    const Duration(days: 30),
                                  ),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setSheetState(() => localDateFrom = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            localDateFrom != null
                                ? DateFormat(
                                    'MMM d, yyyy',
                                  ).format(localDateFrom!)
                                : 'From',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '—',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: localDateTo ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setSheetState(() => localDateTo = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            localDateTo != null
                                ? DateFormat('MMM d, yyyy').format(localDateTo!)
                                : 'To',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        bloc.add(
                          RcbcPostingFiltersChanged(
                            status: localStatus,
                            verification: localVerification,
                            dateFrom: localDateFrom,
                            dateTo: localDateTo,
                          ),
                        );
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterDropdown({
    required String? value,
    required List<String> items,
    required String Function(String) displayFn,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value ?? 'all',
          isExpanded: true,
          items: items.map((s) {
            return DropdownMenuItem(value: s, child: Text(displayFn(s)));
          }).toList(),
          onChanged: (v) => onChanged(v),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RcbcPostingState state) {
    if (state is RcbcPostingInitial || state is RcbcPostingLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _accentColor),
            SizedBox(height: 16),
            Text(
              'Loading posting requests…',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    if (state is RcbcPostingError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: _accentColor),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF334155), fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
                onPressed: _refreshWithCurrentFilters,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is RcbcPostingLoaded && state.isLoading && state.page == 1) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _accentColor),
            SizedBox(height: 16),
            Text(
              'Loading posting requests…',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    final records = state is RcbcPostingLoaded
        ? _records
        : <RcbcPaymentPosting>[];

    if (records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text(
              'No posting requests found.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
            ),
          ],
        ),
      );
    }

    final hasMore = state is RcbcPostingLoaded && state.hasMore;
    final isLoadingMore =
        state is RcbcPostingLoaded && state.isLoading && state.page > 1;

    return RefreshIndicator(
      color: _accentColor,
      onRefresh: _refreshWithCurrentFilters,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        itemCount: records.length + (hasMore || isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == records.length) {
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accentColor,
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: TextButton.icon(
                  onPressed: _loadNextPage,
                  icon: const Icon(Icons.expand_more, size: 18),
                  label: Text(
                    'Show more (${(state as RcbcPostingLoaded).total - records.length} remaining)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            );
          }
          return _PostingCard(record: records[index], view: this);
        },
      ),
    );
  }

  void _loadNextPage() {
    final s = _bloc.state;
    if (s is RcbcPostingLoaded) {
      _bloc.add(
        FetchRcbcPostings(
          searchQuery: s.searchQuery,
          status: s.status,
          verification: s.verification,
          dateFrom: s.dateFrom,
          dateTo: s.dateTo,
          page: s.page + 1,
          perPage: s.perPage,
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────
// Expandable posting card
// ─────────────────────────────────────────────
class _PostingCard extends StatefulWidget {
  final RcbcPaymentPosting record;
  final _RcbcPostingRequestViewState view;

  const _PostingCard({required this.record, required this.view});

  @override
  State<_PostingCard> createState() => _PostingCardState();
}

class _PostingCardState extends State<_PostingCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _chevronTurn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _chevronTurn = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  // ─── Row helper ────────────────────────────

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 148,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFE2E8F0));

  // ─── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final v = widget.view;
    final statusColor = v._statusColor(r.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header (always visible) ──────────
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: r.isVerified == true
                          ? const Color(0xFF16A34A).withOpacity(0.1)
                          : const Color(0xFF94A3B8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          r.isVerified == true
                              ? Icons.check_circle
                              : Icons.cancel_outlined,
                          color: r.isVerified == true
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF94A3B8),
                          size: 18,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          r.isVerified == true ? 'Verified' : 'Unverified',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: r.isVerified == true
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF94A3B8),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Core info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Borrower name
                        Text(
                          r.loan?.displayBorrower.toUpperCase() ?? '—',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              'Loan #${r.loanId ?? '—'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            if (r.loan?.uniqueNumber != null) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '· ${r.loan!.displayUnique}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${v._fmtDate(r.dueDate)} · ₱${v._amountFmt.format(r.amount ?? 0)} · ${r.referenceNumber ?? '—'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Status chip + chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          (r.status ?? 'unknown').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      RotationTransition(
                        turns: _chevronTurn,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded details ─────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _divider(),
                        _sectionTitle('PAYMENT INFO'),
                        _row('ID', r.id.toString()),
                        _row('Loan ID', r.loanId?.toString() ?? '—'),
                        _row('Loan Unique #', r.loan?.displayUnique ?? '—'),
                        _row(
                          'Borrower',
                          r.loan?.displayBorrower ?? '—',
                          valueColor: const Color(0xFF0F172A),
                        ),
                        _row(
                          'Loan Schedule ID',
                          r.loanScheduleId?.toString() ?? '—',
                        ),
                        _row('Due Date', v._fmtDate(r.dueDate)),
                        _row('Payment Date', v._fmtDate(r.paymentDate)),
                        _row('Reference #', r.referenceNumber ?? '—'),
                        _row(
                          'Amount',
                          r.amount != null
                              ? '₱${v._amountFmt.format(r.amount)}'
                              : '—',
                        ),
                        _row('RCBC Transaction ID', r.rcbcTransactionId ?? '—'),
                        _row(
                          'Multi-Loan Repayment',
                          r.multipleLoanRepayment == true ? 'Yes' : 'No',
                        ),
                        if (r.multipleLoanRepayment == true)
                          _row(
                            'Multi-Loan Amount',
                            r.multipleLoanRepaymentAmount != null
                                ? '₱${v._amountFmt.format(r.multipleLoanRepaymentAmount)}'
                                : '—',
                          ),

                        _sectionTitle('STATUS & REMARKS'),
                        _row(
                          'Status',
                          (r.status ?? '—').toUpperCase(),
                          valueColor: v._statusColor(r.status),
                        ),
                        _row('Verified', r.isVerified == true ? 'Yes' : 'No'),
                        _row('Remarks', r.remarks ?? '—'),

                        _sectionTitle('SUBMISSION'),
                        _row('Submitted By', r.submittedBy?.displayName ?? '—'),
                        _row('Submitted At', v._fmt(r.submittedAt)),
                        _row('Verified At', v._fmt(r.verifiedAt)),

                        if (r.approvedBy != null || r.approvedAt != null) ...[
                          _sectionTitle('APPROVAL'),
                          _row('Approved By', r.approvedBy?.displayName ?? '—'),
                          _row('Approved At', v._fmt(r.approvedAt)),
                          _row('Approved Remarks', r.approvedRemarks ?? '—'),
                        ],

                        if (r.disapprovedBy != null ||
                            r.disapprovedAt != null) ...[
                          _sectionTitle('DISAPPROVAL'),
                          _row(
                            'Disapproved By',
                            r.disapprovedBy?.toString() ?? '—',
                          ),
                          _row('Disapproved At', v._fmt(r.disapprovedAt)),
                          _row(
                            'Disapproved Remarks',
                            r.disapprovedRemarks ?? '—',
                          ),
                        ],

                        if (r.postedBy != null || r.postedAt != null) ...[
                          _sectionTitle('POSTING'),
                          _row('Posted By', r.postedBy?.toString() ?? '—'),
                          _row('Posted At', v._fmt(r.postedAt)),
                          _row('Posted Remarks', r.postedRemarks ?? '—'),
                        ],

                        if (r.reversedBy != null || r.reversedAt != null) ...[
                          _sectionTitle('REVERSAL'),
                          _row('Reversed By', r.reversedBy?.toString() ?? '—'),
                          _row('Reversed At', v._fmt(r.reversedAt)),
                          _row('Reversed Remarks', r.reversedRemarks ?? '—'),
                        ],

                        if (r.undisbursedBy != null ||
                            r.undisbursedAt != null) ...[
                          _sectionTitle('UNDISBURSEMENT'),
                          _row(
                            'Undisbursed By',
                            r.undisbursedBy?.toString() ?? '—',
                          ),
                          _row('Undisbursed At', v._fmt(r.undisbursedAt)),
                          _row(
                            'Undisbursed Remarks',
                            r.undisbursedRemarks ?? '—',
                          ),
                        ],

                        if (r.archivedBy != null || r.archivedAt != null) ...[
                          _sectionTitle('ARCHIVAL'),
                          _row('Archived By', r.archivedBy?.toString() ?? '—'),
                          _row('Archived At', v._fmt(r.archivedAt)),
                          _row('Archived Remarks', r.archivedRemarks ?? '—'),
                        ],

                        _sectionTitle('TIMESTAMPS'),
                        _row('Created At', v._fmt(r.createdAt)),
                        _row('Updated At', v._fmt(r.updatedAt)),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
