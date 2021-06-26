import 'package:flutter/material.dart';

abstract class AsyncDataTableSource extends ChangeNotifier {
  /// Called to obtain the data about a particular row.
  ///
  /// The [new DataRow.byIndex] constructor provides a convenient way to construct
  /// [DataRow] objects for this callback's purposes without having to worry about
  /// independently keying each row.
  ///
  /// If the given index does not correspond to a row, or if no data is yet
  /// available for a row, then return null. The row will be left blank and a
  /// loading indicator will be displayed over the table. Once data is available
  /// or once it is firmly established that the row index in question is beyond
  /// the end of the table, call [notifyListeners].
  ///
  /// Data returned from this method must be consistent for the lifetime of the
  /// object. If the row count changes, then a new delegate must be provided.
  Future<List<DataRow>> getRows(int start, int end);

  /// Called to obtain the number of rows to tell the user are available.
  ///
  /// If [isRowCountApproximate] is false, then this must be an accurate number,
  /// and [getRow] must return a non-null value for all indices in the range 0
  /// to one less than the row count.
  ///
  /// If [isRowCountApproximate] is true, then the user will be allowed to
  /// attempt to display rows up to this [rowCount], and the display will
  /// indicate that the count is approximate. The row count should therefore be
  /// greater than the actual number of rows if at all possible.
  ///
  /// If the row count changes, call [notifyListeners].
  int get rowCount;

  /// Called to establish if [rowCount] is a precise number or might be an
  /// over-estimate. If this returns true (i.e. the count is approximate), and
  /// then later the exact number becomes available, then call
  /// [notifyListeners].
  bool get isRowCountApproximate;

  /// Called to obtain the number of rows that are currently selected.
  ///
  /// If the selected row count changes, call [notifyListeners].
  int get selectedRowCount;
}
