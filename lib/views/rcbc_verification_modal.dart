import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/views/rcbc_posting_request_form.dart';

class RcbcVerificationModal extends StatefulWidget {
  final VoidCallback? onVerified;

  const RcbcVerificationModal({super.key, this.onVerified});

  static Future<void> show(BuildContext context, {VoidCallback? onVerified}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RcbcVerificationModal(onVerified: onVerified),
    );
  }

  @override
  State<RcbcVerificationModal> createState() => _RcbcVerificationModalState();
}

enum _Stage { form, loading, success, error }

class _RcbcVerificationModalState extends State<RcbcVerificationModal> {
  final _referenceCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _currencyFmt = NumberFormat('#,##0.00', 'en_PH');

  _Stage _stage = _Stage.form;
  Map<String, dynamic>? _result;
  String? _errorMessage;
  String? _errorType;

  @override
  void dispose() {
    _referenceCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reference = _referenceCtrl.text.trim();
    final amount = _amountCtrl.text.trim();

    if (reference.isEmpty) {
      _showError('Please enter the last 6 digits of the reference number.');
      return;
    }
    if (reference.length != 6) {
      _showError('Reference number must be exactly 6 digits.');
      return;
    }
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      _showError('Please enter a valid amount.');
      return;
    }

    setState(() => _stage = _Stage.loading);

    try {
      final response = await ApiClient.post(
        '/api/rcbc-payment-verifications/verify-reference',
        body: {'reference_number': reference, 'amount': parsedAmount},
      );

      if (!mounted) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      print('RCBC Verification Response: $body');
      if (body['success'] == true) {
        setState(() {
          _result = body['transaction'] as Map<String, dynamic>?;
          _stage = _Stage.success;
        });
      } else {
        setState(() {
          _errorMessage = body['message']?.toString() ?? 'Verification failed.';
          _errorType = body['error_type']?.toString();
          _stage = _Stage.error;
        });
      }
    } on AuthSessionExpiredException {
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _stage = _Stage.error;
      });
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _reset() {
    setState(() {
      _stage = _Stage.form;
      _result = null;
      _errorMessage = null;
      _errorType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Verify RCBC Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (_stage != _Stage.form)
                  TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('New'),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter the last 6 digits of the reference number and the payment amount.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            if (_stage == _Stage.form || _stage == _Stage.loading)
              ..._buildForm(),
            if (_stage == _Stage.success) ..._buildSuccess(),
            if (_stage == _Stage.error) ..._buildError(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildForm() {
    return [
      TextField(
        controller: _referenceCtrl,
        maxLength: 6,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Last 6 digits of Reference No.',
          hintText: '000000',
          border: OutlineInputBorder(),
          counterText: '',
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _amountCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Payment Amount',
          prefixText: '₱ ',
          hintText: '0.00',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _stage == _Stage.loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3D3E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: _stage == _Stage.loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Verify Payment'),
        ),
      ),
    ];
  }

  List<Widget> _buildSuccess() {
    final tx = _result;
    if (tx == null) return [];

    final postings = tx['postings'] as List<dynamic>? ?? [];

    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reference number and payment amount verified successfully.',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Transaction Details',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      _detailCard([
        _row('Transaction ID', tx['transaction_id']?.toString() ?? '-'),
        _row('Posting Date', tx['posting_date']?.toString() ?? '-'),
        _row(
          'Credit',
          '₱ ${_currencyFmt.format(double.tryParse(tx['credit']?.toString() ?? '0') ?? 0)}',
        ),
        _row('Payment Order', tx['payment_order']?.toString() ?? '-'),
        _row('Particulars', tx['transaction_particulars']?.toString() ?? '-'),
        _row('Remarks', tx['remarks']?.toString() ?? '-'),
      ]),
      if (postings.isNotEmpty) ...[
        const SizedBox(height: 16),
        const Text(
          'Postings',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...postings.map((p) => _postingCard(p as Map<String, dynamic>)),
      ],
      const SizedBox(height: 20),
      if (postings.isEmpty) ...[
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              final reference = _referenceCtrl.text.trim();
              final amount = double.tryParse(_amountCtrl.text.trim());
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute(
                  builder: (_) => RcbcPostingRequestForm(
                    initialReference: reference,
                    initialAmount: amount,
                    initialPostingDate: tx['posting_date']?.toString(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Request Posting'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F3D3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            widget.onVerified?.call();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3D3E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Close'),
        ),
      ),
    ];
  }

  List<Widget> _buildError() {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _errorMessage ?? 'Verification failed.',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (_errorType != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Error: $_errorType',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _reset,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3D3E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Try Again'),
        ),
      ),
    ];
  }

  Widget _detailCard(List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _postingCard(Map<String, dynamic> p) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p['borrower']?.toString() ?? 'Unknown',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          _row('Unique No.', p['unique_number']?.toString() ?? '-'),
          _row('Ref. No.', p['reference_number']?.toString() ?? '-'),
          _row(
            'Amount',
            '₱ ${_currencyFmt.format(double.tryParse(p['amount']?.toString() ?? '0') ?? 0)}',
          ),
          _statusRow(p['status']?.toString() ?? '-'),
          if (p['submitted_by'] != null)
            _row('Submitted By', p['submitted_by'].toString()),
        ],
      ),
    );
  }

  Widget _statusRow(String status) {
    final normalized = status.toLowerCase();
    Color bgColor;
    Color textColor;
    IconData? icon;

    if (normalized == 'posted') {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      icon = Icons.check_circle;
    } else if (normalized == 'pending') {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.schedule;
    } else {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      icon = Icons.cancel;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Status',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: textColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
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
