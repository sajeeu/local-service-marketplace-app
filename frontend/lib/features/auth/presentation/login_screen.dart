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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;
  var _rememberMe = false;
  var _submitting = false;
  late final TapGestureRecognizer _signUpRecognizer;

  @override
  void initState() {
    super.initState();
    _signUpRecognizer = TapGestureRecognizer()
      ..onTap = () {
        if (!_submitting) {
          context.go(AppRoutes.register);
        }
      };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _signUpRecognizer.dispose();
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
    try {
      await ref.read(sessionProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
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
      title: 'Sign in',
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
            const AppBrandHeader(),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.outline),
            const SizedBox(height: AppSpacing.lg),
            const AuthHeroBanner(),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sign in to access your $appName account',
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: authInputDecoration(
                hintText: 'e.g. name@example.com',
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
            const AuthFieldLabel('Password'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _passwordController,
              enabled: !_submitting,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) {
                if (!_submitting) {
                  _submit();
                }
              },
              decoration: authInputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
                suffixIcon: IconButton(
                  tooltip:
                      _obscurePassword ? 'Show password' : 'Hide password',
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
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: _submitting
                        ? null
                        : (value) =>
                            setState(() => _rememberMe = value ?? false),
                    side: const BorderSide(
                      color: AppColors.outline,
                      width: 1.5,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'Remember me',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () => context.go(AppRoutes.forgotPassword),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Forgot password?'),
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
              child: Text(
                _submitting ? 'Signing in…' : 'Sign In',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const AuthOrDivider(),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AuthSocialIconButton(
                    tooltip: 'Continue with Google',
                    onPressed: _submitting
                        ? null
                        : () => _showComingSoon('Google sign-in'),
                    child: const GoogleMark(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AuthSocialIconButton(
                    tooltip: 'Continue with Facebook',
                    onPressed: _submitting
                        ? null
                        : () => _showComingSoon('Facebook sign-in'),
                    child: const FacebookMark(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AuthSocialIconButton(
                    tooltip: 'Continue with Apple',
                    onPressed: _submitting
                        ? null
                        : () => _showComingSoon('Apple sign-in'),
                    child: const AppleMark(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: "Don't have an account? "),
                    TextSpan(
                      text: 'Sign Up',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: _signUpRecognizer,
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
