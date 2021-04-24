In-place replacement for Flutter's stock **DataTable** and **PaginatedDataTable** widgets with fixed/sticky header (also footer/paginator for **PaginatedDataTable**) and a few extra features.

# [LIVE DEMO](https://maxim-saplin.github.io/data_table_2/)
<img width="866" alt="image" src="https://user-images.githubusercontent.com/7947027/115952188-48c4e600-a4ed-11eb-9ff9-e5b4deaf9580.png">

You can reference the package and add '2' to the names of the stock widgets (making them **DataTable2** or **PaginatedDataTable2**) and that is it. The differences are:
- Sticky headers and paginator
- Vertiacally scrollable main area (with data rows)
- All columns are fixed width, table automatically stretches horizontaly, individual column width is determined as **(Width)/(Number of Columns)**
  - Should you want to adjust the size of columns, you can replace  **DataColumn** definitions with **DataColumn2** (which is a decendant of DataColumn). The class provides **size** property which can be set to one of 3 relative sizes (S, M and L)
  - You can limit the minimal width of the control and scroll it horizontaly if the viewport is narrow (by setting **minWidth** property) which is useful in portrait orientations with multiple columns
