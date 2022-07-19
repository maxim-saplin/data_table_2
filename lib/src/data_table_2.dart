// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin - changes and modifications to original Flutter implementation of DataTable

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'data_table_2_resizable.dart';

/// Relative size of a column determines the share of total table width allocated
/// to each individual column. When determining column widths ratios between S, M and L
/// columns are kept (i.e. Large columns are set to 1.2x width of Medium ones)
/// - see [DataTable2.smRatio], [DataTable2.lmRatio] and same properties on [PaginatedDataTable2].
/// Default S/M ratio is 0.67,L/M ratio is 1.2
enum ColumnSize { S, M, L }

/// Extension of stock [DataColumn], adds the capability to set relative column
/// size via [size] property
@immutable
class DataColumn2 extends DataColumn {
  /// Creates the configuration for a column of a [DataTable2].
  ///
  /// The [label] argument must not be null.
  const DataColumn2(
      {required super.label,
      super.tooltip,
      super.numeric = false,
      super.onSort,
      this.size = ColumnSize.M,
      this.fixedWidth,
      this.isResizable = false});

  /// Column sizes are determined based on available width by distributing it
  /// to individual columns accounting for their relative sizes (see [ColumnSize])
  final ColumnSize size;

  /// Defines absolute width of the column in pixel (as opposed to relative size used by default).
  /// Warning, if the width happens to be larger than available total width other
  /// columns can be clipped
  final double? fixedWidth;

  /// If you want enable resizing for a given column, set this field to true
  final bool isResizable;
}

/// Extension of standard [DataRow], adds row level tap events. Also there're
/// onSecondaryTap and onSecondaryTapDown which are not available in DataCells and
/// which can be useful in Desktop settings when a reaction to the right click is required.
@immutable
class DataRow2 extends DataRow {
  //DataRow2.fromDataRow(DataRow row) : this.cells = row.cells;

  /// Creates the configuration for a row of a [DataTable2].
  ///
  /// The [cells] argument must not be null.
  const DataRow2(
      {super.key,
      super.selected = false,
      super.onSelectChanged,
      super.color,
      required super.cells,
      this.specificRowHeight,
      this.onTap,
      this.onDoubleTap,
      super.onLongPress,
      this.onSecondaryTap,
      this.onSecondaryTapDown});

  DataRow2.byIndex(
      {int? index,
      super.selected = false,
      super.onSelectChanged,
      super.color,
      required super.cells,
      this.specificRowHeight,
      this.onTap,
      this.onDoubleTap,
      super.onLongPress,
      this.onSecondaryTap,
      this.onSecondaryTapDown})
      : super.byIndex(index: index);

  /// Specific row height, which will be used only if provided.
  /// If not provided, dataRowHeight will be applied.
  final double? specificRowHeight;

  /// Row tap handler, won't be called if tapped cell has any tap event handlers
  final GestureTapCallback? onTap;

  /// Row right click handler, won't be called if tapped cell has any tap event handlers
  final GestureTapCallback? onSecondaryTap;

  /// Row right mouse down handler, won't be called if tapped cell has any tap event handlers
  final GestureTapDownCallback? onSecondaryTapDown;

  /// Row double tap handler, won't be called if tapped cell has any tap event handlers
  final GestureTapCallback? onDoubleTap;

  // /// Row long press handler, won't be called if tapped cell has any tap event handlers
  // final GestureLongPressCallback? onLongPress;
}

/// In-place replacement of standard [DataTable] widget, mimics it API.
/// Has the header row always fixed and core of the table (with data rows)
/// scrollable and stretching to max width/height of it's container.
/// By using [DataColumn2] instead of [DataColumn] it is possible to control
/// relative column sizes (setting them to S, M and L). [DataRow2] provides
/// row-level tap event handlers.
class DataTable2 extends DataTable {
  DataTable2({
    super.key,
    required super.columns,
    super.sortColumnIndex,
    super.sortAscending = true,
    super.onSelectAll,
    super.decoration,
    super.dataRowColor,
    super.dataRowHeight,
    super.dataTextStyle,
    super.headingRowColor,
    this.fixedColumnsColor,
    this.fixedCornerColor,
    super.headingRowHeight,
    super.headingTextStyle,
    super.horizontalMargin,
    super.checkboxHorizontalMargin,
    this.bottomMargin,
    super.columnSpacing,
    super.showCheckboxColumn = true,
    super.showBottomBorder = false,
    super.dividerThickness,
    this.minWidth,
    this.scrollController,
    this.empty,
    this.border,
    this.smRatio = 0.67,
    this.fixedTopRows = 1,
    this.fixedLeftColumns = 0,
    this.lmRatio = 1.2,
    this.columnResizingParameters,
    required super.rows,
  })  : assert(fixedLeftColumns >= 0),
        assert(fixedTopRows >= 0) {
    // // Fix for #111, syncrhonize scroll position for left fixed column with core
    // // Works fine if there's scrollCongtroller provided externally, allows to avoid jumping
    // _leftColumnVerticalContoller = ScrollController(
    //     initialScrollOffset: _coreVerticalController.positions.isNotEmpty
    //         ? _coreVerticalController.offset
    //         : 0.0);
  }

  static final LocalKey _headingRowKey = UniqueKey();

  void _handleSelectAll(bool? checked, bool someChecked) {
    // If some checkboxes are checked, all checkboxes are selected. Otherwise,
    // use the new checked value but default to false if it's null.
    final bool effectiveChecked = someChecked || (checked ?? false);
    if (onSelectAll != null) {
      onSelectAll!(effectiveChecked);
    } else {
      for (final DataRow row in rows) {
        if (row.onSelectChanged != null && row.selected != effectiveChecked) {
          row.onSelectChanged!(effectiveChecked);
        }
      }
    }
  }

  /// The default height of the heading row.
  static const double _headingRowHeight = 56.0;

  /// The default horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  static const double _horizontalMargin = 24.0;

  /// The default horizontal margin between the contents of each data column.
  static const double _columnSpacing = 56.0;

  /// The default padding between the heading content and sort arrow.
  static const double _sortArrowPadding = 2.0;

  /// The default divider thickness.
  static const double _dividerThickness = 1.0;

  static const Duration _sortArrowAnimationDuration =
      Duration(milliseconds: 150);

  /// If set, the table will stop shrinking below the threshold and provide
  /// horizontal scrolling. Useful for the cases with narrow screens (e.g. portrait phone orientation)
  /// and lots of columns (that get messed with little space)
  final double? minWidth;

