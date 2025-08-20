# Surabhi Architecture Documentation

## 🏗️ Architecture Overview

Surabhi follows a **Feature-First Clean Architecture** approach, combining the benefits of Clean Architecture with role-based feature organization. This design ensures:

### Core Principles
- **🔧 Modularity**: Each feature is self-contained and independent
- **📈 Scalability**: New features can be added without affecting existing ones
- **🧪 Testability**: Each layer can be tested in isolation
- **🔒 Security**: Role-based access control built into the architecture
- **🎯 Maintainability**: Clear separation of concerns and responsibilities

### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  (UI, BLoC, Pages, Widgets, User Interaction)             │
├─────────────────────────────────────────────────────────────┤
│                     Domain Layer                            │
│     (Business Logic, Entities, Use Cases, Repositories)    │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                             │
│   (API Clients, Models, Repository Implementations)        │
└─────────────────────────────────────────────────────────────┘
```

### Project Structure
- **`core/`**: Shared functionality and infrastructure
- **`features/`**: Role-based feature modules (admin, employee, preacher, etc.)
- **`routes/`**: Navigation and routing logic

## 🔧 Core Components

The `core/` module provides the foundation for the entire application, containing shared functionality and infrastructure.

### 🌐 Network Layer

#### ApiClient (`core/network/api_client.dart`)
- **Purpose**: Primary HTTP client using Dio package
- **Configuration**: Singleton instance with base URL, timeouts, and headers
- **Features**:
  - Request/response logging with PrettyDioLogger
  - Automatic content-type handling
  - Timeout configuration (30s connect/send/receive)

#### ApiInterceptor (`core/network/api_interceptor.dart`)
- **Authentication**: Automatically adds JWT tokens to requests
- **Token Refresh**: Handles 401 errors by refreshing tokens automatically
- **Error Handling**: Converts HTTP errors to domain-specific exceptions
- **Security**: Manages token lifecycle and secure storage

### 💾 Storage Layer

#### PreferencesService (`core/shared_preferences/preferences_service.dart`)
- **Secure Storage**: Uses FlutterSecureStorage for sensitive data (tokens)
- **Shared Preferences**: Uses SharedPreferences for non-sensitive data (theme, user info)
- **Data Separation**: Clear distinction between secure and non-secure storage
- **Platform Security**: Leverages platform-specific encryption

### 🎯 Dependency Injection

#### Injector (`injector.dart`)
- **Container**: Uses GetIt for dependency management
- **Registration**: Services registered as singletons or factories
- **Lifecycle**: Proper dependency lifecycle management
- **Testing**: Easy mocking and testing support

### 🎨 Theme System

#### Theme Management
- **ThemeCubit**: BLoC-based theme state management
- **AppColors**: Centralized color definitions
- **AppThemes**: Light/dark theme configurations
- **Persistence**: Theme preference storage and restoration

## 3. Feature Structure
Each feature (e.g., `auth/`) adheres to the same layered structure:

- `data/`: Handles data retrieval and storage.

	- `datasources/`: Contains AuthRemoteDataSource for fetching data from the API and AuthLocalDataSource (if needed) for local persistence.

	- `models/`: Defines the data models (e.g., `AuthResponseModel`, `UserModel`) that represent the API response. These are classes specifically for serialization and deserialization of JSON data from the API. The `UserModel` extends `UserEntity`, blurring the line between models and entities to simplify the architecture.

	- `repositories/`: The implementation of the repository interface. It orchestrates data flow by calling data sources and converting low-level exceptions into high-level failures.

- `domain/`: The business logic layer, completely independent of any framework.

	- `entities/`: Defines the business objects (e.g., `UserEntity`).

	- `repositories/`: Defines the abstract repository interfaces, which act as a contract for the data layer.

	- `usecases/`: Encapsulates specific business logic (e.g., `LoginUseCase`).

- `presentation/`: The user-facing layer.

	- `bloc/`: Contains the business logic components (e.g., `AuthBloc`) that manage the state for the UI.

	- `pages/`: The UI widgets and screens.

This project's architecture promotes a clear separation of concerns, making the codebase maintainable, scalable, and easy to navigate for any developer.