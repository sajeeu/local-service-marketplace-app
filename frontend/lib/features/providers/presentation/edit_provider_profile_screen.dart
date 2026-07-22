import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/providers/data/provider_profile_models.dart';
import 'package:frontend/features/providers/state/provider_profile_provider.dart';
import 'package:go_router/go_router.dart';

class EditProviderProfileScreen extends ConsumerStatefulWidget {
  const EditProviderProfileScreen({super.key});

  @override
  ConsumerState<EditProviderProfileScreen> createState() =>
      _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState
    extends ConsumerState<EditProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _websiteUrlController;
  late final TextEditingController _logoUrlController;
  late final TextEditingController _languagesController;
  late String _visibility;
  var _initialized = false;
  var _submitting = false;

  @override
  void dispose() {
    if (_initialized) {
      _displayNameController.dispose();
      _businessNameController.dispose();
      _descriptionController.dispose();
      _contactEmailController.dispose();
      _contactPhoneController.dispose();
      _websiteUrlController.dispose();
      _logoUrlController.dispose();
      _languagesController.dispose();
    }
    super.dispose();
  }

  void _ensureControllers(ProviderProfile profile) {
    if (_initialized) {
      return;
    }
    _displayNameController = TextEditingController(text: profile.displayName);
    _businessNameController =
        TextEditingController(text: profile.businessName ?? '');
    _descriptionController =
        TextEditingController(text: profile.description ?? '');
    _contactEmailController =
        TextEditingController(text: profile.contactEmail ?? '');
    _contactPhoneController =
        TextEditingController(text: profile.contactPhone ?? '');
    _websiteUrlController =
        TextEditingController(text: profile.websiteUrl ?? '');
    _logoUrlController = TextEditingController(text: profile.logoUrl ?? '');
    _languagesController =
        TextEditingController(text: profile.languages.join(', '));
    _visibility = profile.visibility;
    _initialized = true;
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
      await ref.read(providerProfileProvider.notifier).updateProfile(
            UpdateProviderProfileInput(
              displayName: _displayNameController.text.trim(),
              businessName: _businessNameController.text.trim(),
              description: _descriptionController.text.trim(),
              contactEmail: _contactEmailController.text.trim(),
              contactPhone: _contactPhoneController.text.trim(),
              websiteUrl: _websiteUrlController.text.trim(),
              logoUrl: _logoUrlController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final asyncProfile = ref.watch(providerProfileProvider);

    return AppScaffold(
      title: 'Edit provider profile',
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: TextButton(
            onPressed: () =>
                ref.read(providerProfileProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: FilledButton(
                onPressed: () => context.go(AppRoutes.providerProfileCreate),
                child: const Text('Create provider profile'),
              ),
            );
          }
          _ensureControllers(profile);
          return Form(
            key: _formKey,
            child: ListView(
              children: [
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
                  decoration:
                      const InputDecoration(labelText: 'Business name'),
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
                  decoration:
                      const InputDecoration(labelText: 'Contact email'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _contactPhoneController,
                  decoration:
                      const InputDecoration(labelText: 'Contact phone'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _websiteUrlController,
                  decoration: const InputDecoration(labelText: 'Website URL'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _logoUrlController,
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
                  subtitle:
                      const Text('Allow others to view this provider profile'),
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
                  child: Text(_submitting ? 'Saving…' : 'Save changes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