  /// If set the table will have empty space added after the the last row and allow scroll the
  /// core of the table higher (e.g. if you would like to have iOS navigation UI at the bottom overlapping the table and
  /// have the ability to slightly scroll up the bototm row to avoid the obstruction)
  final double? bottomMargin;

  /// Exposes scroll controller of the SingleChildScrollView that makes data rows horizontally scrollable
  final ScrollController? scrollController;

  /// Placeholder widget which is displayed whenever the data rows are empty.
  /// The widget will be displayed below column
  final Widget? empty;

  /// Set vertical and horizontal borders between cells, as well as outside borders around table.
  /// NOTE: setting this field will disable standard horizontal dividers which are controlled by
  /// themes and [dividerThickness] property
  @override
  // keep field in order to keep doc
  // ignore: overridden_fields
  final TableBorder? border;

  /// Determines ratio of Small column's width to Medium column's width.
  /// I.e. 0.5 means that Small column is twice narower than Medium column.
  final double smRatio;

  /// Determines ratio of Large column's width to Medium column's width.
  /// I.e. 2.0 means that Large column is twice wider than Medium column.
  final double lmRatio;

  final ColumnResizingParameters? columnResizingParameters;

  /// The number of sticky rows fixed at the top of the table.
  /// The heading row is counted/included.
  /// By defult the value is 1 which means header row is fixed.
  /// Set to 0 in order to unstick the header,
  /// set to >1 in order to fix data rows
  /// (i.e. in order to fix both header and the first data row use value of 2)
  final int fixedTopRows;

  /// Number of sticky columns fixed at the left side of the table.
  /// Check box column (if enabled) is also counted
  final int fixedLeftColumns;

  /// Backgound color of the sticky columns fixed via [fixedLeftColumns].
  /// Note: unlike data rows which can change their colors depending on material state (e.g. selected, hovered)
  /// this color is static and doesn't repond to state change
  /// Note: to change background color of fixed data rows use [DataTable2.headingRowColor] and
  /// individual row colors of data rows provided via [rows]
  final Color? fixedColumnsColor;

  /// Backgound color of the top left corner which is fixed whenere both [fixedTopRows]
  /// and [fixedLeftColumns] are greater than 0
  /// Note: unlike data rows which can change their colors depending on material state (e.g. selected, hovered)
  /// this color is static and doesn't repond to state change
  /// Note: to change background color of fixed data rows use [DataTable2.headingRowColor] and
  /// individual row colors of data rows provided via [rows]
  final Color? fixedCornerColor;

  Widget _buildCheckbox(
      {required BuildContext context,
      required bool? checked,
      required VoidCallback? onRowTap,
      required ValueChanged<bool?>? onCheckboxChanged,
      required MaterialStateProperty<Color?>? overlayColor,
      required bool tristate,
      required double rowHeight,
      Color? backgroundColor}) {
    final ThemeData themeData = Theme.of(context);
    final double effectiveHorizontalMargin = horizontalMargin ??
        themeData.dataTableTheme.horizontalMargin ??
        _horizontalMargin;

    Widget contents = Semantics(
      container: true,
      child: Container(
        height: rowHeight,
        color: backgroundColor,
        padding: EdgeInsetsDirectional.only(
          start: checkboxHorizontalMargin ?? effectiveHorizontalMargin,
          end: (checkboxHorizontalMargin ?? effectiveHorizontalMargin) / 2.0,
        ),
        child: Center(
          child: Checkbox(
            activeColor: themeData.colorScheme.primary,
            checkColor: themeData.colorScheme.onPrimary,
            value: checked,
            onChanged: onCheckboxChanged,
            tristate: tristate,
          ),
        ),
      ),
    );
    if (onRowTap != null) {
      contents = TableRowInkWell(
        onTap: onRowTap,
        overlayColor: overlayColor,
        child: contents,
      );
    }

    return contents;
  }

  Widget _buildHeadingCell({
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required Widget label,
    required String? tooltip,
    required bool numeric,
    required VoidCallback? onSort,
    required bool sorted,
    required bool ascending,
    required double effectiveHeadingRowHeight,
    required MaterialStateProperty<Color?>? overlayColor,
    Color? backgroundColor,
    DataColumn2? column,
    required Function(List<DataColumn>, DataColumn2, double) onColumnResized,
  }) {
    final ThemeData themeData = Theme.of(context);
    label = Row(
      textDirection: numeric ? TextDirection.rtl : null,
      children: <Widget>[
        Flexible(child: label),
        if (onSort != null) ...<Widget>[
          _SortArrow(
            visible: sorted,
            up: sorted ? ascending : null,
            duration: _sortArrowAnimationDuration,
          ),
          const SizedBox(width: _sortArrowPadding),
        ],
      ],
    );

    final TextStyle effectiveHeadingTextStyle = headingTextStyle ??
        themeData.dataTableTheme.headingTextStyle ??
        themeData.textTheme.subtitle2!;

    label = Container(
      padding: padding,
      height: effectiveHeadingRowHeight,
      color: backgroundColor,
      alignment:
          numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: AnimatedDefaultTextStyle(
        style: effectiveHeadingTextStyle,
        softWrap: false,
        duration: _sortArrowAnimationDuration,
        child: label,
      ),
    );
    if (tooltip != null) {
      label = Tooltip(
        message: tooltip,
        child: label,
      );
    }
    label = InkWell(
      onTap: onSort,
      overlayColor: overlayColor,
      child: label,
    );
    if (column != null && column.isResizable) {
      label = Row(
        children: [
          Expanded(child: label),
          _buildResizeWidget(
            column,
            effectiveHeadingRowHeight,
            onColumnResized,
          ),
        ],
      );
    }
    return label;
  }

  Widget _buildResizeWidget(DataColumn2 column, double widgetHeight,
      Function(List<DataColumn>, DataColumn2, double) onColumnResized) {
    ColumnResizingParameters crp = columnResizingParameters != null
        ? columnResizingParameters!
        : ColumnResizingParameters();
    return ColumnResizeWidget(
      height: widgetHeight,
      color: crp.widgetColor,
      minWidth: crp.widgetMinWidth,
      maxWidth: crp.widgetMaxWidth,
      onDragUpdate: (delta) {
        if (column.isResizable) {
          onColumnResized(columns, column, delta);
        }
      },
      desktopMode: crp.desktopMode,
      realTime: crp.realTime,
    );
  }

