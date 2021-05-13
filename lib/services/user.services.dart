import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homekusine/model/user.model.dart';

class UserServices {

  CollectionReference _userCollection = Firestore.instance.collection("users");

  getUser(String id) => _userCollection.document(id).snapshots();

  //getter
  CollectionReference get userCollection => _userCollection;

  createUser(String id, Map<String, dynamic> value) {
     return _userCollection.document(id).setData(value);
  }

  UserModel setUser(DocumentSnapshot snapshot){
    return UserModel(phoneNo: snapshot.data['phoneNo']);
  }
}