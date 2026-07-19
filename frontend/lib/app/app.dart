import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/state/session_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';

class LocalServiceMarketplaceApp extends ConsumerWidget {
  const LocalServiceMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final router = ref.watch(routerProvider);

    if (session.isLoading) {
      return MaterialApp(
        title: AppConfig.current.appName,
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
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
