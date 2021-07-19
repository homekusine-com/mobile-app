import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:homekusine/constance/constance.dart';
import 'dart:io';

class StorageServices {
  final FirebaseStorage _storage = FirebaseStorage(app: Firestore.instance.app, storageBucket: 'gs://homekusine.appspot.com');

  StorageUploadTask _uploadTask;


  get uploadProgress => _uploadTask.events;

  startProfilePicUpload(String uid, File file) {
    String filePath = '${storagePaths['profilePic']}/$uid.png';
    return _storage.ref().child(filePath).putFile(file);
  }

  startPostPicUpload(String pid, File file) {
    String filePath = '${storagePaths['postImage']}/$pid.png';
    return _storage.ref().child(filePath).putFile(file);
  }

  getProfilePicDownloadUrl(uid) async{
    String filePath = '${storagePaths['profilePic']}/$uid.png';
    var ref = _storage.ref().child(filePath);
    var url = await ref.getDownloadURL();
    return url;
  }

  Future getPostPicDownloadUrl(filePath) async{
    var ref = _storage.ref().child(filePath);
    var downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

}