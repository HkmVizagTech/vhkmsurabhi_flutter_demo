// lib/core/widgets/app_bottom_nav_item.dart
import 'package:flutter/material.dart';

/// One destination in AppScaffold's optional bottom navigation bar -
/// mirrors harekrishnavizag.org's mobile pattern (icon + label row, with
/// a trailing "More" that opens the full menu instead of navigating).
class AppBottomNavItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // ignored when isMore is true
  final bool isMore;

  const AppBottomNavItem({required this.icon, required this.label, this.onTap}) : isMore = false;

  const AppBottomNavItem.more({this.label = 'More', this.icon = Icons.menu_rounded})
      : onTap = null,
        isMore = true;
}
