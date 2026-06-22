import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/blocs/auth/auth_bloc.dart';
import 'package:lenderly_dialer/blocs/auth/auth_event.dart';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/reusables/toast.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserSession? userSession;
  bool isLoading = true;

  // API profile data
  Map<String, dynamic>? _profile;
  bool _isProfileLoading = false;

  // Password change form
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isUpdatingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _fetchProfile();
  }

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserSession() async {
    try {
      final session = await SharedPrefsStorageService.getUserSession();
      setState(() {
        userSession = session;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        toast(context, 'Error loading profile: $e', ShowToast.error);
      }
    }
  }

  Future<void> _fetchProfile() async {
    setState(() => _isProfileLoading = true);
    try {
      final session = await SharedPrefsStorageService.getUserSession();
      final userId = session?.userId;
      final endpoint = userId != null
          ? '/api/user/profile?user_id=$userId'
          : '/api/user/profile';

      final res = await ApiClient.get(endpoint);
      print('Profile API response: ${res.statusCode} - ${res.body}');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _profile = body is Map<String, dynamic>
                ? (body['data']?['user'] as Map<String, dynamic>? ?? body)
                : null;
          });
        }
        if (_profile != null) {
          await SharedPrefsStorageService.saveUserProfile(_profile!);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isProfileLoading = false);
  }

  Future<void> _updatePassword() async {
    final current = _currentPwCtrl.text.trim();
    final newPw = _newPwCtrl.text.trim();
    final confirm = _confirmPwCtrl.text.trim();

    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      toast(context, 'Please fill in all password fields', ShowToast.error);
      return;
    }
    if (newPw != confirm) {
      toast(context, 'New passwords do not match', ShowToast.error);
      return;
    }
    if (newPw.length < 6) {
      toast(
        context,
        'New password must be at least 6 characters',
        ShowToast.error,
      );
      return;
    }

    setState(() => _isUpdatingPassword = true);
    try {
      final session = await SharedPrefsStorageService.getUserSession();
      final userId = session?.userId;

      final res = await ApiClient.post(
        '/api/user/profile',
        body: {
          'user_id': userId,
          'current_password': current,
          'new_password': newPw,
          'new_password_confirmation': confirm,
        },
      );
      print('Password update response: ${res.statusCode} - ${res.body}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final success = body['success'] == true;

        if (success || res.statusCode == 200) {
          toast(context, 'Password updated. Logging out...', ShowToast.success);
          _currentPwCtrl.clear();
          _newPwCtrl.clear();
          _confirmPwCtrl.clear();
          context.read<AuthBloc>().add(AuthLogoutRequested());
          return;
        }
      }

      String msg = 'Failed to update password';
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        msg = body['message']?.toString() ?? msg;
        final errors = body['errors'];
        if (errors is Map) {
          for (final e in errors.values) {
            if (e is List && e.isNotEmpty) {
              msg = e.first.toString();
              break;
            }
          }
        }
      } catch (_) {}

      toast(context, msg, ShowToast.error);
    } catch (e) {
      toast(context, 'Update failed: $e', ShowToast.error);
    } finally {
      if (mounted) setState(() => _isUpdatingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userSession == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No user data found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please log in again',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildUserInfo(),
                  const SizedBox(height: 24),
                  _buildPasswordSection(),
                  const SizedBox(height: 24),
                  _buildSessionInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.purple.shade100,
              child: Text(
                _getInitials(userSession!.fullName),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userSession!.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userSession!.email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'User Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isProfileLoading)
              const Center(child: CircularProgressIndicator())
            else if (_profile != null) ...[
              _buildInfoRow('User ID', (_profile!['id'] ?? '—').toString()),
              _buildInfoRow('Email', (_profile!['email'] ?? '—').toString()),
              _buildInfoRow(
                'First Name',
                (_profile!['first_name'] ?? '—').toString(),
              ),
              _buildInfoRow(
                'Last Name',
                (_profile!['last_name'] ?? '—').toString(),
              ),
              _buildInfoRow(
                'Full Name',
                (_profile!['full_name'] ?? '—').toString(),
              ),
              _buildInfoRow('Phone', (_profile!['phone'] ?? '—').toString()),
              _buildInfoRow(
                'Address',
                (_profile!['address'] ?? '—').toString(),
              ),
              _buildInfoRow('Gender', (_profile!['gender'] ?? '—').toString()),
              _buildInfoRow(
                'Department ID',
                (_profile!['department_id'] ?? '—').toString(),
              ),
              if (_profile!['employee_detail'] != null) ...[
                const Divider(height: 24),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Employee Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),

                _buildInfoRow(
                  'Employee ID',
                  (_profile!['employee_detail']!['employee_id'] ?? '—')
                      .toString(),
                ),
                // _buildInfoRow(
                //   'Contract Start',
                //   (_profile!['employee_detail']!['contract_start_date'] ??
                //           '—')
                //       .toString(),
                // ),
                // _buildInfoRow(
                //   'Contract End',
                //   (_profile!['employee_detail']!['contract_end_date'] ?? '—')
                //       .toString(),
                // ),
                // _buildInfoRow(
                //   'Contact Type',
                //   (_profile!['employee_detail']!['contact_type'] ?? '—')
                //       .toString(),
                // ),
                // _buildInfoRow(
                //   'Salary',
                //   (_profile!['employee_detail']!['salary'] ?? '—').toString(),
                // ),
                // _buildInfoRow(
                //   'Hourly Rate',
                //   (_profile!['employee_detail']!['hourly_rate'] ?? '—')
                //       .toString(),
                // ),
                _buildInfoRow(
                  'Payment Structure',
                  (_profile!['employee_detail']!['payment_structure'] ?? '—')
                      .toString(),
                ),
              ],
            ] else ...[
              _buildInfoRow('User ID', userSession!.userId.toString()),
              _buildInfoRow('Email', userSession!.email),
              _buildInfoRow('Full Name', userSession!.fullName),
              _buildInfoRow('Login Type', userSession!.loginType),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _currentPwCtrl,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPwCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_open),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPwCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdatingPassword ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isUpdatingPassword
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Update Password',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Login Time',
              _formatDateTime(userSession!.loginTime),
            ),
            _buildInfoRow(
              'Token Status',
              userSession!.hasValidToken ? 'Valid' : 'Invalid',
            ),
            if (userSession!.tokenExpiresAt != null)
              _buildInfoRow(
                'Token Expires',
                _formatDateTime(userSession!.tokenExpiresAt!),
              ),
            if (userSession!.token != null)
              _buildInfoRow(
                'Token (Preview)',
                '${userSession!.token!.substring(0, 20)}...',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
