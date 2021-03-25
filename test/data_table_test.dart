// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('!chrome')
import 'dart:math' as math;

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix3;

import 'mock_canvas.dart';
import 'data_table_test_utils.dart';

void main() {
  testWidgets('DataTable2 control test', (WidgetTester tester) async {
    final List<String> log = <String>[];

    Widget buildTable({int? sortColumnIndex, bool sortAscending = true}) {
      return DataTable2(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        onSelectAll: (bool? value) {
          log.add('select-all: $value');
        },
        columns: <DataColumn2>[
          const DataColumn2(
            label: Text('Name'),
            tooltip: 'Name',
          ),
          DataColumn2(
            label: const Text('Calories'),
            tooltip: 'Calories',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {
              log.add('column-sort: $columnIndex $ascending');
            },
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            key: ValueKey<String>(dessert.name),
            onSelectChanged: (bool? selected) {
              log.add('row-selected: ${dessert.name}');
            },
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text('${dessert.calories}'),
                showEditIcon: true,
                onTap: () {
                  log.add('cell-tap: ${dessert.calories}');
                },
              ),
            ],
          );
        }).toList(),
      );
    }

    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable()),
    ));

    await tester.tap(find.byType(Checkbox).first);

    expect(log, <String>['select-all: true']);
    log.clear();

    await tester.tap(find.text('Cupcake'));

    expect(log, <String>['row-selected: Cupcake']);
    log.clear();

    await tester.tap(find.text('Calories'));

    expect(log, <String>['column-sort: 1 true']);
    log.clear();

    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable(sortColumnIndex: 1)),
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await tester.tap(find.text('Calories'));

    expect(log, <String>['column-sort: 1 false']);
    log.clear();

    await tester.pumpWidget(MaterialApp(
      home:
          Material(child: buildTable(sortColumnIndex: 1, sortAscending: false)),
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    await tester.tap(find.text('375'));

    expect(log, <String>['cell-tap: 375']);
    log.clear();

    await tester.tap(find.byType(Checkbox).last);

    expect(log, <String>['row-selected: KitKat']);
    log.clear();
  });

  testWidgets('DataTable2 control test - tristate',
      (WidgetTester tester) async {
    final List<String> log = <String>[];
    const int numItems = 3;
    Widget buildTable(List<bool> selected, {int? disabledIndex}) {
      return DataTable2(
        onSelectAll: (bool? value) {
          log.add('select-all: $value');
        },
        columns: const <DataColumn2>[
          DataColumn2(
            label: Text('Name'),
            tooltip: 'Name',
          ),
        ],
        rows: List<DataRow2>.generate(
          numItems,
          (int index) => DataRow2(
            cells: <DataCell>[DataCell(Text('Row $index'))],
            selected: selected[index],
            onSelectChanged: index == disabledIndex
                ? null
                : (bool? value) {
                    log.add('row-selected: $index');
                  },
          ),
        ),
      );
    }

    // Tapping the parent checkbox when no rows are selected, selects all.
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable(<bool>[false, false, false])),
    ));
    await tester.tap(find.byType(Checkbox).first);

    expect(log, <String>['select-all: true']);
    log.clear();

    // Tapping the parent checkbox when some rows are selected, selects all.
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable(<bool>[true, false, true])),
    ));
    await tester.tap(find.byType(Checkbox).first);

    expect(log, <String>['select-all: true']);
    log.clear();

    // Tapping the parent checkbox when all rows are selected, deselects all.
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable(<bool>[true, true, true])),
    ));
    await tester.tap(find.byType(Checkbox).first);

    expect(log, <String>['select-all: false']);
    log.clear();

    // Tapping the parent checkbox when all rows are selected and one is
    // disabled, deselects all.
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: buildTable(
          <bool>[true, true, false],
          disabledIndex: 2,
        ),
      ),
    ));
    await tester.tap(find.byType(Checkbox).first);

    expect(log, <String>['select-all: false']);
    log.clear();
  });

  testWidgets('DataTable2 control test - no checkboxes',
      (WidgetTester tester) async {
    final List<String> log = <String>[];

    Widget buildTable({bool checkboxes = false}) {
      return DataTable2(
        showCheckboxColumn: checkboxes,
        onSelectAll: (bool? value) {
          log.add('select-all: $value');
        },
        columns: const <DataColumn2>[
          DataColumn2(
            label: Text('Name'),
            tooltip: 'Name',
          ),
          DataColumn2(
            label: Text('Calories'),
            tooltip: 'Calories',
            numeric: true,
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            key: ValueKey<String>(dessert.name),
            onSelectChanged: (bool? selected) {
              log.add('row-selected: ${dessert.name}');
            },
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text('${dessert.calories}'),
                showEditIcon: true,
                onTap: () {
                  log.add('cell-tap: ${dessert.calories}');
                },
              ),
            ],
          );
        }).toList(),
      );
    }

    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable()),
    ));

    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(find.text('Cupcake'));

    expect(log, <String>['row-selected: Cupcake']);
    log.clear();

    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable(checkboxes: true)),
    ));

    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    final Finder checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsNWidgets(11));
    await tester.tap(checkboxes.first);

    expect(log, <String>['select-all: true']);
    log.clear();
  });

  testWidgets('DataTable2 overflow test - header', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            headingTextStyle: const TextStyle(
              fontSize: 14.0,
              letterSpacing:
                  0.0, // Will overflow if letter spacing is larger than 0.0.
            ),
            columns: <DataColumn2>[
              DataColumn2(
                label: Text('X' * 2000),
              ),
            ],
            rows: const <DataRow2>[
              DataRow2(
                cells: <DataCell>[
                  DataCell(
                    Text('X'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.renderObject<RenderBox>(find.byType(Text).first).size.width,
        greaterThan(750.0));
    expect(tester.renderObject<RenderBox>(find.byType(Row).first).size.width,
        greaterThan(750.0));
    expect(tester.takeException(),
        isNull); // column overflows table, but text doesn't overflow cell
  }, skip: false);

  testWidgets('DataTable2 overflow test - header with spaces',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            columns: <DataColumn2>[
              DataColumn2(
                label: Text('X ' *
                    2000), // has soft wrap points, but they should be ignored
              ),
            ],
            rows: const <DataRow2>[
              DataRow2(
                cells: <DataCell>[
                  DataCell(
                    Text('X'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.renderObject<RenderBox>(find.byType(Text).first).size.width,
        greaterThan(800.0));
    expect(tester.renderObject<RenderBox>(find.byType(Row).first).size.width,
        greaterThan(800.0));
    expect(tester.takeException(),
        isNull); // column overflows table, but text doesn't overflow cell
  }, skip: true); // https://github.com/flutter/flutter/issues/13512

  testWidgets('DataTable2 overflow test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            columns: const <DataColumn2>[
              DataColumn2(
                label: Text('X'),
              ),
            ],
            rows: <DataRow2>[
              DataRow2(
                cells: <DataCell>[
                  DataCell(
                    Text('X' * 2000),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.renderObject<RenderBox>(find.byType(Text).first).size.width,
        lessThan(750.0));
    expect(tester.renderObject<RenderBox>(find.byType(Row).first).size.width,
        greaterThan(750.0));
    expect(tester.takeException(),
        isNull); // cell overflows table, but text doesn't overflow cell
  });

  testWidgets('DataTable2 overflow test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            columns: const <DataColumn2>[
              DataColumn2(
                label: Text('X'),
              ),
            ],
            rows: <DataRow2>[
              DataRow2(
                cells: <DataCell>[
                  DataCell(
                    Text('X ' * 2000), // wraps
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.renderObject<RenderBox>(find.byType(Text).first).size.width,
        lessThan(800.0));
    expect(tester.renderObject<RenderBox>(find.byType(Row).first).size.width,
        lessThan(800.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('DataTable2 column onSort test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            columns: const <DataColumn2>[
              DataColumn2(
                label: Text('Dessert'),
              ),
            ],
            rows: const <DataRow2>[
              DataRow2(
                cells: <DataCell>[
                  DataCell(
                    Text('Lollipop'), // wraps
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Dessert'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('DataTable2 sort indicator orientation',
      (WidgetTester tester) async {
    Widget buildTable({bool sortAscending = true}) {
      return DataTable2(
        sortColumnIndex: 0,
        sortAscending: sortAscending,
        columns: <DataColumn2>[
          DataColumn2(
            label: const Text('Name'),
            tooltip: 'Name',
            onSort: (int columnIndex, bool ascending) {},
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
            ],
          );
        }).toList(),
      );
    }

    // Check for ascending list
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable(sortAscending: true)),
    ));
    // The `tester.widget` ensures that there is exactly one upward arrow.
    Transform transformOfArrow = tester
        .widget<Transform>(find.widgetWithIcon(Transform, Icons.arrow_upward));
    expect(
        transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));

    // Check for descending list.
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable(sortAscending: false)),
    ));
    await tester.pumpAndSettle();
    // The `tester.widget` ensures that there is exactly one upward arrow.
    transformOfArrow = tester
        .widget<Transform>(find.widgetWithIcon(Transform, Icons.arrow_upward));
    expect(transformOfArrow.transform.getRotation(),
        equals(Matrix3.rotationZ(math.pi)));
  });

  testWidgets('DataTable2 row onSelectChanged test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            columns: const <DataColumn2>[
              DataColumn2(
                label: Text('Dessert'),
              ),
            ],
            rows: const <DataRow2>[
              DataRow2(
                cells: <DataCell>[
                  DataCell(
                    Text('Lollipop'), // wraps
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Lollipop'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('DataTable2 custom row height', (WidgetTester tester) async {
    Widget buildCustomTable({
      int? sortColumnIndex,
      bool sortAscending = true,
      double dataRowHeight = 48.0,
      double headingRowHeight = 56.0,
    }) {
      return DataTable2(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        onSelectAll: (bool? value) {},
        dataRowHeight: dataRowHeight,
        headingRowHeight: headingRowHeight,
        columns: <DataColumn2>[
          const DataColumn2(
            label: Text('Name'),
            tooltip: 'Name',
          ),
          DataColumn2(
            label: const Text('Calories'),
            tooltip: 'Calories',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {},
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            key: ValueKey<String>(dessert.name),
            onSelectChanged: (bool? selected) {},
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text('${dessert.calories}'),
                showEditIcon: true,
                onTap: () {},
              ),
            ],
          );
        }).toList(),
      );
    }

    // DEFAULT VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: DataTable2(
          onSelectAll: (bool? value) {},
          columns: <DataColumn2>[
            const DataColumn2(
              label: Text('Name'),
              tooltip: 'Name',
            ),
            DataColumn2(
              label: const Text('Calories'),
              tooltip: 'Calories',
              numeric: true,
              onSort: (int columnIndex, bool ascending) {},
            ),
          ],
          rows: kDesserts.map<DataRow2>((Dessert dessert) {
            return DataRow2(
              key: ValueKey<String>(dessert.name),
              onSelectChanged: (bool? selected) {},
              cells: <DataCell>[
                DataCell(
                  Text(dessert.name),
                ),
                DataCell(
                  Text('${dessert.calories}'),
                  showEditIcon: true,
                  onTap: () {},
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ));

    // The finder matches with the Container of the cell content, as well as the
    // Container wrapping the whole table. The first one is used to test row
    // heights.
    Finder findFirstContainerFor(String text) =>
        find.widgetWithText(Container, text).first;

    expect(tester.getSize(findFirstContainerFor('Name')).height, 56.0);
    expect(tester.getSize(findFirstContainerFor('Frozen yogurt')).height, 48.0);

    // CUSTOM VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildCustomTable(headingRowHeight: 48.0)),
    ));
    expect(tester.getSize(findFirstContainerFor('Name')).height, 48.0);

    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildCustomTable(headingRowHeight: 64.0)),
    ));
    expect(tester.getSize(findFirstContainerFor('Name')).height, 64.0);

    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildCustomTable(dataRowHeight: 30.0)),
    ));
    expect(tester.getSize(findFirstContainerFor('Frozen yogurt')).height, 30.0);

    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildCustomTable(dataRowHeight: 56.0)),
    ));
    expect(tester.getSize(findFirstContainerFor('Frozen yogurt')).height, 56.0);
  });

  testWidgets('DataTable2 custom horizontal padding - checkbox',
      (WidgetTester tester) async {
    const double _defaultHorizontalMargin = 24.0;
    const double _defaultColumnSpacing = 56.0;
    const double _customHorizontalMargin = 10.0;
    const double _customColumnSpacing = 15.0;
    Finder cellContent;
    Finder checkbox;
    Finder padding;

    Widget buildDefaultTable({
      int? sortColumnIndex,
      bool sortAscending = true,
    }) {
      return DataTable2(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        onSelectAll: (bool? value) {},
        columns: <DataColumn2>[
          const DataColumn2(
            label: Text('Name'),
            tooltip: 'Name',
          ),
          DataColumn2(
            label: const Text('Calories'),
            tooltip: 'Calories',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {},
          ),
          DataColumn2(
            label: const Text('Fat'),
            tooltip: 'Fat',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {},
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            key: ValueKey<String>(dessert.name),
            onSelectChanged: (bool? selected) {},
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text('${dessert.calories}'),
                showEditIcon: true,
                onTap: () {},
              ),
              DataCell(
                Text('${dessert.fat}'),
                showEditIcon: true,
                onTap: () {},
              ),
            ],
          );
        }).toList(),
      );
    }

    // DEFAULT VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildDefaultTable()),
    ));

    // default checkbox padding
    checkbox = find.byType(Checkbox).first;
    padding = find.ancestor(of: checkbox, matching: find.byType(Padding));
    expect(
      tester.getRect(checkbox).left - tester.getRect(padding).left,
      _defaultHorizontalMargin,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(checkbox).right,
      _defaultHorizontalMargin / 2,
    );

    // default first column padding
    padding = find.widgetWithText(Padding, 'Frozen yogurt');
    cellContent = find.widgetWithText(Align,
        'Frozen yogurt'); // DataTable2 wraps its DataCells in an Align widget
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _defaultHorizontalMargin / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _defaultColumnSpacing / 2,
    );

    // default middle column padding
    padding = find.widgetWithText(Padding, '159');
    cellContent = find.widgetWithText(Align, '159');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _defaultColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _defaultColumnSpacing / 2,
    );

    // default last column padding
    padding = find.widgetWithText(Padding, '6.0');
    cellContent = find.widgetWithText(Align, '6.0');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _defaultColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _defaultHorizontalMargin,
    );

    Widget buildCustomTable({
      int? sortColumnIndex,
      bool sortAscending = true,
      double? horizontalMargin,
      double? columnSpacing,
    }) {
      return DataTable2(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        onSelectAll: (bool? value) {},
        horizontalMargin: horizontalMargin,
        columnSpacing: columnSpacing,
        columns: <DataColumn2>[
          const DataColumn2(
            label: Text('Name'),
            tooltip: 'Name',
          ),
          DataColumn2(
            label: const Text('Calories'),
            tooltip: 'Calories',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {},
          ),
          DataColumn2(
            label: const Text('Fat'),
            tooltip: 'Fat',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {},
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            key: ValueKey<String>(dessert.name),
            onSelectChanged: (bool? selected) {},
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text('${dessert.calories}'),
                showEditIcon: true,
                onTap: () {},
              ),
              DataCell(
                Text('${dessert.fat}'),
                showEditIcon: true,
                onTap: () {},
              ),
            ],
          );
        }).toList(),
      );
    }

    // CUSTOM VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(
          child: buildCustomTable(
        horizontalMargin: _customHorizontalMargin,
        columnSpacing: _customColumnSpacing,
      )),
    ));

    // custom checkbox padding
    checkbox = find.byType(Checkbox).first;
    padding = find.ancestor(of: checkbox, matching: find.byType(Padding));
    expect(
      tester.getRect(checkbox).left - tester.getRect(padding).left,
      _customHorizontalMargin,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(checkbox).right,
      _customHorizontalMargin / 2,
    );

    // custom first column padding
    padding = find.widgetWithText(Padding, 'Frozen yogurt').first;
    cellContent = find.widgetWithText(Align,
        'Frozen yogurt'); // DataTable2 wraps its DataCells in an Align widget
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _customHorizontalMargin / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _customColumnSpacing / 2,
    );

    // custom middle column padding
    padding = find.widgetWithText(Padding, '159');
    cellContent = find.widgetWithText(Align, '159');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _customColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _customColumnSpacing / 2,
    );

    // custom last column padding
    padding = find.widgetWithText(Padding, '6.0');
    cellContent = find.widgetWithText(Align, '6.0');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _customColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _customHorizontalMargin,
    );
  });

  testWidgets('DataTable2 custom horizontal padding - no checkbox',
      (WidgetTester tester) async {
    const double _defaultHorizontalMargin = 24.0;
    const double _defaultColumnSpacing = 56.0;
    const double _customHorizontalMargin = 10.0;
    const double _customColumnSpacing = 15.0;
    Finder cellContent;
    Finder padding;

    Widget buildDefaultTable({
      int? sortColumnIndex,
      bool sortAscending = true,
    }) {
      return DataTable2(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        columns: <DataColumn2>[
          const DataColumn2(
            label: Text('Name'),
            tooltip: 'Name',
          ),
          DataColumn2(
            label: const Text('Calories'),
            tooltip: 'Calories',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {},
          ),
          DataColumn2(
            label: const Text('Fat'),
            tooltip: 'Fat',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {},
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            key: ValueKey<String>(dessert.name),
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text('${dessert.calories}'),
                showEditIcon: true,
                onTap: () {},
              ),
              DataCell(
                Text('${dessert.fat}'),
                showEditIcon: true,
                onTap: () {},
              ),
            ],
          );
        }).toList(),
      );
    }

    // DEFAULT VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildDefaultTable()),
    ));

    // default first column padding
    padding = find.widgetWithText(Padding, 'Frozen yogurt');
    cellContent = find.widgetWithText(Align,
        'Frozen yogurt'); // DataTable2 wraps its DataCells in an Align widget
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _defaultHorizontalMargin,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _defaultColumnSpacing / 2,
    );

    // default middle column padding
    padding = find.widgetWithText(Padding, '159');
    cellContent = find.widgetWithText(Align, '159');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _defaultColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _defaultColumnSpacing / 2,
    );

    // default last column padding
    padding = find.widgetWithText(Padding, '6.0');
    cellContent = find.widgetWithText(Align, '6.0');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _defaultColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _defaultHorizontalMargin,
    );

    Widget buildCustomTable({
      int? sortColumnIndex,
      bool sortAscending = true,
      double? horizontalMargin,
      double? columnSpacing,
    }) {
      return DataTable2(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        horizontalMargin: horizontalMargin,
        columnSpacing: columnSpacing,
        columns: <DataColumn2>[
          const DataColumn2(
            label: Text('Name'),
            tooltip: 'Name',
          ),
          DataColumn2(
            label: const Text('Calories'),
            tooltip: 'Calories',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {},
          ),
          DataColumn2(
            label: const Text('Fat'),
            tooltip: 'Fat',
            numeric: true,
            onSort: (int columnIndex, bool ascending) {},
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            key: ValueKey<String>(dessert.name),
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text('${dessert.calories}'),
                showEditIcon: true,
                onTap: () {},
              ),
              DataCell(
                Text('${dessert.fat}'),
                showEditIcon: true,
                onTap: () {},
              ),
            ],
          );
        }).toList(),
      );
    }

    // CUSTOM VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(
          child: buildCustomTable(
        horizontalMargin: _customHorizontalMargin,
        columnSpacing: _customColumnSpacing,
      )),
    ));

    // custom first column padding
    padding = find.widgetWithText(Padding, 'Frozen yogurt');
    cellContent = find.widgetWithText(Align,
        'Frozen yogurt'); // DataTable2 wraps its DataCells in an Align widget
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _customHorizontalMargin,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _customColumnSpacing / 2,
    );

    // custom middle column padding
    padding = find.widgetWithText(Padding, '159');
    cellContent = find.widgetWithText(Align, '159');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _customColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _customColumnSpacing / 2,
    );

    // custom last column padding
    padding = find.widgetWithText(Padding, '6.0');
    cellContent = find.widgetWithText(Align, '6.0');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      _customColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      _customHorizontalMargin,
    );
  });

  testWidgets('DataTable2 set border width test', (WidgetTester tester) async {
    const List<DataColumn2> columns = <DataColumn2>[
      DataColumn2(label: Text('column1')),
      DataColumn2(label: Text('column2')),
    ];

    const List<DataCell> cells = <DataCell>[
      DataCell(Text('cell1')),
      DataCell(Text('cell2')),
    ];

    const List<DataRow2> rows = <DataRow2>[
      DataRow2(cells: cells),
      DataRow2(cells: cells),
    ];

    // no thickness provided - border should be default: i.e "1.0" as it
    // set in DataTable2 constructor
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );

    Table table = tester.widgetList(find.byType(Table)).last as Table;
    TableRow tableRow = table.children.last;
    BoxDecoration boxDecoration = tableRow.decoration! as BoxDecoration;
    expect(boxDecoration.border!.top.width, 1.0);

    const double thickness = 4.2;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            dividerThickness: thickness,
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
    table = tester.widgetList(find.byType(Table)).last as Table;
    tableRow = table.children.last;
    boxDecoration = tableRow.decoration! as BoxDecoration;
    expect(boxDecoration.border!.top.width, thickness);
  });

  testWidgets('DataTable2 set show bottom border', (WidgetTester tester) async {
    const List<DataColumn2> columns = <DataColumn2>[
      DataColumn2(label: Text('column1')),
      DataColumn2(label: Text('column2')),
    ];

    const List<DataCell> cells = <DataCell>[
      DataCell(Text('cell1')),
      DataCell(Text('cell2')),
    ];

    const List<DataRow2> rows = <DataRow2>[
      DataRow2(cells: cells),
      DataRow2(cells: cells),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            showBottomBorder: true,
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );

    Table table = tester.widgetList(find.byType(Table)).last as Table;
    TableRow tableRow = table.children.last;
    BoxDecoration boxDecoration = tableRow.decoration! as BoxDecoration;
    expect(boxDecoration.border!.bottom.width, 1.0);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DataTable2(
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
    table = tester.widgetList(find.byType(Table)).last as Table;
    tableRow = table.children.last;
    boxDecoration = tableRow.decoration! as BoxDecoration;
    expect(boxDecoration.border!.bottom.width, 0.0);
  });

  testWidgets('DataTable2 column heading cell - with and without sorting',
      (WidgetTester tester) async {
    Widget buildTable({int? sortColumnIndex, bool sortEnabled = true}) {
      return DataTable2(
          sortColumnIndex: sortColumnIndex,
          columns: <DataColumn2>[
            DataColumn2(
              label: Center(child: Text('Name')),
              tooltip: 'Name',
              onSort: sortEnabled ? (_, __) {} : null,
            ),
          ],
          rows: const <DataRow2>[
            DataRow2(
              cells: <DataCell>[
                DataCell(Text('A long desert name')),
              ],
            ),
          ]);
    }

    // Start with without sorting
    await tester.pumpWidget(MaterialApp(
      home: Material(
          child: buildTable(
        sortEnabled: false,
      )),
    ));

    {
      final Finder nameText = find.text('Name');
      expect(nameText, findsOneWidget);
      final Finder nameCell = find
          .ancestor(of: find.text('Name'), matching: find.byType(Container))
          .first;
      expect(tester.getCenter(nameText), equals(tester.getCenter(nameCell)));
      expect(find.descendant(of: nameCell, matching: find.byType(Icon)),
          findsNothing);
    }

    // Turn on sorting
    await tester.pumpWidget(MaterialApp(
      home: Material(
          child: buildTable(
        sortEnabled: true,
      )),
    ));

    {
      final Finder nameText = find.text('Name');
      expect(nameText, findsOneWidget);
      final Finder nameCell = find
          .ancestor(of: find.text('Name'), matching: find.byType(Container))
          .first;
      expect(find.descendant(of: nameCell, matching: find.byType(Icon)),
          findsOneWidget);
    }

    // Turn off sorting again
    await tester.pumpWidget(MaterialApp(
      home: Material(
          child: buildTable(
        sortEnabled: false,
      )),
    ));

    {
      final Finder nameText = find.text('Name');
      expect(nameText, findsOneWidget);
      final Finder nameCell = find
          .ancestor(of: find.text('Name'), matching: find.byType(Container))
          .first;
      expect(tester.getCenter(nameText), equals(tester.getCenter(nameCell)));
      expect(find.descendant(of: nameCell, matching: find.byType(Icon)),
          findsNothing);
    }
  });

  testWidgets('DataTable2 correctly renders with a mouse',
      (WidgetTester tester) async {
    // Regression test for a bug described in
    // https://github.com/flutter/flutter/pull/43735#issuecomment-589459947
    // Filed at https://github.com/flutter/flutter/issues/51152
    Widget buildTable({int? sortColumnIndex}) {
      return DataTable2(
          sortColumnIndex: sortColumnIndex,
          columns: <DataColumn2>[
            const DataColumn2(
              label: Center(child: Text('column1')),
              tooltip: 'Column1',
            ),
            DataColumn2(
              label: Center(child: Text('column2')),
              tooltip: 'Column2',
              onSort: (_, __) {},
            ),
          ],
          rows: const <DataRow2>[
            DataRow2(
              cells: <DataCell>[
                DataCell(Text('Content1')),
                DataCell(Text('Content2')),
              ],
            ),
          ]);
    }

    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable()),
    ));

    expect(tester.renderObject(find.text('column1')).attached, true);
    expect(tester.renderObject(find.text('column2')).attached, true);

    final TestGesture gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    await tester.pumpAndSettle();
    expect(tester.renderObject(find.text('column1')).attached, true);
    expect(tester.renderObject(find.text('column2')).attached, true);

    // Wait for the tooltip timer to expire to prevent it scheduling a new frame
    // after the view is destroyed, which causes exceptions.
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('DataRow2 renders default selected row colors',
      (WidgetTester tester) async {
    final ThemeData _themeData = ThemeData.light();
    Widget buildTable({bool selected = false}) {
      return MaterialApp(
        theme: _themeData,
        home: Material(
          child: DataTable2(
            columns: const <DataColumn2>[
              DataColumn2(
                label: Text('Column1'),
              ),
            ],
            rows: <DataRow2>[
              DataRow2(
                onSelectChanged: (bool? checked) {},
                selected: selected,
                cells: const <DataCell>[
                  DataCell(Text('Content1')),
                ],
              ),
            ],
          ),
        ),
      );
    }

    BoxDecoration lastTableRowBoxDecoration() {
      final Table table = tester.widgetList(find.byType(Table)).last as Table;
      final TableRow tableRow = table.children.last;
      return tableRow.decoration! as BoxDecoration;
    }

    await tester.pumpWidget(buildTable(selected: false));
    expect(lastTableRowBoxDecoration().color, null);

    await tester.pumpWidget(buildTable(selected: true));
    expect(
      lastTableRowBoxDecoration().color,
      _themeData.colorScheme.primary.withOpacity(0.08),
    );
  });

  testWidgets('DataRow2 renders checkbox with colors from Theme',
      (WidgetTester tester) async {
    final ThemeData _themeData = ThemeData.light();
    Widget buildTable() {
      return MaterialApp(
        theme: _themeData,
        home: Material(
          child: DataTable2(
            columns: const <DataColumn2>[
              DataColumn2(
                label: Text('Column1'),
              ),
            ],
            rows: <DataRow2>[
              DataRow2(
                onSelectChanged: (bool? checked) {},
                cells: const <DataCell>[
                  DataCell(Text('Content1')),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Checkbox lastCheckbox() {
      return tester.widgetList<Checkbox>(find.byType(Checkbox)).last;
    }

    await tester.pumpWidget(buildTable());
    expect(lastCheckbox().activeColor, _themeData.colorScheme.primary);
    expect(lastCheckbox().checkColor, _themeData.colorScheme.onPrimary);
  });

  testWidgets('DataRow2 renders custom colors when selected',
      (WidgetTester tester) async {
    const Color selectedColor = Colors.green;
    const Color defaultColor = Colors.red;

    Widget buildTable({bool selected = false}) {
      return Material(
        child: DataTable2(
          columns: const <DataColumn2>[
            DataColumn2(
              label: Text('Column1'),
            ),
          ],
          rows: <DataRow2>[
            DataRow2(
              selected: selected,
              color: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected))
                    return selectedColor;
                  return defaultColor;
                },
              ),
              cells: const <DataCell>[
                DataCell(Text('Content1')),
              ],
            ),
          ],
        ),
      );
    }

    BoxDecoration lastTableRowBoxDecoration() {
      final Table table = tester.widgetList(find.byType(Table)).last as Table;
      final TableRow tableRow = table.children.last;
      return tableRow.decoration! as BoxDecoration;
    }

    await tester.pumpWidget(MaterialApp(
      home: buildTable(),
    ));
    expect(lastTableRowBoxDecoration().color, defaultColor);

    await tester.pumpWidget(MaterialApp(
      home: buildTable(selected: true),
    ));
    expect(lastTableRowBoxDecoration().color, selectedColor);
  });

  testWidgets('DataRow2 renders custom colors when disabled',
      (WidgetTester tester) async {
    const Color disabledColor = Colors.grey;
    const Color defaultColor = Colors.red;

    Widget buildTable({bool disabled = false}) {
      return Material(
        child: DataTable2(
          columns: const <DataColumn2>[
            DataColumn2(
              label: Text('Column1'),
            ),
          ],
          rows: <DataRow2>[
            DataRow2(
              cells: const <DataCell>[
                DataCell(Text('Content1')),
              ],
              onSelectChanged: (bool? value) {},
            ),
            DataRow2(
              color: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled))
                    return disabledColor;
                  return defaultColor;
                },
              ),
              cells: const <DataCell>[
                DataCell(Text('Content2')),
              ],
              onSelectChanged: disabled ? null : (bool? value) {},
            ),
          ],
        ),
      );
    }

    BoxDecoration lastTableRowBoxDecoration() {
      final Table table = tester.widgetList(find.byType(Table)).last as Table;
      final TableRow tableRow = table.children.last;
      return tableRow.decoration! as BoxDecoration;
    }

    await tester.pumpWidget(MaterialApp(
      home: buildTable(),
    ));
    expect(lastTableRowBoxDecoration().color, defaultColor);

    await tester.pumpWidget(MaterialApp(
      home: buildTable(disabled: true),
    ));
    expect(lastTableRowBoxDecoration().color, disabledColor);
  });

  testWidgets('DataRow2 renders custom colors when pressed',
      (WidgetTester tester) async {
    const Color pressedColor = Color(0xff4caf50);
    Widget buildTable() {
      return DataTable2(columns: const <DataColumn2>[
        DataColumn2(
          label: Text('Column1'),
        ),
      ], rows: <DataRow2>[
        DataRow2(
          color: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return pressedColor;
              return Colors.transparent;
            },
          ),
          onSelectChanged: (bool? value) {},
          cells: const <DataCell>[
            DataCell(Text('Content1')),
          ],
        ),
      ]);
    }

    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable()),
    ));

    final TestGesture gesture =
        await tester.startGesture(tester.getCenter(find.text('Content1')));
    await tester
        .pump(const Duration(milliseconds: 200)); // splash is well underway
    final RenderBox box =
        Material.of(tester.element(find.byType(InkWell)))! as RenderBox;
    expect(box, paints..circle(x: 68.0, y: 24.0, color: pressedColor));
    await gesture.up();
  });

  testWidgets('DataTable2 can\'t render inside an AlertDialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: AlertDialog(
            content: DataTable2(
              columns: const <DataColumn2>[
                DataColumn2(label: Text('Col1')),
              ],
              rows: const <DataRow2>[
                DataRow2(cells: <DataCell>[DataCell(Text('1'))]),
              ],
            ),
            scrollable: true,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNotNull);
  });

  testWidgets('DataTable2 renders with border and background decoration',
      (WidgetTester tester) async {
    const double width = 800;
    const double height = 600;
    const double borderHorizontal = 5.0;
    const double borderVertical = 10.0;
    const Color borderColor = Color(0xff2196f3);
    const Color backgroundColor = Color(0xfff5f5f5);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: DataTable2(
          decoration: const BoxDecoration(
            color: backgroundColor,
            border: Border.symmetric(
              vertical: BorderSide(width: borderVertical, color: borderColor),
              horizontal:
                  BorderSide(width: borderHorizontal, color: borderColor),
            ),
          ),
          columns: const <DataColumn2>[
            DataColumn2(label: Text('Col1')),
          ],
          rows: const <DataRow2>[
            DataRow2(cells: <DataCell>[DataCell(Text('1'))]),
          ],
        ),
      ),
    ));

    var t = find
        .ancestor(of: find.byType(Table), matching: find.byType(Container))
        .first;

    expect(
      t,
      paints
        ..rect(
          //rect: const Rect.fromLTRB(0.0, 0.0, width, height),
          color: backgroundColor,
        ),
    );
    expect(
      t,
      paints
        ..path(color: borderColor)
        ..path(color: borderColor)
        ..path(color: borderColor)
        ..path(color: borderColor),
    );
    expect(
      tester.getTopLeft(find.byType(Table).first),
      const Offset(borderVertical, borderHorizontal),
    );
    // expect(
    //   tester.getBottomRight(find.byType(Table).first),
    //   const Offset(width - borderVertical, height - borderHorizontal),
    // );
  });
}
