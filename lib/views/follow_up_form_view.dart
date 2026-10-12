import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

/// LAFU (loan follow-up) form, restructured flow:
/// attempt → result → (contacted) PTP or not → amount → dates → proof.
///
/// Mirrors Symphony's web LAFU form; the server validates the same rules
/// (LafuEntryService), so choice lists come from `/lafuOptions` rather than
/// being hard-coded here.
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

/// A choice from `/lafuOptions` (value sent to the API, label shown).
class _Option {
  final String value;
  final String label;
  const _Option(this.value, this.label);

  static List<_Option> listFrom(dynamic json) => (json as List? ?? [])
      .map((e) => _Option(e['value'].toString(), e['label'].toString()))
      .toList();
}

class _FollowUpFormViewState extends State<FollowUpFormView> {
  static const String _lafuEndpoint = '/api/lenderly/dialer/lafu';
  static const String _optionsEndpoint = '/api/lenderly/dialer/lafuOptions';
  static const int _maxFileBytes = 10 * 1024 * 1024;

  /// A PTP promise date is today up to this many days ahead.
  /// Mirrors LafuEntryService::PTP_MAX_DAYS on the server.
  static const int _ptpMaxDays = 2;
  static final RegExp _decimalRegExp = RegExp(r'^\d*\.?\d{0,2}');
  static const MaterialColor _brand = Colors.indigo;

  bool _isLoadingOptions = true;
  String? _optionsError;
  bool _isSubmitting = false;

  // Options from the server
  List<_Option> _modesOfContact = [];
  List<_Option> _ptpTypes = [];
  List<_Option> _amountTypes = [];
  List<_Option> _modesOfPayment = [];
  List<String> _contactedSubjects = [];
  List<String> _notContactedSubjects = [];
  double? _previewOutstanding;
  double? _previewPerDue;
  String? _previewPerDueDate;

  // Form state
  DateTime _dateOfContact = DateTime.now();
  DateTime _actionDate = DateTime.now();
  String? _modeOfContact;
  String? _attemptResult; // contacted | not_contacted
  bool? _isPtp;
  String? _ptpType;
  String? _subject;
  String? _amountType;
  String? _modeOfPayment;
  final _rfdCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final List<XFile> _attachments = [];
  final ImagePicker _imagePicker = ImagePicker();

  /// field → first validation message (local check or server 422)
  Map<String, String> _errors = {};

  bool get _contacted => _attemptResult == 'contacted';
  bool get _ptp => _contacted && _isPtp == true;
  bool get _needsSubject =>
      _attemptResult != null && (!_contacted || _isPtp == false);
  bool get _typedAmount => _amountType == 'partial' || _amountType == 'other';

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _rfdCtrl.dispose();
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _loadOptions() async {
    setState(() {
      _isLoadingOptions = true;
      _optionsError = null;
    });
    try {
      final response = await ApiClient.get(
        '$_optionsEndpoint?loan_id=${widget.loanId}',
        timeout: const Duration(seconds: 15),
      );
      if (!mounted) return;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true && json['data'] is Map) {
        final data = json['data'] as Map<String, dynamic>;
        final subjects = data['subjects'] as Map<String, dynamic>? ?? {};
        final preview = data['amount_preview'] as Map<String, dynamic>?;
        setState(() {
          _modesOfContact = _Option.listFrom(data['modes_of_contact']);
          _ptpTypes = _Option.listFrom(data['ptp_types']);
          _amountTypes = _Option.listFrom(data['amount_types']);
          _modesOfPayment = _Option.listFrom(data['modes_of_payment']);
          _contactedSubjects = List<String>.from(subjects['contacted'] ?? []);
          _notContactedSubjects =
              List<String>.from(subjects['not_contacted'] ?? []);
          _previewOutstanding =
              (preview?['full_outstanding'] as num?)?.toDouble();
          _previewPerDue = (preview?['per_due'] as num?)?.toDouble();
          _previewPerDueDate = preview?['per_due_date']?.toString();
          _isLoadingOptions = false;
        });
        return;
      }
      setState(() {
        _optionsError =
            json['message']?.toString() ?? 'Could not load the form.';
        _isLoadingOptions = false;
      });
    } on AuthSessionExpiredException {
      return; // ApiClient already navigated to /login
    } catch (_) {
      if (mounted) {
        setState(() {
          _optionsError = 'Could not load the form. Check your connection.';
          _isLoadingOptions = false;
        });
      }
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _money(double? v) {
    if (v == null) return '—';
    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
    return '₱$whole.${parts[1]}';
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime get _ptpFirst => _today;
  DateTime get _ptpLast => _today.add(const Duration(days: _ptpMaxDays));

  /// Keeps the promise date inside the PTP window whenever PTP is chosen.
  void _clampPromiseDate() {
    if (!_ptp) return;
    if (_actionDate.isBefore(_ptpFirst) || _actionDate.isAfter(_ptpLast)) {
      _actionDate = _ptpFirst;
    }
  }

  Future<void> _pickDate({required bool isContact}) async {
    final promise = !isContact && _ptp;
    final picked = await showDatePicker(
      context: context,
      initialDate: isContact ? _dateOfContact : _actionDate,
      firstDate: promise ? _ptpFirst : DateTime(2020),
      lastDate: promise ? _ptpLast : DateTime(2100),
      helpText: promise ? 'Promise date (today up to $_ptpMaxDays days)' : null,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isContact) {
        _dateOfContact = picked;
      } else {
        _actionDate = picked;
      }
      _errors.remove(isContact ? 'date_of_contact' : 'action_date');
    });
  }

