import 'package:flutter/material.dart';

const FormInputDecoration = InputDecoration(
    fillColor: Colors.transparent,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0)
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0)
    ),
    errorStyle: TextStyle(
        fontSize: 18.0,
    ),
);

const FormInputBottomDecoration = InputDecoration(
    fillColor: Colors.transparent,
    filled: true,
    enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue),
    ),
    focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0)
    ),
    errorStyle: TextStyle(
        fontSize: 18.0,
    ),
    hintStyle: TextStyle(color: Colors.lightBlue)
);

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
    color: Colors.black,
    fontSize: 18.0,
    decoration: TextDecoration.underline,
    fontWeight: FontWeight.bold
);

const linkStyleBlue = TextStyle(
    color: Colors.blue,
    fontSize: 18.0,
    decoration: TextDecoration.underline,
    fontWeight: FontWeight.bold
);

const dropDownInputDecoration = InputDecoration(
    fillColor: Colors.transparent,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0)
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0)
    ),
    errorStyle: TextStyle(
        fontSize: 18.0,
    ),
);

const defaultProfileImage = "assets/defaultProfilePic.png";
const defaultPostImage = "assets/defaultPost.png";

const storagePaths = {
  "profilePic": "ProfilePicture",
  "postImage": "PostImages",
  "post": "Post"
};

const localStorage = {
    'LOGGED_IN' : "LOGGED_IN",
    'uid': "uid",
    'COUNTRY_CODE': "countryCode",
    "MOBILE": "MobileNo",
    "COUNTRY": "country",
    "LOCATION": "location",
    "LOCATIONINFO": "locationInfo",
    "USER_INFO": "userInfo",
    "USER_PROFILE_PIC_URL": "profilePictureURL"
};

const REGEX_PATTERN = {
    "ONLY_ALPHABETS": r'^[a-zA-Z]*$',
    "ONLY_NUMBER": r'^[0-9]*$',
    "ONLY_ALPHANUMERIC": r'^[a-zA-Z0-9]*$',
    "ALPHANUMERIC_SPACE": r'^[a-zA-Z0-9 ]*$',
    "ALPHANUMERIC_SPACE_SOMESPL": r'^[a-zA-Z0-9 /,-]*$'
};

const COLOR_PALATE = {
  "primary": Colors.redAccent
};