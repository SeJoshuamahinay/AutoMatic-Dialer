import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'local_conversation_view.dart';

class LocalMessagesView extends StatefulWidget {
  const LocalMessagesView({super.key});

  @override
  State<LocalMessagesView> createState() => _LocalMessagesViewState();
}

class _LocalMessagesViewState extends State<LocalMessagesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SmsMessage> _inboxMessages = [];
  List<SmsMessage> _sentMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      var status = await Permission.sms.status;
      if (status.isDenied) {
        status = await Permission.sms.request();
      }
      if (status.isPermanentlyDenied || status.isRestricted) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSettingsDialog();
        return;
      }
      if (!status.isGranted) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SMS permission is required to view messages.')),
        );
        return;
      }
      final inbox = await Telephony.instance.getInboxSms();
      final sent = await Telephony.instance.getSentSms();
      if (!mounted) return;
      setState(() {
        _inboxMessages = inbox;
        _sentMessages = sent;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e')),
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('SMS Permission Required'),
        content: const Text(
          'SMS permission was denied. Please enable it in app settings to view and send messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Map<String, List<SmsMessage>> _groupByAddress(List<SmsMessage> msgs) {
    final map = <String, List<SmsMessage>>{};
    for (final msg in msgs) {
      final addr = msg.address ?? 'Unknown';
      map.putIfAbsent(addr, () => []).add(msg);
    }
    return map;
  }

  List<_ConversationSummary> _buildConversations(
    Map<String, List<SmsMessage>> grouped,
  ) {
    final list = <_ConversationSummary>[];
    for (final entry in grouped.entries) {
      final msgs = entry.value;
      msgs.sort((a, b) => ((a.date ?? 0)).compareTo((b.date ?? 0)));
      final latest = msgs.last;
      list.add(_ConversationSummary(
        address: entry.key,
        latestBody: latest.body ?? '',
        latestDate: latest.date ?? 0,
        messageCount: msgs.length,
      ));
    }
    list.sort(
      (a, b) => (b.latestDate).compareTo(a.latestDate),
    );
    return list;
  }

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 65,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Inbox'),
            Tab(text: 'Sent'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConversationList(_inboxMessages),
                _buildConversationList(_sentMessages),
              ],
            ),
    );
  }

  Widget _buildConversationList(List<SmsMessage> messages) {
    final grouped = _groupByAddress(messages);
    final conversations = _buildConversations(grouped);

    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No messages',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) => _buildConversationCard(conversations[i]),
      ),
    );
  }

  Widget _buildConversationCard(_ConversationSummary conv) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LocalConversationView(
                address: conv.address,
                inboxMessages: _inboxMessages
                    .where((m) => m.address == conv.address)
                    .toList(),
                sentMessages: _sentMessages
                    .where((m) => m.address == conv.address)
                    .toList(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                radius: 22,
                child: Text(
                  conv.address.isNotEmpty
                      ? conv.address[conv.address.length - 1]
                      : '?',
                  style: TextStyle(
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv.address,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(conv.latestDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv.latestBody,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        if (conv.messageCount > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${conv.messageCount}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.indigo.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationSummary {
  final String address;
  final String latestBody;
  final int latestDate;
  final int messageCount;

  const _ConversationSummary({
    required this.address,
    required this.latestBody,
    required this.latestDate,
    required this.messageCount,
  });
}
