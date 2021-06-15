library data_table_plus;

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin - changes and modifications to original Flutter implementation of DataTable

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

double _smRatio = 0.67;
double _lmRatio = 1.2;

/// Small to Medium column width ratio, 0.67 default
double get smRatio => _smRatio;

/// Large to Medium column width ratio, 1.2 default
double get lmRatio => _lmRatio;

/// Use this method to change the default ratios of columns sizes/widths (see [ColumnSize])
void setColumnSizeRatios(double sm, double lm) {
  _smRatio = sm;
  _lmRatio = lm;
}

/// Extension of stock [DataColumn], adds the capability to set relative column
/// size via [size] property
@immutable
class DataColumnPlus extends DataColumn {
  /// Creates the configuration for a column of a [DataTablePlus].
  ///
  /// The [label] argument must not be null.
  const DataColumnPlus(
      {required Widget label,
      String? tooltip,
      bool numeric = false,
      Function(int, bool)? onSort})
      : super(label: label, tooltip: tooltip, numeric: numeric, onSort: onSort);
}

/// Extension of standard [DataRow], adds row level tap events. Also there're
/// onSecondaryTap and onSecondaryTapDown which are not available in DataCells and
/// which can be useful in Desktop settings when a reaction to the right click is required.
@immutable
class DataRowPlus extends DataRow {
  //DataRow2.fromDataRow(DataRow row) : this.cells = row.cells;

  /// Creates the configuration for a row of a [DataTablePlus].
  ///
  /// The [cells] argument must not be null.
  const DataRowPlus(
      {LocalKey? key,
      bool selected = false,
      ValueChanged<bool?>? onSelectChanged,
      MaterialStateProperty<Color?>? color,
      required List<DataCell> cells,
      this.onTap,
      this.onSecondaryTap,
      this.onSecondaryTapDown})
      : super(
            key: key,
            selected: selected,
            onSelectChanged: onSelectChanged,
            color: color,
            cells: cells);

  DataRowPlus.byIndex(
      {int? index,
      bool selected = false,
      ValueChanged<bool?>? onSelectChanged,
      MaterialStateProperty<Color?>? color,
      required List<DataCell> cells,
      this.onTap,
      this.onSecondaryTap,
      this.onSecondaryTapDown})
      : super.byIndex(
            index: index,
            selected: selected,
            onSelectChanged: onSelectChanged,
            color: color,
            cells: cells);

  /// Row tap handler
  // TODO add tests
  final VoidCallback? onTap;

  /// Row right click handler
  final VoidCallback? onSecondaryTap;

  /// Row right mouse down handler
  final GestureTapDownCallback? onSecondaryTapDown;
}

enum TypeCustomRow { ADD, REPLACE }

class CustomRow {
  int index;
  List<Widget> cells;
  TypeCustomRow typeCustomRow;

  /// A [Key] that uniquely identifies this row. This is used to
  /// ensure that if a row is added or removed, any stateful widgets
  /// related to this row (e.g. an in-progress checkbox animation)
  /// remain on the right row visually.
  ///
  /// If the table never changes once created, no key is necessary.
  final LocalKey? key;

  CustomRow(
      {required this.index,
      required this.cells,
      this.typeCustomRow = TypeCustomRow.REPLACE,
      this.key})
      : assert(index >= 0 || typeCustomRow != TypeCustomRow.REPLACE);
}

