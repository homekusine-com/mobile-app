import 'package:flutter/material.dart';
import 'package:homekusine/screens/loadingScreen.dart';

class UtilityServices {

  showLoader(context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // set to false
        pageBuilder: (_, __, ___) => LoadingScreen(),
      ),
    );
  }

  popRoute(context) {
    Navigator.pop(context);
  }

}