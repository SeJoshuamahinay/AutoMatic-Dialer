import 'package:flutter/material.dart';
import 'package:lenderly_dialer/commons/models/chat_models.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/chat_service.dart';
import 'chat_message_preview_view.dart';

class ChatTemplatePickerView extends StatefulWidget {
  final int loanId;
  final int? borrowerId;
  final String? borrowerName;
  final String? borrowerPhone;
  final bool returnBodyOnly;

  const ChatTemplatePickerView({
    super.key,
    required this.loanId,
    this.borrowerId,
    this.borrowerName,
    this.borrowerPhone,
    this.returnBodyOnly = false,
  });

  @override
  State<ChatTemplatePickerView> createState() => _ChatTemplatePickerViewState();
}

class _ChatTemplatePickerViewState extends State<ChatTemplatePickerView> {
  final ChatService _chatService = ChatService();
  List<ChatTemplate> _templates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final templates = await _chatService.listTemplates();
      if (!mounted) return;
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } on AuthSessionExpiredException {
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load templates: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickTemplate(ChatTemplate template) async {
    if (widget.returnBodyOnly) {
      try {
        final result = await _chatService.generateMessage(
          templateId: template.id,
          loanId: widget.loanId,
          borrowerId: widget.borrowerId,
        );
        if (!mounted) return;
        final data = result['data'] as Map<String, dynamic>?;
        final body = data?['body']?.toString() ?? template.body;
        if (!mounted) return;
        Navigator.pop(context, body);
      } catch (_) {
        if (!mounted) return;
        Navigator.pop(context, template.body);
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatMessagePreviewView(
          template: template,
          loanId: widget.loanId,
          borrowerId: widget.borrowerId,
          borrowerName: widget.borrowerName,
          borrowerPhone: widget.borrowerPhone,
        ),
      ),
    );
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
              'Send Message',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (widget.borrowerName != null)
              Text(
                widget.borrowerName!,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: widget.borrowerName != null ? 65 : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTemplates,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No templates available',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _buildTemplateCard(_templates[i]),
    );
  }

  Widget _buildTemplateCard(ChatTemplate template) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _pickTemplate(template),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                radius: 18,
                child: Icon(
                  Icons.message_outlined,
                  size: 18,
                  color: Colors.indigo.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.body.replaceAll(RegExp(r'\{[^}]+\}'), '___'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
