import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_tokens.dart';

/// Circular avatar placeholder used when no uploaded image is available.
class ProfileAvatarPlaceholder extends StatelessWidget {
  const ProfileAvatarPlaceholder({
    this.size = 88,
    this.displayName,
    super.key,
  });

  final double size;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final initial = _initial(displayName);
    return Semantics(
      label: displayName == null || displayName!.trim().isEmpty
          ? 'Profile avatar placeholder'
          : 'Profile avatar for $displayName',
      image: true,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.primary,
        child: initial == null
            ? Icon(Icons.person_outline, size: size * 0.5)
            : Text(
                initial,
                style: TextStyle(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
      ),
    );
  }

  static String? _initial(String? displayName) {
    final trimmed = displayName?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.substring(0, 1).toUpperCase();
  }
}
