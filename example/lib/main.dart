import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  runApp(const MyApp());
}

const String initialRoute = '/datatable2';

Scaffold _getScaffold(BuildContext context, Widget body, [List<String>? options]) {
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
              style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
              value: _getCurrentRoute(context),
              onChanged: (v) {
                Navigator.of(context).pushNamed(v!);
              },
              items: const [
                DropdownMenuItem(
                  child: Text('DataTable2'),
                  value: '/datatable2',
                ),
                DropdownMenuItem(
                  child: Text('DataTable2 Simple'),
                  value: '/datatable2simple',
                ),
                DropdownMenuItem(
                  child: Text('DataTable2 Scroll-up'),
                  value: '/datatable2scrollup',
                ),
                DropdownMenuItem(
                  child: Text('PaginatedDataTable2'),
                  value: '/paginated2',
                ),
                DropdownMenuItem(
                  child: Text('AsyncPaginatedDataTable2'),
                  value: '/asyncpaginated2',
                ),
                DropdownMenuItem(
                  child: Text('DataTable'),
                  value: '/datatable',
                ),
                DropdownMenuItem(
                  child: Text('PaginatedDataTable'),
                  value: '/paginated',
                ),
                if (kDebugMode)
                  DropdownMenuItem(
                    child: Text('Unit Tests Preview'),
                    value: '/datatable2tests',
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
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black),
                    value: defaultOption,
                    onChanged: (v) {
                      var r = _getCurrentRoute(context);
                      Navigator.of(context).pushNamed(r, arguments: v);
                    },
                    items: options
                        .map<DropdownMenuItem<String>>((v) => DropdownMenuItem<String>(
                              child: Text(v),
                              value: v,
                            ))
                        .toList()))
            : const SizedBox()
      ]),
    ),
    body: body,
  );
}

String _getCurrentRoute(BuildContext context) {
  return ModalRoute.of(context) != null && ModalRoute.of(context)!.settings.name != null
      ? ModalRoute.of(context)!.settings.name!
      : initialRoute;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        '/datatable2': (context) => _getScaffold(context, const DataTable2Demo(), getOptionsForRoute('/datatable2')),
        '/datatable2simple': (context) => _getScaffold(context, const DataTable2SimpleDemo()),
        '/datatable2scrollup': (context) => _getScaffold(context, const DataTable2ScrollupDemo()),
        '/paginated2': (context) =>
            _getScaffold(context, const PaginatedDataTable2Demo(), getOptionsForRoute('/paginated2')),
        '/asyncpaginated2': (context) =>
            _getScaffold(context, const AsyncPaginatedDataTable2Demo(), getOptionsForRoute('/asyncpaginated2')),
        '/datatable': (context) => _getScaffold(context, const DataTableDemo()),
        '/paginated': (context) => _getScaffold(context, const PaginatedDataTableDemo()),
        '/datatable2tests': (context) => _getScaffold(context, const DataTable2Tests()),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
