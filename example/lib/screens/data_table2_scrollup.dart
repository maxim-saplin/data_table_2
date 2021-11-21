import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../data_sources.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class DataTable2ScrollupDemo extends StatefulWidget {
  const DataTable2ScrollupDemo();

  @override
  _DataTable2ScrollupDemoState createState() => _DataTable2ScrollupDemoState();
}

class _DataTable2ScrollupDemoState extends State<DataTable2ScrollupDemo> {
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
          Theme(
              // These makes scroll bars almost always visible. If horizontal scroll bar
              // is displayed then vertical migh be hidden as it will go out of viewport
              data: ThemeData(
                  scrollbarTheme: ScrollbarThemeData(
                      isAlwaysShown: true,
                      thumbColor:
                          MaterialStateProperty.all<Color>(Colors.black))),
              child: DataTable2(
                  scrollController: _controller,
                  columnSpacing: 0,
                  horizontalMargin: 12,
                  bottomMargin: 10,
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
                      (index) => _dessertsDataSource.getRow(index)))),
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
      // On GitHub there was a question on how to determine the event
      // of widget being scrolled to the bottom. Here's the sample
      // if (widget.controller.position.hasViewportDimension &&
      //     widget.controller.position.pixels >=
      //         widget.controller.position.maxScrollExtent - 0.01) {
      //   print('Scrolled to bottom');
      //}
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
