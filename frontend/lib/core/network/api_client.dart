import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/core/network/api_envelope.dart';
import 'package:frontend/core/state/token_store.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: AppConfig.current,
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

/// Thin HTTP client that understands the backend API envelope.
/// Remote state (Riverpod AsyncNotifier) should call this — not widgets.
class ApiClient {
  ApiClient({
    required AppConfig config,
    required TokenStore tokenStore,
    Dio? dio,
  })  : _tokenStore = tokenStore,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: config.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 20),
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final skipAuth = options.extra['skipAuth'] == true;
          if (!skipAuth) {
            final token = await _tokenStore.readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStore _tokenStore;

  Future<ApiEnvelope<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T? Function(Object? raw)? parseData,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {'skipAuth': skipAuth}),
      );
      return _parseEnvelope(response.data, parseData: parseData);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const UnexpectedAppException();
    }
  }

  Future<ApiEnvelope<T>> post<T>(
    String path, {
    Object? data,
    T? Function(Object? raw)? parseData,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(extra: {'skipAuth': skipAuth}),
      );
      return _parseEnvelope(response.data, parseData: parseData);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const UnexpectedAppException();
    }
  }

  Future<ApiEnvelope<T>> patch<T>(
    String path, {
    Object? data,
    T? Function(Object? raw)? parseData,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(extra: {'skipAuth': skipAuth}),
      );
      return _parseEnvelope(response.data, parseData: parseData);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const UnexpectedAppException();
    }
  }

  Future<ApiEnvelope<T>> put<T>(
    String path, {
    Object? data,
    T? Function(Object? raw)? parseData,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(extra: {'skipAuth': skipAuth}),
      );
      return _parseEnvelope(response.data, parseData: parseData);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const UnexpectedAppException();
    }
  }

  Future<ApiEnvelope<T>> delete<T>(
    String path, {
    Object? data,
    T? Function(Object? raw)? parseData,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(extra: {'skipAuth': skipAuth}),
      );
      return _parseEnvelope(response.data, parseData: parseData);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const UnexpectedAppException();
    }
  }

  ApiEnvelope<T> _parseEnvelope<T>(
    Map<String, dynamic>? data, {
    T? Function(Object? raw)? parseData,
  }) {
    if (data == null) {
      throw const UnexpectedAppException('Empty response from server');
    }

    final envelope = ApiEnvelope<T>.fromJson(data, parseData: parseData);
    if (!envelope.isSuccess && envelope.error != null) {
      throw ApiAppException(
        message: envelope.error!.message,
        code: envelope.error!.code,
        details: envelope.error!.details,
      );
    }
    return envelope;
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkAppException();
    }

    final payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      final envelope = ApiEnvelope<dynamic>.fromJson(payload);
      if (envelope.error != null) {
        return ApiAppException(
          message: envelope.error!.message,
          code: envelope.error!.code,
          details: envelope.error!.details,
        );
      }
    }

    return UnexpectedAppException(
      error.message ?? 'Unexpected network error',
    );
  }
}
