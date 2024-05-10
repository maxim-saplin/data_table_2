// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin - changes and modifications to original Flutter implementation of DataTable

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool dataTableShowLogs = true;

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
      this.fixedWidth});

  /// Column sizes are determined based on available width by distributing it
  /// to individual columns accounting for their relative sizes (see [ColumnSize])
  final ColumnSize size;

  /// Defines absolute width of the column in pixel (as opposed to relative size used by default).
  /// Warning, if the width happens to be larger than available total width other
  /// columns can be clipped
  final double? fixedWidth;
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
      this.decoration,
      required super.cells,
      this.specificRowHeight,
      this.onTap,
      this.onDoubleTap,
      super.onLongPress,
      this.onSecondaryTap,
      this.onSecondaryTapDown});

  DataRow2.byIndex(
      {super.index,
      super.selected = false,
      super.onSelectChanged,
      super.color,
      this.decoration,
      required super.cells,
      this.specificRowHeight,
      this.onTap,
      this.onDoubleTap,
      super.onLongPress,
      this.onSecondaryTap,
      this.onSecondaryTapDown})
      : super.byIndex();

  /// Clone row, if non null values are provided - override the corresponding fields
  DataRow2 clone({
    LocalKey? key,
    bool? selected,
    ValueChanged<bool?>? onSelectChanged,
    MaterialStateProperty<Color?>? color,
    Decoration? decoration,
    List<DataCell>? cells,
    double? specificRowHeight,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureTapCallback? onSecondaryTap,
    GestureTapDownCallback? onSecondaryTapDown,
  }) {
    return DataRow2(
      key: key ?? this.key,
      selected: selected ?? this.selected,
      onSelectChanged: onSelectChanged ?? this.onSelectChanged,
      color: color ?? this.color,
      decoration: decoration ?? this.decoration,
      cells: cells ?? this.cells,
      specificRowHeight: specificRowHeight ?? this.specificRowHeight,
      onTap: onTap ?? this.onTap,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onSecondaryTap: onSecondaryTap ?? this.onSecondaryTap,
      onSecondaryTapDown: onSecondaryTapDown ?? this.onSecondaryTapDown,
    );
  }

  /// Decoration to nbe applied to the given row. When applied, it [DataTable2.dividerThickness]
  /// won't take effect
  final Decoration? decoration;

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
    this.dataRowHeight,
    super.dataTextStyle,
    super.headingRowColor,
    this.fixedColumnsColor,
    this.fixedCornerColor,
    super.headingRowHeight,
    super.headingTextStyle,
    this.headingCheckboxTheme,
    this.datarowCheckboxTheme,
    super.horizontalMargin,
    super.checkboxHorizontalMargin,
    this.checkboxAlignment = Alignment.center,
    this.bottomMargin,
    super.columnSpacing,
    this.showHeadingCheckBox = true,
    super.showCheckboxColumn = true,
    super.showBottomBorder = false,
    super.dividerThickness,
    super.clipBehavior,
    this.minWidth,
    this.scrollController,
    this.horizontalScrollController,
    this.isVerticalScrollBarVisible,
    this.isHorizontalScrollBarVisible,
    this.empty,
    this.border,
    this.smRatio = 0.67,
    this.fixedTopRows = 1,
    this.fixedLeftColumns = 0,
    this.lmRatio = 1.2,
    this.sortArrowAnimationDuration = const Duration(milliseconds: 150),
    this.sortArrowIcon = Icons.arrow_upward,
    this.sortArrowBuilder,
    this.headingRowDecoration,
    required super.rows,
  })  : assert(fixedLeftColumns >= 0),
        assert(fixedTopRows >= 0);

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

  /// When changing sort direction an arrow icon in the header is rotated clockwise.
  /// The value defines the duration of the rotation animation.
  /// If not set, the default animation duration is 150 ms.
  final Duration sortArrowAnimationDuration;

  /// Icon to be displayed when sorting is applied to a column.
  /// If not set, the default icon is [Icons.arrow_upward].
  /// When set always overrides/preceeds default arrow icons.
  final IconData sortArrowIcon;

  /// A builder for the sort arrow widget. Can be used in combination with [sortArrowAlwaysVisible] for a custom
  /// sort arrow behavior. If this is used [sortArrowIcon], [sortArrowAnimationDuration] will be ignored.
  final Widget? Function(bool ascending, bool sorted)? sortArrowBuilder;

  /// If set, the table will stop shrinking below the threshold and provide
  /// horizontal scrolling. Useful for the cases with narrow screens (e.g. portrait phone orientation)
  /// and lots of columns (that get messed with little space)
  final double? minWidth;

  /// Overrides theme of the checkbox that is displayed in the leftmost corner
  /// of the heading (should checkboxes be enabled)
  final CheckboxThemeData? headingCheckboxTheme;

  /// Alignment of the checkbox if it is displayed
  /// Defaults to the [Alignment.center]
  final Alignment checkboxAlignment;

  /// Whether to display heading checkbox or not if the checkbox column is present. Defaults to true.
  /// Also check [DataTable.showCheckboxColumn] for details
  /// on how to control the checkbox column visibility
  final bool showHeadingCheckBox;

  /// Overrides theme of the checkbox that is displayed in the checkbox column
  /// in each data row (should checkboxes be enabled)
  final CheckboxThemeData? datarowCheckboxTheme;

  /// If set the table will have empty space added after the the last row and allow scroll the
  /// core of the table higher (e.g. if you would like to have iOS navigation UI at the bottom overlapping the table and
  /// have the ability to slightly scroll up the bototm row to avoid the obstruction)
  final double? bottomMargin;

  /// Overrides default [BoxDecoration](bottom border) applied to heading row.
  /// When both [headerRowColor] and this porperty are provided:
  /// - [headingRowDecoration] takes precedence if there're 0 or 1 fixed rows
  /// - [headerRowColor] is applied to fixed top forws starting from the second
  /// When there're both fixed top rows and fixed left columns with [fixedCornerColor] provided,
  /// this decoration overrides top left cornner cell color.
  final BoxDecoration? headingRowDecoration;

  /// The height of each row (excluding the row that contains column headings).
  ///
  /// If null, [DataTableThemeData.dataRowMinHeight] is used. This value defaults
  /// to [kMinInteractiveDimension] to adhere to the Material Design
  /// specifications.
  ///
  /// Note that unlike stock [DataTable] from the SDK there's no capability to define min/max
  /// height of a row, corresponding properties are ingored. This is an implementation tradeoff
  /// making it possible to have performant sticky columns.
  @override
  final double? dataRowHeight;

  /// Exposes scroll controller of the SingleChildScrollView that makes data rows vertically scrollable
  final ScrollController? scrollController;

  /// Exposes scroll controller of the SingleChildScrollView that makes data rows horizontally scrollable
  final ScrollController? horizontalScrollController;

  /// Determines whether the vertical scroll bar is visible, for iOS takes value from scrollbarTheme when null
  final bool? isVerticalScrollBarVisible;

  /// Determines whether the horizontal scroll bar is visible, for iOS takes value from scrollbarTheme when null
  final bool? isHorizontalScrollBarVisible;

  /// Placeholder widget which is displayed whenever the data rows are empty.
  /// The widget will be displayed below column
  final Widget? empty;

  /// Set vertical and horizontal borders between cells, as well as outside borders around table.
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
  /// Note: to change background color of fixed data rows use [DataTable2.headingRowColor]
  final Color? fixedColumnsColor;

  /// Backgound color of the top left corner which is fixed whenere both [fixedTopRows]
  /// and [fixedLeftColumns] are greater than 0
  /// Note: unlike data rows which can change their colors depending on material state (e.g. selected, hovered)
  /// this color is static and doesn't repond to state change
  /// Note: to change background color of fixed data rows use [DataTable2.headingRowColor]
  final Color? fixedCornerColor;

  (double, double) getMinMaxRowHeight(DataTableThemeData dataTableTheme) {
    final double effectiveDataRowMinHeight = dataRowHeight ??
        dataTableTheme.dataRowMinHeight ??
        kMinInteractiveDimension;
    // Reverting min/max csupport to single row height value in order not to have troubles
    // with sticky column cells
    // https://github.com/maxim-saplin/data_table_2/issues/191
    // final double effectiveDataRowMaxHeight = dataRowMaxHeight ??
    //     dataTableTheme.dataRowMaxHeight ??
    //     dataTableTheme.dataRowMaxHeight ??
    //     kMinInteractiveDimension;

    return (effectiveDataRowMinHeight, effectiveDataRowMinHeight);
  }

  Widget _buildCheckbox(
      {required BuildContext context,
      required bool? checked,
      required VoidCallback? onRowTap,
      required ValueChanged<bool?>? onCheckboxChanged,
      required MaterialStateProperty<Color?>? overlayColor,
      required CheckboxThemeData? checkboxTheme,
      required bool tristate,
      required double? rowHeight}) {
    final DataTableThemeData dataTableTheme = DataTableTheme.of(context);

    final double effectiveHorizontalMargin = horizontalMargin ??
        dataTableTheme.horizontalMargin ??
        _horizontalMargin;

    final (effectiveDataRowMinHeight, effectiveDataRowMaxHeight) =
        getMinMaxRowHeight(dataTableTheme);

    Widget wrapInContainer(Widget child) => Container(
        alignment: checkboxAlignment,
        constraints: BoxConstraints(
            minHeight: rowHeight ?? effectiveDataRowMinHeight,
            maxHeight: rowHeight ?? effectiveDataRowMaxHeight),
        padding: EdgeInsetsDirectional.only(
          start: checkboxHorizontalMargin ?? effectiveHorizontalMargin,
          end: (checkboxHorizontalMargin ?? effectiveHorizontalMargin) / 2.0,
        ),
        child: child);

    Widget contents = Semantics(
      container: true,
      child: wrapInContainer(
        Theme(
            data: ThemeData(checkboxTheme: checkboxTheme),
            child: Checkbox(
              value: checked,
              onChanged: onCheckboxChanged,
              tristate: tristate,
            )),
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

  Widget _buildHeadingCell(
      {required BuildContext context,
      required EdgeInsetsGeometry padding,
      required Widget label,
      required String? tooltip,
      required bool numeric,
      required VoidCallback? onSort,
      required bool sorted,
      required bool ascending,
      required double effectiveHeadingRowHeight,
      required MaterialStateProperty<Color?>? overlayColor}) {
    final ThemeData themeData = Theme.of(context);

    var customArrows =
        sortArrowBuilder != null ? sortArrowBuilder!(ascending, sorted) : null;
    label = Row(
      textDirection: numeric ? TextDirection.rtl : null,
      children: <Widget>[
        Flexible(child: label),
        if (onSort != null) ...<Widget>[
          customArrows ??
              _SortArrow(
                visible: sorted,
                up: sorted ? ascending : null,
                duration: sortArrowAnimationDuration,
                sortArrowIcon: sortArrowIcon,
              ),
          const SizedBox(width: _sortArrowPadding),
        ],
      ],
    );

    final TextStyle effectiveHeadingTextStyle = headingTextStyle ??
        themeData.dataTableTheme.headingTextStyle ??
        themeData.textTheme.titleSmall!;

    label = Container(
      padding: padding,
      height: effectiveHeadingRowHeight,
      alignment:
          numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: AnimatedDefaultTextStyle(
        style: effectiveHeadingTextStyle,
        softWrap: false,
        duration: sortArrowAnimationDuration,
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
    return label;
  }

  Widget _buildDataCell(
      {required BuildContext context,
      required EdgeInsetsGeometry padding,
      required double? specificRowHeight,
      required Widget label,
      required bool numeric,
      required bool placeholder,
      required bool showEditIcon,
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
      required MaterialStateProperty<Color?>? overlayColor}) {
    final ThemeData themeData = Theme.of(context);
    final DataTableThemeData dataTableTheme = DataTableTheme.of(context);

    if (showEditIcon) {
      const Widget icon = Icon(Icons.edit, size: 18.0);
      label = Expanded(child: label);
      label = Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[label, icon],
      );
    }

    final TextStyle effectiveDataTextStyle = dataTextStyle ??
        dataTableTheme.dataTextStyle ??
        themeData.dataTableTheme.dataTextStyle ??
        themeData.textTheme.bodyMedium!;

    final (effectiveDataRowMinHeight, effectiveDataRowMaxHeight) =
        getMinMaxRowHeight(dataTableTheme);

    label = Container(
      padding: padding,
      constraints: BoxConstraints(
          minHeight: specificRowHeight ?? effectiveDataRowMinHeight,
          maxHeight: specificRowHeight ?? effectiveDataRowMaxHeight),
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

    // Wrap label with InkResponse if there're cell or row level tap events
    if (onTap != null ||
        onDoubleTap != null ||
        onLongPress != null ||
        onTapDown != null ||
        onTapCancel != null) {
      // cell level
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
        // Also add row level events to cells
        onSecondaryTap: onRowSecondaryTap,
        onSecondaryTapDown: onRowSecondaryTapDown,
        overlayColor: overlayColor,
        child: label,
      );
    } else if (onSelectChanged != null ||
        onRowTap != null ||
        onRowDoubleTap != null ||
        onRowLongPress != null ||
        onRowSecondaryTap != null ||
        onRowSecondaryTapDown != null) {
      // row level
      label = TableRowInkWell(
        onTap: onRowTap ?? onSelectChanged,
        onDoubleTap: onRowDoubleTap,
        onLongPress: onRowLongPress,
        onSecondaryTap: onRowSecondaryTap,
        onSecondaryTapDown: onRowSecondaryTapDown,
        overlayColor: overlayColor,
        child: label,
      );
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
                    _buildHeadingRow(
                        context,
                        theme,
                        fixedColumnsColor != null
                            ? MaterialStatePropertyAll(fixedColumnsColor)
                            : effectiveHeadingRowColor,
                        actualFixedColumns),
                    ..._buildTableRows(
                        anyRowSelectable,
                        fixedColumnsColor != null
                            ? MaterialStatePropertyAll(fixedColumnsColor)
                            : effectiveDataRowColor,
                        context,
                        theme,
                        actualFixedColumns,
                        defaultRowColor,
                        null,
                        0,
                        0,
                        true)
                  ]
                : _buildTableRows(
                    anyRowSelectable,
                    fixedColumnsColor != null
                        ? MaterialStatePropertyAll(fixedColumnsColor)
                        : effectiveDataRowColor,
                    context,
                    theme,
                    actualFixedColumns,
                    defaultRowColor,
                    null,
                    actualFixedRows - 1,
                    0,
                    true))
            : null;

    List<TableRow>? fixedRows = actualFixedRows > 0
        ? (actualFixedRows == 1
            ? [
                _buildHeadingRow(
                    context,
                    theme,
                    headingRowColor ?? effectiveHeadingRowColor,
                    tableColumnWidths.length - actualFixedColumns)
              ]
            : [
                _buildHeadingRow(
                    context,
                    theme,
                    headingRowColor ?? effectiveHeadingRowColor,
                    tableColumnWidths.length - actualFixedColumns),
                ..._buildTableRows(
                    anyRowSelectable,
                    headingRowColor ?? effectiveDataRowColor,
                    context,
                    theme,
                    tableColumnWidths.length - actualFixedColumns,
                    defaultRowColor,
                    null,
                    0,
                    actualFixedRows - 1,
                    true)
              ])
        : null;

    List<TableRow>? fixedCornerRows =
        actualFixedColumns > 0 && actualFixedRows > 0
            ? (actualFixedRows == 1
                ? [
                    _buildHeadingRow(
                        context,
                        theme,
                        fixedCornerColor != null
                            ? MaterialStatePropertyAll(fixedCornerColor)
                            : effectiveHeadingRowColor,
                        actualFixedColumns)
                  ]
                : [
                    _buildHeadingRow(
                        context,
                        theme,
                        fixedCornerColor != null
                            ? MaterialStatePropertyAll(fixedCornerColor)
                            : effectiveHeadingRowColor,
                        actualFixedColumns),
                    ..._buildTableRows(
                        anyRowSelectable,
                        fixedCornerColor != null
                            ? MaterialStatePropertyAll(fixedCornerColor)
                            : effectiveDataRowColor,
                        context,
                        theme,
                        actualFixedColumns,
                        defaultRowColor,
                        null,
                        0,
                        actualFixedRows - 1,
                        true)
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
        effectiveDataRowColor);

    var builder = LayoutBuilder(builder: (context, constraints) {
      return SyncedScrollControllers(
          scrollController: scrollController,
          sc12toSc11Position: true,
          horizontalScrollController: horizontalScrollController,
          sc22toSc21Position: true,
          builder: (context, sc11, sc12, sc21, sc22) {
            var coreVerticalController = sc11;
            var leftColumnVerticalContoller = sc12;
            var coreHorizontalController = sc21;
            var fixedRowsHorizontalController = sc22;

            var displayColumnIndex = 0;

            // size & build checkboxes in heading and leftmost column
            // to be substracted from total width available to columns

            if (checkBoxWidth > 0) displayColumnIndex += 1;

            // size data columns
            final widths = _calculateDataColumnSizes(
                constraints, checkBoxWidth, effectiveHorizontalMargin);

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

              final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
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
                      ? () => column.onSort!(dataColumnIndex,
                          sortColumnIndex != dataColumnIndex || !sortAscending)
                      : null,
                  sorted: dataColumnIndex == sortColumnIndex,
                  ascending: sortAscending,
                  overlayColor: effectiveHeadingRowColor);

              headingRow.children[displayColumnIndex] =
                  h; // heading row alone is used to display table header should there be no data rows

              if (displayColumnIndex < actualFixedColumns) {
                if (actualFixedRows < 1) {
                  fixedColumnsRows![0].children[displayColumnIndex] = h;
                } else if (actualFixedRows > 0) {
                  fixedCornerRows![0].children[displayColumnIndex] = h;
                }
              } else {
                if (actualFixedRows < 1 && coreRows != null) {
                  coreRows[0]
                      .children[displayColumnIndex - actualFixedColumns] = h;
                } else if (actualFixedRows > 0) {
                  fixedRows![0]
                      .children[displayColumnIndex - actualFixedColumns] = h;
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

                var c = _buildDataCell(
                    context: context,
                    padding: padding,
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
                    onRowDoubleTap: row is DataRow2 ? row.onDoubleTap : null,
                    onRowLongPress: row.onLongPress,
                    onRowSecondaryTap:
                        row is DataRow2 ? row.onSecondaryTap : null,
                    onRowSecondaryTapDown:
                        row is DataRow2 ? row.onSecondaryTapDown : null,
                    onSelectChanged: row.onSelectChanged != null
                        ? () => row.onSelectChanged!(!row.selected)
                        : null,
                    overlayColor: row.color ?? effectiveDataRowColor);

                if (displayColumnIndex < actualFixedColumns) {
                  if (rowIndex + 1 < actualFixedRows) {
                    fixedCornerRows![rowIndex + 1]
                        .children[displayColumnIndex] = c;
                  } else {
                    fixedColumnsRows![rowIndex - skipRows]
                        .children[displayColumnIndex] = c;
                  }
                } else {
                  if (rowIndex + 1 < actualFixedRows) {
                    fixedRows![rowIndex + 1]
                        .children[displayColumnIndex - actualFixedColumns] = c;
                  } else {
                    coreRows![rowIndex - skipRows]
                        .children[displayColumnIndex - actualFixedColumns] = c;
                  }
                }

                rowIndex += 1;
              }
              displayColumnIndex += 1;
            }

            var widthsAsMap = tableColumnWidths.asMap();
            Map<int, TableColumnWidth>? leftWidthsAsMap = actualFixedColumns > 0
                ? tableColumnWidths.take(actualFixedColumns).toList().asMap()
                : null;
            Map<int, TableColumnWidth>? rightWidthsAsMap = actualFixedColumns >
                    0
                ? tableColumnWidths.skip(actualFixedColumns).toList().asMap()
                : null;

            bool isRowsEmpty(List<TableRow>? rows) {
              return rows == null || rows.isEmpty || rows[0].children.isEmpty;
            }

            var coreTable = Table(
                columnWidths:
                    actualFixedColumns > 0 ? rightWidthsAsMap : widthsAsMap,
                children: coreRows ?? [],
                border: border == null
                    ? null
                    : isRowsEmpty(fixedRows) && isRowsEmpty(fixedColumnsRows)
                        ? border
                        : !isRowsEmpty(fixedRows) &&
                                !isRowsEmpty(fixedColumnsRows)
                            ? TableBorder(
                                //top: border!.top,
                                //left: border!.left,
                                right: border!.right,
                                bottom: border!.bottom,
                                verticalInside: border!.verticalInside,
                                horizontalInside: border!.horizontalInside,
                                borderRadius: border!.borderRadius)
                            : isRowsEmpty(fixedRows)
                                ? TableBorder(
                                    top: border!.top,
                                    //left: border!.left,
                                    right: border!.right,
                                    bottom: border!.bottom,
                                    verticalInside: border!.verticalInside,
                                    horizontalInside: border!.horizontalInside,
                                    borderRadius: border!.borderRadius)
                                : TableBorder(
                                    //top: border!.top,
                                    left: border!.left,
                                    right: border!.right,
                                    bottom: border!.bottom,
                                    verticalInside: border!.verticalInside,
                                    horizontalInside: border!.horizontalInside,
                                    borderRadius: border!.borderRadius));

            Table? fixedRowsTabel;
            Table? fixedColumnsTable;
            Table? fixedTopLeftCornerTable;
            Widget? fixedColumnAndCornerCol;
            Widget? fixedRowsAndCoreCol;

            if (rows.isNotEmpty) {
              if (fixedRows != null &&
                  !isRowsEmpty(fixedRows) &&
                  actualFixedColumns <
                      columns.length + (showCheckboxColumn ? 1 : 0)) {
                fixedRowsTabel = Table(
                    columnWidths:
                        actualFixedColumns > 0 ? rightWidthsAsMap : widthsAsMap,
                    children: fixedRows,
                    border: border == null
                        ? null
                        : isRowsEmpty(fixedCornerRows)
                            ? border
                            : TableBorder(
                                top: border!.top,
                                //left: border!.left,
                                right: border!.right,
                                bottom: border!.bottom,
                                verticalInside: border!.verticalInside,
                                horizontalInside: border!.horizontalInside,
                                borderRadius: border!.borderRadius));
              }

              if (fixedColumnsRows != null && !isRowsEmpty(fixedColumnsRows)) {
                fixedColumnsTable = Table(
                    columnWidths: leftWidthsAsMap,
                    children: fixedColumnsRows,
                    border: border == null
                        ? null
                        : isRowsEmpty(fixedCornerRows)
                            ? border
                            : TableBorder(
                                //top: border!.top,
                                left: border!.left,
                                right: border!.right,
                                bottom: border!.bottom,
                                verticalInside: border!.verticalInside,
                                horizontalInside: border!.horizontalInside,
                                borderRadius: border!.borderRadius));
              }

              if (fixedCornerRows != null && !isRowsEmpty(fixedCornerRows)) {
                fixedTopLeftCornerTable = Table(
                    columnWidths: leftWidthsAsMap,
                    children: fixedCornerRows,
                    border: border);
              }

              Widget addBottomMargin(Table t) =>
                  bottomMargin != null && bottomMargin! > 0
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [t, SizedBox(height: bottomMargin!)])
                      : t;

              var scrollBarTheme = Theme.of(context).scrollbarTheme;
              // flutter/lib/src/material/scrollbar.dart, scrollbar decides whther to create  Cupertino or Material scrollbar, Cupertino ignores themes
              var isiOS = Theme.of(context).platform == TargetPlatform.iOS;

              // For iOS/Cupertino scrollbar
              fixedRowsAndCoreCol = Scrollbar(
                  thumbVisibility: isHorizontalScrollBarVisible ??
                      (isiOS
                          ? scrollBarTheme.thumbVisibility
                              ?.resolve({MaterialState.hovered})
                          : null),
                  thickness: (isiOS
                      ? scrollBarTheme.thickness
                          ?.resolve({MaterialState.hovered})
                      : null),
                  controller: coreHorizontalController,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                        child: Scrollbar(
                            thumbVisibility: isVerticalScrollBarVisible ??
                                (isiOS
                                    ? scrollBarTheme.thumbVisibility
                                        ?.resolve({MaterialState.hovered})
                                    : null),
                            thickness: (isiOS
                                ? scrollBarTheme.thickness
                                    ?.resolve({MaterialState.hovered})
                                : null),
                            controller: coreVerticalController,
                            child: SingleChildScrollView(
                                controller: coreVerticalController,
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                    controller: coreHorizontalController,
                                    scrollDirection: Axis.horizontal,
                                    child: addBottomMargin(coreTable)))))
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
                                    controller: leftColumnVerticalContoller,
                                    scrollDirection: Axis.vertical,
                                    child: addBottomMargin(fixedColumnsTable))))
                    ]);
            }

            var completeWidget = Container(
                decoration: decoration ?? theme.dataTableTheme.decoration,
                child: Material(
                    type: MaterialType.transparency,
                    borderRadius: border?.borderRadius,
                    clipBehavior: clipBehavior,
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
                          )));

            return completeWidget;
          });
    });

    sw.stop();

    if (dataTableShowLogs && kDebugMode) {
      debugPrint('DataTable2 built: ${sw.elapsedMilliseconds}ms');
    }

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
      MaterialStateProperty<Color?>? effectiveDataRowColor) {
    double checkBoxWidth = 0;

    if (displayCheckboxColumn) {
      checkBoxWidth = effectiveHorizontalMargin +
          Checkbox.width +
          effectiveHorizontalMargin / 2.0;
      tableColumns[0] = FixedColumnWidth(checkBoxWidth);

      // Create heading twice, in the heading row used as back-up for the case of no data and any of the xxx_rows table

      headingRow.children[0] = showHeadingCheckBox
          ? _buildCheckbox(
              context: context,
              checked: someChecked ? null : allChecked,
              onRowTap: null,
              onCheckboxChanged: (bool? checked) =>
                  _handleSelectAll(checked, someChecked),
              overlayColor: null,
              checkboxTheme: headingCheckboxTheme,
              tristate: true,
              rowHeight: headingHeight)
          : SizedBox(height: headingHeight,);

      if (fixedCornerRows != null) {
        fixedCornerRows[0].children[0] = headingRow.children[0];
      } else if (fixedColumnRows != null) {
        fixedColumnRows[0].children[0] = headingRow.children[0];
      } else if (fixedRows != null) {
        fixedRows[0].children[0] = headingRow.children[0];
      } else {
        coreRows![0].children[0] = headingRow.children[0];
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
              if (row is DataRow2 && row.onTap != null) {
                row.onTap?.call();
              } else {
                row.onSelectChanged?.call(!row.selected);
              }
            },
            onCheckboxChanged: row.onSelectChanged,
            overlayColor: row.color ?? effectiveDataRowColor,
            checkboxTheme: datarowCheckboxTheme,
            tristate: false,
            rowHeight: rows[rowIndex] is DataRow2
                ? (rows[rowIndex] as DataRow2).specificRowHeight
                : null);

        if (fixedCornerRows != null && rowIndex < fixedCornerRows.length - 1) {
          fixedCornerRows[rowIndex + 1].children[0] = x;
        } else if (fixedColumnRows != null) {
          fixedColumnRows[rowIndex - skipRows].children[0] = x;
        } else if (fixedRows != null && rowIndex < fixedRows.length - 1) {
          fixedRows[rowIndex + 1].children[0] = x;
        } else {
          coreRows![rowIndex - skipRows].children[0] = x;
        }

        rowIndex += 1;
      }
    }
    return checkBoxWidth;
  }

  List<double> _calculateDataColumnSizes(BoxConstraints constraints,
      double checkBoxWidth, double effectiveHorizontalMargin) {
    var totalColAvailableWidth = constraints.maxWidth;
    if (minWidth != null && totalColAvailableWidth < minWidth!) {
      totalColAvailableWidth = minWidth!;
    }

    // full margins are added to side column widths when no check box column is
    // present, half-margin added to first data column width is check box column
    // is present and full margin added to the right

    totalColAvailableWidth = totalColAvailableWidth -
        checkBoxWidth -
        effectiveHorizontalMargin -
        (checkBoxWidth > 0
            ? effectiveHorizontalMargin / 2
            : effectiveHorizontalMargin);

    var columnWidth = totalColAvailableWidth / columns.length;
    var totalColCalculatedWidth = 0.0;
    var totalFixedWidth = columns.fold<double>(
        0.0,
        (previousValue, element) =>
            previousValue +
            (element is DataColumn2 && element.fixedWidth != null
                ? element.fixedWidth!
                : 0.0));

    assert(totalFixedWidth < totalColAvailableWidth,
        "DataTable2, combined width of columns of fixed width is greater than availble parent width. Table will be clipped");

    totalColAvailableWidth =
        math.max(0.0, totalColAvailableWidth - totalFixedWidth);

    // adjust column sizes relative to S, M, L
    final widths = List<double>.generate(columns.length, (i) {
      var w = columnWidth;
      var column = columns[i];
      if (column is DataColumn2) {
        if (column.fixedWidth != null) {
          w = column.fixedWidth!;
        } else if (column.size == ColumnSize.S) {
          w *= smRatio;
        } else if (column.size == ColumnSize.L) {
          w *= lmRatio;
        }
      }

      // skip fixed width columns
      if (!(column is DataColumn2 && column.fixedWidth != null)) {
        totalColCalculatedWidth += w;
      }
      return w;
    });

    // scale columns to fit the total lemnght into available width

    var ratio = totalColAvailableWidth / totalColCalculatedWidth;
    for (var i = 0; i < widths.length; i++) {
      // skip fixed width column
      if (!(columns[i] is DataColumn2 &&
          (columns[i] as DataColumn2).fixedWidth != null)) {
        widths[i] *= ratio;
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
      int takeRows = 0,
      bool forceEffectiveDataRowColor = false]) {
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
          final Color? resolvedDataRowColor = (forceEffectiveDataRowColor
                  ? effectiveDataRowColor
                  : (rows[rowStartIndex + actualIndex].color ??
                      effectiveDataRowColor))
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

          Decoration? rowDecoration =
              rows[rowStartIndex + actualIndex] is DataRow2
                  ? (rows[rowStartIndex + actualIndex] as DataRow2).decoration
                  : null;

          return TableRow(
            key: rows[rowStartIndex + actualIndex].key,
            decoration: rowDecoration ??
                BoxDecoration(
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
      ).copyWith(
        color: headingRowDecoration?.color,
        image: headingRowDecoration?.image,
        border: headingRowDecoration?.border,
        borderRadius: headingRowDecoration?.borderRadius,
        boxShadow: headingRowDecoration?.boxShadow,
        gradient: headingRowDecoration?.gradient,
        backgroundBlendMode: headingRowDecoration?.backgroundBlendMode,
        shape: headingRowDecoration?.shape,
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
    required this.sortArrowIcon,
  });

  final bool visible;

  final bool? up;

  final Duration duration;

  final IconData sortArrowIcon;

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
        child: Icon(
          widget.sortArrowIcon,
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
      this.sc12toSc11Position = false,
      this.horizontalScrollController,
      this.sc22toSc21Position = false});

  /// One of the controllers (sc11) won't be created by this widget
  /// but rather use externally provided one
  final ScrollController? scrollController;

  /// One of the controllers (sc21) won't be created by this widget
  /// but rather use externally provided one
  final ScrollController? horizontalScrollController;

  /// Whether to set sc12 initial offset to the value from sc11
  final bool sc12toSc11Position;

  /// Whether to set sc22 initial offset to the value from sc21
  final bool sc22toSc21Position;

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
  ScrollController? _sc21;
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

    var horizontalOffset =
        _sc21 == null || _sc21!.positions.isEmpty ? 0.0 : _sc21!.offset;
    if (widget.horizontalScrollController != null) {
      _sc21 = widget.horizontalScrollController!;
      if (_sc21!.positions.isNotEmpty) {
        offset = _sc21!.offset;
      }
    } else {
      _sc21 = ScrollController();
    }

    _sc12 = ScrollController(
        initialScrollOffset: widget.sc12toSc11Position ? offset : 0.0);
    _sc22 = ScrollController(
        initialScrollOffset:
            widget.sc22toSc21Position ? horizontalOffset : 0.0);

    _syncScrollControllers(_sc11!, _sc12);
    _syncScrollControllers(_sc21!, _sc22);
  }

  void _disposeOrUnsubscribe() {
    if (widget.scrollController == _sc11) {
      _sc11?.removeListener(_listeners[0]);
    } else {
      _sc11?.dispose();
    }
    _sc12.dispose();

    if (widget.horizontalScrollController == _sc21) {
      _sc21?.removeListener(_listeners[0]);
    } else {
      _sc21?.dispose();
    }
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
      widget.builder(context, _sc11!, _sc12, _sc21!, _sc22);
}
