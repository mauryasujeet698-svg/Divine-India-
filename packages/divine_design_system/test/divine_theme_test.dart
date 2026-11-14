import 'package:divine_design_system/divine_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme exposes the Divine India palette', () {
    final theme = DivineTheme.light;

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, DivineColors.saffron);
    expect(theme.scaffoldBackgroundColor, DivineColors.ivory);
  });

  testWidgets('brand mark renders the Om identity', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DivineTheme.light,
        home: const Scaffold(
          body: Center(child: DivineBrandMark()),
        ),
      ),
    );

    expect(find.text('ॐ'), findsOneWidget);
    expect(find.text('DIVINE INDIA'), findsOneWidget);
  });
}
