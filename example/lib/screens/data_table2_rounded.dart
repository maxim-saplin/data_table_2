import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../data_sources.dart';

class DataTable2RoundedDemo extends StatefulWidget {
  const DataTable2RoundedDemo({super.key});

  @override
  DataTable2RoundedDemoState createState() => DataTable2RoundedDemoState();
}

class DataTable2RoundedDemoState extends State<DataTable2RoundedDemo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dessertsDataSource = DessertDataSource(context);
      _initialized = true;
      _dessertsDataSource.addListener(() {
        setState(() {});
      });
    }
  }

  void _sort<T>(
    Comparable<T> Function(Dessert d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dessertsDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void dispose() {
    _dessertsDataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DataTable2(
        // Forcing all scrollbars to be visible, alternatively themes can be used (see above)
        headingRowColor:
            WidgetStateColor.resolveWith((states) => Colors.transparent),
        columnSpacing: 12,
        horizontalMargin: 12,
        border: TableBorder(
            left: BorderSide(color: Colors.black.withAlpha(5)),
            right: BorderSide(color: Colors.black.withAlpha(5)),
            verticalInside: BorderSide(color: Colors.black.withAlpha(10)),
            horizontalInside: BorderSide(color: Colors.black.withAlpha(10))),
        bottomMargin: 10,
        minWidth: 900,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        onSelectAll: (val) =>
            setState(() => _dessertsDataSource.selectAll(val)),
        columns: [
          DataColumn2(
            label: const Text('Desert'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) =>
                _sort<String>((d) => d.name, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Calories'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.calories, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Fat (gm)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.fat, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Carbs (gm)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.carbs, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Protein (gm)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.protein, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Sodium (mg)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.sodium, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Calcium (%)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.calcium, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Iron (%)'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((d) => d.iron, columnIndex, ascending),
          ),
        ],
        rows: List<DataRow>.generate(
            _dessertsDataSource.rowCount,
            (index) => _dessertsDataSource.getRow(index).clone(
                decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.grey.withAlpha(100), width: 19),
                            borderRadius: BorderRadius.circular(8)) +
                        const Border.symmetric(
                          vertical:
                              BorderSide(color: Colors.transparent, width: 3.5),
                          horizontal:
                              BorderSide(color: Colors.transparent, width: 5.0),
                        )))),
      ),
    );
  }
}
