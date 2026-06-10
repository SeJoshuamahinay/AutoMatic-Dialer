import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'follow_up_form_view.dart';
import 'update_borrower_contact_view.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class LoanDetail {
  final int id;
  final String? uniqueNumber;
  final String? accountNumber;
  final String? status;
  final double? loanAmount;
  final double? approvedAmount;
  final double? outstandingBalance;
  final String? disbursedDate;
  final String? releaseDate;
  final String? productName;
  final int? borrowerId;
  final String? borrowerName;
  final String? borrowerPhone;
  final String? borrowerMobile;
  final int? borrowerCountryId;
  final String? borrowerEmail;
  final String? borrowerAddress;
  final String? countryCode;
  final String? houseNumber;
  final String? street;
  final String? village;
  final String? city;
  final String? state;
  final String? province;
  final String? region;
  final String? postalCode;
  final String? zip;
  final int? coSignerId;
  final String? coSignerName;
  final String? coSignerPhone;
  final String? coSignerEmail;
  final String? coSignerAddress;

  LoanDetail({
    required this.id,
    this.uniqueNumber,
    this.accountNumber,
    this.status,
    this.loanAmount,
    this.approvedAmount,
    this.outstandingBalance,
    this.disbursedDate,
    this.releaseDate,
    this.productName,
    this.borrowerId,
    this.borrowerName,
    this.borrowerPhone,
    this.borrowerMobile,
    this.borrowerCountryId,
    this.borrowerEmail,
    this.borrowerAddress,
    this.countryCode,
    this.houseNumber,
    this.street,
    this.village,
    this.city,
    this.state,
    this.province,
    this.region,
    this.postalCode,
    this.zip,
    this.coSignerId,
    this.coSignerName,
    this.coSignerPhone,
    this.coSignerEmail,
    this.coSignerAddress,
  });

  factory LoanDetail.fromJson(Map<String, dynamic> j) {
    return LoanDetail(
      id: (j['id'] as num).toInt(),
      uniqueNumber: j['unique_number']?.toString(),
      accountNumber: j['account_number']?.toString(),
      status: j['status']?.toString(),
      loanAmount: _toDouble(j['loan_amount']),
      approvedAmount: _toDouble(j['approved_amount']),
      outstandingBalance: _toDouble(j['outstanding_balance']),
      disbursedDate: j['disbursed_date']?.toString(),
      releaseDate: j['release_date']?.toString(),
      productName: j['product_name']?.toString(),
      borrowerId: j['borrower_id'] != null
          ? (j['borrower_id'] as num).toInt()
          : null,
      borrowerName: (j['borrower_name'] ?? j['full_name'])?.toString(),
      borrowerPhone: (j['borrower_phone'] ?? j['phone'])?.toString(),
      borrowerMobile: (j['borrower_mobile'] ?? j['mobile'])?.toString(),
      borrowerCountryId: (j['borrower_country_id'] as num?)?.toInt(),
      borrowerEmail: (j['borrower_email'] ?? j['email'])?.toString(),
      borrowerAddress: (j['borrower_address'] ?? j['address'])?.toString(),
      countryCode: (j['borrower_country_code'] ?? j['country_code'])
          ?.toString(),
      houseNumber: (j['borrower_house_number'] ?? j['house_number'])
          ?.toString(),
      street: (j['borrower_street'] ?? j['street'])?.toString(),
      village: (j['borrower_village'] ?? j['village'])?.toString(),
      city: (j['borrower_city'] ?? j['city'])?.toString(),
      state: (j['borrower_state'] ?? j['state'])?.toString(),
      province: (j['borrower_province'] ?? j['province'])?.toString(),
      region: (j['borrower_region'] ?? j['region'])?.toString(),
      postalCode: (j['borrower_postal_code'] ?? j['postal_code'])?.toString(),
      zip: (j['borrower_zip'] ?? j['zip'])?.toString(),
      coSignerId: () {
        final cs = j['co_signer'] as Map<String, dynamic>?;
        final v = cs?['id'] ?? j['co_signer_id'];
        return v != null ? (v as num).toInt() : null;
      }(),
      coSignerName:
          ((j['co_signer'] as Map<String, dynamic>?)?['name'] ??
                  j['co_signer_name'])
              ?.toString(),
      coSignerPhone:
          ((j['co_signer'] as Map<String, dynamic>?)?['phone'] ??
                  j['co_signer_phone'])
              ?.toString(),
      coSignerEmail:
          ((j['co_signer'] as Map<String, dynamic>?)?['email'] ??
                  j['co_signer_email'])
              ?.toString(),
      coSignerAddress:
          ((j['co_signer'] as Map<String, dynamic>?)?['address'] ??
                  j['co_signer_address'])
              ?.toString(),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class LoanSchedule {
  final int id;
  final String? dueDate;
  final String? repayment;
  final String? pendingAmount;
  final String? status;

  LoanSchedule({
    required this.id,
    this.dueDate,
    this.repayment,
    this.pendingAmount,
    this.status,
  });

  factory LoanSchedule.fromJson(Map<String, dynamic> j) => LoanSchedule(
    id: (j['id'] as num).toInt(),
    dueDate: j['due_date']?.toString(),
    repayment: j['repayment']?.toString(),
    pendingAmount: j['pending_amount']?.toString(),
    status: j['status']?.toString(),
  );
}

class LoanTransaction {
  final int id;
  final String? amount;
  final String? paymentDate;
  final String? paymentMethod;
  final String? referenceNumber;

  LoanTransaction({
    required this.id,
    this.amount,
    this.paymentDate,
    this.paymentMethod,
    this.referenceNumber,
  });

  factory LoanTransaction.fromJson(Map<String, dynamic> j) => LoanTransaction(
    id: (j['id'] as num).toInt(),
    amount: j['amount']?.toString(),
    paymentDate: j['payment_date']?.toString(),
    paymentMethod: j['payment_method']?.toString(),
    referenceNumber: j['reference_number']?.toString(),
  );
}

class FollowUpRecord {
  final int id;
  final String? subject;
  final String? discussionNotes;
  final String? followUpActionNotes;
  final String? modeOfPayment;
  final String? recoveryLikelihood;
  final String? amountRecovered;
  final String? dateOfContact;
  final String? actionDate;
  final String? actionPersonName;
  final String? createdAt;

  FollowUpRecord({
    required this.id,
    this.subject,
    this.discussionNotes,
    this.followUpActionNotes,
    this.modeOfPayment,
    this.recoveryLikelihood,
    this.amountRecovered,
    this.dateOfContact,
    this.actionDate,
    this.actionPersonName,
    this.createdAt,
  });

  factory FollowUpRecord.fromJson(Map<String, dynamic> j) => FollowUpRecord(
    id: (j['id'] as num).toInt(),
    subject: j['subject']?.toString(),
    discussionNotes: j['discussion_notes']?.toString(),
    followUpActionNotes: j['follow_up_action_notes']?.toString(),
    modeOfPayment: j['mode_of_payment']?.toString(),
    recoveryLikelihood: j['recovery_likelihood']?.toString(),
    amountRecovered: j['amount_recovered']?.toString(),
    dateOfContact: j['date_of_contact']?.toString(),
    actionDate: j['action_date']?.toString(),
    actionPersonName: j['action_person_name']?.toString(),
    createdAt: j['created_at']?.toString(),
  );
}

// ── View ──────────────────────────────────────────────────────────────────────

class LoanDetailView extends StatefulWidget {
  final int loanId;
  final String? borrowerName;

  const LoanDetailView({super.key, required this.loanId, this.borrowerName});

  @override
  State<LoanDetailView> createState() => _LoanDetailViewState();
}

class _LoanDetailViewState extends State<LoanDetailView>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  LoanDetail? _loan;
  List<LoanSchedule> _schedules = [];
  List<LoanTransaction> _transactions = [];
  List<FollowUpRecord> _followUps = [];
  late TabController _tabController;
  bool _fabOpen = false;

  static const String _detailEndpoint = '/api/lenderly/dialer/get-loan-details';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.get('$_detailEndpoint/${widget.loanId}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        setState(() {
          _loan = LoanDetail.fromJson(data['loan'] as Map<String, dynamic>);
          _schedules = (data['schedules'] as List<dynamic>? ?? [])
              .map((e) => LoanSchedule.fromJson(e as Map<String, dynamic>))
              .toList();
          _transactions = (data['transactions'] as List<dynamic>? ?? [])
              .map((e) => LoanTransaction.fromJson(e as Map<String, dynamic>))
              .toList();
          _followUps = (data['follow_ups'] as List<dynamic>? ?? [])
              .map((e) => FollowUpRecord.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        String msg = 'Failed to load loan (HTTP ${response.statusCode})';
        try {
          final err = jsonDecode(response.body) as Map<String, dynamic>;
          msg = err['message']?.toString() ?? msg;
        } catch (_) {}
        setState(() {
          _errorMessage = msg;
          _isLoading = false;
        });
      }
    } on AuthSessionExpiredException {
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
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
              called == true ? 'Calling $name' : 'Unable to call $number',
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

  void _openFollowUpForm() async {
    if (_loan == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowUpFormView(
          loanId: _loan!.id,
          borrowerId: _loan!.borrowerId ?? 0,
          borrowerName: _loan!.borrowerName,
        ),
      ),
    );
    if (result == true) {
      // Reload to refresh follow-ups list
      _loadDetail();
    }
  }

  void _openUpdateContactForm() async {
    if (_loan == null || _loan!.borrowerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrower ID is missing for this loan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateBorrowerContactView(
          borrowerId: _loan!.borrowerId!,
          borrowerName: _loan!.borrowerName,
          phone: _loan!.borrowerPhone,
          mobile: _loan!.borrowerMobile,
          borrowerCountryId: _loan!.borrowerCountryId,
          countryCode: _loan!.countryCode,
          address: _loan!.borrowerAddress,
          houseNumber: _loan!.houseNumber,
          street: _loan!.street,
          village: _loan!.village,
          city: _loan!.city,
          state: _loan!.state,
          province: _loan!.province,
          region: _loan!.region,
          postalCode: _loan!.postalCode,
        ),
      ),
    );

    if (result == true) {
      _loadDetail();
    }
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    final l = _loan!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard('Loan Info', Icons.description, [
          _infoRow('Loan No', l.uniqueNumber),
          _infoRow('Account No', l.accountNumber),
          _infoRow('Product', l.productName),
          _infoRow(
            'Status',
            _fStatus(l.status),
            valueColor: _statusColor(l.status),
          ),
          _infoRow('Loan Amount', _fAmt(l.loanAmount)),
          _infoRow('Approved Amount', _fAmt(l.approvedAmount)),
          _infoRow(
            'Outstanding Balance',
            _fAmt(l.outstandingBalance),
            valueColor: Colors.red[700],
          ),
          _infoRow('Disbursed Date', _fDate(l.disbursedDate)),
          _infoRow('Release Date', _fDate(l.releaseDate)),
        ]),
        const SizedBox(height: 12),
        _sectionCard('Borrower', Icons.person, [
          _infoRow('Name', l.borrowerName),
          _infoRow('Email', l.borrowerEmail),
          _infoRow('Address', l.borrowerAddress),
          if (l.borrowerMobile != null && l.borrowerMobile!.isNotEmpty)
            _callRow('Mobile', l.borrowerMobile!, l.borrowerName ?? 'Borrower'),
          if (l.borrowerPhone != null && l.borrowerPhone!.isNotEmpty)
            _callRow('Phone', l.borrowerPhone!, l.borrowerName ?? 'Borrower'),
        ]),
        if (l.coSignerName != null) ...[
          const SizedBox(height: 12),
          _sectionCard('Co-signer', Icons.people, [
            _infoRow('Name', l.coSignerName),
            _infoRow('Email', l.coSignerEmail),
            _infoRow('Address', l.coSignerAddress),
            if (l.coSignerPhone != null && l.coSignerPhone!.isNotEmpty)
              _callRow(
                'Phone',
                l.coSignerPhone!,
                l.coSignerName ?? 'Co-signer',
              ),
          ]),
        ],
      ],
    );
  }

  Widget _buildSchedulesTab() {
    if (_schedules.isEmpty) {
      return _emptyState('No schedules found', Icons.calendar_today);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final s = _schedules[i];
        final statusColor = s.status == 'paid'
            ? Colors.green
            : s.status == 'arrears'
            ? Colors.red
            : Colors.orange;
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.15),
              child: Icon(Icons.calendar_today, color: statusColor, size: 18),
            ),
            title: Text(
              _fDate(s.dueDate),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Repayment: ${_fAmt(s.repayment)}  •  Pending: ${_fAmt(s.pendingAmount)}',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _fStatus(s.status).toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return _emptyState('No transactions found', Icons.receipt_long);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = _transactions[i];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade50,
              child: Icon(
                Icons.payments,
                color: Colors.green.shade700,
                size: 18,
              ),
            ),
            title: Text(
              _fAmt(t.amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${_fDate(t.paymentDate)}  •  ${t.paymentMethod ?? '—'}',
            ),
            trailing: t.referenceNumber != null
                ? Text(
                    t.referenceNumber!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildFollowUpsTab() {
    if (_followUps.isEmpty) {
      return _emptyState('No follow-ups yet', Icons.note_alt);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _followUps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final f = _followUps[i];
        final likelihoodColor = f.recoveryLikelihood == 'High'
            ? Colors.green
            : f.recoveryLikelihood == 'Medium'
            ? Colors.orange
            : Colors.red;
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        f.subject ?? 'No subject',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (f.recoveryLikelihood != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: likelihoodColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          f.recoveryLikelihood!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: likelihoodColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (f.discussionNotes != null && f.discussionNotes!.isNotEmpty)
                  Text(
                    f.discussionNotes!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                if (f.followUpActionNotes != null &&
                    f.followUpActionNotes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 13,
                        color: Colors.indigo[400],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          f.followUpActionNotes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.indigo[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Contact: ${_fDate(f.dateOfContact)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.event, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Next: ${_fDate(f.actionDate)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (f.actionPersonName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'By: ${f.actionPersonName}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value, {Color? valueColor}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _callRow(String label, String number, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              number,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () => _makePhoneCall(number, name),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.phone, size: 16, color: Colors.indigo.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
        ],
      ),
    );
  }

  // ── Formatters ──────────────────────────────────────────────────────────

  static final _currencyFmt = NumberFormat('#,##0.00', 'en_PH');
  static final _dateFmt = DateFormat('MMM d, yyyy');

  String _fDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw);
    return dt != null ? _dateFmt.format(dt) : raw;
  }

  String _fAmt(dynamic raw) {
    if (raw == null) return '—';
    final n = raw is num ? raw.toDouble() : double.tryParse(raw.toString());
    return n != null ? '₱${_currencyFmt.format(n)}' : raw.toString();
  }

  String _fStatus(String? s) {
    if (s == null || s.isEmpty) return '—';
    return s
        .replaceAll('_', ' ')
        .replaceAll('patial', 'partial')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green[700]!;
      case 'arrears':
        return Colors.red[700]!;
      case 'closed':
        return Colors.grey[600]!;
      default:
        return Colors.orange[700]!;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.borrowerName?.toUpperCase() ?? 'Loan #${widget.loanId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            if (_loan?.uniqueNumber != null)
              Text(
                _loan!.uniqueNumber!,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 65,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDetail,
          ),
        ],
        bottom: _isLoading || _errorMessage != null
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Schedules'),
                  Tab(text: 'Transactions'),
                  Tab(text: 'Follow-ups'),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDetail,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSchedulesTab(),
                _buildTransactionsTab(),
                _buildFollowUpsTab(),
              ],
            ),
      floatingActionButton: _loan == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedOpacity(
                  opacity: _fabOpen ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: AnimatedSlide(
                    offset: _fabOpen ? Offset.zero : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 180),
                    child: IgnorePointer(
                      ignoring: !_fabOpen,
                      child: FloatingActionButton.extended(
                        heroTag: 'update_contact_btn',
                        onPressed: () {
                          setState(() => _fabOpen = false);
                          _openUpdateContactForm();
                        },
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.edit_location_alt),
                        label: const Text('Update Contact'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: _fabOpen ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 130),
                  child: AnimatedSlide(
                    offset: _fabOpen ? Offset.zero : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 130),
                    child: IgnorePointer(
                      ignoring: !_fabOpen,
                      child: FloatingActionButton.extended(
                        heroTag: 'add_followup_btn',
                        onPressed: () {
                          setState(() => _fabOpen = false);
                          _openFollowUpForm();
                        },
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.note_add),
                        label: const Text('Add Follow-up'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'main_fab',
                  onPressed: () => setState(() => _fabOpen = !_fabOpen),
                  backgroundColor: Colors.indigo[900],
                  foregroundColor: Colors.white,
                  child: AnimatedRotation(
                    turns: _fabOpen ? 0.125 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
    );
  }
}
