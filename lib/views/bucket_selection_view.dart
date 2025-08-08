import 'package:flutter/material.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';
import 'package:lenderly_dialer/commons/utils/gesture_error_handler.dart';
import 'package:lenderly_dialer/views/bucket_view.dart';

class BucketSelectionView extends StatelessWidget {
  final AssignmentData assignmentData;

  const BucketSelectionView({super.key, required this.assignmentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Accounts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assignment Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewRow(
                      'Total Accounts Assigned',
                      '${assignmentData.totalLoansCount}',
                    ),
                    _buildOverviewRow(
                      'Dialable Accounts',
                      '${assignmentData.dialableLoans.length}',
                    ),
                    _buildOverviewRow(
                      'Assigned At',
                      _formatDateTime(assignmentData.assignedAt),
                    ),
                    _buildOverviewRow('User ID', '${assignmentData.userId}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Select Account Bucket',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Bucket Cards
            Expanded(
              child: ListView(
                children: [
                  _buildBucketCard(
                    context,
                    BucketType.frontend,
                    Colors.green,
                    Icons.trending_up,
                    'Early stage accounts',
                  ),
                  const SizedBox(height: 12),
                  _buildBucketCard(
                    context,
                    BucketType.middlecore,
                    Colors.orange,
                    Icons.warning,
                    'Mid-stage accounts',
                  ),
                  const SizedBox(height: 12),
                  _buildBucketCard(
                    context,
                    BucketType.hardcore,
                    Colors.red,
                    Icons.priority_high,
                    'High-risk accounts',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBucketCard(
    BuildContext context,
    BucketType bucketType,
    Color color,
    IconData icon,
    String description,
  ) {
    final loansCount = assignmentData.getCountForBucket(bucketType);
    final dialableCount = assignmentData.getDialableCountForBucket(bucketType);

    return Card(
      child: GestureErrorHandler.safeInkWell(
        onTap: loansCount > 0
            ? () => GestureErrorHandler.safeNavigate(
                context,
                BucketView(
                  bucketType: bucketType,
                  assignmentData: assignmentData,
                ),
              )
            : null,
        borderRadius: BorderRadius.circular(8),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bucketType.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          'Total: $loansCount',
                          color.withValues(alpha: 0.1),
                          color,
                        ),
                        const SizedBox(width: 8),
                        if (dialableCount > 0)
                          _buildStatChip(
                            'Dialable: $dialableCount',
                            Colors.green.withValues(alpha: 0.1),
                            Colors.green,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow or Disabled indicator
              Icon(
                loansCount > 0 ? Icons.arrow_forward_ios : Icons.block,
                color: loansCount > 0 ? Colors.grey[400] : Colors.grey[300],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
