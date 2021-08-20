part of 'paginated_data_table_2.dart';

enum _SourceState { none, ok, loading, error }

/// AsyncDataTableSource states:
/// none -> toggle/selectAllOnPage -> include
/// include -> toggle/deselectAllOnPage -> no
/// include -> selectAll -> exclude
/// none -> selectAll -> exclude
/// exclude -> deselectAll -> none
/// exclude -> toggle/selectAllOnPage/deselectAllOnPage -> exclude
enum SelectionState { none, include, exclude }

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
  _SourceState _state = _SourceState.none;

  _SourceState get state => _state;

  /// Highlights if there're any selected rows (SelectionState.none means there're not any)
  /// and how [selectionRowKeys] must be treated.
  /// If SelectionState.include is the status, it is assumed that by default
  /// all rows are considered deselected and only those items in [selectionRowKeys]
  /// are selected.
  /// If SelectionState.exclude is the status, it is assumed that by default
  /// all rows are considered selected and only those items in [selectionRowKeys]
  /// are de-selected - this can be usefull if yopu deal with scenarious when you need
  /// to have many more selected items than deselected (e.g. selecting all rows across
  /// hundres of pages and than deselecting certain ines).
  SelectionState _selectionState = SelectionState.none;

  SelectionState get selectionState => _selectionState;

  Set<LocalKey> _selectionRowKeys = {};

  /// Lists rows (their keys) which are treated as eitehr selected or deselected (see [selectionState])
  Set<LocalKey> get selectionRowKeys => _selectionRowKeys;

  Object? _error;
  Object? get error => _error;

  List<DataRow> _rows = [];
  int _totalRows = 0;
  int _firstRowAbsoluteIndex = 0;

  int _prevFetchSratIndex = 0;
  int _prevFetchCount = 0;

  /// Override this method to allow the data source asynchronously
  /// fetch data (e.g. from a server) and convert them to [DataRow]/[DataRow2]
  /// entities consumed by [AsyncPaginatedDataTable2] widget.
  /// Note that besides rows this method is also supposed to return
  /// the total number of available rows (both values are packed into [AsyncRowsResponse] instance
  /// returned from this method)
  Future<AsyncRowsResponse> getRows(int start, int end);

  DataRow _clone(DataRow row, bool? selected) {
    if (row is DataRow2) {
      return DataRow2(
          key: row.key,
          selected: selected == null ? row.selected : selected,
          onSelectChanged: row.onSelectChanged,
          color: row.color,
          cells: row.cells,
          onTap: row.onTap,
          onSecondaryTap: row.onSecondaryTap,
          onSecondaryTapDown: row.onSecondaryTapDown);
    }

    return DataRow(
      key: row.key,
      selected: selected == null ? row.selected : selected,
      onSelectChanged: row.onSelectChanged,
      color: row.color,
      cells: row.cells,
    );
  }

  // set row's seelcted property in accordance with included/excluded from selection items
  void _fixSelectedState(int rowIndex) {
    if (_selectionState == SelectionState.include) {
      if (!_rows[rowIndex].selected &&
          _selectionRowKeys.contains(_rows[rowIndex].key)) {
        _rows[rowIndex] = _clone(_rows[rowIndex], true);
      } else if (_rows[rowIndex].selected &&
          !_selectionRowKeys.contains(_rows[rowIndex].key)) {
        _rows[rowIndex] = _clone(_rows[rowIndex], false);
      }
    } else if (_selectionState == SelectionState.exclude) {
      if (!_rows[rowIndex].selected &&
          !_selectionRowKeys.contains(_rows[rowIndex].key)) {
        _rows[rowIndex] = _clone(_rows[rowIndex], true);
      } else if (_rows[rowIndex].selected &&
          _selectionRowKeys.contains(_rows[rowIndex].key)) {
        _rows[rowIndex] = _clone(_rows[rowIndex], false);
      }
    } else {
      //none
      if (_rows[rowIndex].selected) {
        _rows[rowIndex] = _clone(_rows[rowIndex], false);
      }
    }
  }

  void selectAll() {
    _selectionState = SelectionState.exclude;
    _selectionRowKeys.clear();
    notifyListeners();
  }

  void deselectAll() {
    _selectionState = SelectionState.none;
    _selectionRowKeys.clear();
    notifyListeners();
  }

  void selectAllOnThePage() {
    for (var i = 0; i < _rows.length; i++) {
      var r = _rows[i];
      assert(r.key != null, 'Row key can\'t be null');

      if (r.key != null) {
        if (_selectionState == SelectionState.none ||
            _selectionState == SelectionState.include) {
          _selectionRowKeys.add(r.key!);
        } else {
          //exclude
          _selectionRowKeys.remove(r.key!);
        }
        if (!_rows[i].selected) _rows[i] = _clone(r, true);
      }
    }
    if (_selectionState == SelectionState.none &&
        _selectionRowKeys.isNotEmpty) {
      _selectionState = SelectionState.include;
    }
    notifyListeners();
  }

  @override
  int get selectedRowCount => _selectionState == SelectionState.none
      ? 0
      : _selectionState == SelectionState.include
          ? _selectionRowKeys.length
          : _totalRows - _selectionRowKeys.length;

  void deselectAllOnThePage() {
    for (var i = 0; i < _rows.length; i++) {
      var r = _rows[i];
      assert(r.key != null, 'Row key can\'t be null');
      if (r.key != null) {
        if (_selectionState == SelectionState.none ||
            _selectionState == SelectionState.include) {
          _selectionRowKeys.remove(r.key!);
        } else {
          // exclude
          _selectionRowKeys.add(r.key!);
        }
        if (_rows[i].selected) _rows[i] = _clone(r, false);
      }
    }
    if (_selectionState == SelectionState.include &&
        _selectionRowKeys.isEmpty) {
      _selectionState = SelectionState.none;
    }
    notifyListeners();
  }

  void setRowSelection(LocalKey rowKey, bool selected) {
    var i = _rows.indexWhere((r) => r.key == rowKey);
    if (i > -1 && _rows[i].selected != selected) {
      _toggleRowSelection(i);
    }
  }

  void _toggleRowSelection(int i) {
    _rows[i] = _clone(_rows[i], !_rows[i].selected);
    if (_selectionState == SelectionState.none) {
      if (_rows[i].selected) {
        _selectionRowKeys.add(_rows[i].key!);
        _selectionState = SelectionState.include;
      }
    } else if (_selectionState == SelectionState.include) {
      if (_rows[i].selected) {
        _selectionRowKeys.add(_rows[i].key!);
      } else {
        _selectionRowKeys.remove(_rows[i].key!);
      }
      if (_selectionRowKeys.isEmpty) {
        _selectionState = SelectionState.none;
      }
    } else {
      // exclude
      if (_rows[i].selected) {
        _selectionRowKeys.remove(_rows[i].key!);
      } else {
        _selectionRowKeys.add(_rows[i].key!);
      }
    }

    notifyListeners();
  }

  /// This method triggers getRows() requesting same rows as the last time
  /// and intitaite update workflow (and thus rebuilding of [AsyncPaginatedDataTable2]
  /// attached to this data source). Can be used for sorting
  void refreshDatasource() {
    _fetchData(_prevFetchSratIndex, _prevFetchCount);
  }

  Future _fetchData(int startIndex, int count) async {
    _prevFetchSratIndex = startIndex;
    _prevFetchCount = count;
    _state = _SourceState.loading;
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
      _state = _SourceState.error;
      _error = e;
      notifyListeners();
      return;
    }

    _state = _SourceState.ok;
    _error = null;
    notifyListeners();
    return;
  }

  @override
  DataRow? getRow(int index) {
    if (index - _firstRowAbsoluteIndex < 0 ||
        index >= _rows.length + _firstRowAbsoluteIndex) return null;
    index -= _firstRowAbsoluteIndex;
    _fixSelectedState(index);

    return _rows[index];
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
      this.loading,
      this.errorBuilder,
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

  final Widget? loading;
  final Widget Function(Object? error)? errorBuilder;

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
      // int oldFirstRowIndex = _firstRowIndex;
      _operationInProgress = _TableOperationInProgress.pageTo;
      // if row requested happens to be outside the available range - change it to the last aligned page
      if (rowIndex > _rowCount - 1) {
        _rowIndexRequested = math.min(
            ((rowIndex + 1) / _effectiveRowsPerPage).floor() *
                _effectiveRowsPerPage,
            (_rowCount / _effectiveRowsPerPage).floor() *
                _effectiveRowsPerPage);
      } else
        _rowIndexRequested = _alignRowIndex(rowIndex, _effectiveRowsPerPage);
      var source = widget.source as AsyncDataTableSource;
      source._fetchData(_rowIndexRequested, _effectiveRowsPerPage);
    }
  }

  int? _pageSizeInQueue;

  @override
  void _setRowsPerPage(int? r, [bool wrapInSetState = true]) {
    if (r != null) {
      if (_operationInProgress == _TableOperationInProgress.none) {
        _pageSizeInQueue = null;
        _operationInProgress = _TableOperationInProgress.pageSize;
        _rowsPerPageRequested = r;
        _rowIndexRequested = _firstRowIndex;
        // _rowIndexRequested = math.min(
        //     ((_firstRowIndex + 1) / _rowsPerPageRequested).floor() *
        //         _rowsPerPageRequested,
        //     (_rowCount / _rowsPerPageRequested).floor() *
        //         _rowsPerPageRequested);
        var source = widget.source as AsyncDataTableSource;
        source._fetchData(_firstRowIndex, r);
      } else {
        // workaround to auto rows and resizing the window while previous fetch is not complete
        _pageSizeInQueue = r;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var source = widget.source as AsyncDataTableSource;
    var w = widget as AsyncPaginatedDataTable2;

    if (source.state == _SourceState.none) {
      _showNothing = true;
      var x = super.build(context);

      source._fetchData(_firstRowIndex, _effectiveRowsPerPage);

      // Future.delayed(Duration(milliseconds: 0),
      //     () => source._fetchData(_firstRowIndex, _effectiveRowsPerPage));
      return x;
    } else if (source.state == _SourceState.loading) {
      //_showNothing = true;
      var x = super.build(context);
      return Stack(fit: StackFit.expand, children: [
        x,
        if (w.loading != null) w.loading!,
      ]);
    } else if (source.state == _SourceState.error) {
      _showNothing = true;
      return w.errorBuilder != null
          ? w.errorBuilder!(source._error)
          : SizedBox();
    }

    // SourceState.ok
    _showNothing = false;
    if (_operationInProgress == _TableOperationInProgress.pageTo) {
      _operationInProgress = _TableOperationInProgress.none;

      super.pageTo(_rowIndexRequested);
    } else if (_operationInProgress == _TableOperationInProgress.pageSize) {
      _operationInProgress = _TableOperationInProgress.none;
      if (_pageSizeInQueue == null) {
        _firstRowIndex = _rowIndexRequested;
        super._setRowsPerPage(_rowsPerPageRequested);
      } else {
        _setRowsPerPage(_pageSizeInQueue);
      }
    }

    var x = super.build(context);

    return x;
  }
}