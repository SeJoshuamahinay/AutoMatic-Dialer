import 'package:flutter/material.dart';
import 'package:lenderly_dialer/commons/services/api_login_service.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';

/// Demo widget to test Sanctum authentication
class SanctumAuthDemo extends StatefulWidget {
  const SanctumAuthDemo({super.key});

  @override
  State<SanctumAuthDemo> createState() => _SanctumAuthDemoState();
}

class _SanctumAuthDemoState extends State<SanctumAuthDemo> {
  final LoginService _loginService = LoginService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _status = 'Ready';
  String _userInfo = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isAuth = await _loginService.isAuthenticated();
    if (isAuth) {
      final userSession = await _loginService.getCurrentUserSession();
      setState(() {
        _status = 'Authenticated';
        _userInfo =
            'User: ${userSession?.fullName ?? 'Unknown'}\n'
            'Email: ${userSession?.email ?? 'Unknown'}\n'
            'Login Type: ${userSession?.loginType ?? 'Unknown'}\n'
            'Has Token: ${userSession?.hasValidToken ?? false}';
      });
    } else {
      setState(() {
        _status = 'Not Authenticated';
        _userInfo = '';
      });
    }
  }

  Future<void> _login() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _status = 'Logging in...';
    });

    try {
      final result = await _loginService.login(
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _status = result.success ? 'Login Successful' : 'Login Failed';
        if (!result.success) {
          _userInfo = 'Error: ${result.message}';
        }
      });

      if (result.success) {
        await _checkAuthStatus();
      }
    } catch (e) {
      setState(() {
        _status = 'Login Error';
        _userInfo = 'Exception: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _status = 'Logging out...';
    });

    try {
      await _loginService.logout();
      setState(() {
        _status = 'Logged out';
        _userInfo = '';
      });
    } catch (e) {
      setState(() {
        _status = 'Logout Error';
        _userInfo = 'Exception: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshToken() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _status = 'Refreshing token...';
    });

    try {
      final success = await _loginService.refreshToken();
      setState(() {
        _status = success ? 'Token refreshed' : 'Token refresh failed';
      });

      if (success) {
        await _checkAuthStatus();
      }
    } catch (e) {
      setState(() {
        _status = 'Refresh Error';
        _userInfo = 'Exception: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanctum Auth Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Environment info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Environment Configuration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Environment: ${EnvironmentConfig.currentEnvironment}',
                    ),
                    Text('API Base URL: ${EnvironmentConfig.apiBaseUrl}'),
                    Text('Device Name: ${EnvironmentConfig.defaultDeviceName}'),
                    Text('Sanctum Auth: ${EnvironmentConfig.useSanctumAuth}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Login form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Try: ITDepartment',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Try: password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Login'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _logout,
                            child: const Text('Logout'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _refreshToken,
                      child: const Text('Refresh Token'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status and user info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: $_status',
                      style: TextStyle(
                        color:
                            _status.contains('Error') ||
                                _status.contains('Failed')
                            ? Colors.red
                            : _status.contains('Successful') ||
                                  _status.contains('Authenticated')
                            ? Colors.green
                            : Colors.black,
                      ),
                    ),
                    if (_userInfo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'User Information:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(_userInfo),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkAuthStatus,
              child: const Text('Check Auth Status'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
