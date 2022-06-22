part of 'data_table_2.dart';

// TODO: Consider how resizable table should behave when being supplied with DataTable/DataTable2 - should they allow resizing by defualt? Or only when ResizableDataColumn2 is provided resizing should be avaialble

class ResizableDataColumn2 extends DataColumn2 {
  const ResizableDataColumn2(
      {required super.label,
      super.tooltip,
      super.numeric = false,
      super.onSort,
      super.size = ColumnSize.M,
      super.fixedWidth,
      this.isResizable = true});

  /// If you want to disable resizing for a given column, set this field to `false`
  final bool isResizable;
}

class _DataTable2 extends DataTable2 {
  _DataTable2({
    required super.columns,
    super.sortColumnIndex,
    super.sortAscending = true,
    super.onSelectAll,
    super.decoration,
    super.dataRowHeight,
    super.headingRowColor,
    super.headingRowHeight,
    super.horizontalMargin,
    super.checkboxHorizontalMargin,
    super.bottomMargin,
    super.columnSpacing,
    super.showCheckboxColumn = true,
    super.showBottomBorder = false,
    super.dividerThickness,
    super.minWidth,
    super.scrollController,
    super.empty,
    super.border,
    super.smRatio = 0.67,
    super.lmRatio = 1.2,
    required super.rows,
    super.columnDataController,
    required this.buildResizeColumnWidget,
  });

  /// Called to build the resizing column widget
  final Widget Function(DataColumn2, double) buildResizeColumnWidget;

  @override
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
  }) {
    label = super._buildHeadingCell(
        context: context,
        padding: padding,
        label: label,
        tooltip: tooltip,
        numeric: numeric,
        onSort: onSort,
        sorted: sorted,
        ascending: ascending,
        effectiveHeadingRowHeight: effectiveHeadingRowHeight,
        overlayColor: overlayColor);
    if (column != null &&
        column is ResizableDataColumn2 &&
        column.isResizable) {
      label = Row(
        children: [
          Expanded(child: label),
          buildResizeColumnWidget(
            column,
            effectiveHeadingRowHeight,
          ),
        ],
      );
    }
    return label;
  }
}

// TODO - conclude on resizing the table and it's width.
// Current implementation assumes there're 2 options:
// 1) Stretch to fill the container, size all columns inside to the avaialble with
// 2) Stretch and fill container, should the available width be less then specified minWidth - size the columns to minwidth and show horizontal scrollbar
// IMO, for the resizable table it makes sens to have 3rd option, let the table change total width when resizing columns
class StatefulDataTable2 extends StatefulWidget {
  const StatefulDataTable2({
    Key? key,
    this.lockTableWidth = true,
    required this.columns,
    this.sortColumnIndex,
    required this.sortAscending,
    this.onSelectAll,
    this.decoration,
    this.dataRowHeight,
    this.headingRowColor,
    this.headingRowHeight,
    this.horizontalMargin,
    this.checkboxHorizontalMargin,
    required this.columnSpacing,
    this.showCheckboxColumn = true,
    this.showBottomBorder = false,
    required this.rows,
    this.minWidth,
    this.scrollController,
    this.empty,
    this.border,
    this.smRatio = 0.67,
    this.lmRatio = 1.2,
    this.dividerThickness,
    this.bottomMargin,
    this.columnResizingParameters,
  }) : super(key: key);

  /// The configuration and labels for the columns in the table.
  final List<DataColumn> columns;

  /// The current primary sort key's column.
  ///
  /// See [DataTable.sortColumnIndex].
  final int? sortColumnIndex;

  /// Whether the column mentioned in [sortColumnIndex], if any, is sorted
  /// in ascending order.
  ///
  /// See [DataTable.sortAscending].
  final bool sortAscending;

  /// Invoked when the user selects or unselects every row, using the
  /// checkbox in the heading row.
  ///
  /// See [DataTable.onSelectAll].
  final ValueSetter<bool?>? onSelectAll;

  /// {@template flutter.material.dataTable.decoration}
  /// The background and border decoration for the table.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.decoration] is used. By default there is no
  /// decoration.
  final Decoration? decoration;

