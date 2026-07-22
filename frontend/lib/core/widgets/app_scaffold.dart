import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_tokens.dart';

/// Shared page shell with consistent AppBar, padding, and content width.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.maxContentWidth = AppLayout.pageMaxWidth,
    this.floatingActionButton,
    this.showAppBar = true,
    this.horizontalPadding = AppSpacing.md,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final double maxContentWidth;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              actions: actions,
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: AppSpacing.md,
              ),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
