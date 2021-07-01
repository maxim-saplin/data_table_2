// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/data/data_sources/restorable_dessert_selections.dart';
import 'package:example/data/models/dessert.dart';
import 'package:example/data/res/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DessertDataSource extends DataTableSource {
  DessertDataSource.empty(this.context) {
    desserts = [];
  }

  DessertDataSource(this.context) {
    desserts = kDesserts;
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

  void updateSelectedDessertsFromSet(Set<int> selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (selectedRows.contains(i)) {
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
