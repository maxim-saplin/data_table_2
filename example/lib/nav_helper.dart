import 'package:flutter/material.dart';

/// Route options are used to configure certain features of
/// the given example
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
const showBordersWithZebraStripes = 'Borders with Zebra';
const custPager = 'Custom pager';
const defaultSorting = 'Default sorting';
const selectAllPage = 'Select all at page';
const rowTaps = 'Row Taps';
const rowHeightOverrides = 'Row height overrides';
const fixedColumnWidth = 'Fixed column width';

/// Async sample that emulates network error and allow retrying load operation
const asyncErrors = "Errors/Retries";

/// Used by asyn example, navigates to the very last page upon opening the screen
const goToLast = "Start at last page";

/// Configurations available to given example routes
const Map<String, List<String>> routeOptions = {
  '/datatable2': [
    dflt,
    noData,
    showBordersWithZebraStripes,
    fixedColumnWidth,
    rowTaps,
    rowHeightOverrides
  ],
  '/paginated2': [dflt, noData, autoRows, custPager, defaultSorting],
  '/asyncpaginated2': [
    dflt,
    noData,
    selectAllPage,
    autoRows,
    asyncErrors,
    goToLast,
    custPager
  ],
};

List<String>? getOptionsForRoute(String route) {
  if (!routeOptions.containsKey(route)) {
    return null;
  }

  return routeOptions[route];
}
