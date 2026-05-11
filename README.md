# Pokemon Login App

A Flutter application featuring user authentication with Supabase backend and an interactive Pokemon quiz game. Built with Clean Architecture principles and modern Flutter development practices.

## 🚀 Features

### Authentication
- **User Registration** - Create new accounts with email and password
- **Secure Login** - Authenticate with Supabase backend
- **Session Persistence** - Users stay logged in across app restarts
- **Sign Out** - Secure logout with session cleanup

### Pokemon Quiz Game
- **Interactive Quiz** - Guess Pokemon names from images
- **Multiple Choice** - 4 options per question
- **Score Tracking** - Track performance and calculate percentages
- **Game History** - View previous game results
- **Random Questions** - Dynamically generated Pokemon questions

### Technical Features
- **Clean Architecture** - Separation of concerns with layered architecture
- **State Management** - BLoC pattern for reactive state management
- **Dependency Injection** - GetIt for service locator pattern
- **Real-time Backend** - Supabase for authentication and data storage
- **Multi-platform Support** - iOS, Android, Web, Desktop

## 🏗️ Architecture

The project follows Clean Architecture with clear separation of concerns:

```
lib/
├── src/
│   ├── core/           # Core utilities and services
│   │   ├── constants/  # App constants (Supabase config)
│   │   ├── di/         # Dependency injection setup
│   │   ├── services/   # External service integrations
│   │   └── utils/      # Utility classes
│   ├── data/           # Data layer implementation
│   │   ├── datasources/# Remote data sources
│   │   ├── models/     # Data transfer objects
│   │   └── repositories/# Repository implementations
│   ├── domain/         # Business logic layer
│   │   ├── entities/   # Business objects
│   │   ├── repositories/# Repository interfaces
│   │   └── usecases/   # Business use cases
│   └── presentation/   # UI layer
│       ├── bloc/       # BLoC state management
│       ├── pages/      # UI screens
│       └── widgets/    # Reusable components
```

## 🛠️ Technologies Used

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **BLoC** - State management pattern
- **Supabase** - Backend-as-a-Service (Auth & Database)
- **GetIt** - Dependency injection
- **HTTP** - Network requests
- **Shared Preferences** - Local storage
- **Equatable** - Value equality

## 📋 Prerequisites

- Flutter SDK (>=3.1.5)
- Dart SDK
- Supabase account (for backend)
- Android Studio / Xcode (for mobile development)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd login_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Supabase Backend

Follow the detailed setup guide in [SUPABASE_SETUP.md](./SUPABASE_SETUP.md):

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your Project URL and anon key
3. Update `lib/src/core/constants/supabase_constants.dart`
4. Enable email authentication in Supabase dashboard

### 4. Run the Application

```bash
# For development
flutter run

# For specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome
```

## 📱 App Screens

### Authentication Flow
- **Login Page** - Sign in with existing credentials
- **Sign Up Page** - Create new user account
- **Auth Wrapper** - Handles authentication state

### Game Flow
- **Main Page** - User dashboard and game entry
- **Pokemon Game Page** - Interactive quiz interface
- **Game Results** - Score display and history

## 🎮 How to Play

1. **Login or Sign Up** to create your account
2. **Start a New Game** from the main dashboard
3. **Guess Pokemon Names** from the displayed images
4. **Select from Options** - Choose the correct name from 4 choices
5. **View Your Score** - See performance statistics
6. **Track Progress** - Access game history and improvement

## 🧪 Testing

The project includes comprehensive testing:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure
- **Unit Tests** - Domain logic and use cases
- **Widget Tests** - UI component testing
- **Integration Tests** - End-to-end user flows

## 🔧 Configuration

### Environment Variables

Update the Supabase configuration in `lib/src/core/constants/supabase_constants.dart`:

```dart
class SupabaseConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### Build Configuration

For production builds:

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📦 Project Dependencies

### Core Dependencies
- `flutter_bloc` - State management
- `supabase_flutter` - Backend integration
- `get_it` - Dependency injection
- `http` - Network requests
- `shared_preferences` - Local storage
- `equatable` - Value equality

### Development Dependencies
- `flutter_test` - Testing framework
- `mockito` - Mocking for tests
- `build_runner` - Code generation
- `flutter_lints` - Code quality

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 Code Style

The project follows Flutter/Dart conventions:
- Use `flutter_lints` for code quality
- Follow Clean Architecture principles
- Write meaningful commit messages
- Include tests for new features

## 🐛 Troubleshooting

### Common Issues

**Supabase Connection Issues**
- Verify your Supabase URL and keys
- Check network connectivity
- Ensure authentication is enabled in Supabase

**Build Issues**
- Run `flutter clean` and `flutter pub get`
- Check Flutter and Dart versions
- Verify platform-specific dependencies

**Authentication Problems**
- Clear app data and retry
- Check email confirmation settings
- Verify Supabase auth configuration

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - Cross-platform framework
- [Supabase](https://supabase.com/) - Backend services
- [BLoC](https://bloclibrary.dev/) - State management
- [PokéAPI](https://pokeapi.co/) - Pokemon data source

## 📞 Support

For questions or support:
- Create an issue in the repository
- Check the [Supabase Setup Guide](./SUPABASE_SETUP.md)
- Review the Flutter documentation

---

**Happy Coding! 🚀**
