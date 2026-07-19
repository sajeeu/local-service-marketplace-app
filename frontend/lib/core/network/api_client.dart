import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/core/network/api_envelope.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(config: AppConfig.current);
});

/// Thin HTTP client that understands the backend API envelope.
/// Remote state (Riverpod AsyncNotifier) should call this — not widgets.
class ApiClient {
  ApiClient({
    required AppConfig config,
    Dio? dio,
  }) : _dio = dio ??
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
            );

  final Dio _dio;

  Future<ApiEnvelope<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T? Function(Object? raw)? parseData,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
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
