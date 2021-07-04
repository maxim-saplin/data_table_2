import 'package:example/data_table2_scrollup.dart';
import 'package:example/data_table2_tests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'async_paginated_data_table2.dart';
import 'data_table2.dart';
import 'data_table2_simple.dart';
import 'isEmptyArg.dart';
import 'paginated_data_table2.dart';
import 'data_table.dart';
import 'paginated_data_table.dart';

void main() {
  runApp(MyApp());
}

const String initialRoute = '/datatable2';

Scaffold _getScaffold(BuildContext context, Widget body,
    [bool isAllowEmpty = false]) {
  var isEmpty = getIsEmpty(context);
  return Scaffold(
    appBar: AppBar(
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
            color: Colors.grey[850],
            child: DropdownButton<String>(
              icon: Icon(Icons.arrow_forward),
              dropdownColor: Colors.grey[800],
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white),
              value: _getCurrentRoute(context),
              onChanged: (v) {
                Navigator.of(context).pushNamed(v!);
              },
              items: [
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
                DropdownMenuItem(
                  child: Text('Unit Tests Preview'),
                  value: '/datatable2tests',
                ),
              ],
            )),
        isAllowEmpty
            ? Container(
                padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: DropdownButton<bool>(
                    icon: SizedBox(),
                    dropdownColor: Colors.grey[300],
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: Colors.black),
                    value: isEmpty,
                    onChanged: (v) {
                      var r = _getCurrentRoute(context);
                      var flag = v ?? false;
                      if (flag) {
                        Navigator.of(context).pushNamed(r, arguments: true);
                      } else {
                        Navigator.of(context).pushNamed(r, arguments: false);
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        child: Text('With data'),
                        value: false,
                      ),
                      DropdownMenuItem(
                        child: Text('No data'),
                        value: true,
                      )
                    ]))
            : SizedBox()
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
        '/datatable2': (context) =>
            _getScaffold(context, DataTable2Demo(), true),
        '/datatable2simple': (context) =>
            _getScaffold(context, DataTable2SimpleDemo()),
        '/datatable2scrollup': (context) =>
            _getScaffold(context, DataTable2ScrollupDemo()),
        '/paginated2': (context) =>
            _getScaffold(context, PaginatedDataTable2Demo(), true),
        '/asyncpaginated2': (context) =>
            _getScaffold(context, AsyncPaginatedDataTable2Demo(), true),
        '/datatable': (context) => _getScaffold(context, DataTableDemo()),
        '/paginated': (context) =>
            _getScaffold(context, PaginatedDataTableDemo()),
        '/datatable2tests': (context) =>
            _getScaffold(context, DataTable2Tests()),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('be', ''),
        const Locale('ru', ''),
      ],
      // change to see how PaginatedDataTable2 controls (e.g. Rows per page) get translated
      locale: Locale('en', ''),
    );
  }
}
