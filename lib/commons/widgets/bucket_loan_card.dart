import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';

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
                // ── Header row ─────────────────────────────────────────
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
                // ── Due date + last follow-up ───────────────────────────
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
                // ── Action buttons ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewDetails,
                        icon: const Icon(Icons.description_outlined, size: 14),
                        label: const Text(
                          'View Details',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: themeColor,
                          side: BorderSide(color: themeColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onFollowUp,
                        icon: const Icon(Icons.add_comment_outlined, size: 14),
                        label: const Text(
                          'Follow-up',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
                // ── Phone buttons ──────────────────────────────────────
                if (r.hasValidPhone) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (r.hasPhone && onCallPhone != null)
                        Expanded(
                          child: _CallBtn(
                            icon: Icons.phone,
                            label: 'Call Phone',
                            color: themeColor,
                            onTap: onCallPhone!,
                          ),
                        ),
                      if (r.hasPhone && r.hasMobile) const SizedBox(width: 8),
                      if (r.hasMobile && onCallMobile != null)
                        Expanded(
                          child: _CallBtn(
                            icon: Icons.phone_android,
                            label: 'Call Mobile',
                            color: secondaryColor,
                            onTap: onCallMobile!,
                          ),
                        ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_disabled,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'No phone number available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CallBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
