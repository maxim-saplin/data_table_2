import 'package:data_table_plus/data_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'data_source.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class DataTablePlusScrollupDemo extends StatefulWidget {
  const DataTablePlusScrollupDemo();

  @override
  _DataTablePlusScrollupDemoState createState() =>
      _DataTablePlusScrollupDemoState();
}

class _DataTablePlusScrollupDemoState extends State<DataTablePlusScrollupDemo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;
  ScrollController _controller = ScrollController();

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
        child: Stack(children: [
          DataTablePlus(
              scrollController: _controller,
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
          _ScrollUpButton(_controller)
        ]));
  }
}

class _ScrollUpButton extends StatefulWidget {
  _ScrollUpButton(this.controller);

  final ScrollController controller;

  @override
  _ScrollUpButtonState createState() => _ScrollUpButtonState();
}

class _ScrollUpButtonState extends State<_ScrollUpButton> {
  bool _showScrollUp = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.position.pixels > 20 && !_showScrollUp) {
        setState(() {
          _showScrollUp = true;
        });
      } else if (widget.controller.position.pixels < 20 && _showScrollUp) {
        setState(() {
          _showScrollUp = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showScrollUp
        ? Positioned(
            right: 10,
            bottom: 10,
            child: OutlinedButton(
              child: Text('↑↑ go up ↑↑'),
              onPressed: () => widget.controller.animateTo(0,
                  duration: Duration(milliseconds: 300), curve: Curves.easeIn),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey[800]),
                  foregroundColor: MaterialStateProperty.all(Colors.white)),
            ))
        : SizedBox();
  }
}
