# Surabhi App Folder Structure

## Overview
This document outlines the folder structure and naming conventions for the Surabhi Flutter application, following Clean Architecture principles with role-based feature organization.

## Root Structure
```
lib/
├── assets/                # Static assets (fonts, icons, images, logos)
├── core/                  # Shared core functionality
├── features/              # Feature-based modules organized by user roles
├── routes/                # App routing and navigation
├── injector.dart          # Dependency injection setup
└── main.dart              # App entry point
```

## Core Structure
```
lib/core/
├── constants/            # App-wide constants (API endpoints, roles, etc.)
├── data/                 # Shared data models and responses
│   └── models/           # Generic models (PaginatedResponse, UserModel)
├── domain/               # Shared domain entities
│   └── entities/         # Core entities (UserEntity)
├── errors/               # Error handling (exceptions, failures)
├── network/              # Network layer (API client, interceptors)
├── shared_preferences/   # Local storage service
├── theme/                # App theming (colors, themes, theme cubit)
├── usecases/             # Base use case classes
├── utils/                # Utility functions and validators
└── widgets/              # Reusable UI components
```

## Feature Structure (Role-Based)
Each role has its own feature folder following Clean Architecture:

```
lib/features/
├── admin/              # Admin-specific features
│   ├── dashboard/      # Admin dashboard
│   └── users/          # User management
├── employee/           # Employee-specific features
│   ├── dashboard/      # Employee dashboard
│   └── tasks/          # Task management (placeholder)
├── preacher/           # Preacher-specific features
│   ├── dashboard/      # Preacher dashboard
│   └── sermons/        # Sermon management (placeholder)
├── approver/           # Approver-specific features
│   ├── dashboard/      # Approver dashboard
│   └── approvals/      # Approval workflows (placeholder)
├── volunteer/          # Volunteer-specific features
│   ├── dashboard/      # Volunteer dashboard
│   └── activities/     # Activity management (placeholder)
├── auth/               # Authentication (shared across roles)
├── home/               # Home/landing pages
└── settings/           # App settings
```

## Clean Architecture Pattern
Each feature follows the Clean Architecture pattern:

```
feature_name/
├── data/
│   ├── datasources/     # Remote/local data sources
│   ├── models/          # Data models with JSON serialization
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
└── presentation/
    ├── bloc/            # State management (BLoC)
    ├── pages/           # UI pages/screens
    └── widgets/         # Feature-specific widgets
```

## Naming Conventions

### Files
- **Snake_case**: `user_details_page.dart`, `users_bloc.dart`
- **Descriptive names**: Include the type in the filename
  - Pages: `*_page.dart`
  - BLoCs: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
  - Models: `*_model.dart`
  - Entities: `*_entity.dart`
  - Use cases: `*_usecase.dart`

### Classes
- **PascalCase**: `UserDetailsPage`, `UsersBloc`
- **Descriptive names**: Include the type in the class name

### Folders
- **Lowercase with underscores**: `user_management`, `task_tracking`
- **Plural for collections**: `users`, `tasks`, `approvals`
- **Singular for single concepts**: `dashboard`, `auth`

## Validators Location
Validators are correctly placed in `lib/core/utils/validators.dart` as they are:
- Shared across multiple features
- Pure utility functions
- Not feature-specific business logic

## Role-Based Organization Benefits

1. **Separation of Concerns**: Each role has its own feature space
2. **Scalability**: Easy to add new features per role
3. **Maintainability**: Clear boundaries between role responsibilities
4. **Team Development**: Different teams can work on different roles
5. **Security**: Role-based access control is naturally enforced

## Future Expansion
Placeholder folders are created for future features:
- Employee tasks management
- Preacher sermon management
- Approver approval workflows
- Volunteer activity management

Each placeholder contains a `.gitkeep` file to maintain the folder structure in version control.

## Best Practices

1. **Feature Independence**: Each feature should be self-contained
2. **Shared Code**: Common functionality goes in `core/`
3. **Clean Architecture**: Maintain data/domain/presentation separation
4. **Consistent Naming**: Follow established naming conventions
5. **Role Separation**: Keep role-specific features isolated
6. **Documentation**: Update this document when adding new features
