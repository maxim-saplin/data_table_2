import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class DataTableDemo extends StatefulWidget {
  const DataTableDemo();

  @override
  _DataTableDemoState createState() => _DataTableDemoState();
}

class _RestorableDessertSelections extends RestorableProperty<Set<int>> {
  Set<int> _dessertSelections = {};

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _dessertSelections.contains(index);

  /// Takes a list of [_Dessert]s and saves the row indices of selected rows
  /// into a [Set].
  void setDessertSelections(List<_Dessert> desserts) {
    final updatedSet = <int>{};
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (dessert.selected) {
        updatedSet.add(i);
      }
    }
    _dessertSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _dessertSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _dessertSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _dessertSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _dessertSelections = value;
  }

  @override
  Object toPrimitives() => _dessertSelections.toList();
}

class _DataTableDemoState extends State<DataTableDemo> with RestorationMixin {
  final _RestorableDessertSelections _dessertSelections =
      _RestorableDessertSelections();
  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage =
      RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableIntN _sortColumnIndex = RestorableIntN(null);
  late _DessertDataSource _dessertsDataSource;
  bool initialized = false;

  @override
  String get restorationId => 'data_table_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_dessertSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    if (!initialized) {
      _dessertsDataSource = _DessertDataSource(context);
      initialized = true;
    }
    switch (_sortColumnIndex.value) {
      case 0:
        _dessertsDataSource._sort<String>((d) => d.name, _sortAscending.value);
        break;
      case 1:
        _dessertsDataSource._sort<num>((d) => d.calories, _sortAscending.value);
        break;
      case 2:
        _dessertsDataSource._sort<num>((d) => d.fat, _sortAscending.value);
        break;
      case 3:
        _dessertsDataSource._sort<num>((d) => d.carbs, _sortAscending.value);
        break;
      case 4:
        _dessertsDataSource._sort<num>((d) => d.protein, _sortAscending.value);
        break;
      case 5:
        _dessertsDataSource._sort<num>((d) => d.sodium, _sortAscending.value);
        break;
      case 6:
        _dessertsDataSource._sort<num>((d) => d.calcium, _sortAscending.value);
        break;
      case 7:
        _dessertsDataSource._sort<num>((d) => d.iron, _sortAscending.value);
        break;
    }
    _dessertsDataSource.updateSelectedDesserts(_dessertSelections);
    _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      _dessertsDataSource = _DessertDataSource(context);
      initialized = true;
    }
    _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
  }

  void _updateSelectedDessertRowListener() {
    _dessertSelections.setDessertSelections(_dessertsDataSource._desserts);
  }

  void _sort<T>(
    Comparable<T> Function(_Dessert d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dessertsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex.value = columnIndex;
      _sortAscending.value = ascending;
    });
  }

  @override
  void dispose() {
    _rowsPerPage.dispose();
    _sortColumnIndex.dispose();
    _sortAscending.dispose();
    _dessertsDataSource.removeListener(_updateSelectedDessertRowListener);
    _dessertsDataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      restorationId: 'data_table_list_view',
      padding: const EdgeInsets.all(16),
      children: [
        DataTable(
            sortColumnIndex: _sortColumnIndex.value,
            sortAscending: _sortAscending.value,
            onSelectAll: _dessertsDataSource._selectAll,
            columns: [
              DataColumn(
                label: Text('Desert'),
                onSort: (columnIndex, ascending) =>
                    _sort<String>((d) => d.name, columnIndex, ascending),
              ),
              DataColumn(
                label: Text('Calories'),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.calories, columnIndex, ascending),
              ),
              DataColumn(
                label: Text('Fat (gm)'),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.fat, columnIndex, ascending),
              ),
              DataColumn(
                label: Text('Carbs (gm)'),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.carbs, columnIndex, ascending),
              ),
              DataColumn(
                label: Text('Protein (gm)'),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.protein, columnIndex, ascending),
              ),
              DataColumn(
                label: Text('Sodium (mg)'),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.sodium, columnIndex, ascending),
              ),
              DataColumn(
                label: Text('Calcium (%)'),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.calcium, columnIndex, ascending),
              ),
              DataColumn(
                label: Text('Iron (%)'),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.iron, columnIndex, ascending),
              ),
            ],
            rows: List<DataRow>.generate(_dessertsDataSource.rowCount,
                (index) => _dessertsDataSource.getRow(index))),
      ],
    );
  }
}

class _Dessert {
  _Dessert(
    this.name,
    this.calories,
    this.fat,
    this.carbs,
    this.protein,
    this.sodium,
    this.calcium,
    this.iron,
  );

  final String name;
  final int calories;
  final double fat;
  final int carbs;
  final double protein;
  final int sodium;
  final int calcium;
  final int iron;
  bool selected = false;
}

