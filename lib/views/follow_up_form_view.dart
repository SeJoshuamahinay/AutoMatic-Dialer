import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

class FollowUpFormView extends StatefulWidget {
  final int loanId;
  final int borrowerId;
  final String? borrowerName;

  const FollowUpFormView({
    super.key,
    required this.loanId,
    required this.borrowerId,
    this.borrowerName,
  });

  @override
  State<FollowUpFormView> createState() => _FollowUpFormViewState();
}

class _FollowUpFormViewState extends State<FollowUpFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  List<String> _subjects = [];
  bool _isLoadingSubjects = true;

  // Required fields
  String? _subject;
  String _modeOfContact = 'phone_call';
  String _modeOfPayment = 'cash';
  DateTime? _dateOfContact;
  DateTime? _actionDate;
  String _recoveryLikelihood = 'possible';

  // Optional fields
  final _discussionNotesCtrl = TextEditingController();
  final _followUpActionNotesCtrl = TextEditingController();
  final _amountRecoveredCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  static const List<String> _contactModes = [
    'phone_call',
    'sms',
    'viber',
    'whatsapp',
    'facebook_message',
    'house_visit',
    'email',
    'office_visit',
    'letter',
    'via_relative',
    'via_employer',
  ];

  static const List<String> _paymentModes = [
    'cash',
    'gcash',
    'maya',
    'bank_transfer',
    'check',
    'remittance',
    'palawan_express',
    'cebuana',
    'western_union',
  ];

  static const List<String> _likelihoods = [
    'certain',
    'likely',
    'possible',
    'unlikely',
    'rare_remote',
  ];

  static const String _lafuEndpoint = '/api/lenderly/dialer/lafu';
  static const String _subjectsEndpoint = '/api/lenderly/dialer/lafuSubjects';

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final response = await ApiClient.get(
        _subjectsEndpoint,
        timeout: const Duration(seconds: 15),
      );
      if (!mounted) return;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true && json['data'] is List) {
        final list = (json['data'] as List).map((e) => e.toString()).toList();
        setState(() {
          _subjects = list;
          _isLoadingSubjects = false;
        });
        return;
      }
    } on AuthSessionExpiredException {
      return; // ApiClient already navigated to /login
    } catch (_) {}
    if (mounted) setState(() => _isLoadingSubjects = false);
  }

  @override
  void dispose() {
    _discussionNotesCtrl.dispose();
    _followUpActionNotesCtrl.dispose();
    _amountRecoveredCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isContact) async {
    final initial =
        (isContact ? _dateOfContact : _actionDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isContact) {
        _dateOfContact = picked;
      } else {
        _actionDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_subject == null || _subject!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_dateOfContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date of contact'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_actionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an action date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final session = await SharedPrefsStorageService.getUserSession();

      if (session == null) {
        _showError('User session not found. Please re-login.');
        return;
      }

      final payload = <String, dynamic>{
        'loan_id': widget.loanId,
        'borrower_id': widget.borrowerId,
        'action_person_id': session.userId,
        'subject': _subject,
        'mode_of_contact': _modeOfContact,
        'mode_of_payment': _modeOfPayment,
        'date_of_contact': _formatDate(_dateOfContact!),
        'action_date': _formatDate(_actionDate!),
        'recovery_likelihood': _recoveryLikelihood,
      };

      if (_discussionNotesCtrl.text.trim().isNotEmpty) {
        payload['discussion_notes'] = _discussionNotesCtrl.text.trim();
      }
      if (_followUpActionNotesCtrl.text.trim().isNotEmpty) {
        payload['follow_up_action_notes'] = _followUpActionNotesCtrl.text
            .trim();
      }
      if (_amountRecoveredCtrl.text.trim().isNotEmpty) {
        payload['amount_recovered'] =
            double.tryParse(_amountRecoveredCtrl.text.trim()) ?? 0.0;
      }
      if (_messageCtrl.text.trim().isNotEmpty) {
        payload['message'] = _messageCtrl.text.trim();
      }

      final response = await ApiClient.post(_lafuEndpoint, body: payload);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Follow-up recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true so detail view reloads
      } else {
        String msg = 'Failed to save follow-up (HTTP ${response.statusCode})';
        try {
          final err = jsonDecode(response.body) as Map<String, dynamic>;
          msg = err['message']?.toString() ?? msg;
        } catch (_) {}
        _showError(msg);
      }
    } on AuthSessionExpiredException {
      return; // ApiClient already navigated to /login
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? value,
    required bool isContact,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: isRequired),
        GestureDetector(
          onTap: () => _pickDate(isContact),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.indigo[400]),
                const SizedBox(width: 10),
                Text(
                  value != null ? _formatDate(value) : 'Select date',
                  style: TextStyle(
                    fontSize: 14,
                    color: value != null ? Colors.black87 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required bool isRequired,
    String Function(T)? displayLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: isRequired),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    displayLabel != null ? displayLabel(item) : item.toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Convert snake_case enum value to Title Case for display.
  String _formatEnum(String value) {
    return value
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Widget _textField({
    required String label,
    required TextEditingController ctrl,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: required),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: required
              ? (v) {
                  if (v == null || v.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
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
              'Add Follow-up',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (widget.borrowerName != null)
              Text(
                widget.borrowerName!,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: widget.borrowerName != null ? 65 : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Required Fields ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.indigo),
                      SizedBox(width: 6),
                      Text(
                        'Required Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  // Subject dropdown
                  _fieldLabel('Subject', required: true),
                  _isLoadingSubjects
                      ? const SizedBox(
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: _subject,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: 'Select a subject',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _subjects
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _subject = v),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Subject is required'
                              : null,
                        ),
                  const SizedBox(height: 14),
                  _dropdownField<String>(
                    label: 'Mode of Contact',
                    value: _modeOfContact,
                    items: _contactModes,
                    displayLabel: _formatEnum,
                    onChanged: (v) =>
                        setState(() => _modeOfContact = v ?? _modeOfContact),
                    isRequired: true,
                  ),
                  const SizedBox(height: 14),
                  _datePicker(
                    label: 'Date of Contact',
                    value: _dateOfContact,
                    isContact: true,
                    isRequired: true,
                  ),
                  const SizedBox(height: 14),
                  _datePicker(
                    label: 'Action Date (Next Follow-up)',
                    value: _actionDate,
                    isContact: false,
                    isRequired: true,
                  ),
                  const SizedBox(height: 14),
                  _dropdownField<String>(
                    label: 'Mode of Payment',
                    value: _modeOfPayment,
                    items: _paymentModes,
                    displayLabel: _formatEnum,
                    onChanged: (v) =>
                        setState(() => _modeOfPayment = v ?? _modeOfPayment),
                    isRequired: true,
                  ),
                  const SizedBox(height: 14),
                  _dropdownField<String>(
                    label: 'Recovery Likelihood',
                    value: _recoveryLikelihood,
                    items: _likelihoods,
                    displayLabel: _formatEnum,
                    onChanged: (v) => setState(
                      () => _recoveryLikelihood = v ?? _recoveryLikelihood,
                    ),
                    isRequired: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Optional Fields ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notes, size: 16, color: Colors.teal),
                      SizedBox(width: 6),
                      Text(
                        'Additional Notes (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _textField(
                    label: 'Discussion Notes',
                    ctrl: _discussionNotesCtrl,
                    maxLines: 3,
                    hint: 'What was discussed during the contact?',
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    label: 'Follow-up Action Notes',
                    ctrl: _followUpActionNotesCtrl,
                    maxLines: 3,
                    hint: 'What action was agreed or planned?',
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    label: 'Amount Recovered (₱)',
                    ctrl: _amountRecoveredCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    hint: '0.00',
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    label: 'Message',
                    ctrl: _messageCtrl,
                    maxLines: 2,
                    hint: 'Any additional message',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSubmitting ? 'Saving...' : 'Save Follow-up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
