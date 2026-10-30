import 'package:flutter/material.dart';

import 'package:lenderly_dialer/commons/models/routing_plan_model.dart';
import 'package:lenderly_dialer/commons/services/routing_plan_service.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:lenderly_dialer/views/routing_plan_view.dart';

/// The collector's own saved routes, most recent first — past and upcoming dates.
class RoutingPlanHistoryView extends StatefulWidget {
  const RoutingPlanHistoryView({super.key});

  @override
  State<RoutingPlanHistoryView> createState() => _RoutingPlanHistoryViewState();
}

class _RoutingPlanHistoryViewState extends State<RoutingPlanHistoryView> {
  static const _accent = Color(0xFF0F3D3E);

  bool _loading = true;
  String? _error;
  List<RoutingPlanHistoryEntry> _history = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await SharedPrefsStorageService.getUserSession();
      final userId = session?.userId;
      if (userId == null) {
        setState(() => _error = 'User session missing. Please log in again.');
        return;
      }
      final history = await RoutingPlanService.fetchHistory(userId);
      if (!mounted) return;
      setState(() => _history = history);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      appBar: AppBar(
        title: const Text('Routing Plan History'),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700)),
        ),
      );
    }
    if (_history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No saved routes yet.', style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final h = _history[i];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(h.date, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                '${h.stopsCount} stop${h.stopsCount == 1 ? '' : 's'}${h.distanceKm != null ? ' · ~${h.distanceKm} km' : ''}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RoutingPlanView(initialDate: h.date)),
              ),
            ),
          );
        },
      ),
    );
  }
}
