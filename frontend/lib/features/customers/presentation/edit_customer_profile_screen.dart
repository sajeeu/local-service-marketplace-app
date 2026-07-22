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
      maxContentWidth: AppLayout.formMaxWidth,
      body: AsyncBody(
        isLoading: asyncProfile.isLoading && !_initialized,
        error: asyncProfile.hasError && !_initialized
            ? asyncProfile.error
            : null,
        onRetry: () => ref.read(customerProfileProvider.notifier).refresh(),
        builder: () {
          final profile = asyncProfile.value;
          if (profile == null) {
            return EmptyState(
              icon: Icons.person_add_alt_1_outlined,
              title: 'No customer profile yet',
              message: 'Create a customer profile before editing.',
              actionLabel: 'Create customer profile',
              onAction: () => context.go(AppRoutes.customerProfileCreate),
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
                    title: 'Update your details',
                    subtitle: 'Keep your customer contact information current.',
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
                    textInputAction: TextInputAction.done,
                    decoration:
                        const InputDecoration(labelText: 'Contact phone'),
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
