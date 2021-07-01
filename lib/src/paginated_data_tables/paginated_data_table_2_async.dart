// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin, Kristián Balaj - changes and modifications to original Flutter implementation of PaginatedDataTable

import 'package:data_table_2/src/async_data_table_source.dart';
import 'package:data_table_2/src/data_state_enum.dart';
import 'package:data_table_2/src/paginated_data_tables/paginated_data_table_2_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PaginatedDataTable2Async
    extends PaginatedDataTable2Base<AsyncDataTableSource> {
  /// Check out [PaginatedDataTable2Base] for the API decription.
  PaginatedDataTable2Async({
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
    required AsyncDataTableSource source,

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
    this.loadingWidget,
    this.errorBuilder,
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

  /// Displayed in case an error occurs in the [AsyncDataTableSource].
  /// The fallback is an empty [SizedBox].
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  /// Widget that is displayed in case the data rows are being loaded.
  /// The fallback is an empty [SizedBox].
  final Widget? loadingWidget;

  @override
  PaginatedDataTable2BaseState createState() => PaginatedDataTable2AsyncState();
}

class PaginatedDataTable2AsyncState
    extends PaginatedDataTable2BaseState<PaginatedDataTable2Async> {
  @override
  bool get dataSourceIsRowCountApproximate =>
      widget.source.isRowCountApproximate;

  @override
  int get dataSourceRowCount => widget.source.rowCount;

  @override
  int get dataSourceSelectedRowCount => widget.source.selectedRowCount;

  Future<List<DataRow>> _getRows(int firstRowIndex, int rowsPerPage) {
    final List<DataRow> result = <DataRow>[];

    if (widget.empty != null && widget.source.rowCount < 1)
      return SynchronousFuture(result);

    final int nextPageFirstRowIndex = firstRowIndex + rowsPerPage;

    return widget.source.getRows(firstRowIndex, nextPageFirstRowIndex - 1);
  }

  @override
  Widget createDataTableContextWidget() {
    return FutureBuilder<List<DataRow>>(
      future: _getRows(firstRowIndex, widget.rowsPerPage),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<DataRow>> snapshot,
      ) {
        DataState state = () {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return DataState.loading;
            default:
              if (snapshot.hasError)
                return DataState.error;
              else
                return DataState.done;
          }
        }();

        return createDataTableWidget(
          rows: snapshot.data ?? [],
          errorBuilder: (context) =>
              widget.errorBuilder?.call(context, snapshot.error) ??
              const SizedBox(),
          state: state,
          loadingWidget: widget.loadingWidget ?? const SizedBox(),
        );
      },
    );
  }
}
