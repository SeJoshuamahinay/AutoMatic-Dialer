import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/blocs/auth/auth_bloc.dart';
import 'package:lenderly_dialer/blocs/auth/auth_event.dart';
import 'package:lenderly_dialer/blocs/auth/auth_state.dart';
import 'package:lenderly_dialer/commons/reusables/toast.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _useTokenLogin = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_useTokenLogin) {
      final token = _tokenController.text.trim();
      if (token.isEmpty) {
        _showError('Please enter a token');
        return;
      }

      context.read<AuthBloc>().add(
        AuthLoginRequested(identifier: token, isTokenLogin: true),
      );
    } else {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        _showError('Please enter both username and password');
        return;
      }

      context.read<AuthBloc>().add(
        AuthLoginRequested(
          identifier: username,
          password: password,
          isTokenLogin: false,
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      toast(context, message, ShowToast.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (state is AuthError) {
            _showError(state.message);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade400, Colors.blue.shade800],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),

                      // App Icon/Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone,
                          size: 60,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // App Title
                      const Text(
                        'Lenderly Dialer App',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Automated Phone Dialing System',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),

                      const SizedBox(height: 48),

                      // Login Form
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 24),

                              // Login form fields
                              if (!_useTokenLogin) ...[
                                TextField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    hintText: 'Enter your username',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  enabled: !isLoading,
                                ),

                                const SizedBox(height: 16),

                                TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    prefixIcon: const Icon(Icons.lock),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  obscureText: true,
                                  enabled: !isLoading,
                                ),
                              ] else ...[
                                TextField(
                                  controller: _tokenController,
                                  decoration: InputDecoration(
                                    labelText: 'Access Token',
                                    hintText: 'Enter your access token',
                                    prefixIcon: const Icon(Icons.key),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  obscureText: true,
                                  enabled: !isLoading,
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Toggle login method
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _useTokenLogin = !_useTokenLogin;
                                        });
                                      },
                                child: Text(
                                  _useTokenLogin
                                      ? 'Use Username/Password Login'
                                      : 'Use Token Login',
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Demo hint
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Text(
                                  _useTokenLogin
                                      ? 'Demo: Enter any token with at least 4 characters'
                                      : 'Demo Credentials:\n• ITdepartment / password\n• symphony / symphony123\n• Any username (3+ chars) / password (4+ chars)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
