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
  late final TapGestureRecognizer _loginRecognizer;
  late final TapGestureRecognizer _supportRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _loginRecognizer = TapGestureRecognizer()
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
    _loginRecognizer.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back to sign in',
                    onPressed: _submitting
                        ? null
                        : () => context.go(AppRoutes.login),
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
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                "Don't worry! It happens. Please enter the email address associated with your account.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AuthFieldLabel('Email Address'),
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
                  prefixIcon: const Icon(
                    Icons.mail_outline,
                    color: AppColors.primary,
                    size: 22,
                  ),
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
                "We'll send a secure link to reset your password.",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
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
                child: _submitting
                    ? const Text(
                        'Sending…',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Send Reset Link',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Divider(height: 1, color: AppColors.outline),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: 'Remembered your password? '),
                      TextSpan(
                        text: 'Login here',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: _loginRecognizer,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(
                        text: 'Contact Support',
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
    );
  }
}
