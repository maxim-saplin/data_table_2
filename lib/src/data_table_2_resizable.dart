part of 'data_table_2.dart';

/// Stateful widget to manage column resizing and implements events logic
class ResizeColumns extends StatefulWidget {
  const ResizeColumns({
    super.key,
    required this.columns,
    required this.builder,
  });

  /// Positions of 2 pairs of scroll controllers (sc11|sc12 and sc21|sc22)
  /// will be synchronized, attached scrollables will copy the positions
  final Widget Function(
      BuildContext context,
      ColumnDataController dataController,
      Function(List<DataColumn> columns, DataColumn2 dc2, double delta)
          onColumnResized) builder;

  final List<DataColumn> columns;

  @override
  ResizeColumnsState createState() => ResizeColumnsState();
}

class ResizeColumnsState extends State<ResizeColumns> {
  late ColumnDataController _cdc;
  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _cdc = ColumnDataController();
  }

  void _disposeOrUnsubscribe() {
    _cdc.dispose();
  }

  void _onColumnResized(
      List<DataColumn> columns, DataColumn2 dc2, double delta) {
    var idx = columns.indexOf(dc2);

    /// Compensate delta when there are columns with not fixed width to the left
    var cl = _cdc.getPropLeftNotFixedColumns(columns, dc2);
    if (cl < 1) {
      delta = delta / (1 - cl);
    }
    if ((_cdc.getCurrentWidth(idx) + delta) >=
        ColumnDataController.minColWidth) {
      setState(() {
        _cdc.updateDataColumn(idx, delta);
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _cdc, _onColumnResized);
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
