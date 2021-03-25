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

class _DataTable2DemoState extends State<DataTable2Demo> with RestorationMixin {
  final RestorableDessertSelections _dessertSelections =
      RestorableDessertSelections();
  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage =
      RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableIntN _sortColumnIndex = RestorableIntN(null);
  late DessertDataSource _dessertsDataSource;
  bool initialized = false;

  @override
  String get restorationId => 'data_table2_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_dessertSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    if (!initialized) {
      _dessertsDataSource = DessertDataSource(context);
      initialized = true;
    }
    switch (_sortColumnIndex.value) {
      case 0:
        _dessertsDataSource.sort<String>((d) => d.name, _sortAscending.value);
        break;
      case 1:
        _dessertsDataSource.sort<num>((d) => d.calories, _sortAscending.value);
        break;
      case 2:
        _dessertsDataSource.sort<num>((d) => d.fat, _sortAscending.value);
        break;
      case 3:
        _dessertsDataSource.sort<num>((d) => d.carbs, _sortAscending.value);
        break;
      case 4:
        _dessertsDataSource.sort<num>((d) => d.protein, _sortAscending.value);
        break;
      case 5:
        _dessertsDataSource.sort<num>((d) => d.sodium, _sortAscending.value);
        break;
      case 6:
        _dessertsDataSource.sort<num>((d) => d.calcium, _sortAscending.value);
        break;
      case 7:
        _dessertsDataSource.sort<num>((d) => d.iron, _sortAscending.value);
        break;
    }
    _dessertsDataSource.updateSelectedDesserts(_dessertSelections);
    _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      _dessertsDataSource = DessertDataSource(context);
      initialized = true;
    }
    _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
  }

  void _updateSelectedDessertRowListener() {
    setState(() {
      _dessertSelections.setDessertSelections(_dessertsDataSource.desserts);
    });
  }

  void _sort<T>(
    Comparable<T> Function(Dessert d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dessertsDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex.value = columnIndex;
      _sortAscending.value = ascending;
    });
  }

  @override
  void dispose() {
    _rowsPerPage.dispose();
    _sortColumnIndex.dispose();
    _sortAscending.dispose();
    _dessertsDataSource.removeListener(_updateSelectedDessertRowListener);
    _dessertsDataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DataTable2(
          columnSpacing: 6,
          horizontalMargin: 6,
          sortColumnIndex: _sortColumnIndex.value,
          sortAscending: _sortAscending.value,
          onSelectAll: _dessertsDataSource.selectAll,
          columns: [
            DataColumn2(
              label: Text('Desert'),
              size: ColumnSize.L,
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
          rows: List<DataRow2>.generate(_dessertsDataSource.rowCount,
              (index) => _dessertsDataSource.getRow2(index))),
    );
  }
}
