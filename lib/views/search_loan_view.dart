import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'follow_up_form_view.dart';
import 'loan_detail_view.dart';

// ── Model ────────────────────────────────────────────────────────────────────

class SearchResult {
  final int loanId;
  final int? borrowerId;
  final String? uniqueNumber;
  final String? accountNumber;
  final String? fullName;
  final String? borrowerCity;
  final String? phone;
  final String? mobile;

  const SearchResult({
    required this.loanId,
    this.borrowerId,
    this.uniqueNumber,
    this.accountNumber,
    this.fullName,
    this.borrowerCity,
    this.phone,
    this.mobile,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      loanId: (json['loan_id'] as num).toInt(),
      borrowerId: (json['borrower_id'] as num?)?.toInt(),
      uniqueNumber: json['unique_number']?.toString(),
      accountNumber: json['account_number']?.toString(),
      fullName: json['full_name']?.toString(),
      borrowerCity: json['borrower_city']?.toString(),
      phone: json['phone']?.toString(),
      mobile: json['mobile']?.toString(),
    );
  }

  bool get hasPhone =>
      (phone != null && phone!.isNotEmpty) ||
      (mobile != null && mobile!.isNotEmpty);
}

class SearchLoanView extends StatefulWidget {
  const SearchLoanView({super.key});

  @override
  State<SearchLoanView> createState() => _SearchLoanViewState();
}

class _SearchLoanViewState extends State<SearchLoanView> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isSearching = false;
  String? _errorMessage;
  String _lastQuery = '';
  Timer? _debounce;

  static const String _searchEndpoint = '/api/lenderly/dialer/data/search';
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query == _lastQuery) return;
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = null;
        _lastQuery = '';
      });
      return;
    }
    _debounce = Timer(_debounceDuration, () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _lastQuery = query;
    });

    try {
      final queryEndpoint =
          '$_searchEndpoint?q=${Uri.encodeQueryComponent(query)}';
      final response = await ApiClient.get(queryEndpoint);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final rawList = json['results'] as List<dynamic>? ?? [];
        setState(() {
          _results = rawList
              .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList();
          _isSearching = false;
        });
      } else {
        String message = 'Search failed (HTTP ${response.statusCode})';
        try {
          final err = jsonDecode(response.body) as Map<String, dynamic>;
          message = err['message']?.toString() ?? message;
        } catch (_) {}
        setState(() {
          _errorMessage = message;
          _isSearching = false;
        });
      }
    } on AuthSessionExpiredException {
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isSearching = false;
      });
    }
  }

  Future<void> _makePhoneCall(String number, String name) async {
    if (!mounted) return;
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final called = await FlutterPhoneDirectCaller.callNumber(number);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              called == true
                  ? 'Calling $name at $number'
                  : 'Unable to call $number',
            ),
            backgroundColor: called == true ? null : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Call error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Card ──────────────────────────────────────────────────────────────────

  void _openLoanDetail(SearchResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoanDetailView(
          loanId: result.loanId,
          borrowerName: result.fullName,
        ),
      ),
    );
  }

  void _openFollowUp(SearchResult result) {
    final borrowerId = result.borrowerId;
    if (borrowerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrower ID missing for this record.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowUpFormView(
          loanId: result.loanId,
          borrowerId: borrowerId,
          borrowerName: result.fullName,
        ),
      ),
    );
  }

  Widget _buildResultCard(SearchResult result) {
    final name = result.fullName ?? 'Unknown';
    final hasMobile = result.mobile != null && result.mobile!.isNotEmpty;
    final hasPhone = result.phone != null && result.phone!.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openLoanDetail(result),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    radius: 22,
                    child: Text(
                      '#${result.loanId}',
                      style: TextStyle(
                        color: Colors.indigo.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((result.borrowerCity ?? '').isNotEmpty)
                          Text(
                            result.borrowerCity!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (result.accountNumber != null)
                          Text(
                            'Account: ${result.accountNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (result.uniqueNumber != null)
                          Text(
                            'Loan No: ${result.uniqueNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Phone section
              if (hasMobile || hasPhone) ...[
                const Divider(height: 20),
                if (hasMobile)
                  _buildPhoneRow(Icons.phone_android, 'Mobile', result.mobile!),
                if (hasMobile && hasPhone) const SizedBox(height: 4),
                if (hasPhone)
                  _buildPhoneRow(Icons.phone, 'Phone', result.phone!),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (hasMobile)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(result.mobile!, name),
                          icon: const Icon(Icons.phone_android, size: 16),
                          label: const Text('Call Mobile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    if (hasMobile && hasPhone) const SizedBox(width: 8),
                    if (hasPhone)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(result.phone!, name),
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Call Phone'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ] else
                const SizedBox(height: 4),

              // ── Action buttons row ─────────────────────────────────────
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openLoanDetail(result),
                      icon: const Icon(Icons.info_outline, size: 15),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: const BorderSide(color: Colors.indigo),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openFollowUp(result),
                      icon: const Icon(Icons.note_add, size: 15),
                      label: const Text('Follow Up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneRow(IconData icon, String label, String number) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Text(number, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Loans',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Search by account number or borrower name',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by account number or full name...',
                prefixIcon: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.indigo.shade400,
                          ),
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.indigo),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.indigo),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.indigo.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.indigo.shade500,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.indigo.shade200),
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

          // Results
          Expanded(
            child: query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Type a name or account number to search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _search(_lastQuery),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _results.isEmpty && !_isSearching
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No accounts found for\n"$_lastQuery"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      if (_results.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: Colors.indigo.shade50,
                          child: Text(
                            '${_results.length} result${_results.length == 1 ? '' : 's'} found',
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) =>
                              _buildResultCard(_results[i]),
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
