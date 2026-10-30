import 'dart:convert';

import 'package:lenderly_dialer/commons/models/visit_request_model.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';

/// Symphony `lenderly/dialer/visit-requests` endpoints. Completing a request is done
/// by VisitationRequestView in request mode (it owns the GPS/photo form).
class VisitRequestService {
  static const String base = '/api/lenderly/dialer/visit-requests';

  static String completeEndpoint(int id) => '$base/$id/complete';

  /// [status]: 'open' (pending + in progress) or 'closed' (completed + cancelled).
  static Future<List<VisitRequest>> fetch(int userId, {String status = 'open'}) async {
    final response = await ApiClient.get('$base?user_id=$userId&status=$status');
    if (response.statusCode != 200) {
      throw Exception(_message(response.body, 'Failed to load visit requests (HTTP ${response.statusCode})'));
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>? ?? const [])
        .map((e) => VisitRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> start(int id, int userId) async {
    final response = await ApiClient.post('$base/$id/start', body: {'user_id': userId});
    if (response.statusCode != 200) {
      throw Exception(_message(response.body, 'Failed to start (HTTP ${response.statusCode})'));
    }
  }

  static String _message(String raw, String fallback) {
    try {
      final body = jsonDecode(raw) as Map<String, dynamic>;
      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      final msg = body['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg;
    } catch (_) {}
    return fallback;
  }
}
