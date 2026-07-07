// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qishloq_ai_mobile/app/app.dart';
import 'package:qishloq_ai_mobile/features/auth/presentation/login_page.dart';

void main() {
  testWidgets('Splash page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: QishloqAiApp(),
      ),
    );

    // Verify that Splash Page elements are rendered.
    expect(find.text('QISHLOQ AI'), findsOneWidget);
    expect(find.text('Boshlash'), findsOneWidget);
  });

  testWidgets('Login page elements test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    // Check for "OTP olish" button
    expect(find.text('OTP olish'), findsOneWidget);
    // Check for "Demo davom etish" button
    expect(find.text('Demo davom etish'), findsOneWidget);
  });
}