/// In-place replacement of standard [DataTable] widget, mimics it API.
/// Has the header row always fixed and core of the table (with data rows)
/// scrollable and stretching to max width/height of it's container.
/// By using [DataColumnPlus] instead of [DataColumn] it is possible to control
/// relative column sizes (setting them to S, M and L). [DataRowPlus] provides
/// row-level tap event handlers.
class DataTablePlus extends DataTable {
  DataTablePlus(
      {Key? key,
      required List<DataColumn> columns,
      int? sortColumnIndex,
      bool sortAscending = true,
      ValueSetter<bool?>? onSelectAll,
      Decoration? decoration,
      MaterialStateProperty<Color?>? dataRowColor,
      double? dataRowHeight,
      TextStyle? dataTextStyle,
      MaterialStateProperty<Color?>? headingRowColor,
      double? headingRowHeight,
      TextStyle? headingTextStyle,
      double? horizontalMargin,
      this.bottomMargin,
      double? columnSpacing,
      bool showCheckboxColumn = true,
      bool showBottomBorder = false,
      double? dividerThickness,
      this.scrollController,
      required List<DataRow> rows,
      this.tableColumnsWidth,
      this.customRows,
      this.showCheckboxSelectAll = true})
      : super(
            key: key,
            columns: columns,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
            onSelectAll: onSelectAll,
            decoration: decoration,
            dataRowColor: dataRowColor,
            dataRowHeight: dataRowHeight,
            dataTextStyle: dataTextStyle,
            headingRowColor: headingRowColor,
            headingRowHeight: headingRowHeight,
            headingTextStyle: headingTextStyle,
            horizontalMargin: horizontalMargin,
            columnSpacing: columnSpacing,
            showCheckboxColumn: showCheckboxColumn,
            showBottomBorder: showBottomBorder,
            dividerThickness: dividerThickness,
            rows: rows);

  static final LocalKey _headingRowKey = UniqueKey();