  Widget _buildDataCell({
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required double? specificRowHeight,
    required Widget label,
    required bool numeric,
    required bool placeholder,
    required bool showEditIcon,
    required double defaultDataRowHeight,
    required GestureTapCallback? onTap,
    required GestureTapCallback? onDoubleTap,
    required GestureLongPressCallback? onLongPress,
    required GestureTapDownCallback? onTapDown,
    required GestureTapCancelCallback? onTapCancel,
    required GestureTapCallback? onRowTap,
    required GestureTapCallback? onRowDoubleTap,
    required GestureLongPressCallback? onRowLongPress,
    required GestureTapCallback? onRowSecondaryTap,
    required GestureTapDownCallback? onRowSecondaryTapDown,
    required VoidCallback? onSelectChanged,
    required MaterialStateProperty<Color?>? overlayColor,
    Color? backgroundColor,
  }) {
    final ThemeData themeData = Theme.of(context);
    if (showEditIcon) {
      const Widget icon = Icon(Icons.edit, size: 18.0);
      label = Expanded(child: label);
      label = Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[label, icon],
      );
    }

    final TextStyle effectiveDataTextStyle = dataTextStyle ??
        themeData.dataTableTheme.dataTextStyle ??
        themeData.textTheme.bodyText2!;
    final double effectiveDataRowHeight =
        specificRowHeight ?? defaultDataRowHeight;

    label = Container(
      padding: padding,
      height: effectiveDataRowHeight,
      color: backgroundColor,
      alignment:
          numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: DefaultTextStyle(
        style: effectiveDataTextStyle.copyWith(
          color: placeholder
              ? effectiveDataTextStyle.color!.withOpacity(0.6)
              : null,
        ),
        child: DropdownButtonHideUnderline(child: label),
      ),
    );

