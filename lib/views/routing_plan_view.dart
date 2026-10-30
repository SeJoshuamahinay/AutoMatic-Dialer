import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lenderly_dialer/commons/models/routing_plan_model.dart';
import 'package:lenderly_dialer/commons/services/routing_plan_service.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:lenderly_dialer/views/routing_plan_history_view.dart';

/// The collector's planned visit route — whatever they saved on the web dashboard,
/// or computed live from today's open CI requests if nothing's been saved yet.
class RoutingPlanView extends StatefulWidget {
  final String? initialDate;
  const RoutingPlanView({super.key, this.initialDate});

  @override
  State<RoutingPlanView> createState() => _RoutingPlanViewState();
}

class _RoutingPlanViewState extends State<RoutingPlanView> {
  static const _accent = Color(0xFF0F3D3E);
  final _isoFmt = DateFormat('yyyy-MM-dd');

  int? _userId;
  late DateTime _selectedDate;
  bool _loading = true;
  String? _error;
  RoutingPlan? _plan;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate != null ? DateTime.parse(widget.initialDate!) : DateTime.now();
    _init();
  }

  String get _isoDate => _isoFmt.format(_selectedDate);

  Future<void> _init() async {
    final session = await SharedPrefsStorageService.getUserSession();
    _userId = session?.userId;
    if (_userId == null) {
      setState(() {
        _error = 'User session missing. Please log in again.';
        _loading = false;
      });
      return;
    }
    await _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plan = await RoutingPlanService.fetch(_userId!, date: _isoDate);
      if (!mounted) return;
      setState(() => _plan = plan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setDate(DateTime date) {
    setState(() => _selectedDate = date);
    _load();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) _setDate(picked);
  }

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _snack('Could not open Google Maps.', isError: true);
    }
  }

  Future<void> _navigateToStop(RoutingPlanStop stop) async {
    final url = stop.isMappable
        ? 'https://www.google.com/maps/dir/?api=1&destination=${stop.lat},${stop.lng}'
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(stop.address ?? stop.borrower)}';
    await _openMaps(url);
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red.shade700 : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      appBar: AppBar(
        title: const Text('Routing Plan'),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RoutingPlanHistoryView()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                _dateChip('Today', today),
                const SizedBox(width: 8),
                _dateChip('Tomorrow', tomorrow),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.calendar_month_rounded, size: 16),
                  label: Text(DateFormat('MMM d').format(_selectedDate)),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
      bottomNavigationBar: (_plan?.mapsUrl != null)
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: Colors.white,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  onPressed: () => _openMaps(_plan!.mapsUrl!),
                  icon: const Icon(Icons.navigation_rounded),
                  label: const Text('Start Route'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _dateChip(String label, DateTime date) {
    final isSelected = _isoDate == _isoFmt.format(date);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: _accent,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      onSelected: (_) => _setDate(date),
    );
  }

  Widget _body() {
    if (_loading && _plan == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 32),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ]),
          ),
        ]),
      );
    }
    final plan = _plan;
    if (plan == null || plan.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(children: [
              Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 32),
              const SizedBox(height: 12),
              const Text(
                'All clear — nothing to visit on this date.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ]),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          if (plan.optimized && plan.distanceKm != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4),
              child: Text(
                '${plan.stops.length} stop${plan.stops.length == 1 ? '' : 's'} · ~${plan.distanceKm} km · fastest order',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ),
          if (plan.note != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4),
              child: Text(plan.note!, style: TextStyle(color: Colors.amber.shade800, fontSize: 13)),
            ),
          ...plan.stops.asMap().entries.map(
                (e) => _stopCard(index: e.key + 1, stop: e.value, onNavigate: () => _navigateToStop(e.value)),
              ),
          if (plan.unmapped.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 8, left: 4),
              child: Text(
                'These need a pin — add one on the web dashboard first.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ),
            ...plan.unmapped.map((s) => _stopCard(index: null, stop: s, onNavigate: null)),
          ],
        ],
      ),
    );
  }

  Widget _stopCard({required int? index, required RoutingPlanStop stop, required VoidCallback? onNavigate}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: index != null ? _accent : Colors.grey.shade400,
              child: Text(
                index != null ? '$index' : '!',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stop.borrower, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(stop.type, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  if (stop.address != null) ...[
                    const SizedBox(height: 4),
                    Text(stop.address!, style: const TextStyle(color: Color(0xFF334155), fontSize: 13)),
                  ],
                  if (stop.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Text('Due ${stop.dueDate}', style: TextStyle(color: Colors.amber.shade800, fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (onNavigate != null)
              IconButton(
                onPressed: onNavigate,
                icon: Icon(Icons.navigation_rounded, color: _accent),
                tooltip: 'Navigate',
              ),
          ],
        ),
      ),
    );
  }
}
