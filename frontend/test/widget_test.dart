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

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Welcome back'), findsOneWidget);
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

    expect(find.text('Foundation ready'), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsOneWidget);
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
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
