## 2.2.0
- Asycnhronous data fecthing model via AsyncDataTableSource and tailored widget AsyncPaginatedDataTable2, added related examples
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
- `empty` constructir param & property which defines allows to define placeholder widget to be displayed when there're no rows to be displayed
- `smRatio` and `lmRatio` constructor params & properties which allow to defined width ratios of DataColumn2 S, M and L 
sizes
- `border` constructructor param & property allowing to define vertilca an horizontal, inner and outer table borders

## 2.0.3

Added DataTable2.scrollController and PaginatedDataTable2.scrollController property, added scroll-up example

## 2.0.2

Added DataTable2.bottomMargin property

## 2.0.1

Fixed horizonalMargin (it was not accounted for when calculating column sizes, first and last columns where shrinked by this value)

## 2.0.0

Perf. optimization of DataTable.build(), finishing off the package for roll-out to pub.dev

## 2.0.0-dev.1

The very first relase to pub.dev

!NOTE: the package is based of Flutter 2.1 sources codes