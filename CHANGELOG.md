## 2.3.10
- Added dividerThickness to paginated widgets
- renderEmptyRowsInTheEnd now allows to override the default behaviour of paginated tables when empty rows are added in otder to fill pages to page size

## 2.3.9
- Added fixed sections params to PaginatedDataTable2 and AsyncPaginatedDataTable2 (fixedLeftColumns, fixedTopRows, fixedColumnsColor, fixedCornerColor)

## 2.3.8
- Fixed horizontal divider not being displayed in fixed column cells when fixedColumnColor was defined
- Aligned/refactored fixed sections colors (headingColor, fixedRowColor, fixedColumnColor)
 - Now headingColor is applied to all fixed rows, before it was only applied to all rows
 - Fixed colors now take precedence despite any color overrides (e.g. DataRow.color)
- Added few golden tests

## 2.3.7
- Row tap events now do not bubble onSelectChanged() event handler, yet it still fires if there's a checkbox column and a checkbox is clicked (PR #133)

## 2.3.6
-  Added sortArrowIcon and sortArrowAnimationDuration properties

## 2.3.5
- Refactored scroll syncing approach, no static workaround and potential memleaks
- Fixed locked scrolling when bouncing on iOS (#113)

## 2.3.4
- Fix for #111, synchronized scroll position for left fixed column with core table when fixed column is added and core table is already scrolled

## 2.3.3
- Fixed column width/applying border to heading rows in case there're no data rows provided (#108)

## 2.3.2
- Fixed horizontal scrolling not working (jumping\stuttering with small shifts) on Android and iOS

## 2.3.1
- Changed readme, added notes regarding putting the widgets inside scrollable and Column

## 2.3.0
- Added fixed columns (DataTable2.fixedLeftColumns)
- Number of fixed rows can now be changed (DataTable2.fixedTopRows)
- Background color of fixed columns and fixed corner (when both fixed cols and rows are used)

## 2.2.3
- Added Border and Zebra stripes sample, removed Borders sample
- Refactored row/cell tap events, event bubbling added, no hovering effect is visible if there're no tap events in the tables

## 2.2.2
- Added PaginatedDataTable2.headingRowColor property
- DataColumn2.fixedWidth - set column's width as absolute value
- Upgrade to Flutter 3.0 and Dart 2.17.0
- Added flutter_lints
- Changed constructors to inline super params

## 2.2.1
- DataRow2.specificRowHeight allows overriding default row height for any row. The feature allows to have arbitrary heights of rows rather then same height for every row
- Added example for DataRow2.specificRowHeight

## 2.2.0
- Asynchronous data fetching model via AsyncDataTableSource and tailored widget AsyncPaginatedDataTable2, added related examples
- Change of package exports (no need to import paginated_data_table_2.dart, data_table_2.dart now has all widgets)
- Fixed broken initial sort arrow direction in column header after 1st rebuild, added default sorting example to PaginatedDataTable2
- Draggable horizontal scroll bar Issues #42
- More kinds of tap events on cells and rows


## 2.1.1
- PaginatorController that allows externally control PaginatedDataTable2 state (e.g. switch pages, change page size etc.)
- Custom paginator example for PaginatedDataTable2

## 2.1.0
- `autoRowsToHeight` property on PaginatedDataTable2 that allows the widget to auto calculate page size depending on how much rows fit the height and allow to bypass vertical scrolling
- More examples
- Better test coverage
- Aligned with Flutter 2.1.0 DataTable/PaginatedDataTable2 APIs

## 2.0.4
- `empty` constructor param & property which defines allows to define placeholder widget to be displayed when there're no rows to be displayed
- `smRatio` and `lmRatio` constructor params & properties which allow to defined width ratios of DataColumn2 S, M and L 
sizes
- `border` constructor param & property allowing to define vertical an horizontal, inner and outer table borders

## 2.0.3

Added DataTable2.scrollController and PaginatedDataTable2.scrollController property, added scroll-up example

## 2.0.2

Added DataTable2.bottomMargin property

## 2.0.1

Fixed horizontalMargin (it was not accounted for when calculating column sizes, first and last columns where shrunk by this value)

## 2.0.0

Perf. optimization of DataTable.build(), finishing off the package for roll-out to pub.dev

## 2.0.0-dev.1

The very first release to pub.dev

!NOTE: the package is based of Flutter 2.1 sources codes