import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/state/session_provider.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
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
  bool _loading = false;

  Future<void> _checkHealth() async {
    setState(() => _loading = true);
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
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value;
    final email = session?.user?.email;
    final providerProfile = ref.watch(providerProfileProvider);
    final customerProfile = ref.watch(customerProfileProvider);

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
          Text(
            'Marketplace profiles',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            email == null ? 'Signed in.' : 'Signed in as $email',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Customer profile',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          customerProfile.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => TextButton(
              onPressed: () =>
                  ref.read(customerProfileProvider.notifier).refresh(),
              child: const Text('Retry customer profile'),
            ),
            data: (profile) => FilledButton(
              onPressed: () => context.go(
                profile == null
                    ? AppRoutes.customerProfileCreate
                    : AppRoutes.customerProfile,
              ),
              child: Text(
                profile == null
                    ? 'Create customer profile'
                    : 'View customer profile',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Provider profile',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          providerProfile.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => TextButton(
              onPressed: () =>
                  ref.read(providerProfileProvider.notifier).refresh(),
              child: const Text('Retry provider profile'),
            ),
            data: (profile) => FilledButton(
              onPressed: () => context.go(
                profile == null
                    ? AppRoutes.providerProfileCreate
                    : AppRoutes.providerProfile,
              ),
              child: Text(
                profile == null
                    ? 'Create provider profile'
                    : 'View provider profile',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton(
            onPressed: _loading ? null : _checkHealth,
            child: Text(_loading ? 'Checking…' : 'Check API health'),
          ),
          if (_healthStatus != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text('API health: $_healthStatus'),
          ],
        ],
      ),
    );
  }
}
