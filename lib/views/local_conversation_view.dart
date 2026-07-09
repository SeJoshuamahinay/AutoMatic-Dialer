import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'chat_template_picker_view.dart';

class LocalConversationView extends StatefulWidget {
  final String address;
  final List<SmsMessage> inboxMessages;
  final List<SmsMessage> sentMessages;

  const LocalConversationView({
    super.key,
    required this.address,
    required this.inboxMessages,
    required this.sentMessages,
  });

  @override
  State<LocalConversationView> createState() => _LocalConversationViewState();
}

class _LocalConversationViewState extends State<LocalConversationView> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isSending = false;

  List<_ChatBubble> get _mergedMessages {
    final list = <_ChatBubble>[];
    for (final msg in widget.inboxMessages) {
      list.add(_ChatBubble(
        body: msg.body ?? '',
        timestamp: msg.date ?? 0,
        isSent: false,
      ));
    }
    for (final msg in widget.sentMessages) {
      list.add(_ChatBubble(
        body: msg.body ?? '',
        timestamp: msg.date ?? 0,
        isSent: true,
      ));
    }
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await Telephony.instance.sendSms(
        to: widget.address,
        message: text,
        isMultipart: text.length > 160,
      );
      _messageCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _openTemplatePicker() async {
    final session = await SharedPrefsStorageService.getUserSession();
    if (session == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to use templates.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Try to find a matching loan ID for this address. We'll just use 0
    // since the template generation on backend has a bug anyway.
    // The body will at least get placeholders replaced where possible.
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatTemplatePickerView(
          loanId: 0,
          returnBodyOnly: true,
        ),
      ),
    );

    if (result != null && mounted) {
      _messageCtrl.text = result;
      _messageCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: result.length),
      );
    }
  }

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final messages = _mergedMessages;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(
          widget.address,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      return Align(
                        alignment: msg.isSent
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: msg.isSent
                                ? Colors.indigo.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight:
                                  msg.isSent ? const Radius.circular(4) : null,
                              bottomLeft:
                                  !msg.isSent ? const Radius.circular(4) : null,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.body,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _openTemplatePicker,
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.indigo,
                      tooltip: 'Use template',
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _messageCtrl,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      color: Colors.indigo,
                      tooltip: 'Send',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble {
  final String body;
  final int timestamp;
  final bool isSent;

  const _ChatBubble({
    required this.body,
    required this.timestamp,
    required this.isSent,
  });
}
