import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2.0)
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.0)
    )
);

const linkStyle = TextStyle(
    color: Colors.blue,
    fontSize: 18.0
);

const dropDownInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
);

const defaultProfileImage = "assets/defaultProfilePic.png";

const storagePaths = {
  "profilePic": "ProfilePicture",
  "post": "Post"
};

const localStorage = {
    'LOGGED_IN' : "LOGGED_IN",
    'uid': "uid",
    'COUNTRY_CODE': "countryCode",
    "MOBILE": "MobileNo",
    "COUNTRY": "country"
};

const REGEX_PATTERN = {
    "ONLY_ALPHABETS": r'^[a-zA-Z]*$',
    "ONLY_NUMBER": r'^[0-9]*$',
    "ONLY_ALPHANUMERIC": r'^[a-zA-Z0-9]*$',
    "ALPHANUMERIC_SPACE": r'^[a-zA-Z0-9 ]*$',
    "ALPHANUMERIC_SPACE_SOMESPL": r'^[a-zA-Z0-9 /,-]*$'
};