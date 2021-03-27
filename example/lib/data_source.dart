import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

class RestorableDessertSelections extends RestorableProperty<Set<int>> {
  Set<int> _dessertSelections = {};

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _dessertSelections.contains(index);

  /// Takes a list of [Dessert]s and saves the row indices of selected rows
  /// into a [Set].
  void setDessertSelections(List<Dessert> desserts) {
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

class Dessert {
  Dessert(
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

class DessertDataSource extends DataTableSource {
  DessertDataSource(this.context) {
    desserts = <Dessert>[
      Dessert(
        'Frozen Yogurt',
        159,
        6.0,
        24,
        4.0,
        87,
        14,
        1,
      ),
      Dessert(
        'Ice Cream Sandwich',
        237,
        9.0,
        37,
        4.3,
        129,
        8,
        1,
      ),
      Dessert(
        'Eclair',
        262,
        16.0,
        24,
        6.0,
        337,
        6,
        7,
      ),
      Dessert(
        'Cupcake',
        305,
        3.7,
        67,
        4.3,
        413,
        3,
        8,
      ),
      Dessert(
        'Gingerbread',
        356,
        16.0,
        49,
        3.9,
        327,
        7,
        16,
      ),
      Dessert(
        'Jelly Bean',
        375,
        0.0,
        94,
        0.0,
        50,
        0,
        0,
      ),
      Dessert(
        'Lollipop',
        392,
        0.2,
        98,
        0.0,
        38,
        0,
        2,
      ),
      Dessert(
        'Honeycomb',
        408,
        3.2,
        87,
        6.5,
        562,
        0,
        45,
      ),
      Dessert(
        'Donut',
        452,
        25.0,
        51,
        4.9,
        326,
        2,
        22,
      ),
      Dessert(
        'Apple Pie',
        518,
        26.0,
        65,
        7.0,
        54,
        12,
        6,
      ),
      Dessert(
        'Frozen Yougurt with sugar',
        168,
        6.0,
        26,
        4.0,
        87,
        14,
        1,
      ),
      Dessert(
        'Ice Cream Sandich with sugar',
        246,
        9.0,
        39,
        4.3,
        129,
        8,
        1,
      ),
      Dessert(
        'Eclair with sugar',
        271,
        16.0,
        26,
        6.0,
        337,
        6,
        7,
      ),
      Dessert(
        'Cupcake with sugar',
        314,
        3.7,
        69,
        4.3,
        413,
        3,
        8,
      ),
      Dessert(
        'Gingerbread with sugar',
        345,
        16.0,
        51,
        3.9,
        327,
        7,
        16,
      ),
      Dessert(
        'Jelly Bean with sugar',
        364,
        0.0,
        96,
        0.0,
        50,
        0,
        0,
      ),
      Dessert(
        'Lollipop with sugar',
        401,
        0.2,
        100,
        0.0,
        38,
        0,
        2,
      ),
      Dessert(
        'Honeycomd with sugar',
        417,
        3.2,
        89,
        6.5,
        562,
        0,
        45,
      ),
      Dessert(
        'Donut with sugar',
        461,
        25.0,
        53,
        4.9,
        326,
        2,
        22,
      ),
      Dessert(
        'Apple pie with sugar',
        527,
        26.0,
        67,
        7.0,
        54,
        12,
        6,
      ),
      Dessert(
        'Forzen yougurt with honey',
        223,
        6.0,
        36,
        4.0,
        87,
        14,
        1,
      ),
      Dessert(
        'Ice Cream Sandwich with honey',
        301,
        9.0,
        49,
        4.3,
        129,
        8,
        1,
      ),
      Dessert(
        'Eclair with honey',
        326,
        16.0,
        36,
        6.0,
        337,
        6,
        7,
      ),
      Dessert(
        'Cupcake with honey',
        369,
        3.7,
        79,
        4.3,
        413,
        3,
        8,
      ),
      Dessert(
        'Gignerbread with hone',
        420,
        16.0,
        61,
        3.9,
        327,
        7,
        16,
      ),
      Dessert(
        'Jelly Bean with honey',
        439,
        0.0,
        106,
        0.0,
        50,
        0,
        0,
      ),
      Dessert(
        'Lollipop with honey',
        456,
        0.2,
        110,
        0.0,
        38,
        0,
        2,
      ),
      Dessert(
        'Honeycomd with honey',
        472,
        3.2,
        99,
        6.5,
        562,
        0,
        45,
      ),
      Dessert(
        'Donut with honey',
        516,
        25.0,
        63,
        4.9,
        326,
        2,
        22,
      ),
      Dessert(
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
  late List<Dessert> desserts;

  void sort<T>(Comparable<T> Function(Dessert d) getField, bool ascending) {
    desserts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;
  void updateSelectedDesserts(RestorableDessertSelections selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
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
    if (index >= desserts.length) throw 'index > _desserts.length';
    final dessert = desserts[index];
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

  // @override
  // DataRow2 getRow2(int index) {
  //   final format = NumberFormat.decimalPercentPattern(
  //     locale: 'en',
  //     decimalDigits: 0,
  //   );
  //   assert(index >= 0);
  //   if (index >= desserts.length) throw 'index > _desserts.length';
  //   final dessert = desserts[index];
  //   return DataRow2.byIndex(
  //     index: index,
  //     selected: dessert.selected,
  //     onSelectChanged: (value) {
  //       if (dessert.selected != value) {
  //         _selectedCount += value! ? 1 : -1;
  //         assert(_selectedCount >= 0);
  //         dessert.selected = value;
  //         notifyListeners();
  //       }
  //     },
  //     cells: [
  //       DataCell(Text(dessert.name)),
  //       DataCell(Text('${dessert.calories}')),
  //       DataCell(Text(dessert.fat.toStringAsFixed(1))),
  //       DataCell(Text('${dessert.carbs}')),
  //       DataCell(Text(dessert.protein.toStringAsFixed(1))),
  //       DataCell(Text('${dessert.sodium}')),
  //       DataCell(Text('${format.format(dessert.calcium / 100)}')),
  //       DataCell(Text('${format.format(dessert.iron / 100)}')),
  //     ],
  //   );
  // }

  @override
  int get rowCount => desserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void selectAll(bool? checked) {
    for (final dessert in desserts) {
      dessert.selected = checked ?? false;
    }
    _selectedCount = (checked ?? false) ? desserts.length : 0;
    notifyListeners();
  }
}

// END
