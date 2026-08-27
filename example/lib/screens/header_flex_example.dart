import 'package:flutter/material.dart';

import '../data_sources.dart';

class HeaderFlexExample extends StatefulWidget {
  const HeaderFlexExample({super.key});

  @override
  State<HeaderFlexExample> createState() => _HeaderFlexExampleState();
}

class _HeaderFlexExampleState extends State<HeaderFlexExample> {
  double _headerFlex = 1.0;
  late DessertDataSource _dessertsDataSource;

  @override
  void initState() {
    super.initState();
    _dessertsDataSource = DessertDataSource(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Header Flex Example'),
      ),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Header Flex: '),
                Expanded(
                  child: Slider(
                    value: _headerFlex,
                    min: 0.1,
                    max: 4.0,
                    divisions: 39,
                    label: _headerFlex.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _headerFlex = value;
                      });
                    },
                  ),
                ),
                Text(_headerFlex.toStringAsFixed(1)),
              ],
            ),
          ),
          
          // Table with custom header flex
          Expanded(
            child: PaginatedDataTable(
              headerFlex: _headerFlex,
              header: Row(
                children: [
                  const Text('Desserts Table'),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Flex: ${_headerFlex.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _dessertsDataSource = DessertDataSource(context);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Settings action
                  },
                ),
              ],
              columns: const [
                DataColumn(label: Text('Dessert')),
                DataColumn(label: Text('Calories'), numeric: true),
                DataColumn(label: Text('Fat (g)'), numeric: true),
                DataColumn(label: Text('Carbs (g)'), numeric: true),
                DataColumn(label: Text('Protein (g)'), numeric: true),
                DataColumn(label: Text('Sodium (mg)'), numeric: true),
                DataColumn(label: Text('Calcium (%)'), numeric: true),
                DataColumn(label: Text('Iron (%)'), numeric: true),
              ],
              source: _dessertsDataSource,
              rowsPerPage: 5,
              onRowsPerPageChanged: (value) {
                // Handle rows per page change
              },
            ),
          ),
        ],
      ),
    );
  }
} 