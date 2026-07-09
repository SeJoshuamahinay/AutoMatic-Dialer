import 'package:flutter/material.dart';
import 'package:lenderly_dialer/commons/models/chat_models.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/chat_service.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:telephony/telephony.dart';

class ChatMessagePreviewView extends StatefulWidget {
  final ChatTemplate template;
  final int loanId;
  final int? borrowerId;
  final String? borrowerName;
  final String? borrowerPhone;

  const ChatMessagePreviewView({
    super.key,
    required this.template,
    required this.loanId,
    this.borrowerId,
    this.borrowerName,
    this.borrowerPhone,
  });

  @override
  State<ChatMessagePreviewView> createState() => _ChatMessagePreviewViewState();
}

class _ChatMessagePreviewViewState extends State<ChatMessagePreviewView> {
  final ChatService _chatService = ChatService();
  bool _isLoading = true;
  bool _isSending = false;
  String? _filledBody;
  String? _filledSubject;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateMessage();
  }

  Future<void> _generateMessage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _chatService.generateMessage(
        templateId: widget.template.id,
        loanId: widget.loanId,
        borrowerId: widget.borrowerId,
      );
      if (!mounted) return;
      if (result['status'] == 'success') {
        final data = result['data'] as Map<String, dynamic>?;
        setState(() {
          _filledBody = data?['body']?.toString();
          _filledSubject = data?['subject']?.toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message']?.toString() ?? 'Failed to generate message';
          _isLoading = false;
        });
      }
    } on AuthSessionExpiredException {
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error generating message: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_filledBody == null || _isSending) return;

    setState(() => _isSending = true);

    try {
      final session = await SharedPrefsStorageService.getUserSession();
      if (session == null) {
        _showError('User session not found. Please re-login.');
        return;
      }

      await _chatService.createChatLog(
        chatTemplateId: widget.template.id,
        userId: session.userId,
        borrowerId: widget.borrowerId,
        loanId: widget.loanId,
        message: _filledBody!,
        sentAt: DateTime.now().toIso8601String(),
      );

      final phone = widget.borrowerPhone;
      if (phone != null && phone.isNotEmpty) {
        await Telephony.instance.sendSms(
          to: phone,
          message: _filledBody!,
          isMultipart: _filledBody!.length > 160,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            phone != null
                ? 'Message sent to $phone!'
                : 'Message logged successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } on AuthSessionExpiredException {
      return;
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to send message: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _filledSubject ?? widget.template.subject,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating message...'),
          ],
        ),
      );
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
              onPressed: _generateMessage,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_filledSubject != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _filledSubject!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _filledBody ?? widget.template.body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(_isSending ? 'Sending...' : 'Send Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
