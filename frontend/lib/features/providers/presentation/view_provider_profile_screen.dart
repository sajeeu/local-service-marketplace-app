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
import 'package:frontend/features/providers/state/provider_coverage_provider.dart';
import 'package:frontend/features/providers/state/provider_profile_provider.dart';
import 'package:go_router/go_router.dart';

class ViewProviderProfileScreen extends ConsumerWidget {
  const ViewProviderProfileScreen({super.key});

  Future<void> _deactivate(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Deactivate provider profile?',
      message:
          'Your provider profile will be deactivated and hidden from discovery. You can restore it later.',
    );
    if (!confirmed) {
      return;
    }
    await ref.read(providerProfileProvider.notifier).deactivate();
    final state = ref.read(providerProfileProvider);
    if (state.hasError && context.mounted) {
      ErrorFeedback.showSnackBar(context, state.error!);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    await ref.read(providerProfileProvider.notifier).restore();
    final state = ref.read(providerProfileProvider);
    if (state.hasError && context.mounted) {
      ErrorFeedback.showSnackBar(context, state.error!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(providerProfileProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Provider profile',
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
        onRetry: () => ref.read(providerProfileProvider.notifier).refresh(),
        builder: () {
          final profile = asyncProfile.value;
          if (profile == null) {
            return EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No provider profile yet',
              message:
                  'Create a provider profile to offer services on the marketplace.',
              actionLabel: 'Create provider profile',
              onAction: () => context.go(AppRoutes.providerProfileCreate),
            );
          }

          final avatarName = profile.businessName?.trim().isNotEmpty == true
              ? profile.businessName
              : profile.displayName;

          return ListView(
            children: [
              Center(
                child: ProfileAvatarPlaceholder(displayName: avatarName),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                profile.displayName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              if (profile.businessName != null &&
                  profile.businessName!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.businessName!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  StatusChip.profileStatus(profile.status),
                  StatusChip.visibility(profile.visibility),
                  StatusChip.completion(
                    status: profile.completion.status,
                    percent: profile.completion.percent,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              if (profile.description != null &&
                  profile.description!.trim().isNotEmpty)
                ProfileFieldRow(
                  label: 'About',
                  value: profile.description!,
                  icon: Icons.info_outline,
                ),
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
              if (profile.websiteUrl != null)
                ProfileFieldRow(
                  label: 'Website',
                  value: profile.websiteUrl!,
                  icon: Icons.language_outlined,
                ),
              if (profile.languages.isNotEmpty)
                ProfileFieldRow(
                  label: 'Languages',
                  value: profile.languages.join(', '),
                  icon: Icons.translate_outlined,
                ),
              const SizedBox(height: AppSpacing.md),
              const _CoverageSummarySection(),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => context.go(AppRoutes.providerProfileEdit),
                child: const Text('Edit profile'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.providerProfileCoverage),
                child: const Text('Edit service areas'),
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

class _CoverageSummarySection extends ConsumerWidget {
  const _CoverageSummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverageAsync = ref.watch(providerCoverageProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Service areas', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        coverageAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(
            ErrorFeedback.messageOf(error),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          data: (coverage) {
            if (coverage == null || coverage.islands.isEmpty) {
              return Text(
                'No service areas selected yet.',
                style: theme.textTheme.bodyMedium,
              );
            }
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: coverage.islands
                  .map(
                    (island) => Chip(
                      label: Text(
                        island.atollCode != null
                            ? '${island.name} (${island.atollCode})'
                            : island.name,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
