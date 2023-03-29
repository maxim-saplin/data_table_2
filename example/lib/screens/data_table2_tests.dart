// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, avoid_renaming_method_parameters

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

int _idCounter = 0;

class Dessert {
  Dessert(this.name, this.calories, this.fat, this.carbs, this.protein, this.sodium, this.calcium, this.iron);

  final String name;
  final int calories;
  final double fat;
  final int carbs;
  final double protein;
  final int sodium;
  final int calcium;
  final int iron;

  final int id = _idCounter++;
  bool selected = false;
}

final List<Dessert> kDesserts = <Dessert>[
  Dessert('Frozen yogurt', 159, 6.0, 24, 4.0, 87, 14, 1),
  Dessert('Ice cream sandwich', 237, 9.0, 37, 4.3, 129, 8, 1),
  Dessert('Eclair', 262, 16.0, 24, 6.0, 337, 6, 7),
  Dessert('Cupcake', 305, 3.7, 67, 4.3, 413, 3, 8),
  Dessert('Gingerbread', 356, 16.0, 49, 3.9, 327, 7, 16),
  Dessert('Jelly bean', 375, 0.0, 94, 0.0, 50, 0, 0),
  Dessert('Lollipop', 392, 0.2, 98, 0.0, 38, 0, 2),
  Dessert('Honeycomb', 408, 3.2, 87, 6.5, 562, 0, 45),
  Dessert('Donut', 452, 25.0, 51, 4.9, 326, 2, 22),
  Dessert('KitKat', 518, 26.0, 65, 7.0, 54, 12, 6),
];

final testColumns = <DataColumn2>[
  DataColumn2(label: const Text('Name'), tooltip: 'Name', onSort: (int columnIndex, bool ascending) {}),
  DataColumn2(
    label: const Text('Calories'),
    tooltip: 'Calories',
    numeric: true,
    onSort: (int columnIndex, bool ascending) {},
  ),
  DataColumn2(
    label: const Text('Carbs'),
    tooltip: 'Carbs',
    numeric: true,
    onSort: (int columnIndex, bool ascending) {},
  ),
];

final smlColumns = <DataColumn2>[
  const DataColumn2(label: Text('Name'), tooltip: 'Name', size: ColumnSize.S),
  DataColumn2(
    label: const Text('Calories'),
    tooltip: 'Calories',
    size: ColumnSize.M,
    numeric: true,
    onSort: (int columnIndex, bool ascending) {},
  ),
  DataColumn2(
    label: const Text('Carbs'),
    tooltip: 'Carbs',
    size: ColumnSize.L,
    numeric: true,
    onSort: (int columnIndex, bool ascending) {},
  ),
];

final testRows = kDesserts.map<DataRow2>((Dessert dessert) {
  return DataRow2(
    key: ValueKey<String>(dessert.name),
    onSelectChanged: (bool? selected) {},
    cells: <DataCell>[
      DataCell(
        Text(dessert.name),
      ),
      DataCell(
        Text('${dessert.calories}'),
        showEditIcon: true,
        onTap: () {},
      ),
      DataCell(
        Text('${dessert.carbs}'),
        showEditIcon: true,
        onTap: () {},
      ),
    ],
  );
}).toList();

DataTable2 buildTable(
    {int? sortColumnIndex,
    bool sortAscending = true,
    bool overrideSizes = false,
    double? minWidth,
    int fixedTopRows = 1,
    int fixedLeftColumns = 0,
    Color? fixedColumnsColor,
    Color? fixedCornerColor,
    double? dividerThickness,
    Widget? empty,
    bool showCheckboxColumn = true,
    ScrollController? scrollController,
    List<DataColumn2>? columns,
    List<DataRow2>? rows}) {
  return DataTable2(
    horizontalMargin: 24,
    showCheckboxColumn: showCheckboxColumn,
    sortColumnIndex: sortColumnIndex,
    sortAscending: sortAscending,
    minWidth: minWidth,
    fixedTopRows: fixedTopRows,
    fixedLeftColumns: fixedLeftColumns,
    fixedColumnsColor: fixedColumnsColor,
    fixedCornerColor: fixedCornerColor,
    dividerThickness: dividerThickness,
    empty: empty,
    onSelectAll: (bool? value) {},
    columns: columns ?? testColumns,
    scrollController: scrollController,
    smRatio: overrideSizes ? 0.5 : 0.67,
    lmRatio: overrideSizes ? 1.5 : 1.2,
    rows: rows ?? testRows,
  );
}

