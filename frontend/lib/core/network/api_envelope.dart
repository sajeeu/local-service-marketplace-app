class ApiErrorBody {
  const ApiErrorBody({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Object? details;

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) {
    return ApiErrorBody(
      code: json['code'] as String? ?? 'INTERNAL_ERROR',
      message: json['message'] as String? ?? 'Request failed',
      details: json['details'],
    );
  }
}

class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.data,
    required this.error,
    this.meta,
  });

  final T? data;
  final ApiErrorBody? error;
  final Map<String, dynamic>? meta;

  bool get isSuccess => error == null;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json, {
    T? Function(Object? raw)? parseData,
  }) {
    final rawError = json['error'];
    return ApiEnvelope<T>(
      data: parseData != null
          ? parseData(json['data'])
          : json['data'] as T?,
      error: rawError is Map<String, dynamic>
          ? ApiErrorBody.fromJson(rawError)
          : null,
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
    );
  }
}
