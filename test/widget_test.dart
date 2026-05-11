// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Material app smoke test', (WidgetTester tester) async {
    // Build a simple material app for testing
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test App'),
        ),
        body: const Center(
          child: Text('Hello, World!'),
        ),
      ),
    ));

    // Verify that our app builds successfully
    expect(find.text('Test App'), findsOneWidget);
    expect(find.text('Hello, World!'), findsOneWidget);
  });

  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Test a simple widget
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Test Widget'),
        ),
      ),
    ));

    // Verify the widget is displayed
    expect(find.text('Test Widget'), findsOneWidget);
  });
}
