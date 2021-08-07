import 'package:flutter/material.dart';

String getCurrentRouteOption(BuildContext context) {
  var isEmpty = ModalRoute.of(context) != null &&
          ModalRoute.of(context)!.settings.arguments != null &&
          ModalRoute.of(context)!.settings.arguments is String
      ? ModalRoute.of(context)!.settings.arguments as String
      : '';

  return isEmpty;
}

const hasData = 'Default';
const noData = 'No data';
const autoRows = 'Auto rows';
const showBorders = 'Borders';
const custPager = 'Custom pager';

const Map<String, List<String>> routeOptions = {
  '/datatable2': [hasData, noData, showBorders],
  '/paginated2': [hasData, noData, autoRows, custPager],
  '/asyncpaginated2': [hasData, noData, autoRows, custPager],
};

List<String>? getOptionsForRoute(String route) {
  if (!routeOptions.containsKey(route)) {
    return null;
  }

  return routeOptions[route];
}
