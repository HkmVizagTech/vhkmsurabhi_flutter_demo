# Surabhi - Donor Care Cell of Hare Krishna Movement

A comprehensive Flutter application designed for role-based management across Android, iOS, and Web platforms. Built with Clean Architecture principles and modern Flutter development practices.

## 🎯 Target Platforms
- **Android** (API 21+)
- **iOS** (iOS 12+)
- **Web** (Modern browsers)

## ✨ Features

### 🔐 Authentication & Security
- Secure JWT-based authentication with automatic token refresh
- Role-based access control and navigation
- Encrypted local storage for sensitive data

### 👥 Role-Based Experience
- **Admin**: User management, registration, and system oversight
- **Employee**: Task management and workflow tools
- **Preacher**: Sermon management and scheduling
- **Approver**: Approval workflows and decision tracking
- **Volunteer**: Activity management and participation

### 🎨 Modern UI/UX
- Material Design 3 with custom theming
- Dark/Light mode support with system preference detection
- Responsive design for all screen sizes
- Role-specific drawer navigation with user avatars

### 🏗️ Technical Excellence
- Clean Architecture with feature-first organization
- BLoC pattern for state management
- Dependency injection with GetIt
- Comprehensive error handling and logging
- Automated testing and code quality checks

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code with Flutter extensions
- For iOS: Xcode 14+ (macOS only)

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/praveenkumargurrala/vhkmsurabhi_flutter.git
   cd vhkmsurabhi_flutter
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Generate App Assets**
   ```bash
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

5. **Run the Application**
   ```bash
   # Development mode
   flutter run

   # Specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d chrome
   ```

### Using Makefile (Recommended)
```bash
# Install dependencies and run
make run

# Build for production
make build_android  # Android APK
make build_ios      # iOS IPA

# Development tools
make analyze        # Code analysis
make test          # Run tests
make format        # Format code
```

## 📁 Project Structure

```
surabhi/
├── lib/
│   ├── main.dart                   # Application entry point
│   ├── injector.dart               # Dependency injection setup
│   ├── assets/                     # Static assets
│   │   ├── fonts/                  # Custom fonts (Open Sans, Montserrat)
│   │   ├── icons/                  # App icons
│   │   ├── images/                 # Images and graphics
│   │   └── logos/                  # App logos and branding
│   ├── core/                       # Shared core functionality
│   │   ├── constants/              # App-wide constants
│   │   ├── data/models/            # Shared data models
│   │   ├── domain/entities/        # Core business entities
│   │   ├── errors/                 # Error handling
│   │   ├── network/                # HTTP client and interceptors
│   │   ├── shared_preferences/     # Local storage service
│   │   ├── theme/                  # App theming and colors
│   │   ├── utils/                  # Utility functions and validators
│   │   └── widgets/                # Reusable UI components
│   ├── features/                   # Role-based feature modules
│   │   ├── admin/                  # Admin features
│   │   │   ├── dashboard/          # Admin dashboard
│   │   │   └── users/              # User management
│   │   ├── employee/               # Employee features
│   │   ├── preacher/               # Preacher features
│   │   ├── approver/               # Approver features
│   │   ├── volunteer/              # Volunteer features
│   │   ├── auth/                   # Authentication (shared)
│   │   ├── home/                   # Landing pages
│   │   └── settings/               # App settings
│   └── routes/                     # Navigation and routing
├── test/unit/                      # Unit tests
├── android/                        # Android platform files
├── ios/                            # iOS platform files
├── web/                            # Web platform files
├── docs/                           # Project documentation
├── pubspec.yaml                    # Dependencies and metadata
├── analysis_options.yaml           # Code analysis configuration
├── Makefile                        # Build automation
└── README.md                       # This file
```

### Architecture Highlights
- **Clean Architecture**: Clear separation of data, domain, and presentation layers
- **Feature-First**: Each role has its own feature module
- **Shared Core**: Common functionality in the core module
- **Role-Based**: Tailored experiences for each user type

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Detailed architecture overview and design patterns |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines and development workflow |
| [Folder Structure](docs/folder_structure.md) | Project organization and naming conventions |
| [Role-Based Navigation](docs/role_based_navigation.md) | Navigation system and user experience |

## 🎨 Theming & Styling

- **Colors**: Defined in `lib/core/theme/app_colors.dart`
- **Themes**: Light/Dark themes in `lib/core/theme/app_themes.dart`
- **State Management**: Theme switching via `ThemeCubit`
- **Fonts**: Open Sans (primary), Montserrat (headings)

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/core/utils/validators_test.dart
```

## 🔧 Development Tools

- **Code Analysis**: `flutter analyze` or `make analyze`
- **Code Formatting**: `dart format lib/` or `make format`
- **Code Generation**: `flutter pub run build_runner build`
- **Asset Generation**: `make assets`

## 🤝 Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Coding standards
- Pull request process
- Issue reporting

## 📄 License

This project is proprietary software. All rights reserved.
See [LICENSE.md](LICENSE.md) for details.

## 👥 Maintainers

- [@praveenkumargurrala](https://github.com/praveenkumargurrala) - Project Lead
- [@sudama011](https://github.com/sudama011) - Lead Developer
- [@Sdcoder123](https://github.com/Sdcoder123) - Developer

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/praveenkumargurrala/vhkmsurabhi_flutter/issues)
- **Discussions**: [GitHub Discussions](https://github.com/praveenkumargurrala/vhkmsurabhi_flutter/discussions)
- **Email**: Contact maintainers for urgent matters

---

**Built with ❤️ using Flutter for the Hare Krishna Movement**