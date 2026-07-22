import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/status_chip.dart';

/// Marketplace role entry card used on the home hub.
class ProfileRoleCard extends StatelessWidget {
  const ProfileRoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    this.statusChip,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;
  final StatusChip? statusChip;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(description, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (isLoading)
              const LinearProgressIndicator()
            else if (hasError)
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              )
            else ...[
              if (statusChip != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: statusChip!,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
