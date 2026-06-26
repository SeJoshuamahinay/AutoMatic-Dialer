import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/app_config.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:http/http.dart' as http;

// ─── Search item model ───────────────────────

class _LoanSearchItem {
  final int loanId;
  final int? borrowerId;
  final String? fullName;
  final String? uniqueNumber;

  const _LoanSearchItem({
    required this.loanId,
    this.borrowerId,
    this.fullName,
    this.uniqueNumber,
  });

  factory _LoanSearchItem.fromJson(Map<String, dynamic> json) {
    return _LoanSearchItem(
      loanId: (json['loan_id'] as num).toInt(),
      borrowerId: (json['borrower_id'] as num?)?.toInt(),
      fullName: json['full_name']?.toString(),
      uniqueNumber: json['unique_number']?.toString(),
    );
  }

  String get displayName =>
      fullName?.trim().isNotEmpty == true ? fullName!.trim() : 'Unknown';
}

class _ScheduleItem {
  final int id;
  final String? dueDate;
  final String? repayment;
  final String? pendingAmount;
  final String? status;

  const _ScheduleItem({
    required this.id,
    this.dueDate,
    this.repayment,
    this.pendingAmount,
    this.status,
  });

  factory _ScheduleItem.fromJson(Map<String, dynamic> j) => _ScheduleItem(
    id: (j['id'] as num).toInt(),
    dueDate: j['due_date']?.toString(),
    repayment: j['repayment']?.toString(),
    pendingAmount: j['pending_amount']?.toString(),
    status: j['status']?.toString(),
  );
}

// ─── Form ─────────────────────────────────────

class RcbcPostingRequestForm extends StatefulWidget {
  final String? initialReference;
  final double? initialAmount;
  final String? initialPostingDate;

  const RcbcPostingRequestForm({
    super.key,
    this.initialReference,
    this.initialAmount,
    this.initialPostingDate,
  });

  static Future<bool?> open(
    BuildContext context, {
    String? reference,
    double? amount,
    String? postingDate,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RcbcPostingRequestForm(
          initialReference: reference,
          initialAmount: amount,
          initialPostingDate: postingDate,
        ),
      ),
    );
  }

  @override
  State<RcbcPostingRequestForm> createState() => _RcbcPostingRequestFormState();
}

class _RcbcPostingRequestFormState extends State<RcbcPostingRequestForm> {
  static const _accentColor = Color.fromARGB(255, 234, 58, 23);
  static const _searchEndpoint = '/api/lenderly/dialer/data/search';
  static const _detailEndpoint = '/api/lenderly/dialer/get-loan-details';

  final _formKey = GlobalKey<FormState>();
  final _referenceCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _multiLoanAmountCtrl = TextEditingController();
  final _paymentDateCtrl = TextEditingController();
  final _imagePicker = ImagePicker();
  final _currencyFmt = NumberFormat('#,##0.00', 'en_PH');

  DateTime? _paymentDate;
  bool _multipleLoanRepayment = false;
  final List<XFile> _attachments = [];
  String? _errorMessage;
  Map<String, dynamic>? _verifiedTransaction;

  _LoanSearchItem? _selectedLoan;
  List<_ScheduleItem> _schedules = [];
  _ScheduleItem? _selectedSchedule;
  bool _loadingLoanDetails = false;

