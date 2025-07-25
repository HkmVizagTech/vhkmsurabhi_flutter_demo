# Contributing to Surabhi

Thank you for your interest in contributing to the Surabhi Flutter project!  
Please follow these guidelines to help us maintain a high-quality codebase and smooth collaboration.

---

## Getting Started

### Prerequisites

- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Git**: For cloning the repository
- **Android Studio** or **VS Code**: With Flutter and Dart plugins

### Installation

1. **Fork the Repository**
   - Click "Fork" on GitHub to create your own copy.

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/vhkmsurabhi_flutter.git
   cd vhkmsurabhi_flutter
   ```
3. **Install dependencies**:
    ```bash
    flutter pub get
    ```

4. **Create a new branch** for your feature or bugfix:
     - For features:
     ```bash
     git checkout -b feature/your-feature-name
     ```
   - For bug fixes:
     ```bash
     git checkout -b bugfix/issue-description
     ```

5. **Make Your Changes**
   - Follow Dart and Flutter style guidelines.
   - Write clear comments where needed.

6. **Write and Run Tests**
   - Add unit/integration tests for your changes.
   - Run all tests before committing:
     ```bash
     flutter test
     ```
7. **Check code style**
    ```bash
    flutter analyze
    ```

8. **Commit and Push**
   - Use clear, conventional commit messages (e.g., `feat: add user registration`, `fix: resolve login issue`).
   - Push your branch:
     ```bash
     git push origin feature/your-feature-name
     ```

9. **Open a Pull Request**
   - Target the `develop` branch.
   - Provide a detailed description and reference related issues (e.g., `Fixes #123`).

---

## Code Style

- Follow Dart and Flutter best practices.
- Use descriptive variable and function names.
- Write unit tests for new features and bug fixes.
- Keep functions and files small and focused.

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
- Changes to `lib/` must be reviewed by code owners as specified in [CODEOWNERS](.github/CODEOWNERS).

---

Thank you for helping make Surabhi better!