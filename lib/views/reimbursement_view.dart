import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/app_config.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

class _Category {
  final int id;
  final String name;
  const _Category({required this.id, required this.name});
  factory _Category.fromJson(Map<String, dynamic> json) => _Category(
    id: int.parse(json['id'].toString()),
    name: json['name']?.toString() ?? '',
  );
}

class _ReimbursementItem {
  final int id;
  final double amount;
  final String? categoryName;
  final String? description;
  final String? dateIncurred;
  final String? dateReimbursed;
  final String? dateApproved;
  final String? approver;
  final String? status;

  const _ReimbursementItem({
    required this.id,
    required this.amount,
    this.categoryName,
    this.description,
    this.dateIncurred,
    this.dateReimbursed,
    this.dateApproved,
    this.approver,
    this.status,
  });

  factory _ReimbursementItem.fromJson(Map<String, dynamic> json) {
    return _ReimbursementItem(
      id: int.parse(json['id'].toString()),
      amount: double.parse(json['amount']?.toString() ?? '0'),
      categoryName: json['category_name']?.toString(),
      description: json['description']?.toString(),
      dateIncurred: json['date_incurred']?.toString(),
      dateReimbursed: json['date_reimbursed']?.toString(),
      dateApproved: json['date_approved']?.toString(),
      approver: json['approver']?.toString(),
      status: json['status']?.toString(),
    );
  }

  String get statusLabel => status == null
      ? 'Unknown'
      : '${status![0].toUpperCase()}${status!.substring(1)}';

