# Role-Based Navigation System

## Overview
The Surabhi app implements a comprehensive role-based navigation system with customized drawer menus for different user roles. Each role has access to specific features while sharing common functionality.

## Drawer Structure

### Header Section
- **User Avatar**: Displays user.image if available, otherwise shows first letter of email
- **User Name**: Shows firstName + lastName if available, otherwise displays email
- **User Role**: Displays role in uppercase (ADMIN, EMPLOYEE, etc.)
- **Email**: Shows user's email address
- **Gradient Background**: Theme-aware gradient background

### Navigation Sections

#### 1. Dashboard (Common for All Roles)
- Always present for all authenticated users
- Navigates to role-specific dashboard

#### 2. Role-Specific Features

**Admin Role:**
- User Management (navigates to admin dashboard)
- Register User (navigates to create user page)

**Employee Role:**
- My Tasks (placeholder - shows "coming soon" message)

**Preacher Role:**
- Sermons (placeholder - shows "coming soon" message)

**Approver Role:**
- Pending Approvals (placeholder - shows "coming soon" message)

**Volunteer Role:**
- Activities (placeholder - shows "coming soon" message)

#### 3. Common Features (All Roles)
- Settings (navigates to settings page)
- Dark Mode Toggle (theme switcher)
- Logout (with confirmation dialog)

## Theme Toggle Functionality

### Fixed Implementation
- **Toggle Control**: Only the switch button on the right can toggle the theme
- **Disabled Tap**: The entire ListTile tap is disabled (`onTap: null`)
- **Visual Feedback**: Icon changes based on current theme (light_mode/dark_mode)
- **State Management**: Uses ThemeCubit for state management

### Theme States
- **Light Mode**: Shows light_mode icon, switch is OFF
- **Dark Mode**: Shows dark_mode icon, switch is ON
- **System Mode**: Follows system preference (handled by ThemeCubit)

## User Image Handling

### Image Priority
1. **Network Image**: If user.image is not null and not empty
2. **Fallback Avatar**: First letter of email in uppercase
3. **Error Fallback**: Question mark (?) if email is also empty

### Implementation
```dart
CircleAvatar(
  backgroundImage: user.image != null && user.image!.isNotEmpty 
      ? NetworkImage(user.image!) 
      : null,
  child: user.image == null || user.image!.isEmpty
      ? Text(user.email.isNotEmpty ? user.email[0].toUpperCase() : '?')
      : null,
)
```

## Navigation Behavior

### Drawer Closure
- All navigation actions automatically close the drawer first
- Prevents navigation while drawer is open

### Role-Based Routing
- Dashboard navigation routes to appropriate role-specific dashboard
- Feature navigation shows "coming soon" for placeholder features
- Admin features are fully functional

### Logout Confirmation
- Shows confirmation dialog before logout
- Prevents accidental logouts
- Provides clear feedback on successful logout

## Security Features

### Role Validation
- Drawer content is dynamically generated based on authenticated user's role
- No access to features outside user's role permissions
- Graceful handling of unauthenticated states

### State Management
- Uses BlocBuilder for reactive UI updates
- Automatically updates when auth state changes
- Handles authentication state transitions

## Responsive Design

### Text Overflow
- User name and email use ellipsis for long text
- Maintains layout integrity on smaller screens

### Theme Awareness
- Drawer header uses theme-aware gradient
- Icons and colors adapt to current theme
- Consistent with app's overall design system

## Future Enhancements

### Planned Features
- Badge notifications for role-specific items
- Quick actions in drawer header
- User profile editing from drawer
- Role-specific shortcuts

### Placeholder Integration
- Task management for employees
- Sermon management for preachers
- Approval workflows for approvers
- Activity management for volunteers

## Implementation Benefits

1. **User Experience**: Personalized navigation based on role
2. **Security**: Role-based access control
3. **Maintainability**: Modular, role-specific components
4. **Scalability**: Easy to add new roles and features
5. **Consistency**: Unified navigation pattern across roles
