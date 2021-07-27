In-place substitute for Flutter's stock **DataTable** and **PaginatedDataTable** widgets with fixed/sticky header/top row (footer/paginator for **PaginatedDataTable**) and a few extra features. **DataTable2** and **PaginatedDataTable2** widgets are based on the sources of Flutter's originals, mimic the API and provide seamless integration.

If you've been using (or considered using) standard Flutter's widgets for displaying tables/data grids and missed the sticky headers (or vertical border, 'no rows' placeholder etc.) - you've come to the right place. No need to learn yet another API of a new control, just stick to well described DataTable and PaginatedDataTable.

# [LIVE DEMO](https://maxim-saplin.github.io/data_table_2/)

<img width="866" alt="image" src="https://user-images.githubusercontent.com/7947027/115952188-48c4e600-a4ed-11eb-9ff9-e5b4deaf9580.png">

\- please check the [example folder](https://github.com/maxim-saplin/data_table_2/tree/main/example) which recreates the [Flutter Gallery's](https://gallery.flutter.dev/#/demo/data-table) Data Table sample (with PgaintedDataTable and DataSource) as well as has a few more samples. There's also a [DataGrid Sample](https://maxim-saplin.github.io/flutter_web_spa_sample/canvaskit/) in separate repo.

## Extra Features
- Sticky headers and paginator (when using `PabinatedDataTable2`)
- Vertiacally scrollable main area (with data rows)
  - `autoRowsToHeight` property on PaginatedDataTable2 allows to auto calculate page size depending on how much rows fit the height and makes vertical scrolling unnecessary
- All columns are fixed width, table automatically stretches horizontaly, individual column's width is determined as **(Width)/(Number of Columns)**
  - Should you want to adjust sizes of columns, you can replace `DataColumn` definitions with `DataColumn2` (which is a decendant of DataColumn). The class provides `size` property which can be set to one of 3 relative sizes (S, M and L)
  - Width ratios between Small and Medium, Large and Medium columns are defined by `smRatio` and `lmRatio` params
  - You can limit the minimal width of the control and scroll it horizontaly if the viewport is narrower (by setting `minWidth` property) which is useful in portrait orientations with multiple columns not fitting the screen
  - You can add bottom margin (by setting `bottomMargin` property) to allow slight overscroll
  - Fixed width columns are faster than default implementation of DataTable which does 2 passes to determine contents size and justify column widths
- Data rows are wrapped with `Flexible` and `SingleScrollView` widgets to allow widget fill parent container and be scrollable
  - Vertical scroller is exposed via table's `scrollController` property. See example 'DataTable2 - Scroll-up' which shows 'up' button when scrolling down and allows to jump to the top of the table
  - `PaginatedDataTable2.fit` property controls whether the paginator sticks to the bottom and leaves a gap to data rows above
- There's `DataRow2` alternative to stock `DataRow` which provides row level tap events (including right clicks)
- `empty` property which allows defining a placeholder widget to be displayed when data source is empty
- `border` allows drawing inner and outer vertical and horizontal borders (e.g. outlining individual cells) - stock widgets only allow drawing horizontal row splitters


## Usage

1. Add reference to pubspec.yaml.

2. Import:
```dart
import 'package:data_table_2/data_table_2.dart';
```

3. Code:
```dart
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Example without datasource
class DataTable2SimpleDemo extends StatelessWidget {
  const DataTable2SimpleDemo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          columns: [
            DataColumn2(
              label: Text('Column A'),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: Text('Column B'),
            ),
            DataColumn(
              label: Text('Column C'),
            ),
            DataColumn(
              label: Text('Column D'),
            ),
            DataColumn(
              label: Text('Column NUMBERS'),
              numeric: true,
            ),
          ],
          rows: List<DataRow>.generate(
              100,
              (index) => DataRow(cells: [
                    DataCell(Text('A' * (10 - index % 10))),
                    DataCell(Text('B' * (10 - (index + 5) % 10))),
                    DataCell(Text('C' * (15 - (index + 5) % 10))),
                    DataCell(Text('D' * (15 - (index + 10) % 10))),
                    DataCell(Text(((index + 0.1) * 25.4).toString()))
                  ]))),
    );
  }
}

```
If you're already using the standard widgets you can reference the package and add '2' to the names of stock widgets (making them **DataTable2** or **PaginatedDataTable2**) and that is it. 
