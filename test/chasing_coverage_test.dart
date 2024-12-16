@TestOn('!chrome')
library;

import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';

void main() {
  testWidgets('DataTable2 renders with DataRow.index()',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Material(
      child: buildTable(rows: [
        DataRow2.byIndex(
          index: 2,
          cells: const <DataCell>[
            DataCell(
              Text("A1"),
            ),
            DataCell(Text('B1')),
            DataCell(Text('C1')),
          ],
        ),
        DataRow2.byIndex(
          index: 1,
          cells: const <DataCell>[
            DataCell(
              Text("A2"),
            ),
            DataCell(Text('B2')),
            DataCell(Text('C2')),
          ],
        )
      ]),
    )));

    expect(find.text('A1'), findsOneWidget);
    expect(find.text('C2'), findsOneWidget);
  });

  testWidgets('DataTable2 applies placeholder text style',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Material(
      child: buildTable(rows: [
        DataRow2.byIndex(
          index: 2,
          cells: const <DataCell>[
            DataCell(Text("A1"), placeholder: true),
            DataCell(Text('B1')),
            DataCell(Text('C1')),
          ],
        ),
        DataRow2.byIndex(
          index: 1,
          cells: const <DataCell>[
            DataCell(
              Text("A2"),
            ),
            DataCell(Text('B2')),
            DataCell(Text('C2')),
          ],
        )
      ]),
    )));

    var t = find
        .ancestor(of: find.text('A1'), matching: find.byType(DefaultTextStyle))
        .evaluate()
        .first
        .widget as DefaultTextStyle;

    expect(t.style.color!.a, 0.6);
  });
  testWidgets('DataTable2, placholder text is 0.6 opacity',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Material(
      child: buildTable(rows: [
        DataRow2.byIndex(
          index: 2,
          cells: const <DataCell>[
            DataCell(Text("A1"), placeholder: true),
            DataCell(Text('B1')),
            DataCell(Text('C1')),
          ],
        ),
        DataRow2.byIndex(
          index: 1,
          cells: const <DataCell>[
            DataCell(
              Text("A2"),
            ),
            DataCell(Text('B2')),
            DataCell(Text('C2')),
          ],
        )
      ]),
    )));

    var t = find
        .ancestor(of: find.text('A1'), matching: find.byType(DefaultTextStyle))
        .evaluate()
        .first
        .widget as DefaultTextStyle;

    expect(t.style.color!.a, 0.6);
  });

  testWidgets('DataTable2, divider thickness 0 shows no border',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Material(
      child: buildTable(showBottomBorder: true, dividerThickness: 0, rows: [
        DataRow2.byIndex(
          index: 2,
          cells: const <DataCell>[
            DataCell(Text("A1"), placeholder: true),
            DataCell(Text('B1')),
            DataCell(Text('C1')),
          ],
        ),
        DataRow2.byIndex(
          index: 1,
          cells: const <DataCell>[
            DataCell(
              Text("A2"),
            ),
            DataCell(Text('B2')),
            DataCell(Text('C2')),
          ],
        )
      ]),
    )));

    expect(find.byType(Table), findsNWidgets(2));

    expect(
        find
            .byType(Table)
            .evaluate()
            .where((e) => (e.widget as Table).border != null)
            .length,
        0);
  });

  testWidgets('DataRow2.clone() creates a copy with the same properties',
      (WidgetTester tester) async {
    const originalKey = ValueKey('original');
    const cellText = Text('Cell');
    final originalRow = DataRow2(
      key: originalKey,
      selected: true,
      cells: const <DataCell>[DataCell(cellText)],
      specificRowHeight: 42.0,
      onTap: () {},
      onDoubleTap: () {},
      onLongPress: () {},
      onSecondaryTap: () {},
      onSecondaryTapDown: (TapDownDetails details) {},
    );

    final clonedRow = originalRow.clone();

    // Verify that the cloned DataRow2 has the same properties as the original
    expect(clonedRow.key, equals(originalKey));
    expect(clonedRow.selected, isTrue);
    expect(clonedRow.cells.length, equals(1));
    expect((clonedRow.cells.first.child as Text), equals(cellText));
    expect(clonedRow.specificRowHeight, equals(42.0));
    expect(clonedRow.onTap, isNotNull);
    expect(clonedRow.onDoubleTap, isNotNull);
    expect(clonedRow.onLongPress, isNotNull);
    expect(clonedRow.onSecondaryTap, isNotNull);
    expect(clonedRow.onSecondaryTapDown, isNotNull);
  });

  testWidgets('DataRow2.clone() creates a copy with the overriden properties',
      (WidgetTester tester) async {
    const originalKey = ValueKey('original');
    const cellText = Text('Cell');
    final originalRow = DataRow2(
      key: originalKey,
      selected: true,
      cells: const <DataCell>[DataCell(cellText)],
      specificRowHeight: 42.0,
      onTap: () {},
      onDoubleTap: () {},
      onLongPress: () {},
      onSecondaryTap: () {},
      onSecondaryTapDown: (TapDownDetails details) {},
    );

    final modifiedRow = originalRow.clone(
      selected: false,
      specificRowHeight: 21.0,
    );

    // Verify that the modified DataRow2 has the overriden properties
    expect(modifiedRow.key, equals(originalKey));
    expect(modifiedRow.selected, isFalse);
    expect(modifiedRow.cells.length, equals(1));
    expect((modifiedRow.cells.first.child as Text), equals(cellText));
    expect(modifiedRow.specificRowHeight, equals(21.0));
  });

  testWidgets('DataTable2, showing sort arrow when changing sort column',
      (WidgetTester tester) async {
    var sortCol = 1;
    var asc = false;
    var trigger = StreamController();

    Widget sortedColTable(int col, bool direction) => buildTable(
          sortColumnIndex: col,
          sortAscending: direction,
          dividerThickness: 0.0,
          columns: [
            DataColumn2(
                label: const Text('A'),
                onSort: (col, direction) {
                  sortCol = 0;
                  asc = !asc;
                  trigger.add(true);
                }),
            DataColumn2(label: const Text('B'), onSort: (col, asc) {}),
            DataColumn2(label: const Text('C'), onSort: (col, asc) {})
          ],
          rows: [
            DataRow2.byIndex(
              index: 2,
              cells: const <DataCell>[
                DataCell(Text("A1")),
                DataCell(Text('B1')),
                DataCell(Text('C1')),
              ],
            ),
            DataRow2.byIndex(
              index: 1,
              cells: const <DataCell>[
                DataCell(
                  Text("A2"),
                ),
                DataCell(Text('B2')),
                DataCell(Text('C2')),
              ],
            )
          ],
        );

    var widget = StreamBuilder(
        stream: trigger.stream,
        builder: (c, s) {
          return sortedColTable(sortCol, asc);
        });

    await tester.pumpWidget(MaterialApp(home: Material(child: widget)));

    expect(
        (find.byType(Opacity).evaluate().first.widget as Opacity).opacity, 0);

    // Going through all paths in _SortArrowState.didUpdateWidget
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(
        (find.byType(Opacity).evaluate().first.widget as Opacity).opacity, 1);

    expect(true, true);
  });
}
