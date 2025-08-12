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

class MidRangeView extends StatefulWidget {
  final AssignmentData? assignmentData;

  const MidRangeView({super.key, this.assignmentData});

  @override
  State<MidRangeView> createState() => _MidRangeViewState();
}

class _MidRangeViewState extends State<MidRangeView> {
  List<LoanRecord> _loans = [];
  List<LoanRecord> _filteredLoans = [];
  Map<String, dynamic> _statistics = {};
  UserSession? _userSession;
  AssignmentData? _assignmentData;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterLoans();
    });
  }

  void _filterLoans() {
    if (_searchQuery.isEmpty) {
      _filteredLoans = List.from(_loans);
    } else {
      _filteredLoans = _loans.where((loan) {
        final loanId = loan.loanId?.toLowerCase() ?? '';
        final borrowerName = loan.borrower?.borrowerName?.toLowerCase() ?? '';
        final accountNumber = loan.loanAccountNumber?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return loanId.contains(query) ||
            borrowerName.contains(query) ||
            accountNumber.contains(query);
      }).toList();
    }
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
          _errorMessage = 'Please log in to view middlecore accounts';
          _isLoading = false;
        });
        return;
      }

      final response = await AccountsBucketService.assignLoansToUser(
        _userSession!.userId.toString(),
      );

      if (!response.success || response.data == null) {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
        return;
      }

      _assignmentData = response.data;
      _loadLoansData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading middlecore data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _loadLoansData() {
    if (_assignmentData == null) return;

    setState(() {
      _isLoading = false;
      _loans = AccountsBucketService.getLoansByBucket(
        _assignmentData!,
        BucketType.middlecore,
      );
      _statistics = AccountsBucketService.getBucketStatistics(
        _assignmentData!,
        BucketType.middlecore,
      );
      _filterLoans(); // Initialize filtered loans
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.assignmentData != null) {
        // If assignmentData was passed, re-request fresh data
        _userSession = await SharedPrefsStorageService.getUserSession();
        if (_userSession != null) {
          final response = await AccountsBucketService.assignLoansToUser(
            _userSession!.userId.toString(),
          );

          if (response.success && response.data != null) {
            setState(() {
              _assignmentData = response.data;
              _isLoading = false;
            });
            _loadLoansData();
          } else {
            setState(() {
              _errorMessage = 'Failed to refresh data: ${response.message}';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Please log in to refresh data';
            _isLoading = false;
          });
        }
      } else {
        // Re-initialize data if no assignmentData was passed
        await _initializeData();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to refresh data: $e';
        _isLoading = false;
      });
    }
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
        BucketType.middlecore,
        _assignmentData!,
      );
    } else {
      presenter.startBorrowerDialingForBucket(
        BucketType.middlecore,
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
    final borrowerCount = _statistics['borrower_phone_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          // Icon and Header
          Icon(Icons.autorenew, color: Colors.orange.shade700, size: 16),
          const SizedBox(width: 6),
          Text(
            'Automation',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade800,
            ),
          ),
          const Spacer(),
          // Buttons
          if (coMakerCount > 0) ...[
            _buildCompactButton(
              onPressed: () => _startAutoDialing(true),
              icon: Icons.phone_callback,
              count: coMakerCount,
              color: Colors.green,
              label: 'Co-Makers',
            ),
            if (borrowerCount > 0) const SizedBox(width: 6),
          ],
          const SizedBox(width: 5),
          if (borrowerCount > 0)
            _buildCompactButton(
              onPressed: () => _startAutoDialing(false),
              icon: Icons.person,
              count: borrowerCount,
              color: Colors.orange,
              label: 'Borrowers',
            ),
          if (coMakerCount == 0 && borrowerCount == 0)
            Text(
              'No dialable',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required VoidCallback onPressed,
    required IconData icon,
    required int count,
    required Color color,
    required String label,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12),
            const SizedBox(width: 4),
            Text(
              '$label ($count)',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Middlecore Bucket',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Moderate priority accounts requiring focused attention',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade100,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 70,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.orange,
        child: SafeArea(child: _buildBody(theme)),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 16),
            Text(
              'Loading middlecore accounts...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
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
                backgroundColor: Colors.orange,
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
      );
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Loan ID, Account Number, or Borrower Name',
              prefixIcon: const Icon(Icons.search, color: Colors.orange),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.orange),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.orange.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.orange.shade500, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.orange.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
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
              child: Row(
                children: [
                  _buildStatisticTile(
                    Icons.contacts,
                    'Total Contacts',
                    '${_statistics['total_loans'] ?? 0}',
                    iconColor: Colors.orange.shade400,
                  ),
                  _buildStatisticTile(
                    Icons.phone_in_talk,
                    'Called',
                    '0', // TODO: Integrate with dialer state
                    iconColor: Colors.green.shade400,
                  ),
                  _buildStatisticTile(
                    Icons.pending,
                    'Pending',
                    '${_statistics['total_loans'] ?? 0}', // For now, all are pending
                    iconColor: Colors.orange.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Automationing Buttons
        _buildAutoDialingButtons(),

        // Loans List
        Expanded(
          child: _filteredLoans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No accounts found matching "$_searchQuery"'
                            : 'No middlecore accounts assigned',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                          },
                          child: const Text(
                            'Clear search',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search Results Count
                    if (_searchQuery.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: Colors.orange.shade50,
                        child: Text(
                          'Found ${_filteredLoans.length} of ${_loans.length} accounts',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    // Loans List
                    Expanded(
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredLoans.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        separatorBuilder: (context, idx) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final loan = _filteredLoans[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _buildLoanCard(loan, index),
                          );
                        },
                      ),
                    ),
                  ],
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
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor ?? Colors.orange.shade400, size: 16),
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
      cardColor = Colors.orange.shade50;
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
            backgroundColor: Colors.orange.shade100,
            child: Text(
              loan.loanId?.toString() ?? '${index + 1}',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  (borrower?.borrowerName ?? 'Unknown Borrower').toUpperCase(),
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
                  style: const TextStyle(color: Colors.orange, fontSize: 13),
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
                              backgroundColor: Colors.orange,
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
                    color: hasPhone ? Colors.blue : Colors.grey,
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
