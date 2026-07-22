import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/core/state/token_store.dart';
import 'package:frontend/features/auth/data/auth_api.dart';
import 'package:frontend/features/auth/data/auth_models.dart';

/// Session state ownership: authentication identity and tokens.
class SessionState {
  const SessionState({
    this.isAuthenticated = false,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  final bool isAuthenticated;
  final AuthUser? user;
  final String? accessToken;
  final String? refreshToken;

  static const unauthenticated = SessionState();
}

class SessionNotifier extends AsyncNotifier<SessionState> {
  bool _refreshing = false;

  TokenStore get _tokens => ref.read(tokenStoreProvider);
  AuthApi get _authApi => ref.read(authApiProvider);

  @override
  Future<SessionState> build() async {
    final accessToken = await _tokens.readAccessToken();
    final refreshToken = await _tokens.readRefreshToken();
    if (accessToken == null || refreshToken == null) {
      return SessionState.unauthenticated;
    }

    try {
      final user = await _authApi.getMe();
      return SessionState(
        isAuthenticated: true,
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on AppException {
      final refreshed = await _tryRefresh(refreshToken);
      if (refreshed != null) {
        return refreshed;
      }
      await _tokens.clear();
      return SessionState.unauthenticated;
    } catch (_) {
      await _tokens.clear();
      return SessionState.unauthenticated;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Do not set AsyncLoading — that made app.dart tear down MaterialApp.router.
    // Screens already expose local submitting UI state.
    state = await AsyncValue.guard(() async {
      final tokens = await _authApi.login(email: email, password: password);
      return _persistAuthenticated(tokens);
    });
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Do not set AsyncLoading — same MaterialApp.router teardown risk as login.
    state = await AsyncValue.guard(() async {
      final tokens = await _authApi.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      return _persistAuthenticated(tokens);
    });
  }

  Future<void> logout() async {
    final current = state.value;
    final refreshToken = current?.refreshToken;
    if (refreshToken != null) {
      try {
        await _authApi.logout(refreshToken);
      } catch (_) {
        // Local logout still proceeds.
      }
    }
    await _tokens.clear();
    state = const AsyncData(SessionState.unauthenticated);
  }

  Future<bool> refreshSession() async {
    final current = state.value;
    final refreshToken = current?.refreshToken;
    if (refreshToken == null) {
      return false;
    }
    final next = await _tryRefresh(refreshToken);
    if (next == null) {
      await _tokens.clear();
      state = const AsyncData(SessionState.unauthenticated);
      return false;
    }
    state = AsyncData(next);
    return true;
  }

  Future<SessionState> _persistAuthenticated(AuthTokens tokens) async {
    await _tokens.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return SessionState(
      isAuthenticated: true,
      user: tokens.user,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<SessionState?> _tryRefresh(String refreshToken) async {
    if (_refreshing) {
      return null;
    }
    _refreshing = true;
    try {
      final tokens = await _authApi.refresh(refreshToken);
      return _persistAuthenticated(tokens);
    } catch (_) {
      return null;
    } finally {
      _refreshing = false;
    }
  }
}

final sessionProvider =
    AsyncNotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