    // Wrap label intro InkResponse if there're cell or row level tap events
    if (onTap != null ||
        onDoubleTap != null ||
        onLongPress != null ||
        onTapDown != null ||
        onTapCancel != null) {
      // cell only
      label = InkWell(
        onTap: () {
          onTap?.call();
          onRowTap?.call();
        },
        onDoubleTap: () {
          onDoubleTap?.call();
          onRowDoubleTap?.call();
        },
        onLongPress: () {
          onLongPress?.call();
          onRowLongPress?.call();
        },
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        overlayColor: overlayColor,
        child: label,
      );
      label =
          _addSecondaryTaps(onRowSecondaryTap, onRowSecondaryTapDown, label);
    } else if (onSelectChanged != null ||
        onRowTap != null ||
        onRowDoubleTap != null ||
        onRowLongPress != null ||
        onRowSecondaryTap != null ||
        onRowSecondaryTapDown != null) {
      label = TableRowInkWell(
        onTap: onRowTap == null && onSelectChanged == null
            ? null
            : () {
                onRowTap?.call();
                onSelectChanged?.call();
              },
        onDoubleTap: onRowDoubleTap,
        onLongPress: onRowLongPress,
        overlayColor: overlayColor,
        child: label,
      );

      label =
          _addSecondaryTaps(onRowSecondaryTap, onRowSecondaryTapDown, label);
    }
    return label;
  }

  Widget _addSecondaryTaps(GestureTapCallback? onRowSecondaryTap,
      GestureTapDownCallback? onRowSecondaryTapDown, Widget label) {
    if (onRowSecondaryTap != null || onRowSecondaryTapDown != null) {
      label = GestureDetector(
          onSecondaryTap: onRowSecondaryTap,
          onSecondaryTapDown: onRowSecondaryTapDown,
          child: label);
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    var sw = Stopwatch();
    sw.start();
    // assert(!_debugInteractive || debugCheckHasMaterial(context));
    assert(debugCheckHasMaterial(context));

    final theme = Theme.of(context);
    final effectiveHeadingRowColor =
        headingRowColor ?? theme.dataTableTheme.headingRowColor;
    final effectiveDataRowColor =
        dataRowColor ?? theme.dataTableTheme.dataRowColor;
    final defaultRowColor = MaterialStateProperty.resolveWith(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return theme.colorScheme.primary.withOpacity(0.08);
        }
        return null;
      },
    );
    final anyRowSelectable =
        rows.any((DataRow row) => row.onSelectChanged != null);
    final displayCheckboxColumn = showCheckboxColumn && anyRowSelectable;
    final rowsWithCheckbox = displayCheckboxColumn
        ? rows.where((DataRow row) => row.onSelectChanged != null)
        : <DataRow2>[];
    final rowsChecked = rowsWithCheckbox.where((DataRow row) => row.selected);
    final allChecked =
        displayCheckboxColumn && rowsChecked.length == rowsWithCheckbox.length;
    final anyChecked = displayCheckboxColumn && rowsChecked.isNotEmpty;
    final someChecked = anyChecked && !allChecked;
    final effectiveHorizontalMargin = horizontalMargin ??
        theme.dataTableTheme.horizontalMargin ??
        _horizontalMargin;
    final effectiveColumnSpacing =
        columnSpacing ?? theme.dataTableTheme.columnSpacing ?? _columnSpacing;

    final double effectiveHeadingRowHeight = headingRowHeight ??
        theme.dataTableTheme.headingRowHeight ??
        _headingRowHeight;

    final double defaultDataRowHeight = dataRowHeight ??
        theme.dataTableTheme.dataRowHeight ??
        kMinInteractiveDimension;

    final tableColumnWidths = List<TableColumnWidth>.filled(
        columns.length + (displayCheckboxColumn ? 1 : 0),
        const _NullTableColumnWidth());

    final headingRow = _buildHeadingRow(
        context, theme, effectiveHeadingRowColor, tableColumnWidths.length);

    final actualFixedRows =
        math.max(0, rows.isEmpty ? 0 : math.min(fixedTopRows, rows.length + 1));
    final actualFixedColumns = math.max(
        0,
        rows.isEmpty
            ? 0
            : math.min(fixedLeftColumns,
                columns.length + (showCheckboxColumn ? 1 : 0)));

    List<TableRow>? coreRows = rows.isEmpty ||
            actualFixedColumns >= columns.length + (showCheckboxColumn ? 1 : 0)
        ? null
        : _buildTableRows(
            anyRowSelectable,
            effectiveDataRowColor,
            context,
            theme,
            tableColumnWidths.length - actualFixedColumns,
            defaultRowColor,
            actualFixedRows == 0
                ? _buildHeadingRow(context, theme, effectiveHeadingRowColor,
                    tableColumnWidths.length - actualFixedColumns)
                : null,
            actualFixedRows > 0 ? actualFixedRows - 1 : 0);

    List<TableRow>? fixedColumnsRows = rows.isEmpty
        ? null
        : actualFixedColumns > 0
            ? (actualFixedRows < 1
                ? [
                    _buildHeadingRow(context, theme, effectiveHeadingRowColor,
                        actualFixedColumns),
                    ..._buildTableRows(
                        anyRowSelectable,
                        effectiveDataRowColor,
                        context,
                        theme,
                        actualFixedColumns,
                        defaultRowColor,
                        null)
                  ]
                : _buildTableRows(
                    anyRowSelectable,
                    effectiveDataRowColor,
                    context,
                    theme,
                    actualFixedColumns,
                    defaultRowColor,
                    null,
                    actualFixedRows - 1,
                  ))
            : null;

    List<TableRow>? fixedRows = actualFixedRows > 0
        ? (actualFixedRows == 1
            ? [
                _buildHeadingRow(context, theme, effectiveHeadingRowColor,
                    tableColumnWidths.length - actualFixedColumns)
              ]
            : [
                _buildHeadingRow(context, theme, effectiveHeadingRowColor,
                    tableColumnWidths.length - actualFixedColumns),
                ..._buildTableRows(
                    anyRowSelectable,
                    effectiveDataRowColor,
                    context,
                    theme,
                    tableColumnWidths.length - actualFixedColumns,
                    defaultRowColor,
                    null,
                    0,
                    actualFixedRows - 1)
              ])
        : null;

    List<TableRow>? fixedCornerRows =
        actualFixedColumns > 0 && actualFixedRows > 0
            ? (actualFixedRows == 1
                ? [
                    _buildHeadingRow(context, theme, effectiveHeadingRowColor,
                        actualFixedColumns)
                  ]
                : [
                    _buildHeadingRow(context, theme, effectiveHeadingRowColor,
                        actualFixedColumns),
                    ..._buildTableRows(
                        anyRowSelectable,
                        effectiveDataRowColor,
                        context,
                        theme,
                        actualFixedColumns,
                        defaultRowColor,
                        null,
                        0,
                        actualFixedRows - 1)
                  ])
            : null;

    double checkBoxWidth = _addCheckBoxes(
        displayCheckboxColumn,
        effectiveHorizontalMargin,
        tableColumnWidths,
        headingRow,
        effectiveHeadingRowHeight,
        context,
        someChecked,
        allChecked,
        coreRows,
        fixedRows,
        fixedCornerRows,
        fixedColumnsRows,
        rows,
        actualFixedRows,
        defaultDataRowHeight,
        effectiveDataRowColor);

    var builder = LayoutBuilder(builder: (context, constraints) {
      return SyncedScrollControllers(
          scrollController: scrollController,
          sc12toSc11Position: true,
          builder: (context, sc11, sc12, sc21, sc22) {
            return ResizeColumns(
                columns: columns,
                builder: (context, cdc, onColumnResized) {
                  var coreVerticalController = sc11;
                  var leftColumnVerticalContoller = sc12;
                  var coreHorizontalController = sc21;
                  var fixedRowsHorizontalController = sc22;

                  var displayColumnIndex = 0;

                  // size & build checkboxes in heading and leftmost column
                  // to be substracted from total width available to columns

                  if (checkBoxWidth > 0) displayColumnIndex += 1;

                  // size data columns
                  final widths = _calculateDataColumnSizes(constraints,
                      checkBoxWidth, effectiveHorizontalMargin, cdc);

                  // File empty cells in created rows with actual widgets
                  for (int dataColumnIndex = 0;
                      dataColumnIndex < columns.length;
                      dataColumnIndex++) {
                    final DataColumn column = columns[dataColumnIndex];

                    final double paddingStart;
                    if (dataColumnIndex == 0 && displayCheckboxColumn) {
                      paddingStart = effectiveHorizontalMargin / 2.0;
                    } else if (dataColumnIndex == 0 && !displayCheckboxColumn) {
                      paddingStart = effectiveHorizontalMargin;
                    } else {
                      paddingStart = effectiveColumnSpacing / 2.0;
                    }

                    final double paddingEnd;
                    if (dataColumnIndex == columns.length - 1) {
                      paddingEnd = effectiveHorizontalMargin;
                    } else {
                      paddingEnd = effectiveColumnSpacing / 2.0;
                    }

                    final EdgeInsetsDirectional padding =
                        EdgeInsetsDirectional.only(
                      start: paddingStart,
                      end: paddingEnd,
                    );

                    tableColumnWidths[displayColumnIndex] =
                        FixedColumnWidth(widths[dataColumnIndex]);
                    var h = _buildHeadingCell(
                        context: context,
                        padding: padding,
                        effectiveHeadingRowHeight: effectiveHeadingRowHeight,
                        label: column.label,
                        tooltip: column.tooltip,
                        numeric: column.numeric,
                        onSort: column.onSort != null
                            ? () => column.onSort!(
                                dataColumnIndex,
                                sortColumnIndex != dataColumnIndex ||
                                    !sortAscending)
                            : null,
                        sorted: dataColumnIndex == sortColumnIndex,
                        ascending: sortAscending,
                        overlayColor: effectiveHeadingRowColor,
                        column: column is DataColumn2 ? column : null,
                        backgroundColor: displayColumnIndex < actualFixedColumns
                            ? (actualFixedRows < 1
                                ? fixedColumnsColor
                                : (actualFixedRows > 0
                                    ? fixedCornerColor
                                    : null))
                            : null,
                        onColumnResized: onColumnResized);

                    headingRow.children![displayColumnIndex] =
                        h; // heading row alone is used to display table header should there be no data rows

                    if (displayColumnIndex < actualFixedColumns) {
                      if (actualFixedRows < 1) {
                        fixedColumnsRows![0].children![displayColumnIndex] = h;
                      } else if (actualFixedRows > 0) {
                        fixedCornerRows![0].children![displayColumnIndex] = h;
                      }
                    } else {
                      if (actualFixedRows < 1 && coreRows != null) {
                        coreRows[0].children![
                            displayColumnIndex - actualFixedColumns] = h;
                      } else if (actualFixedRows > 0) {
                        fixedRows![0].children![
                            displayColumnIndex - actualFixedColumns] = h;
                      }
                    }

                    var rowIndex = 0;
                    var skipRows = actualFixedRows == 1
                        ? 0
                        : actualFixedRows > 1
                            ? actualFixedRows - 1
                            : -1;

                    for (final DataRow row in rows) {
                      final DataCell cell = row.cells[dataColumnIndex];
                      //dataRows[rowIndex].children![displayColumnIndex]

                      var c = _buildDataCell(
                          context: context,
                          padding: padding,
                          defaultDataRowHeight: defaultDataRowHeight,
                          specificRowHeight:
                              row is DataRow2 ? row.specificRowHeight : null,
                          label: cell.child,
                          numeric: column.numeric,
                          placeholder: cell.placeholder,
                          showEditIcon: cell.showEditIcon,
                          onTap: cell.onTap,
                          onDoubleTap: cell.onDoubleTap,
                          onLongPress: cell.onLongPress,
                          onTapDown: cell.onTapDown,
                          onTapCancel: cell.onTapCancel,
                          onRowTap: row is DataRow2 ? row.onTap : null,
                          onRowDoubleTap:
                              row is DataRow2 ? row.onDoubleTap : null,
                          onRowLongPress: row.onLongPress,
                          onRowSecondaryTap:
                              row is DataRow2 ? row.onSecondaryTap : null,
                          onRowSecondaryTapDown:
                              row is DataRow2 ? row.onSecondaryTapDown : null,
                          onSelectChanged: row.onSelectChanged != null
                              ? () => row.onSelectChanged!(!row.selected)
                              : null,
                          overlayColor: row.color ?? effectiveDataRowColor,
                          backgroundColor:
                              displayColumnIndex < actualFixedColumns
                                  ? (rowIndex + 1 < actualFixedRows
                                      ? fixedCornerColor
                                      : fixedColumnsColor)
                                  : null);

                      if (displayColumnIndex < actualFixedColumns) {
                        if (rowIndex + 1 < actualFixedRows) {
                          fixedCornerRows![rowIndex + 1]
                              .children![displayColumnIndex] = c;
                        } else {
                          fixedColumnsRows![rowIndex - skipRows]
                              .children![displayColumnIndex] = c;
                        }
                      } else {
                        if (rowIndex + 1 < actualFixedRows) {
                          fixedRows![rowIndex + 1].children![
                              displayColumnIndex - actualFixedColumns] = c;
                        } else {
                          coreRows![rowIndex - skipRows].children![
                              displayColumnIndex - actualFixedColumns] = c;
                        }
                      }

                      rowIndex += 1;
                    }
                    displayColumnIndex += 1;
                  }

                  var widthsAsMap = tableColumnWidths.asMap();
                  Map<int, TableColumnWidth>? leftWidthsAsMap =
                      actualFixedColumns > 0
                          ? tableColumnWidths
                              .take(actualFixedColumns)
                              .toList()
                              .asMap()
                          : null;
                  Map<int, TableColumnWidth>? rightWidthsAsMap =
                      actualFixedColumns > 0
                          ? tableColumnWidths
                              .skip(actualFixedColumns)
                              .toList()
                              .asMap()
                          : null;

                  bool _isRowsEmpty(List<TableRow>? rows) {
                    return rows == null ||
                        rows.isEmpty ||
                        rows[0].children!.isEmpty;
                  }

                  var coreTable = Table(
                      columnWidths: actualFixedColumns > 0
                          ? rightWidthsAsMap
                          : widthsAsMap,
                      children: coreRows ?? [],
                      border: border == null
                          ? null
                          : _isRowsEmpty(fixedRows) &&
                                  _isRowsEmpty(fixedColumnsRows)
                              ? border
                              : !_isRowsEmpty(fixedRows) &&
                                      !_isRowsEmpty(fixedColumnsRows)
                                  ? TableBorder(
                                      //top: border!.top,
                                      //left: border!.left,
                                      right: border!.right,
                                      bottom: border!.bottom,
                                      verticalInside: border!.verticalInside,
                                      horizontalInside:
                                          border!.horizontalInside,
                                      borderRadius: border!.borderRadius)
                                  : _isRowsEmpty(fixedRows)
                                      ? TableBorder(
                                          top: border!.top,
                                          //left: border!.left,
                                          right: border!.right,
                                          bottom: border!.bottom,
                                          verticalInside:
                                              border!.verticalInside,
                                          horizontalInside:
                                              border!.horizontalInside,
                                          borderRadius: border!.borderRadius)
                                      : TableBorder(
                                          //top: border!.top,
                                          left: border!.left,
                                          right: border!.right,
                                          bottom: border!.bottom,
                                          verticalInside:
                                              border!.verticalInside,
                                          horizontalInside:
                                              border!.horizontalInside,
                                          borderRadius: border!.borderRadius));

                  Table? fixedRowsTabel;
                  Table? fixedColumnsTable;
                  Table? fixedTopLeftCornerTable;
                  Widget? fixedColumnAndCornerCol;
                  Widget? fixedRowsAndCoreCol;

                  if (rows.isNotEmpty) {
                    if (fixedRows != null &&
                        !_isRowsEmpty(fixedRows) &&
                        actualFixedColumns <
                            columns.length + (showCheckboxColumn ? 1 : 0)) {
                      fixedRowsTabel = Table(
                          columnWidths: actualFixedColumns > 0
                              ? rightWidthsAsMap
                              : widthsAsMap,
                          children: fixedRows,
                          border: border == null
                              ? null
                              : _isRowsEmpty(fixedCornerRows)
                                  ? border
                                  : TableBorder(
                                      top: border!.top,
                                      //left: border!.left,
                                      right: border!.right,
                                      bottom: border!.bottom,
                                      verticalInside: border!.verticalInside,
                                      horizontalInside:
                                          border!.horizontalInside,
                                      borderRadius: border!.borderRadius));
                    }

                    if (fixedColumnsRows != null &&
                        !_isRowsEmpty(fixedColumnsRows)) {
                      fixedColumnsTable = Table(
                          columnWidths: leftWidthsAsMap,
                          children: fixedColumnsRows,
                          border: border == null
                              ? null
                              : _isRowsEmpty(fixedCornerRows)
                                  ? border
                                  : TableBorder(
                                      //top: border!.top,
                                      left: border!.left,
                                      right: border!.right,
                                      bottom: border!.bottom,
                                      verticalInside: border!.verticalInside,
                                      horizontalInside:
                                          border!.horizontalInside,
                                      borderRadius: border!.borderRadius));
                    }

                    if (fixedCornerRows != null &&
                        !_isRowsEmpty(fixedCornerRows)) {
                      fixedTopLeftCornerTable = Table(
                          columnWidths: leftWidthsAsMap,
                          children: fixedCornerRows,
                          border: border);
                    }

                    Widget _addBottomMargin(Table t) =>
                        bottomMargin != null && bottomMargin! > 0
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [t, SizedBox(height: bottomMargin!)])
                            : t;

                    fixedRowsAndCoreCol = Scrollbar(
                        controller: coreHorizontalController,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                  controller: fixedRowsHorizontalController,
                                  scrollDirection: Axis.horizontal,
                                  child: (fixedRowsTabel != null)
                                      ? fixedRowsTabel
                                      // WOrkaround for a bug when there's no horizontal scrollbar should there be no this SingleChildScrollView. I.e. originally this part was ommited and not scrollable was added to the column if not fixed top row was visible
                                      : SizedBox(
                                          height: 0,
                                          width: widths.fold<double>(
                                              0,
                                              (previousValue, value) =>
                                                  previousValue + value),
                                        ))),
                          Flexible(
                              fit: FlexFit.tight,
                              child: SingleChildScrollView(
                                  controller: coreVerticalController,
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                      controller: coreHorizontalController,
                                      scrollDirection: Axis.horizontal,
                                      child: _addBottomMargin(coreTable))))
                        ]));

                    fixedColumnAndCornerCol = fixedTopLeftCornerTable == null &&
                            fixedColumnsTable == null
                        ? null
                        : Column(mainAxisSize: MainAxisSize.min, children: [
                            if (fixedTopLeftCornerTable != null)
                              fixedTopLeftCornerTable,
                            if (fixedColumnsTable != null)
                              Flexible(
                                  fit: FlexFit.loose,
                                  child: ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(scrollbars: false),
                                      child: SingleChildScrollView(
                                          controller:
                                              leftColumnVerticalContoller,
                                          scrollDirection: Axis.vertical,
                                          child: _addBottomMargin(
                                              fixedColumnsTable))))
                          ]);
                  }

                  var completeWidget = Container(
                      decoration: decoration ?? theme.dataTableTheme.decoration,
                      child: rows.isEmpty
                          ? Column(children: [
                              SingleChildScrollView(
                                  controller: coreHorizontalController,
                                  scrollDirection: Axis.horizontal,
                                  child: Table(
                                      columnWidths: widthsAsMap,
                                      border: border,
                                      children: [headingRow])),
                              Flexible(
                                  fit: FlexFit.tight,
                                  child: empty ?? const SizedBox())
                            ])
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (fixedColumnAndCornerCol != null)
                                  fixedColumnAndCornerCol,
                                if (fixedRowsAndCoreCol != null)
                                  Flexible(
                                      fit: FlexFit.tight,
                                      child: fixedRowsAndCoreCol)
                              ],
                            ));

                  return completeWidget;
                });
          });
    });

    sw.stop();
    if (kDebugMode) print('DataTable2 built: ${sw.elapsedMilliseconds}ms');
    return builder;
  }

  double _addCheckBoxes(
      bool displayCheckboxColumn,
      double effectiveHorizontalMargin,
      List<TableColumnWidth> tableColumns,
      TableRow headingRow,
      double headingHeight,
      BuildContext context,
      bool someChecked,
      bool allChecked,
      List<TableRow>? coreRows,
      List<TableRow>? fixedRows,
      List<TableRow>? fixedCornerRows,
      List<TableRow>? fixedColumnRows,
      List<DataRow> rows,
      int actualFixedRows,
      double defaultDataRowHeight,
      MaterialStateProperty<Color?>? effectiveDataRowColor) {
    double checkBoxWidth = 0;

    if (displayCheckboxColumn) {
      checkBoxWidth = effectiveHorizontalMargin +
          Checkbox.width +
          effectiveHorizontalMargin / 2.0;
      tableColumns[0] = FixedColumnWidth(checkBoxWidth);

      // Create heading twice, in the heading row used as back-up for the case of no data and any of the xxx_rows table
      headingRow.children![0] = _buildCheckbox(
          context: context,
          checked: someChecked ? null : allChecked,
          onRowTap: null,
          onCheckboxChanged: (bool? checked) =>
              _handleSelectAll(checked, someChecked),
          overlayColor: null,
          tristate: true,
          rowHeight: headingHeight,
          backgroundColor: fixedCornerRows != null
              ? fixedCornerColor
              : fixedColumnRows != null
                  ? fixedColumnsColor
                  : null);

      if (fixedCornerRows != null) {
        fixedCornerRows[0].children![0] = headingRow.children![0];
      } else if (fixedColumnRows != null) {
        fixedColumnRows[0].children![0] = headingRow.children![0];
      } else if (fixedRows != null) {
        fixedRows[0].children![0] = headingRow.children![0];
      } else {
        coreRows![0].children![0] = headingRow.children![0];
      }

      var skipRows = actualFixedRows == 1
          ? 0
          : actualFixedRows > 1
              ? actualFixedRows - 1
              : -1;

      var rowIndex = 0;
      for (final DataRow row in rows) {
        var x = _buildCheckbox(
            context: context,
            checked: row.selected,
            onRowTap: () {
              row.onSelectChanged?.call(!row.selected);
              if (row is DataRow2) {
                row.onTap?.call();
              }
            },
            onCheckboxChanged: row.onSelectChanged,
            overlayColor: row.color ?? effectiveDataRowColor,
            tristate: false,
            rowHeight: ((rows[rowIndex] is DataRow2) &&
                    (rows[rowIndex] as DataRow2).specificRowHeight != null)
                ? (rows[rowIndex] as DataRow2).specificRowHeight!
                : defaultDataRowHeight,
            backgroundColor:
                fixedCornerRows != null && rowIndex < fixedCornerRows.length - 1
                    ? fixedCornerColor
                    : fixedColumnRows != null
                        ? fixedColumnsColor
                        : null);

        if (fixedCornerRows != null && rowIndex < fixedCornerRows.length - 1) {
          fixedCornerRows[rowIndex + 1].children![0] = x;
        } else if (fixedColumnRows != null) {
          fixedColumnRows[rowIndex - skipRows].children![0] = x;
        } else if (fixedRows != null && rowIndex < fixedRows.length - 1) {
          fixedRows[rowIndex + 1].children![0] = x;
        } else {
          coreRows![rowIndex - skipRows].children![0] = x;
        }

        rowIndex += 1;
      }
    }
    return checkBoxWidth;
  }

  List<double> _calculateDataColumnSizes(
      BoxConstraints constraints,
      double checkBoxWidth,
      double effectiveHorizontalMargin,
      ColumnDataController columnDataController) {
    var totalColAvailableWidth = constraints.maxWidth;
    double totalExtraWidth = 0;
    double totalFixedWidth = 0;
    for (var c in columns) {
      if (c is DataColumn2) {
        var extraWidth = columnDataController.getExtraWidth(columns.indexOf(c));
        totalExtraWidth += extraWidth;
        if (c.fixedWidth != null) {
          totalFixedWidth += c.fixedWidth!;
        } else if (extraWidth != 0) {
          totalFixedWidth +=
              columnDataController.colsWidthNoExtra[columns.indexOf(c)]!;
        }
      }
    }
    if (minWidth != null && totalColAvailableWidth < minWidth!) {
      totalColAvailableWidth = minWidth!;
    }

    // full margins are added to side column widths when no check box column is
    // present, half-margin added to first data column width is check box column
    // is present and full margin added to the right
    var minColWidth = checkBoxWidth +
        effectiveHorizontalMargin +
        (checkBoxWidth > 0
            ? effectiveHorizontalMargin / 2
            : effectiveHorizontalMargin);
    totalColAvailableWidth = totalColAvailableWidth - minColWidth;

    // We only check fixed width if there are no resisable columns
    if (totalExtraWidth == 0) {
      assert(totalFixedWidth < totalColAvailableWidth,
          "DataTable2, combined width of columns of fixed width is greater than availble parent width. Table will be clipped");
    }
    totalColAvailableWidth = math.max(
        0.0, totalColAvailableWidth - totalFixedWidth - totalExtraWidth);
    var columnWidth = totalColAvailableWidth / columns.length;
    var totalColCalculatedWidth = 0.0;
    // adjust column sizes relative to S, M, L
    final widths = List<double>.generate(columns.length, (i) {
      var w = columnWidth;
      var column = columns[i];
      var extraWidth = 0.0;
      if (column is DataColumn2) {
        extraWidth = columnDataController.getExtraWidth(i);
        if (extraWidth != 0) {
          w = columnDataController.colsWidthNoExtra[i]!;
        } else if (column.fixedWidth != null) {
          w = column.fixedWidth!;
        } else if (column.size == ColumnSize.S) {
          w *= smRatio;
        } else if (column.size == ColumnSize.L) {
          w *= lmRatio;
        }
      }

      //skip fixed width columns
      if (!(column is DataColumn2 && column.fixedWidth != null) &&
          extraWidth == 0) {
        totalColCalculatedWidth += w;
      }
      return w;
    });

    // scale columns to fit the total lenght into available width

    var ratio = totalColCalculatedWidth != 0
        ? totalColAvailableWidth / totalColCalculatedWidth
        : 0;
    for (var i = 0; i < widths.length; i++) {
      double extraWidth = columnDataController.getExtraWidth(i);
      // skip fixed width column
      if (!(columns[i] is DataColumn2 &&
              (columns[i] as DataColumn2).fixedWidth != null) &&
          extraWidth == 0) {
        widths[i] *= ratio;
      }
      columnDataController.colsWidthNoExtra[i] = widths[i];
      widths[i] += extraWidth;
      if (widths[i] < ColumnDataController.minColWidth) {
        widths[i] = ColumnDataController.minColWidth;
        columnDataController.colsWidthNoExtra[i] = widths[i];
      }
    }

    // add margins to side columns
    if (widths.length == 1) {
      widths[0] = math.max(
          0,
          widths[0] +
              effectiveHorizontalMargin +
              (checkBoxWidth > 0
                  ? effectiveHorizontalMargin / 2
                  : effectiveHorizontalMargin));
    } else if (widths.length > 1) {
      widths[0] = math.max(
          0,
          widths[0] +
              (checkBoxWidth > 0
                  ? effectiveHorizontalMargin / 2
                  : effectiveHorizontalMargin));
      widths[widths.length - 1] =
          math.max(0, widths[widths.length - 1] + effectiveHorizontalMargin);
    }
    return widths;
  }

  List<TableRow> _buildTableRows(
      bool anyRowSelectable,
      MaterialStateProperty<Color?>? effectiveDataRowColor,
      BuildContext context,
      ThemeData theme,
      int numberOfCols,
      MaterialStateProperty<Color?> defaultRowColor,
      TableRow? headingRow,
      [int skipRows = 0,
      int takeRows = 0]) {
    final rowStartIndex = skipRows;
    final List<TableRow> tableRows = List<TableRow>.generate(
      (takeRows <= 0 ? rows.length - skipRows : takeRows) +
          (headingRow == null ? 0 : 1),
      (int index) {
        var actualIndex = headingRow == null ? index : index - 1;
        if (headingRow != null && index == 0) {
          return headingRow;
        } else {
          final bool isSelected = rows[rowStartIndex + actualIndex].selected;
          final bool isDisabled = anyRowSelectable &&
              rows[rowStartIndex + actualIndex].onSelectChanged == null;
          final Set<MaterialState> states = <MaterialState>{
            if (isSelected) MaterialState.selected,
            if (isDisabled) MaterialState.disabled,
          };
          final Color? resolvedDataRowColor =
              (rows[rowStartIndex + actualIndex].color ?? effectiveDataRowColor)
                  ?.resolve(states);
          final Color? rowColor = resolvedDataRowColor;
          final BorderSide borderSide = Divider.createBorderSide(
            context,
            width: dividerThickness ??
                theme.dataTableTheme.dividerThickness ??
                _dividerThickness,
          );
          final Border border = showBottomBorder
              ? Border(bottom: borderSide)
              : Border(top: borderSide);
          return TableRow(
            key: rows[rowStartIndex + actualIndex].key,
            decoration: BoxDecoration(
              // Changed standard behaviour to never add border should the thickness be 0
              border: dividerThickness == null ||
                      (dividerThickness != null && dividerThickness != 0.0)
                  ? border
                  : null,
              color: rowColor ?? defaultRowColor.resolve(states),
            ),
            children: List<Widget>.filled(
                numberOfCols <= 0 ? numberOfCols : numberOfCols,
                const _NullWidget()),
          );
        }
      },
    );

    return tableRows;
  }

  TableRow _buildHeadingRow(
      BuildContext context,
      ThemeData theme,
      MaterialStateProperty<Color?>? effectiveHeadingRowColor,
      int numberOfCols) {
    var headingRow = TableRow(
      key: _headingRowKey,
      decoration: BoxDecoration(
        // Changed standard behaviour to never add border should the thickness be 0
        border: showBottomBorder &&
                border == null &&
                (dividerThickness == null ||
                    (dividerThickness != null && dividerThickness != 0.0))
            ? Border(
                bottom: Divider.createBorderSide(
                context,
                width: dividerThickness ??
                    theme.dataTableTheme.dividerThickness ??
                    _dividerThickness,
              ))
            : null,
        color: effectiveHeadingRowColor?.resolve(<MaterialState>{}),
      ),
      children: List<Widget>.filled(numberOfCols, const _NullWidget()),
    );
    return headingRow;
  }
}

