import 'package:flutter/material.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
  ],
);
