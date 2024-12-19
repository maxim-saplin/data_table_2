// ignore_for_file: avoid_print

@TestOn('!chrome')
library;

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'mock_canvas.dart';
import 'test_utils.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' show Matrix3;

void main() {
  group('DataTable2', () {
    // testWidgets('No scrollbars visible by default',
    //     (WidgetTester tester) async {
    //   await wrapWidgetSetSurf(tester, buildTable());
    //   await tester.binding.setSurfaceSize(const Size(200, 300));
    //   await tester.pumpAndSettle();

    //   expect(find.byType(Scrollbar).hitTestable(), findsNothing);
    // });

    testWidgets(
        'Horizontal scrollbar is visible if isHorizontalScrollBarVisible=true',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
        tester,
        buildTable(minWidth: 350, isHorizontalScrollBarVisible: true),
        const Size(250, 300),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar).first, paints..rect());
    });

    testWidgets(
        'Vertical and horizontal scrollbars are visible if isHorizontalScrollBarVisible=true, isVerticalScrollBarVisible=true',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
        tester,
        buildTable(
          minWidth: 350,
          isVerticalScrollBarVisible: true,
          isHorizontalScrollBarVisible: true,
        ),
        const Size(250, 300),
      );

      await tester.pumpAndSettle();

      // Check if both scrollbars are visible
      expect(find.byType(Scrollbar).first, paints..rect());
      expect(find.byType(Scrollbar).last, paints..rect());
    });

    testWidgets(
        'Vertical and horizontal scrollbars are visible  when using theme',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          Theme(
              data: ThemeData(
                  scrollbarTheme: ScrollbarThemeData(
                      thumbVisibility: WidgetStateProperty.all(true))),
              child: buildTable()),
          const Size(250, 300));

      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar).first, paints..rect());
      expect(find.byType(Scrollbar).last, paints..rect());
    });

    testWidgets(
        'Vertical and horizontal scroll bars are not visible by default',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester, buildTable(), const Size(250, 300));

      await tester.pumpAndSettle();

      bool invisible = false;

      try {
        expect(find.byType(Scrollbar).first, paints..rect());
      } catch (_) {
        invisible = true;
      }
      expect(invisible, true);
      invisible = false;
      try {
        expect(find.byType(Scrollbar).last, paints..rect());
      } catch (_) {
        invisible = true;
      }
      expect(invisible, true);
    });

    testWidgets('Default column size is applied to header cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester, buildTable());

      await _defaultColumnSizeApplied(tester, true);
    });

    testWidgets('Default column size is applied to data cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester, buildTable());

      await _defaultColumnSizeApplied(tester, false);
    });

    testWidgets('Default S, M, L column sizes are applied to header cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester, buildTable(columns: smlColumns));

      await _smlColumnSizeApplied(tester, true);
    });

    testWidgets('Default S, M, L column sizes are applied to data cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester, buildTable(columns: smlColumns));

      await _smlColumnSizeApplied(tester, false);
    });

    testWidgets('Overidden S, M, L column sizes are applied to header cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(columns: smlColumns, overrideSizes: true));

      await _smlOverridenColumnSizeApplied(tester, true);
    });

    testWidgets('Overidden S, M, L column sizes are applied to data cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(columns: smlColumns, overrideSizes: true));

      await _smlOverridenColumnSizeApplied(tester, false);
    });

    testWidgets('minWidth is respected', (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester, buildTable(minWidth: 350));
      await tester.binding.setSurfaceSize(const Size(250, 500));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(Table).last);
      print('${s1.width} ${s1.height} ');

      expect(s1.width > 349 && s1.width < 351, true);
    });

    testWidgets('scrollController scrolls to bottom',
        (WidgetTester tester) async {
      var sc = ScrollController();
      await wrapWidgetSetSurf(tester, buildTable(scrollController: sc));

      expect(find.text('KitKat').hitTestable(), findsNothing);
      sc.jumpTo(10000);
      await tester.pumpAndSettle();
      expect(find.text('KitKat').hitTestable(), findsOneWidget);
    });

    testWidgets('horizontalScrollController scrolls to right',
        (WidgetTester tester) async {
      var horizontalSc = ScrollController();
      await wrapWidgetSetSurf(
          tester,
          buildTable(horizontalScrollController: horizontalSc, minWidth: 500),
          const Size(300, 500));

      expect(find.text('Frozen yogurt').hitTestable(), findsOneWidget);
      horizontalSc.jumpTo(10000);
      await tester.pumpAndSettle();
      expect(find.text('Frozen yogurt').hitTestable(), findsNothing);
    });

    testWidgets('empty widget is displayed when there\'s no data',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(empty: const Text('No data'), rows: []));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('border in heading is displayed when there\'s no data',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(
            empty: const Text('No data'),
            rows: [],
            border: TableBorder.all(color: Colors.red),
          ));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);

      var tableBorder =
          (find.byType(Table).evaluate().first.widget as Table).border!;
      expect(tableBorder.top.color, Colors.red);
      expect(tableBorder.top.width, 1);
      expect(tableBorder.bottom.color, Colors.red);
      expect(tableBorder.bottom.width, 1);
      expect(tableBorder.left.color, Colors.red);
      expect(tableBorder.left.width, 1);
      expect(tableBorder.right.color, Colors.red);
      expect(tableBorder.right.width, 1);

      await wrapWidgetSetSurf(
          tester,
          buildTable(
            rows: [],
            border: TableBorder.all(color: Colors.red),
          ));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('No data'), findsNothing);

      tableBorder =
          (find.byType(Table).evaluate().first.widget as Table).border!;
      expect(tableBorder.top.color, Colors.red);
      expect(tableBorder.top.width, 1);
      expect(tableBorder.bottom.color, Colors.red);
      expect(tableBorder.bottom.width, 1);
      expect(tableBorder.left.color, Colors.red);
      expect(tableBorder.left.width, 1);
      expect(tableBorder.right.color, Colors.red);
      expect(tableBorder.right.width, 1);
    });

    testWidgets('DataTable2.border', (WidgetTester tester) async {
      const columns = <DataColumn>[
        DataColumn2(label: Text('col1')),
        DataColumn(label: Text('col2')),
      ];

      const cells = <DataCell>[
        DataCell(Text('cell1')),
        DataCell(Text('cell2')),
      ];

      const rows = <DataRow>[
        DataRow2(cells: cells),
        DataRow(cells: cells),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: DataTable2(
              border: TableBorder.all(color: Colors.red),
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      );

      var i = 0;
      for (var t in find.byType(Table).evaluate()) {
        expect(true, i < 2, reason: '2 tables expected, found more');
        var table = t.widget as Table;
        // two tables, 1st is header, 2nd is data cells
        var tableBorder = table.border!;
        if (i == 0) {
          // header
          expect(tableBorder.top.color, Colors.red);
          expect(tableBorder.top.width, 1);
        } else {
          // data cells
          expect(tableBorder.top, BorderSide.none);
        }
        expect(tableBorder.bottom.color, Colors.red);
        expect(tableBorder.bottom.width, 1);
        expect(tableBorder.left.color, Colors.red);
        expect(tableBorder.left.width, 1);
        expect(tableBorder.right.color, Colors.red);
        expect(tableBorder.right.width, 1);

        i++;
      }

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

      i = 0;
      for (var t in find.byType(Table).evaluate()) {
        expect(true, i < 2, reason: '2 tables expected, found more');
        var table = t.widget as Table;
        // two tables, 1st is header, 2nd is data cells
        expect(table.border, null);
        i++;
      }
    });

    testWidgets(
        'Custom sortArrowIcon and sortArrowAnimationDuration parameters',
        (WidgetTester tester) async {
      IconData iconForTest = Icons.keyboard_arrow_up;
      var sortAscendingGlobal = true;
      var currentColumnIndex = 0;
      var trigger = StreamController();

      // using 'columns' here for the fake async trigger
      final triggerColumns = <DataColumn2>[
        DataColumn2(
            label: const Text('Name'),
            tooltip: 'Name',
            onSort: (int columnIndex, bool ascending) {
              sortAscendingGlobal = !sortAscendingGlobal;
              currentColumnIndex = columnIndex;

              trigger.add(null);
              // print(
              //     'onSort() --> [column: $columnIndex, ascending: $ascending], sortAscendingGlobal: $sortAscendingGlobal');
            }),
        const DataColumn2(
          label: Text('Calories'),
          tooltip: 'Calories',
          numeric: true,
          //onSort: (int columnIndex, bool ascending) {},
        ),
        const DataColumn2(
          label: Text('Carbs'),
          tooltip: 'Carbs',
          numeric: true,
          //onSort: (int columnIndex, bool ascending) {},
        ),
      ];

      Widget getStatefulWidget(
          {IconData? sortArrowIcon, Duration? sortArrowAnimationDuration}) {
        return StreamBuilder(
            stream: trigger.stream,
            builder: (c, s) {
              return MaterialApp(
                home: Material(
                  child: buildTable(
                      sortAscending: sortAscendingGlobal,
                      sortArrowIcon: sortArrowIcon,
                      sortArrowAnimationDuration: sortArrowAnimationDuration,
                      sortColumnIndex: currentColumnIndex,
                      columns: triggerColumns),
                ),
              );
            });
      }

      await tester.pumpWidget(getStatefulWidget(
        sortArrowIcon: iconForTest,
        sortArrowAnimationDuration: const Duration(milliseconds: 100),
      ));

      expect(find.byIcon(iconForTest), findsOneWidget);

      // initial rotation before toggle
      Transform transformOfArrow = tester.widget<Transform>(
        find.widgetWithIcon(Transform, iconForTest).first,
      );
      expect(
          transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));

      // tap column header to toggle sort to descending...
      await tester.tap(find.text('Name'));
      await tester.pump(const Duration(milliseconds: 95));

      // rotation before sortArrowAnimationDuration
      transformOfArrow = tester.widget<Transform>(
        find.widgetWithIcon(Transform, iconForTest).first,
      );
      print(
          'before sortArrowAnimationDuration: \n${transformOfArrow.transform.getRotation()}');
      expect(transformOfArrow.transform.getRotation(),
          isNot(Matrix3.rotationZ(math.pi)));

      await tester.pump(const Duration(milliseconds: 105));

      // rotation after sortArrowAnimationDuration
      transformOfArrow = tester.widget<Transform>(
        find.widgetWithIcon(Transform, iconForTest).first,
      );
      expect(transformOfArrow.transform.getRotation(),
          equals(Matrix3.rotationZ(math.pi)));
      print(
          'after sortArrowAnimationDuration: \n${transformOfArrow.transform.getRotation()}');
    });

    testWidgets('DataRow2 renders with custom decoration',
        (WidgetTester tester) async {
      const BoxDecoration rowDecoration =
          BoxDecoration(color: Color(0xFFFFF3E0));

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: DataTable2(
            columns: const <DataColumn>[
              DataColumn(label: Text('Column1')),
            ],
            rows: const <DataRow2>[
              DataRow2(
                cells: <DataCell>[DataCell(Text('Content1'))],
                decoration: rowDecoration,
              ),
            ],
          ),
        ),
      ));

      expect(
          find.ancestor(
              of: find.byType(Table).first,
              matching: find.byType(Container).first),
          paints..rect(color: const Color(0xFFFFF3E0)));
    });
  });

  group('PaginatedDataTable2', () {
    testWidgets('Default column size is applied to header cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildPaginatedTable(showPage: false, showGeneration: false));

      await _defaultColumnSizeApplied(tester, true);
    });

    testWidgets('Default column size is applied to data cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildPaginatedTable(showPage: false, showGeneration: false));

      await _defaultColumnSizeApplied(tester, false);
    });

    testWidgets('Default S, M, L column sizes are applied to header cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              showPage: false, showGeneration: false, columns: smlColumns));

      await _smlColumnSizeApplied(tester, true);
    });

    testWidgets('Default S, M, L column sizes are applied to data cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              showPage: false, showGeneration: false, columns: smlColumns));

      await _smlColumnSizeApplied(tester, false);
    });

    testWidgets('Overidden S, M, L column sizes are applied to header cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              showPage: false,
              showGeneration: false,
              columns: smlColumns,
              overrideSizes: true));

      await _smlOverridenColumnSizeApplied(tester, true);
    });

    testWidgets('Overidden S, M, L column sizes are applied to data cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              showPage: false,
              showGeneration: false,
              columns: smlColumns,
              overrideSizes: true));

      await _smlOverridenColumnSizeApplied(tester, false);
    });

    testWidgets('autoRowsToHeight WITHOUT headers works fine',
        (WidgetTester tester) async {
      int? rowsPp = -1;

      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              showPage: false,
              showGeneration: false,
              showHeader: false,
              onRowsPerPageChanged: (p) {
                rowsPp = p;
              },
              autoRowsToHeight: true));
      const height = 300.0;
      await tester.binding.setSurfaceSize(const Size(1000, height));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      var n = ((height - 56 - 56) / 48).floor() + 1;
      // - header row - footer
      // +1 - checkbox in header

      expect(find.byType(Checkbox), findsNWidgets(n));
      expect(rowsPp, n - 1);

      await tester.binding.setSurfaceSize(const Size(1000, height * 2));
      await tester.pumpAndSettle();
      s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      n = ((2 * height - 56 - 56) / 48).floor() + 1;
      expect(rowsPp, n - 1);

      expect(find.byType(Checkbox), findsNWidgets(n));
    });

    testWidgets('autoRowsToHeight WITH headers works fine',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              showPage: false,
              showGeneration: false,
              showHeader: true,
              autoRowsToHeight: true));

      const height = 300.0;
      await tester.binding.setSurfaceSize(const Size(1000, height));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      expect(find.byType(Checkbox),
          findsNWidgets(((height - 64 - 56 - 56) / 48).floor() + 1));
      // - header - header row - footer
      // +1 - checkbox in header

      await tester.binding.setSurfaceSize(const Size(1000, height * 2));
      await tester.pumpAndSettle();
      s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      expect(find.byType(Checkbox),
          findsNWidgets(((2 * height - 64 - 56 - 56) / 48).floor() + 1));
    });

    testWidgets('autoRowsToHeight WITH headers AND card works fine',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              showPage: false,
              showGeneration: false,
              showHeader: true,
              wrapInCard: true,
              autoRowsToHeight: true));

      const height = 300.0;
      await tester.binding.setSurfaceSize(const Size(1000, height));

      var s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox),
          findsNWidgets(((height - 64 - 56 - 56 - 8) / 48).floor() + 1));
      // - header - header row - footer
      // +1 - checkbox in header

      await tester.binding.setSurfaceSize(const Size(1000, height * 2));
      await tester.pumpAndSettle();
      s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      expect(find.byType(Checkbox),
          findsNWidgets(((2 * height - 64 - 56 - 56 - 8) / 48).floor() + 1));
    });

    testWidgets('autoRowsToHeight doesn\'t allow setting page size',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      await tester.pumpWidget(MaterialApp(
        home: Material(
            child: buildPaginatedTable(
                showPage: false,
                showGeneration: false,
                showPageSizeSelector: true,
                autoRowsToHeight: true)),
      ));

      expect(find.text('Rows per page:'), findsNothing);
    });

    testWidgets('minWidth is respected', (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              showPage: false, showGeneration: false, minWidth: 350));

      await tester.binding.setSurfaceSize(const Size(200, 300));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(Table).last);
      print('${s1.width} ${s1.height} ');

      expect(s1.width > 349 && s1.width < 351, true);
    });

    testWidgets('scrollController scrolls to bottom',
        (WidgetTester tester) async {
      var sc = ScrollController();
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              scrollController: sc, showGeneration: false, showPage: false));

      expect(find.text('KitKat').hitTestable(), findsNothing);
      sc.jumpTo(10000);
      await tester.pumpAndSettle();
      expect(find.text('KitKat').hitTestable(), findsOneWidget);
    });

    testWidgets('horizontalScrollController scrolls to right',
        (WidgetTester tester) async {
      var horizontalSc = ScrollController();
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              horizontalScrollController: horizontalSc,
              minWidth: 500,
              showGeneration: false,
              showPage: false),
          const Size(300, 500));

      expect(find.text('Frozen yogurt').hitTestable(), findsOneWidget);
      horizontalSc.jumpTo(10000);
      await tester.pumpAndSettle();
      expect(find.text('Frozen yogurt').hitTestable(), findsNothing);
    });

    testWidgets('empty widget is displayed when there\'s no data',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester,
          buildPaginatedTable(empty: const Text('No data'), noData: true));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('headingRowColor is applied', (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildPaginatedTable(
              headingRowColor: WidgetStateProperty.all(Colors.yellow)));

      var t = tester.widget(find.byType(DataTable2)) as DataTable2;
      expect(t.headingRowColor!.resolve({WidgetState.focused}), Colors.yellow);

      await wrapWidgetSetSurf(tester, buildPaginatedTable());

      t = tester.widget(find.byType(DataTable2)) as DataTable2;
      expect(t.headingRowColor, null);
    });

    testWidgets('"FlexFit fit" is applied', (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester, buildPaginatedTable());

      var t = tester.widget(find
          .descendant(
              of: find.byType(PaginatedDataTable2),
              matching: find.byType(Flexible))
          .first) as Flexible;

      expect(t.fit, FlexFit.tight);

      await wrapWidgetSetSurf(tester, buildPaginatedTable(fit: FlexFit.loose));

      t = tester.widget(find
          .descendant(
              of: find.byType(PaginatedDataTable2),
              matching: find.byType(Flexible))
          .first) as Flexible;

      expect(t.fit, FlexFit.loose);
    });

    testWidgets('hidePaginator hides paginator', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildPaginatedTable(
                  showPage: false,
                  showGeneration: false,
                  showPageSizeSelector: true,
                  hidePaginator: true))));

      expect(find.text('Rows per page:'), findsNothing);
    });

    testWidgets('PaginatorController works', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      var controller = PaginatorController();
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildPaginatedTable(
                  showPage: false,
                  showGeneration: false,
                  showPageSizeSelector: true,
                  controller: controller))));

      // peek into what text is visible
      // var d = find.byType(Text);
      // var w = tester.widgetList(d).toList();

      expect(controller.rowsPerPage, 10);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('1–10 of 500'), findsOneWidget);
      controller.setRowsPerPage(20);
      await tester.pumpAndSettle();
      expect(controller.rowsPerPage, 20);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('1–20 of 500'), findsOneWidget);

      controller.goToPageWithRow(40);
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 40);
      expect(find.text('41–60 of 500'), findsOneWidget);

      controller.goToRow(41);
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 41);
      expect(find.text('42–61 of 500'), findsOneWidget);

      controller.goToFirstPage();
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 0);
      expect(find.text('1–20 of 500'), findsOneWidget);

      controller.setRowsPerPage(10);
      await tester.pumpAndSettle();
      expect(controller.rowsPerPage, 10);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('1–10 of 500'), findsOneWidget);

      controller.goToNextPage();
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 10);
      expect(find.text('11–20 of 500'), findsOneWidget);

      controller.goToPreviousPage();
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 0);
      expect(find.text('1–10 of 500'), findsOneWidget);

      controller.goToLastPage();
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 490);
      expect(find.text('491–500 of 500'), findsOneWidget);

      expect(controller.rowCount, 500);
    });

    testWidgets(
        'PaginatedDataTable2 initial sort indicator orientation not spoiled',
        (WidgetTester tester) async {
      // Check for ascending list
      await tester.pumpWidget(MaterialApp(
        home: Material(
            child:
                buildPaginatedTable(sortAscending: true, sortColumnIndex: 0)),
      ));
      // The `tester.widget` ensures that there is exactly one upward arrow.
      Transform transformOfArrow = tester.widget<Transform>(
          find.widgetWithIcon(Transform, Icons.arrow_upward).first);

      expect(transformOfArrow.transform.getRotation().getColumn(0)[0],
          equals(1.0));

      // Setting surface size via await tester.binding.setSurfaceSize(Size(1000, 200));
      // messes with float numbers and sizes precision. That's why not using full matrix comparison but components

      // expect(
      //     transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));
      // Expected: Matrix3:<
      //   [0] [1.0,0.0,0.0]
      //   [1] [0.0,1.0,0.0]
      //   [2] [0.0,0.0,1.0]
      // Actual: Matrix3:<
      // [0] [1.0,-0.0,0.0]
      //   [1] [0.0,1.0,0.0]
      //   [2] [0.0,0.0,1.0]
      //   >

      // There was a bug thaty after first rebuild the initial sort direction
      // got spoiled
      // https://github.com/maxim-saplin/data_table_2/pull/39
      await tester.tap(find.byTooltip('Next page'));
      await tester.pumpAndSettle();
      expect(transformOfArrow.transform.getRotation().getColumn(0)[0],
          equals(1.0));

      // Check for descending list.
      await tester.pumpWidget(MaterialApp(
        home: Material(
            child:
                buildPaginatedTable(sortAscending: false, sortColumnIndex: 0)),
      ));
      await tester.pumpAndSettle();
      // The `tester.widget` ensures that there is exactly one upward arrow.
      transformOfArrow = tester.widget<Transform>(
          find.widgetWithIcon(Transform, Icons.arrow_upward).first);
      expect(transformOfArrow.transform.getRotation().getColumn(0)[0],
          equals(-1.0));
      // expect(transformOfArrow.transform.getRotation(),
      //     equals(Matrix3.rotationZ(math.pi)));
      //  Expected: Matrix3:<
      // [0] [-1.0,-1.2246468525851679e-16,0.0]
      // [1] [1.2246468525851679e-16,-1.0,0.0]
      // [2] [0.0,0.0,1.0]

      //  Actual: Matrix3:<
      //  [0] [-1.0,-1.2246467991473532e-16,0.0]
      // [1] [1.2246467991473532e-16,-1.0,0.0]
      // [2] [0.0,0.0,1.0]
    });

    testWidgets('PaginatedDataTable2.border', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildPaginatedTable(
                  border: TableBorder.all(color: Colors.red)))));

      var i = 0;
      for (var t in find.byType(Table).evaluate()) {
        expect(true, i < 2, reason: '2 tables expected, found more');
        var table = t.widget as Table;
        // two tables, 1st is header, 2nd is data cells
        var tableBorder = table.border!;
        if (i == 0) {
          // header
          expect(tableBorder.top.color, Colors.red);
          expect(tableBorder.top.width, 1);
        } else {
          // data cells
          expect(tableBorder.top, BorderSide.none);
        }
        expect(tableBorder.bottom.color, Colors.red);
        expect(tableBorder.bottom.width, 1);
        expect(tableBorder.left.color, Colors.red);
        expect(tableBorder.left.width, 1);
        expect(tableBorder.right.color, Colors.red);
        expect(tableBorder.right.width, 1);

        i++;
      }

      await tester.pumpWidget(
          MaterialApp(home: Material(child: buildPaginatedTable())));

      i = 0;
      for (var t in find.byType(Table).evaluate()) {
        expect(true, i < 2, reason: '2 tables expected, found more');
        var table = t.widget as Table;
        // two tables, 1st is header, 2nd is data cells
        expect(table.border, null);
        i++;
      }
    });

    testWidgets('Custom sortArrowIcon test for PaginatedDataTable2',
        (WidgetTester tester) async {
      IconData iconForTest = Icons.keyboard_arrow_up;
      var sortAscendingGlobal = true;
      var currentColumnIndex = 0;
      var trigger = StreamController();

      // using 'columns' here for the fake async trigger
      final triggerColumns = <DataColumn2>[
        DataColumn2(
            label: const Text('Name'),
            tooltip: 'Name',
            onSort: (int columnIndex, bool ascending) {
              sortAscendingGlobal = !sortAscendingGlobal;
              currentColumnIndex = columnIndex;

              trigger.add(null);
              // print(
              //     'onSort() --> [column: $columnIndex, ascending: $ascending], sortAscendingGlobal: $sortAscendingGlobal');
            }),
        const DataColumn2(
          label: Text('Calories'),
          tooltip: 'Calories',
          numeric: true,
          //onSort: (int columnIndex, bool ascending) {},
        ),
        const DataColumn2(
          label: Text('Carbs'),
          tooltip: 'Carbs',
          numeric: true,
          //onSort: (int columnIndex, bool ascending) {},
        ),
      ];

      Widget getStatefulWidget(
          {IconData? sortArrowIcon, Duration? sortArrowAnimationDuration}) {
        return StreamBuilder(
            stream: trigger.stream,
            builder: (c, s) {
              return MaterialApp(
                home: Material(
                  child: buildPaginatedTable(
                      sortAscending: sortAscendingGlobal,
                      sortArrowIcon: sortArrowIcon,
                      sortArrowAnimationDuration: sortArrowAnimationDuration,
                      sortColumnIndex: currentColumnIndex,
                      columns: triggerColumns),
                ),
              );
            });
      }

      await tester.pumpWidget(getStatefulWidget(
        sortArrowIcon: iconForTest,
        sortArrowAnimationDuration: const Duration(milliseconds: 100),
      ));

      expect(find.byIcon(iconForTest), findsOneWidget);

      // initial rotation before toggle
      Transform transformOfArrow = tester.widget<Transform>(
        find.widgetWithIcon(Transform, iconForTest).first,
      );
      expect(
          transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));

      // tap column header to toggle sort to descending...
      await tester.tap(find.text('Name'));
      await tester.pump(const Duration(milliseconds: 95));

      // rotation before sortArrowAnimationDuration
      transformOfArrow = tester.widget<Transform>(
        find.widgetWithIcon(Transform, iconForTest).first,
      );
      print(
          'before sortArrowAnimationDuration: \n${transformOfArrow.transform.getRotation()}');
      expect(transformOfArrow.transform.getRotation(),
          isNot(Matrix3.rotationZ(math.pi)));

      await tester.pump(const Duration(milliseconds: 105));

      // rotation after sortArrowAnimationDuration
      transformOfArrow = tester.widget<Transform>(
        find.widgetWithIcon(Transform, iconForTest).first,
      );
      expect(transformOfArrow.transform.getRotation(),
          equals(Matrix3.rotationZ(math.pi)));
      print(
          'after sortArrowAnimationDuration: \n${transformOfArrow.transform.getRotation()}');
    });
  });

  group('AsyncPaginatedDataTable2', () {
    testWidgets('Default column size is applied to header cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester,
          buildAsyncPaginatedTable(showPage: false, showGeneration: false));

      await _defaultColumnSizeApplied(tester, true);
    });

    testWidgets('Default column size is applied to data cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester,
          buildAsyncPaginatedTable(showPage: false, showGeneration: false));

      await _defaultColumnSizeApplied(tester, false);
    });

    testWidgets('Default S, M, L column sizes are applied to header cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              showPage: false, showGeneration: false, columns: smlColumns));

      await _smlColumnSizeApplied(tester, true);
    });

    testWidgets('Default S, M, L column sizes are applied to data cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              showPage: false, showGeneration: false, columns: smlColumns));

      await _smlColumnSizeApplied(tester, false);
    });

    testWidgets('Overidden S, M, L column sizes are applied to header cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              showPage: false,
              showGeneration: false,
              columns: smlColumns,
              overrideSizes: true));

      await _smlOverridenColumnSizeApplied(tester, true);
    });

    testWidgets('Overidden S, M, L column sizes are applied to data cells',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              showPage: false,
              showGeneration: false,
              columns: smlColumns,
              overrideSizes: true));

      await _smlOverridenColumnSizeApplied(tester, false);
    });

    testWidgets('autoRowsToHeight WITHOUT headers works fine',
        (WidgetTester tester) async {
      int? rowsPp = -1;

      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              showPage: false,
              showGeneration: false,
              showHeader: false,
              onRowsPerPageChanged: (p) {
                rowsPp = p;
              },
              autoRowsToHeight: true));
      const height = 300.0;
      await tester.binding.setSurfaceSize(const Size(1000, height));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(AsyncPaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      var n = ((height - 56 - 56) / 48).floor() + 1;
      // - header row - footer
      // +1 - checkbox in header

      expect(find.byType(Checkbox), findsNWidgets(n));
      expect(rowsPp, n - 1);

      await tester.binding.setSurfaceSize(const Size(1000, height * 2));
      await tester.pumpAndSettle();
      s1 = tester.getSize(find.byType(AsyncPaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      n = ((2 * height - 56 - 56) / 48).floor() + 1;
      expect(rowsPp, n - 1);

      expect(find.byType(Checkbox), findsNWidgets(n));
    });

    testWidgets('autoRowsToHeight WITH headers works fine',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              showPage: false,
              showGeneration: false,
              showHeader: true,
              autoRowsToHeight: true));

      const height = 300.0;
      await tester.binding.setSurfaceSize(const Size(1000, height));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(AsyncPaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      expect(find.byType(Checkbox),
          findsNWidgets(((height - 64 - 56 - 56) / 48).floor() + 1));
      // - header - header row - footer
      // +1 - checkbox in header

      await tester.binding.setSurfaceSize(const Size(1000, height * 2));
      await tester.pumpAndSettle();
      s1 = tester.getSize(find.byType(AsyncPaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      expect(find.byType(Checkbox),
          findsNWidgets(((2 * height - 64 - 56 - 56) / 48).floor() + 1));
    });

    testWidgets('autoRowsToHeight WITH headers AND card works fine',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              showPage: false,
              showGeneration: false,
              showHeader: true,
              wrapInCard: true,
              autoRowsToHeight: true));

      const height = 300.0;
      await tester.binding.setSurfaceSize(const Size(1000, height));

      var s1 = tester.getSize(find.byType(AsyncPaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox),
          findsNWidgets(((height - 64 - 56 - 56 - 8) / 48).floor() + 1));
      // - header - header row - footer
      // +1 - checkbox in header

      await tester.binding.setSurfaceSize(const Size(1000, height * 2));
      await tester.pumpAndSettle();
      s1 = tester.getSize(find.byType(AsyncPaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      expect(find.byType(Checkbox),
          findsNWidgets(((2 * height - 64 - 56 - 56 - 8) / 48).floor() + 1));
    });

    testWidgets('autoRowsToHeight doesn\'t allow setting page size',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      await tester.pumpWidget(MaterialApp(
        home: Material(
            child: buildAsyncPaginatedTable(
                showPage: false,
                showGeneration: false,
                showPageSizeSelector: true,
                autoRowsToHeight: true)),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Rows per page:'), findsNothing);
    });

    testWidgets('minWidth is respected', (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              showPage: false, showGeneration: false, minWidth: 350));

      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(const Size(200, 300));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(Table).last);
      print('${s1.width} ${s1.height} ');

      expect(s1.width > 349 && s1.width < 351, true);
    });

    testWidgets('scrollController scrolls to bottom',
        (WidgetTester tester) async {
      var sc = ScrollController();
      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              scrollController: sc, showGeneration: false, showPage: false));

      await tester.pumpAndSettle();

      expect(find.text('Frozen yogurt').hitTestable(), findsNothing);
      sc.jumpTo(10000);
      await tester.pumpAndSettle();
      expect(find.text('Frozen yogurt').hitTestable(), findsOneWidget);
    });

    testWidgets('horizontalScrollController scrolls to right',
        (WidgetTester tester) async {
      var horizontalSc = ScrollController();
      await wrapWidgetSetSurf(
          tester,
          buildAsyncPaginatedTable(
              horizontalScrollController: horizontalSc,
              minWidth: 500,
              showGeneration: false,
              showPage: false),
          const Size(300, 500));

      await tester.pumpAndSettle();

      expect(find.text('Eclair').hitTestable(), findsOneWidget);
      horizontalSc.jumpTo(10000);
      await tester.pumpAndSettle();
      expect(find.text('Eclair').hitTestable(), findsNothing);
    });

    testWidgets('empty widget is displayed when there\'s no data',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester,
          buildAsyncPaginatedTable(empty: const Text('No data'), noData: true));

      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('hidePaginator hides paginator', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildAsyncPaginatedTable(
                  showPage: false,
                  showGeneration: false,
                  showPageSizeSelector: true,
                  hidePaginator: true))));

      await tester.pumpAndSettle();

      expect(find.text('Rows per page:'), findsNothing);
    });

    testWidgets('PaginatorController works', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      var controller = PaginatorController();
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildAsyncPaginatedTable(
                  showPage: false,
                  showGeneration: false,
                  showPageSizeSelector: true,
                  controller: controller))));

      await tester.pumpAndSettle();

      expect(controller.rowsPerPage, 10);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('1–10 of 30'), findsOneWidget);
      controller.setRowsPerPage(20);
      await tester.pumpAndSettle();
      expect(controller.rowsPerPage, 20);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('1–20 of 30'), findsOneWidget);

      controller.goToPageWithRow(40);
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 20);
      expect(find.text('21–40 of 30'), findsOneWidget);

      controller.goToPageWithRow(10);
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 0);
      expect(find.text('1–20 of 30'), findsOneWidget);

      controller.goToRow(21);
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 21);

      // // peek into what text is visible
      // var d = find.byType(Text);
      // var w = tester.widgetList(d).toList();

      expect(find.text('22–41 of 30'), findsOneWidget);

      controller.goToFirstPage();
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 0);
      expect(find.text('1–20 of 30'), findsOneWidget);

      controller.setRowsPerPage(10);
      await tester.pumpAndSettle();
      expect(controller.rowsPerPage, 10);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('1–10 of 30'), findsOneWidget);

      controller.goToNextPage();
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 10);
      expect(find.text('11–20 of 30'), findsOneWidget);

      controller.goToPreviousPage();
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 0);
      expect(find.text('1–10 of 30'), findsOneWidget);

      controller.goToLastPage();
      await tester.pumpAndSettle();
      expect(controller.currentRowIndex, 20);
      expect(find.text('21–30 of 30'), findsOneWidget);

      expect(controller.rowCount, 30);
    });

    testWidgets('DataTable2 initial sort indicator orientation not spoiled',
        (WidgetTester tester) async {
      // Check for ascending list
      await tester.pumpWidget(MaterialApp(
        home: Material(
            child: buildAsyncPaginatedTable(
                sortAscending: true, sortColumnIndex: 0)),
      ));
      // The `tester.widget` ensures that there is exactly one upward arrow.
      Transform transformOfArrow = tester.widget<Transform>(
          find.widgetWithIcon(Transform, Icons.arrow_upward).first);

      expect(transformOfArrow.transform.getRotation().getColumn(0)[0],
          equals(1.0));

      // Setting surface size via await tester.binding.setSurfaceSize(Size(1000, 200));
      // messes with float numbers and sizes precision. That's why not using full matrix comparison but components

      // expect(
      //     transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));
      // Expected: Matrix3:<
      //   [0] [1.0,0.0,0.0]
      //   [1] [0.0,1.0,0.0]
      //   [2] [0.0,0.0,1.0]
      // Actual: Matrix3:<
      // [0] [1.0,-0.0,0.0]
      //   [1] [0.0,1.0,0.0]
      //   [2] [0.0,0.0,1.0]
      //   >

      // There was a bug thaty after first rebuild the initial sort direction
      // got spoiled
      // https://github.com/maxim-saplin/data_table_2/pull/39
      await tester.tap(find.byTooltip('Next page'));
      await tester.pumpAndSettle();
      expect(transformOfArrow.transform.getRotation().getColumn(0)[0],
          equals(1.0));

      // Check for descending list.
      await tester.pumpWidget(MaterialApp(
        home: Material(
            child: buildAsyncPaginatedTable(
                sortAscending: false, sortColumnIndex: 0)),
      ));
      await tester.pumpAndSettle();
      // The `tester.widget` ensures that there is exactly one upward arrow.
      transformOfArrow = tester.widget<Transform>(
          find.widgetWithIcon(Transform, Icons.arrow_upward).first);
      expect(transformOfArrow.transform.getRotation().getColumn(0)[0],
          equals(-1.0));
      // expect(transformOfArrow.transform.getRotation(),
      //     equals(Matrix3.rotationZ(math.pi)));
      //  Expected: Matrix3:<
      // [0] [-1.0,-1.2246468525851679e-16,0.0]
      // [1] [1.2246468525851679e-16,-1.0,0.0]
      // [2] [0.0,0.0,1.0]

      //  Actual: Matrix3:<
      //  [0] [-1.0,-1.2246467991473532e-16,0.0]
      // [1] [1.2246467991473532e-16,-1.0,0.0]
      // [2] [0.0,0.0,1.0]
    });

    testWidgets(
        'Custom sortArrowIcon and sortArrowAnimationDuration parameters',
        (WidgetTester tester) async {
      IconData iconForTest = Icons.keyboard_arrow_up;
      var sortAscendingGlobal = true;
      var currentColumnIndex = 0;
      var trigger = StreamController();

      // using 'columns' here for the fake async trigger
      final triggerColumns = <DataColumn2>[
        DataColumn2(
            label: const Text('Name'),
            tooltip: 'Name',
            onSort: (int columnIndex, bool ascending) {
              sortAscendingGlobal = !sortAscendingGlobal;
              currentColumnIndex = columnIndex;

              trigger.add(null);
            }),
        const DataColumn2(
          label: Text('Calories'),
          tooltip: 'Calories',
          numeric: true,
        ),
        const DataColumn2(
          label: Text('Carbs'),
          tooltip: 'Carbs',
          numeric: true,
        ),
      ];

      Widget getStatefulWidget(
          {IconData? sortArrowIcon, Duration? sortArrowAnimationDuration}) {
        return StreamBuilder(
            stream: trigger.stream,
            builder: (c, s) {
              return MaterialApp(
                home: Material(
                  child: buildAsyncPaginatedTable(
                      sortAscending: sortAscendingGlobal,
                      sortArrowIcon: sortArrowIcon,
                      sortArrowAnimationDuration: sortArrowAnimationDuration,
                      sortColumnIndex: currentColumnIndex,
                      columns: triggerColumns),
                ),
              );
            });
      }

      await tester.pumpWidget(getStatefulWidget(
        sortArrowIcon: iconForTest,
        sortArrowAnimationDuration: const Duration(milliseconds: 100),
      ));

      expect(find.byIcon(iconForTest), findsOneWidget);

      // initial rotation before toggle
      Transform transformOfArrow = tester.widget<Transform>(
        find.widgetWithIcon(Transform, iconForTest).first,
      );
      //print('before tap: \n${transformOfArrow.transform.getRotation()}');
      expect(
          transformOfArrow.transform.getRotation(), equals(Matrix3.identity()));

      // tap column header to toggle sort to descending...
      await tester.tap(find.text('Name'));
      await tester.pump(const Duration(milliseconds: 95));

      // rotation before sortArrowAnimationDuration
      transformOfArrow = tester.widget<Transform>(
        find.widgetWithIcon(Transform, iconForTest).first,
      );
      print(
          'before sortArrowAnimationDuration: \n${transformOfArrow.transform.getRotation()}');
      expect(transformOfArrow.transform.getRotation(),
          isNot(Matrix3.rotationZ(math.pi)));

      await tester.pump(const Duration(milliseconds: 105));

      // rotation after sortArrowAnimationDuration
      transformOfArrow = tester.widget<Transform>(
        find.widgetWithIcon(Transform, iconForTest).first,
      );
      expect(transformOfArrow.transform.getRotation(),
          equals(Matrix3.rotationZ(math.pi)));
      print(
          'after sortArrowAnimationDuration: \n${transformOfArrow.transform.getRotation()}');

      tester.pumpAndSettle();
    });

    testWidgets('Default loading spinner is shown',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildAsyncPaginatedTable(
                  showPage: false,
                  showGeneration: false,
                  showPageSizeSelector: true,
                  hidePaginator: true))));

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('Custom loading spinner is shown', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildAsyncPaginatedTable(
                  showPage: false,
                  showGeneration: false,
                  showPageSizeSelector: true,
                  circularSpinner: true,
                  hidePaginator: true))));

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Switching page shows loading spinner',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildAsyncPaginatedTable(
                  showGeneration: false,
                  showPageSizeSelector: true,
                  hidePaginator: false))));

      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('Error widget is displayed', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      await tester.pumpWidget(MaterialApp(
          home: Material(child: buildAsyncPaginatedTable(throwError: true))));

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // peek into what text is visible
      // var d = find.byType(Text);
      // var w = tester.widgetList(d).toList();

      expect(find.text("Cupcake"), findsNothing);
      expect(find.text('Error #1 has occured'), findsOneWidget);
    });

    testWidgets('Not empty table loaded', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildAsyncPaginatedTable(
                  showHeader: false,
                  showCheckboxColumn: false,
                  fewerResultsAfterRefresh: false,
                  syncApproach: PageSyncApproach.doNothing))));

      await tester.pumpAndSettle();

      expect(
          find.byType(Text),
          findsNWidgets(
              3 * 11 + 1)); // 3 columns, 10 rows + 1 header row + paginator
      expect(find.text('Cupcake'), findsOneWidget);
      expect(find.text('1–10 of 30'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(
          find.byType(Text),
          findsNWidgets(
              3 * 11 + 1)); // 3 columns, 10 rows + 1 header row + paginator
      expect(find.text('Frozen yogurt x2'), findsOneWidget);
      expect(find.text('11–20 of 30'), findsOneWidget);
    });

    testWidgets('Select/deselect all', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      var source = DessertDataSourceAsync(allowSelection: true);
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildAsyncPaginatedTable(
                  showPage: false,
                  showGeneration: false,
                  showPageSizeSelector: true,
                  source: source,
                  onSelectAll: (val) {
                    if (val ?? false) {
                      source.selectAll();
                    } else {
                      source.deselectAll();
                    }
                  }))));

      await tester.pumpAndSettle();

      int numebrOfCheckboxes(bool cheked) => find
          .byType(Checkbox)
          .evaluate()
          .where((e) => (e.widget as Checkbox).value == cheked)
          .length;

      expect(numebrOfCheckboxes(false), 11);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(numebrOfCheckboxes(true), 11);

      await tester.tap(find.byIcon(Icons.chevron_right)); // page 2
      await tester.pumpAndSettle();
      expect(numebrOfCheckboxes(true), 11);
      await tester.tap(find.byIcon(Icons.chevron_right)); // page 3
      await tester.pumpAndSettle();
      expect(numebrOfCheckboxes(true), 11);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(numebrOfCheckboxes(false), 11);
    });

    testWidgets('Select/deselect all on page', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 300));
      var source = DessertDataSourceAsync(allowSelection: true);
      await tester.pumpWidget(MaterialApp(
          home: Material(
              child: buildAsyncPaginatedTable(
                  showPage: false,
                  showGeneration: false,
                  showPageSizeSelector: true,
                  source: source,
                  onSelectAll: (val) {
                    if (val!) {
                      source.selectAllOnThePage();
                    } else {
                      source.deselectAllOnThePage();
                    }
                  }))));

      await tester.pumpAndSettle();

      int numebrOfCheckboxes(bool cheked) => find
          .byType(Checkbox)
          .evaluate()
          .where((e) => (e.widget as Checkbox).value == cheked)
          .length;

      expect(numebrOfCheckboxes(false), 11);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(numebrOfCheckboxes(true), 11);

      await tester.tap(find.byIcon(Icons.chevron_right)); // page 2
      await tester.pumpAndSettle();
      expect(numebrOfCheckboxes(false), 11);
      await tester.tap(find.byIcon(Icons.chevron_right)); // page 3
      await tester.pumpAndSettle();
      expect(numebrOfCheckboxes(false), 11);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(numebrOfCheckboxes(true), 11);
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(numebrOfCheckboxes(false), 11);
    });
  });

  testWidgets('PageSyncApproach.doNothing', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 300));
    await tester.pumpWidget(MaterialApp(
        home: Material(
            child: buildAsyncPaginatedTable(
                showHeader: false,
                showCheckboxColumn: false,
                fewerResultsAfterRefresh: true,
                syncApproach: PageSyncApproach.doNothing))));

    await tester.pumpAndSettle();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 11 + 1)); // 3 columns, 10 rows + 1 header row + paginator
    expect(find.text('Cupcake'), findsOneWidget);
    expect(find.text('1–10 of 30'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 1 + 1)); // 3 columns, 0 rows + 1 header row + paginator
    expect(find.text('Frozen yogurt x2'), findsNothing);
    expect(find.text('11–20 of 10'), findsOneWidget);
  });

  testWidgets('Page switch and PageSyncApproach.goToFirst',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 300));
    await tester.pumpWidget(MaterialApp(
        home: Material(
            child: buildAsyncPaginatedTable(
                showHeader: false,
                showCheckboxColumn: false,
                fewerResultsAfterRefresh: true,
                syncApproach: PageSyncApproach.goToFirst))));

    await tester.pumpAndSettle();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 11 + 1)); // 3 columns, 10 rows + 1 header row + paginator
    expect(find.text('Cupcake'), findsOneWidget);
    expect(find.text('1–10 of 30'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    // // peek into what text is visible
    // var d = find.byType(Text);
    // var w = tester.widgetList(d).toList();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 11 + 1)); // 3 columns, 0 rows + 1 header row + paginator
    expect(find.text('Frozen yogurt x2'), findsNothing);
    expect(find.text('1–10 of 10'), findsOneWidget);
  });

  testWidgets('Page switch and PageSyncApproach.goToLast',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 300));
    await tester.pumpWidget(MaterialApp(
        home: Material(
            child: buildAsyncPaginatedTable(
                showHeader: false,
                rowsPerPage: 5,
                showCheckboxColumn: false,
                fewerResultsAfterRefresh: true,
                syncApproach: PageSyncApproach.goToLast))));

    await tester.pumpAndSettle();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 6 + 1)); // 3 columns, 10 rows + 1 header row + paginator
    expect(find.text('Cupcake'), findsOneWidget);
    expect(find.text('1–5 of 30'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    // // peek into what text is visible
    // var d = find.byType(Text);
    // var w = tester.widgetList(d).toList();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 6 + 1)); // 3 columns, 0 rows + 1 header row + paginator
    expect(find.text('Frozen yogurt x2'), findsNothing);
    expect(find.text('6–10 of 10'), findsOneWidget);
  });

  testWidgets('Page size and PageSyncApproach.goToFirst',
      (WidgetTester tester) async {
    var controller = PaginatorController();
    await tester.binding.setSurfaceSize(const Size(1000, 300));
    await tester.pumpWidget(MaterialApp(
        home: Material(
            child: buildAsyncPaginatedTable(
                showHeader: false,
                rowsPerPage: 5,
                controller: controller,
                initialFirstRowIndex: 15,
                showCheckboxColumn: false,
                fewerResultsAfterRefresh: true,
                syncApproach: PageSyncApproach.goToFirst))));

    await tester.pumpAndSettle();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 6 + 1)); // 3 columns, 10 rows + 1 header row + paginator
    expect(find.text('Honeycomb'), findsOneWidget);
    expect(find.text('16–20 of 30'), findsOneWidget);

    controller.setRowsPerPage(10);
    await tester.pumpAndSettle();

    // // peek into what text is visible
    // var d = find.byType(Text);
    // var w = tester.widgetList(d).toList();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 11 + 1)); // 3 columns, 0 rows + 1 header row + paginator
    expect(find.text('Cupcake'), findsOneWidget);
    expect(find.text('1–10 of 10'), findsOneWidget);
  });

  testWidgets('Page size and PageSyncApproach.goToLast',
      (WidgetTester tester) async {
    var controller = PaginatorController();
    await tester.binding.setSurfaceSize(const Size(1000, 300));
    await tester.pumpWidget(MaterialApp(
        home: Material(
            child: buildAsyncPaginatedTable(
                showHeader: false,
                rowsPerPage: 5,
                controller: controller,
                initialFirstRowIndex: 20,
                showCheckboxColumn: false,
                fewerResultsAfterRefresh: true,
                syncApproach: PageSyncApproach.goToLast))));

    await tester.pumpAndSettle();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 6 + 1)); // 3 columns, 10 rows + 1 header row + paginator
    expect(find.text('Jelly bean'), findsOneWidget);
    expect(find.text('21–25 of 30'), findsOneWidget);

    controller.setRowsPerPage(10);
    await tester.pumpAndSettle();

    // // peek into what text is visible
    // var d = find.byType(Text);
    // var w = tester.widgetList(d).toList();

    expect(
        find.byType(Text),
        findsNWidgets(
            3 * 11 + 1)); // 3 columns, 0 rows + 1 header row + paginator
    expect(find.text('Donut x3'), findsOneWidget);
    expect(find.text('1–10 of 10'), findsOneWidget);
  });

  testWidgets('DataTable2 custom sort arrow widget',
      (WidgetTester tester) async {
    const alwaysShowArrows = false;
    Widget buildTable({bool sortAscending = true}) {
      return DataTable2(
        sortColumnIndex: 0,
        sortAscending: sortAscending,
        sortArrowBuilder: (ascending, sorted) => sorted || alwaysShowArrows
            ? Stack(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: _SortIcon(
                          ascending: true, active: sorted && ascending)),
                  Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _SortIcon(
                          ascending: false, active: sorted && !ascending)),
                ],
              )
            : null,
        columns: <DataColumn>[
          DataColumn(
            label: const Text('Name'),
            tooltip: 'Name',
            onSort: (int columnIndex, bool ascending) {},
          ),
          DataColumn(
            label: const Text('Calories'),
            tooltip: 'Calories',
            onSort: (int columnIndex, bool ascending) {},
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text(dessert.calories.toString()),
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

    List upArrow =
        tester.widgetList(find.byIcon(Icons.arrow_drop_up_rounded)).toList();
    List downArrow =
        tester.widgetList(find.byIcon(Icons.arrow_drop_down_rounded)).toList();
    expect(upArrow.length, equals(1));
    expect(downArrow.length, equals(1));

    expect(upArrow.first.color, equals(Colors.cyan));
    expect(downArrow.first.color, null);

    // Check for descending list.
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable(sortAscending: false)),
    ));
    await tester.pumpAndSettle();

    upArrow =
        tester.widgetList(find.byIcon(Icons.arrow_drop_up_rounded)).toList();
    downArrow =
        tester.widgetList(find.byIcon(Icons.arrow_drop_down_rounded)).toList();
    expect(upArrow.length, equals(1));
    expect(downArrow.length, equals(1));

    expect(upArrow.first.color, null);
    expect(downArrow.first.color, equals(Colors.cyan));
  });

  testWidgets('DataTable2 checkbox themes', (WidgetTester tester) async {
    Widget buildTable() {
      return DataTable2(
        headingCheckboxTheme:
            CheckboxThemeData(fillColor: WidgetStateProperty.all(Colors.red)),
        datarowCheckboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.all(Colors.yellow)),
        showCheckboxColumn: true,
        onSelectAll: (value) {},
        columns: <DataColumn>[
          DataColumn(
            label: const Text('Name'),
            tooltip: 'Name',
            onSort: (int columnIndex, bool ascending) {},
          ),
          DataColumn(
            label: const Text('Calories'),
            tooltip: 'Calories',
            onSort: (int columnIndex, bool ascending) {},
          ),
        ],
        rows: kDesserts.map<DataRow2>((Dessert dessert) {
          return DataRow2(
            onSelectChanged: (v) {},
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text(dessert.calories.toString()),
              ),
            ],
          );
        }).toList(),
      );
    }

    // Check for ascending list
    await tester.pumpWidget(MaterialApp(
      home: Material(child: buildTable()),
    ));

    var h = find.byType(Theme).evaluate().where((element) =>
        (element.widget as Theme).data.checkboxTheme.fillColor != null &&
        (element.widget as Theme)
                .data
                .checkboxTheme
                .fillColor!
                .resolve({WidgetState.hovered}) ==
            Colors.red);
    expect(h.length, 1);
    expect((h.first.widget as Theme).child.runtimeType, Checkbox);

    var d = find.byType(Theme).evaluate().where((element) =>
        (element.widget as Theme).data.checkboxTheme.fillColor != null &&
        (element.widget as Theme)
                .data
                .checkboxTheme
                .fillColor!
                .resolve({WidgetState.hovered}) ==
            Colors.yellow);
    expect(d.length, kDesserts.length);
    expect((d.first.widget as Theme).child.runtimeType, Checkbox);
  });

  testWidgets('DataTable2 heading checkbox', (WidgetTester tester) async {
    final List<DataColumn2> columns = [
      const DataColumn2(label: Text('Column1')),
    ];
    final List<DataRow2> rows = [
      DataRow2(
        onSelectChanged: (value) {},
        cells: const [DataCell(Text('Content1'))],
      ),
    ];

    // Check if heading checkbox is shown by default
    await wrapWidgetSetSurf(
        tester,
        buildTable(
          columns: columns,
          rows: rows,
        ));

    await tester.pumpAndSettle();
    expect(find.text('Column1'), findsOneWidget);
    expect(find.byType(Checkbox), findsNWidgets(2));

    // Check if heading checkbox is hided
    await wrapWidgetSetSurf(
        tester,
        buildTable(
          showHeadingCheckbox: false,
          columns: columns,
          rows: rows,
        ));

    await tester.pumpAndSettle();
    expect(find.text('Column1'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
  });
}

Tripple<Size> _getColumnSizes(WidgetTester tester, bool header) {
  var s0 = tester.getSize(find.byType(DataTable2));

  var c = findFirstContainerFor(header ? 'Name' : 'Frozen yogurt');
  var s1 = tester.getSize(c);

  c = findFirstContainerFor(header ? 'Calories' : '159');
  expect(c, findsOneWidget);
  var s2 = tester.getSize(c);

  c = findFirstContainerFor(header ? 'Carbs' : '24');
  expect(c, findsOneWidget);
  var s3 = tester.getSize(c);

  print('${s0.width} ${s1.width} ${s2.width} ${s3.width}');

  return Tripple(s1, s2, s3);
}

Future<void> _defaultColumnSizeApplied(WidgetTester tester, bool header) async {
  await tester.pumpAndSettle();

  var s = _getColumnSizes(tester, header);

  // Firsrt column is half margin greater than the  second one.
  // 24p margin is split between check box (zero) column and second column
  expect((s.v1.width - 12 - s.v2.width).abs() < 0.01, true);

  // Last column is margin greater (24p) than the middle one.
  expect((s.v3.width - 24 - s.v2.width).abs() < 0.01, true);
}

Future<void> _smlColumnSizeApplied(WidgetTester tester, bool header) async {
  await tester.pumpAndSettle();
  var s = _getColumnSizes(tester, header);

  // Firsrt column is half margin greater than the  second one.
  // 24p margin is split between check box (zero) column and second column
  expect(((s.v1.width - 12) / s.v2.width - 0.67).abs() < 0.01, true);

  // Last column is margin greater (24p) than the middle one.
  expect(((s.v3.width - 24) / s.v2.width - 1.2).abs() < 0.01, true);
}

Future<void> _smlOverridenColumnSizeApplied(
    WidgetTester tester, bool header) async {
  await tester.pumpAndSettle();
  var s = _getColumnSizes(tester, header);

  // Firsrt column is half margin greater than the  second one.
  // 24p margin is split between check box (zero) column and second column
  expect(((s.v1.width - 12) / s.v2.width - 0.5).abs() < 0.01, true);

  // Last column is margin greater (24p) than the middle one.
  expect(((s.v3.width - 24) / s.v2.width - 1.5).abs() < 0.01, true);
}

class _SortIcon extends StatelessWidget {
  final bool ascending;
  final bool active;

  const _SortIcon({required this.ascending, required this.active});

  @override
  Widget build(BuildContext context) {
    return Icon(
      ascending ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
      size: 28,
      color: active ? Colors.cyan : null,
    );
  }
}
