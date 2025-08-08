import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/services/accounts_bucket_service.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:lenderly_dialer/blocs/dialer/dialer_bloc.dart';
import 'package:lenderly_dialer/commons/presenters/dialer_presenter.dart';
import 'package:lenderly_dialer/views/dialer_view.dart';

class HardcoreView extends StatefulWidget {
  final AssignmentData? assignmentData;

  const HardcoreView({super.key, this.assignmentData});

  @override
  State<HardcoreView> createState() => _HardcoreViewState();
}

class _HardcoreViewState extends State<HardcoreView> {
  List<LoanRecord> _loans = [];
  Map<String, dynamic> _statistics = {};
  bool _prioritizeCoMaker = true;
  UserSession? _userSession;
  AssignmentData? _assignmentData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (widget.assignmentData != null) {
      _assignmentData = widget.assignmentData;
      _loadLoansData();
      return;
    }

    // Load assignment data if not provided
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _userSession = await SharedPrefsStorageService.getUserSession();
      if (_userSession == null) {
        setState(() {
          _errorMessage = 'Please log in to view hardcore accounts';
          _isLoading = false;
        });
        return;
      }

      final response = await AccountsBucketService.assignLoansToUser(
        _userSession!.userId.toString(),
      );

      setState(() {
        _assignmentData = response.data;
        _isLoading = false;
      });

