/// A custom exception class to handle specific API-related errors.
///
/// Using a custom exception class allows the application to catch API errors
/// specifically, distinguishing them from other types of exceptions (like formatting
/// errors or file system errors). This leads to more precise error handling
/// in the UI and test files.
class ApiException implements Exception {
  /// A message providing more details about the error.
  final String message;

  ApiException(this.message);

  @override
  String toString() {
    // The toString method is overridden to provide a clean, readable error message
    // when the exception is printed or displayed in the UI.
    return message;
  }
}