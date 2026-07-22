import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/providers/data/provider_profile_models.dart';
import 'package:frontend/features/providers/state/provider_profile_provider.dart';
import 'package:go_router/go_router.dart';

class CreateProviderProfileScreen extends ConsumerStatefulWidget {
  const CreateProviderProfileScreen({super.key});

  @override
  ConsumerState<CreateProviderProfileScreen> createState() =>
      _CreateProviderProfileScreenState();
}

class _CreateProviderProfileScreenState
    extends ConsumerState<CreateProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _languagesController = TextEditingController();
  var _visibility = 'PRIVATE';
  var _submitting = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _businessNameController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _websiteUrlController.dispose();
    _logoUrlController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final languages = _languagesController.text
          .split(',')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      await ref.read(providerProfileProvider.notifier).create(
            CreateProviderProfileInput(
              displayName: _displayNameController.text.trim(),
              businessName: _optional(_businessNameController),
              description: _optional(_descriptionController),
              contactEmail: _optional(_contactEmailController),
              contactPhone: _optional(_contactPhoneController),
              websiteUrl: _optional(_websiteUrlController),
              logoUrl: _optional(_logoUrlController),
              languages: languages,
              visibility: _visibility,
            ),
          );
      final profile = ref.read(providerProfileProvider);
      if (profile.hasError && mounted) {
        ErrorFeedback.showSnackBar(context, profile.error!);
        return;
      }
      if (mounted) {
        context.go(AppRoutes.providerProfile);
      }
    } catch (error) {
      if (mounted) {
        ErrorFeedback.showSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create provider profile',
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              'Business identity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This is your provider marketplace identity — not a service listing.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Display name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(labelText: 'Business name'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _contactEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Contact email'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _contactPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Contact phone'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _websiteUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Website URL'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _logoUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Logo URL'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _languagesController,
              decoration: const InputDecoration(
                labelText: 'Languages (comma-separated)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Public profile'),
              subtitle: const Text('Allow others to view this provider profile'),
              value: _visibility == 'PUBLIC',
              onChanged: _submitting
                  ? null
                  : (value) {
                      setState(
                        () => _visibility = value ? 'PUBLIC' : 'PRIVATE',
                      );
                    },
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Creating…' : 'Create profile'),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
