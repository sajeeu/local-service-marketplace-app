import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/auth_form_controls.dart';
import 'package:go_router/go_router.dart';

/// Set a new password after requesting a reset (UI flow until API exists).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({this.email, super.key});

  final String? email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _submitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    // Frontend-only until a password-reset API exists.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    context.go(AppRoutes.passwordResetSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email?.trim();
    final subtitle = (email == null || email.isEmpty)
        ? 'Choose a new password for your account.'
        : 'Choose a new password for $email.';

    return AppScaffold(
      title: 'Reset password',
      showAppBar: false,
      maxContentWidth: AppLayout.formMaxWidth,
      horizontalPadding: AppSpacing.lg,
      body: Form(
        key: _formKey,
        child: AutofillGroup(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                AuthBackBrandHeader(
                  backTooltip: 'Back',
                  onBack: _submitting
                      ? null
                      : () => context.go(AppRoutes.forgotPassword),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, color: AppColors.outline),
                const SizedBox(height: AppSpacing.lg),
                AuthHeroBanner.passwordRecovery(),
                const SizedBox(height: AppSpacing.lg),
                const AuthPageTitle('Reset password'),
                const SizedBox(height: AppSpacing.sm),
                AuthPageSubtitle(subtitle),
                const SizedBox(height: AppSpacing.lg),
                const AuthFieldLabel('New password', required: true),
                const SizedBox(height: AppSpacing.sm),
                AuthPasswordField(
                  controller: _passwordController,
                  enabled: !_submitting,
                  hintText: 'Create a new password',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ListenableBuilder(
                  listenable: _passwordController,
                  builder: (context, _) {
                    return PasswordStrengthMeter(
                      password: _passwordController.text,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const AuthFieldLabel('Confirm password', required: true),
                const SizedBox(height: AppSpacing.sm),
                AuthPasswordField(
                  controller: _confirmPasswordController,
                  enabled: !_submitting,
                  hintText: 'Re-enter your password',
                  prefixIcon: Icons.verified_user_outlined,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) {
                    if (!_submitting) {
                      _submit();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthPrimaryButton(
                  label: 'Update password',
                  loadingLabel: 'Updating…',
                  loading: _submitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
