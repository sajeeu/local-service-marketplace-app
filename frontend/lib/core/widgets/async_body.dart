import 'package:flutter/material.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';

/// Standard loading / error / data body for async screens.
class AsyncBody extends StatelessWidget {
  const AsyncBody({
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.builder,
    super.key,
  });

  final bool isLoading;
  final Object? error;
  final VoidCallback onRetry;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Semantics(
          label: 'Loading',
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                ErrorFeedback.messageOf(error!),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return builder();
  }
}
