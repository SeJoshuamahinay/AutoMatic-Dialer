import 'dart:convert';

import 'package:lenderly_dialer/commons/models/routing_plan_model.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';

/// Symphony `lenderly/dialer/routing-plan` endpoints — the collector's planned visit
/// route, saved from the web dashboard or computed live if nothing's been saved yet.
class RoutingPlanService {
  static const String base = '/api/lenderly/dialer/routing-plan';

  static Future<RoutingPlan> fetch(int userId, {String? date}) async {
    final qs = StringBuffer('user_id=$userId');
    if (date != null) qs.write('&date=$date');
    final response = await ApiClient.get('$base?$qs');
    if (response.statusCode != 200) {
      throw Exception(_message(response.body, 'Failed to load routing plan (HTTP ${response.statusCode})'));
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return RoutingPlan.fromJson(body['data'] as Map<String, dynamic>? ?? {});
  }

  static Future<List<RoutingPlanHistoryEntry>> fetchHistory(int userId) async {
    final response = await ApiClient.get('$base/history?user_id=$userId');
    if (response.statusCode != 200) {
      throw Exception(_message(response.body, 'Failed to load route history (HTTP ${response.statusCode})'));
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>? ?? const [])
        .map((e) => RoutingPlanHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String _message(String raw, String fallback) {
    try {
      final body = jsonDecode(raw) as Map<String, dynamic>;
      final msg = body['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg;
    } catch (_) {}
    return fallback;
  }
}
