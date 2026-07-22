import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/state/session_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_tokens.dart';

class LocalServiceMarketplaceApp extends ConsumerWidget {
  const LocalServiceMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final router = ref.watch(routerProvider);

    // Only tear down the router during the initial bootstrap (no resolved
    // session yet). Login/register loading must not replace MaterialApp.router.
    if (session.isLoading && !session.hasValue) {
      return MaterialApp(
        title: AppConfig.current.appName,
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Semantics(
              label: 'Loading ${AppConfig.current.appName}',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppConfig.current.appName,
                    style: AppTypography.title.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: AppConfig.current.appName,
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
