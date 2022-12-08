import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../data_sources.dart';
import '../nav_helper.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class DataTable2Demo extends StatefulWidget {
  const DataTable2Demo({super.key});

  @override
  DataTable2DemoState createState() => DataTable2DemoState();
}

class DataTable2DemoState extends State<DataTable2Demo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final currentRouteOption = getCurrentRouteOption(context);
      _dessertsDataSource = DessertDataSource(
          context,
          false,
          currentRouteOption == rowTaps,
          currentRouteOption == rowHeightOverrides,
          currentRouteOption == showBordersWithZebraStripes);
      // Default sorting sample. Set __sortColumnIndex to 0 and uncoment the lines below
      // if (_sortColumnIndex == 0) {
      //   _sort<String>((d) => d.name, _sortColumnIndex!, _sortAscending);
      // }
      _initialized = true;
      _dessertsDataSource.addListener(() {
        setState(() {});
      });
    }
  }

  void _sort<T>(
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        hideColumnsHeader: getCurrentRouteOption(context) == hideColumnHeaders,
        border: getCurrentRouteOption(context) == fixedColumnWidth
            ? TableBorder(
                top: const BorderSide(color: Colors.black),
                bottom: BorderSide(color: Colors.grey[300]!),
                left: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
                verticalInside: BorderSide(color: Colors.grey[300]!),
                horizontalInside:
                    const BorderSide(color: Colors.grey, width: 1))
            : (getCurrentRouteOption(context) == showBordersWithZebraStripes
                ? TableBorder.all()
                : null),
        dividerThickness:
            1, // this one will be ignored if [border] is set above
        bottomMargin: 10,
        minWidth: 900,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        sortArrowIcon: Icons.keyboard_arrow_up, // custom arrow
        sortArrowAnimationDuration:
            const Duration(milliseconds: 500), // custom animation duration
        onSelectAll: (val) =>
            setState(() => _dessertsDataSource.selectAll(val)),
        columns: [
          DataColumn2(
            label: const Text('Desert'),
            size: ColumnSize.S,
            // example of fixed 1st row
            fixedWidth:
                getCurrentRouteOption(context) == fixedColumnWidth ? 200 : null,
            onSort: (columnIndex, ascending) =>
                _sort<String>((d) => d.name, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Calories'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.calories, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Fat (gm)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.fat, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Carbs (gm)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.carbs, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Protein (gm)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.protein, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Sodium (mg)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.sodium, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Calcium (%)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.calcium, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Iron (%)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.iron, columnIndex, ascending),
          ),
        ],
        empty: Center(
            child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.grey[200],
                child: const Text('No data'))),
        rows: getCurrentRouteOption(context) == noData
            ? []
            : List<DataRow>.generate(_dessertsDataSource.rowCount,
                (index) => _dessertsDataSource.getRow(index)),
      ),
    );
  }
}