class TestDataSource extends DataTableSource {
  TestDataSource({this.allowSelection = false, this.showPage = true, this.showGeneration = true, this.noData = false});

  final bool allowSelection;
  final bool showPage;
  final bool showGeneration;
  final bool noData;

  int get generation => _generation;
  int _generation = 0;
  set generation(int value) {
    if (_generation == value) return;
    _generation = value;
    notifyListeners();
  }

  final Set<int> _selectedRows = <int>{};

  void _handleSelected(int index, bool? selected) {
    if (selected == true) {
      _selectedRows.add(index);
    } else {
      _selectedRows.remove(index);
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final Dessert dessert = kDesserts[index % kDesserts.length];
    final int page = index ~/ kDesserts.length;
    return DataRow.byIndex(
      index: index,
      selected: _selectedRows.contains(index),
      cells: <DataCell>[
        DataCell(Text(showPage ? '${dessert.name} ($page)' : dessert.name)),
        DataCell(Text('${dessert.calories}')),
        DataCell(Text(showGeneration ? '$generation' : '${dessert.carbs}')),
      ],
      onSelectChanged: allowSelection ? (bool? selected) => _handleSelected(index, selected) : null,
    );
  }

  @override
  int get rowCount => noData ? 0 : 50 * kDesserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}

PaginatedDataTable2 buildPaginatedTable(
    {int? sortColumnIndex,
    bool sortAscending = true,
    bool showPage = true,
    bool showGeneration = true,
    bool overrideSizes = false,
    bool autoRowsToHeight = false,
    bool showHeader = false,
    bool wrapInCard = false,
    bool showPageSizeSelector = false,
    bool noData = false,
    bool hidePaginator = false,
    TableBorder? border,
    PaginatorController? controller,
    Widget? empty,
    FlexFit fit = FlexFit.tight,
    ScrollController? scrollController,
    MaterialStateProperty<Color?>? headingRowColor,
    double? minWidth,
    Function(int?)? onRowsPerPageChanged,
    List<DataColumn2>? columns}) {
  return PaginatedDataTable2(
    horizontalMargin: 24,
    showCheckboxColumn: true,
    wrapInCard: wrapInCard,
    header: showHeader ? const Text('Header') : null,
    sortColumnIndex: sortColumnIndex,
    sortAscending: sortAscending,
    onSelectAll: (bool? value) {},
    columns: columns ?? testColumns,
    showFirstLastButtons: true,
    controller: controller,
    border: border,
    headingRowColor: headingRowColor,
    empty: empty,
    fit: fit,
    scrollController: scrollController,
    hidePaginator: hidePaginator,
    minWidth: minWidth,
    smRatio: overrideSizes ? 0.5 : 0.67,
    lmRatio: overrideSizes ? 1.5 : 1.2,
    autoRowsToHeight: autoRowsToHeight,
    onRowsPerPageChanged: showPageSizeSelector || onRowsPerPageChanged != null ? onRowsPerPageChanged ?? (int? rowsPerPage) {} : null,
    source: TestDataSource(allowSelection: true, showPage: showPage, showGeneration: showGeneration, noData: noData),
  );
}

PaginatedDataTable2 buildAsyncPaginatedTable(
    {int? sortColumnIndex,
    bool sortAscending = true,
    bool showPage = true,
    bool showGeneration = true,
    bool overrideSizes = false,
    bool autoRowsToHeight = false,
    bool showHeader = false,
    bool wrapInCard = false,
    bool showPageSizeSelector = false,
    bool noData = false,
    bool throwError = false,
    bool hidePaginator = false,
    int rowsPerPage = 10,
    initialFirstRowIndex = 0,
    bool circularSpinner = false,
    Function(bool? value)? onSelectAll,
    bool showCheckboxColumn = true,
    bool fewerResultsAfterRefresh = false,
    PaginatorController? controller,
    AsyncDataTableSource? source,
    Widget? empty,
    PageSyncApproach syncApproach = PageSyncApproach.doNothing,
    // Return less rows when calling refresh method on the data source
    ScrollController? scrollController,
    double? minWidth,
    Function(int?)? onRowsPerPageChanged,
    List<DataColumn2>? columns}) {
  return AsyncPaginatedDataTable2(
    horizontalMargin: 24,
    showCheckboxColumn: showCheckboxColumn,
    wrapInCard: wrapInCard,
    initialFirstRowIndex: initialFirstRowIndex,
    header: showHeader ? const Text('Header') : null,
    sortColumnIndex: sortColumnIndex,
    sortAscending: sortAscending,
    onSelectAll: onSelectAll ?? (bool? value) {},
    columns: columns ?? testColumns,
    showFirstLastButtons: true,
    controller: controller,
    rowsPerPage: rowsPerPage,
    loading: circularSpinner
        ? const Center(
            child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                )))
        : null,
    empty: empty,
    scrollController: scrollController,
    hidePaginator: hidePaginator,
    minWidth: minWidth,
    smRatio: overrideSizes ? 0.5 : 0.67,
    lmRatio: overrideSizes ? 1.5 : 1.2,
    autoRowsToHeight: autoRowsToHeight,
    errorBuilder: (e) => Text(e.toString()),
    onRowsPerPageChanged: showPageSizeSelector || onRowsPerPageChanged != null ? onRowsPerPageChanged ?? (int? rowsPerPage) {} : null,
    pageSyncApproach: syncApproach,
    source: source ??
        (DessertDataSourceAsync(allowSelection: true, showPage: showPage, noData: noData, fewerResultsAfterRefresh: fewerResultsAfterRefresh)
          .._errorCounter = throwError ? 0 : null),
  );
}

