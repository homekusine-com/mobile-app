import 'package:cloud_firestore/cloud_firestore.dart';


class FireStoreDBServices {
  CollectionReference _cuisineCollection = Firestore.instance.collection("cuisine");
  CollectionReference _dishCategoryCollection = Firestore.instance.collection("dish_category");

  //getter
  CollectionReference get cuisineCollection => _cuisineCollection;
  CollectionReference get dishCategoryCollection => _dishCategoryCollection;

}