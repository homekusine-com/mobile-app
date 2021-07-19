import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';


class FireStoreDBServices {
  CollectionReference _cuisineCollection = Firestore.instance.collection("cuisine");
  CollectionReference _dishCategoryCollection = Firestore.instance.collection("dish_category");
  CollectionReference _postCollection = Firestore.instance.collection("post");

  //getter
  CollectionReference get cuisineCollection => _cuisineCollection;
  CollectionReference get dishCategoryCollection => _dishCategoryCollection;
  CollectionReference get postCollection => _postCollection;

  final geo = Geoflutterfire();

  createPost(Map<String, dynamic> value) {
    return _postCollection.document().setData(value);
  }

  getPost(lat, long) {
    // Create a geoFirePoint
    GeoFirePoint centerGeoPoint = geo.point(latitude: lat, longitude: long);

    var collectionReference = Firestore.instance.collection('post');
    var geoRef = geo.collection(collectionRef: collectionReference);

    // For GeoFirePoint stored at the root of the fire store document
    Stream<List<DocumentSnapshot>> postList =  geoRef.within(center: centerGeoPoint, radius: 1, field: 'location');
    return postList.map((item) {
      return item.toList();
    });
  }

}