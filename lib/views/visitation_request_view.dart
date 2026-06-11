import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/app_config.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

class _BorrowerSearchItem {
  final int loanId;
  final int? borrowerId;
  final String? fullName;

  const _BorrowerSearchItem({
    required this.loanId,
    required this.borrowerId,
    required this.fullName,
  });

  factory _BorrowerSearchItem.fromJson(Map<String, dynamic> json) {
    return _BorrowerSearchItem(
      loanId: (json['loan_id'] as num).toInt(),
      borrowerId: (json['borrower_id'] as num?)?.toInt(),
      fullName: json['full_name']?.toString(),
    );
  }

  String get displayName =>
      fullName?.trim().isNotEmpty == true ? fullName!.trim() : 'Unknown';
}

class _CountryOption {
  final int id;
  final String name;

  const _CountryOption({required this.id, required this.name});

  factory _CountryOption.fromJson(Map<String, dynamic> json) {
    return _CountryOption(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString().trim(),
    );
  }
}

class VisitationRequestView extends StatefulWidget {
  final int? borrowerId;
  final String? borrowerName;

  const VisitationRequestView({super.key, this.borrowerId, this.borrowerName});

  @override
  State<VisitationRequestView> createState() => _VisitationRequestViewState();
}

class _VisitationRequestViewState extends State<VisitationRequestView> {
  static const List<String> _types = <String>[
    'DL Delivery',
    'Credit Investigation',
    'House Visitation',
    'Reminder Visit',
    'Borrower Tracing',
  ];

  static const List<String> _approvalReasons = <String>[
    'Long-term resident',
    'Known by community',
    'Ownership verified',
    'Rental verified',
    'Utility bill explained',
    'Barangay verified',
    'Guard / HOA verified',
    'Other',
  ];

