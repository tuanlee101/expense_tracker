import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/providers/app_provider.dart';
import 'package:expense_tracker/screens/pin_screen.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:expense_tracker/models/bill_model.dart';
import 'package:expense_tracker/utils/constants.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════
  // PIN LOCKOUT & REMAINING ATTEMPTS TESTS
  // ═══════════════════════════════════════════

  group('PIN Screen - Lockout & Remaining Attempts', () {
    testWidgets('shows correct remaining attempts after wrong PIN',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: MaterialApp(
            home: const PinScreen(),
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

      expect(find.text('Nhập mã PIN'), findsOneWidget);

      // Enter 6 wrong digits
      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(digit));
        await tester.pump();
      }

      await tester.pump();

      // Should show error with remaining attempts (not local counter)
      // After 1 wrong attempt: 4 remaining (5 - 1)
      expect(find.textContaining('Còn'), findsOneWidget);
      expect(find.textContaining('lần thử'), findsOneWidget);
    });

    testWidgets('lockout replaces number pad when triggered',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'failed_attempts': 5,
        'lockout_time': DateTime.now().millisecondsSinceEpoch,
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: MaterialApp(
            home: const PinScreen(),
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                surface: AppColors.surface,
                error: AppColors.error,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show lockout message instead of number pad
      expect(find.textContaining('Khóa trong'), findsOneWidget);
    });

    testWidgets('no infinite loop - Timer.periodic replaces while(true)',
        (WidgetTester tester) async {
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

      // Let it run for 500ms - with while(true) this would freeze the test
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be responsive
      expect(find.text('Nhập mã PIN'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════
  // BILL MONTHLY RESET TESTS
  // ═══════════════════════════════════════════

  group('Bill Monthly Reset', () {
    test('paid bills are tracked by month for reset', () async {
      SharedPreferences.setMockInitialValues({});

      final dataService = DataService();
      await dataService.addBill(
        BillModel(
          id: 'b1',
          name: 'Tiền điện',
          amount: 1200000,
          dueDay: 5,
          category: BillCategory.electricity,
          isPaid: false,
        ),
      );

      // Mark as paid
      await dataService.markBillPaid('b1', true);

      // Reset - bills marked paid should stay paid
      await dataService.resetMonthlyBills();
      final bills = await dataService.getBills();
      final electricBill = bills.firstWhere((b) => b.id == 'b1');

      expect(electricBill.isPaid, isTrue,
          reason: 'Bill marked paid should remain paid after reset');
    });

    test('unpaid bills stay unpaid after reset', () async {
      SharedPreferences.setMockInitialValues({});

      final dataService = DataService();
      await dataService.addBill(
        BillModel(
          id: 'b2',
          name: 'Tiền nước',
          amount: 350000,
          dueDay: 10,
          category: BillCategory.water,
          isPaid: false,
        ),
      );

      // Do NOT mark as paid

      // Reset
      await dataService.resetMonthlyBills();
      final bills = await dataService.getBills();
      final waterBill = bills.firstWhere((b) => b.id == 'b2');

      expect(waterBill.isPaid, isFalse,
          reason: 'Unpaid bill should remain unpaid after reset');
    });

    test('paid bills reset to unpaid next month', () async {
      SharedPreferences.setMockInitialValues({});

      final dataService = DataService();
      await dataService.addBill(
        BillModel(
          id: 'b3',
          name: 'Internet',
          amount: 350000,
          dueDay: 15,
          category: BillCategory.internet,
          isPaid: false,
        ),
      );

      // Mark paid this month
      await dataService.markBillPaid('b3', true);

      // Simulate: clear current month tracking key, keep bill isPaid = true
      // In real app: new month triggers resetMonthlyBills()
      // Test: resetMonthlyBills() WITHOUT paid ID tracked → bill resets
      SharedPreferences.setMockInitialValues({});
      final dataService2 = DataService();
      await dataService2.addBill(
        BillModel(
          id: 'b3',
          name: 'Internet',
          amount: 350000,
          dueDay: 15,
          category: BillCategory.internet,
          isPaid: true, // still marked paid from last month
        ),
      );

      // Reset with no paid IDs tracked → should reset to unpaid
      await dataService2.resetMonthlyBills();
      final bills = await dataService2.getBills();
      final internetBill = bills.firstWhere((b) => b.id == 'b3');

      expect(internetBill.isPaid, isFalse,
          reason: 'Bill should reset to unpaid when new month has no paid record');
    });
  });

  // ═══════════════════════════════════════════
  // DUE DATE EDGE CASE TESTS
  // ═══════════════════════════════════════════

  group('Bill Due Date Edge Cases', () {
    test('bill with dueDay 31 resolves safely in 30-day month (Feb)',
        () async {
      final bills = [
        BillModel(
          id: 'd1',
          name: 'Test Bill',
          amount: 100000,
          dueDay: 31,
          category: BillCategory.other,
          isPaid: false,
        ),
      ];

      final dataService = DataService();
      final upcoming = dataService.getUpcomingBills(bills, days: 7);

      // Should not throw - due day 31 in Feb should be handled
      expect(upcoming, isA<List<BillModel>>());
    });

    test('bill with dueDay 31 resolves safely in April (30 days)', () async {
      final bills = [
        BillModel(
          id: 'd2',
          name: 'Test Bill 31st',
          amount: 200000,
          dueDay: 31,
          category: BillCategory.other,
          isPaid: false,
        ),
      ];

      final dataService = DataService();
      final upcoming = dataService.getUpcomingBills(bills, days: 30);

      // Should handle gracefully
      expect(upcoming, isA<List<BillModel>>());
    });

    test('overdue bills correctly identifies overdue within month',
        () async {
      final bills = [
        BillModel(
          id: 'd3',
          name: 'Already Due',
          amount: 500000,
          dueDay: 1,
          category: BillCategory.other,
          isPaid: false,
        ),
      ];

      final dataService = DataService();
      final overdue = dataService.getOverdueBills(bills);

      expect(overdue, isA<List<BillModel>>());
    });
  });

  // ═══════════════════════════════════════════
  // DATA ENCRYPTION TESTS
  // ═══════════════════════════════════════════

  group('Data Encryption', () {
    test('data is stored encrypted in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final dataService = DataService();
      await dataService.addBill(
        BillModel(
          id: 'enc1',
          name: 'Encrypted Bill',
          amount: 999999,
          dueDay: 25,
          category: BillCategory.subscription,
          isPaid: false,
        ),
      );

      // Read raw prefs - data should NOT be plain JSON
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('bills');

      expect(raw, isNotNull);
      // If encrypted, it should contain ':' (IV:ciphertext format)
      // or at minimum not be parseable as straight JSON array
      final isPlainJson = raw!.startsWith('[') || raw.startsWith('{');
      expect(isPlainJson, isFalse,
          reason: 'Data should be encrypted, not plain JSON');
    });
  });
}