# Contributing to Surabhi

Thank you for your interest in contributing to the Surabhi Flutter project!  
Please follow these guidelines to help us maintain a high-quality codebase and smooth collaboration.

---

## Getting Started

### Prerequisites

- **Flutter SDK**: 3.8.1 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: 3.8.1 or higher (included with Flutter)
- **Git**: For version control
- **IDE**: Android Studio, VS Code, or IntelliJ with Flutter/Dart plugins
- **Platform-specific tools**:
  - **Android**: Android Studio with Android SDK
  - **iOS**: Xcode 14+ (macOS only)
  - **Web**: Chrome browser for testing

### Installation

1. **Fork the Repository**
   - Click "Fork" on GitHub to create your own copy.

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/vhkmsurabhi_flutter.git
   cd vhkmsurabhi_flutter
   ```
3. **Setup Project** (Recommended - using Makefile):
   ```bash
   make setup
   ```

   Or manually:
   ```bash
   # Install dependencies
   flutter pub get

   # Generate code
   flutter pub run build_runner build --delete-conflicting-outputs

   # Generate app assets
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

4. **Create a Feature Branch**:
   ```bash
   # For new features
   git checkout -b feature/your-feature-name

   # For bug fixes
   git checkout -b bugfix/issue-description

   # For documentation
   git checkout -b docs/update-description
   ```

5. **Development Workflow**:
   ```bash
   # Start development server
   make dev
   # or
   make run

   # Run on specific platform
   make run-android
   make run-ios
   make run-web
   ```

6. **Code Quality Checks**:
   ```bash
   # Format code
   make format

   # Analyze code
   make analyze

   # Run tests
   make test
   ```

7. **Follow Project Standards**:
   - Use Clean Architecture principles
   - Follow the existing folder structure
   - Write meaningful commit messages
   - Add tests for new features
   - Update documentation when needed

8. **Commit Your Changes**:
   ```bash
   # Stage your changes
   git add .

   # Commit with conventional message format
   git commit -m "feat: add user registration feature"
   git commit -m "fix: resolve login authentication issue"
   git commit -m "docs: update API documentation"

   # Push to your fork
   git push origin feature/your-feature-name
   ```

9. **Open a Pull Request**:
   - Target the `main` branch (or `develop` if specified)
   - Use the PR template if available
   - Provide clear description of changes
   - Reference related issues: `Fixes #123`, `Closes #456`
   - Add screenshots for UI changes
   - Ensure all CI checks pass

---

## 📝 Code Style & Standards

### Dart/Flutter Guidelines
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` for consistent formatting (or `make format`)
- Prefer single quotes for strings
- Use meaningful variable and function names
- Keep functions small and focused (max 20-30 lines)

### Architecture Standards
- Follow Clean Architecture principles
- Use BLoC pattern for state management
- Implement proper error handling
- Write comprehensive tests for new features
- Document complex business logic

### File Organization
- Place files in appropriate feature folders
- Use consistent naming conventions (snake_case for files)
- Group related functionality together
- Keep shared code in the `core/` module

### Testing Requirements
- Write unit tests for business logic
- Add widget tests for UI components
- Ensure minimum 80% code coverage
- Test error scenarios and edge cases

---

## Reporting Bugs

If you find a bug, please [open an issue](https://github.com/praveenkumargurrala/vhkmsurabhi_flutter/issues) and include:

- Clear description of the bug
- Steps to reproduce
- Expected behavior
- Screenshots or error messages (if applicable)
- Environment details (OS, Python version, etc.)

---

## Feature Requests

We welcome new ideas! Open an issue describing:

- The problem your feature solves
- How you envision it working
- Any potential impact or considerations

---

## Pull Request Process

- All PRs must target the `develop` branch.
- Describe your changes clearly.
- Reference related issues.
- Ensure code passes all tests and lints.
- Do not commit generated or unrelated files.
- At least one maintainer approval is required before merging.
- All status checks must pass.
- Do not merge your own PRs without approval.
- Changes must be reviewed by code owners as specified in [CODEOWNERS](.github/CODEOWNERS).

---

Thank you for helping make Surabhi better!
