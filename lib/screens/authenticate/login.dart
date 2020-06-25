import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homekusine/services/auth.services.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = new GlobalKey<FormState>();

  String phoneNo, verificationId, smsCode;
  bool codeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0),
              child: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: "Enter Mobile Number"),
                onChanged: (val){
                  setState(() {
                    this.phoneNo = val;
                  });
                },
              ),
            ),
            codeSent ? Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0),
              child: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: "Enter OTP"),
                onChanged: (val){
                  setState(() {
                    this.smsCode = val;
                  });
                },
              ),
            ) : Container(),
            Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0),
              child: RaisedButton(
                child: Center(
                  child: codeSent ? Text('Login') : Text('Verify'),
                ),
                onPressed: (){
                  codeSent ? AuthService().signInWithOTP(smsCode, verificationId) : verifyPhone(phoneNo);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
  Future<void> verifyPhone(phoneNo) async {

    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult);
    };

    final PhoneVerificationFailed verificationFailed = (AuthException exception) {
      print('$exception.message');

    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: Duration(seconds: 20),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
