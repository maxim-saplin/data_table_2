import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'data_source.dart';

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
          columnSpacing: 0,
          horizontalMargin: 12,
          minWidth: 600,
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
          rows: List<DataRow>.generate(_dessertsDataSource.rowCount,
              (index) => _dessertsDataSource.getRow(index))),
    );
  }
}
