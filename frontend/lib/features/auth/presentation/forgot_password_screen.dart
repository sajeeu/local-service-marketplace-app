import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/auth_form_controls.dart';
import 'package:go_router/go_router.dart';

/// Request a password reset email (UI flow; backend endpoint not yet available).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  var _submitting = false;
  late final TapGestureRecognizer _signInRecognizer;
  late final TapGestureRecognizer _supportRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _signInRecognizer = TapGestureRecognizer()
      ..onTap = () {
        if (!_submitting) {
          context.go(AppRoutes.login);
        }
      };
    _supportRecognizer = TapGestureRecognizer()
      ..onTap = () => _showComingSoon('Support');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _showComingSoon('Privacy Policy');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _signInRecognizer.dispose();
    _supportRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature is coming soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    context.go(
      AppRoutes.resetPassword,
      extra: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Forgot password',
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
                  backTooltip: 'Back to sign in',
                  onBack: _submitting
                      ? null
                      : () => context.go(AppRoutes.login),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, color: AppColors.outline),
                const SizedBox(height: AppSpacing.lg),
                AuthHeroBanner.passwordRecovery(),
                const SizedBox(height: AppSpacing.lg),
                const AuthPageTitle('Forgot password?'),
                const SizedBox(height: AppSpacing.sm),
                const AuthPageSubtitle(
                  "Enter the email linked to your account and we'll send a "
                  'secure link to reset your password.',
                ),
                const SizedBox(height: AppSpacing.lg),
                const AuthFieldLabel('Email address', required: true),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _emailController,
                  enabled: !_submitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) {
                    if (!_submitting) {
                      _submit();
                    }
                  },
                  decoration: authInputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: const AuthFieldIcon(Icons.mail_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'For your security, the reset link expires after a short time.',
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthPrimaryButton(
                  label: 'Send reset link',
                  loadingLabel: 'Sending…',
                  loading: _submitting,
                  showTrailingArrow: true,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(height: 1, color: AppColors.outline),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.bodySmall,
                      children: [
                        const TextSpan(text: 'Remembered your password? '),
                        TextSpan(
                          text: 'Sign in',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: _signInRecognizer,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.labelSmall,
                      children: [
                        TextSpan(
                          text: 'Contact support',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          recognizer: _supportRecognizer,
                        ),
                        const TextSpan(text: '  ·  '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          recognizer: _privacyRecognizer,
                        ),
                      ],
                    ),
                  ),
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
