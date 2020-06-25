import 'package:firebase_auth/firebase_auth.dart';
import 'package:homekusine/model/user.model.dart';

class AuthService {

  final FirebaseAuth _authInstance = FirebaseAuth.instance;

  //getter
  FirebaseAuth get authInstance => _authInstance;

  //signOut
  signOut(){
    _authInstance.signOut();
  }

  //signIn
  signIn(AuthCredential authCreds) {
    _authInstance.signInWithCredential(authCreds);
  }

  //signIn with OTP
  signInWithOTP(smsCode, verId) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(verificationId: verId, smsCode: smsCode);
    signIn(authCreds);
  }
}