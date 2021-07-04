import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';

import 'data_table_2.dart';

enum SourceState { none, ok, loading, error }

abstract class AsyncDataTableSource extends DataTableSource {
  SourceState _state = SourceState.none;
  SourceState get state => _state;

  Object? _error;
  Object? get error => _error;

  List<DataRow> _rows = [];
  List<DataRow> get rows => _rows;

  Future<List<DataRow>> getRows(int start, int end);

  Future _getRows(int start, int end) async {
    _state = SourceState.loading;
    await Future(() => notifyListeners());

    try {
      _rows = await getRows(start, end);
    } catch (e) {
      _rows = [];
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
      source._getRows(firstRowIndex, widget.rowsPerPage);
      return SizedBox();
    } else if (source.state == SourceState.loading) {
      return Center(child: Text('Loading'));
    } else if (source.state == SourceState.error) {
      return Center(child: Text('Error'));
    }

    return super.build(context);
  }
}
