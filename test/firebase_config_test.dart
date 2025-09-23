import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/firebase_options.dart';

void main() {
  group('Firebase configuration', () {
    test('DefaultFirebaseOptions are present for current platform', () {
      final options = DefaultFirebaseOptions.currentPlatform;
      expect(options.apiKey.isNotEmpty, true);
      expect(options.appId.isNotEmpty, true);
      expect(options.projectId.isNotEmpty, true);
    });
  });
}
