import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';
import 'package:lenderly_dialer/commons/services/accounts_bucket_service.dart';
import 'package:lenderly_dialer/commons/utils/gesture_error_handler.dart';

class BucketView extends StatefulWidget {
  final BucketType bucketType;
  final AssignmentData assignmentData;

  const BucketView({
    super.key,
    required this.bucketType,
    required this.assignmentData,
  });

  @override
  State<BucketView> createState() => _BucketViewState();
}

class _BucketViewState extends State<BucketView> {
  List<LoanRecord> _loans = [];
  Map<String, dynamic> _statistics = {};
  bool _prioritizeCoMaker = true;

  @override
  void initState() {
    super.initState();
    _loadLoansData();
  }

  void _loadLoansData() {
    setState(() {
      if (_prioritizeCoMaker) {
        _loans = AccountsBucketService.getCoMakerPrioritizedLoansByBucket(
          widget.assignmentData,
          widget.bucketType,
        );
      } else {
        _loans = AccountsBucketService.getLoansByBucket(
          widget.assignmentData,
          widget.bucketType,
        );
      }
      _statistics = AccountsBucketService.getBucketStatistics(
        widget.assignmentData,
        widget.bucketType,
      );
    });
  }

  Future<void> _makePhoneCall(String phoneNumber, String contactName) async {
    if (!mounted) return;

    try {
      // Add a small delay to prevent rapid gesture conflicts
      await Future.delayed(const Duration(milliseconds: 100));

      bool? callMade = await FlutterPhoneDirectCaller.callNumber(phoneNumber);

      if (mounted) {
        if (callMade == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Calling $contactName at $phoneNumber'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to make phone call to $phoneNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bucketType.displayName} Accounts'),
        backgroundColor: _getBucketColor(),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_priority') {
                setState(() {
                  _prioritizeCoMaker = !_prioritizeCoMaker;
                  _loadLoansData();
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_priority',
                child: Row(
                  children: [
                    Icon(_prioritizeCoMaker ? Icons.people : Icons.person),
                    const SizedBox(width: 8),
                    Text(
                      _prioritizeCoMaker
                          ? 'Show All Loans'
                          : 'Prioritize Co-Maker',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.bucketType.displayName} Statistics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatisticRow(
                    'Total Loans',
                    '${_statistics['total_loans'] ?? 0}',
                  ),
                  _buildStatisticRow(
                    'Dialable Loans',
                    '${_statistics['dialable_count'] ?? 0}',
                  ),
                  _buildStatisticRow(
                    'Co-Maker Phones',
                    '${_statistics['co_maker_phone_count'] ?? 0}',
                  ),
                  _buildStatisticRow(
                    'Borrower Phones',
                    '${_statistics['borrower_phone_count'] ?? 0}',
                  ),
                  _buildStatisticRow(
                    'No Phone Available',
                    '${_statistics['no_phone_count'] ?? 0}',
                  ),
                  if ((_statistics['co_maker_percentage'] ?? 0) > 0)
                    _buildStatisticRow(
                      'Co-Maker Coverage',
                      '${_statistics['co_maker_percentage']}%',
                    ),
                ],
              ),
            ),
          ),

          // Filter Toggle
          if (_loans.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Prioritize Co-Maker Phones'),
                      subtitle: Text(
                        _prioritizeCoMaker
                            ? 'Co-maker numbers shown first'
                            : 'Original order',
                      ),
                      value: _prioritizeCoMaker,
                      onChanged: (value) {
                        setState(() {
                          _prioritizeCoMaker = value;
                          _loadLoansData();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Loans List
          Expanded(
            child: _loans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${widget.bucketType.displayName.toLowerCase()} accounts assigned',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _loans.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final loan = _loans[index];
                      return _buildLoanCard(loan, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLoanCard(LoanRecord loan, int index) {
    final hasPhone = loan.hasValidPhone;
    final isCoMakerPhone =
        loan.borrower?.coMakerPhone != null &&
        loan.borrower!.coMakerPhone!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getBucketColor(),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.displayAccountNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (loan.loanStatus != null)
                        Text(
                          'Status: ${loan.loanStatus}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasPhone)
                  GestureErrorHandler.safeIconButton(
                    onPressed: () {
                      // Add debouncing to prevent rapid taps that can cause gesture conflicts
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (mounted) {
                          _makePhoneCall(
                            loan.preferredPhone!,
                            loan.preferredContactName ?? 'Unknown',
                          );
                        }
                      });
                    },
                    icon: Icon(
                      Icons.phone,
                      color: isCoMakerPhone ? Colors.green : Colors.blue,
                    ),
                    tooltip: 'Call ${isCoMakerPhone ? 'Co-Maker' : 'Borrower'}',
                    splashRadius: 24,
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Contact Information
            if (loan.borrower != null) ...[
              _buildContactInfo(
                'Borrower',
                loan.borrower!.borrowerName,
                loan.borrower!.borrowerPhone,
                isCoMakerPhone ? false : true,
              ),
              if (loan.borrower!.coMakerName != null ||
                  loan.borrower!.coMakerPhone != null)
                _buildContactInfo(
                  'Co-Maker',
                  loan.borrower!.coMakerName,
                  loan.borrower!.coMakerPhone,
                  isCoMakerPhone,
                ),
            ],

            // Loan Details
            if (loan.outstandingBalance != null || loan.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (loan.outstandingBalance != null)
                    Expanded(
                      child: Text(
                        'Balance: PHP ${loan.outstandingBalance!.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  if (loan.dueDate != null)
                    Text(
                      'Due: ${loan.dueDate!.day}/${loan.dueDate!.month}/${loan.dueDate!.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(
    String label,
    String? name,
    String? phone,
    bool isPreferred,
  ) {
    if (name == null && phone == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isPreferred ? FontWeight.bold : FontWeight.normal,
                color: isPreferred ? _getBucketColor() : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${name ?? 'Unknown'} ${phone != null ? '($phone)' : ''}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isPreferred ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isPreferred && phone != null)
            Icon(Icons.priority_high, size: 16, color: _getBucketColor()),
        ],
      ),
    );
  }

  Color _getBucketColor() {
    switch (widget.bucketType) {
      case BucketType.frontend:
        return Colors.green;
      case BucketType.middlecore:
        return Colors.orange;
      case BucketType.hardcore:
        return Colors.red;
    }
  }
}
