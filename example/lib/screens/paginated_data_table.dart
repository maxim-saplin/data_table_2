import 'package:flutter/material.dart';

import '../data_sources.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class PaginatedDataTableDemo extends StatefulWidget {
  const PaginatedDataTableDemo({Key? key}) : super(key: key);

  @override
  _PaginatedDataTableDemoState createState() => _PaginatedDataTableDemoState();
}

class _PaginatedDataTableDemoState extends State<PaginatedDataTableDemo>
    with RestorationMixin {
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
  String get restorationId => 'paginated_data_table_demo';

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
    _dessertSelections.setDessertSelections(_dessertsDataSource.desserts);
  }

  void sort<T>(
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
    return ListView(
      restorationId: 'paginated_data_table_list_view',
      padding: const EdgeInsets.all(16),
      children: [
        PaginatedDataTable(
          header: const Text('PaginatedDataTable'),
          rowsPerPage: _rowsPerPage.value,
          onRowsPerPageChanged: (value) {
            setState(() {
              _rowsPerPage.value = value!;
            });
          },
          initialFirstRowIndex: _rowIndex.value,
          onPageChanged: (rowIndex) {
            setState(() {
              _rowIndex.value = rowIndex;
            });
          },
          sortColumnIndex: _sortColumnIndex.value,
          sortAscending: _sortAscending.value,
          onSelectAll: _dessertsDataSource.selectAll,
          columns: [
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
          ],
          source: _dessertsDataSource,
        ),
      ],
    );
  }
}