class _SortArrow extends StatefulWidget {
  const _SortArrow({
    required this.visible,
    required this.up,
    required this.duration,
  });

  final bool visible;

  final bool? up;

  final Duration duration;

  @override
  _SortArrowState createState() => _SortArrowState();
}

class _SortArrowState extends State<_SortArrow> with TickerProviderStateMixin {
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;

  late AnimationController _orientationController;
  late Animation<double> _orientationAnimation;
  double _orientationOffset = 0.0;

  bool? _up;

  static final Animatable<double> _turnTween =
      Tween<double>(begin: 0.0, end: math.pi)
          .chain(CurveTween(curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _up = widget.up;
    _opacityAnimation = CurvedAnimation(
      parent: _opacityController = AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
      curve: Curves.fastOutSlowIn,
    )..addListener(_rebuild);
    _opacityController.value = widget.visible ? 1.0 : 0.0;
    _orientationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _orientationAnimation = _orientationController.drive(_turnTween)
      ..addListener(_rebuild)
      ..addStatusListener(_resetOrientationAnimation);
    if (widget.visible) _orientationOffset = widget.up! ? 0.0 : math.pi;
  }

  void _rebuild() {
    setState(() {
      // The animations changed, so we need to rebuild.
    });
  }

  void _resetOrientationAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      assert(_orientationAnimation.value == math.pi);
      _orientationOffset += math.pi;
      _orientationController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(_SortArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool skipArrow = false;
    final bool? newUp = widget.up ?? _up;
    if (oldWidget.visible != widget.visible) {
      if (widget.visible &&
          (_opacityController.status == AnimationStatus.dismissed)) {
        _orientationController.stop();
        _orientationController.value = 0.0;
        _orientationOffset = newUp! ? 0.0 : math.pi;
        skipArrow = true;
      }
      if (widget.visible) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }
    if ((_up != newUp) && !skipArrow) {
      if (_orientationController.status == AnimationStatus.dismissed) {
        _orientationController.forward();
      } else {
        _orientationController.reverse();
      }
    }
    _up = newUp;
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _orientationController.dispose();
    super.dispose();
  }

  static const double _arrowIconBaselineOffset = -1.5;
  static const double _arrowIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacityAnimation.value,
      child: Transform(
        transform:
            Matrix4.rotationZ(_orientationOffset + _orientationAnimation.value)
              ..setTranslationRaw(0.0, _arrowIconBaselineOffset, 0.0),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_upward,
          size: _arrowIconSize,
        ),
      ),
    );
  }
}

