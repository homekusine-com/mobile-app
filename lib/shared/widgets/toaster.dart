import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class Toaster {
  showToast(mes) {
    Fluttertoast.showToast(
        msg: mes,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  showSuccessToast(mes) {
    Fluttertoast.showToast(
        msg: mes,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.lightGreen,
        textColor: Colors.white);
  }
}