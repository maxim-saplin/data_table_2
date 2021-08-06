part of 'paginated_data_table_2.dart';

enum SourceState { none, ok, loading, error }

class AsyncRowsResponse {
  AsyncRowsResponse(this.totalRows, this.rows);
  final int totalRows;
  final List<DataRow> rows;
}

/// Implement this class and use it in conjunction with [AsyncPaginatedDataTable2]
/// to allow asynchronous data fetching.
/// Please overide [AsyncDataTableSource.getRows] and [DataTableSource.selectedRowCount]
/// to make it legible as a data source.
abstract class AsyncDataTableSource extends DataTableSource {
  SourceState _state = SourceState.none;
  SourceState get state => _state;

  Object? _error;
  Object? get error => _error;

  List<DataRow> _rows = [];
  int _totalRows = 0;
  int _firstRowAbsoluteIndex = 0;

  /// Override this method to allow the data source asynchronously
  /// fetch data (e.g. from a server) and convert them to [DataRow]/[DataRow2]
  /// entities consumed by [AsyncPaginatedDataTable2] widget.
  /// Note that besides rows this method is also supposed to return
  /// the total number of available rows (both values are packed into [AsyncRowsResponse] instance
  /// returned from this method)
  Future<AsyncRowsResponse> getRows(int start, int end);

  Future _getRows(int startIndex, int count) async {
    _state = SourceState.loading;
    await Future(() => notifyListeners());

    try {
      var data = await getRows(startIndex, count);
      _rows = data.rows;
      _totalRows = data.totalRows;
      _firstRowAbsoluteIndex = startIndex;
    } catch (e) {
      _rows = [];
      _totalRows = 0;
      _firstRowAbsoluteIndex = 0;
      _state = SourceState.error;
      _error = e;
      notifyListeners();
      return;
    }

    _state = SourceState.ok;
    _error = null;
    notifyListeners();
    return;
  }

  @override
  DataRow? getRow(int index) {
    if (index - _firstRowAbsoluteIndex < 0 ||
        index >= _rows.length + _firstRowAbsoluteIndex) return null;

    return _rows[index - _firstRowAbsoluteIndex];
  }

  @override
  int get rowCount => _totalRows;

  @override
  bool get isRowCountApproximate => false;
}

class AsyncPaginatedDataTable2 extends PaginatedDataTable2 {
  AsyncPaginatedDataTable2(
      {Key? key,
      Widget? header,
      List<Widget>? actions,
      required List<DataColumn> columns,
      required AsyncDataTableSource source})
      : super(
            key: key,
            header: header,
            actions: actions,
            columns: columns,
            source: source);

  @override
  PaginatedDataTable2State createState() => AsyncPaginatedDataTable2State();
}

enum _TableOperationInProgress { none, pageTo, pageSize }

class AsyncPaginatedDataTable2State extends PaginatedDataTable2State {
  _TableOperationInProgress _operationInProgress =
      _TableOperationInProgress.none;

  int _rowIndexRequested = -1;
  int _rowsPerPageRequested = -1;

  @override
  void pageTo(int rowIndex) {
    if (_operationInProgress == _TableOperationInProgress.none) {
      _operationInProgress = _TableOperationInProgress.pageTo;
      _rowIndexRequested = rowIndex;
      var source = widget.source as AsyncDataTableSource;
      source._getRows(rowIndex, widget.rowsPerPage);
    }
  }

  @override
  void _setRowsPerPage(int? r) {
    if (r != null && _operationInProgress == _TableOperationInProgress.none) {
      _operationInProgress = _TableOperationInProgress.pageSize;
      _rowsPerPageRequested = r;
      var source = widget.source as AsyncDataTableSource;
      source._getRows(_firstRowIndex, r);
    }
  }

  @override
  Widget build(BuildContext context) {
    var source = widget.source as AsyncDataTableSource;

    if (source.state == SourceState.none) {
      var x = super.build(context);
      source._getRows(_firstRowIndex, widget.rowsPerPage);
      return x;
    } else if (source.state == SourceState.loading) {
      var x = super.build(context);
      return Stack(fit: StackFit.expand, children: [
        x,
        ColoredBox(
            color: Colors.white.withAlpha(128),
            child: Center(
                child: Container(
              color: Colors.amber,
              padding: EdgeInsets.all(7),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [CircularProgressIndicator(), Text('Loading..')]),
              width: 150,
              height: 50,
            ))),
      ]);
    } else if (source.state == SourceState.error) {
      return Center(child: Text('Error'));
    }

    // SourceState.ok
    if (_operationInProgress == _TableOperationInProgress.pageTo) {
      super.pageTo(_rowIndexRequested);
      _operationInProgress = _TableOperationInProgress.none;
    } else if (_operationInProgress == _TableOperationInProgress.pageSize) {
      super._setRowsPerPage(_rowsPerPageRequested);
      _operationInProgress = _TableOperationInProgress.none;
    }

    var x = super.build(context);

    return x;
  }
}
