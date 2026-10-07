import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_muse/main.dart';

class _MockHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  testWidgets('HiveMuseApp renders Onboarding and navigates to MainShell Screen', (WidgetTester tester) async {
    // Build HiveMuseApp and trigger frame
    await tester.pumpWidget(const HiveMuseApp());

    // Verify Onboarding screen components are rendered
    expect(find.text('HiveMuse'), findsOneWidget);
    expect(find.text('Start Your\nSonic Journey'), findsOneWidget);
    expect(find.text('Turn on your music'), findsOneWidget);

    // Tap "Turn on your music" CTA
    await tester.tap(find.text('Turn on your music'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify main screen header appears
    expect(find.text('Good Morning!'), findsOneWidget);
    expect(find.text('Antony Das'), findsOneWidget);
    expect(find.text('Select Categories'), findsOneWidget);
    expect(find.text('Popular Songs'), findsNWidgets(2));
  });
}

