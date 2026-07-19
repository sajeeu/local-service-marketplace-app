import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_tokens.dart';

/// Shared page shell for feature screens.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: body,
      ),
    );
  }
}
