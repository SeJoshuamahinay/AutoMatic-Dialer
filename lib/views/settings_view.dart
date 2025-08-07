import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/break/break_bloc.dart';
import '../blocs/break/break_event.dart';
import '../blocs/break/break_state.dart';
import '../commons/models/break_session_model.dart';
import '../commons/reusables/logout_dialog.dart';
import '../commons/models/auth_models.dart';
import '../commons/services/shared_prefs_storage_service.dart';
import 'profile_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  UserSession? userSession;

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
      if (mounted) {
        setState(() {
          userSession = session;
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
            const Divider(),
            // ListTile(
            //   leading: const Icon(Icons.speed),
            //   title: const Text('Auto-Dial Speed'),
            //   subtitle: const Text('Set time between calls'),
            //   trailing: const Icon(Icons.chevron_right),
            //   onTap: () {
            //     // Navigate to auto-dial settings
            //   },
            // ),
            // const Divider(),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Data Backup'),
              subtitle: const Text('Backup call logs and settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to backup settings
              },
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
              subtitle: const Text('App version and information'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Started ${type.name}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _endBreak() {
    context.read<BreakBloc>().add(const EndBreak());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Break ended'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Lenderly Dialer',
      applicationVersion: '1.0.0',
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
