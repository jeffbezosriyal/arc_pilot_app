import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/api/api_exceptions.dart';

void main() {
  group('ApiException', () {
    test('toString() returns the correct message', () {
      const message = 'Test error message';
      final exception = ApiException(message);

      expect(exception.toString(), message);
    });

    test('can be caught as an Exception', () {
      try {
        throw ApiException('Test');
      } catch (e) {
        expect(e, isA<ApiException>());
        expect(e, isA<Exception>());
      }
    });
  });
}