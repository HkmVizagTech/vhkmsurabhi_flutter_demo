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
      title: Text(titleText, style: Theme.of(context).appBarTheme.titleTextStyle),
      leading: onLeadingPressed != null
          ? IconButton(icon: const Icon(Icons.menu_rounded), onPressed: onLeadingPressed)
          : null, // Let AppBar decide if it should show back button
      actions: actions, // Dynamically populated actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}
