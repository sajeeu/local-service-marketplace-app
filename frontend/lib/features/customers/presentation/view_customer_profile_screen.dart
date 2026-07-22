import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/async_body.dart';
import 'package:frontend/core/widgets/confirm_dialog.dart';
import 'package:frontend/core/widgets/empty_state.dart';
import 'package:frontend/core/widgets/profile_avatar_placeholder.dart';
import 'package:frontend/core/widgets/profile_field_row.dart';
import 'package:frontend/core/widgets/status_chip.dart';
import 'package:frontend/features/customers/state/customer_profile_provider.dart';
import 'package:go_router/go_router.dart';

class ViewCustomerProfileScreen extends ConsumerWidget {
  const ViewCustomerProfileScreen({super.key});

  Future<void> _deactivate(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Deactivate customer profile?',
      message:
          'Your customer profile will be deactivated. You can restore it later.',
    );
    if (!confirmed) {
      return;
    }
    await ref.read(customerProfileProvider.notifier).deactivate();
    final state = ref.read(customerProfileProvider);
    if (state.hasError && context.mounted) {
      ErrorFeedback.showSnackBar(context, state.error!);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    await ref.read(customerProfileProvider.notifier).restore();
    final state = ref.read(customerProfileProvider);
    if (state.hasError && context.mounted) {
      ErrorFeedback.showSnackBar(context, state.error!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(customerProfileProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Customer profile',
      actions: [
        IconButton(
          tooltip: 'Home',
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.home_outlined),
        ),
      ],
      body: AsyncBody(
        isLoading: asyncProfile.isLoading,
        error: asyncProfile.hasError ? asyncProfile.error : null,
        onRetry: () => ref.read(customerProfileProvider.notifier).refresh(),
        builder: () {
          final profile = asyncProfile.value;
          if (profile == null) {
            return EmptyState(
              icon: Icons.person_add_alt_1_outlined,
              title: 'No customer profile yet',
              message:
                  'Create a customer profile to book local services with a trusted identity.',
              actionLabel: 'Create customer profile',
              onAction: () => context.go(AppRoutes.customerProfileCreate),
            );
          }

          return ListView(
            children: [
              Center(
                child: ProfileAvatarPlaceholder(
                  displayName: profile.displayName,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                profile.displayName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  StatusChip.profileStatus(profile.status),
                  StatusChip.completion(
                    status: profile.completion.status,
                    percent: profile.completion.percent,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              if (profile.contactEmail != null)
                ProfileFieldRow(
                  label: 'Contact email',
                  value: profile.contactEmail!,
                  icon: Icons.email_outlined,
                ),
              if (profile.contactPhone != null)
                ProfileFieldRow(
                  label: 'Contact phone',
                  value: profile.contactPhone!,
                  icon: Icons.phone_outlined,
                ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => context.go(AppRoutes.customerProfileEdit),
                child: const Text('Edit profile'),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (profile.isActive)
                OutlinedButton(
                  onPressed: () => _deactivate(context, ref),
                  child: const Text('Deactivate'),
                )
              else
                OutlinedButton(
                  onPressed: () => _restore(context, ref),
                  child: const Text('Restore'),
                ),
            ],
          );
        },
      ),
    );
  }
}
