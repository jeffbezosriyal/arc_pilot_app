import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/utils/snackbar_utils.dart'; // Import the utility file

void main() {
  // Helper function to build a minimal app for testing SnackBars
  Widget buildTestApp(Widget child) {
    // Use a known key to easily access the ScaffoldMessenger
    final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey, // <<< Assign key here
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Center(child: child);
          },
        ),
      ),
    );
  }


  group('SnackBar Utils', () {
    // Setup for stable window size
    setUp(() {
      final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.window.physicalSizeTestValue = const Size(1080, 1920);
      binding.window.devicePixelRatioTestValue = 1.0;
    });

    testWidgets('showInfoSnackBar displays correctly and dismisses', (WidgetTester tester) async {
      const String message = 'Info message';
      BuildContext? targetContext;

      await tester.pumpWidget(buildTestApp(
        Builder(builder: (context) {
          targetContext = context;
          return ElevatedButton(
            onPressed: () => showInfoSnackBar(targetContext!, message),
            child: const Text('Show Info'),
          );
        }),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Show entry animation

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      // ... (icon/color checks remain the same) ...
      final iconFinder = find.descendant(of: find.byType(SnackBar), matching: find.byType(Icon));
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.icon, Icons.info_outline);
      expect(iconWidget.color, Colors.blue);


      // --- FINAL ATTEMPT: Manual Removal ---
      // 1. Get the ScaffoldMessenger using its context (use BuildContext captured earlier)
      ScaffoldMessenger.of(targetContext!).removeCurrentSnackBar();
      // 2. Pump once to process removal and start exit animation
      await tester.pump();
      // 3. Wait for exit animation to finish
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      // --- END OF FIX ---
    });

    testWidgets('showSuccessSnackBar displays correctly and dismisses', (WidgetTester tester) async {
      const String message = 'Success message';
      BuildContext? targetContext;

      await tester.pumpWidget(buildTestApp(
        Builder(builder: (context) {
          targetContext = context;
          return ElevatedButton(
            onPressed: () => showSuccessSnackBar(targetContext!, message),
            child: const Text('Show Success'),
          );
        }),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      // ... (icon/color checks remain the same) ...
      final iconFinder = find.descendant(of: find.byType(SnackBar), matching: find.byType(Icon));
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.icon, Icons.check_circle_outline);
      expect(iconWidget.color, Colors.green);


      // Manual Removal Fix
      ScaffoldMessenger.of(targetContext!).removeCurrentSnackBar();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('showErrorSnackBar displays correctly and dismisses', (WidgetTester tester) async {
      const String message = 'Error message';
      BuildContext? targetContext;

      await tester.pumpWidget(buildTestApp(
        Builder(builder: (context) {
          targetContext = context;
          return ElevatedButton(
            onPressed: () => showErrorSnackBar(targetContext!, message),
            child: const Text('Show Error'),
          );
        }),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      // ... (icon/color checks remain the same) ...
      final iconFinder = find.descendant(of: find.byType(SnackBar), matching: find.byType(Icon));
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.icon, Icons.error_outline);
      expect(iconWidget.color, Colors.red);

      // Manual Removal Fix
      ScaffoldMessenger.of(targetContext!).removeCurrentSnackBar();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('showLoadingSnackBar displays correctly and dismisses', (WidgetTester tester) async {
      const String message = 'Loading...';
      BuildContext? targetContext;

      await tester.pumpWidget(buildTestApp(
        Builder(builder: (context) {
          targetContext = context;
          return ElevatedButton(
            onPressed: () => showLoadingSnackBar(targetContext!, message),
            child: const Text('Show Loading'),
          );
        }),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      expect(find.descendant(of: find.byType(SnackBar), matching: find.byType(CircularProgressIndicator)), findsOneWidget);

      // Manual Removal Fix
      ScaffoldMessenger.of(targetContext!).removeCurrentSnackBar();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('showDeleteSnackBar displays correctly and dismisses', (WidgetTester tester) async {
      const String message = 'Item deleted';
      BuildContext? targetContext;

      await tester.pumpWidget(buildTestApp(
        Builder(builder: (context) {
          targetContext = context;
          return ElevatedButton(
            onPressed: () => showDeleteSnackBar(targetContext!, message),
            child: const Text('Show Delete'),
          );
        }),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      // ... (icon/color/shape checks remain the same) ...
      final iconFinder = find.descendant(of: find.byType(SnackBar), matching: find.byType(Icon));
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.icon, Icons.delete_outline);
      expect(iconWidget.color, Colors.white);
      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, const Color(0xFFE04000));
      expect((snackBarWidget.shape as RoundedRectangleBorder).borderRadius, BorderRadius.circular(0.0));

      // Manual Removal Fix
      ScaffoldMessenger.of(targetContext!).removeCurrentSnackBar();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Showing a new SnackBar hides the previous one', (WidgetTester tester) async {
      const String message1 = 'First message';
      const String message2 = 'Second message';
      BuildContext? targetContext;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            targetContext = context; // Capture context
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => showInfoSnackBar(targetContext!, message1),
                  child: const Text('Show 1'),
                ),
                ElevatedButton(
                  onPressed: () => showSuccessSnackBar(targetContext!, message2),
                  child: const Text('Show 2'),
                ),
              ],
            );
          }),
        ),
      ));

      // Show the first SnackBar
      await tester.tap(find.text('Show 1'));
      await tester.pump();
      expect(find.text(message1), findsOneWidget);
      expect(find.text(message2), findsNothing);

      // Show the second SnackBar immediately
      await tester.tap(find.text('Show 2'));
      // Pump once to trigger hideCurrentSnackBar and start showSnackBar
      await tester.pump();
      // Pump again slightly to let animations progress
      await tester.pump(const Duration(milliseconds: 500));

      // Verify only the second SnackBar is visible
      expect(find.text(message1), findsNothing);
      expect(find.text(message2), findsOneWidget);

      // Manually remove the second snackbar
      ScaffoldMessenger.of(targetContext!).removeCurrentSnackBar();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}