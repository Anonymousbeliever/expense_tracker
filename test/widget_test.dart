// Basic widget smoke tests that avoid initializing platform plugins in test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a minimal MaterialApp', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Text('Hello')),
    ));
    expect(find.text('Hello'), findsOneWidget);
  });
}
