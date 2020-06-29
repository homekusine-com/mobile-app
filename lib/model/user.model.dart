import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  User({ this.uid });
}

class CreateUserModel {
  String mobileNo;
  String countryCode;
  String country;
  bool isRegistered;
  bool isActive;
  Timestamp createdAt;
}

class RegisterUserModel {
  String firstName;
  String lastName;
  String gender;
  String profileName;
  String DOB;
  String doorNo;
  String streetName;
  String city;
  String postCode;
  bool isChef;
  bool isRegistered;
  Timestamp updatedAt;
}

class UserModel {
  String phoneNo;

  UserModel({this.phoneNo});
}