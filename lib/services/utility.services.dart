import 'package:flutter/material.dart';
import 'package:homekusine/screens/loadingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UtilityServices {

  SharedPreferences prefs;

  var currencySymbol = {
    'India': {'value': '\u20B9', 'type': 'string'},
    'United Kingdom of Great Britain and Northern Ireland': {'value': 0x00A3, 'type': 'icon'}
  };

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

  setAddress(address) async {
    prefs = await SharedPreferences.getInstance();
    var addrObj = {

    };
  }

  getCurrencySymbol(name) {
    return currencySymbol[name];
  }

}