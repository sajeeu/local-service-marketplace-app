import 'package:flutter/material.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/theme/app_tokens.dart';

/// Field label for auth forms (title case).
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(
    this.text, {
    this.required = false,
    super.key,
  });

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          height: 1.2,
        ),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared outlined input decoration for auth screens.
InputDecoration authInputDecoration({
  required String hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: const BorderSide(color: AppColors.outline),
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF94A3B8),
      fontWeight: FontWeight.w400,
      fontSize: 15,
    ),
    filled: true,
    fillColor: AppColors.surfaceContainer,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 14,
    ),
    prefixIcon: prefixIcon,
    prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    suffixIcon: suffixIcon,
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}

/// App logo mark + name for auth headers.
class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.handyman_rounded,
            color: AppColors.onPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            AppConfig.current.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Marketplace-themed hero illustration for the sign-in screen.
class AuthHeroBanner extends StatelessWidget {
  const AuthHeroBanner({
    this.icons = const [
      Icons.home_repair_service_outlined,
      Icons.handshake_outlined,
      Icons.water_drop_outlined,
    ],
    super.key,
  });

  final List<IconData> icons;

  /// Security-themed hero for password recovery screens.
  factory AuthHeroBanner.passwordRecovery({Key? key}) {
    return AuthHeroBanner(
      key: key,
      icons: const [
        Icons.shield_outlined,
        Icons.vpn_key_outlined,
        Icons.lock_outline,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F1FF),
            Color(0xFFD6E8FF),
            Color(0xFFC9DEFF),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _AuthHeroPainter(),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < icons.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.lg),
                _HeroBadge(icon: icons[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: AppColors.primary, size: 26),
    );
  }
}

class _AuthHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.22,
        size.width * 0.78,
        size.height * 0.5,
      );
    canvas.drawPath(path, paint);

    final soft = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.28), 18, soft);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.7), 22, soft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Horizontal rule with centered label.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({
    this.label = 'OR CONTINUE WITH',
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outline, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.outline, thickness: 1)),
      ],
    );
  }
}

/// Icon-only social sign-in button.
class AuthSocialIconButton extends StatelessWidget {
  const AuthSocialIconButton({
    required this.child,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceContainer,
          side: const BorderSide(color: AppColors.outline),
          minimumSize: const Size(56, 52),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// Compact Google "G" mark.
class GoogleMark extends StatelessWidget {
  const GoogleMark({this.size = 22, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleMarkPainter()),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.4, 1.6, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.2, 1.2, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.4, 0.9, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.3, 1.2, false, paint);

    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.48,
        size.height * 0.42,
        size.width * 0.42,
        stroke,
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Facebook "f" mark.
class FacebookMark extends StatelessWidget {
  const FacebookMark({this.size = 22, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.facebook, size: size, color: const Color(0xFF1877F2));
  }
}

/// Compact Apple mark.
class AppleMark extends StatelessWidget {
  const AppleMark({this.size = 22, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.apple, size: size, color: AppColors.onSurface);
  }
}

/// Simple password strength meter (4 segments).
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.password, super.key});

  final String password;

  static int scoreFor(String password) {
    if (password.isEmpty) {
      return 0;
    }
    var score = 0;
    if (password.length >= 8) {
      score++;
    }
    if (password.length >= 12) {
      score++;
    }
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password) ||
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score++;
    }
    return score.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final score = scoreFor(password);
    final label = switch (score) {
      0 => '',
      1 => 'WEAK',
      2 => 'FAIR',
      3 => 'GOOD',
      _ => 'STRONG',
    };
    final color = switch (score) {
      0 => AppColors.outline,
      1 => AppColors.error,
      2 => AppColors.warning,
      3 => const Color(0xFF2563EB),
      _ => AppColors.success,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'Password Strength',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (label.isNotEmpty)
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: color,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(4, (index) {
            final active = index < score;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: active ? color : AppColors.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Trust callout used on registration.
class SecureRegistrationBanner extends StatelessWidget {
  const SecureRegistrationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 22),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Registration',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Your data is encrypted and handled according to global privacy standards.',
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
    );
  }
}
