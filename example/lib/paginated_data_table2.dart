import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';

import 'data_source.dart';
import 'isEmptyArg.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class PaginatedDataTable2Demo extends StatefulWidget {
  const PaginatedDataTable2Demo();

  @override
  _PaginatedDataTable2DemoState createState() =>
      _PaginatedDataTable2DemoState();
}

class _PaginatedDataTable2DemoState extends State<PaginatedDataTable2Demo> {
  int _rowIndex = 0;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late AsyncDessertDataSource _dessertsDataSource;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dessertsDataSource = AsyncDessertDataSource(context);
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

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      horizontalMargin: 20,
      checkboxHorizontalMargin: 12,
      columnSpacing: 0,
      wrapInCard: false,
      header: Text('PaginatedDataTable2'),
      rowsPerPage: _rowsPerPage,
      minWidth: 800,
      fit: FlexFit.tight,
      border: TableBorder(
          top: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
          right: BorderSide(color: Colors.grey[300]!),
          verticalInside: BorderSide(color: Colors.grey[300]!),
          horizontalInside: BorderSide(color: Colors.grey, width: 1)),
      onRowsPerPageChanged: (value) {
        setState(() {
          _rowsPerPage = value!;
        });
      },
      initialFirstRowIndex: _rowIndex,
      onPageChanged: (rowIndex) {
        setState(() {
          _rowIndex = rowIndex;
        });
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      onSelectAll: _dessertsDataSource.selectAll,
      columns: [
        DataColumn(
          label: Text('Desert'),
          onSort: (columnIndex, ascending) =>
              sort<String>((d) => d.name, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Calories'),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              sort<num>((d) => d.calories, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Fat (gm)'),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              sort<num>((d) => d.fat, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Carbs (gm)'),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              sort<num>((d) => d.carbs, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Protein (gm)'),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              sort<num>((d) => d.protein, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Sodium (mg)'),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              sort<num>((d) => d.sodium, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Calcium (%)'),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              sort<num>((d) => d.calcium, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Iron (%)'),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              sort<num>((d) => d.iron, columnIndex, ascending),
        ),
      ],
      empty: Center(
          child: Container(
              padding: EdgeInsets.all(20),
              color: Colors.grey[200],
              child: Text('No data'))),
      source: getIsEmpty(context)
          ? AsyncDessertDataSource.empty(context)
          : _dessertsDataSource,
      errorBuilder: (context, error) => Center(
        child: Text(error.toString()),
      ),
      loadingBuilder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
