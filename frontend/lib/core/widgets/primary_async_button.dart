import 'package:flutter/material.dart';

/// Primary filled button that shows a busy label while submitting.
class PrimaryAsyncButton extends StatelessWidget {
  const PrimaryAsyncButton({
    required this.label,
    required this.busyLabel,
    required this.isBusy,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String busyLabel;
  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !isBusy && onPressed != null,
      label: isBusy ? busyLabel : label,
      child: FilledButton(
        onPressed: isBusy ? null : onPressed,
        child: Text(isBusy ? busyLabel : label),
      ),
    );
  }
}
