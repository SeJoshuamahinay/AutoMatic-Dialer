import 'package:flutter/material.dart';

class LoanCardActionsMenu extends StatelessWidget {
  final Color themeColor;
  final Color secondaryColor;
  final VoidCallback onViewDetails;
  final VoidCallback onFollowUp;
  final VoidCallback? onCallPhone;
  final String? borrowerPhone;
  final VoidCallback? onCallMobile;
  final String? coMakerName;
  final String? coMakerPhone;
  final VoidCallback? onSendMessageBorrower;
  final VoidCallback? onSendMessageCoMaker;

  const LoanCardActionsMenu({
    super.key,
    required this.themeColor,
    required this.secondaryColor,
    required this.onViewDetails,
    required this.onFollowUp,
    this.onCallPhone,
    this.borrowerPhone,
    this.onCallMobile,
    this.coMakerName,
    this.coMakerPhone,
    this.onSendMessageBorrower,
    this.onSendMessageCoMaker,
  });

  /// "Name — 0917..." when both present, otherwise whichever is non-empty.
  String? _label(String? name, String? phone) {
    final n = (name ?? '').trim();
    final p = (phone ?? '').trim();
    if (n.isNotEmpty && p.isNotEmpty) return '$n — $p';
    if (p.isNotEmpty) return p;
    return n.isNotEmpty ? n : null;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_LoanCardAction>(
      tooltip: 'Actions',
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (action) {
        switch (action) {
          case _LoanCardAction.viewDetails:
            onViewDetails();
            break;
          case _LoanCardAction.followUp:
            onFollowUp();
            break;
          case _LoanCardAction.callPhone:
            onCallPhone?.call();
            break;
          case _LoanCardAction.callMobile:
            onCallMobile?.call();
            break;
          case _LoanCardAction.messageBorrower:
            onSendMessageBorrower?.call();
            break;
          case _LoanCardAction.messageCoMaker:
            onSendMessageCoMaker?.call();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_LoanCardAction>>[
          _menuItem(
            value: _LoanCardAction.viewDetails,
            icon: Icons.info_outline,
            title: 'View details',
            color: themeColor,
          ),
          _menuItem(
            value: _LoanCardAction.followUp,
            icon: Icons.add_comment_outlined,
            title: 'Follow-up',
            color: secondaryColor,
          ),
        ];

        if (onCallPhone != null || onCallMobile != null) {
          items.add(const PopupMenuDivider());
        }

        if (onCallPhone != null) {
          items.add(
            _menuItem(
              value: _LoanCardAction.callPhone,
              icon: Icons.phone,
              title: 'Call borrower',
              subtitle: borrowerPhone,
              color: themeColor,
            ),
          );
        }

        if (onCallMobile != null) {
          items.add(
            _menuItem(
              value: _LoanCardAction.callMobile,
              icon: Icons.phone_android,
              title: 'Call comaker',
              subtitle: _label(coMakerName, coMakerPhone),
              color: secondaryColor,
            ),
          );
        }

        if (onSendMessageBorrower != null || onSendMessageCoMaker != null) {
          items.add(const PopupMenuDivider());
        }

        if (onSendMessageBorrower != null) {
          items.add(
            _menuItem(
              value: _LoanCardAction.messageBorrower,
              icon: Icons.message_outlined,
              title: 'Message borrower',
              subtitle: borrowerPhone,
              color: Colors.indigo,
            ),
          );
        }

        if (onSendMessageCoMaker != null) {
          items.add(
            _menuItem(
              value: _LoanCardAction.messageCoMaker,
              icon: Icons.forum_outlined,
              title: 'Message comaker',
              subtitle: _label(coMakerName, coMakerPhone),
              color: Colors.indigo,
            ),
          );
        }

        return items;
      },
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: themeColor.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: themeColor.withValues(alpha: 0.2)),
        ),
        child: Icon(Icons.add, size: 22, color: themeColor),
      ),
    );
  }

  PopupMenuItem<_LoanCardAction> _menuItem({
    required _LoanCardAction value,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
  }) {
    return PopupMenuItem<_LoanCardAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _LoanCardAction {
  viewDetails,
  followUp,
  callPhone,
  callMobile,
  messageBorrower,
  messageCoMaker,
}
