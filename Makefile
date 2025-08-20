# Surabhi Flutter Project Makefile
# Supports Android, iOS, and Web platforms

FLUTTER_CMD = flutter
BUILD_RUNNER_CMD = $(FLUTTER_CMD) pub run build_runner build --delete-conflicting-outputs

# Default target - show help
.PHONY: help
help:
	@echo "🚀 Surabhi Flutter Project - Build Commands"
	@echo ""
	@echo "📦 Setup & Dependencies:"
	@echo "  make get              - Install Flutter dependencies"
	@echo "  make generate         - Generate code (JSON serialization, etc.)"
	@echo "  make assets           - Generate app icons and splash screens"
	@echo ""
	@echo "🏃 Development:"
	@echo "  make run              - Run app on connected device/emulator"
	@echo "  make run-android      - Run specifically on Android"
	@echo "  make run-ios          - Run specifically on iOS"
	@echo "  make run-web          - Run on web browser"
	@echo ""
	@echo "🏗️ Production Builds:"
	@echo "  make build-android    - Build Android APK"
	@echo "  make build-ios        - Build iOS IPA"
	@echo "  make build-web        - Build web application"
	@echo ""
	@echo "🧪 Quality & Testing:"
	@echo "  make test             - Run all tests"
	@echo "  make analyze          - Analyze code for issues"
	@echo "  make format           - Format Dart code"
	@echo "  make clean            - Clean build artifacts"

# Setup & Dependencies
.PHONY: get
get:
	@echo "📦 Installing Flutter dependencies..."
	$(FLUTTER_CMD) pub get

# Development - Run Commands
.PHONY: run run-android run-ios run-web
run: get generate
	@echo "🏃 Running application..."
	$(FLUTTER_CMD) run

run-android: get generate
	@echo "🤖 Running on Android..."
	$(FLUTTER_CMD) run -d android

run-ios: get generate
	@echo "🍎 Running on iOS..."
	$(FLUTTER_CMD) run -d ios

run-web: get generate
	@echo "🌐 Running on Web..."
	$(FLUTTER_CMD) run -d chrome

# Production Builds
.PHONY: build-android build-ios build-web
build-android: get generate assets
	@echo "🤖 Building Android APK..."
	$(FLUTTER_CMD) build apk --release
	@echo "✅ Android APK built successfully!"

build-ios: get generate assets
	@echo "🍎 Building iOS IPA..."
	$(FLUTTER_CMD) build ipa --release
	@echo "✅ iOS IPA built successfully!"

build-web: get generate assets
	@echo "🌐 Building Web application..."
	$(FLUTTER_CMD) build web --release
	@echo "✅ Web build completed successfully!"

# Code Generation
.PHONY: generate
generate:
	@echo "⚙️ Running code generation..."
	$(BUILD_RUNNER_CMD)
	@echo "✅ Code generation completed!"

# Asset Generation
.PHONY: assets
assets: get
	@echo "🎨 Generating app assets..."
	@echo "  📱 Generating launcher icons..."
	$(FLUTTER_CMD) pub run flutter_launcher_icons
	@echo "  🎬 Generating splash screens..."
	$(FLUTTER_CMD) pub run flutter_native_splash:create
	@echo "✅ All assets generated successfully!"

# Quality & Testing
.PHONY: test analyze format clean lint
test: get
	@echo "🧪 Running tests..."
	$(FLUTTER_CMD) test
	@echo "✅ All tests completed!"

analyze:
	@echo "🔍 Analyzing code..."
	$(FLUTTER_CMD) analyze
	@echo "✅ Code analysis completed!"

format:
	@echo "✨ Formatting code..."
	dart format lib/ test/
	@echo "✅ Code formatting completed!"

clean:
	@echo "🧹 Cleaning build artifacts..."
	$(FLUTTER_CMD) clean
	@echo "✅ Project cleaned!"

# Aliases
lint: analyze

# Development workflow
.PHONY: dev setup
setup: get generate assets
	@echo "🚀 Project setup completed! Ready for development."

dev: setup
	@echo "🏃 Starting development server..."
	$(FLUTTER_CMD) run
	