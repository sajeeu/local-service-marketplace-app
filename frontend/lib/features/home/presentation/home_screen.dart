import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/state/session_provider.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/profile_role_card.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/core/widgets/status_chip.dart';
import 'package:frontend/features/customers/state/customer_profile_provider.dart';
import 'package:frontend/features/providers/state/provider_profile_provider.dart';
import 'package:go_router/go_router.dart';

/// Bootstrap home shell — not a business feature screen.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _healthStatus;
  bool _loadingHealth = false;

  Future<void> _checkHealth() async {
    setState(() => _loadingHealth = true);
    try {
      final client = ref.read(apiClientProvider);
      final envelope = await client.get<Map<String, dynamic>>(
        '/health',
        parseData: (raw) =>
            raw is Map<String, dynamic> ? raw : <String, dynamic>{},
        skipAuth: true,
      );
      setState(() {
        _healthStatus = envelope.data?['status']?.toString() ?? 'unknown';
      });
    } catch (error) {
      if (mounted) {
        ErrorFeedback.showSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingHealth = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value;
    final email = session?.user?.email;
    final providerProfile = ref.watch(providerProfileProvider);
    final customerProfile = ref.watch(customerProfileProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: AppConfig.current.appName,
      actions: [
        IconButton(
          tooltip: 'Sign out',
          onPressed: () => ref.read(sessionProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: ListView(
        children: [
          SectionHeader(
            title: email == null ? 'Welcome' : 'Welcome back',
            subtitle: email == null
                ? 'Manage your marketplace profiles.'
                : 'Signed in as $email',
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileRoleCard(
            title: 'Customer profile',
            description:
                'Book local services and manage your customer identity.',
            icon: Icons.person_outline,
            isLoading: customerProfile.isLoading,
            hasError: customerProfile.hasError,
            onRetry: () =>
                ref.read(customerProfileProvider.notifier).refresh(),
            statusChip: customerProfile.whenOrNull(
              data: (profile) => profile == null
                  ? StatusChip.missing()
                  : StatusChip.profileStatus(profile.status),
            ),
            actionLabel: customerProfile.asData?.value == null
                ? 'Create customer profile'
                : 'View customer profile',
            onAction: () {
              final profile = customerProfile.asData?.value;
              context.go(
                profile == null
                    ? AppRoutes.customerProfileCreate
                    : AppRoutes.customerProfile,
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileRoleCard(
            title: 'Provider profile',
            description:
                'Offer services and manage your business marketplace identity.',
            icon: Icons.storefront_outlined,
            isLoading: providerProfile.isLoading,
            hasError: providerProfile.hasError,
            onRetry: () =>
                ref.read(providerProfileProvider.notifier).refresh(),
            statusChip: providerProfile.whenOrNull(
              data: (profile) => profile == null
                  ? StatusChip.missing()
                  : StatusChip.profileStatus(profile.status),
            ),
            actionLabel: providerProfile.asData?.value == null
                ? 'Create provider profile'
                : 'View provider profile',
            onAction: () {
              final profile = providerProfile.asData?.value;
              context.go(
                profile == null
                    ? AppRoutes.providerProfileCreate
                    : AppRoutes.providerProfile,
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: AppColors.outline.withValues(alpha: 0.6)),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loadingHealth ? null : _checkHealth,
              icon: _loadingHealth
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.monitor_heart_outlined, size: 18),
              label: Text(
                _loadingHealth ? 'Checking…' : 'Check API health',
              ),
            ),
          ),
          if (_healthStatus != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                'API health: $_healthStatus',
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
