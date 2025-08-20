// lib/core/widgets/error_display.dart

import 'package:flutter/material.dart';

class ErrorDisplay extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryButtonText;

  const ErrorDisplay({super.key, required this.message, this.onRetry, this.icon, this.retryButtonText});

  @override
  State<ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<ErrorDisplay> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying || widget.onRetry == null) return;

    setState(() => _isRetrying = true);

    // Add a small delay to show the loading state
    await Future.delayed(const Duration(milliseconds: 100));

    widget.onRetry!();

    // Reset the retry state after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon ?? Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.message,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isRetrying ? null : _handleRetry,
                icon: _isRetrying
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: Text(_isRetrying ? 'Retrying...' : (widget.retryButtonText ?? 'Retry')),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorSnackBar {
  static void show(BuildContext context, String message, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null ? SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: onRetry) : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
