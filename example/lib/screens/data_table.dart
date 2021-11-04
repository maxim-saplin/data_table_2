import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../data_sources.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class DataTableDemo extends StatefulWidget {
  const DataTableDemo();

  @override
  _DataTableDemoState createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<DataTableDemo> with RestorationMixin {
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
  String get restorationId => 'data_table_demo';

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
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                  sortColumnIndex: _sortColumnIndex.value,
                  sortAscending: _sortAscending.value,
                  onSelectAll: _dessertsDataSource.selectAll,
                  columns: [
                    DataColumn(
                      label: Text('Desert'),
                      onSort: (columnIndex, ascending) =>
                          _sort<String>((d) => d.name, columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text('Calories'),
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.calories, columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text('Fat (gm)'),
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.fat, columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text('Carbs (gm)'),
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.carbs, columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text('Protein (gm)'),
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.protein, columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text('Sodium (mg)'),
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.sodium, columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text('Calcium (%)'),
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.calcium, columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text('Iron (%)'),
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.iron, columnIndex, ascending),
                    ),
                  ],
                  rows: List<DataRow>.generate(_dessertsDataSource.rowCount,
                      (index) => _dessertsDataSource.getRow(index))),
            )));
  }
}
