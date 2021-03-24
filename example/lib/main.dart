import 'package:example/data_table.dart';
import 'package:example/paginated_data_table.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

Scaffold _getScaffold(BuildContext context, Widget body) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: DropdownButton<String>(
        value: ModalRoute.of(context)!.settings.name,
        onChanged: (v) {
          switch (v) {
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
            child: Text('PaginatedDataTable'),
            value: '/paginated',
          ),
          DropdownMenuItem(
            child: Text('DataTable'),
            value: '/datatable',
          )
        ],
      ),
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
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/paginated',
      routes: {
        '/paginated': (context) =>
            _getScaffold(context, PaginatedDataTableDemo()),
        '/datatable': (context) => _getScaffold(context, DataTableDemo())
      },
    );
  }
}
