import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/commons/reusables/toast.dart';
import '../blocs/break/break_bloc.dart';
import '../blocs/break/break_event.dart';
import '../blocs/break/break_state.dart';
import '../commons/models/break_session_model.dart';
import '../commons/reusables/logout_dialog.dart';
import '../commons/models/auth_models.dart';
import '../commons/services/app_config.dart';
import '../commons/services/environment_config.dart';
import '../commons/services/shared_prefs_storage_service.dart';
import 'profile_view.dart';
import 'break_management_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  UserSession? userSession;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    // Load break history when the view is initialized
    context.read<BreakBloc>().add(const LoadBreakHistory());
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final session = await SharedPrefsStorageService.getUserSession();
      final token = await SharedPrefsStorageService.getAuthToken();
      if (mounted) {
        setState(() {
          userSession = session;
          _authToken = token;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreakControls(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakControls() {
    return BlocBuilder<BreakBloc, BreakState>(
      builder: (context, state) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.purple, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Break Controls',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state is BreakActive) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pause_circle_filled,
                          color: Colors.orange,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Currently on ${state.activeBreak.type.name}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            final duration = DateTime.now().difference(
                              state.activeBreak.startTime,
                            );
                            return Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.orange.shade600,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _endBreak,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('End Break'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (state is BreakLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else ...[
                  const Text(
                    'Take a break from dialing:',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _buildBreakButton(
                        BreakType.shortBreak,
                        Icons.coffee,
                        Colors.blue,
                      ),
                      _buildBreakButton(
                        BreakType.lunch,
                        Icons.restaurant,
                        Colors.green,
                      ),
                      _buildBreakButton(
                        BreakType.meeting,
                        Icons.meeting_room,
                        Colors.orange,
                      ),
                      _buildBreakButton(
                        BreakType.customerSupportBreak,
                        Icons.support_agent,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Add button to navigate to full break management
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _navigateToBreakManagement,
                      icon: const Icon(Icons.manage_history),
                      label: const Text(
                        'Manage Breaks & History',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreakButton(BreakType type, IconData icon, Color color) {
    return ElevatedButton(
      onPressed: () => _startBreak(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            type.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          if (type.duration.inHours < 24)
            Text(
              _formatDuration(type.duration),
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'App Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Configure call notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle notification toggle
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
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
                  'Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User info section
            if (userSession != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.purple.shade200,
                      child: Text(
                        _getInitials(userSession!.fullName),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userSession!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            userSession!.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Debug: auth token display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.key, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text(
                        'Auth Token (Debug)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      if (_authToken != null)
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _authToken!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Token copied!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 14,
                            color: Colors.purple,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _authToken ?? 'No token found',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: _authToken != null ? Colors.black87 : Colors.red,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.public,
                        size: 14,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Environment',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: EnvironmentConfig.isProduction
                              ? Colors.red.shade100
                              : (EnvironmentConfig.isLocal
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          EnvironmentConfig.isProduction
                              ? 'PROD'
                              : (EnvironmentConfig.isLocal ? 'LOCAL' : 'DEV'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: EnvironmentConfig.isProduction
                                ? Colors.red.shade800
                                : (EnvironmentConfig.isLocal
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    EnvironmentConfig.apiBaseUrl.isEmpty
                        ? 'No API base URL loaded'
                        : EnvironmentConfig.apiBaseUrl,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'App Version',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'v${AppConfig.version}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              subtitle: const Text('View and edit your profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileView()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Security'),
              subtitle: const Text('Change password and security settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to security settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help and contact support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to help
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: Text(
                'v${AppConfig.version} — App version and information',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showAboutDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Sign out of your account'),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () => showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _startBreak(BreakType type) {
    context.read<BreakBloc>().add(StartBreak(type));
    toast(context, 'Started ${type.name}', ShowToast.warning);
  }

  void _endBreak() {
    context.read<BreakBloc>().add(const EndBreak());
    toast(context, 'Break ended', ShowToast.error);
  }

  void _navigateToBreakManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BreakManagementView()),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Lenderly Dialer',
      applicationVersion: AppConfig.version,
      applicationIcon: const Icon(Icons.phone, size: 48, color: Colors.purple),
      children: const [
        Text('A professional dialer app for loan collection teams.'),
        SizedBox(height: 8),
        Text('Features:'),
        Text('• Multi-bucket dialing system'),
        Text('• Break time tracking'),
        Text('• Call analytics and reporting'),
        Text('• Status tracking and notes'),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
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
}
