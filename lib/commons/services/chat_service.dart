import 'dart:convert';
import '../models/chat_models.dart';
import 'api_client.dart';

class ChatService {
  static const String _templatesEndpoint = '/api/chat-templates';
  static const String _logsEndpoint = '/api/chat-logs';

  Future<List<ChatTemplate>> listTemplates() async {
    final response = await ApiClient.get(_templatesEndpoint);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rawList = json['data'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => ChatTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> generateMessage({
    required int templateId,
    int? loanId,
    int? borrowerId,
  }) async {
    final params = <String, String>{};
    if (loanId != null) params['loan_id'] = loanId.toString();
    if (borrowerId != null) params['borrower_id'] = borrowerId.toString();
    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final response = await ApiClient.get('$_templatesEndpoint/$templateId$query');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createChatLog({
    required int chatTemplateId,
    required int userId,
    int? borrowerId,
    int? loanId,
    required String message,
    required String sentAt,
  }) async {
    final body = <String, dynamic>{
      'chat_template_id': chatTemplateId,
      'user_id': userId,
      'message': message,
      'sent_at': sentAt,
    };
    if (borrowerId != null) body['borrower_id'] = borrowerId;
    if (loanId != null) body['loan_id'] = loanId;

    final response = await ApiClient.post(_logsEndpoint, body: body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
