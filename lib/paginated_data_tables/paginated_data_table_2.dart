// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin, Kristián Balaj - changes and modifications to original Flutter implementation of PaginatedDataTable

import 'package:data_table_2/paginated_data_tables/paginated_data_table_2_base.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// In-place replacement of standard [PaginatedDataTable] widget, mimics it API.
/// Has the header row and paginatior always fixed to top and bottom (correspondingly).
/// Core of the table (with data rows) is scrollable and stretching to max width/height of it's container.
/// You can set minimal width of the table via [minWidth] property and Flex behavior of
/// table core via [fit] property.
/// By using [DataColumn2] instead of [DataColumn] it is possible to control
/// relative column sizes (setting them to S, M and L). [DataRow2] provides
/// row-level tap event handlers.
/// See also:
///
///  * [DataTable2], which is not paginated.
class PaginatedDataTable2 extends PaginatedDataTable2Base<DataTableSource> {
  /// Check out [PaginatedDataTable] for the API decription.
  /// Key differences are [minWidth] and [fit] properties.
  PaginatedDataTable2({
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
    int rowsPerPage = PaginatedDataTable2Base.defaultRowsPerPage,
    List<int> availableRowsPerPage = const <int>[
      PaginatedDataTable2Base.defaultRowsPerPage,
      PaginatedDataTable2Base.defaultRowsPerPage * 2,
      PaginatedDataTable2Base.defaultRowsPerPage * 5,
      PaginatedDataTable2Base.defaultRowsPerPage * 10
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
  PaginatedDataTable2BaseState createState() => PaginatedDataTable2State();
}

class PaginatedDataTable2State
    extends PaginatedDataTable2BaseState<PaginatedDataTable2> {
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
