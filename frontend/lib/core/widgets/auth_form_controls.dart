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
        style: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
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
      color: AppColors.iconMuted,
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

/// Standard muted prefix/suffix icon for auth fields.
class AuthFieldIcon extends StatelessWidget {
  const AuthFieldIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: AppColors.iconMuted, size: 22);
  }
}

/// App logo mark + name for auth headers.
class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          label: '${AppConfig.current.appName} logo',
          child: Container(
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
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            AppConfig.current.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}

/// Back control + centered brand for nested auth screens.
class AuthBackBrandHeader extends StatelessWidget {
  const AuthBackBrandHeader({
    required this.onBack,
    this.backTooltip = 'Back',
    super.key,
  });

  final VoidCallback? onBack;
  final String backTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: backTooltip,
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          visualDensity: VisualDensity.compact,
        ),
        const Expanded(child: AppBrandHeader()),
        const SizedBox(width: 48),
      ],
    );
  }
}

/// Page title using design-system display type.
class AuthPageTitle extends StatelessWidget {
  const AuthPageTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.display);
  }
}

/// Supporting copy under an auth page title.
class AuthPageSubtitle extends StatelessWidget {
  const AuthPageSubtitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodySmall.copyWith(fontSize: 15, height: 1.45),
    );
  }
}

/// Primary auth CTA with optional in-button loading indicator.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
    this.showTrailingArrow = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final String? loadingLabel;
  final bool showTrailingArrow;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = loading ? (loadingLabel ?? label) : label;

    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
        disabledForegroundColor: AppColors.onPrimary,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: loading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  effectiveLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : showTrailingArrow
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      effectiveLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                )
              : Text(
                  effectiveLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
    );
  }
}

/// Password field with show/hide toggle using auth input styling.
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.password],
    this.validator,
    this.onFieldSubmitted,
    this.prefixIcon = Icons.lock_outline,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Iterable<String> autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final IconData prefixIcon;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  var _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      decoration: authInputDecoration(
        hintText: widget.hintText,
        prefixIcon: AuthFieldIcon(widget.prefixIcon),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          onPressed: widget.enabled
              ? () => setState(() => _obscure = !_obscure)
              : null,
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.iconMuted,
          ),
        ),
      ),
    );
  }
}

/// Checkbox row with a 44dp tap target for accessibility.
class AuthCheckboxRow extends StatelessWidget {
  const AuthCheckboxRow({
    required this.value,
    required this.onChanged,
    required this.child,
    this.enabled = true,
    super.key,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled && onChanged != null
          ? () => onChanged!(!value)
          : null,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: enabled ? onChanged : null,
                side: const BorderSide(
                  color: AppColors.outline,
                  width: 1.5,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Marketplace-themed hero illustration for auth screens.
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

  /// Success-themed hero after password update.
  factory AuthHeroBanner.success({Key? key}) {
    return AuthHeroBanner(
      key: key,
      icons: const [
        Icons.verified_outlined,
        Icons.check_circle_outline,
        Icons.lock_open_outlined,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Marketplace illustration',
      child: ExcludeSemantics(
        child: Container(
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
      1 => 'Weak',
      2 => 'Fair',
      3 => 'Good',
      _ => 'Strong',
    };
    final color = switch (score) {
      0 => AppColors.outline,
      1 => AppColors.error,
      2 => AppColors.warning,
      3 => AppColors.secondary,
      _ => AppColors.success,
    };

    return Semantics(
      liveRegion: true,
      label: label.isEmpty
          ? 'Password strength not rated yet'
          : 'Password strength: $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Password strength',
                style: AppTypography.labelSmall,
              ),
              const Spacer(),
              if (label.isNotEmpty)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
      ),
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
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.primary,
            size: 22,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure registration',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Your account details are encrypted. We never share your '
                  'information with providers without your consent.',
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

/// Inline trust tip used on success / recovery screens.
class AuthInfoCallout extends StatelessWidget {
  const AuthInfoCallout({
    required this.title,
    required this.body,
    this.icon = Icons.info_outline,
    super.key,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: const TextStyle(
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
