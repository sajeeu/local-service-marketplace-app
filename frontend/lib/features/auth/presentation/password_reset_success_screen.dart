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
            Row(
              children: [
                IconButton(
                  tooltip: 'Back to sign in',
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
                const Expanded(child: AppBrandHeader()),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.outline),
            const SizedBox(height: AppSpacing.xl),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDE4),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Center(
                child: Text('👌', style: TextStyle(fontSize: 72)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.onPrimary,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Password Reset',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Your password has been updated!',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your security is our priority. You can now use your new password to access your $appName account.',
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SECURITY TIP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          "Ensure you haven't shared your new credentials with anyone to keep your service history secure.",
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => context.go(AppRoutes.login),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Back to Login',
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
                    const TextSpan(text: 'Having trouble? '),
                    TextSpan(
                      text: 'Contact Support',
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
            const SizedBox(height: AppSpacing.xl),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepDot(active: true),
                SizedBox(width: 8),
                _StepDot(active: false),
                SizedBox(width: 8),
                _StepDot(active: false),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppColors.onSurfaceVariant
            : AppColors.outline.withValues(alpha: 0.8),
      ),
    );
  }
}
