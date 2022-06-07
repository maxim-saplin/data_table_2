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

// TODO - conclude on resizing the table and it's width.
// Current implementation assumes there're 2 options:
// 1) Stretch to fill the container, size all columns inside to the avaialble with
// 2) Stretch and fill container, should the available width be less then specified minWidth - size the columns to minwidth and show horizontal scrollbar
// IMO, for the resizable table it makes sens to have 3rd option, let the table change total width when resizing columns
class StatefulDataTable2 extends StatefulWidget {
  const StatefulDataTable2({Key? key})
      : super(key: key, this.lockTableWidth = true);

  /// If this flag is set to `false` than strating/shrinking table columns lead to
  /// changing table's total width. I.e. by default the table fills viewport's width OR occupies
  /// the space not less than minWidth (if provided) should the viewport be narrower
  final bool lockTableWidth;

  @override
  State<StatefulDataTable2> createState() {
    // TODO: implement createState
    throw UnimplementedError();
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

  const ColumnResizeWidget({
    super.key,
    required this.height,
    required this.onDragUpdate,
    this.color = Colors.black,
    this.desktopMode = false,
    this.realTime = false,
  });

  @override
  State<StatefulWidget> createState() => ColumnResizeWidgetState();
}

class ColumnResizeWidgetState extends State<ColumnResizeWidget> {
  var _width = 4.0;
  var _color = Colors.transparent;
  var _hover = false;
  var _dragging = false;
  var amountResized = 0.0;

  void _update() {
    if (_dragging || _hover) {
      _color = widget.color;
      _width = 6;
    } else if (!_hover) {
      _color = Colors.transparent;
      _width = 4;
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
  /// Called when the column is resized
  final void Function(DataColumn2, double) onColumnResized;
  final bool desktopMode;
  final Color widgetColor;
  final bool realTime;

  ColumnResizingParameters({
    required this.onColumnResized,
    this.desktopMode = true,
    this.widgetColor = Colors.black,
    this.realTime = true,
  });
}
