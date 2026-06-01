import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/commons/models/loan_models.dart';
import 'package:lenderly_dialer/commons/services/accounts_bucket_service.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:lenderly_dialer/views/follow_up_form_view.dart';
import 'package:lenderly_dialer/views/loan_detail_view.dart';

class FrontEndView extends StatefulWidget {
  const FrontEndView({super.key});

  @override
  State<FrontEndView> createState() => _FrontEndViewState();
}

class _FrontEndViewState extends State<FrontEndView> {
  List<DialerLoanRecord> _loans = [];
  List<DialerLoanRecord> _filteredLoans = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final _amtFmt = NumberFormat('#,##0.00', 'en_PH');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
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
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredLoans = List.from(_loans);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredLoans = _loans.where((r) {
        return r.fullName.toLowerCase().contains(q) ||
            r.accountNumber.toLowerCase().contains(q) ||
            r.uniqueNumber.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await SharedPrefsStorageService.getUserSession();
      if (session == null) {
        setState(() {
          _errorMessage = 'Please log in to view frontend accounts';
          _isLoading = false;
        });
        return;
      }

      final records = await AccountsBucketService.getDialerDataByBucket(
        session.userId.toString(),
        'frontend',
      );

      setState(() {
        _loans = records;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load frontend accounts: $e';
        _isLoading = false;
      });
    }
  }

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
      final d = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy').format(d);
    } catch (_) {
      return raw;
    }
  }

  void _openLoanDetail(DialerLoanRecord r) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LoanDetailView(loanId: r.loanId)));
  }

  Future<void> _openFollowUp(DialerLoanRecord r) async {
    // Show loading
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Loading follow-up form...'),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final borrowerId = await AccountsBucketService.getBorrowerIdForLoan(
        r.loanId,
      );
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FollowUpFormView(
            loanId: r.loanId,
            borrowerId: borrowerId,
            borrowerName: r.fullName,
          ),
        ),
      );
      if (result == true && mounted) {
        _loadData(); // refresh after successful follow-up
      }
    } catch (e) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not open follow-up form: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phone, String name) async {
    if (!mounted) return;
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final called = await FlutterPhoneDirectCaller.callNumber(phone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              called == true
                  ? 'Calling $name at $phone'
                  : 'Unable to call $phone',
            ),
            backgroundColor: called == true ? null : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frontend Bucket',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Early intervention accounts',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade100,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 70,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.blue,
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or account number',
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.blue),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade300),
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
        // Stats bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _statTile(
                    Icons.folder,
                    'Total',
                    '${_loans.length}',
                    Colors.blue.shade400,
                  ),
                  _statTile(
                    Icons.phone,
                    'Dialable',
                    '${_loans.where((r) => r.hasValidPhone).length}',
                    Colors.green.shade400,
                  ),
                  _statTile(
                    Icons.search,
                    'Filtered',
                    '${_filteredLoans.length}',
                    Colors.orange.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
        // List
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
                            ? 'No accounts matching "$_searchQuery"'
                            : 'No frontend accounts',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _filteredLoans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _buildCard(_filteredLoans[i], i),
                ),
        ),
      ],
    );
  }

  Widget _statTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(DialerLoanRecord r, int index) {
    final hasLastFollowUp = r.lastLafuDate != null;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: r.hasValidPhone ? Colors.white : Colors.grey.shade50,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openLoanDetail(r),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.blue.shade800,
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
                  // Outstanding balance
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
              // Due date + last follow-up
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
              // Action buttons row
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openLoanDetail(r),
                      icon: const Icon(Icons.description_outlined, size: 14),
                      label: const Text(
                        'View Details',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
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
                      onPressed: () => _openFollowUp(r),
                      icon: const Icon(Icons.add_comment_outlined, size: 14),
                      label: const Text(
                        'Follow-up',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
              // Phone buttons
              if (r.hasValidPhone) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (r.hasPhone)
                      Expanded(
                        child: _callButton(
                          r.phone!,
                          r.fullName,
                          Icons.phone,
                          'Call Phone',
                          Colors.blue,
                        ),
                      ),
                    if (r.hasPhone && r.hasMobile) const SizedBox(width: 8),
                    if (r.hasMobile)
                      Expanded(
                        child: _callButton(
                          r.mobile!,
                          r.fullName,
                          Icons.phone_android,
                          'Call Mobile',
                          Colors.indigo,
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
    );
  }

  Widget _callButton(
    String phone,
    String name,
    IconData icon,
    String label,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _makePhoneCall(phone, name),
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
