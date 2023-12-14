import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class PageNumber extends StatefulWidget {
  const PageNumber({
    super.key,
    required PaginatorController controller,
  }) : _controller = controller;

  final PaginatorController _controller;

  @override
  PageNumberState createState() => PageNumberState();
}

class PageNumberState extends State<PageNumber> {
  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget._controller.addListener(update);
  }

  @override
  void dispose() {
    widget._controller.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Checking instance id to see if build is called
    // on different ones
    // Due to some reasons when using this widget
    // with AsyncPaginatedDatatable2 the widget is instatiotaed once
    // though it's state is created 3 times upon first loading
    // of the Custom pager example
    // print(identityHashCode(this));
    return Text(widget._controller.isAttached
        ? 'Page: ${1 + ((widget._controller.currentRowIndex + 1) / widget._controller.rowsPerPage).floor()} of '
            '${(widget._controller.rowCount / widget._controller.rowsPerPage).ceil()}'
        : 'Page: x of y');
  }
}

class CustomPager extends StatefulWidget {
  const CustomPager(this.controller, {super.key});

  final PaginatorController controller;

  @override
  CustomPagerState createState() => CustomPagerState();
}

class CustomPagerState extends State<CustomPager> {
  static const List<int> _availableSizes = [3, 5, 10, 20];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // skip this build pass
    if (!widget.controller.isAttached) return const SizedBox();
    return Container(
      width: 220,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 4,
            offset: const Offset(4, 8), // Shadow position
          ),
        ],
      ),
      child: Theme(
          data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: Colors.white),
              textTheme:
                  const TextTheme(titleMedium: TextStyle(color: Colors.white))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () => widget.controller.goToFirstPage(),
                  icon: const Icon(Icons.skip_previous)),
              IconButton(
                  onPressed: () => widget.controller.goToPreviousPage(),
                  icon: const Icon(Icons.chevron_left_sharp)),
              DropdownButton<int>(
                  onChanged: (v) => widget.controller.setRowsPerPage(v!),
                  value: _availableSizes.contains(widget.controller.rowsPerPage)
                      ? widget.controller.rowsPerPage
                      : _availableSizes[0],
                  dropdownColor: Colors.grey[800],
                  items: _availableSizes
                      .map((s) => DropdownMenuItem<int>(
                            value: s,
                            child: Text(s.toString()),
                          ))
                      .toList()),
              IconButton(
                  onPressed: () => widget.controller.goToNextPage(),
                  icon: const Icon(Icons.chevron_right_sharp)),
              IconButton(
                  onPressed: () => widget.controller.goToLastPage(),
                  icon: const Icon(Icons.skip_next))
            ],
          )),
    );
  }
}
