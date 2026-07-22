import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/providers/state/provider_profile_provider.dart';
import 'package:go_router/go_router.dart';

class ViewProviderProfileScreen extends ConsumerWidget {
  const ViewProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(providerProfileProvider);

    return AppScaffold(
      title: 'Provider profile',
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
                    ref.read(providerProfileProvider.notifier).refresh(),
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
                    'No provider profile yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () =>
                        context.go(AppRoutes.providerProfileCreate),
                    child: const Text('Create provider profile'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: [
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Status: ${profile.status}'),
              Text('Visibility: ${profile.visibility}'),
              Text(
                'Completion: ${profile.completion.status} (${profile.completion.percent}%)',
              ),
              if (profile.businessName != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Business: ${profile.businessName}'),
              ],
              if (profile.description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(profile.description!),
              ],
              if (profile.contactEmail != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Email: ${profile.contactEmail}'),
              ],
              if (profile.contactPhone != null)
                Text('Phone: ${profile.contactPhone}'),
              if (profile.websiteUrl != null)
                Text('Website: ${profile.websiteUrl}'),
              if (profile.languages.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('Languages: ${profile.languages.join(', ')}'),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => context.go(AppRoutes.providerProfileEdit),
                child: const Text('Edit profile'),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (profile.isActive)
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(providerProfileProvider.notifier)
                        .deactivate();
                    final state = ref.read(providerProfileProvider);
                    if (state.hasError && context.mounted) {
                      ErrorFeedback.showSnackBar(context, state.error!);
                    }
                  },
                  child: const Text('Deactivate'),
                )
              else
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(providerProfileProvider.notifier).restore();
                    final state = ref.read(providerProfileProvider);
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
