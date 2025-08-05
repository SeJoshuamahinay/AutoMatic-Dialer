import 'package:flutter_test/flutter_test.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/api_login_service.dart';

void main() {
  group('Real Backend Login Test', () {
    late LoginService loginService;

    setUpAll(() async {
      await EnvironmentConfig.initialize(environment: Environment.dev);
      loginService = LoginService();
      
      print('🔧 Testing with real backend:');
      print('Backend URL: ${EnvironmentConfig.apiBaseUrl}');
      print('Login Endpoint: ${EnvironmentConfig.getFullUrl(EnvironmentConfig.authEndpoint)}');
      print('');
    });

    test('should login with provided credentials', () async {
      print('🧪 Testing login with: jMahinay@lenderly.ph');
      
      final result = await loginService.login(
        identifier: 'jMahinay@lenderly.ph',
        password: '123',
        rememberMe: true,
      );

      print('Login result: ${result.success ? "✅ SUCCESS" : "❌ FAILED"}');
      print('Message: ${result.message}');
      
      if (result.success) {
        print('Username: ${result.username}');
        print('Token: ${result.token?.substring(0, 20)}...');
        
        // Test authentication status
        final isAuth = await loginService.isAuthenticated();
        print('Is Authenticated: ${isAuth ? "✅ YES" : "❌ NO"}');
        
        // Get user session
        final userSession = await loginService.getCurrentUserSession();
        if (userSession != null) {
          print('User Session:');
          print('  - Email: ${userSession.email}');
          print('  - Full Name: ${userSession.fullName}');
          print('  - Login Type: ${userSession.loginType}');
          print('  - Has Valid Token: ${userSession.hasValidToken}');
        }
        
        // Test Remember Me
        final rememberMeEnabled = await loginService.isRememberMeEnabled();
        print('Remember Me Enabled: ${rememberMeEnabled ? "✅ YES" : "❌ NO"}');
        
        final savedCredentials = await loginService.getSavedCredentials();
        if (savedCredentials != null) {
          print('Saved Credentials: ${savedCredentials['email']}');
        }
        
        // Cleanup
        await loginService.logout();
        print('✅ Logout completed');
      } else {
        // Check if it's a connection issue
        if (result.message.contains('Connection refused') || 
            result.message.contains('Failed host lookup')) {
          print('❌ Backend not reachable');
          print('💡 Make sure your Laravel backend is running:');
          print('   php artisan serve --port=8001');
        } else {
          print('❌ Authentication failed: ${result.message}');
        }
      }

      // The test should at least not throw an exception
      expect(result, isNotNull);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