// coverage:ignore-start
class _NullTableColumnWidth extends TableColumnWidth {
  const _NullTableColumnWidth();

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      throw UnimplementedError();

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}
// coverage:ignore-end

/// Creates pairs of scroll controllers which can be provided to scrollables and ensure that
/// offset change in one scrollable scroll the second one (and vice a versa)
/// There's a bug (or feature) on iOS with bouncing scroll (when it goes out of range)
/// when scrollable get out of sync while in this bouncing position
class SyncedScrollControllers extends StatefulWidget {
  const SyncedScrollControllers(
      {super.key,
      required this.builder,
      this.scrollController,
      this.sc12toSc11Position = false});

  /// One of the controllers (sc11) won't be created by this widget
  /// but rather use externally provided one
  final ScrollController? scrollController;

  /// Whether to set sc12 initison offset to the value from sc11
  final bool sc12toSc11Position;

  /// Positions of 2 pairs of scroll controllers (sc11|sc12 and sc21|sc22)
  /// will be synchronized, attached scrollables will copy the positions
  final Widget Function(
      BuildContext context,
      ScrollController sc11,
      ScrollController sc12,
      ScrollController sc21,
      ScrollController sc22) builder;

  @override
  SyncedScrollControllersState createState() => SyncedScrollControllersState();
}

