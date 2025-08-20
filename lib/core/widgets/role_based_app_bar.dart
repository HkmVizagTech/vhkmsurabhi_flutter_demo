// lib/core/widgets/role_based_app_bar.dart
import 'package:flutter/material.dart';

class RoleBasedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final List<Widget> actions; // Dynamic actions based on role
  final VoidCallback? onLeadingPressed; // Optional for a custom leading icon action

  const RoleBasedAppBar({
    super.key,
    required this.titleText,
    this.actions = const [], // Default to empty list
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          // Constant Icon
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.apps, color: Colors.white), // Your common app icon
          ),
          // Constant App Name
          Text(
            titleText, // This can also be a constant like 'My App'
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Use theme color
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor, // Use theme color
      elevation: Theme.of(context).appBarTheme.elevation, // Use theme elevation
      // Optional: Custom leading widget if needed, otherwise default back button
      leading: onLeadingPressed != null
          ? IconButton(
              icon: const Icon(Icons.menu), // Example: a menu icon for a drawer
              onPressed: onLeadingPressed,
            )
          : null, // Let AppBar decide if it should show back button
      actions: actions, // Dynamically populated actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}
