// lib/core/utils/ui_utils.dart
import 'package:flutter/material.dart';

class UiUtils {
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: backgroundColor));
  }
}