class DessertDataSourceAsync extends AsyncDataTableSource {
  DessertDataSourceAsync({
    this.allowSelection = false,
    this.showPage = true,
    this.noData = false,
    this.useKDeserts = false,
    this.fewerResultsAfterRefresh = false,
  });

  final bool allowSelection;
  final bool showPage;
  final bool noData;
  final bool useKDeserts;
  final bool fewerResultsAfterRefresh;
  bool _usefewerResultsAfterRefresh = false;

  int get generation => _generation;

  int _generation = 0;
  set generation(int value) {
    if (_generation == value) return;
    _generation = value;
    notifyListeners();
  }

  final bool _empty = false;
  int? _errorCounter;

  final DesertsFakeWebService _repo = DesertsFakeWebService();

  String _sortColumn = "name";
  bool _sortAscending = true;

  void sort(String columnName, bool ascending) {
    _sortColumn = columnName;
    _sortAscending = ascending;
    refreshDatasource();
  }

  Future<int> getTotalRecors() {
    return Future<int>.delayed(const Duration(milliseconds: 0), () => _empty ? 0 : _dessertsX3.length);
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    print('getRows($startIndex, $count)');
    if (_errorCounter != null) {
      _errorCounter = _errorCounter! + 1;

      if (_errorCounter! % 2 == 1) {
        await Future.delayed(const Duration(milliseconds: 1000));
        throw 'Error #${((_errorCounter! - 1) / 2).round() + 1} has occured';
      }
    }

    var index = startIndex;
    assert(index >= 0);

    var x = _empty
        ? await Future.delayed(const Duration(milliseconds: 2000), () => DesertsFakeWebServiceResponse(0, []))
        : (_usefewerResultsAfterRefresh)
            ? await Future.delayed(const Duration(milliseconds: 2000), () => DesertsFakeWebServiceResponse(10, _dessertsX3.take(10).toList()))
            : await _repo.getData(startIndex, count, _sortColumn, _sortAscending, noData, useKDeserts);

    if (fewerResultsAfterRefresh && !_usefewerResultsAfterRefresh) {
      _usefewerResultsAfterRefresh = true;
    }

    var r = AsyncRowsResponse(
        x.totalRecords,
        x.data.map((dessert) {
          return DataRow(
            key: ValueKey<int>(dessert.id),
            selected: dessert.selected,
            onSelectChanged: (value) {
              if (value != null) {
                setRowSelection(ValueKey<int>(dessert.id), value);
              }
            },
            cells: <DataCell>[
              DataCell(
                Text(dessert.name),
              ),
              DataCell(
                Text('${dessert.calories}'),
                showEditIcon: true,
                onTap: () {},
              ),
              DataCell(
                Text('${dessert.carbs}'),
                showEditIcon: true,
                onTap: () {},
              ),
            ],
          );
        }).toList());

    return r;
  }
}

