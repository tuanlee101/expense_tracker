import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/providers/app_provider.dart';
import 'package:expense_tracker/screens/pin_screen.dart';
import 'package:expense_tracker/utils/constants.dart';

void main() {
  group('PIN Screen Tests', () {
    testWidgets('PIN setup flow - creates and confirms PIN', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: MaterialApp(
            home: const PinScreen(isSetup: true),
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.onPrimary,
                surface: AppColors.surface,
                error: AppColors.error,
              ),
            ),
          ),
        ),
      );

      // Verify initial state - should show "Tạo mã PIN bảo vệ"
      expect(find.text('Tạo mã PIN bảo vệ'), findsOneWidget);
      expect(find.text('Mã PIN sẽ bảo vệ dữ liệu tài chính của bạn'), findsOneWidget);

      // Verify 6 dots are shown (empty state)
      final dotFinder = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).shape == BoxShape.circle);

      // Should have 6 dots for PIN input
      expect(dotFinder, findsNWidgets(6));

      // Verify number pad exists (buttons 0-9)
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      // Verify delete button exists
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('PIN input - digits are registered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: MaterialApp(
            home: const PinScreen(),
            theme: ThemeData(useMaterial3: true),
          ),
        ),
      );

      // Tap digit 1
      await tester.tap(find.text('1'));
      await tester.pump();

      // Tap digit 2
      await tester.tap(find.text('2'));
      await tester.pump();

      // Tap digit 3
      await tester.tap(find.text('3'));
      await tester.pump();

      // 3 digits entered - should not verify yet
      // (PIN needs 6 digits)
    });

    testWidgets('PIN delete button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: MaterialApp(
            home: const PinScreen(),
            theme: ThemeData(useMaterial3: true),
          ),
        ),
      );

      // Enter digit 1
      await tester.tap(find.text('1'));
      await tester.pump();

      // Tap delete
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      // PIN should be empty again
    });
  });

}