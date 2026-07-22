import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/state/session_provider.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';
import 'package:frontend/features/customers/presentation/create_customer_profile_screen.dart';
import 'package:frontend/features/customers/presentation/edit_customer_profile_screen.dart';
import 'package:frontend/features/customers/presentation/view_customer_profile_screen.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:frontend/features/providers/presentation/create_provider_profile_screen.dart';
import 'package:frontend/features/providers/presentation/edit_provider_profile_screen.dart';
import 'package:frontend/features/providers/presentation/view_provider_profile_screen.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const providerProfile = '/provider-profile';
  static const providerProfileCreate = '/provider-profile/create';
  static const providerProfileEdit = '/provider-profile/edit';
  static const customerProfile = '/customer-profile';
  static const customerProfileCreate = '/customer-profile/create';
  static const customerProfileEdit = '/customer-profile/edit';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AsyncValue<SessionState>>(sessionProvider, (previous, next) {
    // Trigger go_router refresh whenever session async state changes.
    if (previous != next) {
      refresh.value++;
    }
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (session.isLoading) {
        return null;
      }

      final authenticated = session.value?.isAuthenticated ?? false;

      if (!authenticated && !loggingIn) {
        return AppRoutes.login;
      }
      if (authenticated && loggingIn) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.providerProfile,
        name: 'provider-profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ViewProviderProfileScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.providerProfileCreate,
        name: 'provider-profile-create',
        builder: (BuildContext context, GoRouterState state) {
          return const CreateProviderProfileScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.providerProfileEdit,
        name: 'provider-profile-edit',
        builder: (BuildContext context, GoRouterState state) {
          return const EditProviderProfileScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.customerProfile,
        name: 'customer-profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ViewCustomerProfileScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.customerProfileCreate,
        name: 'customer-profile-create',
        builder: (BuildContext context, GoRouterState state) {
          return const CreateCustomerProfileScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.customerProfileEdit,
        name: 'customer-profile-edit',
        builder: (BuildContext context, GoRouterState state) {
          return const EditCustomerProfileScreen();
        },
      ),
    ],
    debugLogDiagnostics: kDebugMode,
  );
});
