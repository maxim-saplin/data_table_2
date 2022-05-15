import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_helper.dart';
import 'screens/async_paginated_data_table2.dart';
import 'screens/data_table.dart';
import 'screens/data_table2.dart';
import 'screens/data_table2_scrollup.dart';
import 'screens/data_table2_simple.dart';
import 'screens/data_table2_tests.dart';
import 'screens/paginated_data_table.dart';
import 'screens/paginated_data_table2.dart';

void main() {
  runApp(MyApp());
}

const String initialRoute = '/datatable2';

Scaffold _getScaffold(BuildContext context, Widget body,
    [List<String>? options]) {
  var defaultOption = getCurrentRouteOption(context);
  if (defaultOption.isEmpty && options != null && options.isNotEmpty) {
    defaultOption = options[0];
  }
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.grey[200],
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            color: Colors.grey[850],
            //screen selection
            child: DropdownButton<String>(
              icon: const Icon(Icons.arrow_forward),
              dropdownColor: Colors.grey[800],
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white),
              value: _getCurrentRoute(context),
              onChanged: (v) {
                Navigator.of(context).pushNamed(v!);
              },
              items: const [
                DropdownMenuItem(
                  value: '/datatable2',
                  child: Text('DataTable2'),
                ),
                DropdownMenuItem(
                  value: '/datatable2simple',
                  child: Text('DataTable2 Simple'),
                ),
                DropdownMenuItem(
                  value: '/datatable2scrollup',
                  child: Text('DataTable2 Scroll-up'),
                ),
                DropdownMenuItem(
                  value: '/paginated2',
                  child: Text('PaginatedDataTable2'),
                ),
                DropdownMenuItem(
                  value: '/asyncpaginated2',
                  child: Text('AsyncPaginatedDataTable2'),
                ),
                DropdownMenuItem(
                  value: '/datatable',
                  child: Text('DataTable'),
                ),
                DropdownMenuItem(
                  value: '/paginated',
                  child: Text('PaginatedDataTable'),
                ),
                if (kDebugMode)
                  DropdownMenuItem(
                    value: '/datatable2tests',
                    child: Text('Unit Tests Preview'),
                  ),
              ],
            )),
        options != null && options.isNotEmpty
            ? Container(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                // screen options
                child: DropdownButton<String>(
                    icon: const SizedBox(),
                    dropdownColor: Colors.grey[300],
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: Colors.black),
                    value: defaultOption,
                    onChanged: (v) {
                      var r = _getCurrentRoute(context);
                      Navigator.of(context).pushNamed(r, arguments: v);
                    },
                    items: options
                        .map<DropdownMenuItem<String>>(
                            (v) => DropdownMenuItem<String>(
                                  value: v,
                                  child: Text(v),
                                ))
                        .toList()))
            : const SizedBox()
      ]),
    ),
    body: body,
  );
}

String _getCurrentRoute(BuildContext context) {
  return ModalRoute.of(context) != null &&
          ModalRoute.of(context)!.settings.name != null
      ? ModalRoute.of(context)!.settings.name!
      : initialRoute;
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'main',
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.grey[300],
      ),
      initialRoute: initialRoute,
      routes: {
        '/datatable2': (context) => _getScaffold(
            context, const DataTable2Demo(), getOptionsForRoute('/datatable2')),
        '/datatable2simple': (context) =>
            _getScaffold(context, const DataTable2SimpleDemo()),
        '/datatable2scrollup': (context) =>
            _getScaffold(context, const DataTable2ScrollupDemo()),
        '/paginated2': (context) => _getScaffold(context,
            const PaginatedDataTable2Demo(), getOptionsForRoute('/paginated2')),
        '/asyncpaginated2': (context) => _getScaffold(
            context,
            const AsyncPaginatedDataTable2Demo(),
            getOptionsForRoute('/asyncpaginated2')),
        '/datatable': (context) => _getScaffold(context, const DataTableDemo()),
        '/paginated': (context) =>
            _getScaffold(context, const PaginatedDataTableDemo()),
        '/datatable2tests': (context) =>
            _getScaffold(context, const DataTable2Tests()),
      },
      supportedLocales: const [
        Locale('en', ''),
        Locale('be', ''),
        Locale('ru', ''),
      ],
      // change to see how PaginatedDataTable2 controls (e.g. Rows per page) get translated
      locale: const Locale('en', ''),
    );
  }
}
