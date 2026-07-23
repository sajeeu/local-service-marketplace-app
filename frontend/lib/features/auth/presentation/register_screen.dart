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
  var _agreedToTerms = false;
  var _submitting = false;
  late final TapGestureRecognizer _signInRecognizer;
  late final TapGestureRecognizer _termsRecognizer;
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
    _signInRecognizer.dispose();
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
            content: Text(
              'Please agree to the Terms of Service and Privacy Policy.',
            ),
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
                const AuthHeroBanner(),
                const SizedBox(height: AppSpacing.lg),
                const AuthPageTitle('Create account'),
                const SizedBox(height: AppSpacing.sm),
                AuthPageSubtitle(
                  'Join $appName to find and book trusted local professionals '
                  'across Malé, Hulhumalé, and islands throughout the Maldives.',
                ),
                const SizedBox(height: AppSpacing.lg),
                const AuthFieldLabel('Full name', required: true),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _displayNameController,
                  enabled: !_submitting,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: authInputDecoration(
                    hintText: 'Your full name',
                    prefixIcon: const AuthFieldIcon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const AuthFieldLabel('Email address', required: true),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _emailController,
                  enabled: !_submitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
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
                const SizedBox(height: AppSpacing.md),
                const AuthFieldLabel('Password', required: true),
                const SizedBox(height: AppSpacing.sm),
                AuthPasswordField(
                  controller: _passwordController,
                  enabled: !_submitting,
                  hintText: 'Create a password',
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
                const SizedBox(height: AppSpacing.md),
                AuthCheckboxRow(
                  value: _agreedToTerms,
                  enabled: !_submitting,
                  onChanged: (value) =>
                      setState(() => _agreedToTerms = value ?? false),
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.bodySmall.copyWith(fontSize: 13),
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
                const SizedBox(height: AppSpacing.lg),
                AuthPrimaryButton(
                  label: 'Sign up',
                  loadingLabel: 'Creating account…',
                  loading: _submitting,
                  showTrailingArrow: true,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.bodySmall,
                      children: [
                        const TextSpan(text: 'Already have an account? '),
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
                const SecureRegistrationBanner(),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: _submitting
                      ? null
                      : () => _showComingSoon('Support'),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Need help? Contact support'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 44),
                    foregroundColor: AppColors.onSurfaceVariant,
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