  bool _submitting = false;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialReference != null) {
      _referenceCtrl.text = widget.initialReference!;
    }
    if (widget.initialAmount != null) {
      _amountCtrl.text = widget.initialAmount!.toStringAsFixed(2);
    }
    if (widget.initialPostingDate != null) {
      try {
        _paymentDate = DateTime.parse(widget.initialPostingDate!);
        _paymentDateCtrl.text = DateFormat('MMM d, yyyy').format(_paymentDate!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _referenceCtrl.dispose();
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    _multiLoanAmountCtrl.dispose();
    _paymentDateCtrl.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────

  String _fmtAmount(dynamic raw) {
    final v = double.tryParse(raw?.toString() ?? '') ?? 0;
    return '₱${_currencyFmt.format(v)}';
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  // ─── Loan search & selection ───────────────

  Future<void> _pickLoan() async {
    final picked = await showDialog<_LoanSearchItem>(
      context: context,
      builder: (dialogContext) {
        String query = '';
        Timer? debounce;
        bool isLoading = false;
        String? error;
        List<_LoanSearchItem> results = [];

        Future<void> runSearch(StateSetter setDialogState) async {
          final q = query.trim();
          if (q.length < 2) {
            setDialogState(() {
              results = [];
              error = null;
              isLoading = false;
            });
            return;
          }

          setDialogState(() {
            isLoading = true;
            error = null;
          });

          try {
            final endpoint =
                '$_searchEndpoint?q=${Uri.encodeQueryComponent(q)}';
            final response = await ApiClient.get(endpoint);

            if (response.statusCode == 200) {
              final body = jsonDecode(response.body) as Map<String, dynamic>;
              final rawList = body['results'] as List<dynamic>? ?? [];
              final found = rawList
                  .map(
                    (e) => _LoanSearchItem.fromJson(e as Map<String, dynamic>),
                  )
                  .where((e) => e.borrowerId != null)
                  .toList();
              setDialogState(() {
                results = found;
                isLoading = false;
              });
            } else {
              setDialogState(() {
                results = [];
                error = 'Search failed (HTTP ${response.statusCode})';
                isLoading = false;
              });
            }
          } catch (e) {
            setDialogState(() {
              results = [];
              error = e.toString();
              isLoading = false;
            });
          }
        }

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final screenSize = MediaQuery.of(ctx).size;
            return AlertDialog(
              title: const Text('Select Loan / Borrower'),
              content: SizedBox(
                width: screenSize.width > 520 ? 460 : screenSize.width * 0.88,
                height: screenSize.height > 760
                    ? 420
                    : screenSize.height * 0.62,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search by name or account number',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        query = v;
                        debounce?.cancel();
                        debounce = Timer(
                          const Duration(milliseconds: 350),
                          () => runSearch(setDialogState),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          if (isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (error != null) {
                            return Center(
                              child: Text(
                                error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          if (query.trim().length < 2) {
                            return const Center(
                              child: Text('Type at least 2 characters.'),
                            );
                          }
                          if (results.isEmpty) {
                            return const Center(
                              child: Text('No results found.'),
                            );
                          }
                          return ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (_, i) {
                              final item = results[i];
                              return ListTile(
                                title: Text(item.displayName),
                                subtitle: Text(
                                  'Loan ID: ${item.loanId}  •  ${item.uniqueNumber ?? ''}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () =>
                                    Navigator.of(dialogContext).pop(item),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedLoan = picked;
      _selectedSchedule = null;
      _schedules = [];
      _loadingLoanDetails = true;
    });

    await _loadLoanSchedules(picked.loanId);
  }

  Future<void> _loadLoanSchedules(int loanId) async {
    try {
      final response = await ApiClient.get('$_detailEndpoint/$loanId');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;
        final schedulesRaw = data?['schedules'] as List<dynamic>? ?? [];
        final schedules = schedulesRaw
            .map((e) => _ScheduleItem.fromJson(e as Map<String, dynamic>))
            .where((s) {
              final outstanding =
                  double.tryParse(s.pendingAmount?.toString() ?? '') ?? 0;
              return outstanding > 0;
            })
            .toList();

        if (!mounted) return;

        if (schedules.isEmpty) {
          _showSnack(
            'No outstanding schedules found for this loan.',
            error: true,
          );
          setState(() {
            _selectedLoan = null;
            _loadingLoanDetails = false;
          });
          return;
        }

        setState(() {
          _schedules = schedules;
          _selectedSchedule = schedules.length == 1 ? schedules.first : null;
          _loadingLoanDetails = false;
        });
      } else {
        _showSnack('Failed to load loan details.', error: true);
        setState(() {
          _selectedLoan = null;
          _loadingLoanDetails = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error loading loan details: $e', error: true);
      setState(() {
        _selectedLoan = null;
        _loadingLoanDetails = false;
      });
    }
  }

  void _clearLoan() {
    setState(() {
      _selectedLoan = null;
      _selectedSchedule = null;
      _schedules = [];
    });
  }

  void _pickSchedule() {
    if (_schedules.length <= 1) return;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Schedule'),
        children: _schedules.map((s) {
          final dueDate = _fmtDate(s.dueDate);
          return RadioListTile<_ScheduleItem>(
            title: Text('Due: $dueDate'),
            subtitle: Text(
              'Amount: ${_fmtAmount(s.repayment)}  •  ${s.status ?? '—'}',
            ),
            value: s,
            groupValue: _selectedSchedule,
            onChanged: (v) {
              Navigator.of(ctx).pop();
              if (v != null) setState(() => _selectedSchedule = v);
            },
          );
        }).toList(),
      ),
    );
  }

  // ─── Attachment picking ────────────────────

  Future<void> _pickAttachments() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final file = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (file != null) setState(() => _attachments.add(file));
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  // ─── Date picker ───────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _paymentDate = picked;
        _paymentDateCtrl.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  // ─── Main submit flow ──────────────────────

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLoan == null) {
      _showSnack('Please select a loan.', error: true);
      return;
    }
    if (_selectedSchedule == null) {
      _showSnack('Please select a schedule.', error: true);
      return;
    }
    if (_paymentDate == null) {
      _showSnack('Please select a payment date.', error: true);
      return;
    }
    if (_attachments.isEmpty) {
      _showSnack('Please attach at least one file.', error: true);
      return;
    }

    setState(() {
      _verifying = true;
      _errorMessage = null;
      _verifiedTransaction = null;
    });

    try {
      final response = await ApiClient.post(
        '/api/rcbc-payment-verifications/verify-reference',
        body: {
          'reference_number': _referenceCtrl.text.trim(),
          'amount': double.parse(_amountCtrl.text.trim()),
        },
      );

      if (!mounted) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['success'] == true) {
        final transaction = body['transaction'] as Map<String, dynamic>?;
        final postings = transaction?['postings'] as List<dynamic>? ?? [];

        setState(() => _verifiedTransaction = transaction);

        if (postings.isNotEmpty) {
          if (!mounted) return;
          _showAlreadyPostedDialog(transaction);
          return;
        }

        if (!mounted) return;
        _showConfirmDialog(transaction);
      } else {
        setState(() {
          _errorMessage = body['message']?.toString() ?? 'Verification failed.';
          _verifying = false;
        });
      }
    } on AuthSessionExpiredException {
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _verifying = false;
      });
    }
  }

  void _showAlreadyPostedDialog(Map<String, dynamic>? transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Already Posted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This reference number already has existing posting data. '
              'Submission is not allowed.',
            ),
            if (transaction != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction ID: ${transaction['transaction_id'] ?? '-'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Credit: ${_fmtAmount(transaction['credit'])}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _verifying = false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(Map<String, dynamic>? transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text('Verified'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reference number and amount verified successfully.'),
            if (transaction != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction ID: ${transaction['transaction_id'] ?? '-'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Credit: ${_fmtAmount(transaction['credit'])}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade800,
                      ),
                    ),
                    if (transaction['posting_date'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Posting Date: ${transaction['posting_date']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Do you still wish to submit this posting request?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _verifying = false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _verifying = false);
              _submitPosting();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // ─── Actual submission ─────────────────────

  Future<void> _submitPosting() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final session = await SharedPrefsStorageService.getUserSession();
      final token = await SharedPrefsStorageService.getAuthToken();
      final baseUrl = EnvironmentConfig.apiBaseUrl;
      final uri = Uri.parse(
        '$baseUrl/api/rcbc-payment-verifications/rcbc-payment-verifications',
      );
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['X-App-Version'] = AppConfig.version;

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (session?.userId != null) {
        request.fields['user_id'] = session!.userId.toString();
      }

      if (_selectedSchedule == null) {
        _showSnack(
          'Schedule not selected. Please go back and select a schedule.',
          error: true,
        );
        setState(() => _submitting = false);
        return;
      }
      request.fields['loan_schedule_id'] = _selectedSchedule!.id.toString();
      request.fields['amount'] = _amountCtrl.text.trim();
      request.fields['reference_number'] = _referenceCtrl.text.trim();
      request.fields['payment_date'] = DateFormat(
        'yyyy-MM-dd',
      ).format(_paymentDate!);

      final rcbcTxId = _verifiedTransaction?['transaction_id']?.toString();
      if (rcbcTxId != null && rcbcTxId.isNotEmpty) {
        request.fields['rcbc_transaction_id'] = rcbcTxId;
      }

      if (_remarksCtrl.text.trim().isNotEmpty) {
        request.fields['remarks'] = _remarksCtrl.text.trim();
      }

      if (_multipleLoanRepayment) {
        request.fields['multiple_loan_repayment'] = '1';
        if (_multiLoanAmountCtrl.text.trim().isNotEmpty) {
          request.fields['multiple_loan_repayment_amount'] =
              _multiLoanAmountCtrl.text.trim();
        }
      }

      for (final file in _attachments) {
        final bytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'attachments[]',
            bytes,
            filename: file.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && body['success'] == true) {
        _showSnack('Posting request submitted successfully.');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      } else {
        setState(() {
          _errorMessage =
              body['message']?.toString() ??
              'Failed to submit posting request.';
          _submitting = false;
        });
      }
    } on AuthSessionExpiredException {
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _submitting = false;
      });
    }
  }

  // ─── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Request Posting',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Payment Details'),
              const SizedBox(height: 12),
              _buildCard([
                _buildField(
                  label: 'Reference Number',
                  controller: _referenceCtrl,
                  hint: 'RCBC reference / transaction number',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Amount',
                  controller: _amountCtrl,
                  hint: '0.00',
                  prefix: '₱ ',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Payment Date',
                  readOnly: true,
                  controller: _paymentDateCtrl,
                  hint: 'Tap to select date',
                  onTap: _pickDate,
                  validator: (_) =>
                      _paymentDate == null ? 'Please select a date' : null,
                  suffixIcon: Icons.calendar_today,
                ),
              ]),

              const SizedBox(height: 24),
              _buildSection('Loan / Borrower'),
              const SizedBox(height: 12),
              _buildCard([
                _buildLoanSelector(),
                if (_selectedLoan != null && _schedules.length > 1) ...[
                  const SizedBox(height: 12),
                  _buildScheduleSelector(),
                ],
              ]),

              const SizedBox(height: 24),
              _buildSection('Additional Info'),
              const SizedBox(height: 12),
              _buildCard([
                _buildField(
                  label: 'Remarks (optional)',
                  controller: _remarksCtrl,
                  hint: 'Any additional notes',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text(
                    'Multiple Loan Repayment',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: _multipleLoanRepayment,
                  onChanged: (v) => setState(() => _multipleLoanRepayment = v),
                  contentPadding: EdgeInsets.zero,
                  activeColor: _accentColor,
                ),
                if (_multipleLoanRepayment) ...[
                  const SizedBox(height: 8),
                  _buildField(
                    label: 'Multi-Loan Repayment Amount',
                    controller: _multiLoanAmountCtrl,
                    hint: '0.00',
                    prefix: '₱ ',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (!_multipleLoanRepayment) return null;
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = double.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Must be greater than 0';
                      return null;
                    },
                  ),
                ],
              ]),

              const SizedBox(height: 24),
              _buildSection('Attachments'),
              const SizedBox(height: 12),
              _buildCard([
                ..._attachments.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.image, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.value.name,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeAttachment(e.key),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pickAttachments,
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 20,
                    ),
                    label: Text(
                      _attachments.isEmpty ? 'Add Attachment' : 'Add Another',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ]),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_verifying || _submitting) ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: _verifying || _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanSelector() {
    if (_loadingLoanDetails) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_selectedLoan != null) {
      final s = _selectedSchedule;
      final dueDate = _fmtDate(s?.dueDate);
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _selectedLoan!.displayName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _clearLoan,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Loan ID: ${_selectedLoan!.loanId}  •  ${_selectedLoan!.uniqueNumber ?? ''}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            if (s != null) ...[
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Schedule #${s.id}  •  Due: $dueDate',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (s.status != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        s.status!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (s.repayment != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Amount: ${_fmtAmount(s.repayment)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
            ],
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _pickLoan,
        icon: const Icon(Icons.search, size: 20),
        label: const Text('Search & Select Loan'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
    );
  }

  Widget _buildScheduleSelector() {
    return InkWell(
      onTap: _pickSchedule,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedSchedule != null
                    ? 'Schedule #${_selectedSchedule!.id} — Due: ${_fmtDate(_selectedSchedule!.dueDate)}'
                    : 'Select a schedule (${_schedules.length} available)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _selectedSchedule != null
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: _selectedSchedule != null
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ─── Shared widgets ────────────────────────

  Widget _buildSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Color(0xFF64748B),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? prefix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          onTap: onTap,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _accentColor),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
