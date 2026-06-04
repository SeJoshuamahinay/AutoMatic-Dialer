import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lenderly_dialer/blocs/auth/auth_bloc.dart';
import 'package:lenderly_dialer/blocs/auth/auth_event.dart';
import 'package:lenderly_dialer/blocs/dashboard/dashboard_bloc.dart';
import 'package:lenderly_dialer/blocs/dashboard/dashboard_event.dart';
import 'package:lenderly_dialer/blocs/dashboard/dashboard_state.dart';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/models/break_session_model.dart';
import 'package:lenderly_dialer/commons/models/call_log_model.dart';
import 'package:lenderly_dialer/commons/reusables/toast.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:lenderly_dialer/views/attendance_request_view.dart';
import 'package:lenderly_dialer/views/visitation_request_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final NumberFormat _amountFmt = NumberFormat('#,##0.00', 'en_PH');
  final ImagePicker _imagePicker = ImagePicker();
  late DateTime _now;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });

    final bloc = context.read<DashboardBloc>();
    bloc
      ..add(const InitializeDashboardServices())
      ..add(const LoadUserSession())
      ..add(LoadDashboardData(selectedDate: DateTime.now()));
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _onStateChanged(
    BuildContext context,
    DashboardState state,
  ) async {
    if (state is DashboardError) {
      toast(context, state.message, ShowToast.error);
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }

  DateTime _selectedDate(DashboardState state) {
    if (state is DashboardLoaded) return state.selectedDate;
    if (state is DashboardError) return state.selectedDate;
    return DateTime.now();
  }

  Future<void> _pickDate(DashboardState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate(state),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      context.read<DashboardBloc>().add(
        ChangeDashboardDate(selectedDate: picked),
      );
    }
  }

  ({
    DateTime selectedDate,
    List<CallLog> callLogs,
    List<BreakSession> breakSessions,
    Map<String, dynamic> dailyStats,
    UserSession? userSession,
    Map<String, dynamic>? dialerStats,
    bool isLoadingData,
    bool isLoadingStats,
  })
  _data(DashboardState state) {
    if (state is DashboardLoaded) {
      return (
        selectedDate: state.selectedDate,
        callLogs: state.callLogs,
        breakSessions: state.breakSessions,
        dailyStats: state.dailyStats,
        userSession: state.userSession,
        dialerStats: state.dialerStats,
        isLoadingData: state.isLoadingData,
        isLoadingStats: state.isLoadingStats,
      );
    }

    if (state is DashboardError) {
      return (
        selectedDate: state.selectedDate,
        callLogs: state.callLogs,
        breakSessions: state.breakSessions,
        dailyStats: state.dailyStats,
        userSession: state.userSession,
        dialerStats: state.dialerStats,
        isLoadingData: false,
        isLoadingStats: false,
      );
    }

    return (
      selectedDate: DateTime.now(),
      callLogs: const <CallLog>[],
      breakSessions: const <BreakSession>[],
      dailyStats: const <String, dynamic>{},
      userSession: null,
      dialerStats: null,
      isLoadingData: state is DashboardLoading,
      isLoadingStats: false,
    );
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value) ?? double.tryParse(value)?.toInt();
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${d.inMinutes}m';
  }

  Widget _quickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap an action to prepare a draft. Backend fields can be wired later.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _quickActionCard(
                title: 'Visitation',
                subtitle: 'DL, CI, house, reminder, tracing',
                icon: Icons.route,
                color: const Color(0xFF0F3D3E),
                onTap: _openVisitationRequestPage,
              ),
              _quickActionCard(
                title: 'Time In',
                subtitle: 'Selfie + GPS required',
                icon: Icons.login,
                color: const Color(0xFF16A34A),
                onTap: _openTimeInPage,
              ),
              _quickActionCard(
                title: 'Time Out',
                subtitle: 'Time in and out summary',
                icon: Icons.logout,
                color: const Color(0xFFF59E0B),
                onTap: _openTimeOutPage,
              ),
              _quickActionCard(
                title: 'Reimbursement',
                subtitle: 'Request draft only',
                icon: Icons.receipt_long,
                color: const Color(0xFF8B5CF6),
                onTap: _openReimbursementActionSheet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.82)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Position?> _getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _showSnack('Location service is off.', isError: true);
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnack('Location permission needed.', isError: true);
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String _positionLabel(Position pos) {
    return '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
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

  Widget _draftRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
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

  Future<XFile?> _captureSelfie() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );
    } catch (e) {
      _showSnack('Camera not available: $e', isError: true);
      return null;
    }
  }

  Future<XFile?> _captureProof() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
    } catch (e) {
      _showSnack('Camera not available: $e', isError: true);
      return null;
    }
  }

  Future<int?> _resolveUserId() async {
    final session = await SharedPrefsStorageService.getUserSession();
    if (session?.userId != null) return session!.userId;
    _showSnack('User session missing. Please login again.', isError: true);
    return null;
  }

  String _extractApiMessage(httpBody, int statusCode, String fallback) {
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
            if (first != null && first.trim().isNotEmpty) {
              return first;
            }
          }
          if (value is String && value.trim().isNotEmpty) {
            return value;
          }
        }
      }
      final msg = body['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg;
    } catch (_) {}
    return '$fallback (HTTP $statusCode)';
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

  Future<bool> _submitTimeIn(
    Position location, {
    required String attendanceType,
    required String remarks,
    XFile? attachment,
  }) async {
    final userId = await _resolveUserId();
    if (userId == null) return false;

    try {
      final response = attachment == null
          ? await ApiClient.post(
              '/api/attendance/time-in',
              body: {
                'user_id': userId,
                'latitude': location.latitude,
                'longiturede': location.longitude,
                'attendance_type': attendanceType,
                if (remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
              },
            )
          : await _postAttendanceMultipart(
              '/api/attendance/time-in',
              fields: {
                'user_id': userId.toString(),
                'latitude': location.latitude.toString(),
                'longiturede': location.longitude.toString(),
                'attendance_type': attendanceType,
                if (remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
              },
              attachment: attachment,
            );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnack('Time-in recorded.');
        return true;
      }

      _showSnack(
        _extractApiMessage(
          response.body,
          response.statusCode,
          'Failed to record time-in',
        ),
        isError: true,
      );
      return false;
    } catch (e) {
      _showSnack('Time-in failed: $e', isError: true);
      return false;
    }
  }

  Future<bool> _submitTimeOut(
    Position location, {
    required String attendanceType,
    required String remarks,
    XFile? attachment,
  }) async {
    final userId = await _resolveUserId();
    if (userId == null) return false;

    try {
      final response = attachment == null
          ? await ApiClient.post(
              '/api/attendance/time-out',
              body: {
                'user_id': userId,
                'latitude': location.latitude,
                'longiturede': location.longitude,
                'attendance_type': attendanceType,
                if (remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
              },
            )
          : await _postAttendanceMultipart(
              '/api/attendance/time-out',
              fields: {
                'user_id': userId.toString(),
                'latitude': location.latitude.toString(),
                'longiturede': location.longitude.toString(),
                'attendance_type': attendanceType,
                if (remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
              },
              attachment: attachment,
            );

      if (response.statusCode == 200) {
        _showSnack('Time-out recorded.');
        return true;
      }

      _showSnack(
        _extractApiMessage(
          response.body,
          response.statusCode,
          'Failed to record time-out',
        ),
        isError: true,
      );
      return false;
    } catch (e) {
      _showSnack('Time-out failed: $e', isError: true);
      return false;
    }
  }

  Future<void> _openVisitationRequestPage() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const VisitationRequestView()),
    );

    if (!mounted || created != true) return;
    _showSnack('Visitation request submitted.');
  }

  Future<void> _openTimeInPage() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AttendanceRequestView(action: AttendanceAction.timeIn),
      ),
    );
  }

  Future<void> _openTimeOutPage() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AttendanceRequestView(action: AttendanceAction.timeOut),
      ),
    );
  }

  // ignore: unused_element
  Future<void> _openTimeInActionSheet() async {
    final location = await _getCurrentPosition();
    if (!mounted) return;

    XFile? selfie = await _captureSelfie();
    if (!mounted) return;

    final now = DateTime.now();
    final notesController = TextEditingController();
    String attendanceType = 'onsite';
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      'Time In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _draftRow(
                      'Time In',
                      DateFormat('yyyy-MM-dd hh:mm a').format(now),
                    ),
                    _draftRow(
                      'Location',
                      location == null
                          ? 'Pending location'
                          : _positionLabel(location),
                    ),
                    _draftRow(
                      'Selfie',
                      selfie == null ? 'No photo' : selfie!.name,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: attendanceType,
                      decoration: const InputDecoration(
                        labelText: 'Attendance Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'onsite',
                          child: Text('Onsite'),
                        ),
                        DropdownMenuItem(
                          value: 'remote',
                          child: Text('Remote'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setSheetState(() => attendanceType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final nextSelfie = await _captureSelfie();
                              if (!mounted) return;
                              if (nextSelfie != null) {
                                setSheetState(() => selfie = nextSelfie);
                              }
                            },
                            child: const Text('Retake Selfie'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (location == null) {
                                      _showSnack(
                                        'Location is required. Enable GPS then retry.',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    if (selfie == null) {
                                      _showSnack(
                                        'Selfie attachment is required for Time In.',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    setSheetState(() => isSubmitting = true);
                                    final ok = await _submitTimeIn(
                                      location,
                                      attendanceType: attendanceType,
                                      remarks: notesController.text,
                                      attachment: selfie,
                                    );
                                    if (!mounted) return;
                                    setSheetState(() => isSubmitting = false);
                                    if (!ok) return;
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              isSubmitting ? 'Submitting...' : 'Submit Time In',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Time in requires selfie/photo and geolocation.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    notesController.dispose();
  }

  // ignore: unused_element
  Future<void> _openTimeOutActionSheet() async {
    final location = await _getCurrentPosition();
    if (!mounted) return;

    final now = DateTime.now();
    XFile? proof;

    final notesController = TextEditingController();
    String attendanceType = 'onsite';
    bool isSubmitting = false;
    final timeInText = DateFormat(
      'yyyy-MM-dd hh:mm a',
    ).format(now.subtract(const Duration(hours: 8)));
    final timeOutText = DateFormat('yyyy-MM-dd hh:mm a').format(now);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      'Time Out',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _draftRow('Time In', timeInText),
                    _draftRow('Time Out', timeOutText),
                    _draftRow(
                      'Location',
                      location == null
                          ? 'Pending location'
                          : _positionLabel(location),
                    ),
                    _draftRow(
                      'Attachment',
                      proof == null ? 'No photo' : proof!.name,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: attendanceType,
                      decoration: const InputDecoration(
                        labelText: 'Attendance Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'onsite',
                          child: Text('Onsite'),
                        ),
                        DropdownMenuItem(
                          value: 'remote',
                          child: Text('Remote'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setSheetState(() => attendanceType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: () async {
                          final next = await _captureProof();
                          if (!mounted) return;
                          if (next != null) {
                            setSheetState(() => proof = next);
                          }
                        },
                        child: const Text('Retake Attachment'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (location == null) {
                                  _showSnack(
                                    'Location is required. Enable GPS then retry.',
                                    isError: true,
                                  );
                                  return;
                                }
                                setSheetState(() => isSubmitting = true);
                                final ok = await _submitTimeOut(
                                  location,
                                  attendanceType: attendanceType,
                                  remarks: notesController.text,
                                  attachment: proof,
                                );
                                if (!mounted) return;
                                setSheetState(() => isSubmitting = false);
                                if (!ok) return;
                                Navigator.pop(context);
                              },
                        child: Text(
                          isSubmitting ? 'Submitting...' : 'Submit Time Out',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Time out keeps both time in and time out visible for backend mapping.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    notesController.dispose();
  }

  Future<void> _openReimbursementActionSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  'Reimbursement Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Receipt / Attachment Ref',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnack('Reimbursement draft ready.');
                    },
                    child: const Text('Prepare Draft'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add backend fields later for amount, reason, and attachment.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0F3D3E),
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) => IconButton(
              tooltip: 'Select Date',
              icon: const Icon(Icons.calendar_month),
              onPressed: () => _pickDate(state),
            ),
          ),
          IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<DashboardBloc>().add(const RefreshDashboardData()),
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: _onStateChanged,
        builder: (context, state) {
          final d = _data(state);
          final totalLoans = _asInt(d.dialerStats?['total_loans']);
          final totalOutstanding = _asDouble(
            d.dialerStats?['total_outstanding'],
          );

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const RefreshDashboardData());
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              children: [
                _timeHero(d.userSession, d.selectedDate),
                const SizedBox(height: 12),
                _quickActionsSection(),
                const SizedBox(height: 12),
                _portfolioCard(
                  totalLoans,
                  totalOutstanding,
                  d.dialerStats,
                  d.isLoadingStats,
                ),
                const SizedBox(height: 12),
                _activityCard(d.callLogs),
                const SizedBox(height: 12),
                _latestCallsCard(d.callLogs),
                const SizedBox(height: 12),
                _breakSummaryCard(d.breakSessions, d.selectedDate),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _timeHero(UserSession? user, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3D3E), Color(0xFF2A9D8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Operations',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.fullName ?? 'Dialer Agent',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('hh:mm:ss a').format(_now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                DateFormat('EEEE, MMMM d').format(_now),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Selected: ${DateFormat('EEE, MMM d, y').format(selectedDate)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _portfolioCard(
    int totalLoans,
    double totalOutstanding,
    Map<String, dynamic>? stats,
    bool isLoading,
  ) {
    final frontend =
        (stats?['buckets']?['frontend'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final hardcore =
        (stats?['buckets']?['hardcore'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF0F3D3E),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Portfolio',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Loans: $totalLoans',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            'Outstanding: P${_amountFmt.format(totalOutstanding)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _bucketLine('Frontend', frontend),
          const SizedBox(height: 8),
          _bucketLine('Hardcore', hardcore),
        ],
      ),
    );
  }

  Widget _bucketLine(String title, Map<String, dynamic> bucket) {
    final count = _asInt(bucket['count']);
    final outstanding = _asDouble(bucket['total_outstanding']);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF8FAFC),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$title: $count accounts',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'P${_amountFmt.format(outstanding)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(List<CallLog> callLogs) {
    final complete = callLogs
        .where((c) => c.status == CallStatus.complete)
        .length;
    final noAnswer = callLogs
        .where((c) => c.status == CallStatus.noAnswer)
        .length;
    final hangUp = callLogs.where((c) => c.status == CallStatus.hangUp).length;
    final total = callLogs.isEmpty ? 1 : callLogs.length;

    Widget line(String title, int value, Color color) {
      final ratio = (value / total).clamp(0, 1).toDouble();
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text('$value'),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Call Activity',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          line('Complete', complete, const Color(0xFF16A34A)),
          line('No Answer', noAnswer, const Color(0xFFF59E0B)),
          line('Hang Up', hangUp, const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _latestCallsCard(List<CallLog> callLogs) {
    final latest = callLogs.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Calls',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (latest.isEmpty)
            const Text(
              'No recent calls yet',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            ...latest.map(
              (log) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.teal.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.borrowerName?.isNotEmpty == true
                            ? log.borrowerName!
                            : 'Loan #${log.loanID ?? '-'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(log.callTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _breakSummaryCard(List<BreakSession> sessions, DateTime selectedDate) {
    final today = sessions.where(
      (s) =>
          s.startTime.year == selectedDate.year &&
          s.startTime.month == selectedDate.month &&
          s.startTime.day == selectedDate.day,
    );
    final total = today.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + s.actualDuration,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.pause_circle_filled, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Break Summary: ${today.length} sessions, ${_formatDuration(total)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
