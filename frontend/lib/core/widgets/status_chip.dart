import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_tokens.dart';

enum StatusChipTone { neutral, success, warning, danger, info }

/// Compact status / visibility / completion chip.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    this.tone = StatusChipTone.neutral,
    super.key,
  });

  final String label;
  final StatusChipTone tone;

  factory StatusChip.profileStatus(String status) {
    final normalized = status.toUpperCase();
    if (normalized == 'ACTIVE') {
      return const StatusChip(label: 'Active', tone: StatusChipTone.success);
    }
    if (normalized == 'INACTIVE' || normalized == 'DEACTIVATED') {
      return const StatusChip(label: 'Inactive', tone: StatusChipTone.danger);
    }
    return StatusChip(label: status, tone: StatusChipTone.neutral);
  }

  factory StatusChip.visibility(String visibility) {
    final normalized = visibility.toUpperCase();
    if (normalized == 'PUBLIC') {
      return const StatusChip(label: 'Public', tone: StatusChipTone.info);
    }
    if (normalized == 'PRIVATE') {
      return const StatusChip(label: 'Private', tone: StatusChipTone.warning);
    }
    return StatusChip(label: visibility, tone: StatusChipTone.neutral);
  }

  factory StatusChip.completion({
    required String status,
    required int percent,
  }) {
    final tone = percent >= 100
        ? StatusChipTone.success
        : percent >= 50
            ? StatusChipTone.info
            : StatusChipTone.warning;
    return StatusChip(
      label: '$status · $percent%',
      tone: tone,
    );
  }

  factory StatusChip.missing() {
    return const StatusChip(label: 'Not set up', tone: StatusChipTone.warning);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(tone);

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: AppRadius.borderSm,
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ({Color background, Color foreground}) _colorsFor(
    StatusChipTone tone,
  ) {
    switch (tone) {
      case StatusChipTone.success:
        return (
          background: AppColors.success.withValues(alpha: 0.12),
          foreground: AppColors.success,
        );
      case StatusChipTone.warning:
        return (
          background: AppColors.warning.withValues(alpha: 0.12),
          foreground: AppColors.warning,
        );
      case StatusChipTone.danger:
        return (
          background: AppColors.error.withValues(alpha: 0.12),
          foreground: AppColors.error,
        );
      case StatusChipTone.info:
        return (
          background: AppColors.primaryContainer,
          foreground: AppColors.onPrimaryContainer,
        );
      case StatusChipTone.neutral:
        return (
          background: AppColors.outline.withValues(alpha: 0.35),
          foreground: AppColors.onSurfaceVariant,
        );
    }
  }
}