  /// The height of each row (excluding the row that contains column headings).
  ///
  /// This value is optional and defaults to kMinInteractiveDimension if not
  /// specified.
  final double? dataRowHeight;

  /// {@template flutter.material.dataTable.headingRowColor}
  /// The background color for the heading row.
  ///
  /// The effective background color can be made to depend on the
  /// [MaterialState] state, i.e. if the row is pressed, hovered, focused when
  /// sorted. The color is painted as an overlay to the row. To make sure that
  /// the row's [InkWell] is visible (when pressed, hovered and focused), it is
  /// recommended to use a translucent color.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.headingRowColor] is used.
  ///
  /// {@template flutter.material.DataTable.headingRowColor}
  /// ```dart
  /// PaginatedDataTable2(
  ///   headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
  ///     if (states.contains(MaterialState.hovered))
  ///       return Theme.of(context).colorScheme.primary.withOpacity(0.08);
  ///     return null;  // Use the default value.
  ///   }),
  /// )
  /// ```
  ///
  /// See also:
  ///
  ///  * The Material Design specification for overlay colors and how they
  ///    match a component's state:
  ///    <https://material.io/design/interaction/states.html#anatomy>.
  /// {@endtemplate}
  final MaterialStateProperty<Color?>? headingRowColor;

  /// The height of the heading row.
  ///
  /// This value is optional and defaults to 56.0 if not specified.
  final double? headingRowHeight;

  /// The horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  ///
  /// When a checkbox is displayed, it is also the margin between the checkbox
  /// the content in the first data column.
  ///
  /// This value defaults to 24.0 to adhere to the Material Design specifications.
  ///
  /// If [checkboxHorizontalMargin] is null, then [horizontalMargin] is also the
  /// margin between the edge of the table and the checkbox, as well as the
  /// margin between the checkbox and the content in the first data column.
  final double? horizontalMargin;

  /// Horizontal margin around the checkbox, if it is displayed.
  ///
  /// If null, then [horizontalMargin] is used as the margin between the edge
  /// of the table and the checkbox, as well as the margin between the checkbox
  /// and the content in the first data column. This value defaults to 24.0.
  final double? checkboxHorizontalMargin;

  /// The horizontal margin between the contents of each data column.
  ///
  /// This value defaults to 56.0 to adhere to the Material Design specifications.
  final double columnSpacing;

  /// {@macro flutter.material.dataTable.showCheckboxColumn}
  final bool showCheckboxColumn;

  /// Whether a border at the bottom of the table is displayed.
  ///
  /// By default, a border is not shown at the bottom to allow for a border
  /// around the table defined by [decoration].
  final bool showBottomBorder;

  /// The rows of the table
  final List<DataRow> rows;

  /// If set, the table will stop shrinking below the threshold and provide
  /// horizontal scrolling. Useful for the cases with narrow screens (e.g. portrait phone orientation)
  /// and lots of columns (that get messed with little space)
  final double? minWidth;

  /// Exposes scroll controller of the SingleChildScrollView that makes data rows horizontally scrollable
  final ScrollController? scrollController;

  /// Placeholder widget which is displayed whenever the data rows are empty.
  /// The widget will be displayed below column
  final Widget? empty;

  /// Set vertical and horizontal borders between cells, as well as outside borders around table.
  /// NOTE: setting this field will disable standard horizontal dividers which are controlled by
  /// themes and [dividerThickness] property
  final TableBorder? border;

  /// Determines ratio of Small column's width to Medium column's width.
  /// I.e. 0.5 means that Small column is twice narower than Medium column.
  final double smRatio;

  /// Determines ratio of Large column's width to Medium column's width.
  /// I.e. 2.0 means that Large column is twice wider than Medium column.
  final double lmRatio;

  /// {@template flutter.material.dataTable.dividerThickness}
  /// The width of the divider that appears between [TableRow]s.
  ///
  /// Must be greater than or equal to zero.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.dividerThickness] is used. This value
  /// defaults to 1.0.
  final double? dividerThickness;

  /// If set the table will have empty space added after the the last row and allow scroll the
  /// core of the table higher (e.g. if you would like to have iOS navigation UI at the bottom overlapping the table and
  /// have the ability to slightly scroll up the bototm row to avoid the obstruction)
  final double? bottomMargin;

