import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/app_config.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

enum AttendanceAction { timeIn, timeOut }

class AttendanceRequestView extends StatefulWidget {
  final AttendanceAction action;

  const AttendanceRequestView({super.key, required this.action});

  @override
  State<AttendanceRequestView> createState() => _AttendanceRequestViewState();
}

class _AttendanceRequestViewState extends State<AttendanceRequestView> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _remarksCtrl = TextEditingController();

  Position? _location;
  bool _isLocating = false;
  bool _isSubmitting = false;
  XFile? _attachment;
  String _attendanceType = 'onsite';
  late final DateTime _now;

  bool get _isTimeIn => widget.action == AttendanceAction.timeIn;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocation();
    });
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
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

  String _extractApiMessage(dynamic httpBody, int statusCode, String fallback) {
    if (httpBody == null || httpBody.isEmpty) {
      return '$fallback (HTTP $statusCode)';
    }
    try {
      final body = jsonDecode(httpBody) as Map<String, dynamic>;
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

  Future<int?> _resolveUserId() async {
    final session = await SharedPrefsStorageService.getUserSession();
    if (session?.userId != null) return session!.userId;
    _showSnack('User session missing. Please login again.', isError: true);
    return null;
  }

  Future<void> _loadLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _showSnack('Location service is off.', isError: true);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Location permission needed.', isError: true);
        return;
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
        _showSnack('Unable to get current location.', isError: true);
        return;
      }

      if (!mounted) return;
      setState(() => _location = pos);
    } catch (e) {
      _showSnack('Location error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _captureAttachment() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: _isTimeIn
            ? CameraDevice.front
            : CameraDevice.rear,
        imageQuality: 80,
      );
      if (!mounted || file == null) return;
      setState(() => _attachment = file);
    } catch (e) {
      _showSnack('Camera not available: $e', isError: true);
    }
  }

  Future<http.Response> _postAttendanceMultipart(
    String endpoint, {
    required Map<String, String> fields,
    XFile? attachment,
  }) async {
    final token = await SharedPrefsStorageService.getAuthToken();
    final uri = Uri.parse('${EnvironmentConfig.apiBaseUrl}$endpoint');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['X-App-Version'] = AppConfig.version
      ..fields.addAll(fields);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath('attachment', attachment.path),
      );
    }

    final streamResponse = await request.send();
    return http.Response.fromStream(streamResponse);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (_location == null) {
      _showSnack('Location is required. Enable GPS then retry.', isError: true);
      return;
    }
    if (_isTimeIn && _attachment == null) {
      _showSnack('Selfie attachment is required for Time In.', isError: true);
      return;
    }

    final userId = await _resolveUserId();
    if (userId == null) return;

    final endpoint = _isTimeIn
        ? '/api/attendance/time-in'
        : '/api/attendance/time-out';

    setState(() => _isSubmitting = true);
    try {
      final response = _attachment == null
          ? await ApiClient.post(
              endpoint,
              body: {
                'user_id': userId,
                'latitude': _location!.latitude,
                'longiturede': _location!.longitude,
                'attendance_type': _attendanceType,
                if (_remarksCtrl.text.trim().isNotEmpty)
                  'remarks': _remarksCtrl.text.trim(),
              },
            )
          : await _postAttendanceMultipart(
              endpoint,
              fields: {
                'user_id': userId.toString(),
                'latitude': _location!.latitude.toString(),
                'longiturede': _location!.longitude.toString(),
                'attendance_type': _attendanceType,
                if (_remarksCtrl.text.trim().isNotEmpty)
                  'remarks': _remarksCtrl.text.trim(),
              },
              attachment: _attachment,
            );

      final ok = _isTimeIn
          ? (response.statusCode == 201 || response.statusCode == 200)
          : response.statusCode == 200;

      if (!ok) {
        _showSnack(
          _extractApiMessage(
            response.body,
            response.statusCode,
            _isTimeIn
                ? 'Failed to record time-in'
                : 'Failed to record time-out',
          ),
          isError: true,
        );
        return;
      }

      _showSnack(_isTimeIn ? 'Time-in recorded.' : 'Time-out recorded.');
      Navigator.of(context).pop(true);
    } catch (e) {
      _showSnack('Submit failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _positionLabel(Position pos) {
    return '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeInText = DateFormat('yyyy-MM-dd hh:mm a').format(_now);
    final timeOutText = DateFormat('yyyy-MM-dd hh:mm a').format(_now);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isTimeIn ? 'Time In' : 'Time Out'),
        backgroundColor: _isTimeIn
            ? const Color(0xFF16A34A)
            : const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _row(
            _isTimeIn ? 'Time In' : 'Time Out',
            _isTimeIn ? timeInText : timeOutText,
          ),
          _row(
            'Location',
            _location == null ? 'Pending location' : _positionLabel(_location!),
          ),
          _row(
            _isTimeIn ? 'Selfie' : 'Attachment',
            _attachment == null ? 'No photo' : _attachment!.name,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _attendanceType,
            decoration: const InputDecoration(
              labelText: 'Attendance Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'onsite', child: Text('Onsite')),
              DropdownMenuItem(value: 'remote', child: Text('Remote')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _attendanceType = v);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _remarksCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Remarks',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLocating ? null : _loadLocation,
                  icon: _isLocating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: const Text('Refresh Location'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _captureAttachment,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    _attachment == null ? 'Capture Photo' : 'Retake Photo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(
                _isSubmitting
                    ? 'Submitting...'
                    : (_isTimeIn ? 'Submit Time In' : 'Submit Time Out'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