class SyncedScrollControllersState extends State<SyncedScrollControllers> {
  ScrollController? _sc11;
  late ScrollController _sc12;
  late ScrollController _sc21;
  late ScrollController _sc22;

  final List<void Function()> _listeners = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(SyncedScrollControllers oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeOrUnsubscribe();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _doNotReissueJump.clear();
    var offset =
        _sc11 == null || _sc11!.positions.isEmpty ? 0.0 : _sc11!.offset;
    if (widget.scrollController != null) {
      _sc11 = widget.scrollController!;
      if (_sc11!.positions.isNotEmpty) {
        offset = _sc11!.offset;
      }
    } else {
      _sc11 = ScrollController();
    }

    _sc12 = ScrollController(
        initialScrollOffset: widget.sc12toSc11Position ? offset : 0.0);

    _sc21 = ScrollController();
    _sc22 = ScrollController();

    _syncScrollControllers(_sc11!, _sc12);
    _syncScrollControllers(_sc21, _sc22);
  }

  void _disposeOrUnsubscribe() {
    if (widget.scrollController == _sc11) {
      _sc11?.removeListener(_listeners[0]);
    } else {
      _sc11?.dispose();
    }
    _sc12.dispose();
    _sc21.dispose();
    _sc22.dispose();
    _listeners.clear();
  }

  final Map<ScrollController, bool> _doNotReissueJump = {};

  void _syncScrollControllers(ScrollController sc1, ScrollController sc2) {
    var l = () => _jumpToNoCascade(sc1, sc2);
    sc1.addListener(l);
    _listeners.add(l);
    l = () => _jumpToNoCascade(sc2, sc1);
    sc2.addListener(l);
  }

  void _jumpToNoCascade(ScrollController master, ScrollController slave) {
    //print('$master $slave');
    if (!slave.hasClients || slave.position.outOfRange) {
      return; //outOfRange check for bounce case, bug #113
    }
    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true;
      slave.jumpTo(master.offset);
    } else {
      _doNotReissueJump[master] = false;
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _sc11!, _sc12, _sc21, _sc22);
}
