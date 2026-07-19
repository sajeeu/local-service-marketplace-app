import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';

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
    return AppScaffold(
      title: AppConfig.current.appName,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foundation ready',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Phase 0 bootstrap shell. Business features arrive in later phases.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
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
