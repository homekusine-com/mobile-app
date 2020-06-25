import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  User({ this.uid });
}

class UserModel {
  String mobileNo;
  String id;
  String firstName;
  String lastName;
  String gender;

}