  static const List<String> _declineReasons = <String>[
    'Address mismatch',
    'Vacant property',
    'Unknown borrower',
    'Ownership issue',
    'Co-maker issue',
    'Utility bill mismatch',
    'Squatter area',
    'Fraud suspected',
    'Short-term tenant',
    'Other',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _borrowerIdCtrl = TextEditingController();
  final TextEditingController _longitudeCtrl = TextEditingController();
  final TextEditingController _latitudeCtrl = TextEditingController();
  final TextEditingController _regionCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _brgyCtrl = TextEditingController();
  final TextEditingController _houseNumberCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  int? _userId;
  String? _selectedType;
  String? _selectedBorrowerName;
  int? _selectedLoanId;
  int? _selectedCountryId;
  bool? _verificationResult;
  String? _selectedPrimaryReason;
  bool _fraudFlag = false;
  XFile? _attachment;
  bool _showAttachmentError = false;
  List<_CountryOption> _countries = const <_CountryOption>[];
  DateTime _visitedAt = DateTime.now();
  bool _isLoadingUser = true;
  bool _isSubmitting = false;
  bool _isLocating = false;
  bool _isPrefillingAddress = false;
  bool _isLoadingCountries = false;

  static const String _searchEndpoint = '/api/lenderly/dialer/data/search';
  static const String _detailEndpoint = '/api/lenderly/dialer/get-loan-details';
  static const String _countriesEndpoint = '/api/lenderly/dialer/countries';
  static const int _defaultCountryId = 168;

  @override
  void initState() {
    super.initState();
    if (widget.borrowerId != null) {
      _borrowerIdCtrl.text = widget.borrowerId.toString();
      _selectedBorrowerName = widget.borrowerName;
    }
    _loadUser();
    _loadCountries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoLocateOnOpen();
    });
  }

  Future<void> _autoLocateOnOpen() async {
    await _getCurrentLocation(silent: false);
  }

  Future<void> _loadCountries() async {
    setState(() => _isLoadingCountries = true);
    try {
      final response = await ApiClient.get(_countriesEndpoint);
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load countries (HTTP ${response.statusCode})',
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>? ?? <dynamic>[];
      final countries = data
          .map((e) => _CountryOption.fromJson(e as Map<String, dynamic>))
          .where((e) => e.name.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _countries = countries;
        _selectedCountryId =
            countries
                .where((e) => e.id == _defaultCountryId)
                .cast<_CountryOption?>()
                .firstOrNull
                ?.id ??
            countries.firstOrNull?.id;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _countries = const <_CountryOption>[];
        _selectedCountryId = _defaultCountryId;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingCountries = false);
      }
    }
  }

  _CountryOption? _countryById(int? id) {
    if (id == null) return null;
    for (final country in _countries) {
      if (country.id == id) return country;
    }
    return null;
  }

  Future<List<_BorrowerSearchItem>> _searchBorrowers(String query) async {
    final endpoint =
        '$_searchEndpoint?q=${Uri.encodeQueryComponent(query.trim())}';
    final response = await ApiClient.get(endpoint);
    if (response.statusCode != 200) {
      throw Exception('Search failed (HTTP ${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? <dynamic>[];
    return results
        .map((e) => _BorrowerSearchItem.fromJson(e as Map<String, dynamic>))
        .where((e) => e.borrowerId != null)
        .toList();
  }

  Future<void> _prefillAddressFromLoan(int loanId) async {
    setState(() => _isPrefillingAddress = true);
    try {
      final response = await ApiClient.get('$_detailEndpoint/$loanId');
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load loan detail (HTTP ${response.statusCode})',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      final loan = data?['loan'] as Map<String, dynamic>?;
      if (loan == null) {
        _showSnack(
          'Loan detail not found for selected borrower.',
          isError: true,
        );
        return;
      }

      final region = (loan['borrower_region'] ?? loan['region'] ?? '')
          .toString()
          .trim();
      final city = (loan['borrower_city'] ?? loan['city'] ?? '')
          .toString()
          .trim();
      final brgy =
          (loan['borrower_village'] ?? loan['village'] ?? loan['brgy'] ?? '')
              .toString()
              .trim();
      final house =
          (loan['borrower_house_number'] ?? loan['house_number'] ?? '')
              .toString()
              .trim();
      final country =
          (loan['borrower_country'] ??
                  loan['country'] ??
                  loan['country_name'] ??
                  '')
              .toString()
              .trim();

      if (!mounted) return;
      setState(() {
        if (country.isNotEmpty) {
          final matched = _countries
              .where((c) => c.name.toLowerCase() == country.toLowerCase())
              .cast<_CountryOption?>()
              .firstOrNull;
          if (matched != null) {
            _selectedCountryId = matched.id;
          }
        }
        _regionCtrl.text = region;
        _cityCtrl.text = city;
        _brgyCtrl.text = brgy;
        _houseNumberCtrl.text = house;
      });
    } catch (e) {
      _showSnack('Failed to prefill address: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isPrefillingAddress = false);
      }
    }
  }

  Future<void> _pickBorrower() async {
    final picked = await showDialog<_BorrowerSearchItem>(
      context: context,
      builder: (dialogContext) {
        String query = '';
        Timer? debounce;
        bool isLoading = false;
        String? error;
        List<_BorrowerSearchItem> results = const <_BorrowerSearchItem>[];

        Future<void> runSearch(StateSetter setDialogState) async {
          final q = query.trim();
          if (q.length < 2) {
            setDialogState(() {
              results = const <_BorrowerSearchItem>[];
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
            final found = await _searchBorrowers(q);
            setDialogState(() {
              results = found;
              isLoading = false;
            });
          } catch (e) {
            setDialogState(() {
              results = const <_BorrowerSearchItem>[];
              error = e.toString();
              isLoading = false;
            });
          }
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final screenSize = MediaQuery.of(context).size;
            return AlertDialog(
              title: const Text('Select Borrower'),
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
                        hintText: 'Search by borrower name',
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
                              child: Text('No borrowers found.'),
                            );
                          }
                          return ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (_, i) {
                              final item = results[i];
                              return ListTile(
                                title: Text(item.displayName),
                                subtitle: Text(
                                  'Borrower ID: ${item.borrowerId}  •  Loan ID: ${item.loanId}',
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
      _borrowerIdCtrl.text = picked.borrowerId.toString();
      _selectedBorrowerName = picked.displayName;
      _selectedLoanId = picked.loanId;
    });

    await _prefillAddressFromLoan(picked.loanId);
  }

  @override
  void dispose() {
    _borrowerIdCtrl.dispose();
    _longitudeCtrl.dispose();
    _latitudeCtrl.dispose();
    _regionCtrl.dispose();
    _cityCtrl.dispose();
    _brgyCtrl.dispose();
    _houseNumberCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  List<String> get _primaryReasons {
    if (_verificationResult == true) return _approvalReasons;
    if (_verificationResult == false) return _declineReasons;
    return const <String>[];
  }

  String get _verificationLabel {
    if (_verificationResult == true) return 'Approved';
    if (_verificationResult == false) return 'Declined';
    return 'Pending';
  }

  Future<void> _pickAttachment() async {
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
    if (source == null || !mounted) return;
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (!mounted || file == null) return;
      setState(() {
        _attachment = file;
        _showAttachmentError = false;
      });
    } catch (e) {
      _showSnack('Attachment capture failed: $e', isError: true);
    }
  }

  String _extractApiMessage(String? bodyText, int statusCode, String fallback) {
    if (bodyText == null || bodyText.isEmpty) {
      return '$fallback (HTTP $statusCode)';
    }
    try {
      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final errors = body['errors'];
      if (errors is Map<String, dynamic>) {
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            final first = value.first?.toString();
            if (first != null && first.trim().isNotEmpty) return first;
          }
          if (value is String && value.trim().isNotEmpty) return value;
        }
      }
      final msg = body['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg;
    } catch (_) {}
    return '$fallback (HTTP $statusCode)';
  }

  Future<http.Response> _postVisitationMultipart(
    Map<String, String> fields,
  ) async {
    final token = await SharedPrefsStorageService.getAuthToken();
    final uri = Uri.parse(
      '${EnvironmentConfig.apiBaseUrl}/api/visitation-requests',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['X-App-Version'] = AppConfig.version
      ..fields.addAll(fields);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (_attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath('attachment', _attachment!.path),
      );
    }

    final response = await request.send();
    return http.Response.fromStream(response);
  }

  Future<void> _loadUser() async {
    final session = await SharedPrefsStorageService.getUserSession();
    if (!mounted) return;
    setState(() {
      _userId = session?.userId;
      _isLoadingUser = false;
    });
  }

  Future<void> _pickVisitedAt() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _visitedAt,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_visitedAt),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _visitedAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<Position?> _getCurrentLocation({bool silent = false}) async {
    setState(() => _isLocating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!silent) {
          _showSnack('Location service is off.', isError: true);
        }
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!silent) {
          _showSnack('Location permission needed.', isError: true);
        }
        return null;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 12),
        );
      } on TimeoutException {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        if (!silent) {
          _showSnack(
            'Unable to get current location. Try again.',
            isError: true,
          );
        }
        return null;
      }
      final currentPos = pos;

      if (!mounted) return null;
      setState(() {
        _longitudeCtrl.text = currentPos.longitude.toString();
        _latitudeCtrl.text = currentPos.latitude.toString();
      });
      return currentPos;
    } catch (e) {
      if (!silent) {
        _showSnack('Failed to get location: $e', isError: true);
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  String? _requiredText(String? value, String label) {
    if ((value ?? '').trim().isEmpty) return '$label is required';
    return null;
  }

  String? _optionalNumeric(String? value, String label) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    if (num.tryParse(text) == null) return '$label must be numeric';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      _showSnack('Visitation type is required.', isError: true);
      return;
    }
    if (_userId == null) {
      _showSnack('User session not found. Please log in again.', isError: true);
      return;
    }

    final borrowerRaw = _borrowerIdCtrl.text.trim();
    final borrowerId = borrowerRaw.isEmpty ? null : int.tryParse(borrowerRaw);

    if (borrowerRaw.isNotEmpty && borrowerId == null) {
      _showSnack('Borrower ID must be numeric.', isError: true);
      return;
    }

    if (_attachment == null) {
      setState(() => _showAttachmentError = true);
      _showSnack('Attachment is required.', isError: true);
      return;
    }

    final payload = <String, dynamic>{
      'user_id': _userId,
      'borrower_id': borrowerId,
      'visitation_type': _selectedType,
      // Keep backend field names exactly as provided.
      'longitute': double.parse(_longitudeCtrl.text.trim()),
      'lattitude': double.parse(_latitudeCtrl.text.trim()),
      'visited_at': _visitedAt.toIso8601String(),
      if (_remarksCtrl.text.trim().isNotEmpty)
        'remarks': _remarksCtrl.text.trim(),
      if (_verificationResult != null)
        'verification_result': _verificationResult,
      if ((_selectedPrimaryReason ?? '').trim().isNotEmpty)
        'primary_reason': _selectedPrimaryReason,
      if (_verificationResult == false || _fraudFlag) 'fraud_flag': _fraudFlag,
      if ((_countryById(_selectedCountryId)?.name ?? '').isNotEmpty)
        'country': _countryById(_selectedCountryId)!.name,
      if (_regionCtrl.text.trim().isNotEmpty) 'region': _regionCtrl.text.trim(),
      if (_cityCtrl.text.trim().isNotEmpty) 'city': _cityCtrl.text.trim(),
      if (_brgyCtrl.text.trim().isNotEmpty) 'brgy': _brgyCtrl.text.trim(),
      if (_houseNumberCtrl.text.trim().isNotEmpty)
        'house_number': _houseNumberCtrl.text.trim(),
    };

    setState(() => _isSubmitting = true);
    try {
      final response = _attachment == null
          ? await ApiClient.post('/api/visitation-requests', body: payload)
          : await _postVisitationMultipart({
              'user_id': _userId.toString(),
              if (borrowerId != null) 'borrower_id': borrowerId.toString(),
              'visitation_type': _selectedType!,
              'longitute': _longitudeCtrl.text.trim(),
              'lattitude': _latitudeCtrl.text.trim(),
              'visited_at': _visitedAt.toIso8601String(),
              if (_remarksCtrl.text.trim().isNotEmpty)
                'remarks': _remarksCtrl.text.trim(),
              if (_verificationResult != null)
                'verification_result': _verificationResult! ? '1' : '0',
              if ((_selectedPrimaryReason ?? '').trim().isNotEmpty)
                'primary_reason': _selectedPrimaryReason!,
              if (_verificationResult == false || _fraudFlag)
                'fraud_flag': _fraudFlag ? '1' : '0',
              if ((_countryById(_selectedCountryId)?.name ?? '').isNotEmpty)
                'country': _countryById(_selectedCountryId)!.name,
              if (_regionCtrl.text.trim().isNotEmpty)
                'region': _regionCtrl.text.trim(),
              if (_cityCtrl.text.trim().isNotEmpty)
                'city': _cityCtrl.text.trim(),
              if (_brgyCtrl.text.trim().isNotEmpty)
                'brgy': _brgyCtrl.text.trim(),
              if (_houseNumberCtrl.text.trim().isNotEmpty)
                'house_number': _houseNumberCtrl.text.trim(),
            });
      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        _showSnack(
          (body['message'] ?? 'Visitation request created.').toString(),
        );
        Navigator.of(context).pop(true);
        return;
      }

      final err = _extractApiMessage(
        response.body,
        response.statusCode,
        'Failed to create visitation request.',
      );
      _showSnack(err, isError: true);
    } catch (e) {
      _showSnack('Submit failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitation Request'),
        backgroundColor: const Color(0xFF0F3D3E),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoadingUser
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _userId == null
                            ? 'No user session found.'
                            : 'User ID: $_userId',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Visitation Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _types
                          .map(
                            (t) => DropdownMenuItem<String>(
                              value: t,
                              child: Text(t),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedType = v),
                      validator: (v) => _requiredText(v, 'Visitation type'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _borrowerIdCtrl,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Borrower',
                        border: const OutlineInputBorder(),
                        helperText: _selectedBorrowerName == null
                            ? 'Search borrower by name'
                            : 'Name: $_selectedBorrowerName',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _pickBorrower,
                        ),
                      ),
                      validator: (v) => _optionalNumeric(v, 'Borrower ID'),
                    ),
                    if (_selectedLoanId != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Selected Loan ID: $_selectedLoanId',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                    if (_isPrefillingAddress) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(minHeight: 3),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<bool>(
                      value: _verificationResult,
                      decoration: InputDecoration(
                        labelText: 'Verification Result ($_verificationLabel)',
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem<bool>(
                          value: true,
                          child: Text('Approve'),
                        ),
                        DropdownMenuItem<bool>(
                          value: false,
                          child: Text('Decline'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _verificationResult = value;
                          _selectedPrimaryReason = null;
                          if (value != false) {
                            _fraudFlag = false;
                          }
                        });
                      },
                      validator: (value) => value == null
                          ? 'Verification result is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _primaryReasons.contains(_selectedPrimaryReason)
                          ? _selectedPrimaryReason
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: _verificationResult == true
                            ? 'Primary Reason (Approved)'
                            : _verificationResult == false
                            ? 'Primary Reason (Declined)'
                            : 'Primary Reason',
                        border: const OutlineInputBorder(),
                      ),
                      items: _primaryReasons
                          .map(
                            (reason) => DropdownMenuItem<String>(
                              value: reason,
                              child: Text(reason),
                            ),
                          )
                          .toList(),
                      onChanged: _primaryReasons.isEmpty
                          ? null
                          : (value) =>
                                setState(() => _selectedPrimaryReason = value),
                      validator: (value) {
                        if (_verificationResult == null) {
                          return 'Select verification result first';
                        }
                        if ((value ?? '').trim().isEmpty) {
                          return 'Primary reason is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: _fraudFlag,
                      title: const Text('Fraud Flag'),
                      subtitle: const Text(
                        'Mark when visit indicates fraud risk.',
                      ),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setState(() => _fraudFlag = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _remarksCtrl,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => _requiredText(value, 'Remarks'),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Attachment'),
                      subtitle: Text(
                        _attachment == null
                            ? 'No attachment selected'
                            : _attachment!.name,
                        style: _showAttachmentError && _attachment == null
                            ? const TextStyle(color: Colors.red)
                            : null,
                      ),
                      trailing: OutlinedButton(
                        onPressed: _pickAttachment,
                        child: Text(_attachment == null ? 'Capture' : 'Retake'),
                      ),
                    ),
                    if (_showAttachmentError && _attachment == null)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Attachment is required',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeCtrl,
                            readOnly: true,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              final req = _requiredText(v, 'Longitude');
                              if (req != null) return req;
                              return _optionalNumeric(v, 'Longitude');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeCtrl,
                            readOnly: true,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              final req = _requiredText(v, 'Latitude');
                              if (req != null) return req;
                              return _optionalNumeric(v, 'Latitude');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _isLocating ? null : _getCurrentLocation,
                        icon: _isLocating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: const Text('Use Current Location'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickVisitedAt,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Visited At',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('yyyy-MM-dd hh:mm a').format(_visitedAt),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedCountryId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        border: const OutlineInputBorder(),
                        suffixIcon: _isLoadingCountries
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      items: _countries
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: _isLoadingCountries
                          ? null
                          : (value) =>
                                setState(() => _selectedCountryId = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _regionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Region (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'City (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _brgyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Brgy (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _houseNumberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'House Number (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Submit Visitation Request'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
