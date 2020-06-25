import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homekusine/model/user.model.dart';

class UserServices {
  String collection = "users";
  CollectionReference _userCollection = Firestore.instance.collection('collection');

  getUser(String id) => _userCollection.document(id).get();


  void createUser(Map<String, dynamic> value) {
     String id = value['id'];
     _userCollection.document(id).setData(value);
  }


}