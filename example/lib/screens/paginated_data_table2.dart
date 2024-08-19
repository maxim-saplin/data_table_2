// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import '../data_sources.dart';
import '../nav_helper.dart';
import '../custom_pager.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class PaginatedDataTable2Demo extends StatefulWidget {
  const PaginatedDataTable2Demo({super.key});

  @override
  PaginatedDataTable2DemoState createState() => PaginatedDataTable2DemoState();
}

class PaginatedDataTable2DemoState extends State<PaginatedDataTable2Demo> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;
  PaginatorController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dessertsDataSource = DessertDataSource(
          context, getCurrentRouteOption(context) == defaultSorting);

      _controller = PaginatorController();

      if (getCurrentRouteOption(context) == defaultSorting) {
        _sortColumnIndex = 1;
      }
      _initialized = true;
    }
  }

  void sort<T>(
    Comparable<T> Function(Dessert d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dessertsDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void dispose() {
    _dessertsDataSource.dispose();
    super.dispose();
  }

  List<DataColumn> get _columns {
    return [
      DataColumn(
        label: const Text('Desert'),
        onSort: (columnIndex, ascending) =>
            sort<String>((d) => d.name, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Calories'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            sort<num>((d) => d.calories, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Fat (gm)'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            sort<num>((d) => d.fat, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Carbs (gm)'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            sort<num>((d) => d.carbs, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Protein (gm)'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            sort<num>((d) => d.protein, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Sodium (mg)'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            sort<num>((d) => d.sodium, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Calcium (%)'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            sort<num>((d) => d.calcium, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Iron (%)'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            sort<num>((d) => d.iron, columnIndex, ascending),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      PaginatedDataTable2(
        // 100 Won't be shown since it is smaller than total records
        availableRowsPerPage: const [2, 5, 10, 30, 100],
        horizontalMargin: 20,
        checkboxHorizontalMargin: 12,
        columnSpacing: 0,
        wrapInCard: false,
        renderEmptyRowsInTheEnd: false,
        headingRowColor:
            WidgetStateColor.resolveWith((states) => Colors.grey[200]!),
        header:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('PaginatedDataTable2'),
          if (kDebugMode && getCurrentRouteOption(context) == custPager)
            Row(children: [
              OutlinedButton(
                  onPressed: () => _controller!.goToPageWithRow(25),
                  child: const Text('Go to row 25')),
              OutlinedButton(
                  onPressed: () => _controller!.goToRow(5),
                  child: const Text('Go to row 5'))
            ]),
          if (getCurrentRouteOption(context) == custPager &&
              _controller != null)
            PageNumber(controller: _controller!)
        ]),
        rowsPerPage: _rowsPerPage,
        autoRowsToHeight: getCurrentRouteOption(context) == autoRows,
        minWidth: 800,
        fit: FlexFit.tight,
        border: TableBorder(
            top: const BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.grey[300]!),
            left: BorderSide(color: Colors.grey[300]!),
            right: BorderSide(color: Colors.grey[300]!),
            verticalInside: BorderSide(color: Colors.grey[300]!),
            horizontalInside: const BorderSide(color: Colors.grey, width: 1)),
        onRowsPerPageChanged: (value) {
          // No need to wrap into setState, it will be called inside the widget
          // and trigger rebuild
          //setState(() {
          _rowsPerPage = value!;
          print(_rowsPerPage);
          //});
        },
        initialFirstRowIndex: 0,
        onPageChanged: (rowIndex) {
          print(rowIndex / _rowsPerPage);
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        sortArrowIcon: Icons.keyboard_arrow_up, // custom arrow
        sortArrowAnimationDuration:
            const Duration(milliseconds: 0), // custom animation duration
        onSelectAll: _dessertsDataSource.selectAll,
        controller:
            getCurrentRouteOption(context) == custPager ? _controller : null,
        hidePaginator: getCurrentRouteOption(context) == custPager,
        columns: _columns,
        empty: Center(
            child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.grey[200],
                child: const Text('No data'))),
        source: getCurrentRouteOption(context) == noData
            ? DessertDataSource.empty(context)
            : _dessertsDataSource,
      ),
      if (getCurrentRouteOption(context) == custPager)
        Positioned(bottom: 16, child: CustomPager(_controller!))
    ]);
  }
}
