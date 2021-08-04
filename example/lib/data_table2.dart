import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'data_sources.dart';
import 'nav_helper.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class DataTable2Demo extends StatefulWidget {
  const DataTable2Demo();

  @override
  _DataTable2DemoState createState() => _DataTable2DemoState();
}

class _DataTable2DemoState extends State<DataTable2Demo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dessertsDataSource = DessertDataSource(context);
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
        border: getCurrentRouteOption(context) == showBorders
            ? TableBorder(
                top: BorderSide(color: Colors.black),
                bottom: BorderSide(color: Colors.grey[300]!),
                left: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
                verticalInside: BorderSide(color: Colors.grey[300]!),
                horizontalInside: BorderSide(color: Colors.grey, width: 1))
            : null,
        dividerThickness:
            1, // this one will be ignored if [border] is set above
        bottomMargin: 10,
        minWidth: 900,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        onSelectAll: (val) =>
            setState(() => _dessertsDataSource.selectAll(val)),
        columns: [
          DataColumn2(
            label: Text('Desert'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) =>
                _sort<String>((d) => d.name, columnIndex, ascending),
          ),
          DataColumn2(
            label: Text('Calories'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.calories, columnIndex, ascending),
          ),
          DataColumn2(
            label: Text('Fat (gm)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.fat, columnIndex, ascending),
          ),
          DataColumn2(
            label: Text('Carbs (gm)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.carbs, columnIndex, ascending),
          ),
          DataColumn2(
            label: Text('Protein (gm)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.protein, columnIndex, ascending),
          ),
          DataColumn2(
            label: Text('Sodium (mg)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.sodium, columnIndex, ascending),
          ),
          DataColumn2(
            label: Text('Calcium (%)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.calcium, columnIndex, ascending),
          ),
          DataColumn2(
            label: Text('Iron (%)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.iron, columnIndex, ascending),
          ),
        ],
        empty: Center(
            child: Container(
                padding: EdgeInsets.all(20),
                color: Colors.grey[200],
                child: Text('No data'))),
        rows: getCurrentRouteOption(context) == noData
            ? []
            : List<DataRow>.generate(_dessertsDataSource.rowCount,
                (index) => _dessertsDataSource.getRow(index)),
      ),
    );
  }
}
