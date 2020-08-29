import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:homekusine/services/utility.services.dart';
import 'package:homekusine/shared/widgets/toaster.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homekusine/services/user.services.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:homekusine/model/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';

enum Status { Loading, Authenticated, Unauthenticated, Register }

class AuthProvider with ChangeNotifier {

  final FirebaseAuth _authInstance = FirebaseAuth.instance;
  final Future<FirebaseUser> user = FirebaseAuth.instance.currentUser();

  final UserServices _userService = UserServices();
  final UtilityServices _utility = UtilityServices();
  final toast = Toaster();

  bool loggedIn = false;
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
      prefs = await SharedPreferences.getInstance();

      PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
      print('status: $permission');
      if(permission.toString() == "PermissionStatus.denied"){
        PermissionStatus requestPermission = await LocationPermissions().requestPermissions();
      }
    GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();
    print('geolocationStatus -  $geolocationStatus');
    if(geolocationStatus.toString() != "GeolocationStatus.granted"){
      print('turn on');
    }else{
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if(position != null){
        prefs.setString(localStorage['LOCATION'], position.toString());
      }else {
        Position lastPosition = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
        if(lastPosition != null) {
          prefs.setString(localStorage['LOCATION'], lastPosition.toString());
        }
      }
    }
      
      loggedIn = prefs.getBool(localStorage['LOGGED_IN']);
      if(loggedIn == true){
        _authInstance.currentUser().then((user) {
          if (user.uid != null) {
            checkIsRegistered(user.uid, null);
          } else {
            _status = Status.Unauthenticated;
            notifyListeners();
          }
        }).catchError((onError) {
          print(onError.toString());
        });
      }else{
        _status = Status.Unauthenticated;
        notifyListeners();
      }
    
  }

  checkIsRegistered(uid, context) async {
    _uid = uid;
    _userService.userCollection.document(uid).get().then((dataSnapshot){
      if(dataSnapshot.data != null){
        if(dataSnapshot.data['isRegistered'] != null && dataSnapshot.data['isRegistered'] != false) {
          _status = Status.Authenticated;
          prefs.setBool(localStorage['LOGGED_IN'], true);
          if(context != null)
            _utility.popRoute(context);
          notifyListeners();
        }else {
          _status = Status.Register;
          if(context != null)
            _utility.popRoute(context);
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
               if(context != null)
                 _utility.popRoute(context);
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
    print('signout');
    _authInstance.signOut();
    prefs.setBool(localStorage['LOGGED_IN'], false);
    _status = Status.Unauthenticated;
    notifyListeners();
  }

  //signIn
  signIn(AuthCredential authCreds, context) async {
    AuthResult result = await _authInstance.signInWithCredential(authCreds).catchError((onError) {
      _utility.popRoute(context);
      toast.showToast('unable to login, invalid OTP');
    });
    checkIsRegistered(result.user.uid, context);
  }

  //signIn with OTP
  signInWithOTP(smsCode, verId, context) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(verificationId: verId, smsCode: smsCode);
    signIn(authCreds, context);
  }

  getCurrentUser() {
    user.then((val) {
      _uid = val.uid;
    }).catchError((e) => print(e.toString()));
  }
}

