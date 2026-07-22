import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/core/state/preferences_store.dart';
import 'package:frontend/core/state/session_provider.dart';
import 'package:frontend/core/state/token_store.dart';
import 'package:frontend/features/auth/data/auth_api.dart';
import 'package:frontend/features/auth/data/auth_models.dart';
import 'package:frontend/features/customers/data/customer_profile_api.dart';
import 'package:frontend/features/customers/data/customer_profile_models.dart';
import 'package:frontend/features/providers/data/provider_profile_api.dart';
import 'package:frontend/features/providers/data/provider_profile_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _HydratedSession extends SessionNotifier {
  _HydratedSession(this.seed);

  final SessionState seed;

  @override
  Future<SessionState> build() async => seed;
}

class _NoopAuthApi implements AuthApi {
  @override
  Future<AuthUser> getMe() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    throw const ApiAppException(
      message: 'Invalid credentials',
      code: 'UNAUTHORIZED',
    );
  }

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<AuthTokens> refresh(String refreshToken) {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokens> register({
    required String email,
    required String password,
    String? displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> updateMe({String? displayName}) {
    throw UnimplementedError();
  }
}

class _MissingProviderProfileApi implements ProviderProfileApi {
  @override
  Future<ProviderProfile> create(CreateProviderProfileInput input) {
    throw UnimplementedError();
  }

  @override
  Future<ProviderProfile> getMe() async {
    throw const ApiAppException(
      message: 'Provider profile not found',
      code: 'NOT_FOUND',
    );
  }

  @override
  Future<ProviderProfile> update(UpdateProviderProfileInput input) {
    throw UnimplementedError();
  }

  @override
  Future<ProviderProfile> deactivate() {
    throw UnimplementedError();
  }

  @override
  Future<ProviderProfile> restore() {
    throw UnimplementedError();
  }
}

class _MissingCustomerProfileApi implements CustomerProfileApi {
  @override
  Future<CustomerProfile> create(CreateCustomerProfileInput input) {
    throw UnimplementedError();
  }

  @override
  Future<CustomerProfile> getMe() async {
    throw const ApiAppException(
      message: 'Customer profile not found',
      code: 'NOT_FOUND',
    );
  }

  @override
  Future<CustomerProfile> update(UpdateCustomerProfileInput input) {
    throw UnimplementedError();
  }

  @override
  Future<CustomerProfile> deactivate() {
    throw UnimplementedError();
  }

  @override
  Future<CustomerProfile> restore() {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unauthenticated app opens login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          authApiProvider.overrideWithValue(_NoopAuthApi()),
        ],
        child: const LocalServiceMarketplaceApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.textContaining('Local Service Marketplace'), findsWidgets);
  });

  testWidgets('authenticated app opens home shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const user = AuthUser(
      id: 'u1',
      email: 'user@example.com',
      role: 'CUSTOMER',
      status: 'ACTIVE',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          authApiProvider.overrideWithValue(_NoopAuthApi()),
          providerProfileApiProvider
              .overrideWithValue(_MissingProviderProfileApi()),
          customerProfileApiProvider
              .overrideWithValue(_MissingCustomerProfileApi()),
          sessionProvider.overrideWith(
            () => _HydratedSession(
              const SessionState(
                isAuthenticated: true,
                user: user,
                accessToken: 'access',
                refreshToken: 'refresh',
              ),
            ),
          ),
        ],
        child: const LocalServiceMarketplaceApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsOneWidget);
    expect(find.text('Create customer profile'), findsOneWidget);
    expect(find.text('Create provider profile'), findsOneWidget);
  });

  testWidgets('login form shows validation errors', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          authApiProvider.overrideWithValue(_NoopAuthApi()),
        ],
        child: const LocalServiceMarketplaceApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
