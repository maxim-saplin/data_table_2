import 'package:flutter/material.dart';

String getCurrentRouteOption(BuildContext context) {
  var isEmpty = ModalRoute.of(context) != null &&
          ModalRoute.of(context)!.settings.arguments != null &&
          ModalRoute.of(context)!.settings.arguments is String
      ? ModalRoute.of(context)!.settings.arguments as String
      : '';

  return isEmpty;
}

const dflt = 'Default';
const noData = 'No data';
const autoRows = 'Auto rows';
const showBorders = 'Borders';
const custPager = 'Custom pager';
const selectAllPage = 'Select all at page';
const asyncErrors = "Errors/Retries";

const Map<String, List<String>> routeOptions = {
  '/datatable2': [dflt, noData, showBorders],
  '/paginated2': [dflt, noData, autoRows, custPager],
  '/asyncpaginated2': [
    dflt,
    noData,
    selectAllPage,
    autoRows,
    asyncErrors,
    custPager
  ],
};

List<String>? getOptionsForRoute(String route) {
  if (!routeOptions.containsKey(route)) {
    return null;
  }

  return routeOptions[route];
}
