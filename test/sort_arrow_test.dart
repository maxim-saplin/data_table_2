import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix3;
import 'dart:math' as math;

void main() {
  testWidgets('Testing DataTable2 for new sortArrowAnimationDuration and sortArrowIcon parameters',
      (tester) async {
    IconData iconForTest = Icons.keyboard_arrow_up;
    final List<String> log = <String>[];

    bool sort = true;
    int currentColumnIndex = 0;

    Widget buildTable({
      required IconData sortArrowIcon,
      required Duration sortArrowAnimationDuration,
      bool sortAscending = true,
    }) {
      return DataTable2(
        sortArrowIcon: sortArrowIcon,
        sortArrowAnimationDuration: sortArrowAnimationDuration,
        //
        sortAscending: sort,
        sortColumnIndex: currentColumnIndex,
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: [
          DataColumn2(
            label: const Text('Column A'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {
              //log.add('column-sort: $columnIndex $ascending');

              // the test doesn't seem to rebuild DataTable2 after onSort so i can't
              // test whether tapping the column header will toggle sortAscending.
              sort = !sort;
              currentColumnIndex = columnIndex;
              // print('column-sort: $columnIndex $ascending');
              // print('sort: $sort');
              print('onSort() --> [column: $columnIndex, ascending: $ascending], sort: $sort');

              //stopper;
            },
          ),
          const DataColumn2(
            label: Text('Column B'),
          ),
          const DataColumn2(
            label: Text('Column C'),
          ),
          const DataColumn2(
            label: Text('Column D'),
          ),
          const DataColumn2(
            label: Text('Column NUMBERS'),
            numeric: true,
          ),
        ],
        rows: List<DataRow>.generate(
          100,
          (index) => DataRow(cells: [
            DataCell(Text('A' * (10 - index % 10))),
            DataCell(Text('B' * (10 - (index + 5) % 10))),
            DataCell(Text('C' * (15 - (index + 5) % 10))),
            DataCell(Text('D' * (15 - (index + 10) % 10))),
            DataCell(Text(((index + 0.1) * 25.4).toString()))
          ]),
        ),
      );
    }

    Widget buildTableWithDefaultIcon({
      bool sortAscending = true,
    }) {
      return DataTable2(
        // sortArrowIcon: sortArrowIcon,
        // sortArrowAnimationDuration: sortArrowAnimationDuration,
        //
        sortAscending: sort,
        sortColumnIndex: currentColumnIndex,
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: [
          DataColumn2(
            label: const Text('Column A'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {
              //log.add('column-sort: $columnIndex $ascending');

              // the test doesn't seem to rebuild DataTable2 after onSort so i can't
              // test whether tapping the column header will toggle sortAscending.
              sort = !sort;
              currentColumnIndex = columnIndex;
              // print('column-sort: $columnIndex $ascending');
              // print('sort: $sort');
              print('onSort() --> [column: $columnIndex, ascending: $ascending], sort: $sort');

              //stopper;
            },
          ),
          const DataColumn2(
            label: Text('Column B'),
          ),
          const DataColumn2(
            label: Text('Column C'),
          ),
          const DataColumn2(
            label: Text('Column D'),
          ),
          const DataColumn2(
            label: Text('Column NUMBERS'),
            numeric: true,
          ),
        ],
        rows: List<DataRow>.generate(
          100,
          (index) => DataRow(cells: [
            DataCell(Text('A' * (10 - index % 10))),
            DataCell(Text('B' * (10 - (index + 5) % 10))),
            DataCell(Text('C' * (15 - (index + 5) % 10))),
            DataCell(Text('D' * (15 - (index + 10) % 10))),
            DataCell(Text(((index + 0.1) * 25.4).toString()))
          ]),
        ),
      );
    }

    // TESTS................

    // verify that default icon is created if parameter isn't used
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: buildTableWithDefaultIcon(
            sortAscending: true,
          ),
        ),
      ),
    );

    // test for default icon
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

    // verify that custom icon is applied if parameter is used
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: buildTable(
            sortArrowIcon: iconForTest,
            sortArrowAnimationDuration: const Duration(milliseconds: 0),
            sortAscending: true,
          ),
        ),
      ),
    );

    // test for custom icon
    //final iconKeyboardArrowUp = find.byIcon(iconForTest);
    expect(find.byIcon(iconForTest), findsOneWidget);

    // test for initial icon rotation
    Transform transformOfArrow = tester.widget<Transform>(
      find.widgetWithIcon(Transform, iconForTest).first,
    );
    expect(transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));
    print('original ascending rotation: \n${transformOfArrow.transform.getRotation()}');

    // tap column header to toggle sorting...
    // ! this will call onSort but DataTable2 does not get rebuilt afterward with
    // ! the new sortAscending value and therefore the arrow does not rotate
    print('tap Column A...');
    await tester.tap(find.text('Column A'));
    await tester.pump(const Duration(milliseconds: 200));

    // check icon rotation
    transformOfArrow = tester.widget<Transform>(find.widgetWithIcon(Transform, iconForTest).first);
    //expect(transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));
    print('rotation: \n${transformOfArrow.transform.getRotation()}');

    // tap column header to toggle sorting
    print('tap Column A...');
    await tester.tap(find.text('Column A'));
    await tester.pump(const Duration(milliseconds: 200));

    // check icon rotation
    transformOfArrow = tester.widget<Transform>(
      find.widgetWithIcon(Transform, iconForTest).first,
    );
    //expect(transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));
    print('rotation: \n${transformOfArrow.transform.getRotation()}');

    // rebuild with descending icon
    // await tester.pumpWidget(
    //   MaterialApp(
    //     home: Material(
    //       child: buildTable(
    //         sortArrowIcon: iconForTest,
    //         sortArrowAnimationDuration: const Duration(milliseconds: 0),
    //         sortAscending: false,
    //       ),
    //     ),
    //   ),
    // );

    // check for icon rotation (descending)
    //transformOfArrow = tester
    //    .widget<Transform>(find.widgetWithIcon(Transform, iconForTest).first);
    //expect(transformOfArrow.transform.getRotation(), equals(Matrix3.rotationZ(math.pi)));
    //print('descending rotation: \n${transformOfArrow.transform.getRotation()}');

    // tap 'Column A' to sort from descending to ascending
    //print('tapping column a');
    //await tester.tap(find.text('Column A'));
    //expect(log, <String>['column-sort: 0 true']);
    //print('log: $log');
    //log.clear();
    //transformOfArrow = tester.widget<Transform>(find.widgetWithIcon(Transform, iconForTest).first);
    //print('current rotation: \n${transformOfArrow.transform.getRotation()}');

    // tap 'Column A' to sort from ascending to descending
    //print('tapping column a');
    //await tester.tap(find.text('Column A'));
    //expect(log, <String>['column-sort: 0 false']);
    //print('log: $log');
    //log.clear();
    //transformOfArrow = tester.widget<Transform>(find.widgetWithIcon(Transform, iconForTest).first);
    //print('current rotation: \n${transformOfArrow.transform.getRotation()}');
    //expect(transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));
  });
}
