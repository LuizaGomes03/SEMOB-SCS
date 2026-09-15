// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semob_scs/app/app.dart';
import 'package:semob_scs/core/constants/app_colors.dart';

void main() {
  testWidgets('SemobApp smoke test on default viewport', (WidgetTester tester) async {
    await tester.pumpWidget(const SemobApp());
    expect(find.byType(SemobApp), findsOneWidget);
  });

  testWidgets('SemobApp renders cleanly on Desktop resolution (1440x900)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const SemobApp());
    await tester.pumpAndSettle();

    expect(find.byType(SemobApp), findsOneWidget);
  });

  testWidgets('SemobApp renders cleanly on Tablet resolution (820x1180)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(820, 1180);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const SemobApp());
    await tester.pumpAndSettle();

    expect(find.byType(SemobApp), findsOneWidget);
  });

  testWidgets('SemobApp renders cleanly on Mobile resolution (390x844)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const SemobApp());
    await tester.pumpAndSettle();

    expect(find.byType(SemobApp), findsOneWidget);
  });

  test('AppColors institutional palette conforms to specifications', () {
    expect(AppColors.primary, const Color(0xFF3D5D9A));
    expect(AppColors.textPrimary, const Color(0xFF183B70));
    expect(AppColors.background, const Color(0xFFF5F7FA));
    expect(AppColors.card, const Color(0xFFFFFFFF));
    expect(AppColors.textSecondary, const Color(0xFF667085));
  });
}
