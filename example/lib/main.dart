import 'package:example/data_table2_scrollup.dart';
import 'package:flutter/material.dart';

import 'data_table2.dart';
import 'data_table2_simple.dart';
import 'paginated_data_table2.dart';
import 'data_table.dart';
import 'paginated_data_table.dart';

void main() {
  runApp(MyApp());
}

Scaffold _getScaffold(BuildContext context, Widget body) {
  return Scaffold(
    appBar: AppBar(
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(children: [
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
              value: ModalRoute.of(context)!.settings.name,
              onChanged: (v) {
                switch (v) {
                  case '/DataTablePlus':
                    Navigator.of(context).pushNamed('/DataTablePlus');
                    break;
                  case '/DataTablePlussimple':
                    Navigator.of(context).pushNamed('/DataTablePlussimple');
                    break;
                  case '/DataTablePlusscrollup':
                    Navigator.of(context).pushNamed('/DataTablePlusscrollup');
                    break;
                  case '/paginated2':
                    Navigator.of(context).pushNamed('/paginated2');
                    break;
                  case '/datatable':
                    Navigator.of(context).pushNamed('/datatable');
                    break;
                  case '/paginated':
                    Navigator.of(context).pushNamed('/paginated');
                    break;
                }
              },
              items: [
                DropdownMenuItem(
                  child: Text('DataTablePlus'),
                  value: '/DataTablePlus',
                ),
                DropdownMenuItem(
                  child: Text('DataTablePlus Simple'),
                  value: '/DataTablePlussimple',
                ),
                DropdownMenuItem(
                  child: Text('DataTablePlus Scroll-up'),
                  value: '/DataTablePlusscrollup',
                ),
                DropdownMenuItem(
                  child: Text('PaginatedDataTablePlus'),
                  value: '/paginated2',
                ),
                DropdownMenuItem(
                  child: Text('DataTable'),
                  value: '/datatable',
                ),
                DropdownMenuItem(
                  child: Text('PaginatedDataTable'),
                  value: '/paginated',
                ),
              ],
            )),
      ]),
    ),
    body: body,
  );
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
      initialRoute: '/DataTablePlus',
      routes: {
        '/DataTablePlus': (context) =>
            _getScaffold(context, DataTablePlusDemo()),
        '/DataTablePlussimple': (context) =>
            _getScaffold(context, DataTablePlusSimpleDemo()),
        '/DataTablePlusscrollup': (context) =>
            _getScaffold(context, DataTablePlusScrollupDemo()),
        '/paginated2': (context) =>
            _getScaffold(context, PaginatedDataTablePlusDemo()),
        '/datatable': (context) => _getScaffold(context, DataTableDemo()),
        '/paginated': (context) =>
            _getScaffold(context, PaginatedDataTableDemo()),
      },
    );
  }
}
