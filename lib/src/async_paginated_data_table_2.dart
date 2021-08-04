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
  //List<DataRow> get rows => _rows;
  int _totalRows = 0;

  /// Override this method to allow the data source asynchronously
  /// fetch data (e.g. from a server) and convert them to [DataRow]/[DataRow2]
  /// entities consumed by [AsyncPaginatedDataTable2] widget.
  /// Note that besides rows this method is also supposed to return
  /// the total number of available rows (both values are packed into [AsyncRowsResponse] instance
  /// returned from this method)
  Future<AsyncRowsResponse> getRows(int start, int end);

  Future _getRows(int start, int end) async {
    _state = SourceState.loading;
    await Future(() => notifyListeners());

    try {
      var data = await getRows(start, end);
      _rows = data.rows;
      _totalRows = data.totalRows;
    } catch (e) {
      _rows = [];
      _totalRows = 0;
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
    if (_rows.length - 1 <= index) return _rows[index];

    return null;
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

class AsyncPaginatedDataTable2State extends PaginatedDataTable2State {
  @override
  Widget build(BuildContext context) {
    var source = widget.source as AsyncDataTableSource;
    if (source.state == SourceState.none) {
      source._getRows(_firstRowIndex, widget.rowsPerPage);
      return SizedBox();
    } else if (source.state == SourceState.loading) {
      return Center(child: Text('Loading'));
    } else if (source.state == SourceState.error) {
      return Center(child: Text('Error'));
    }

    return super.build(context);
  }
}