      _loadLoansData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load hardcore accounts: $e';
        _isLoading = false;
      });
    }
  }

  void _loadLoansData() {
    if (_assignmentData == null) return;

    setState(() {
      if (_prioritizeCoMaker) {
        _loans = AccountsBucketService.getCoMakerPrioritizedLoansByBucket(
          _assignmentData!,
          BucketType.hardcore,
        );
      } else {
        _loans = AccountsBucketService.getLoansByBucket(
          _assignmentData!,
          BucketType.hardcore,
        );
      }
      _statistics = AccountsBucketService.getBucketStatistics(
        _assignmentData!,
        BucketType.hardcore,
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

  void _startAutoDialing(bool coMakersOnly) {
    if (_assignmentData == null) return;

    // Get or create the dialer bloc
    final dialerBloc = context.read<DialerBloc>();
    final presenter = DialerPresenter(dialerBloc);

    if (coMakersOnly) {
      presenter.startCoMakerDialingForBucket(
        BucketType.hardcore,
        _assignmentData!,
      );
    } else {
      presenter.startAllContactsDialingForBucket(
        BucketType.hardcore,
        _assignmentData!,
      );
    }

    // Navigate to dialer view
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            BlocProvider.value(value: dialerBloc, child: const DialerView()),
      ),
    );
  }

  Widget _buildAutoDialingButtons() {
    if (_assignmentData == null) return const SizedBox.shrink();

    final coMakerCount = _statistics['co_maker_phone_count'] ?? 0;
    final dialableCount = _statistics['dialable_count'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon and Header
            Icon(Icons.autorenew, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'Auto Dialing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const Spacer(),
            // Buttons
            if (coMakerCount > 0)
              SizedBox(
                width: 100,
                child: ElevatedButton.icon(
                  onPressed: () => _startAutoDialing(true),
                  icon: const Icon(Icons.people, size: 14),
                  label: Text(
                    '($coMakerCount)',
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                  ),
                ),
              ),
            if (coMakerCount > 0 && dialableCount > coMakerCount)
              const SizedBox(width: 16),
            if (dialableCount > 0)
              SizedBox(
                width: 80,
                child: ElevatedButton.icon(
                  onPressed: () => _startAutoDialing(false),
                  icon: const Icon(Icons.phone, size: 14),
                  label: Text(
                    '($dialableCount)',
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                  ),
                ),
              ),
            if (dialableCount == 0)
              Text(
                'No dialable contacts',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Hardcore Bucket',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
              SizedBox(height: 16),
              Text(
                'Loading hardcore accounts...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Hardcore Bucket',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'Hardcore Bucket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
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
      body: SafeArea(child: _buildBody(theme)),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Column(
      children: [
        // Warning Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: const Border(left: BorderSide(width: 4, color: Colors.red)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hardcore Collection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                    Text(
                      'High-priority accounts requiring immediate attention',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Optimized Statistics Card (2 rows layout)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // First row
                  Row(
                    children: [
                      _buildStatisticTile(
                        Icons.list_alt,
                        'Total',
                        '${_statistics['total_loans'] ?? 0}',
                        iconColor: Colors.red.shade400,
                      ),
                      _buildStatisticTile(
                        Icons.phone,
                        'Dialable',
                        '${_statistics['dialable_count'] ?? 0}',
                        iconColor: Colors.red.shade400,
                      ),
                      _buildStatisticTile(
                        Icons.people,
                        'Co-Maker',
                        '${_statistics['co_maker_phone_count'] ?? 0}',
                        iconColor: Colors.red.shade400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Second row
                  Row(
                    children: [
                      _buildStatisticTile(
                        Icons.person,
                        'Borrower',
                        '${_statistics['borrower_phone_count'] ?? 0}',
                        iconColor: Colors.red.shade400,
                      ),
                      _buildStatisticTile(
                        Icons.block,
                        'No Phone',
                        '${_statistics['no_phone_count'] ?? 0}',
                        iconColor: Colors.red.shade400,
                      ),
                      if ((_statistics['co_maker_percentage'] ?? 0) > 0)
                        _buildStatisticTile(
                          Icons.percent,
                          'Co-Maker %',
                          '${_statistics['co_maker_percentage']}%',
                          iconColor: Colors.red.shade400,
                        )
                      else
                        const Expanded(
                          child: SizedBox(),
                        ), // Empty space if no percentage
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Auto Dialing Buttons
        _buildAutoDialingButtons(),

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
                        'No hardcore accounts assigned',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _loans.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  separatorBuilder: (context, idx) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final loan = _loans[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _buildLoanCard(loan, index),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatisticTile(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor ?? Colors.red.shade400, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(LoanRecord loan, int index) {
    final borrower = loan.borrower;
    final hasCoMaker =
        borrower?.coMakerPhone != null && borrower!.coMakerPhone!.isNotEmpty;
    final hasBorrowerPhone =
        borrower?.borrowerPhone != null && borrower!.borrowerPhone!.isNotEmpty;
    final preferredPhone = borrower?.preferredPhone;
    final preferredName = borrower?.preferredContactName;

    Color cardColor = Colors.white;
    if (!loan.hasValidPhone) {
      cardColor = Colors.grey.shade100;
    } else if (hasCoMaker) {
      cardColor = Colors.red.shade50;
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: cardColor,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red.shade100,
            child: Text(
              loan.loanId?.toString() ?? '${index + 1}',
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  borrower?.borrowerName ?? 'Unknown Borrower',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!loan.hasValidPhone)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Chip(
                    label: const Text(
                      'No Phone',
                      style: TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loan.loanAccountNumber != null)
                Text(
                  'Account: ${loan.loanAccountNumber}',
                  style: const TextStyle(fontSize: 13),
                ),
              if (loan.outstandingBalance != null)
                Text(
                  'Amount: ₱${loan.outstandingBalance!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              if (loan.arrearsDays != null)
                Text(
                  'Arrears: ${loan.arrearsDays} days',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Borrower Info
                  if (borrower?.borrowerName != null)
                    _buildContactInfo(
                      'Borrower',
                      borrower!.borrowerName!,
                      borrower.borrowerPhone,
                      hasBorrowerPhone,
                    ),

                  if (hasCoMaker) const SizedBox(height: 12),

                  // Co-Maker Info
                  if (hasCoMaker)
                    _buildContactInfo(
                      'Co-Maker',
                      borrower.coMakerName ?? 'Unknown Co-Maker',
                      borrower.coMakerPhone,
                      true,
                    ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      if (preferredPhone != null && preferredPhone.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(
                              preferredPhone,
                              preferredName ?? 'Contact',
                            ),
                            icon: const Icon(Icons.phone),
                            label: Text(
                              hasCoMaker ? 'Call Co-Maker' : 'Call Borrower',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (hasCoMaker && hasBorrowerPhone) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(
                              borrower.borrowerPhone!,
                              borrower.borrowerName ?? 'Borrower',
                            ),
                            icon: const Icon(Icons.phone_outlined),
                            label: const Text('Call Borrower'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                      if (!loan.hasValidPhone)
                        const Expanded(
                          child: Text(
                            'No phone number available',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
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
    );
  }

  Widget _buildContactInfo(
    String label,
    String name,
    String? phone,
    bool hasPhone,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              if (phone != null && phone.isNotEmpty)
                Text(
                  phone,
                  style: TextStyle(
                    color: hasPhone ? Colors.red : Colors.grey,
                    fontWeight: hasPhone ? FontWeight.w500 : FontWeight.normal,
                  ),
                )
              else
                const Text(
                  'No phone number',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
