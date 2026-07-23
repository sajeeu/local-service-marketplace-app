import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/auth_form_controls.dart';
import 'package:go_router/go_router.dart';

/// Confirmation shown after a successful password update.
class PasswordResetSuccessScreen extends StatefulWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  State<PasswordResetSuccessScreen> createState() =>
      _PasswordResetSuccessScreenState();
}

class _PasswordResetSuccessScreenState
    extends State<PasswordResetSuccessScreen> {
  late final TapGestureRecognizer _supportRecognizer;

  @override
  void initState() {
    super.initState();
    _supportRecognizer = TapGestureRecognizer()
      ..onTap = () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Support is coming soon.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      };
  }

  @override
  void dispose() {
    _supportRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appName = AppConfig.current.appName;

    return AppScaffold(
      title: 'Password reset',
      showAppBar: false,
      maxContentWidth: AppLayout.formMaxWidth,
      horizontalPadding: AppSpacing.lg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),
            AuthBackBrandHeader(
              backTooltip: 'Back to sign in',
              onBack: () => context.go(AppRoutes.login),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.outline),
            const SizedBox(height: AppSpacing.lg),
            AuthHeroBanner.success(),
            const SizedBox(height: AppSpacing.lg),
            const AuthPageTitle('Password updated'),
            const SizedBox(height: AppSpacing.sm),
            AuthPageSubtitle(
              'Your password has been updated. You can now sign in to your '
              '$appName account with your new credentials.',
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthInfoCallout(
              title: 'Security tip',
              icon: Icons.shield_outlined,
              body:
                  "Don't share your new password with anyone. "
                  '$appName will never ask for it by email or message.',
            ),
            const SizedBox(height: AppSpacing.xl),
            AuthPrimaryButton(
              label: 'Back to sign in',
              showTrailingArrow: true,
              onPressed: () => context.go(AppRoutes.login),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text.rich(
                TextSpan(
                  style: AppTypography.bodySmall,
                  children: [
                    const TextSpan(text: 'Having trouble? '),
                    TextSpan(
                      text: 'Contact support',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: _supportRecognizer,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
