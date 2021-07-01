// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin, Kristián Balaj - changes and modifications to original Flutter implementation of PaginatedDataTable

import 'package:data_table_2/paged_data_table_2_base.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PagedDataTable2 extends PagedDataTable2Base<DataTableSource> {
  PagedDataTable2({
    Key? key,
    Widget? header,
    List<Widget>? actions,
    required List<DataColumn> columns,
    int? sortColumnIndex,
    bool sortAscending = true,
    ValueSetter<bool?>? onSelectAll,
    double dataRowHeight = kMinInteractiveDimension,
    double headingRowHeight = 56.0,
    double horizontalMargin = 24.0,
    double columnSpacing = 56.0,
    bool showCheckboxColumn = true,
    bool showFirstLastButtons = false,
    int? initialFirstRowIndex = 0,
    ValueChanged<int>? onPageChanged,
    int rowsPerPage = PagedDataTable2Base.defaultRowsPerPage,
    List<int> availableRowsPerPage = const <int>[
      PagedDataTable2Base.defaultRowsPerPage,
      PagedDataTable2Base.defaultRowsPerPage * 2,
      PagedDataTable2Base.defaultRowsPerPage * 5,
      PagedDataTable2Base.defaultRowsPerPage * 10
    ],
    ValueChanged<int?>? onRowsPerPageChanged,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    required DataTableSource dataSource,
    double? checkboxHorizontalMargin,
    bool wrapInCard = true,
    double? minWidth,
    FlexFit fit = FlexFit.loose,
    ScrollController? scrollController,
    TableBorder? border,
    double smRatio = 0.67,
    double lmRatio = 1.2,
    Widget? empty,
  }) : super(
          header: header,
          actions: actions,
          columns: columns,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          onSelectAll: onSelectAll,
          dataRowHeight: dataRowHeight,
          horizontalMargin: horizontalMargin,
          columnSpacing: columnSpacing,
          showCheckboxColumn: showCheckboxColumn,
          showFirstLastButtons: showFirstLastButtons,
          initialFirstRowIndex: initialFirstRowIndex,
          onPageChanged: onPageChanged,
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: availableRowsPerPage,
          onRowsPerPageChanged: onRowsPerPageChanged,
          dragStartBehavior: dragStartBehavior,
          dataSource: dataSource,
          checkboxHorizontalMargin: checkboxHorizontalMargin,
          wrapInCard: wrapInCard,
          minWidth: minWidth,
          fit: fit,
          scrollController: scrollController,
          border: border,
          smRatio: smRatio,
          lmRatio: lmRatio,
          empty: empty,
        );

  @override
  PagedDataTable2BaseState createState() => PagedDataTable2State();
}

class PagedDataTable2State extends PagedDataTable2BaseState<PagedDataTable2> {
  @override
  bool get dataSourceIsRowCountApproximate =>
      widget.dataSource.isRowCountApproximate;

  @override
  int get dataSourceRowCount => widget.dataSource.rowCount;

  @override
  int get dataSourceSelectedRowCount => widget.dataSource.selectedRowCount;

  @override
  Widget createDataTableContextWidget() {
    return Container();
  }
}