  void _handleSelectAll(bool? checked, bool someChecked) {
    // If some checkboxes are checked, all checkboxes are selected. Otherwise,
    // use the new checked value but default to false if it's null.
    final bool effectiveChecked = someChecked || (checked ?? false);
    if (onSelectAll != null) {
      onSelectAll!(effectiveChecked);
    } else {
      for (final DataRow row in rows) {
        if (row.onSelectChanged != null && row.selected != effectiveChecked)
          row.onSelectChanged!(effectiveChecked);
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

  /// If set the table will have empty space added after the the last row and allow scroll the
  /// core of the table higher (e.g. if you would like to have iOS navigation UI at the bottom overlapping the table and
  /// have the ability to slightly scroll up the bototm row to avoid the obstruction)
  final double? bottomMargin;

  /// Exposes scroll controller of the SingleChildScrollView that makes data rows horizontally scrollable
  final ScrollController? scrollController;

  final Map<int, TableColumnWidth>? tableColumnsWidth;

  final List<CustomRow>? customRows;

  final bool showCheckboxSelectAll;

  Widget _buildCheckbox({
    required BuildContext context,
    required bool? checked,
    required VoidCallback? onRowTap,
    required ValueChanged<bool?>? onCheckboxChanged,
    required MaterialStateProperty<Color?>? overlayColor,
    required bool tristate,
  }) {
    final ThemeData themeData = Theme.of(context);
    Widget contents = Semantics(
      container: true,
      child: Center(
        child: Checkbox(
            activeColor: themeData.colorScheme.primary,
            checkColor: themeData.colorScheme.onPrimary,
            value: checked,
            onChanged: onCheckboxChanged,
            tristate: tristate),
      ),
    );
    if (onRowTap != null) {
      contents = TableRowInkWell(
        onTap: onRowTap,
        child: contents,
        overlayColor: overlayColor,
      );
    }
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: contents,
    );
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
    required MaterialStateProperty<Color?>? overlayColor,
  }) {
    final ThemeData themeData = Theme.of(context);
    label = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      textDirection: numeric ? TextDirection.rtl : null,
      children: <Widget>[
        Flexible(child: label),
        if (onSort != null) ...<Widget>[
          const SizedBox(width: _sortArrowPadding),
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
    final double effectiveHeadingRowHeight = headingRowHeight ??
        themeData.dataTableTheme.headingRowHeight ??
        _headingRowHeight;
    label = Container(
      padding: padding,
      height: effectiveHeadingRowHeight,
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
    return label;
  }

  Widget _buildDataCell({
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required Widget label,
    required bool numeric,
    required bool placeholder,
    required bool showEditIcon,
    required VoidCallback? onTap,
    required VoidCallback? onRowTap,
    required VoidCallback? onRowSecondaryTap,
    required GestureTapDownCallback? onRowSecondaryTapDown,
    required VoidCallback? onSelectChanged,
    required MaterialStateProperty<Color?>? overlayColor,
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
    final double effectiveDataRowHeight = dataRowHeight ??
        themeData.dataTableTheme.dataRowHeight ??
        kMinInteractiveDimension;
    label = Container(
      padding: padding,
      height: effectiveDataRowHeight,
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
    if (onTap != null) {
      label = InkWell(
        onTap: onTap,
        child: label,
        overlayColor: overlayColor,
      );
    } else if (onSelectChanged != null) {
      label = GestureDetector(
        child: TableRowInkWell(
            child: label,
            overlayColor: overlayColor,
            onTap: onRowTap == null
                ? onSelectChanged
                : () {
                    onRowTap();
                    onSelectChanged();
                  }),
        onSecondaryTap: onRowSecondaryTap,
        onSecondaryTapDown: onRowSecondaryTapDown,
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

    final ThemeData theme = Theme.of(context);
    final MaterialStateProperty<Color?>? effectiveHeadingRowColor =
        headingRowColor ?? theme.dataTableTheme.headingRowColor;
    final MaterialStateProperty<Color?>? effectiveDataRowColor =
        dataRowColor ?? theme.dataTableTheme.dataRowColor;
    final MaterialStateProperty<Color?> defaultRowColor =
        MaterialStateProperty.resolveWith(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected))
          return theme.colorScheme.primary.withOpacity(0.08);
        return null;
      },
    );
    final bool anyRowSelectable =
        rows.any((DataRow row) => row.onSelectChanged != null);
    final bool displayCheckboxColumn = showCheckboxColumn && anyRowSelectable;
    final Iterable<DataRow> rowsWithCheckbox = displayCheckboxColumn
        ? rows.where((DataRow row) => row.onSelectChanged != null)
        : <DataRowPlus>[];
    final Iterable<DataRow> rowsChecked =
        rowsWithCheckbox.where((DataRow row) => row.selected);
    final bool allChecked =
        displayCheckboxColumn && rowsChecked.length == rowsWithCheckbox.length;
    final bool anyChecked = displayCheckboxColumn && rowsChecked.isNotEmpty;
    final bool someChecked = anyChecked && !allChecked;
    final double effectiveHorizontalMargin = horizontalMargin ??
        theme.dataTableTheme.horizontalMargin ??
        _horizontalMargin;
    final double effectiveColumnSpacing =
        columnSpacing ?? theme.dataTableTheme.columnSpacing ?? _columnSpacing;
    final ThemeData themeData = Theme.of(context);
    final double effectiveCheckboxHorizontalMarginStart =
        checkboxHorizontalMargin ??
            themeData.dataTableTheme.checkboxHorizontalMargin ??
            effectiveHorizontalMargin;
    final double effectiveCheckboxHorizontalMarginEnd =
        checkboxHorizontalMargin ??
            themeData.dataTableTheme.checkboxHorizontalMargin ??
            effectiveHorizontalMargin / 2.0;

    late List<TableColumnWidth> effectiveTableColumns = [];
    List.generate(columns.length + (displayCheckboxColumn ? 1 : 0), (index) {
      if (tableColumnsWidth != null && tableColumnsWidth![index] != null) {
        effectiveTableColumns.add(tableColumnsWidth![index]!);
      } else {
        effectiveTableColumns.add(const _NullTableColumnWidth());
      }
    });
    List<TableRow> tableRows = [];
    bool useDefaultHeader = true;

    /// Add custom lines pre-header
    if (customRows != null) {
      customRows!.forEach((element) {
        if (element.index < 0 ||
            (element.index == 0 &&
                element.typeCustomRow == TypeCustomRow.REPLACE)) {
          tableRows.add(TableRow(
              children:
                  List<Widget>.generate(effectiveTableColumns.length, (index) {
            if (index == 0 && displayCheckboxColumn) {
              return SizedBox();
            }
            return const _NullWidget();
          })));
        }
        if (element.index == 0 &&
            element.typeCustomRow == TypeCustomRow.REPLACE) {
          /// Header
          useDefaultHeader = false;
        }
      });
    }

    int currentQtdCustomLines = 0;
    for (int rowIndex = 0;
        rowIndex <

            /// Add +1 Header
            (rows.length + (useDefaultHeader ? 1 : 0)) +
                (customRows
                        ?.where((element) =>
                            element.index > 0 &&
                            element.typeCustomRow == TypeCustomRow.ADD)
                        .length ??
                    0);
        rowIndex++) {
      int indexCustomRow =
          customRows?.indexWhere((element) => element.index == rowIndex) ?? -1;
      if (indexCustomRow > -1) {
        tableRows.add(TableRow(
            key: customRows![indexCustomRow].key,
            children:
                List<Widget>.generate(effectiveTableColumns.length, (index) {
              if (index == 0 && displayCheckboxColumn) {
                return SizedBox();
              }
              return const _NullWidget();
            })));
        if (customRows![indexCustomRow].typeCustomRow ==
            TypeCustomRow.REPLACE) {
          continue;
        } else {
          //currentQtdCustomLines++;
        }
      }
      int index = rowIndex - (currentQtdCustomLines) - 1;
      if (index == -1) {
        /// Header

        final Color? resolvedHeadingRowColor =
            effectiveHeadingRowColor?.resolve(<MaterialState>{});
        final Color? rowColor = resolvedHeadingRowColor;

        final BorderSide borderSide = Divider.createBorderSide(
          context,
          width: dividerThickness ??
              theme.dataTableTheme.dividerThickness ??
              _dividerThickness,
        );
        final Border? border =
            showBottomBorder ? Border(bottom: borderSide) : null;

        tableRows.add(
          TableRow(
              key: _headingRowKey,
              decoration: BoxDecoration(
                border: border,
                color: rowColor,
              ),
              children: List<Widget>.filled(
                  effectiveTableColumns.length, const _NullWidget())),
        );
      } else if (index < rows.length) {
        final bool isSelected = rows[index].selected;
        final bool isDisabled =
            anyRowSelectable && rows[index].onSelectChanged == null;
        final Set<MaterialState> states = <MaterialState>{
          if (isSelected) MaterialState.selected,
          if (isDisabled) MaterialState.disabled,
        };
        final Color? resolvedDataRowColor =
            (rows[index].color ?? effectiveDataRowColor)?.resolve(states);

        final Color? rowColor = resolvedDataRowColor;
        final BorderSide borderSide = Divider.createBorderSide(
          context,
          width: dividerThickness ??
              theme.dataTableTheme.dividerThickness ??
              _dividerThickness,
        );
        final Border? border = showBottomBorder
            ? Border(bottom: borderSide)
            : index == 0
                ? null
                : Border(top: borderSide);

        tableRows.add(
          TableRow(
              key: rows[index].key,
              decoration: BoxDecoration(
                border: border,
                color: rowColor ?? defaultRowColor.resolve(states),
              ),
              children: List<Widget>.filled(
                  effectiveTableColumns.length, const _NullWidget())),
        );
        if (displayCheckboxColumn) {
          tableRows.last.children![0] = _buildCheckbox(
            context: context,
            checked: rows[index].selected,
            onRowTap: () =>
                rows[index].onSelectChanged?.call(!rows[index].selected),
            onCheckboxChanged: rows[index].onSelectChanged,
            overlayColor: rows[index].color ?? effectiveDataRowColor,
            tristate: false,
          );
        }
      }
    }

    int rowIndex;

    int displayColumnIndex = 0;
    if (displayCheckboxColumn) {
      effectiveTableColumns[0] = FixedColumnWidth(
          effectiveCheckboxHorizontalMarginStart +
              Checkbox.width +
              effectiveCheckboxHorizontalMarginEnd);
      int headerIndex = 0;
      if (customRows != null) {
        headerIndex = customRows!
            .where((element) =>
                element.index <= 0 &&
                element.typeCustomRow == TypeCustomRow.ADD)
            .length;
      }
      if (showCheckboxSelectAll) {
        tableRows[headerIndex].children![0] = _buildCheckbox(
          context: context,
          checked: someChecked ? null : allChecked,
          onRowTap: null,
          onCheckboxChanged: (bool? checked) =>
              _handleSelectAll(checked, someChecked),
          overlayColor: null,
          tristate: true,
        );
      } else {
        tableRows[headerIndex].children![0] = SizedBox();
      }
      displayColumnIndex += 1;
    }

    for (int dataColumnIndex = 0;
        dataColumnIndex < columns.length;
        dataColumnIndex += 1) {
      final DataColumn column = columns[dataColumnIndex];

      final double paddingStart;
      if (dataColumnIndex == 0 &&
          displayCheckboxColumn &&
          checkboxHorizontalMargin != null) {
        paddingStart = effectiveHorizontalMargin;
      } else if (dataColumnIndex == 0 && displayCheckboxColumn) {
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

      if (effectiveTableColumns[displayColumnIndex] is _NullTableColumnWidth) {
        if (displayColumnIndex == columns.length - 1) {
          effectiveTableColumns[displayColumnIndex] =
              (const IntrinsicColumnWidth(flex: 1.0));
        } else {
          effectiveTableColumns[displayColumnIndex] =
              (const IntrinsicColumnWidth());
        }
      }
      currentQtdCustomLines = 0;
      rowIndex = 0;

      int qtdPreHeaderCustomLines = 0;
      if (customRows != null) {
        for (CustomRow customRow
            in customRows!.where((element) => element.index <= 0)) {
          tableRows[rowIndex].children![displayColumnIndex] =
              customRow.cells[displayColumnIndex];
          if (customRow.index < 0 ||
              customRow.typeCustomRow == TypeCustomRow.ADD) {
            qtdPreHeaderCustomLines++;
          }
          //currentQtdCustomLines++;

          rowIndex++;
        }
      }
      if (useDefaultHeader) {
        tableRows[rowIndex].children![displayColumnIndex] = _buildHeadingCell(
          context: context,
          padding: padding,
          label: column.label,
          tooltip: column.tooltip,
          numeric: column.numeric,
          onSort: column.onSort != null
              ? () => column.onSort!(dataColumnIndex,
                  sortColumnIndex != dataColumnIndex || !sortAscending)
              : null,
          sorted: dataColumnIndex == sortColumnIndex,
          ascending: sortAscending,
          overlayColor: effectiveHeadingRowColor,
        );
        rowIndex++;
      }

      for (;
          rowIndex <
              (rows.length + 1) +
                  (customRows
                          ?.where((element) =>
                              element.typeCustomRow == TypeCustomRow.ADD)
                          .length ??
                      0);
          rowIndex++) {
        int indexCustomRow =
            customRows?.indexWhere((element) => element.index == rowIndex) ??
                -1;
        if (indexCustomRow > -1) {
          tableRows[rowIndex + currentQtdCustomLines]
                  .children![displayColumnIndex] =
              customRows![indexCustomRow].cells[dataColumnIndex];
          if (customRows![indexCustomRow].typeCustomRow ==
              TypeCustomRow.REPLACE) {
            continue;
          } else {
            currentQtdCustomLines++;
          }
        }

        /// Checks if the index exists in the list of lines.
        /// It may not exist as the for cycles through the sum of the lines with the custom ones.
        if (rows.length > ((rowIndex - 1) - qtdPreHeaderCustomLines)) {
          final row = rows[(rowIndex - 1) - qtdPreHeaderCustomLines];

          final DataCell cell = row.cells[dataColumnIndex];

          tableRows[rowIndex + currentQtdCustomLines]
              .children![displayColumnIndex] = _buildDataCell(
            onRowTap: row is DataRowPlus ? row.onTap : null,
            onRowSecondaryTap: row is DataRowPlus ? row.onSecondaryTap : null,
            onRowSecondaryTapDown:
                row is DataRowPlus ? row.onSecondaryTapDown : null,
            onSelectChanged: () => row.onSelectChanged != null
                ? row.onSelectChanged!(!row.selected)
                : null,
            context: context,
            padding: padding,
            label: cell.child,
            numeric: column.numeric,
            placeholder: cell.placeholder,
            showEditIcon: cell.showEditIcon,
            onTap: cell.onTap,
            overlayColor: row.color ?? effectiveDataRowColor,
          );
        }
      }
      displayColumnIndex += 1;
    }

    return Container(
      decoration: decoration ?? theme.dataTableTheme.decoration,
      child: Material(
        type: MaterialType.transparency,
        child: Table(
          columnWidths: effectiveTableColumns.asMap(),
          children: tableRows,
        ),
      ),
    );
  }
}

class _SortArrow extends StatefulWidget {
  const _SortArrow({
    Key? key,
    required this.visible,
    required this.up,
    required this.duration,
  }) : super(key: key);

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
