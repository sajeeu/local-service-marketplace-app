import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/profile_avatar_placeholder.dart';
import 'package:frontend/features/customers/state/customer_profile_provider.dart';
import 'package:go_router/go_router.dart';

class ViewCustomerProfileScreen extends ConsumerWidget {
  const ViewCustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(customerProfileProvider);

    return AppScaffold(
      title: 'Customer profile',
      actions: [
        IconButton(
          tooltip: 'Home',
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.home_outlined),
        ),
      ],
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.read(customerProfileProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No customer profile yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () =>
                        context.go(AppRoutes.customerProfileCreate),
                    child: const Text('Create customer profile'),
                  ),
                ],
              ),
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
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Status: ${profile.status}'),
              Text(
                'Completion: ${profile.completion.status} (${profile.completion.percent}%)',
              ),
              if (profile.contactEmail != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Email: ${profile.contactEmail}'),
              ],
              if (profile.contactPhone != null)
                Text('Phone: ${profile.contactPhone}'),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => context.go(AppRoutes.customerProfileEdit),
                child: const Text('Edit profile'),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (profile.isActive)
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(customerProfileProvider.notifier)
                        .deactivate();
                    final state = ref.read(customerProfileProvider);
                    if (state.hasError && context.mounted) {
                      ErrorFeedback.showSnackBar(context, state.error!);
                    }
                  },
                  child: const Text('Deactivate'),
                )
              else
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(customerProfileProvider.notifier).restore();
                    final state = ref.read(customerProfileProvider);
                    if (state.hasError && context.mounted) {
                      ErrorFeedback.showSnackBar(context, state.error!);
                    }
                  },
                  child: const Text('Restore'),
                ),
            ],
          );
        },
      ),
    );
  }
}