  Future<void> _addAttachments() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(ctx).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose Photos'),
              onTap: () => Navigator.of(ctx).pop('gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Choose PDF'),
              onTap: () => Navigator.of(ctx).pop('pdf'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;

    final picked = <XFile>[];
    if (choice == 'camera') {
      final f = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (f != null) picked.add(f);
    } else if (choice == 'gallery') {
      picked.addAll(await _imagePicker.pickMultiImage(imageQuality: 85));
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true,
      );
      for (final f in result?.files ?? <PlatformFile>[]) {
        if (f.bytes != null) {
          picked.add(XFile.fromData(
            f.bytes!,
            name: f.name,
            mimeType: 'application/pdf',
          ));
        } else if (f.path != null) {
          picked.add(XFile(f.path!, name: f.name));
        }
      }
    }

    final skipped = <String>[];
    for (final f in picked) {
      if (await f.length() > _maxFileBytes) {
        skipped.add(f.name);
      } else {
        _attachments.add(f);
      }
    }
    if (!mounted) return;
    setState(() => _errors.remove('attachments'));
    if (skipped.isNotEmpty) {
      _showSnack('Skipped (over 10 MB): ${skipped.join(', ')}', error: true);
    }
  }

  /// Client-side check of the same rules the server enforces, so the agent
  /// sees every missing field at once instead of one round trip each.
  Map<String, String> _localErrors() {
    final e = <String, String>{};
    if (_modeOfContact == null) {
      e['mode_of_contact'] = 'Choose the attempt type.';
    }
    if (_attemptResult == null) {
      e['attempt_result'] = 'Choose the attempt result.';
    }
    if (_contacted && _isPtp == null) e['is_ptp'] = 'Tag it PTP or Non-PTP.';
    if (_ptp && _ptpType == null) e['ptp_type'] = 'Choose the PTP type.';
    if (_needsSubject && (_subject == null || _subject!.isEmpty)) {
      e['subject'] = 'Pick a subject.';
    }
    if (_contacted && _rfdCtrl.text.trim().isEmpty) {
      e['reason_for_delay'] = 'Enter the reason for delay.';
    }
    if (_attemptResult != null && _amountType == null) {
      e['amount_type'] = 'Choose the amount.';
    }
    if (_typedAmount && (double.tryParse(_amountCtrl.text.trim()) ?? 0) <= 0) {
      e['amount_recovered'] = 'Enter an amount above zero.';
    }
    if (_ptp && _modeOfPayment == null) {
      e['mode_of_payment'] = 'Choose the payment method.';
    }
    if (_attemptResult != null && _attachments.isEmpty) {
      e['attachments'] = 'Attach at least one photo or PDF.';
    }
    return e;
  }

  Future<void> _submit() async {
    final local = _localErrors();
    if (local.isNotEmpty) {
      setState(() => _errors = local);
      _showSnack('Please complete the highlighted fields.', error: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errors = {};
    });

    try {
      final session = await SharedPrefsStorageService.getUserSession();
      if (session == null) {
        _showSnack('User session not found. Please re-login.', error: true);
        return;
      }

      final fields = <String, String>{
        'loan_id': widget.loanId.toString(),
        'borrower_id': widget.borrowerId.toString(),
        'action_person_id': session.userId.toString(),
        'date_of_contact': _formatDate(_dateOfContact),
        'mode_of_contact': _modeOfContact!,
        'attempt_result': _attemptResult!,
        'amount_type': _amountType!,
        'action_date': _formatDate(_actionDate),
      };
      if (_contacted) {
        fields['is_ptp'] = _isPtp == true ? '1' : '0';
        fields['reason_for_delay'] = _rfdCtrl.text.trim();
      }
      if (_ptp) {
        fields['ptp_type'] = _ptpType!;
        fields['mode_of_payment'] = _modeOfPayment!;
      }
      if (_needsSubject) fields['subject'] = _subject!;
      if (_typedAmount) fields['amount_recovered'] = _amountCtrl.text.trim();
      if (_remarksCtrl.text.trim().isNotEmpty) {
        fields['discussion_notes'] = _remarksCtrl.text.trim();
      }

      final files = <http.MultipartFile>[];
      for (final f in _attachments) {
        files.add(http.MultipartFile.fromBytes(
          'attachments[]',
          await f.readAsBytes(),
          filename: f.name,
        ));
      }

      final response = await ApiClient.postMultipart(
        _lafuEndpoint,
        fields: fields,
        files: files,
      );
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack('Follow-up recorded successfully!');
        Navigator.pop(context, true); // Return true so detail view reloads
        return;
      }

      String msg = 'Failed to save follow-up (HTTP ${response.statusCode})';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        msg = err['message']?.toString() ?? msg;
        final serverErrors = err['errors'];
        if (serverErrors is Map) {
          setState(() {
            _errors = serverErrors.map((k, v) => MapEntry(
                  k.toString().split('.').first,
                  (v is List && v.isNotEmpty)
                      ? v.first.toString()
                      : v.toString(),
                ));
          });
        }
      } catch (_) {}
      _showSnack(msg, error: true);
    } on AuthSessionExpiredException {
      return; // ApiClient already navigated to /login
    } catch (e) {
      if (mounted) _showSnack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _section({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: required
            ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
            : [],
      )),
    );
  }

  Widget _error(String field) {
    final msg = _errors[field];
    if (msg == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        msg,
        style: const TextStyle(color: Colors.red, fontSize: 11.5),
      ),
    );
  }

  /// A single-choice row of chips.
  Widget _choices({
    required String field,
    required List<_Option> options,
    required String? value,
    required ValueChanged<String> onSelected,
    Map<String, IconData> icons = const {},
    Color color = _brand,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final selected = o.value == value;
            return ChoiceChip(
              avatar: icons[o.value] != null
                  ? Icon(
                      icons[o.value],
                      size: 16,
                      color: selected ? Colors.white : color,
                    )
                  : null,
              label: Text(o.label),
              selected: selected,
              showCheckmark: false,
              selectedColor: color,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? color : Colors.grey.shade300,
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
              onSelected: (_) => setState(() {
                onSelected(o.value);
                _errors.remove(field);
              }),
            );
          }).toList(),
        ),
        _error(field),
      ],
    );
  }

  InputDecoration _input({String? hint, String? field}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: field != null && _errors[field] != null
                ? Colors.red
                : Colors.grey.shade300,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFBFD),
      );

  Widget _dateField({
    required String label,
    required DateTime value,
    required bool isContact,
    required String field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _pickDate(isContact: isContact),
          child: InputDecorator(
            decoration: _input(field: field),
            child: Row(children: [
              Icon(Icons.event_outlined, size: 18, color: _brand.shade400),
              const SizedBox(width: 8),
              Text(_formatDate(value), style: const TextStyle(fontSize: 14)),
            ]),
          ),
        ),
        _error(field),
      ],
    );
  }

  Widget _subjectField() {
    final subjects = _contacted ? _contactedSubjects : _notContactedSubjects;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('LAFU Subject'),
        DropdownButtonFormField<String>(
          key: ValueKey(_attemptResult), // reset when the branch changes
          value: subjects.contains(_subject) ? _subject : null,
          isExpanded: true,
          decoration: _input(hint: 'Select a subject', field: 'subject'),
          items: subjects
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() {
            _subject = v;
            _errors.remove('subject');
          }),
        ),
        _error('subject'),
      ],
    );
  }

  String? _amountPreview() {
    if (_amountType == 'full_outstanding') {
      return 'Outstanding: ${_money(_previewOutstanding)}';
    }
    if (_amountType == 'per_due') {
      return _previewPerDue == null
          ? 'Nothing due on this loan — choose Partial or Others.'
          : 'Due $_previewPerDueDate: ${_money(_previewPerDue)}';
    }
    return null;
  }

  Widget _attachmentsField() {
    final hasError = _errors['attachments'] != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Attachments'),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _addAttachments,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _brand.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? Colors.red : _brand.withValues(alpha: 0.35),
              ),
            ),
            child: Column(children: [
              Icon(Icons.cloud_upload_outlined,
                  color: _brand.shade400, size: 26),
              const SizedBox(height: 4),
              const Text(
                'Add photo or PDF',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                'At least one · up to 10 MB each',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ]),
          ),
        ),
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_attachments.length, (i) {
              final f = _attachments[i];
              final isPdf = f.name.toLowerCase().endsWith('.pdf');
              return InputChip(
                avatar: Icon(
                  isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                  size: 16,
                  color: isPdf ? Colors.red : _brand,
                ),
                label: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    f.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                onDeleted: () => setState(() => _attachments.removeAt(i)),
              );
            }),
          ),
        ],
        _error('attachments'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = !_isLoadingOptions && _optionsError == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      resizeToAvoidBottomInset: true,
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
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: widget.borrowerName != null ? 65 : null,
      ),
      body: _isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : _optionsError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_optionsError!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _loadOptions,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ]),
                  ),
                )
              : _buildForm(),
      bottomNavigationBar: !ready
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
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
                    backgroundColor: _brand,
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
            ),
    );
  }

  Widget _buildForm() {
    final preview = _amountPreview();

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // ── Attempt ────────────────────────────────────────────────────────
        _section(
          icon: Icons.phone_in_talk_outlined,
          title: 'Attempt',
          color: _brand,
          children: [
            _dateField(
              label: 'LAFU Date',
              value: _dateOfContact,
              isContact: true,
              field: 'date_of_contact',
            ),
            const SizedBox(height: 14),
            _label('Attempt Type'),
            _choices(
              field: 'mode_of_contact',
              options: _modesOfContact,
              value: _modeOfContact,
              icons: const {
                'phone_call': Icons.call_outlined,
                'message': Icons.sms_outlined,
                'email': Icons.email_outlined,
                'house_visit': Icons.home_outlined,
              },
              onSelected: (v) => _modeOfContact = v,
            ),
            const SizedBox(height: 14),
            _label('Attempt Result'),
            _choices(
              field: 'attempt_result',
              options: const [
                _Option('contacted', 'Contacted'),
                _Option('not_contacted', 'Not Contacted'),
              ],
              value: _attemptResult,
              icons: const {
                'contacted': Icons.how_to_reg_outlined,
                'not_contacted': Icons.person_off_outlined,
              },
              color: _attemptResult == 'not_contacted'
                  ? Colors.red
                  : Colors.green,
              onSelected: (v) {
                _attemptResult = v;
                _subject = null;
                _clampPromiseDate();
              },
            ),
          ],
        ),

        // ── Outcome ────────────────────────────────────────────────────────
        if (_attemptResult != null)
          _section(
            icon: Icons.sell_outlined,
            title: 'Outcome',
            color: Colors.deepPurple,
            children: [
              if (_contacted) ...[
                _label('Tagging'),
                _choices(
                  field: 'is_ptp',
                  options: const [
                    _Option('1', 'PTP'),
                    _Option('0', 'Non-PTP'),
                  ],
                  value: _isPtp == null ? null : (_isPtp! ? '1' : '0'),
                  icons: const {
                    '1': Icons.handshake_outlined,
                    '0': Icons.chat_bubble_outline,
                  },
                  color: Colors.deepPurple,
                  onSelected: (v) {
                    _isPtp = v == '1';
                    _clampPromiseDate();
                  },
                ),
                const SizedBox(height: 14),
              ],
              if (_ptp) ...[
                _label('PTP Type'),
                _choices(
                  field: 'ptp_type',
                  options: _ptpTypes,
                  value: _ptpType,
                  color: Colors.deepPurple,
                  onSelected: (v) => _ptpType = v,
                ),
                const SizedBox(height: 14),
              ],
              if (_needsSubject) ...[
                _subjectField(),
                if (_contacted) const SizedBox(height: 14),
              ],
              if (_contacted) ...[
                _label('Reason for Delay (RFD)'),
                TextField(
                  controller: _rfdCtrl,
                  maxLines: 2,
                  scrollPadding: const EdgeInsets.only(bottom: 120),
                  decoration: _input(
                    hint: 'Why the borrower has not paid yet…',
                    field: 'reason_for_delay',
                  ),
                  onChanged: (_) {
                    if (_errors.containsKey('reason_for_delay')) {
                      setState(() => _errors.remove('reason_for_delay'));
                    }
                  },
                ),
                _error('reason_for_delay'),
              ],
            ],
          ),

        // ── Amount & dates ─────────────────────────────────────────────────
        if (_attemptResult != null)
          _section(
            icon: Icons.payments_outlined,
            title: 'Amount',
            color: Colors.teal,
            children: [
              _label('Amount'),
              _choices(
                field: 'amount_type',
                options: _amountTypes,
                value: _amountType,
                color: Colors.teal,
                onSelected: (v) => _amountType = v,
              ),
              if (preview != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    preview,
                    style: TextStyle(
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
              if (_typedAmount) ...[
                const SizedBox(height: 14),
                _label('Enter Amount (₱)'),
                TextField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(_decimalRegExp),
                  ],
                  scrollPadding: const EdgeInsets.only(bottom: 120),
                  decoration: _input(hint: '0.00', field: 'amount_recovered'),
                  onChanged: (_) {
                    if (_errors.containsKey('amount_recovered')) {
                      setState(() => _errors.remove('amount_recovered'));
                    }
                  },
                ),
                _error('amount_recovered'),
              ],
              if (_ptp) ...[
                const SizedBox(height: 14),
                _label('Payment Method'),
                DropdownButtonFormField<String>(
                  value: _modeOfPayment,
                  isExpanded: true,
                  decoration: _input(
                    hint: 'Select payment method',
                    field: 'mode_of_payment',
                  ),
                  items: _modesOfPayment
                      .map((o) => DropdownMenuItem(
                            value: o.value,
                            child: Text(
                              o.label,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _modeOfPayment = v;
                    _errors.remove('mode_of_payment');
                  }),
                ),
                _error('mode_of_payment'),
              ],
              const SizedBox(height: 14),
              _dateField(
                label: _ptp ? 'Promise Date' : 'Next Follow-up Date',
                value: _actionDate,
                isContact: false,
                field: 'action_date',
              ),
            ],
          ),

        // ── Proof & remarks ────────────────────────────────────────────────
        if (_attemptResult != null)
          _section(
            icon: Icons.attach_file,
            title: 'Proof & Remarks',
            color: Colors.blueGrey,
            children: [
              _attachmentsField(),
              const SizedBox(height: 14),
              _label('Remarks', required: false),
              TextField(
                controller: _remarksCtrl,
                maxLines: 4,
                scrollPadding: const EdgeInsets.only(bottom: 120),
                decoration: _input(
                  hint: 'Anything else worth recording about this attempt…',
                ),
              ),
            ],
          ),
      ],
    );
  }
}
