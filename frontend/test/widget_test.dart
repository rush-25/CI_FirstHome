import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firsthome_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FirstHomeApp desktop layout (1440px) renders brand and landing sections', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const FirstHomeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify brand and navigation elements
    expect(find.text('FirstHome'), findsWidgets);
    expect(find.text('Find Professionals'), findsWidgets);
    expect(find.text('Become a Provider'), findsWidgets);
    expect(find.text('Log In'), findsWidgets);
  });

  testWidgets('FirstHomeApp tablet layout (768px) renders without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const FirstHomeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('FirstHome'), findsWidgets);
    expect(find.byIcon(Icons.menu), findsWidgets);
  });

  testWidgets('FirstHomeApp mobile layout (375px) renders without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const FirstHomeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('FirstHome'), findsWidgets);
    expect(find.byIcon(Icons.menu), findsWidgets);
  });

  testWidgets('Navigation to Login and Registration screens', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const FirstHomeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Tap Log In button
    final loginBtn = find.text('Log In');
    expect(loginBtn, findsOneWidget);
    await tester.tap(loginBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Login Screen appears
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
