@TestOn('!chrome')

import 'package:data_table_2/data_table_2.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';

void main() {
  group('DataTable2', () {
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
      await tester.binding.setSurfaceSize(Size(250, 500));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(Column).last);
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

    testWidgets('empty widget is displayed when there\'s no data',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(empty: Text('No data'), noData: true));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
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
      await tester.binding.setSurfaceSize(Size(1000, height));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      var n = ((height - 56 - 56) / 48).floor() + 1;
      // - header row - footer
      // +1 - checkbox in header

      expect(find.byType(Checkbox), findsNWidgets(n));
      expect(rowsPp, n - 1);

      await tester.binding.setSurfaceSize(Size(1000, height * 2));
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
      await tester.binding.setSurfaceSize(Size(1000, height));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      expect(find.byType(Checkbox),
          findsNWidgets(((height - 64 - 56 - 56) / 48).floor() + 1));
      // - header - header row - footer
      // +1 - checkbox in header

      await tester.binding.setSurfaceSize(Size(1000, height * 2));
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
      await tester.binding.setSurfaceSize(Size(1000, height));

      var s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox),
          findsNWidgets(((height - 64 - 56 - 56 - 8) / 48).floor() + 1));
      // - header - header row - footer
      // +1 - checkbox in header

      await tester.binding.setSurfaceSize(Size(1000, height * 2));
      await tester.pumpAndSettle();
      s1 = tester.getSize(find.byType(PaginatedDataTable2).first);
      print('${s1.width} ${s1.height} ');

      expect(find.byType(Checkbox),
          findsNWidgets(((2 * height - 64 - 56 - 56 - 8) / 48).floor() + 1));
    });

    testWidgets('autoRowsToHeight doesn\'t allow setting page size',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(1000, 300));
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

      await tester.binding.setSurfaceSize(Size(200, 300));
      await tester.pumpAndSettle();

      var s1 = tester.getSize(find.byType(Column).last);
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

    testWidgets('empty widget is displayed when there\'s no data',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildPaginatedTable(empty: Text('No data'), noData: true));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
    });
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
  var s = _getColumnSizes(tester, header);

  // Firsrt column is half margin greater than the  second one.
  // 24p margin is split between check box (zero) column and second column
  expect((s.v1.width - 12 - s.v2.width).abs() < 0.01, true);

  // Last column is margin greater (24p) than the middle one.
  expect((s.v3.width - 24 - s.v2.width).abs() < 0.01, true);
}

Future<void> _smlColumnSizeApplied(WidgetTester tester, bool header) async {
  var s = _getColumnSizes(tester, header);

  // Firsrt column is half margin greater than the  second one.
  // 24p margin is split between check box (zero) column and second column
  expect(((s.v1.width - 12) / s.v2.width - 0.67).abs() < 0.01, true);

  // Last column is margin greater (24p) than the middle one.
  expect(((s.v3.width - 24) / s.v2.width - 1.2).abs() < 0.01, true);
}

Future<void> _smlOverridenColumnSizeApplied(
    WidgetTester tester, bool header) async {
  var s = _getColumnSizes(tester, header);

  // Firsrt column is half margin greater than the  second one.
  // 24p margin is split between check box (zero) column and second column
  expect(((s.v1.width - 12) / s.v2.width - 0.5).abs() < 0.01, true);

  // Last column is margin greater (24p) than the middle one.
  expect(((s.v3.width - 24) / s.v2.width - 1.5).abs() < 0.01, true);
}
