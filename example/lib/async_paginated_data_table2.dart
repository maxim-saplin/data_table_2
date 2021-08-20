import 'package:example/custom_pager.dart';
import 'package:example/data_sources.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import 'nav_helper.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class AsyncPaginatedDataTable2Demo extends StatefulWidget {
  const AsyncPaginatedDataTable2Demo();

  @override
  _AsyncPaginatedDataTable2DemoState createState() =>
      _AsyncPaginatedDataTable2DemoState();
}

class _AsyncPaginatedDataTable2DemoState
    extends State<AsyncPaginatedDataTable2Demo> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  DessertDataSourceAsync? _dessertsDataSource;
  PaginatorController _controller = PaginatorController();

  bool _dataSourceLoading = false;
  int _initialRow = 0;

  @override
  void didChangeDependencies() {
    // initState is to early to access route options, context is invalid at that stage
    if (_dessertsDataSource == null) {
      _dessertsDataSource = getCurrentRouteOption(context) == noData
          ? DessertDataSourceAsync.empty()
          : getCurrentRouteOption(context) == asyncErrors
              ? DessertDataSourceAsync.error()
              : DessertDataSourceAsync();
    }

    if (getCurrentRouteOption(context) == goToLast) {
      _dataSourceLoading = true;
      _dessertsDataSource!.getTotalRecors().then((count) => setState(() {
            _initialRow = count - _rowsPerPage;
            _dataSourceLoading = false;
          }));
    }
    super.didChangeDependencies();
  }

  void sort(
    int columnIndex,
    bool ascending,
  ) {
    var columnName = "name";
    switch (columnIndex) {
      case 1:
        columnName = "calories";
        break;
      case 2:
        columnName = "fat";
        break;
      case 3:
        columnName = "carbs";
        break;
      case 4:
        columnName = "protein";
        break;
      case 5:
        columnName = "sodium";
        break;
      case 6:
        columnName = "calcium";
        break;
      case 7:
        columnName = "iron";
        break;
    }
    _dessertsDataSource!.sort(columnName, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void dispose() {
    _dessertsDataSource!.dispose();
    super.dispose();
  }

  List<DataColumn> get _columns {
    return [
      DataColumn(
        label: Text('Desert'),
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Calories'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Fat (gm)'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Carbs (gm)'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Protein (gm)'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Sodium (mg)'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Calcium (%)'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Iron (%)'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Last ppage example uses extra API call to get the number of items in datasource
    if (_dataSourceLoading) return SizedBox();

    return Stack(alignment: Alignment.bottomCenter, children: [
      AsyncPaginatedDataTable2(
          horizontalMargin: 20,
          checkboxHorizontalMargin: 12,
          columnSpacing: 0,
          wrapInCard: false,
          header:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('AsyncPaginatedDataTable2'),
            if (kDebugMode && getCurrentRouteOption(context) == custPager)
              Row(children: [
                OutlinedButton(
                    onPressed: () => _controller.goToPageWithRow(25),
                    child: Text('Go to row 25')),
                OutlinedButton(
                    onPressed: () => _controller.goToRow(5),
                    child: Text('Go to row 5'))
              ]),
            if (getCurrentRouteOption(context) == custPager)
              PageNumber(controller: _controller)
          ]),
          rowsPerPage: _rowsPerPage,
          autoRowsToHeight: getCurrentRouteOption(context) == autoRows,
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
            // No need to wrap into setState, it will be called inside the widget
            // and trigger rebuild
            //setState(() {
            _rowsPerPage = value!;
            //});
          },
          initialFirstRowIndex: _initialRow,
          onPageChanged: (rowIndex) {
            //print(rowIndex / _rowsPerPage);
          },
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          onSelectAll: (select) => select != null && select
              ? (getCurrentRouteOption(context) != selectAllPage
                  ? _dessertsDataSource!.selectAll()
                  : _dessertsDataSource!.selectAllOnThePage())
              : (getCurrentRouteOption(context) != selectAllPage
                  ? _dessertsDataSource!.deselectAll()
                  : _dessertsDataSource!.deselectAllOnThePage()),
          controller:
              getCurrentRouteOption(context) == custPager ? _controller : null,
          hidePaginator: getCurrentRouteOption(context) == custPager,
          columns: _columns,
          empty: Center(
              child: Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.grey[200],
                  child: Text('No data'))),
          loading: _Loading(),
          errorBuilder: (e) => Center(
                child: Container(
                    padding: EdgeInsets.all(10),
                    height: 70,
                    color: Colors.red,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Oops! ${e != null ? e.toString() : ""}',
                              style: TextStyle(color: Colors.white)),
                          TextButton(
                              onPressed: () =>
                                  _dessertsDataSource!.refreshDatasource(),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    Text('Retry',
                                        style: TextStyle(color: Colors.white))
                                  ]))
                        ])),
              ),
          source: _dessertsDataSource!),
      if (getCurrentRouteOption(context) == custPager)
        Positioned(bottom: 16, child: CustomPager(_controller))
    ]);
  }
}

class _Loading extends StatefulWidget {
  @override
  __LoadingState createState() => __LoadingState();
}

class __LoadingState extends State<_Loading> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: Colors.white.withAlpha(128),
        // at first show shade, if loading takes longer than 0,5s show spinner
        child: FutureBuilder(
            future: Future.delayed(Duration(milliseconds: 500), () => true),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SizedBox()
                  : Center(
                      child: Container(
                      color: Colors.yellow,
                      padding: EdgeInsets.all(7),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                            Text('Loading..')
                          ]),
                      width: 150,
                      height: 50,
                    ));
            }));
  }
}