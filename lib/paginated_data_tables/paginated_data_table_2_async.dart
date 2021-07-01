// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin, Kristián Balaj - changes and modifications to original Flutter implementation of PaginatedDataTable

import 'package:data_table_2/async_data_table_source.dart';
import 'package:data_table_2/data_state_enum.dart';
import 'package:data_table_2/paginated_data_tables/paginated_data_table_2.dart';
import 'package:data_table_2/paginated_data_tables/paginated_data_table_2_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PaginatedDataTable2Async
    extends PaginatedDataTable2Base<AsyncDataTableSource> {
  PaginatedDataTable2Async({
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
    required AsyncDataTableSource dataSource,
    double? checkboxHorizontalMargin,
    bool wrapInCard = true,
    double? minWidth,
    FlexFit fit = FlexFit.loose,
    ScrollController? scrollController,
    TableBorder? border,
    double smRatio = 0.67,
    double lmRatio = 1.2,
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

  /// Displayed in case an error occurs in the [AsyncDataTableSource].
  /// The fallback is an empty [SizedBox].
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  /// Widget that is displayed in case the data rows are being loaded.
  /// The fallback is an empty [SizedBox].
  final Widget? loadingWidget;

  @override
  PaginatedDataTable2BaseState createState() => PaginatedDataTable2State();
}

class PaginatedDataTable2AsyncState
    extends PaginatedDataTable2BaseState<PaginatedDataTable2Async> {
  @override
  bool get dataSourceIsRowCountApproximate =>
      widget.dataSource.isRowCountApproximate;

  @override
  int get dataSourceRowCount => widget.dataSource.rowCount;

  @override
  int get dataSourceSelectedRowCount => widget.dataSource.selectedRowCount;

  Future<List<DataRow>> _getRows(int firstRowIndex, int rowsPerPage) {
    final List<DataRow> result = <DataRow>[];

    if (widget.empty != null && widget.dataSource.rowCount < 1)
      return SynchronousFuture(result);

    final int nextPageFirstRowIndex = firstRowIndex + rowsPerPage;

    return widget.dataSource.getRows(firstRowIndex, nextPageFirstRowIndex - 1);
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
