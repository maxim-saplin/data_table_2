import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';

void main() {
  group('PaginatedDataTable headerFlex', () {
    testWidgets('uses default flex of 1 when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaginatedDataTable(
            header: const Text('Test Header'),
            source: TestDataSource(),
            columns: const [
              DataColumn(label: Text('Column 1')),
            ],
          ),
        ),
      );

      // The header should be wrapped in a Flexible with flex: 1
      final Flexible flexible = tester.widget<Flexible>(
        find.descendant(
          of: find.byType(PaginatedDataTable),
          matching: find.byType(Flexible),
        ),
      );
      expect(flexible.flex, equals(1));
    });

    testWidgets('uses custom flex value when specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaginatedDataTable(
            headerFlex: 3,
            header: const Text('Test Header'),
            source: TestDataSource(),
            columns: const [
              DataColumn(label: Text('Column 1')),
            ],
          ),
        ),
      );

      // The header should be wrapped in a Flexible with flex: 3
      final Flexible flexible = tester.widget<Flexible>(
        find.descendant(
          of: find.byType(PaginatedDataTable),
          matching: find.byType(Flexible),
        ),
      );
      expect(flexible.flex, equals(3));
    });

    testWidgets('throws assertion error for invalid flex values', (WidgetTester tester) async {
      expect(
        () => PaginatedDataTable(
          headerFlex: 0, // Invalid: must be > 0
          header: const Text('Test Header'),
          source: TestDataSource(),
          columns: const [
            DataColumn(label: Text('Column 1')),
          ],
        ),
        throwsAssertionError,
      );

      expect(
        () => PaginatedDataTable(
          headerFlex: -1, // Invalid: must be > 0
          header: const Text('Test Header'),
          source: TestDataSource(),
          columns: const [
            DataColumn(label: Text('Column 1')),
          ],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('works with selected row count display', (WidgetTester tester) async {
      final TestDataSource source = TestDataSource(allowSelection: true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: PaginatedDataTable(
            headerFlex: 2,
            header: const Text('Test Header'),
            source: source,
            columns: const [
              DataColumn(label: Text('Column 1')),
            ],
          ),
        ),
      );

      // Select a row to trigger the selected row count display
      await tester.tap(find.text('Frozen yogurt (0)'));
      await tester.pumpAndSettle();

      // The selected row count should be wrapped in a Flexible with flex: 2
      final Flexible flexible = tester.widget<Flexible>(
        find.descendant(
          of: find.byType(PaginatedDataTable),
          matching: find.byType(Flexible),
        ),
      );
      expect(flexible.flex, equals(2));
    });
  });
} 