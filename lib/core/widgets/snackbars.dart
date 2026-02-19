import 'package:flutter/material.dart';

/// Default duration for success and error snackbars.
const Duration _kSnackBarDuration = Duration(seconds: 2);

/// Shows a success snackbar with theme styling and consistent duration.
/// Use after create/update/delete operations (e.g. "Order created", "Product updated").
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: _kSnackBarDuration,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Shows an error snackbar with theme error color and consistent duration.
/// Use in catch blocks or when an operation fails (e.g. "Operation failed", "Could not save").
void showErrorSnackBar(BuildContext context, String message) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: theme.colorScheme.onError),
      ),
      duration: _kSnackBarDuration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: theme.colorScheme.error,
    ),
  );
}
