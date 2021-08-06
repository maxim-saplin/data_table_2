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
      int? sortColumnIndex,
      bool sortAscending = true,
      ValueSetter<bool?>? onSelectAll,
      double dataRowHeight = kMinInteractiveDimension,
      double headingRowHeight = 56,
      double horizontalMargin = 24,
      double columnSpacing = 56,
      bool showCheckboxColumn = true,
      bool showFirstLastButtons = false,
      int initialFirstRowIndex = 0,
      ValueChanged<int>? onPageChanged,
      int rowsPerPage = defaultRowsPerPage,
      List<int> availableRowsPerPage = const <int>[
        defaultRowsPerPage,
        defaultRowsPerPage * 2,
        defaultRowsPerPage * 5,
        defaultRowsPerPage * 10
      ],
      ValueChanged<int?>? onRowsPerPageChanged,
      DragStartBehavior dragStartBehavior = DragStartBehavior.start,
      required AsyncDataTableSource source,
      double? checkboxHorizontalMargin,
      bool wrapInCard = true,
      double? minWidth,
      FlexFit fit = FlexFit.tight,
      bool hidePaginator = false,
      PaginatorController? controller,
      ScrollController? scrollController,
      Widget? empty,
      TableBorder? border,
      bool autoRowsToHeight = false,
      double smRatio = 0.67,
      double lmRatio = 1.2})
      : super(
            key: key,
            header: header,
            actions: actions,
            columns: columns,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
            onSelectAll: onSelectAll,
            dataRowHeight: dataRowHeight,
            headingRowHeight: headingRowHeight,
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
            hidePaginator: hidePaginator,
            controller: controller,
            scrollController: scrollController,
            empty: empty,
            border: border,
            autoRowsToHeight: autoRowsToHeight,
            smRatio: smRatio,
            lmRatio: lmRatio);

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
