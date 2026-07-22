import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/async_body.dart';
import 'package:frontend/core/widgets/empty_state.dart';
import 'package:frontend/core/widgets/primary_async_button.dart';
import 'package:frontend/core/widgets/profile_avatar_placeholder.dart';
import 'package:frontend/core/widgets/section_header.dart';
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
      maxContentWidth: AppLayout.formMaxWidth,
      body: AsyncBody(
        isLoading: asyncProfile.isLoading && !_initialized,
        error: asyncProfile.hasError && !_initialized
            ? asyncProfile.error
            : null,
        onRetry: () => ref.read(providerProfileProvider.notifier).refresh(),
        builder: () {
          final profile = asyncProfile.value;
          if (profile == null) {
            return EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No provider profile yet',
              message: 'Create a provider profile before editing.',
              actionLabel: 'Create provider profile',
              onAction: () => context.go(AppRoutes.providerProfileCreate),
            );
          }
          _ensureControllers(profile);
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'Business identity',
                    subtitle:
                        'Update how your business appears on the marketplace.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _displayNameController,
                      builder: (context, value, _) {
                        return ProfileAvatarPlaceholder(
                          displayName: value.text,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _displayNameController,
                    enabled: !_submitting,
                    textInputAction: TextInputAction.next,
                    decoration:
                        const InputDecoration(labelText: 'Display name'),
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
                    enabled: !_submitting,
                    textInputAction: TextInputAction.next,
                    decoration:
                        const InputDecoration(labelText: 'Business name'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !_submitting,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Contact'),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _contactEmailController,
                    enabled: !_submitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration:
                        const InputDecoration(labelText: 'Contact email'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _contactPhoneController,
                    enabled: !_submitting,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration:
                        const InputDecoration(labelText: 'Contact phone'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _websiteUrlController,
                    enabled: !_submitting,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration:
                        const InputDecoration(labelText: 'Website URL'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _logoUrlController,
                    enabled: !_submitting,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Logo URL'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Languages & visibility'),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _languagesController,
                    enabled: !_submitting,
                    decoration: const InputDecoration(
                      labelText: 'Languages (comma-separated)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Public profile'),
                    subtitle: const Text(
                      'Allow others to view this provider profile',
                    ),
                    value: _visibility == 'PUBLIC',
                    onChanged: _submitting
                        ? null
                        : (value) {
                            setState(
                              () =>
                                  _visibility = value ? 'PUBLIC' : 'PRIVATE',
                            );
                          },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryAsyncButton(
                    label: 'Save changes',
                    busyLabel: 'Saving…',
                    isBusy: _submitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
