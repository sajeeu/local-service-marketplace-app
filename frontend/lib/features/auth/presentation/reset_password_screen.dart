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
  var _obscurePassword = true;
  var _obscureConfirm = true;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

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
    return AppScaffold(
      title: 'Reset password',
      showAppBar: false,
      maxContentWidth: AppLayout.formMaxWidth,
      horizontalPadding: AppSpacing.lg,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: _submitting
                        ? null
                        : () => context.go(AppRoutes.forgotPassword),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Expanded(child: AppBrandHeader()),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1, color: AppColors.outline),
              const SizedBox(height: AppSpacing.lg),
              AuthHeroBanner.passwordRecovery(),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.email == null || widget.email!.isEmpty
                    ? 'Choose a new password for your account.'
                    : 'Choose a new password for ${widget.email}.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AuthFieldLabel('New Password', required: true),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _passwordController,
                enabled: !_submitting,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                decoration: authInputDecoration(
                  hintText: 'Create a new password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: _submitting
                        ? null
                        : () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              PasswordStrengthMeter(password: _passwordController.text),
              const SizedBox(height: AppSpacing.md),
              const AuthFieldLabel('Confirm Password', required: true),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _confirmPasswordController,
                enabled: !_submitting,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_submitting) {
                    _submit();
                  }
                },
                decoration: authInputDecoration(
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
                  suffixIcon: IconButton(
                    tooltip:
                        _obscureConfirm ? 'Show password' : 'Hide password',
                    onPressed: _submitting
                        ? null
                        : () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
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
              FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  _submitting ? 'Updating…' : 'Update Password',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
