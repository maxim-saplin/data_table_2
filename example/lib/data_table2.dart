import 'package:data_table_plus/data_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'data_source.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class DataTablePlusDemo extends StatefulWidget {
  const DataTablePlusDemo();

  @override
  _DataTablePlusDemoState createState() => _DataTablePlusDemoState();
}

class _DataTablePlusDemoState extends State<DataTablePlusDemo> {
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
      child: DataTablePlus(
          columnSpacing: 0,
          horizontalMargin: 12,
          bottomMargin: 10,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          onSelectAll: (val) =>
              setState(() => _dessertsDataSource.selectAll(val)),
          columns: [
            DataColumnPlus(
              label: Text('Desert'),
              onSort: (columnIndex, ascending) =>
                  _sort<String>((d) => d.name, columnIndex, ascending),
            ),
            DataColumnPlus(
              label: Text('Calories'),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((d) => d.calories, columnIndex, ascending),
            ),
            DataColumnPlus(
              label: Text('Fat (gm)'),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((d) => d.fat, columnIndex, ascending),
            ),
            DataColumnPlus(
              label: Text('Carbs (gm)'),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((d) => d.carbs, columnIndex, ascending),
            ),
            DataColumnPlus(
              label: Text('Protein (gm)'),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((d) => d.protein, columnIndex, ascending),
            ),
            DataColumnPlus(
              label: Text('Sodium (mg)'),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((d) => d.sodium, columnIndex, ascending),
            ),
            DataColumnPlus(
              label: Text('Calcium (%)'),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((d) => d.calcium, columnIndex, ascending),
            ),
            DataColumnPlus(
              label: Text('Iron (%)'),
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
