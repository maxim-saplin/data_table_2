// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin - changes and modifications to original Flutter implementation of DataTable

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;

import 'test_utils.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AsyncPaginatedDataTable2 paging', (WidgetTester tester) async {
    final DessertDataSourceAsync source =
        DessertDataSourceAsync(useKDeserts: true);

    final List<String> log = <String>[];

    await tester.pumpWidget(MaterialApp(
      home: AsyncPaginatedDataTable2(
        header: const Text('Test table'),
        source: source,
        rowsPerPage: 2,
        showFirstLastButtons: true,
        loading: const Center(
            child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ))),
        availableRowsPerPage: const <int>[
          2,
          4,
          8,
          16,
        ],
        onRowsPerPageChanged: (int? rowsPerPage) {
          log.add('rows-per-page-changed: $rowsPerPage');
        },
        onPageChanged: (int rowIndex) {
          log.add('page-changed: $rowIndex');
        },
        columns: const <DataColumn2>[
          DataColumn2(label: Text('Name')),
          DataColumn2(label: Text('Calories'), numeric: true),
          DataColumn2(label: Text('Generation')),
        ],
      ),
    ));

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Next page'));

    await tester.pumpAndSettle();

    expect(log, <String>['page-changed: 2']);
    log.clear();

    // // peek into what text is visible
    // var d = find.byType(Text);
    // var w = tester.widgetList(d).toList();

    expect(find.text('Frozen yogurt'), findsNothing);
    expect(find.text('Eclair'), findsOneWidget);
    expect(find.text('Gingerbread'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(log, <String>['page-changed: 0']);
    log.clear();

    await tester.pumpAndSettle();

    expect(find.text('Frozen yogurt'), findsOneWidget);
    expect(find.text('Eclair'), findsNothing);
    expect(find.text('Gingerbread'), findsNothing);

    final Finder lastPageButton = find.ancestor(
        of: find.byTooltip('Last page'),
        matching:
            find.byWidgetPredicate((Widget widget) => widget is IconButton));

    expect(tester.widget<IconButton>(lastPageButton).onPressed, isNotNull);

    await tester.tap(lastPageButton);
    await tester.pumpAndSettle();

    expect(log, <String>['page-changed: 498']);
    log.clear();

    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(lastPageButton).onPressed, isNull);

    expect(find.text('Frozen yogurt'), findsNothing);
    expect(find.text('Donut'), findsOneWidget);
    expect(find.text('KitKat'), findsOneWidget);

    final Finder firstPageButton = find.ancestor(
        of: find.byTooltip('First page'),
        matching:
            find.byWidgetPredicate((Widget widget) => widget is IconButton));

    expect(tester.widget<IconButton>(firstPageButton).onPressed, isNotNull);

    await tester.tap(firstPageButton);
    await tester.pumpAndSettle();

    expect(log, <String>['page-changed: 0']);
    log.clear();

    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(firstPageButton).onPressed, isNull);

    expect(find.text('Frozen yogurt'), findsOneWidget);
    expect(find.text('Eclair'), findsNothing);
    expect(find.text('Gingerbread'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(log, isEmpty);

    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('8').last);
    await tester.pumpAndSettle();

    expect(log, <String>['rows-per-page-changed: 8']);
    log.clear();
  });

  testWidgets('AsyncPaginatedDataTable2 control test',
      (WidgetTester tester) async {
    DessertDataSourceAsync source = DessertDataSourceAsync(useKDeserts: true);

    final List<String> log = <String>[];

    Widget buildTable(DessertDataSourceAsync source) {
      return AsyncPaginatedDataTable2(
        header: const Text('Test table'),
        source: source,
        onPageChanged: (int rowIndex) {
          log.add('page-changed: $rowIndex');
        },
        loading: const Center(
            child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ))),
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
          const DataColumn2(
            label: Text('Generation'),
            tooltip: 'Generation',
          ),
        ],
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.adjust),
            onPressed: () {
              log.add('action: adjust');
            },
          ),
        ],
      );
    }

    await tester.pumpWidget(MaterialApp(
      home: buildTable(source),
    ));
    await tester.pumpAndSettle();

    // // peek into what text is visible
    // var d = find.byType(Text);
    // var w = tester.widgetList(d).toList();

    expect(find.text('Gingerbread'), findsOneWidget);
    //expect(find.text('Gingerbread'), findsNothing);

    final AsyncPaginatedDataTable2State state =
        tester.state(find.byType(AsyncPaginatedDataTable2));

    expect(log, isEmpty);
    state.pageTo(23);
    await tester.pumpAndSettle();
    expect(log, <String>['page-changed: 20']);
    log.clear();

    await tester.pumpAndSettle();

    expect(find.text('Gingerbread'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.adjust));
    await tester.pumpAndSettle();
    expect(log, <String>['action: adjust']);
    log.clear();
  });

  testWidgets('AsyncPaginatedDataTable2 text alignment',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AsyncPaginatedDataTable2(
        header: const Text('HEADER'),
        source: DessertDataSourceAsync(useKDeserts: true),
        rowsPerPage: 8,
        loading: const Center(
            child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ))),
        availableRowsPerPage: const <int>[
          8,
          9,
        ],
        onRowsPerPageChanged: (int? rowsPerPage) {},
        columns: const <DataColumn2>[
          DataColumn2(label: Text('COL1')),
          DataColumn2(label: Text('COL2')),
          DataColumn2(label: Text('COL3')),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Rows per page:'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(tester.getTopRight(find.text('8')).dx,
        tester.getTopRight(find.text('Rows per page:')).dx + 40.0); // per spec
  });

  testWidgets('AsyncPaginatedDataTable2 with and without header and actions',
      (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(800, 800));
    const String headerText = 'HEADER';
    final List<Widget> actions = <Widget>[
      IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
    ];
    Widget buildTable({String? header, List<Widget>? actions}) => MaterialApp(
          home: AsyncPaginatedDataTable2(
            header: header != null ? Text(header) : null,
            actions: actions,
            source: DessertDataSourceAsync(allowSelection: true),
            showCheckboxColumn: true,
            loading: const Center(
                child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ))),
            columns: const <DataColumn2>[
              DataColumn2(label: Text('Name')),
              DataColumn2(label: Text('Calories'), numeric: true),
              DataColumn2(label: Text('Generation')),
            ],
          ),
        );

    await tester.pumpWidget(buildTable(header: headerText));
    await tester.pumpAndSettle();
    expect(find.text(headerText), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);

    await tester.pumpWidget(buildTable(header: headerText, actions: actions));
    await tester.pumpAndSettle();
    expect(find.text(headerText), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.pumpWidget(buildTable());
    await tester.pumpAndSettle();
    expect(find.text(headerText), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);

    expect(() => buildTable(actions: actions), throwsAssertionError);

    await binding.setSurfaceSize(null);
  });

  testWidgets('AsyncPaginatedDataTable2 with large text',
      (WidgetTester tester) async {
    final DessertDataSourceAsync source = DessertDataSourceAsync();

    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(20.0)),
        child: AsyncPaginatedDataTable2(
          header: const Text('HEADER'),
          source: source,
          rowsPerPage: 501,
          availableRowsPerPage: const <int>[501],
          onRowsPerPageChanged: (int? rowsPerPage) {},
          columns: const <DataColumn2>[
            DataColumn2(label: Text('COL1')),
            DataColumn2(label: Text('COL2')),
            DataColumn2(label: Text('COL3')),
          ],
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Rows per page:'), findsOneWidget);
    // Test that we will show some options in the drop down even if the lowest option is bigger than the source:
    assert(501 > source.rowCount);
    expect(find.text('501'), findsOneWidget);
    // Test that it fits:
    expect(
        tester.getTopRight(find.text('501')).dx,
        greaterThanOrEqualTo(
            tester.getTopRight(find.text('Rows per page:')).dx + 40.0));
  }, skip: isBrowser); // https://github.com/flutter/flutter/issues/43433

  testWidgets('AsyncPaginatedDataTable2 footer scrolls',
      (WidgetTester tester) async {
    final DessertDataSourceAsync source =
        DessertDataSourceAsync(useKDeserts: true);
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 100.0,
            child: AsyncPaginatedDataTable2(
              header: const Text('HEADER'),
              source: source,
              rowsPerPage: 5,
              dragStartBehavior: DragStartBehavior.down,
              availableRowsPerPage: const <int>[5],
              onRowsPerPageChanged: (int? rowsPerPage) {},
              columns: const <DataColumn2>[
                DataColumn2(label: Text('COL1')),
                DataColumn2(label: Text('COL2')),
                DataColumn2(label: Text('COL3')),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Rows per page:'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Rows per page:')).dx,
        lessThan(0.0)); // off screen
    await tester.dragFrom(
      Offset(50.0, tester.getTopLeft(find.text('Rows per page:')).dy),
      const Offset(1000.0, 0.0),
    );
    await tester.pump();
    expect(find.text('Rows per page:'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Rows per page:')).dx,
        18.0); // 14 padding in the footer row, 4 padding from the card
  });

  testWidgets('AsyncPaginatedDataTable2 custom row height',
      (WidgetTester tester) async {
    final DessertDataSourceAsync source =
        DessertDataSourceAsync(useKDeserts: true);

    Widget buildCustomHeightPaginatedTable({
      double dataRowHeight = 48.0,
      double headingRowHeight = 56.0,
    }) {
      return AsyncPaginatedDataTable2(
        header: const Text('Test table'),
        source: source,
        rowsPerPage: 2,
        availableRowsPerPage: const <int>[
          2,
          4,
          8,
          16,
        ],
        onRowsPerPageChanged: (int? rowsPerPage) {},
        onPageChanged: (int rowIndex) {},
        columns: const <DataColumn2>[
          DataColumn2(label: Text('Name')),
          DataColumn2(label: Text('Calories'), numeric: true),
          DataColumn2(label: Text('Generation')),
        ],
        dataRowHeight: dataRowHeight,
        headingRowHeight: headingRowHeight,
      );
    }

    // DEFAULT VALUES
    await tester.pumpWidget(MaterialApp(
      home: AsyncPaginatedDataTable2(
        header: const Text('Test table'),
        source: source,
        rowsPerPage: 2,
        availableRowsPerPage: const <int>[
          2,
          4,
          8,
          16,
        ],
        onRowsPerPageChanged: (int? rowsPerPage) {},
        onPageChanged: (int rowIndex) {},
        columns: const <DataColumn2>[
          DataColumn2(label: Text('Name')),
          DataColumn2(label: Text('Calories'), numeric: true),
          DataColumn2(label: Text('Generation')),
        ],
      ),
    ));

    await tester.pumpAndSettle();

    expect(
        tester
            .renderObject<RenderBox>(
                find.widgetWithText(Container, 'Name').first)
            .size
            .height,
        56.0); // This is the header row height
    expect(
        tester
            .renderObject<RenderBox>(
                find.widgetWithText(Container, 'Frozen yogurt').first)
            .size
            .height,
        48.0); // This is the data row height

    // CUSTOM VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(
          child: buildCustomHeightPaginatedTable(headingRowHeight: 48.0)),
    ));

    await tester.pumpAndSettle();

    expect(
        tester
            .renderObject<RenderBox>(
                find.widgetWithText(Container, 'Name').first)
            .size
            .height,
        48.0);

    await tester.pumpWidget(MaterialApp(
      home: Material(
          child: buildCustomHeightPaginatedTable(headingRowHeight: 64.0)),
    ));
    expect(
        tester
            .renderObject<RenderBox>(
                find.widgetWithText(Container, 'Name').first)
            .size
            .height,
        64.0);

    await tester.pumpWidget(MaterialApp(
      home:
          Material(child: buildCustomHeightPaginatedTable(dataRowHeight: 30.0)),
    ));

    await tester.pumpAndSettle();

    expect(
        tester
            .renderObject<RenderBox>(
                find.widgetWithText(Container, 'Frozen yogurt').first)
            .size
            .height,
        30.0);

    await tester.pumpWidget(MaterialApp(
      home:
          Material(child: buildCustomHeightPaginatedTable(dataRowHeight: 56.0)),
    ));
    expect(
        tester
            .renderObject<RenderBox>(
                find.widgetWithText(Container, 'Frozen yogurt').first)
            .size
            .height,
        56.0);
  });

  testWidgets('AsyncPaginatedDataTable2 custom horizontal padding - checkbox',
      (WidgetTester tester) async {
    const double defaultHorizontalMargin = 24.0;
    const double defaultColumnSpacing = 56.0;
    const double customHorizontalMargin = 10.0;
    const double customColumnSpacing = 15.0;

    const double width = 400;
    const double height = 400;

    final Size originalSize = binding.renderViews.first.size;

    // Ensure the containing Card is small enough that we don't expand too
    // much, resulting in our custom margin being ignored.
    await binding.setSurfaceSize(const Size(width, height));

    final DessertDataSourceAsync source =
        DessertDataSourceAsync(allowSelection: true, useKDeserts: true);

    Finder cellContent;
    Finder checkbox;
    Finder padding;

    await tester.pumpWidget(MaterialApp(
      home: AsyncPaginatedDataTable2(
        header: const Text('Test table'),
        source: source,
        rowsPerPage: 2,
        availableRowsPerPage: const <int>[
          2,
          4,
        ],
        onRowsPerPageChanged: (int? rowsPerPage) {},
        onPageChanged: (int rowIndex) {},
        onSelectAll: (bool? value) {},
        columns: const <DataColumn2>[
          DataColumn2(label: Text('Name')),
          DataColumn2(label: Text('Calories'), numeric: true),
          DataColumn2(label: Text('Generation')),
        ],
      ),
    ));

    await tester.pumpAndSettle();

    // default checkbox padding
    checkbox = find.byType(Checkbox).first;
    padding = find.ancestor(of: checkbox, matching: find.byType(Padding)).first;
    expect(
      tester.getRect(checkbox).left - tester.getRect(padding).left,
      defaultHorizontalMargin,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(checkbox).right,
      defaultHorizontalMargin / 2,
    );

    // default first column padding
    padding = find.widgetWithText(Padding, 'Frozen yogurt').first;
    cellContent = find.widgetWithText(Align,
        'Frozen yogurt'); // DataTable wraps its DataCells in an Align widget
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      defaultHorizontalMargin / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      defaultColumnSpacing / 2,
    );

    // default middle column padding
    padding = find.widgetWithText(Padding, '159').first;
    cellContent = find.widgetWithText(Align, '159');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      defaultColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      defaultColumnSpacing / 2,
    );

    // default last column padding
    padding = find.widgetWithText(Padding, '0').first;
    cellContent = find.widgetWithText(Align, '0').first;

    // CUSTOM VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: AsyncPaginatedDataTable2(
          header: const Text('Test table'),
          source: source,
          rowsPerPage: 2,
          availableRowsPerPage: const <int>[
            2,
            4,
          ],
          onRowsPerPageChanged: (int? rowsPerPage) {},
          onPageChanged: (int rowIndex) {},
          onSelectAll: (bool? value) {},
          columns: const <DataColumn2>[
            DataColumn2(label: Text('Name')),
            DataColumn2(label: Text('Calories'), numeric: true),
            DataColumn2(label: Text('Generation')),
          ],
          horizontalMargin: customHorizontalMargin,
          columnSpacing: customColumnSpacing,
        ),
      ),
    ));

    // custom checkbox padding
    checkbox = find.byType(Checkbox).first;
    padding = find.ancestor(of: checkbox, matching: find.byType(Padding)).first;
    expect(
      tester.getRect(checkbox).left - tester.getRect(padding).left,
      customHorizontalMargin,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(checkbox).right,
      customHorizontalMargin / 2,
    );

    // custom first column padding
    padding = find.widgetWithText(Padding, 'Frozen yogurt').first;
    cellContent = find.widgetWithText(Align,
        'Frozen yogurt'); // DataTable wraps its DataCells in an Align widget
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      customHorizontalMargin / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      customColumnSpacing / 2,
    );

    // custom middle column padding
    padding = find.widgetWithText(Padding, '159').first;
    cellContent = find.widgetWithText(Align, '159');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      customColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      customColumnSpacing / 2,
    );

    // Reset the surface size.
    await binding.setSurfaceSize(originalSize);
  });

  testWidgets(
      'AsyncPaginatedDataTable2 custom horizontal padding - no checkbox',
      (WidgetTester tester) async {
    const double defaultHorizontalMargin = 24.0;
    const double defaultColumnSpacing = 56.0;
    const double customHorizontalMargin = 10.0;
    const double customColumnSpacing = 15.0;

    final DessertDataSourceAsync source =
        DessertDataSourceAsync(useKDeserts: true);

    Finder cellContent;
    Finder padding;

    await tester.pumpWidget(MaterialApp(
      home: AsyncPaginatedDataTable2(
        header: const Text('Test table'),
        source: source,
        rowsPerPage: 2,
        availableRowsPerPage: const <int>[
          2,
          4,
          8,
          16,
        ],
        onRowsPerPageChanged: (int? rowsPerPage) {},
        onPageChanged: (int rowIndex) {},
        columns: const <DataColumn2>[
          DataColumn2(label: Text('Name')),
          DataColumn2(label: Text('Calories'), numeric: true),
          DataColumn2(label: Text('Generation')),
        ],
      ),
    ));

    await tester.pumpAndSettle();

    // default first column padding
    padding = find.widgetWithText(Padding, 'Frozen yogurt').first;
    cellContent = find.widgetWithText(Align,
        'Frozen yogurt'); // DataTable wraps its DataCells in an Align widget
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      defaultHorizontalMargin / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      defaultColumnSpacing / 2,
    );

    // default middle column padding
    padding = find.widgetWithText(Padding, '159').first;
    cellContent = find.widgetWithText(Align, '159');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      defaultColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      defaultColumnSpacing / 2,
    );

    // CUSTOM VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: AsyncPaginatedDataTable2(
          header: const Text('Test table'),
          source: source,
          rowsPerPage: 2,
          availableRowsPerPage: const <int>[
            2,
            4,
            8,
            16,
          ],
          onRowsPerPageChanged: (int? rowsPerPage) {},
          onPageChanged: (int rowIndex) {},
          columns: const <DataColumn2>[
            DataColumn2(label: Text('Name')),
            DataColumn2(label: Text('Calories'), numeric: true),
            DataColumn2(label: Text('Generation')),
          ],
          horizontalMargin: customHorizontalMargin,
          columnSpacing: customColumnSpacing,
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // custom first column padding
    padding = find.widgetWithText(Padding, 'Frozen yogurt').first;
    cellContent = find.widgetWithText(Align, 'Frozen yogurt');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      customHorizontalMargin / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      customColumnSpacing / 2,
    );

    // custom middle column padding
    padding = find.widgetWithText(Padding, '159').first;
    cellContent = find.widgetWithText(Align, '159');
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      customColumnSpacing / 2,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(cellContent).right,
      customColumnSpacing / 2,
    );
  });

  testWidgets('AsyncPaginatedDataTable2 set border width test',
      (WidgetTester tester) async {
    final DessertDataSourceAsync source =
        DessertDataSourceAsync(allowSelection: true, useKDeserts: true);
    const List<DataColumn> columns = <DataColumn>[
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Calories'), numeric: true),
      DataColumn(label: Text('Generation')),
    ];

    // no thickness provided - border should be default: i.e "1.0" as it
    // set in DataTable2 constructor
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: AsyncPaginatedDataTable2(
            columns: columns,
            source: source,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    Table table = tester.widgetList(find.byType(Table)).last as Table;
    TableRow tableRow = table.children.last;
    BoxDecoration boxDecoration = tableRow.decoration! as BoxDecoration;
    expect(boxDecoration.border!.bottom.width, 1.0);

    const double thickness = 4.2;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PaginatedDataTable2(
            dividerThickness: thickness,
            columns: columns,
            source: source,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    table = tester.widgetList(find.byType(Table)).last as Table;
    tableRow = table.children.last;
    boxDecoration = tableRow.decoration! as BoxDecoration;
    expect(boxDecoration.border!.bottom.width, thickness);
  });

  testWidgets('AsyncPaginatedDataTable2 table fills Card width',
      (WidgetTester tester) async {
    final DessertDataSourceAsync source =
        DessertDataSourceAsync(useKDeserts: true);

    // Note: 800 is wide enough to ensure that all of the columns fit in the
    // Card. The DataTable can be larger than its containing Card, but this test
    // is only concerned with ensuring the DataTable is at least as wide as the
    // Card.
    const double originalWidth = 800;
    const double expandedWidth = 1600;
    const double height = 400;

    final Size originalSize = binding.renderViews.first.size;

    Widget buildWidget() => MaterialApp(
          home: AsyncPaginatedDataTable2(
            header: const Text('Test table'),
            source: source,
            rowsPerPage: 2,
            availableRowsPerPage: const <int>[
              2,
              4,
              8,
              16,
            ],
            onRowsPerPageChanged: (int? rowsPerPage) {},
            onPageChanged: (int rowIndex) {},
            columns: const <DataColumn2>[
              DataColumn2(label: Text('Name')),
              DataColumn2(label: Text('Calories'), numeric: true),
              DataColumn2(label: Text('Generation')),
            ],
          ),
        );

    await binding.setSurfaceSize(const Size(originalWidth, height));
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle(const Duration(minutes: 1));

    // // Widths should be equal before we resize...
    // expect(
    //     tester.renderObject<RenderBox>(find.byType(DataTable).first).size.width,
    //     moreOrLessEquals(tester
    //         .renderObject<RenderBox>(find.byType(Card).first)
    //         .size
    //         .width));

    await binding.setSurfaceSize(const Size(expandedWidth, height));
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle(const Duration(minutes: 1));

    final double cardWidth =
        tester.renderObject<RenderBox>(find.byType(Card).first).size.width;

    // // ... and should still be equal after the resize.
    // expect(
    //     tester.renderObject<RenderBox>(find.byType(DataTable).first).size.width,
    //     moreOrLessEquals(cardWidth));

    // Double check to ensure we actually resized the surface properly.
    expect(cardWidth, moreOrLessEquals(expandedWidth));

    // Reset the surface size.
    await binding.setSurfaceSize(originalSize);
  });

  testWidgets('AsyncPaginatedDataTable2 with optional column checkbox',
      (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(800, 800));

    Widget buildTable(bool checkbox) => MaterialApp(
          home: AsyncPaginatedDataTable2(
            header: const Text('Test table'),
            source:
                DessertDataSourceAsync(allowSelection: true, useKDeserts: true),
            showCheckboxColumn: checkbox,
            columns: const <DataColumn2>[
              DataColumn2(label: Text('Name')),
              DataColumn2(label: Text('Calories'), numeric: true),
              DataColumn2(label: Text('Generation')),
            ],
          ),
        );

    await tester.pumpWidget(buildTable(true));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNWidgets(11));

    await tester.pumpWidget(buildTable(false));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('Table should not use decoration from DataTableTheme',
      (WidgetTester tester) async {
    final Size originalSize = binding.renderViews.first.size;
    await binding.setSurfaceSize(const Size(800, 800));

    Widget buildTable() {
      return MaterialApp(
        theme: ThemeData.light().copyWith(
          dataTableTheme: const DataTableThemeData(
            decoration: BoxDecoration(color: Colors.white),
          ),
        ),
        home: AsyncPaginatedDataTable2(
          header: const Text('Test table'),
          source: DessertDataSourceAsync(allowSelection: true),
          showCheckboxColumn: true,
          columns: const <DataColumn2>[
            DataColumn2(label: Text('Name')),
            DataColumn2(label: Text('Calories'), numeric: true),
            DataColumn2(label: Text('Generation')),
          ],
        ),
      );
    }

    await tester.pumpWidget(buildTable());
    await tester.pumpAndSettle();

    final Finder tableContainerFinder = find
        .ancestor(of: find.byType(Table), matching: find.byType(Container))
        .first;
    expect(tester.widget<Container>(tableContainerFinder).decoration,
        const BoxDecoration());

    // Reset the surface size.
    await binding.setSurfaceSize(originalSize);
  });

  testWidgets(
      'AsyncPaginatedDataTable2 custom checkboxHorizontalMargin properly applied',
      (WidgetTester tester) async {
    const double customCheckboxHorizontalMargin = 15.0;
    const double customHorizontalMargin = 10.0;

    const double width = 400;
    const double height = 400;

    final Size originalSize = binding.renderViews.first.size;

    // Ensure the containing Card is small enough that we don't expand too
    // much, resulting in our custom margin being ignored.
    await binding.setSurfaceSize(const Size(width, height));

    final DessertDataSourceAsync source =
        DessertDataSourceAsync(allowSelection: true, useKDeserts: true);

    Finder cellContent;
    Finder checkbox;
    Finder padding;

    // CUSTOM VALUES
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: AsyncPaginatedDataTable2(
          header: const Text('Test table'),
          source: source,
          rowsPerPage: 2,
          availableRowsPerPage: const <int>[
            2,
            4,
          ],
          onRowsPerPageChanged: (int? rowsPerPage) {},
          onPageChanged: (int rowIndex) {},
          onSelectAll: (bool? value) {},
          columns: const <DataColumn2>[
            DataColumn2(label: Text('Name')),
            DataColumn2(label: Text('Calories'), numeric: true),
            DataColumn2(label: Text('Generation')),
          ],
          horizontalMargin: customHorizontalMargin,
          checkboxHorizontalMargin: customCheckboxHorizontalMargin,
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Custom checkbox padding.
    checkbox = find.byType(Checkbox).first;
    padding = find.ancestor(of: checkbox, matching: find.byType(Padding)).first;
    expect(
      tester.getRect(checkbox).left - tester.getRect(padding).left,
      customCheckboxHorizontalMargin,
    );
    expect(
      tester.getRect(padding).right - tester.getRect(checkbox).right,
      customCheckboxHorizontalMargin / 2, // half of margin goes to data cell
    );

    // Custom first column padding.
    padding = find.widgetWithText(Padding, 'Frozen yogurt').first;
    cellContent = find.widgetWithText(Align,
        'Frozen yogurt'); // DataTable wraps its DataCells in an Align widget.
    expect(
      tester.getRect(cellContent).left - tester.getRect(padding).left,
      customHorizontalMargin / 2,
    );

    // Reset the surface size.
    await binding.setSurfaceSize(originalSize);
  });

  testWidgets('Items selected text uses secondary color',
      (WidgetTester tester) async {
    const Color selectedTextColor = Color(0xff00ddff);
    final ColorScheme colors =
        const ColorScheme.light().copyWith(secondary: selectedTextColor);
    final ThemeData theme = ThemeData.from(colorScheme: colors);

    Widget buildTable() {
      return MaterialApp(
        theme: theme,
        home: AsyncPaginatedDataTable2(
          header: const Text('Test table'),
          source:
              DessertDataSourceAsync(allowSelection: true, useKDeserts: true),
          columns: const <DataColumn2>[
            DataColumn2(label: Text('Name')),
            DataColumn2(label: Text('Calories'), numeric: true),
            DataColumn2(label: Text('Generation')),
          ],
        ),
      );
    }

    await binding.setSurfaceSize(const Size(800, 800));
    await tester.pumpWidget(buildTable());
    await tester.pumpAndSettle();

    expect(find.text('Test table'), findsOneWidget);

    // Select a row with yogurt
    await tester.tap(find.text('Frozen yogurt'));
    await tester.pumpAndSettle();

    // The header should be replace with a selected text item
    expect(find.text('Test table'), findsNothing);
    expect(find.text('1 item selected'), findsOneWidget);

    // The color of the selected text item should be the colorScheme.secondary
    final TextStyle selectedTextStyle = tester
        .renderObject<RenderParagraph>(find.text('1 item selected'))
        .text
        .style!;
    expect(selectedTextStyle.color, equals(selectedTextColor));

    await binding.setSurfaceSize(null);
  });
}
