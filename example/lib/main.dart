import 'package:example/data_table.dart';
import 'package:example/paginated_data_table.dart';
import 'package:flutter/material.dart';

import 'data_table2.dart';

void main() {
  runApp(MyApp());
}

Scaffold _getScaffold(BuildContext context, Widget body) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Row(children: [
        DropdownButton<String>(
          style: Theme.of(context).textTheme.headline6,
          value: ModalRoute.of(context)!.settings.name,
          onChanged: (v) {
            switch (v) {
              case '/datatable2':
                Navigator.of(context).pushNamed('/datatable2');
                break;
              case '/paginated':
                Navigator.of(context).pushNamed('/paginated');
                break;
              case '/datatable':
                Navigator.of(context).pushNamed('/datatable');
                break;
            }
          },
          items: [
            DropdownMenuItem(
              child: Text('DataTable2'),
              value: '/datatable2',
            ),
            DropdownMenuItem(
              child: Text('PaginatedDataTable'),
              value: '/paginated',
            ),
            DropdownMenuItem(
              child: Text('DataTable'),
              value: '/datatable',
            )
          ],
        ),
        Text(' - demo page'),
      ]),
    ),
    body: Scrollbar(child: body),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.grey[300],
      ),
      initialRoute: '/datatable2',
      routes: {
        '/datatable2': (context) => _getScaffold(context, DataTable2Demo()),
        '/paginated': (context) =>
            _getScaffold(context, PaginatedDataTableDemo()),
        '/datatable': (context) => _getScaffold(context, DataTableDemo())
      },
    );
  }
}
