import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/primary_async_button.dart';
import 'package:frontend/core/widgets/profile_avatar_placeholder.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/customers/data/customer_profile_models.dart';
import 'package:frontend/features/customers/state/customer_profile_provider.dart';
import 'package:go_router/go_router.dart';

class CreateCustomerProfileScreen extends ConsumerStatefulWidget {
  const CreateCustomerProfileScreen({super.key});

  @override
  ConsumerState<CreateCustomerProfileScreen> createState() =>
      _CreateCustomerProfileScreenState();
}

class _CreateCustomerProfileScreenState
    extends ConsumerState<CreateCustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  var _submitting = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(customerProfileProvider.notifier).create(
            CreateCustomerProfileInput(
              displayName: _displayNameController.text.trim(),
              contactEmail: _optional(_contactEmailController),
              contactPhone: _optional(_contactPhoneController),
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

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create customer profile',
      maxContentWidth: AppLayout.formMaxWidth,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: 'Customer identity',
                subtitle:
                    'Separate from your login account and from provider profiles.',
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
                controller: _contactEmailController,
                enabled: !_submitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Contact email'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _contactPhoneController,
                enabled: !_submitting,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Contact phone'),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryAsyncButton(
                label: 'Create profile',
                busyLabel: 'Creating…',
                isBusy: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
