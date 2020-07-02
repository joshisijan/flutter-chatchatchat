import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

showError(BuildContext context, String x){
  return Fluttertoast.showToast(
    msg: x,
    backgroundColor: Theme.of(context).errorColor,
    textColor: Theme.of(context).textTheme.title.color,
    gravity: ToastGravity.TOP,
  );
}