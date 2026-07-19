/// Client-side exception hierarchy mapped from API envelope errors.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Object? details;

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkAppException extends AppException {
  const NetworkAppException([
    String message = 'Unable to reach the server. Check your connection.',
  ]) : super(message: message, code: 'NETWORK_ERROR');
}

class ApiAppException extends AppException {
  const ApiAppException({
    required super.message,
    required String code,
    super.details,
  }) : super(code: code);
}

class UnexpectedAppException extends AppException {
  const UnexpectedAppException([
    String message = 'Something went wrong. Please try again.',
  ]) : super(message: message, code: 'UNEXPECTED_ERROR');
}
