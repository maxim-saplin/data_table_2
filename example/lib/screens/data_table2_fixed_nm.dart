import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../data_sources.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class DataTable2FixedNMDemo extends StatefulWidget {
  const DataTable2FixedNMDemo({super.key});

  @override
  DataTable2FixedNMDemoState createState() => DataTable2FixedNMDemoState();
}

class DataTable2FixedNMDemoState extends State<DataTable2FixedNMDemo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;
  final ScrollController _controller = ScrollController();

  int _fixedRows = 0;
  int _fixedCols = 0;
  int _dataItems = 30;

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
        child: Column(children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  height: 36,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                          width: 130, child: Text('Fixed rows ($_fixedRows)')),
                      SizedBox(
                          width: 240,
                          child: Slider(
                              value: _fixedRows.toDouble(),
                              min: 0,
                              max: 10,
                              divisions: 10,
                              onChanged: (val) {
                                setState(() {
                                  _fixedRows = val.toInt();
                                });
                              }))
                    ],
                  )),
              SizedBox(
                  height: 36,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                          width: 130,
                          child: Text('Fixed columns ($_fixedCols)')),
                      SizedBox(
                          width: 240,
                          child: Slider(
                              value: _fixedCols.toDouble(),
                              min: 0,
                              max: 10,
                              divisions: 10,
                              onChanged: (val) {
                                setState(() {
                                  _fixedCols = val.toInt();
                                });
                              }))
                    ],
                  )),
              SizedBox(
                  height: 36,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                          width: 130, child: Text('Data items ($_dataItems)')),
                      SizedBox(
                          width: 240,
                          child: Slider(
                              value: _dataItems.toDouble(),
                              min: 0,
                              max: 30,
                              divisions: 10,
                              onChanged: (val) {
                                setState(() {
                                  _dataItems = val.toInt();
                                });
                              }))
                    ],
                  ))
            ],
          ),
          Flexible(
              fit: FlexFit.tight,
              child: Theme(
                  data: ThemeData(
                      scrollbarTheme: ScrollbarThemeData(
                          thumbVisibility: MaterialStateProperty.all(true),
                          thumbColor:
                              MaterialStateProperty.all<Color>(Colors.black))),
                  child: DataTable2(
                      scrollController: _controller,
                      columnSpacing: 0,
                      horizontalMargin: 12,
                      bottomMargin: 10,
                      minWidth: 600,
                      fixedTopRows: _fixedRows,
                      fixedLeftColumns: _fixedCols,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      onSelectAll: (val) =>
                          setState(() => _dessertsDataSource.selectAll(val)),
                      columns: [
                        DataColumn2(
                          label: const Text('Desert'),
                          size: ColumnSize.S,
                          onSort: (columnIndex, ascending) => _sort<String>(
                              (d) => d.name, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Calories'),
                          size: ColumnSize.S,
                          numeric: true,
                          onSort: (columnIndex, ascending) => _sort<num>(
                              (d) => d.calories, columnIndex, ascending),
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
                          onSort: (columnIndex, ascending) => _sort<num>(
                              (d) => d.carbs, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Protein (gm)'),
                          size: ColumnSize.S,
                          numeric: true,
                          onSort: (columnIndex, ascending) => _sort<num>(
                              (d) => d.protein, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Sodium (mg)'),
                          size: ColumnSize.S,
                          numeric: true,
                          onSort: (columnIndex, ascending) => _sort<num>(
                              (d) => d.sodium, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Calcium (%)'),
                          size: ColumnSize.S,
                          numeric: true,
                          onSort: (columnIndex, ascending) => _sort<num>(
                              (d) => d.calcium, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Iron (%)'),
                          size: ColumnSize.S,
                          numeric: true,
                          onSort: (columnIndex, ascending) =>
                              _sort<num>((d) => d.iron, columnIndex, ascending),
                        ),
                      ],
                      rows: List<DataRow>.generate(_dessertsDataSource.rowCount,
                          (index) => _dessertsDataSource.getRow(index)))))
        ]));
  }
}
