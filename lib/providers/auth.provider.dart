import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homekusine/services/user.services.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:homekusine/model/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Status { Loading, Authenticated, Unauthenticated, Register }

class AuthProvider with ChangeNotifier {

  final FirebaseAuth _authInstance = FirebaseAuth.instance;
  final Future<FirebaseUser> user = FirebaseAuth.instance.currentUser();

  final UserServices _userService = UserServices();

  bool loggedIn;
  Status _status = Status.Loading;
  String _uid;

  //getter
  FirebaseAuth get authInstance => _authInstance;
  String get uid => _uid;
  Status get status => _status;
  SharedPreferences prefs;

  //Stream
  Stream<UserModel> get userData {
    if(_uid != null){
      print("Strem of user data : ${_uid}");
      return _userService.userCollection.document(_uid).snapshots().map(_userService.setUser);
    }
  }


  AuthProvider.initialize() {
    readPrefs();
  }

  Future<void> readPrefs() async {
    await Future.delayed(Duration(seconds: 3)).then((v)async {
      prefs = await SharedPreferences.getInstance();
      loggedIn = prefs.getBool(localStorage['LOGGED_IN']);
      _authInstance.currentUser().then((user) {
        if (user.uid != null) {
          checkIsRegistered(user.uid);
//          _status = Status.Authenticated;
//          notifyListeners();
//          return;
        } else {
          _status = Status.Unauthenticated;
          notifyListeners();
        }
      }).catchError((onError) {
        print(onError.toString());
      });
    });
  }

  checkIsRegistered(uid) async {
    _uid = uid;
    _userService.userCollection.document(uid).get().then((dataSnapshot){
      if(dataSnapshot.data != null){
        if(dataSnapshot.data['isRegistered'] != null && dataSnapshot.data['isRegistered'] != false) {
          _status = Status.Authenticated;
          prefs.setBool(localStorage['LOGGED_IN'], true);
          notifyListeners();
        }else {
          _status = Status.Register;
          notifyListeners();
        }
      }else{
        dynamic newUser = {
          "isRegistered": false,
          "isActive": false ,
          "mobileNo": prefs.getString(localStorage['MOBILE']),
          "countryCode": prefs.getString(localStorage['COUNTRY_CODE']),
          "country": prefs.getString(localStorage['COUNTRY']),
          "createdAt": new DateTime.now()
        };
         _userService.userCollection.document(uid).setData(newUser)
             .then((onValue){
               _status = Status.Register;
               notifyListeners();
             })
             .catchError((onError) {
                print(onError.toString());
             });
      }
    });
  }

  registrationCompleted() {
    _status = Status.Authenticated;
    notifyListeners();
  }

  //signOut
  signOut(){
    _authInstance.signOut();
    prefs.setBool(localStorage['LOGGED_IN'], false);
    _status = Status.Unauthenticated;
    notifyListeners();
  }

  //signIn
  signIn(AuthCredential authCreds) async {
    AuthResult result = await _authInstance.signInWithCredential(authCreds);
    checkIsRegistered(result.user.uid);
  }
//  signIn(AuthCredential authCreds) async {
//    _authInstance.signInWithCredential(authCreds).then((data) {
//      print('signin sucess');
//      user.then((val) {
//        _uid = val.uid;
//
//           print("----user data -----");
//          _userService.userCollection.document(val.uid).get()
//              .then((DocumentSnapshot ds) {
//                print(ds);
//                print(ds.data);
//              }).catchError((e){
//                print('user data retriving error:  ${e.toString()}');
//          });
////          _status = Status.Authenticated;
////          prefs.setBool(localStorage['LOGGED_IN'], true);
////          notifyListeners();
//
//      }).catchError((e) => print(e.toString()));
//    }).catchError((e) {
//      print('signin fail');
//      print(e.toString());
//    });
//    print('signin fnx complete');
//  }

  //signIn with OTP
  signInWithOTP(smsCode, verId) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(verificationId: verId, smsCode: smsCode);
    signIn(authCreds);
  }

  getCurrentUser() {
    user.then((val) {
      _uid = val.uid;
    }).catchError((e) => print(e.toString()));
  }


}

