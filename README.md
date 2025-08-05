# AutoMatic Dialer - Lenderly Dialer App

A Flutter-based automatic dialer application with Laravel Sanctum authentication integration.

## 🚀 Features

- **Sanctum Token Authentication**: Secure authentication using Laravel Sanctum tokens
- **Remember Me Functionality**: Auto-login with saved credentials
- **Automatic Dialing**: Efficient call management system
- **Cross-Platform**: Supports Android, iOS, Web, Windows, macOS, and Linux
- **State Management**: Clean architecture using BLoC pattern
- **Modern UI**: Beautiful and responsive user interface
- **Secure Storage**: Token and credential management using shared preferences

## 🏗️ Architecture

- **Frontend**: Flutter with BLoC state management
- **Backend**: Laravel with Sanctum authentication
- **Storage**: SharedPreferences for session/token management
- **API**: RESTful API integration with proper error handling

## 📋 Requirements

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Laravel backend with Sanctum authentication
- Android Studio / VS Code
- Git

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/SeJoshuamahinay/AutoMatic-Dialer.git
   cd AutoMatic-Dialer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Copy `.env.dev` and update with your backend URL
   - Ensure your Laravel backend is running on the configured port

4. **Run the application**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Environment Settings

Update `.env.dev` with your backend configuration:

```bash
API_BASE_URL=http://127.0.0.1:8001/api/auth/sanctum
DEFAULT_DEVICE_NAME=LenderlyDialer
USE_SANCTUM_AUTH=true
ENABLE_LOGGING=true
```

### Backend Integration

Ensure your Laravel backend has:
- Sanctum package installed and configured
- Proper API endpoints for authentication
- CORS configuration for cross-origin requests

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/backend_integration_test.dart
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔧 Development

### Project Structure

```
lib/
├── blocs/              # BLoC state management
│   └── auth/          # Authentication BLoC
├── commons/           # Shared utilities
│   ├── models/        # Data models
│   └── services/      # API and storage services
├── data/              # Data layer
├── views/             # UI screens
└── main.dart          # App entry point

test/
├── backend_integration_test.dart  # Integration tests
├── mocks/                        # Mock services for testing
└── widget_test.dart              # Widget tests
```

### Key Services

- **LoginService**: Handles authentication logic
- **AuthApiService**: API communication with backend
- **SharedPrefsStorageService**: Local storage management
- **EnvironmentConfig**: Configuration management

## 🌟 Features in Detail

### Authentication System
- Sanctum token-based authentication
- Automatic token refresh
- Remember Me functionality
- Secure credential storage
- ITDepartment bypass for testing

### State Management
- BLoC pattern for clean separation of concerns
- Event-driven architecture
- Reactive UI updates
- Error handling and loading states

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Joshua Mahinay**
- GitHub: [@SeJoshuamahinay](https://github.com/SeJoshuamahinay)
- Email: jMahinay@lenderly.ph

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Laravel team for Sanctum authentication
- Contributors and testers

## 📞 Support

For support and questions, please open an issue on GitHub or contact the development team.

---

Built with ❤️ using Flutter and Laravel Sanctum
# AutoMatic-Dialer
