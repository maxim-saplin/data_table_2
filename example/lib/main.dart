import 'package:flutter/material.dart';

import 'data_table_plus.dart';

void main() {
  runApp(MyApp());
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
        '/DataTablePlus': (context) => DataTablePlusDemo(),
      },
    );
  }
}
