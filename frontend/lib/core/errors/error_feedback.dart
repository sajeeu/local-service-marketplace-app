import 'package:flutter/material.dart';
import 'package:frontend/core/errors/app_exception.dart';

/// User-facing feedback helpers for API and unexpected errors.
abstract final class ErrorFeedback {
  static String messageOf(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }

  static void showSnackBar(BuildContext context, Object error) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(messageOf(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
