import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';
import 'package:lenderly_dialer/commons/widgets/loan_card_actions_menu.dart';

/// Stateless card for a single loan record in a bucket list.
/// Extracted so Flutter can skip rebuilds for unchanged items.
class BucketLoanCard extends StatelessWidget {
  final DialerLoanRecord record;
  final int index;
  final Color themeColor;
  final Color secondaryColor;
  final VoidCallback onViewDetails;
  final VoidCallback onFollowUp;
  final VoidCallback? onCallPhone;
  final VoidCallback? onCallMobile;

  const BucketLoanCard({
    super.key,
    required this.record,
    required this.index,
    required this.themeColor,
    required this.secondaryColor,
    required this.onViewDetails,
    required this.onFollowUp,
    this.onCallPhone,
    this.onCallMobile,
  });

  static final _amtFmt = NumberFormat('#,##0.00', 'en_PH');

  String _fAmt(String? raw) {
    if (raw == null || raw.isEmpty) return '₱0.00';
    final clean = raw.replaceAll(',', '');
    final v = double.tryParse(clean);
    if (v == null) return '₱$raw';
    return '₱${_amtFmt.format(v)}';
  }

  String _fDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = record;
    final hasLastFollowUp = r.lastLafuDate != null;
    final lastFollowUpSubject = (r.lastLafuSubject ?? '').trim();
    final avatarBg = themeColor.withValues(alpha: 0.15);
    final avatarFg = themeColor;

    return RepaintBoundary(
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: r.hasValidPhone ? Colors.white : Colors.grey.shade50,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onViewDetails,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: avatarBg,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: avatarFg,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.fullName.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if ((r.borrowerCity ?? '').isNotEmpty)
                            Text(
                              r.borrowerCity!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            r.accountNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _fAmt(r.outstandingBalance),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${r.arrearsDays} days overdue',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_fDate(r.earliestDue)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    if (hasLastFollowUp) ...[
                      Icon(
                        Icons.assignment_turned_in,
                        size: 13,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Last FU: ${_fDate(r.lastLafuDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.assignment_late,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'No follow-up yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (lastFollowUpSubject.isNotEmpty) ...[
                      Expanded(
                        child: Text(
                          'Subject: $lastFollowUpSubject',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    LoanCardActionsMenu(
                      themeColor: themeColor,
                      secondaryColor: secondaryColor,
                      onViewDetails: onViewDetails,
                      onFollowUp: onFollowUp,
                      onCallPhone: onCallPhone,
                      onCallMobile: onCallMobile,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