  /// Parameters to control column resizing
  final ColumnResizingParameters? columnResizingParameters;

  /// If this flag is set to `false` than strating/shrinking table columns lead to
  /// changing table's total width. I.e. by default the table fills viewport's width OR occupies
  /// the space not less than minWidth (if provided) should the viewport be narrower
  final bool lockTableWidth;

  @override
  State<StatefulDataTable2> createState() => _StatefulDataTable2State();
}

class _StatefulDataTable2State extends State<StatefulDataTable2> {
  ColumnDataController columnDataController = ColumnDataController();
  late ColumnResizingParameters _colParams;

  @override
  void initState() {
    super.initState();
    _colParams = (widget.columnResizingParameters ??
        ColumnResizingParameters(desktopMode: true, realTime: true));
  }

  @override
  Widget build(BuildContext context) {
    var table = _DataTable2(
      columns: widget.columns,
      sortColumnIndex: widget.sortColumnIndex,
      sortAscending: widget.sortAscending,
      onSelectAll: widget.onSelectAll,
      decoration: widget.decoration,
      dataRowHeight: widget.dataRowHeight,
      headingRowColor: widget.headingRowColor,
      headingRowHeight: widget.headingRowHeight,
      horizontalMargin: widget.horizontalMargin,
      checkboxHorizontalMargin: widget.checkboxHorizontalMargin,
      columnSpacing: widget.columnSpacing,
      showCheckboxColumn: widget.showCheckboxColumn,
      showBottomBorder: widget.showBottomBorder,
      rows: widget.rows,
      minWidth: widget.minWidth,
      scrollController: widget.scrollController,
      empty: widget.empty,
      border: widget.border,
      smRatio: widget.smRatio,
      lmRatio: widget.lmRatio,
      dividerThickness: widget.dividerThickness,
      bottomMargin: widget.bottomMargin,
      buildResizeColumnWidget: _buildResizeWidget,
      columnDataController: columnDataController,
    );
    return table;
  }

  Widget _buildResizeWidget(DataColumn2 column, double widgetHeight) {
    return ColumnResizeWidget(
      height: widgetHeight,
      color: _colParams.widgetColor,
      minWidth: _colParams.widgetMinWidth,
      maxWidth: _colParams.widgetMaxWidth,
      onDragUpdate: (delta) {
        if (column is ResizableDataColumn2 && column.isResizable) {
          _onColumnResized(column, delta);
        }
      },
      desktopMode: _colParams.desktopMode,
      realTime: _colParams.realTime,
    );
  }

  void _onColumnResized(DataColumn2 dc2, double delta) {
    var idx = widget.columns.indexOf(dc2);

    /// Compensate delta when there are columns with not fixed width to the left
    var cl =
        columnDataController.getPropLeftNotFixedColumns(widget.columns, dc2);
    if (cl < 1) {
      delta = delta / (1 - cl);
    }
    if ((columnDataController.getCurrentWidth(idx) + delta) >=
        ColumnDataController.minColWidth) {
      setState(() {
        columnDataController.updateDataColumn(idx, delta);
      });
    }
  }

  @override
  void dispose() {
    columnDataController.dispose();
    super.dispose();
  }
}

/// Controller to store and calculate columns resizing
class ColumnDataController extends ChangeNotifier {
  /// Minimum size for a column
  /// TODO: find a way to calculate minimum column or just leave it hardcoded
  static double minColWidth = 50;

  Map<int, double> colsExtraWidth = {};
  Map<int, double> colsWidthNoExtra = {};

  double getExtraWidth(int idCol) {
    return colsExtraWidth[idCol] ?? 0.0;
  }

  double getCurrentWidth(int idCol) {
    return (colsWidthNoExtra[idCol] ?? 0.0) + getExtraWidth(idCol);
  }

  void updateDataColumn(int idCol, double delta) {
    colsExtraWidth[idCol] = getExtraWidth(idCol) + delta;
  }

  bool isFixedWidth(DataColumn dc, int colIdx) {
    return dc is! DataColumn2 ||
        (dc.fixedWidth != null || getExtraWidth(colIdx) != 0);
  }

