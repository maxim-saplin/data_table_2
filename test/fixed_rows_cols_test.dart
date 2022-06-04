// ignore_for_file: avoid_print

@TestOn('!chrome')

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';

// Table with 10 rows, aproximately 450 pixel tall
void main() {
  group('Fixed cols/rows out of range', () {
    testWidgets('Fixed columns equal to the number of columns',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(fixedLeftColumns: 3), const Size(500, 300));

      _verifyDataTable2InitialState(tester);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
    });

    testWidgets('Fixed columns greater than number of columns',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(fixedLeftColumns: 4), const Size(500, 300));

      _verifyDataTable2InitialState(tester);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
    });

    testWidgets('Fixed rows equal to the number of rows',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(fixedTopRows: 10), const Size(500, 800));

      _verifyDataTable2InitialState(tester, true, false);

      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
    });

    testWidgets('Fixed rows greater than number of columns',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(fixedTopRows: 11), const Size(500, 800));

      _verifyDataTable2InitialState(tester, true, false);

      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
    });
  });

  group('Scrolling', () {
    testWidgets('Default settings (fixed header), scroll to bottom',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(tester, buildTable(), const Size(500, 300));

      _verifyDataTable2InitialState(tester);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
    });

    testWidgets('No fixed sections, scroll to bottom',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(fixedTopRows: 0), const Size(500, 300));

      _verifyDataTable2InitialState(tester);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
    });

    testWidgets('2 fixed rows, scroll to bottom', (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(fixedTopRows: 2), const Size(500, 300));

      _verifyDataTable2InitialState(tester);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isFalse);
    });

    testWidgets('3 fixed rows, scroll to bottom', (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester, buildTable(fixedTopRows: 3), const Size(500, 300));

      _verifyDataTable2InitialState(tester);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
    });

    testWidgets(
        '3 fixed rows, 1 fixed column, no minWidth, scroll to bottom, scroll views sync test',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 3, fixedLeftColumns: 1),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
    });

    testWidgets(
        '3 fixed rows, 2 fixed columns, no minWidth, scroll to bottom (via fixed col item), scroll views sync test ',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 3, fixedLeftColumns: 2),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);

      await tester.ensureVisible(find.text(
          'KitKat')); // now this one is ont the fixed column which has separate scrollable/controller from the left item
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
    });

    testWidgets(
        '0 fixed rows, 1 fixed column, no minWidth, scroll to bottom, scroll views sync test ',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 0, fixedLeftColumns: 2),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);

      await tester.ensureVisible(find.text(
          'KitKat')); // now this one is ont the fixed column which has separate scrollable/controller from the left item
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
    });

    testWidgets(
        '0 fixed rows, 2 fixed columns, no minWidth, scroll to bottom (via fixed col item), scroll views sync test ',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 0, fixedLeftColumns: 2),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);

      await tester.ensureVisible(find.text(
          'KitKat')); // now this one is ont the fixed column which has separate scrollable/controller from the left item
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
    });

    testWidgets(
        '3 fixed rows, 2 fixed columns, with minWidth, scroll to bottom (via fixed col item), scroll views sync test ',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 3, fixedLeftColumns: 2, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);

      await tester.ensureVisible(find.text(
          'KitKat')); // now this one is ont the fixed column which has separate scrollable/controller from the left item
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isFalse);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
    });

    testWidgets('0 fixed rows, 0 fixed columns, with minWidth, scroll to right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 0, fixedLeftColumns: 0, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('Carbs'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('24'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets('0 fixed rows, 1 fixed column, with minWidth, scroll to right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 0, fixedLeftColumns: 1, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('Carbs'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('24'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets('0 fixed rows, 2 fixed columns, with minWidth, scroll to right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 0, fixedLeftColumns: 2, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('Carbs'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('24'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isTrue);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets(
        '1 fixed row, 1 fixed column, with minWidth, scroll to right (via fixed row item), scroll views sync test',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 1, fixedLeftColumns: 1, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('Carbs'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('24'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets(
        '1 fixed row, 2 fixed columns, with minWidth, scroll to right (via fixed row item), scroll views sync test',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 1, fixedLeftColumns: 2, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('Carbs'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('24'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isTrue);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets(
        '3 fixed rows, 2 fixed columns, with minWidth, scroll to right (via fixed row item), scroll views sync test',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 3, fixedLeftColumns: 2, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('Carbs'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('24'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isTrue);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets(
        '0 fixed rows, 0 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 0, fixedLeftColumns: 0, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets(
        '1 fixed row, 0 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 1, fixedLeftColumns: 0, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets(
        '2 fixed rows, 0 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 2, fixedLeftColumns: 0, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets(
        '3 fixed rows, 0 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 3, fixedLeftColumns: 0, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);
      expect(_isVisibleInTable(find.text('237'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets(
        '1 fixed row, 1 fixed column, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 1, fixedLeftColumns: 1, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
    });

    testWidgets(
        '1 fixed row, 2 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 1, fixedLeftColumns: 2, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
    });

    testWidgets(
        '2 fixed rows, 2 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 2, fixedLeftColumns: 2, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
    });

    testWidgets(
        '3 fixed rows, 2 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurf(
          tester,
          buildTable(fixedTopRows: 3, fixedLeftColumns: 2, minWidth: 850),
          const Size(500, 300));

      _verifyDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);
      expect(_isVisibleInTable(find.text('237'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
    });
  });
}

bool _isVisibleInTable(Finder widget, WidgetTester tester) {
  var tableDimentions = tester.getSize(find.byType(DataTable2));
  var el = widget.evaluate().first;

  var pos = el.renderObject!.getTransformTo(null).getTranslation();

  return pos.y >= 0 &&
      pos.y < tableDimentions.height &&
      pos.x >= 0 &&
      pos.x < tableDimentions.width;
}

void _verifyDataTable2InitialState(WidgetTester tester,
    [includeCarbsHeader = true, includeKitKat = true]) {
  expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
  expect(_isVisibleInTable(find.text('Calories'), tester), isTrue);
  if (includeCarbsHeader) {
    expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
  } // goes out of sight with minWidth greater than surface size

  expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
  expect(_isVisibleInTable(find.text('159'), tester), isTrue);
  expect(_isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);
  expect(_isVisibleInTable(find.text('237'), tester), isTrue);
  expect(_isVisibleInTable(find.text('Eclair'), tester), isTrue);
  expect(_isVisibleInTable(find.text('262'), tester), isTrue);

  if (includeKitKat) {
    expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);

    expect(_isVisibleInTable(find.text('518'), tester), isFalse);
    expect(_isVisibleInTable(find.text('65'), tester), isFalse);
  }

  expect(find.byType(Checkbox), findsNWidgets(11));
}
