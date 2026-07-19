import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/core/state/session_provider.dart';
import 'package:frontend/core/state/token_store.dart';
import 'package:frontend/features/auth/data/auth_api.dart';
import 'package:frontend/features/auth/data/auth_models.dart';

class _FakeAuthApi implements AuthApi {
  _FakeAuthApi({
    this.loginResult,
    this.loginError,
    this.meResult,
  });

  AuthTokens? loginResult;
  Object? loginError;
  AuthUser? meResult;
  var logoutCalled = false;

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    if (loginError != null) {
      throw loginError!;
    }
    return loginResult!;
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
  Future<AuthTokens> refresh(String refreshToken) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout(String refreshToken) async {
    logoutCalled = true;
  }

  @override
  Future<AuthUser> getMe() async {
    return meResult!;
  }

  @override
  Future<AuthUser> updateMe({String? displayName}) {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = AuthUser(
    id: 'u1',
    email: 'user@example.com',
    role: 'CUSTOMER',
    status: 'ACTIVE',
    displayName: 'User',
  );

  const tokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresIn: 900,
    user: user,
  );

  test('login persists session and tokens', () async {
    final store = InMemoryTokenStore();
    final authApi = _FakeAuthApi(loginResult: tokens);

    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authApiProvider.overrideWithValue(authApi),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.future);
    await container
        .read(sessionProvider.notifier)
        .login(email: 'user@example.com', password: 'password123');

    final session = container.read(sessionProvider).value;
    expect(session?.isAuthenticated, isTrue);
    expect(session?.user?.email, 'user@example.com');
    expect(await store.readAccessToken(), 'access');
    expect(await store.readRefreshToken(), 'refresh');
  });

  test('login error leaves session unauthenticated', () async {
    final store = InMemoryTokenStore();
    final authApi = _FakeAuthApi(
      loginError: const ApiAppException(
        message: 'Invalid credentials',
        code: 'UNAUTHORIZED',
      ),
    );

    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authApiProvider.overrideWithValue(authApi),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.future);
    await container
        .read(sessionProvider.notifier)
        .login(email: 'user@example.com', password: 'bad');

    final session = container.read(sessionProvider);
    expect(session.hasError, isTrue);
    expect(await store.readAccessToken(), isNull);
  });

  test('logout clears secure tokens', () async {
    final store = InMemoryTokenStore();
    await store.saveTokens(accessToken: 'access', refreshToken: 'refresh');
    final authApi = _FakeAuthApi(meResult: user);

    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authApiProvider.overrideWithValue(authApi),
      ],
    );
    addTearDown(container.dispose);

    final hydrated = await container.read(sessionProvider.future);
    expect(hydrated.isAuthenticated, isTrue);

    await container.read(sessionProvider.notifier).logout();
    expect(
      container.read(sessionProvider).value?.isAuthenticated,
      isFalse,
    );
    expect(await store.readAccessToken(), isNull);
    expect(authApi.logoutCalled, isTrue);
  });
}