class _DessertDataSource extends DataTableSource {
  _DessertDataSource(this.context) {
    _desserts = <_Dessert>[
      _Dessert(
        'localizations.dataTableRowFrozenYogurt',
        159,
        6.0,
        24,
        4.0,
        87,
        14,
        1,
      ),
      _Dessert(
        'localizations.dataTableRowIceCreamSandwich',
        237,
        9.0,
        37,
        4.3,
        129,
        8,
        1,
      ),
      _Dessert(
        'localizations.dataTableRowEclair',
        262,
        16.0,
        24,
        6.0,
        337,
        6,
        7,
      ),
      _Dessert(
        'localizations.dataTableRowCupcake',
        305,
        3.7,
        67,
        4.3,
        413,
        3,
        8,
      ),
      _Dessert(
        'localizations.dataTableRowGingerbread',
        356,
        16.0,
        49,
        3.9,
        327,
        7,
        16,
      ),
      _Dessert(
        'localizations.dataTableRowJellyBean',
        375,
        0.0,
        94,
        0.0,
        50,
        0,
        0,
      ),
      _Dessert(
        'localizations.dataTableRowLollipop',
        392,
        0.2,
        98,
        0.0,
        38,
        0,
        2,
      ),
      _Dessert(
        'localizations.dataTableRowHoneycomb',
        408,
        3.2,
        87,
        6.5,
        562,
        0,
        45,
      ),
      _Dessert(
        'localizations.dataTableRowDonut',
        452,
        25.0,
        51,
        4.9,
        326,
        2,
        22,
      ),
      _Dessert(
        'localizations.dataTableRowApplePie',
        518,
        26.0,
        65,
        7.0,
        54,
        12,
        6,
      ),
      _Dessert(
        'Frozen yougurt with sugar',
        168,
        6.0,
        26,
        4.0,
        87,
        14,
        1,
      ),
      _Dessert(
        'Ice Cream Sandich with sugar',
        246,
        9.0,
        39,
        4.3,
        129,
        8,
        1,
      ),
      _Dessert(
        'Eclair with sugar',
        271,
        16.0,
        26,
        6.0,
        337,
        6,
        7,
      ),
      _Dessert(
        'Cupcake with sugar',
        314,
        3.7,
        69,
        4.3,
        413,
        3,
        8,
      ),
      _Dessert(
        'Gingerbread with sugar',
        345,
        16.0,
        51,
        3.9,
        327,
        7,
        16,
      ),
      _Dessert(
        'Jelly Bean with sugar',
        364,
        0.0,
        96,
        0.0,
        50,
        0,
        0,
      ),
      _Dessert(
        'Lollipop with sugar',
        401,
        0.2,
        100,
        0.0,
        38,
        0,
        2,
      ),
      _Dessert(
        'Honeycomd with sugar',
        417,
        3.2,
        89,
        6.5,
        562,
        0,
        45,
      ),
      _Dessert(
        'Donut with sugar',
        461,
        25.0,
        53,
        4.9,
        326,
        2,
        22,
      ),
      _Dessert(
        'Apple pie with sugar',
        527,
        26.0,
        67,
        7.0,
        54,
        12,
        6,
      ),
      _Dessert(
        'Forzen yougurt with honey',
        223,
        6.0,
        36,
        4.0,
        87,
        14,
        1,
      ),
      _Dessert(
        'Ice Cream Sandwich with honey',
        301,
        9.0,
        49,
        4.3,
        129,
        8,
        1,
      ),
      _Dessert(
        'Eclair with honey',
        326,
        16.0,
        36,
        6.0,
        337,
        6,
        7,
      ),
      _Dessert(
        'Cupcake with honey',
        369,
        3.7,
        79,
        4.3,
        413,
        3,
        8,
      ),
      _Dessert(
        'Gignerbread with hone',
        420,
        16.0,
        61,
        3.9,
        327,
        7,
        16,
      ),
      _Dessert(
        'Jelly Bean with honey',
        439,
        0.0,
        106,
        0.0,
        50,
        0,
        0,
      ),
      _Dessert(
        'Lollipop with honey',
        456,
        0.2,
        110,
        0.0,
        38,
        0,
        2,
      ),
      _Dessert(
        'Honeycomd with honey',
        472,
        3.2,
        99,
        6.5,
        562,
        0,
        45,
      ),
      _Dessert(
        'Donut with honey',
        516,
        25.0,
        63,
        4.9,
        326,
        2,
        22,
      ),
      _Dessert(
        'Apple pie with honey',
        582,
        26.0,
        77,
        7.0,
        54,
        12,
        6,
      ),
    ];
  }

  final BuildContext context;
  late List<_Dessert> _desserts;

  void _sort<T>(Comparable<T> Function(_Dessert d) getField, bool ascending) {
    _desserts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;
  void updateSelectedDesserts(_RestorableDessertSelections selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < _desserts.length; i += 1) {
      var dessert = _desserts[i];
      if (selectedRows.isSelected(i)) {
        dessert.selected = true;
        _selectedCount += 1;
      } else {
        dessert.selected = false;
      }
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final format = NumberFormat.decimalPercentPattern(
      locale: 'en',
      decimalDigits: 0,
    );
    assert(index >= 0);
    if (index >= _desserts.length) throw 'index > _desserts.length';
    final dessert = _desserts[index];
    return DataRow.byIndex(
      index: index,
      selected: dessert.selected,
      onSelectChanged: (value) {
        if (dessert.selected != value) {
          _selectedCount += value! ? 1 : -1;
          assert(_selectedCount >= 0);
          dessert.selected = value;
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text(dessert.name)),
        DataCell(Text('${dessert.calories}')),
        DataCell(Text(dessert.fat.toStringAsFixed(1))),
        DataCell(Text('${dessert.carbs}')),
        DataCell(Text(dessert.protein.toStringAsFixed(1))),
        DataCell(Text('${dessert.sodium}')),
        DataCell(Text('${format.format(dessert.calcium / 100)}')),
        DataCell(Text('${format.format(dessert.iron / 100)}')),
      ],
    );
  }

  @override
  int get rowCount => _desserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool? checked) {
    for (final dessert in _desserts) {
      dessert.selected = checked ?? false;
    }
    _selectedCount = (checked ?? false) ? _desserts.length : 0;
    notifyListeners();
  }
}

// END
