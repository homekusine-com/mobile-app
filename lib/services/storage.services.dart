import 'package:firebase_storage/firebase_storage.dart';
import 'package:homekusine/constance/constance.dart';
import 'dart:io';

class StorageServices {
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://homekusine.appspot.com');


  StorageUploadTask _uploadTask;

  get uploadProgress => _uploadTask.events;

  startProfilePicUpload(String uid, File file) {
    String filePath = '${storagePaths['profilePic']}/$uid.png';
    return _uploadTask = _storage.ref().child(filePath).putFile(file);
  }
}