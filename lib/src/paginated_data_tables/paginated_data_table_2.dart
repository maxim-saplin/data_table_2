// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin, Kristián Balaj - changes and modifications to original Flutter implementation of PaginatedDataTable

import 'package:data_table_2/src/data_state_enum.dart';
import 'package:data_table_2/src/paginated_data_tables/paginated_data_table_2_base.dart';
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
  /// Check out [PaginatedDataTable2Base] for the API decription.
  PaginatedDataTable2({
    Key? key,

    /// {@macro dataTable2.paginatedDataTable2Base.header}
    Widget? header,

    /// {@macro dataTable2.paginatedDataTable2Base.actions}
    List<Widget>? actions,

    /// {@macro dataTable2.paginatedDataTable2Base.columns}
    required List<DataColumn> columns,

    /// {@macro dataTable2.paginatedDataTable2Base.sortColumnIndex}
    int? sortColumnIndex,

    /// {@macro dataTable2.paginatedDataTable2Base.sortAscending}
    bool sortAscending = true,

    /// {@macro dataTable2.paginatedDataTable2Base.onSelectAll}
    ValueSetter<bool?>? onSelectAll,

    /// {@macro dataTable2.paginatedDataTable2Base.dataRowHeight}
    double dataRowHeight = kMinInteractiveDimension,

    /// {@macro dataTable2.paginatedDataTable2Base.headingRowHeight}
    double headingRowHeight = 56.0,

    /// {@macro dataTable2.paginatedDataTable2Base.horizontalMargin}
    double horizontalMargin = 24.0,

    /// {@macro dataTable2.paginatedDataTable2Base.columnSpacing}
    double columnSpacing = 56.0,

    /// {@macro dataTable2.paginatedDataTable2Base.showCheckboxColumn}
    bool showCheckboxColumn = true,

    /// {@macro dataTable2.paginatedDataTable2Base.showFirstLastButtons}
    bool showFirstLastButtons = false,

    /// {@macro dataTable2.paginatedDataTable2Base.initialFirstRowIndex}
    int? initialFirstRowIndex = 0,

    /// {@macro dataTable2.paginatedDataTable2Base.onPageChanged}
    ValueChanged<int>? onPageChanged,
    int rowsPerPage = PaginatedDataTable2Base.defaultRowsPerPage,

    /// {@macro dataTable2.paginatedDataTable2Base.availableRowsPerPage}
    List<int> availableRowsPerPage = const <int>[
      PaginatedDataTable2Base.defaultRowsPerPage,
      PaginatedDataTable2Base.defaultRowsPerPage * 2,
      PaginatedDataTable2Base.defaultRowsPerPage * 5,
      PaginatedDataTable2Base.defaultRowsPerPage * 10
    ],

    /// {@macro dataTable2.paginatedDataTable2Base.onRowsPerPageChanged}
    ValueChanged<int?>? onRowsPerPageChanged,

    /// {@macro dataTable2.paginatedDataTable2Base.dragStartBehavior}
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,

    /// {@macro dataTable2.paginatedDataTable2Base.dataSource}
    required DataTableSource source,

    /// {@macro dataTable2.paginatedDataTable2Base.checkboxHorizontalMargin}
    double? checkboxHorizontalMargin,
    bool wrapInCard = true,

    /// {@macro dataTable2.paginatedDataTable2Base.minWidth}
    double? minWidth,

    /// {@macro dataTable2.paginatedDataTable2Base.fit}
    FlexFit fit = FlexFit.loose,

    /// {@macro dataTable2.paginatedDataTable2Base.scrollController}
    ScrollController? scrollController,

    /// {@macro dataTable2.paginatedDataTable2Base.border}
    TableBorder? border,

    /// {@macro dataTable2.paginatedDataTable2Base.smRatio}
    double smRatio = 0.67,

    /// {@macro dataTable2.paginatedDataTable2Base.lmRatio}
    double lmRatio = 1.2,

    /// {@macro dataTable2.paginatedDataTable2Base.empty}
    Widget? empty,
  }) : super(
          key: key,
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
          source: source,
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
      widget.source.isRowCountApproximate;

  @override
  int get dataSourceRowCount => widget.source.rowCount;

  @override
  int get dataSourceSelectedRowCount => widget.source.selectedRowCount;

  DataRow _getProgressIndicatorRowFor(int index) {
    bool haveProgressIndicator = false;
    final List<DataCell> cells =
        widget.columns.map<DataCell>((DataColumn column) {
      if (!column.numeric) {
        haveProgressIndicator = true;
        return const DataCell(CircularProgressIndicator());
      }
      return DataCell.empty;
    }).toList();
    if (!haveProgressIndicator) {
      haveProgressIndicator = true;
      cells[0] = const DataCell(CircularProgressIndicator());
    }
    return DataRow.byIndex(
      index: index,
      cells: cells,
    );
  }

  DataRow _getBlankRowFor(int index) {
    return DataRow.byIndex(
      index: index,
      cells: widget.columns
          .map<DataCell>((DataColumn column) => DataCell.empty)
          .toList(),
    );
  }

  List<DataRow> _getRows(int firstRowIndex, int rowsPerPage) {
    final List<DataRow> result = <DataRow>[];

    if (widget.empty != null && widget.source.rowCount < 1)
      return result; // If empty placeholder is provided - don't create blank rows

    final int nextPageFirstRowIndex = firstRowIndex + rowsPerPage;
    bool haveProgressIndicator = false;

    for (int index = firstRowIndex; index < nextPageFirstRowIndex; index += 1) {
      DataRow? row;
      if (index < rowCount || rowCountApproximate) {
        row = rows.putIfAbsent(index, () => widget.source.getRow(index));
        if (row == null && !haveProgressIndicator) {
          row ??= _getProgressIndicatorRowFor(index);
          haveProgressIndicator = true;
        }
      }
      row ??= _getBlankRowFor(index);
      result.add(row);
    }
    return result;
  }

  @override
  Widget createDataTableContextWidget() {
    return createDataTableWidget(
      rows: _getRows(firstRowIndex, widget.rowsPerPage),
      errorBuilder: null,
      state: DataState.done,
      loadingWidget: null,
    );
  }
}