  /// Returns the proportion of not fixed width columns left of [colLimit]
  /// with respect the total of not fixed width columns
  double getPropLeftNotFixedColumns(
      List<DataColumn> columns, DataColumn colLimit) {
    double res = 0;
    int t = 0;
    int l = 0;
    var idxLimit = columns.indexOf(colLimit);
    for (var c in columns) {
      var idx = columns.indexOf(c);
      if (c != colLimit &&
          !isFixedWidth(c, idx) &&
          (colsWidthNoExtra[idx] == null ||
              colsWidthNoExtra[idx]! > ColumnDataController.minColWidth)) {
        if (idx < idxLimit) {
          l++;
        }
        t++;
      }
    }
    if (t > 0) {
      res = l / t;
    }
    return res;
  }
}

/// Widget to control column resizing
class ColumnResizeWidget extends StatefulWidget {
  final double height;
  final void Function(double) onDragUpdate;
  final Color color;
  final bool desktopMode;
  final bool realTime;

  /// Minimum width of widget in desktop mode
  final double minWidth;

  /// Maximum width of widget in desktop mode
  final double maxWidth;
  const ColumnResizeWidget({
    super.key,
    required this.height,
    required this.onDragUpdate,
    this.color = Colors.black,
    this.desktopMode = false,
    this.realTime = false,
    this.minWidth = 2,
    this.maxWidth = 6,
  });

  @override
  State<StatefulWidget> createState() => ColumnResizeWidgetState();
}

class ColumnResizeWidgetState extends State<ColumnResizeWidget> {
  late double _width;
  var _color = Colors.transparent;
  var _hover = false;
  var _dragging = false;
  var amountResized = 0.0;

  @override
  void initState() {
    _width = widget.minWidth;
    super.initState();
  }

  void _update() {
    if (_dragging || _hover) {
      _color = widget.color;
      _width = widget.maxWidth;
    } else if (!_hover) {
      _color = Colors.transparent;
      _width = widget.minWidth;
      if (!widget.realTime) {
        _dragUpdated(0.0);
      }
    }
  }

  void _dragUpdated(double delta) {
    if (widget.realTime) {
      widget.onDragUpdate(delta);
    } else {
      if (_dragging) {
        setState(() {
          amountResized += delta;
        });
      } else {
        widget.onDragUpdate(amountResized);
        amountResized = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
      onDragUpdate: (details) => _dragUpdated(details.delta.dx),
      onDragStarted: () => setState(() {
        _dragging = true;
        _update();
      }),
      onDragEnd: (_) => setState(() {
        _dragging = false;
        _update();
      }),
      axis: Axis.horizontal,
      feedback: widget.realTime
          ? const SizedBox.shrink()
          : (widget.desktopMode)
              ? Container(
                  width: _width,
                  height: widget.height,
                  color: _color,
                )
              : (RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    color: widget.color,
                    Icons.vertical_align_center,
                  ),
                )),
      childWhenDragging: (!widget.desktopMode)
          ? RotatedBox(
              quarterTurns: 1,
              child: Icon(
                color: widget.color,
                Icons.vertical_align_center,
              ),
            )
          : null,
      child: (widget.desktopMode)
          ? MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              onEnter: (_) => setState(() {
                _hover = true;
                _update();
              }),
              onExit: (_) => setState(() {
                _hover = false;
                _update();
              }),
              child: AnimatedContainer(
                height: widget.height,
                width: _width,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                decoration: BoxDecoration(
                  color: widget.realTime || !_dragging ? _color : Colors.grey,
                ),
              ),
            )
          : Icon(color: widget.color, Icons.drag_indicator),
    );
  }
}

/// Class to set parameters of resize widget
class ColumnResizingParameters {
  final bool desktopMode;
  final Color widgetColor;

  /// Minimum width of widget in desktop mode
  final double widgetMinWidth;

  /// Maximum width of widget in desktop mode
  final double widgetMaxWidth;
  final bool realTime;

  ColumnResizingParameters({
    this.desktopMode = true,
    this.widgetColor = Colors.black,
    this.realTime = true,
    this.widgetMinWidth = 2,
    this.widgetMaxWidth = 6,
  });
}
