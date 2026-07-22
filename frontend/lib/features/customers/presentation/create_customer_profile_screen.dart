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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Customer identity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Separate from your login account and from provider profiles.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
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
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Contact email'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _contactPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Contact phone'),
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
