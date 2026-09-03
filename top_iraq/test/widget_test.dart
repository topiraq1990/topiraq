// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:top_iraq/main.dart';

void main() {
  testWidgets('Top Iraq home screen renders primary sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TopIraqApp());

    expect(find.text('Top Iraq'), findsWidgets);
    expect(find.text('الأقسام'), findsOneWidget);
    expect(find.text('مهام اليوم'), findsOneWidget);
    expect(find.text('الغرف الصوتية'), findsOneWidget);
    expect(find.text('VIP'), findsOneWidget);
  });

  testWidgets('Account tab opens local demo login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TopIraqApp());

    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('دخول'), findsOneWidget);
  });

  testWidgets('Wallet screen shows demo balance and gift list',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TopIraqApp());

    final walletCard = find.ancestor(
      of: find.text('العملات').last,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(walletCard);
    await tester.tap(walletCard);
    await tester.pumpAndSettle();

    expect(find.text('رصيد العملات'), findsOneWidget);
    expect(find.text('عرض الهدايا'), findsOneWidget);
    expect(find.text('آخر الهدايا المرسلة'), findsOneWidget);
  });

  testWidgets('VIP screen shows current level, XP and daily tasks',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TopIraqApp());

    final vipCard = find.ancestor(
      of: find.text('VIP').last,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(vipCard);
    await tester.tap(vipCard);
    await tester.pumpAndSettle();

    expect(find.text('VIP'), findsWidgets);
    expect(find.text('مستوى المستخدم الحالي'), findsOneWidget);
    expect(find.text('XP'), findsWidgets);
    expect(find.text('المهام اليومية'), findsOneWidget);
  });
}
