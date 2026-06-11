import 'package:flutter/material.dart';

class LoanCardActionsMenu extends StatelessWidget {
  final Color themeColor;
  final Color secondaryColor;
  final VoidCallback onViewDetails;
  final VoidCallback onFollowUp;
  final VoidCallback? onCallPhone;
  final VoidCallback? onCallMobile;

  const LoanCardActionsMenu({
    super.key,
    required this.themeColor,
    required this.secondaryColor,
    required this.onViewDetails,
    required this.onFollowUp,
    this.onCallPhone,
    this.onCallMobile,
  });

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

        if (onCallPhone != null) {
          items.addAll([
            const PopupMenuDivider(),
            _menuItem(
              value: _LoanCardAction.callPhone,
              icon: Icons.phone,
              title: 'Call phone',
              color: themeColor,
            ),
          ]);
        }

        if (onCallMobile != null) {
          items.add(
            _menuItem(
              value: _LoanCardAction.callMobile,
              icon: Icons.phone_android,
              title: 'Call mobile',
              color: secondaryColor,
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
        child: Icon(Icons.more_vert, size: 20, color: themeColor),
      ),
    );
  }

  PopupMenuItem<_LoanCardAction> _menuItem({
    required _LoanCardAction value,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return PopupMenuItem<_LoanCardAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}

enum _LoanCardAction { viewDetails, followUp, callPhone, callMobile }
