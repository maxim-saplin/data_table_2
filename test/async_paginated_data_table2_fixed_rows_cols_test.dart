// ignore_for_file: avoid_print

@TestOn('!chrome')
library;

import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'test_utils.dart';

// Table with 10 rows, aproximately 450 pixel tall
main() {
  group('AsyncPaginatedDataTable2 Fixed colums/corner colors', () {
    testWidgets('0 cols, 0 rows', (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedLeftColumns: 0,
              fixedTopRows: 0,
              headingRowColor: Colors.yellow,
              fixedColumnsColor: Colors.red,
              fixedCornerColor: Colors.blue),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      var decorations = find
          .byType(Table)
          .evaluate()
          .map<Table>((e) => e.widget as Table)
          .fold<List<Table>>([], (l, i) {
        l.add(i);
        return l;
      }).fold<List<TableRow>>([], (l, i) {
        l.addAll(i.children);
        return l;
      }).map<BoxDecoration>((e) => e.decoration as BoxDecoration);

      expect(decorations.where((c) => c.color == Colors.yellow).length, 1);
      expect(decorations.where((c) => c.color == Colors.blue).length, 0);
      expect(decorations.where((c) => c.color == Colors.red).length, 0);
    });

    testWidgets('1 col, 0 rows', (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedLeftColumns: 1,
              fixedTopRows: 0,
              headingRowColor: Colors.yellow,
              fixedCornerColor: Colors.blue,
              fixedColumnsColor: Colors.red),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      var decorations = find
          .byType(Table)
          .evaluate()
          .map<Table>((e) => e.widget as Table)
          .fold<List<Table>>([], (l, i) {
        l.add(i);
        return l;
      }).fold<List<TableRow>>([], (l, i) {
        l.addAll(i.children);
        return l;
      }).map<BoxDecoration>((e) => e.decoration as BoxDecoration);

      expect(decorations.where((c) => c.color == Colors.yellow).length, 1);
      expect(decorations.where((c) => c.color == Colors.blue).length, 0);
      expect(decorations.where((c) => c.color == Colors.red).length, 11);
    });

    testWidgets('2 cols, 0 rows', (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedLeftColumns: 2,
              fixedTopRows: 0,
              headingRowColor: Colors.yellow,
              fixedCornerColor: Colors.blue,
              fixedColumnsColor: Colors.red),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      var decorations = find
          .byType(Table)
          .evaluate()
          .map<Table>((e) => e.widget as Table)
          .fold<List<Table>>([], (l, i) {
        l.add(i);
        return l;
      }).fold<List<TableRow>>([], (l, i) {
        l.addAll(i.children);
        return l;
      }).map<BoxDecoration>((e) => e.decoration as BoxDecoration);

      expect(decorations.where((c) => c.color == Colors.yellow).length, 1);
      expect(decorations.where((c) => c.color == Colors.blue).length, 0);
      expect(decorations.where((c) => c.color == Colors.red).length, 11);
    });

    testWidgets('3 cols, 0 rows', (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedLeftColumns: 3,
              fixedTopRows: 0,
              headingRowColor: Colors.yellow,
              fixedCornerColor: Colors.blue,
              fixedColumnsColor: Colors.red),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      var decorations = find
          .byType(Table)
          .evaluate()
          .map<Table>((e) => e.widget as Table)
          .fold<List<Table>>([], (l, i) {
        l.add(i);
        return l;
      }).fold<List<TableRow>>([], (l, i) {
        l.addAll(i.children);
        return l;
      }).map<BoxDecoration>((e) => e.decoration as BoxDecoration);

      expect(decorations.where((c) => c.color == Colors.yellow).length, 1);
      expect(decorations.where((c) => c.color == Colors.blue).length, 0);
      expect(decorations.where((c) => c.color == Colors.red).length, 11);
    });

    testWidgets('1 col, 1 row', (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedLeftColumns: 1,
              fixedTopRows: 1,
              headingRowColor: Colors.yellow,
              fixedCornerColor: Colors.blue,
              fixedColumnsColor: Colors.red),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      var decorations = find
          .byType(Table)
          .evaluate()
          .map<Table>((e) => e.widget as Table)
          .fold<List<Table>>([], (l, i) {
        l.add(i);
        return l;
      }).fold<List<TableRow>>([], (l, i) {
        l.addAll(i.children);
        return l;
      }).map<BoxDecoration>((e) => e.decoration as BoxDecoration);

      expect(decorations.where((c) => c.color == Colors.yellow).length, 1);
      expect(decorations.where((c) => c.color == Colors.blue).length, 1);
      expect(decorations.where((c) => c.color == Colors.red).length, 10);
    });

    testWidgets('3 cols, 3 rows', (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedLeftColumns: 3,
              fixedTopRows: 3,
              headingRowColor: Colors.yellow,
              fixedCornerColor: Colors.blue,
              fixedColumnsColor: Colors.red),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      var decorations = find
          .byType(Table)
          .evaluate()
          .map<Table>((e) => e.widget as Table)
          .fold<List<Table>>([], (l, i) {
        l.add(i);
        return l;
      }).fold<List<TableRow>>([], (l, i) {
        l.addAll(i.children);
        return l;
      }).map<BoxDecoration>((e) => e.decoration as BoxDecoration);

      expect(decorations.where((c) => c.color == Colors.yellow).length, 3);
      expect(decorations.where((c) => c.color == Colors.blue).length, 3);
      expect(decorations.where((c) => c.color == Colors.red).length, 8);
    });

    testWidgets('async paginated 3 cols, 3 rows, golden',
        (WidgetTester tester) async {
      await loadAppFonts();
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedLeftColumns: 3,
              fixedTopRows: 3,
              headingRowColor: Colors.yellow,
              fixedCornerColor: Colors.blue,
              fixedColumnsColor: Colors.red),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      await expectLater(find.byType(AsyncPaginatedDataTable2),
          matchesGoldenFile('async_paginated_fixed_3_3_colors.png'));
    });

    testWidgets(
        '[headingRowDecoration] color will override [headerRowColor] and [fixedCornerColor]',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
            useKDeserts: true,
            fixedLeftColumns: 1,
            fixedTopRows: 1,
            headingRowColor: Colors.yellow,
            fixedCornerColor: Colors.blue,
            headingRowDecoration: const BoxDecoration(color: Colors.pink),
          ),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      var decorations = find
          .byType(Table)
          .evaluate()
          .map<Table>((e) => e.widget as Table)
          .fold<List<Table>>([], (l, i) {
        l.add(i);
        return l;
      }).fold<List<TableRow>>([], (l, i) {
        l.addAll(i.children);
        return l;
      }).map<BoxDecoration>((e) => e.decoration as BoxDecoration);

      expect(decorations.where((c) => c.color == Colors.yellow).length, 0);
      expect(decorations.where((c) => c.color == Colors.blue).length, 0);
      expect(decorations.where((c) => c.color == Colors.pink).length, 2);
    });

    testWidgets(
        '[headingRowDecoration] gradient will overlay [headerRowColor] and [fixedCornerColor]',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedLeftColumns: 1,
              fixedTopRows: 1,
              headingRowColor: Colors.yellow,
              fixedCornerColor: Colors.blue,
              headingRowDecoration: const BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.pink, Colors.purple]))),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      var decorations = find
          .byType(Table)
          .evaluate()
          .map<Table>((e) => e.widget as Table)
          .fold<List<Table>>([], (l, i) {
        l.add(i);
        return l;
      }).fold<List<TableRow>>([], (l, i) {
        l.addAll(i.children);
        return l;
      }).map<BoxDecoration>((e) => e.decoration as BoxDecoration);

      expect(decorations.where((c) => c.color == Colors.yellow).length, 1);
      expect(decorations.where((c) => c.color == Colors.blue).length, 1);
      expect(
          decorations
              .where((c) =>
                  c.gradient ==
                  const LinearGradient(colors: [Colors.pink, Colors.purple]))
              .length,
          2);
    });
  });

  group('AsyncPaginatedDataTable2 Fixed cols/rows out of range', () {
    testWidgets('Fixed columns equal to the number of columns',
        (WidgetTester tester) async {
      // Will fail if not macOS, see data_table_2.dart _isControllerActive()
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(useKDeserts: true, fixedLeftColumns: 3),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Fixed columns greater than number of columns',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(useKDeserts: true, fixedLeftColumns: 4),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
    });

    testWidgets('Fixed rows equal to the number of rows',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(useKDeserts: true, fixedTopRows: 10),
          const Size(500, 800));

      _verifyAsyncPaginatedDataTable2InitialState(tester, true, false);

      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
    });

    testWidgets('Fixed rows greater than number of rows',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(useKDeserts: true, fixedTopRows: 11),
          const Size(500, 800));

      _verifyAsyncPaginatedDataTable2InitialState(tester, true, false);

      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
    });

    testWidgets('Fixed rows/columns greater than number of rows/columns',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true, fixedTopRows: 12, fixedLeftColumns: 5),
          const Size(500, 800));

      _verifyAsyncPaginatedDataTable2InitialState(tester, true, false);

      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
    });

    testWidgets(
        'Fixed rows/columns greater than number of rows/columns, no checkbox column',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 12,
              fixedLeftColumns: 5,
              showCheckboxColumn: false),
          const Size(500, 800));

      _verifyAsyncPaginatedDataTable2InitialState(tester, true, false, false);

      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
    });
  });

  group('AsyncPaginatedDataTable2 Scrolling', () {
    testWidgets('Default settings (fixed header), scroll to bottom',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
            useKDeserts: true,
          ),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
    });

    testWidgets('No fixed sections, scroll to bottom',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(useKDeserts: true, fixedTopRows: 0),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
    });

    testWidgets('2 fixed rows, scroll to bottom', (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(useKDeserts: true, fixedTopRows: 2),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);
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
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(useKDeserts: true, fixedTopRows: 3),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);
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
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true, fixedTopRows: 3, fixedLeftColumns: 1),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);
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
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true, fixedTopRows: 3, fixedLeftColumns: 2),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);
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
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '0 fixed rows, 1 fixed column, no minWidth, scroll to bottom, scroll views sync test ',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true, fixedTopRows: 0, fixedLeftColumns: 2),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);

      await tester.ensureVisible(find.text(
          'KitKat')); // now this one is ont the fixed column which has separate scrollable/controller from the left item
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '0 fixed rows, 2 fixed columns, no minWidth, scroll to bottom (via fixed col item), scroll views sync test ',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true, fixedTopRows: 0, fixedLeftColumns: 2),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);
      expect(
          _isVisibleInTable(find.text('Ice cream sandwich'), tester), isTrue);

      await tester.ensureVisible(find.text(
          'KitKat')); // now this one is ont the fixed column which has separate scrollable/controller from the left item
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '3 fixed rows, 2 fixed columns, with minWidth, scroll to bottom (via fixed col item), scroll views sync test ',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 3,
              fixedLeftColumns: 2,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('0 fixed rows, 0 fixed columns, with minWidth, scroll to right',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 0,
              fixedLeftColumns: 0,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 0,
              fixedLeftColumns: 1,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 0,
              fixedLeftColumns: 2,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 1,
              fixedLeftColumns: 1,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('Carbs'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('24'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '1 fixed row, 2 fixed columns, with minWidth, scroll to right (via fixed row item), scroll views sync test',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 1,
              fixedLeftColumns: 2,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('Carbs'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('24'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isTrue);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '3 fixed rows, 2 fixed columns, with minWidth, scroll to right (via fixed row item), scroll views sync test',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 3,
              fixedLeftColumns: 2,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 0,
              fixedLeftColumns: 0,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 1,
              fixedLeftColumns: 0,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '2 fixed rows, 0 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 2,
              fixedLeftColumns: 0,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '3 fixed rows, 0 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 3,
              fixedLeftColumns: 0,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '1 fixed row, 1 fixed column, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 1,
              fixedLeftColumns: 1,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isFalse);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isFalse);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '1 fixed row, 2 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 1,
              fixedLeftColumns: 2,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
      expect(_isVisibleInTable(find.text('Carbs'), tester), isFalse);
      expect(_isVisibleInTable(find.text('24'), tester), isFalse);

      await tester.ensureVisible(find.text('65'));
      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '2 fixed rows, 2 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 2,
              fixedLeftColumns: 2,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '3 fixed rows, 1 fixed columns, with minWidth, no checkboxes, scroll to bottom right',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 3,
              fixedLeftColumns: 1,
              showCheckboxColumn: false,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false, true, false);
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

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '3 fixed rows, 2 fixed columns, with minWidth, scroll to bottom right',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 3,
              fixedLeftColumns: 2,
              minWidth: 850),
          const Size(500, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester, false);
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

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        '3 fixed rows, 2 fixed columns, with minWidth, with scrollController, scroll to bottom',
        (WidgetTester tester) async {
      var sc = ScrollController();

      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 3,
              fixedLeftColumns: 2,
              minWidth: 850,
              scrollController: sc),
          const Size(850, 300));

      _verifyAsyncPaginatedDataTable2InitialState(tester);

      sc.jumpTo(400);

      await tester.pumpAndSettle();

      expect(_isVisibleInTable(find.text('Carbs'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);
      expect(_isVisibleInTable(find.text('237'), tester), isTrue);
      expect(_isVisibleInTable(find.text('65'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Name'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Eclair'), tester), isFalse);
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
    });

    testWidgets(
        '0 fixed rows, 0-1 fixed column, left coulm out of sync when added, bug#111',
        (WidgetTester tester) async {
      var col = 0;
      var trigger = StreamController();

      var widget = StreamBuilder(
          stream: trigger.stream,
          builder: (c, s) {
            return buildAsyncPaginatedTable(
                useKDeserts: true,
                fixedTopRows: 0,
                fixedLeftColumns: col,
                minWidth: 850,
                showCheckboxColumn: false);
          });

      await wrapWidgetSetSurfAndWait(tester, widget, const Size(500, 300));
      await tester.pumpAndSettle();

      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
      expect(_isVisibleInTable(find.text('159'), tester), isFalse);

      col = 1;
      trigger.add(true);
      // await tester.pumpAndSettle();
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
    });

    testWidgets(
        '0 fixed rows, 0-1 fixed column, left coulm out of sync when added, with ScrollController, bug#111',
        (WidgetTester tester) async {
      var col = 0;
      var trigger = StreamController();
      var sc = ScrollController();

      var widget = StreamBuilder(
          stream: trigger.stream,
          builder: (c, s) {
            return buildAsyncPaginatedTable(
                useKDeserts: true,
                fixedTopRows: 0,
                fixedLeftColumns: col,
                scrollController: sc,
                minWidth: 850,
                showCheckboxColumn: false);
          });

      await wrapWidgetSetSurfAndWait(tester, widget, const Size(500, 300));
      await tester.pumpAndSettle();

      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);

      await tester.ensureVisible(find.text('KitKat'));
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);

      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
      expect(_isVisibleInTable(find.text('159'), tester), isFalse);

      col = 1;
      trigger.add(true);
      // await tester.pumpAndSettle();
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
    });
    testWidgets(
        '1 fixed rows, 1 fixed column, scroll down via core, scroll up via left column',
        (WidgetTester tester) async {
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 1,
              fixedLeftColumns: 1,
              minWidth: 850,
              showCheckboxColumn: false),
          const Size(500, 300));

      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);

      await tester.ensureVisible(find.text('518')); // core
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
      expect(_isVisibleInTable(find.text('159'), tester), isFalse);

      await tester.ensureVisible(find.text('159'));
      await tester.ensureVisible(find.text('518'));

      await tester.ensureVisible(find.text('Frozen yogurt')); // left column
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);
    });

    testWidgets(
        '1 fixed rows, 1 fixed column, scroll down via core, scroll up via left column, with controller',
        (WidgetTester tester) async {
      var sc = ScrollController();
      await wrapWidgetSetSurfAndWait(
          tester,
          buildAsyncPaginatedTable(
              useKDeserts: true,
              fixedTopRows: 1,
              fixedLeftColumns: 1,
              minWidth: 850,
              scrollController: sc,
              showCheckboxColumn: false),
          const Size(500, 300));

      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);

      await tester.ensureVisible(find.text('518')); // core
      expect(_isVisibleInTable(find.text('KitKat'), tester), isTrue);
      expect(_isVisibleInTable(find.text('518'), tester), isTrue);
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isFalse);
      expect(_isVisibleInTable(find.text('159'), tester), isFalse);

      await tester.ensureVisible(find.text('159'));
      await tester.ensureVisible(find.text('518'));

      await tester.ensureVisible(find.text('Frozen yogurt')); // left column
      expect(_isVisibleInTable(find.text('Frozen yogurt'), tester), isTrue);
      expect(_isVisibleInTable(find.text('159'), tester), isTrue);
    });
  });
}

bool _isVisibleInTable(Finder widget, WidgetTester tester) {
  var tableDimentions = tester.getSize(find.byType(AsyncPaginatedDataTable2));
  var el = widget.evaluate().first;

  var pos = el.renderObject!.getTransformTo(null).getTranslation();

  return pos.y >= 0 &&
      pos.y < tableDimentions.height &&
      pos.x >= 0 &&
      pos.x < tableDimentions.width;
}

void _verifyAsyncPaginatedDataTable2InitialState(WidgetTester tester,
    [includeCarbsHeader = true,
    includeKitKat = true,
    bool checkboxesPresent = true]) {
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

  expect(find.byType(Checkbox),
      checkboxesPresent ? findsNWidgets(11) : findsNothing);
}
