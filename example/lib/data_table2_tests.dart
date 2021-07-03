import 'package:data_table_2/data_table_2.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Dessert {
  Dessert(this.name, this.calories, this.fat, this.carbs, this.protein,
      this.sodium, this.calcium, this.iron);

  final String name;
  final int calories;
  final double fat;
  final int carbs;
  final double protein;
  final int sodium;
  final int calcium;
  final int iron;
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
  const DataColumn2(
    label: Text('Name'),
    tooltip: 'Name',
  ),
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

DataTable2 buildDefaultTable(
    {int? sortColumnIndex, bool sortAscending = true}) {
  return DataTable2(
    sortColumnIndex: sortColumnIndex,
    sortAscending: sortAscending,
    onSelectAll: (bool? value) {},
    columns: testColumns,
    rows: testRows,
  );
}

class TestDataSource extends DataTableSource {
  TestDataSource({
    this.allowSelection = false,
  });

  final bool allowSelection;

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
    return DataRow.byIndex(
      index: index,
      selected: _selectedRows.contains(index),
      cells: <DataCell>[
        DataCell(Text(dessert.name)),
        DataCell(Text('${dessert.calories}')),
        DataCell(Text('${dessert.carbs}')),
      ],
      onSelectChanged: allowSelection
          ? (bool? selected) => _handleSelected(index, selected)
          : null,
    );
  }

  @override
  int get rowCount => 50 * kDesserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}

PaginatedDataTable2 buildDefaultPaginatedTable(
    {int? sortColumnIndex, bool sortAscending = true}) {
  return PaginatedDataTable2(
    horizontalMargin: 24,
    showCheckboxColumn: true,
    sortColumnIndex: sortColumnIndex,
    sortAscending: sortAscending,
    onSelectAll: (bool? value) {},
    columns: testColumns,
    source: TestDataSource(),
    showFirstLastButtons: true,
    rowsPerPage: 2,
  );
}

/// Example without datasource
class DataTable2Tests extends StatelessWidget {
  const DataTable2Tests();

  @override
  Widget build(BuildContext context) {
    //setColumnSizeRatios(1, 2);
    return Padding(
        padding: const EdgeInsets.all(16),
        child: buildDefaultPaginatedTable() //buildDefaultTable(),
        );
  }
}