  Color get statusColor {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

enum AttachmentSource { camera, gallery, files }

class ReimbursementView extends StatefulWidget {
  const ReimbursementView({super.key});
  @override
  State<ReimbursementView> createState() => _ReimbursementViewState();
}

class _ReimbursementViewState extends State<ReimbursementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreateModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _QuickCreateModal(
        onCreated: () {
          Navigator.of(ctx).pop();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reimbursement created.'),
              backgroundColor: Colors.green,
            ),
          );
          _tabController.animateTo(0);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      appBar: AppBar(
        title: const Text(
          'Reimbursements',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0F3D3E),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'My Reimbursements'),
            Tab(text: 'Submit a Request'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _RequestTab(),
          _FormTab(
            onCreated: () {
              _tabController.animateTo(0);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reimbursement submitted.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestTab extends StatefulWidget {
  @override
  State<_RequestTab> createState() => _RequestTabState();
}

class _RequestTabState extends State<_RequestTab> {
  List<_ReimbursementItem> _items = [];
  bool _isLoading = true;
  String? _error;
  int? _employeeId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final profile = await SharedPrefsStorageService.getUserProfile();
    _employeeId = int.tryParse(
      '${profile?['employee_detail']?['employee_id']}',
    );
    if (mounted) _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final employeeId = _employeeId ?? 0;
      final response = await ApiClient.get(
        '/api/reimbursements/get?employee_id=$employeeId',
      );
      print(employeeId);
      print(
        'Reimbursements response: ${response.statusCode} - ${response.body}',
      );
      if (!mounted) return;
      if (response.statusCode != 200) {
        setState(() {
          _error = 'Failed to load (HTTP ${response.statusCode})';
          _isLoading = false;
        });
        return;
      }
      final body = jsonDecode(response.body);
      final List<dynamic> raw;
      if (body is Map<String, dynamic> && body['data'] is List<dynamic>) {
        raw = body['data'] as List<dynamic>;
      } else if (body is List<dynamic>) {
        raw = body;
      } else {
        raw = [];
      }
      setState(() {
        _items = raw
            .map((e) => _ReimbursementItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } on AuthSessionExpiredException {
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'No reimbursement requests yet.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }
    final currencyFmt = NumberFormat('#,##0.00', 'en_PH');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final item = _items[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₱${currencyFmt.format(item.amount)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: item.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.categoryName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.categoryName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.dateIncurred ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FormTab extends StatefulWidget {
  final VoidCallback onCreated;
  const _FormTab({required this.onCreated});
  @override
  State<_FormTab> createState() => _FormTabState();
}

class _FormTabState extends State<_FormTab> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _approverCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  PlatformFile? _attachment;

  int? _employeeId;
  List<_Category> _categories = [];
  bool _isLoadingUser = true;
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  int? _selectedCategoryId;
  DateTime? _dateIncurred;
  DateTime? _dateReimbursed;
  DateTime? _dateApproved;
  final String _status = 'pending';

  static const _statuses = ['pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCategories();
  }

  Future<void> _loadUser() async {
    final profile = await SharedPrefsStorageService.getUserProfile();
    if (!mounted) return;
    setState(() {
      _employeeId = int.tryParse(
        '${profile?['employee_detail']?['employee_id']}',
      );
      _isLoadingUser = false;
    });
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiClient.get('/api/reimbursements/categories');
      if (!mounted) return;
      if (response.statusCode != 200) {
        setState(() => _isLoadingCategories = false);
        return;
      }
      final body = jsonDecode(response.body);
      final List<dynamic> raw;
      if (body is Map<String, dynamic> && body['data'] is List<dynamic>) {
        raw = body['data'] as List<dynamic>;
      } else if (body is List<dynamic>) {
        raw = body;
      } else {
        raw = [];
      }
      setState(() {
        _categories = raw
            .map((e) => _Category.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoadingCategories = false;
      });
    } on AuthSessionExpiredException {
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickDateIncurred() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateIncurred ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dateIncurred = picked);
    }
  }

  Future<void> _pickDateReimbursed() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateReimbursed ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dateReimbursed = picked);
    }
  }

  Future<void> _pickDateApproved() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateApproved ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dateApproved = picked);
    }
  }

  Future<void> _pickAttachment() async {
    final source = await showModalBottomSheet<AttachmentSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, AttachmentSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, AttachmentSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('Files'),
                onTap: () => Navigator.pop(context, AttachmentSource.files),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;

    switch (source) {
      case AttachmentSource.camera:
        final file = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (file != null && mounted) {
          final fileBytes = await File(file.path).readAsBytes();
          setState(() {
            _attachment = PlatformFile(
              name: file.name,
              size: fileBytes.length,
              path: file.path,
            );
          });
        }
        break;
      case AttachmentSource.gallery:
        final file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (file != null && mounted) {
          final fileBytes = await File(file.path).readAsBytes();
          setState(() {
            _attachment = PlatformFile(
              name: file.name,
              size: fileBytes.length,
              path: file.path,
            );
          });
        }
        break;
      case AttachmentSource.files:
        final result = await FilePicker.platform.pickFiles();
        if (result != null && result.files.isNotEmpty && mounted) {
          setState(() => _attachment = result.files.first);
        }
        break;
    }
  }

  void _clearAttachment() {
    setState(() => _attachment = null);
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return 'Select date';
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      _showError('Please select a category.');
      return;
    }
    if (_dateIncurred == null) {
      _showError('Please select date incurred.');
      return;
    }
    if (_employeeId == null) {
      _showError('Employee profile not found. Please log in again.');
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Amount must be greater than 0.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final fields = <String, String>{
        'employee_id': _employeeId.toString(),
        'amount': amount.toString(),
        'category_id': _selectedCategoryId.toString(),
        'date_incurred': _fmtDate(_dateIncurred),
      };

      final desc = _descriptionCtrl.text.trim();
      if (desc.isNotEmpty) fields['description'] = desc;

      if (_dateReimbursed != null) {
        fields['date_reimbursed'] = _fmtDate(_dateReimbursed);
      }
      if (_dateApproved != null) {
        fields['date_approved'] = _fmtDate(_dateApproved);
      }

      final approver = _approverCtrl.text.trim();
      if (approver.isNotEmpty) fields['approver'] = approver;

      final http.Response response;
      if (_attachment != null) {
        final token = await SharedPrefsStorageService.getAuthToken();
        final uri = Uri.parse(
          '${EnvironmentConfig.apiBaseUrl}/api/reimbursements/post',
        );
        final request = http.MultipartRequest('POST', uri)
          ..headers['Accept'] = 'application/json'
          ..headers['X-App-Version'] = AppConfig.version
          ..fields.addAll(fields);

        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        final fileBytes = await File(_attachment!.path!).readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'attachment',
            fileBytes,
            filename: _attachment!.name,
          ),
        );

        final streamResponse = await request.send();
        response = await http.Response.fromStream(streamResponse);
      } else {
        response = await ApiClient.post(
          '/api/reimbursements/post',
          body: Map<String, dynamic>.from(fields),
        );
      }

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        widget.onCreated();
        return;
      }

      String msg = 'Failed to create (HTTP ${response.statusCode})';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        if (err['message'] != null) msg = err['message'].toString();
      } catch (_) {}
      _showError(msg);
    } on AuthSessionExpiredException {
      return;
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

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _approverCtrl.dispose();
    super.dispose();
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _employeeId == null
                  ? 'No employee profile found.'
                  : 'Employee ID: $_employeeId',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          _fieldLabel('Amount', required: true),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: '0.00',
              prefixText: '₱ ',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Amount is required';
              final val = double.tryParse(v.trim());
              if (val == null || val < 0) {
                return 'Amount must be a valid number';
              }
              return null;
            },
          ),
          _fieldLabel('Category', required: true),
          _isLoadingCategories
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
              : DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Select category',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  validator: (v) => v == null ? 'Category is required' : null,
                ),
          _fieldLabel('Description'),
          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Optional description',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          _fieldLabel('Date Incurred', required: true),
          InkWell(
            onTap: _pickDateIncurred,
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _fmtDate(_dateIncurred),
                style: TextStyle(
                  color: _dateIncurred != null ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ),
          _fieldLabel('Attachment'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _attachment == null
                      ? const Text(
                          'No file selected',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Text(
                          _attachment!.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                if (_attachment != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearAttachment,
                  ),
                TextButton.icon(
                  onPressed: _pickAttachment,
                  icon: const Icon(Icons.attach_file, size: 20),
                  label: const Text('Choose'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
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
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit Reimbursement'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCreateModal extends StatefulWidget {
  final VoidCallback onCreated;
  const _QuickCreateModal({required this.onCreated});
  @override
  State<_QuickCreateModal> createState() => _QuickCreateModalState();
}

class _QuickCreateModalState extends State<_QuickCreateModal> {
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  int? _employeeId;
  List<_Category> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  int? _selectedCategoryId;
  DateTime? _dateIncurred;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await SharedPrefsStorageService.getUserProfile();
    if (!mounted) return;
    _employeeId = int.tryParse(
      '${profile?['employee_detail']?['employee_id']}',
    );
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiClient.get('/api/reimbursements/categories');
      if (!mounted) return;
      if (response.statusCode != 200) {
        setState(() => _isLoadingCategories = false);
        return;
      }
      final body = jsonDecode(response.body);
      final List<dynamic> raw;
      if (body is Map<String, dynamic> && body['data'] is List<dynamic>) {
        raw = body['data'] as List<dynamic>;
      } else if (body is List<dynamic>) {
        raw = body;
      } else {
        raw = [];
      }
      setState(() {
        _categories = raw
            .map((e) => _Category.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateIncurred ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dateIncurred = picked);
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_dateIncurred == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date incurred.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee profile not found. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final payload = <String, dynamic>{
        'employee_id': _employeeId,
        'amount': amount,
        'category_id': _selectedCategoryId,
        'date_incurred': fmt.format(_dateIncurred!),
      };

      final desc = _descriptionCtrl.text.trim();
      if (desc.isNotEmpty) payload['description'] = desc;

      final response = await ApiClient.post(
        '/api/reimbursements/post',
        body: payload,
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        widget.onCreated();
        return;
      }

      String msg = 'Failed (HTTP ${response.statusCode})';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        if (err['message'] != null) msg = err['message'].toString();
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
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
            const Text(
              'Quick Reimbursement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _isLoadingCategories
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
                : DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date Incurred',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _dateIncurred != null
                      ? DateFormat('yyyy-MM-dd').format(_dateIncurred!)
                      : 'Select date',
                  style: TextStyle(
                    color: _dateIncurred != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
