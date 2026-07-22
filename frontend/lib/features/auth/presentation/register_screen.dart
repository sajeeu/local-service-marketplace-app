import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/state/session_provider.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/auth_form_controls.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _obscurePassword = true;
  var _obscureConfirm = true;
  var _agreedToTerms = false;
  var _submitting = false;
  late final TapGestureRecognizer _logInRecognizer;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _logInRecognizer = TapGestureRecognizer()
      ..onTap = () {
        if (!_submitting) {
          context.go(AppRoutes.login);
        }
      };
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _showComingSoon('Terms of Service');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _showComingSoon('Privacy Policy');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _logInRecognizer.dispose();
    _termsRecognizer.dispose();
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
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please agree to the Terms of Service and Privacy Policy.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(sessionProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _displayNameController.text.trim(),
          );
      final session = ref.read(sessionProvider);
      if (session.hasError && mounted) {
        ErrorFeedback.showSnackBar(context, session.error!);
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
    final appName = AppConfig.current.appName;

    return AppScaffold(
      title: 'Create account',
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
              const AuthHeroBanner(),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Join $appName to find and book trusted professionals in your neighborhood.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AuthFieldLabel('Full Name', required: true),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _displayNameController,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: authInputDecoration(
                  hintText: 'John Doe',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const AuthFieldLabel('Email Address', required: true),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _emailController,
                enabled: !_submitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: authInputDecoration(
                  hintText: 'john@example.com',
                  prefixIcon: const Icon(
                    Icons.mail_outline,
                    color: Color(0xFF94A3B8),
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
              const SizedBox(height: AppSpacing.md),
              const AuthFieldLabel('Password', required: true),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _passwordController,
                enabled: !_submitting,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                decoration: authInputDecoration(
                  hintText: 'Create a password',
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
                autofillHints: const [AutofillHints.newPassword],
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
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: _submitting
                          ? null
                          : (value) => setState(
                                () => _agreedToTerms = value ?? false,
                              ),
                      side: const BorderSide(
                        color: AppColors.outline,
                        width: 1.5,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: _privacyRecognizer,
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
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
                        'Creating…',
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
                            'Sign Up',
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
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log In',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: _logInRecognizer,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SecureRegistrationBanner(),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: _submitting
                    ? null
                    : () => _showComingSoon('Support'),
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('Need help? Contact support'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onSurfaceVariant,
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
