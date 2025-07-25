# Surabhi - Donor Care Cell of Hare Krishna Movement

Surabhi is a comprehensive Flutter mobile application designed for Admins, Employees, Preachers, Approvers, and Volunteers. The app provides tailored experiences and efficient management tools for each user group.

## Features

- Role-based dashboards and navigation
- Secure authentication and session management
- Modular and scalable architecture
- Centralized theming and styling
- Clean code practices using BLoC, Provider, and Dependency Injection

## Getting Started

### Prerequisites

- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Git**: For cloning the repository
- **Android Studio** or **VS Code**: With Flutter and Dart plugins

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

3. **Generate Launcher Icons**
    ```bash
    flutter pub run flutter_launcher_icons:main
    ```

4. **Run the Application**
    - Connect a device or start an emulator, then run:
    ```bash
    flutter run
    ```

## Project Structure

- `lib/main.dart` – App entry point and theme setup
- `lib/assets/` – Static assets (images, icons, fonts, etc.)
- `lib/features/` – Feature modules (auth, dashboard, etc.)
- `lib/core/` – Shared utilities, constants, and services
- `lib/routes/` – App navigation and routing
- `test/` - Test files
- `pubspec.yaml` – Project dependencies and metadata
- `README.md` – Project overview and guide
- `LICENSE.md` – License information

## Theming & Styling

Primary colors are defined in `lib/core/constants/colors.dart` and applied globally via `ThemeData` in `main.dart` for a consistent look and feel.

## Contribution

Contributions are welcome!  
Please fork the repository, create a feature branch, and submit a pull request following standard Git Flow practices.

## License

This project is proprietary software. All rights reserved.  
See the [LICENSE.md](LICENSE.md) file for details.

## Contact

For inquiries or support, please contact: [your-email@example.com]