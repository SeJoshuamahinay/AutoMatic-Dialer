import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lenderly_dialer/commons/models/visit_request_model.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:lenderly_dialer/commons/services/visit_request_service.dart';
import 'package:lenderly_dialer/views/visitation_request_view.dart';

/// CI / visit requests assigned to the collector from Symphony. Start one when heading
/// out, then submit findings through the visitation form in request mode.
class VisitRequestsView extends StatefulWidget {
  const VisitRequestsView({super.key});

  @override
  State<VisitRequestsView> createState() => _VisitRequestsViewState();
}

class _VisitRequestsViewState extends State<VisitRequestsView> {
  static const _accent = Color(0xFF0F3D3E);
  final _dateFmt = DateFormat('MMM d, yyyy');

  int? _userId;
  final Map<String, List<VisitRequest>> _lists = {'open': [], 'closed': []};
  final Map<String, bool> _loading = {'open': true, 'closed': true};
  final Map<String, String?> _errors = {'open': null, 'closed': null};
  final Set<int> _busy = {};
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<VisitRequest> _filtered(List<VisitRequest> rows) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return rows
        .where((r) => [r.borrowerName, r.loanNumber, r.address]
            .any((v) => (v ?? '').toLowerCase().contains(q)))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = await SharedPrefsStorageService.getUserSession();
    _userId = session?.userId;
    if (_userId == null) {
      setState(() {
        _errors['open'] = _errors['closed'] = 'User session missing. Please log in again.';
        _loading['open'] = _loading['closed'] = false;
      });
      return;
    }
    await Future.wait([_load('open'), _load('closed')]);
  }

  Future<void> _load(String status) async {
    if (_userId == null) return;
    setState(() {
      _loading[status] = true;
      _errors[status] = null;
    });
    try {
      final rows = await VisitRequestService.fetch(_userId!, status: status);
      if (!mounted) return;
      setState(() => _lists[status] = rows);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errors[status] = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading[status] = false);
    }
  }

  Future<void> _start(VisitRequest r) async {
    setState(() => _busy.add(r.id));
    try {
      await VisitRequestService.start(r.id, _userId!);
      _snack('Request started.');
      await _load('open');
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _busy.remove(r.id));
    }
  }

  Future<void> _submitFindings(VisitRequest r) async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => VisitationRequestView(visitRequest: r)),
    );
    if (done == true) {
      await Future.wait([_load('open'), _load('closed')]);
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) _snack('Could not open the dialer.', isError: true);
  }

  Future<void> _directions(String address) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _snack('Could not open Maps.', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red.shade700 : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CI Requests'),
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Open (${_lists['open']!.length})'),
              const Tab(text: 'Closed'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search borrower, loan #, address',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _searchCtrl.clear();
                            _query = '';
                          }),
                        ),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            Expanded(child: TabBarView(children: [_list('open'), _list('closed')])),
          ],
        ),
      ),
    );
  }

  Widget _list(String status) {
    final all = _lists[status]!;
    final rows = _filtered(all);
    Widget child;
    if (_loading[status]! && all.isEmpty) {
      child = const Center(child: CircularProgressIndicator());
    } else if (_errors[status] != null) {
      child = ListView(children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_errors[status]!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700)),
        ),
      ]);
    } else if (rows.isEmpty) {
      child = ListView(children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            all.isNotEmpty
                ? 'No requests match "$_query".'
                : status == 'open' ? 'No open requests. New CI requests from Symphony will appear here.' : 'No completed or cancelled requests yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      ]);
    } else {
      child = ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _card(rows[i]),
      );
    }
    return RefreshIndicator(onRefresh: () => _load(status), child: child);
  }

  Color _statusColor(VisitRequest r) {
    if (r.isOverdue) return Colors.red.shade600;
    return switch (r.status) {
      'pending' => Colors.amber.shade700,
      'in_progress' => Colors.blue.shade600,
      'completed' => Colors.green.shade600,
      _ => Colors.grey.shade600,
    };
  }

  Widget _card(VisitRequest r) {
    final color = _statusColor(r);
    final busy = _busy.contains(r.id);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: .5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(r.type.toUpperCase(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                child: Text(r.isOverdue ? 'Overdue' : r.statusLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(r.borrowerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(r.loanNumber ?? 'Loan #${r.loanId}', style: const TextStyle(color: Color(0xFF64748B))),
            if (r.address != null) ...[
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.place_outlined, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(child: Text(r.address!)),
              ]),
            ],
            if ((r.instructions ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: Text(r.instructions!),
              ),
            ],
            if (r.status == 'cancelled' && (r.cancelReason ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Cancelled: ${r.cancelReason}', style: TextStyle(color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: Text('By ${r.requestedBy ?? '—'}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ),
              Text(
                r.completedAt != null
                    ? 'Done ${_dateFmt.format(r.completedAt!)}'
                    : r.dueDate != null
                        ? 'Due ${_dateFmt.format(r.dueDate!)}'
                        : (r.createdAt != null ? 'Filed ${_dateFmt.format(r.createdAt!)}' : ''),
                style: TextStyle(
                  fontSize: 12,
                  color: r.isOverdue ? Colors.red.shade700 : const Color(0xFF64748B),
                  fontWeight: r.isOverdue ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ]),
            if (r.isOpen) ...[
              const Divider(height: 18),
              Wrap(spacing: 8, runSpacing: 6, children: [
                if ((r.borrowerPhone ?? '').isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _call(r.borrowerPhone!),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call'),
                  ),
                if (r.address != null)
                  OutlinedButton.icon(
                    onPressed: () => _directions(r.address!),
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Map'),
                  ),
                if (r.isPending)
                  FilledButton.tonalIcon(
                    onPressed: busy ? null : () => _start(r),
                    icon: busy
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Start'),
                  ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _accent),
                  onPressed: busy ? null : () => _submitFindings(r),
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Submit Findings'),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