class DesertsFakeWebServiceResponse {
  DesertsFakeWebServiceResponse(this.totalRecords, this.data);

  /// THe total ammount of records on the server, e.g. 100
  final int totalRecords;

  /// One page, e.g. 10 reocrds
  final List<Dessert> data;
}

class DesertsFakeWebService {
  int Function(Dessert, Dessert)? _getComparisonFunction(String column, bool ascending) {
    var coef = ascending ? 1 : -1;
    switch (column) {
      case 'name':
        return (Dessert d1, Dessert d2) => coef * d1.name.compareTo(d2.name);
      case 'calories':
        return (Dessert d1, Dessert d2) => coef * (d1.calories - d2.calories);
      case 'fat':
        return (Dessert d1, Dessert d2) => coef * (d1.fat - d2.fat).round();
      case 'carbs':
        return (Dessert d1, Dessert d2) => coef * (d1.carbs - d2.carbs);
      case 'protein':
        return (Dessert d1, Dessert d2) => coef * (d1.protein - d2.protein).round();
      case 'sodium':
        return (Dessert d1, Dessert d2) => coef * (d1.sodium - d2.sodium);
      case 'calcium':
        return (Dessert d1, Dessert d2) => coef * (d1.calcium - d2.calcium);
      case 'iron':
        return (Dessert d1, Dessert d2) => coef * (d1.iron - d2.iron);
    }

    return null;
  }

  Future<DesertsFakeWebServiceResponse> getData(int startingAt, int count, String sortedBy, bool sortedAsc, bool noData,
      [bool useKDesserts = false]) async {
    return Future.delayed(
        Duration(
            milliseconds: startingAt == 0
                ? 2650
                : startingAt < 20
                    ? 2000
                    : 400), () {
      _dessertsX3.sort(_getComparisonFunction(sortedBy, sortedAsc));
      return noData
          ? DesertsFakeWebServiceResponse(0, [])
          : (useKDesserts
              ? DesertsFakeWebServiceResponse(
                  50 * kDesserts.length, List.generate(count, (index) => kDesserts[(startingAt + index) % kDesserts.length]))
              : DesertsFakeWebServiceResponse(_dessertsX3.length, _dessertsX3.skip(startingAt).take(count).toList()));
    });
  }
}

List<Dessert> _desserts = kDesserts;

List<Dessert> _dessertsX3 = _desserts.toList()
  ..addAll(_desserts.map((i) => Dessert('${i.name} x2', i.calories, i.fat, i.carbs, i.protein, i.sodium, i.calcium, i.iron)))
  ..addAll(_desserts.map((i) => Dessert('${i.name} x3', i.calories, i.fat, i.carbs, i.protein, i.sodium, i.calcium, i.iron)));

class DataTable2Tests extends StatelessWidget {
  const DataTable2Tests({super.key});

  static ScrollController sc = ScrollController();
  static PaginatorController pc = PaginatorController();

  @override
  Widget build(BuildContext context) {
    var source = DessertDataSourceAsync(allowSelection: true);

    //setColumnSizeRatios(1, 2);
    return Padding(
        padding: const EdgeInsets.all(16),
        child:

            // AsyncPaginatedDataTable2(
            //   header: const Text('Test table'),
            //   source: DessertDataSourceAsync(
            //       allowSelection: true,
            //       useKDeserts: true,
            //       showGeneration: true,
            //       noData: false),
            //   rowsPerPage: 2,
            //   availableRowsPerPage: const <int>[
            //     2,
            //     4,
            //   ],
            //   onRowsPerPageChanged: (int? rowsPerPage) {},
            //   onPageChanged: (int rowIndex) {},
            //   onSelectAll: (bool? value) {},
            //   columns: const <DataColumn2>[
            //     DataColumn2(label: Text('Name')),
            //     DataColumn2(label: Text('Calories'), numeric: true),
            //     DataColumn2(label: Text('Generation')),
            //   ],
            // )

            buildAsyncPaginatedTable(
                showPage: false,
                showGeneration: false,
                showPageSizeSelector: true,
                source: source,
                onSelectAll: (val) {
                  if (val ?? false) {
                    source.selectAll();
                  } else {
                    source.deselectAll();
                  }
                }));
  }
}
