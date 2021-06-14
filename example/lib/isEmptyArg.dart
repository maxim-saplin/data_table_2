import 'package:flutter/material.dart';

bool getIsEmpty(BuildContext context) {
  var isEmpty = ModalRoute.of(context) != null &&
          ModalRoute.of(context)!.settings.arguments != null &&
          ModalRoute.of(context)!.settings.arguments is bool
      ? ModalRoute.of(context)!.settings.arguments as bool
      : false;

  return isEmpty;
}
