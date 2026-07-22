import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/profile_avatar_placeholder.dart';
import 'package:frontend/features/customers/data/customer_profile_models.dart';
import 'package:frontend/features/customers/state/customer_profile_provider.dart';
import 'package:go_router/go_router.dart';

class EditCustomerProfileScreen extends ConsumerStatefulWidget {
  const EditCustomerProfileScreen({super.key});

  @override
  ConsumerState<EditCustomerProfileScreen> createState() =>
      _EditCustomerProfileScreenState();
}

class _EditCustomerProfileScreenState
    extends ConsumerState<EditCustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _contactPhoneController;
  var _initialized = false;
  var _submitting = false;

  @override
  void dispose() {
    if (_initialized) {
      _displayNameController.dispose();
      _contactEmailController.dispose();
      _contactPhoneController.dispose();
    }
    super.dispose();
  }

  void _ensureControllers(CustomerProfile profile) {
    if (_initialized) {
      return;
    }
    _displayNameController = TextEditingController(text: profile.displayName);
    _contactEmailController =
        TextEditingController(text: profile.contactEmail ?? '');
    _contactPhoneController =
        TextEditingController(text: profile.contactPhone ?? '');
    _initialized = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(customerProfileProvider.notifier).updateProfile(
            UpdateCustomerProfileInput(
              displayName: _displayNameController.text.trim(),
              contactEmail: _contactEmailController.text.trim(),
              contactPhone: _contactPhoneController.text.trim(),
            ),
          );
      final profile = ref.read(customerProfileProvider);
      if (profile.hasError && mounted) {
        ErrorFeedback.showSnackBar(context, profile.error!);
        return;
      }
      if (mounted) {
        context.go(AppRoutes.customerProfile);
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
    final asyncProfile = ref.watch(customerProfileProvider);

    return AppScaffold(
      title: 'Edit customer profile',
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: TextButton(
            onPressed: () =>
                ref.read(customerProfileProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: FilledButton(
                onPressed: () => context.go(AppRoutes.customerProfileCreate),
                child: const Text('Create customer profile'),
              ),
            );
          }
          _ensureControllers(profile);
          return Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: ProfileAvatarPlaceholder(
                    displayName: _displayNameController.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Display name is required';
                    }
                    return null;
                  },
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
