// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, Kristián Balaj, 2021

import 'package:data_table_2/data_table_2.dart';
import 'package:example/data/data_sources/restorable_dessert_selections.dart';
import 'package:example/data/models/dessert.dart';
import 'package:example/data/res/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Loading desserts with 3s delay on every page.
/// Other pages than the first one will return Future error to show the error builder.
class AsyncDessertDataSource extends AsyncDataTableSource {
  AsyncDessertDataSource.empty(this.context) {
    desserts = [];
  }

  AsyncDessertDataSource(this.context) {
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
  Future<List<DataRow>> getRows(int start, int end) {
    return Future.delayed(Duration(seconds: 3)).then(
      (_) {
        if (start > 0) {
          throw Exception(
              'An error occured while loading data. This is wanted behaviour to test errorBuilder :)');
        }

        final format = NumberFormat.decimalPercentPattern(
          locale: 'en',
          decimalDigits: 0,
        );

        return List.generate(end - start, (index) => index + start)
            .where((element) => element < desserts.length)
            .map(
              (index) => DataRow.byIndex(
                index: index,
                selected: desserts[index].selected,
                onSelectChanged: (value) {
                  if (desserts[index].selected != value) {
                    _selectedCount += value! ? 1 : -1;
                    assert(_selectedCount >= 0);
                    desserts[index].selected = value;
                    notifyListeners();
                  }
                },
                cells: [
                  DataCell(Text(desserts[index].name)),
                  DataCell(Text('${desserts[index].calories}')),
                  DataCell(Text(desserts[index].fat.toStringAsFixed(1))),
                  DataCell(Text('${desserts[index].carbs}')),
                  DataCell(Text(desserts[index].protein.toStringAsFixed(1))),
                  DataCell(Text('${desserts[index].sodium}')),
                  DataCell(
                      Text('${format.format(desserts[index].calcium / 100)}')),
                  DataCell(
                      Text('${format.format(desserts[index].iron / 100)}')),
                ],
              ),
            )
            .toList();
      },
    );
  }

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
