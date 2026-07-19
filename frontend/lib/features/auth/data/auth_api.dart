import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/data/auth_models.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<AuthTokens> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final envelope = await _client.post<AuthTokens>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        if (displayName != null && displayName.isNotEmpty)
          'displayName': displayName,
      },
      parseData: _parseTokens,
      skipAuth: true,
    );
    return envelope.data!;
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final envelope = await _client.post<AuthTokens>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      parseData: _parseTokens,
      skipAuth: true,
    );
    return envelope.data!;
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final envelope = await _client.post<AuthTokens>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      parseData: _parseTokens,
      skipAuth: true,
    );
    return envelope.data!;
  }

  Future<void> logout(String refreshToken) async {
    await _client.post<Map<String, dynamic>>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
      parseData: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<AuthUser> getMe() async {
    final envelope = await _client.get<AuthUser>(
      '/users/me',
      parseData: (raw) => AuthUser.fromJson(raw as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<AuthUser> updateMe({String? displayName}) async {
    final envelope = await _client.patch<AuthUser>(
      '/users/me',
      data: {'displayName': displayName},
      parseData: (raw) => AuthUser.fromJson(raw as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  static AuthTokens? _parseTokens(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return AuthTokens.fromJson(raw);
    }
    return null;
  }
}
