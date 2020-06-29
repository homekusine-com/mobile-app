import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:homekusine/providers/auth.provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homekusine/constance/constance.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formKey = new GlobalKey<FormState>();
  String phoneNo, verificationId, smsCode;
  bool codeSent = false;
  SharedPreferences prefs;

  Country _selectedCountry;

  @override

  void initState() {
    initCountry();
    super.initState();
  }

  void initCountry() async {
    final country = await getCountryByCountryCode(context, 'IN');;

    setState(() {
      _selectedCountry = country;
    });
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(
      context,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }


  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    Future<void> verifyPhone(phoneNoWtihCode) async {
      prefs = await SharedPreferences.getInstance();
      prefs.setString(localStorage['MOBILE'], phoneNo);
      prefs.setString(localStorage['COUNTRY_CODE'], _selectedCountry?.callingCode);
      prefs.setString(localStorage['COUNTRY'], _selectedCountry?.name);

      final PhoneVerificationCompleted verified = (AuthCredential authResult) {
        auth.signIn(authResult);
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
          phoneNumber: phoneNoWtihCode,
          timeout: Duration(seconds: 20),
          verificationCompleted: verified,
          verificationFailed: verificationFailed,
          codeSent: smsSent,
          codeAutoRetrievalTimeout: autoTimeout);
    }

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 50.0,
                  color: Colors.amber
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: !codeSent ? (_selectedCountry == null
                  ? Container() : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    _selectedCountry.flag,
                    package: countryCodePackageName,
                    width: 30,
                  ),
                  SizedBox(width: 10.0,),
                  InkWell(
                    child: Text(
                      _selectedCountry == null
                          ? ''
                          : '${_selectedCountry?.callingCode ?? '+code'} ${_selectedCountry?.name ?? 'Name'} (${_selectedCountry?.countryCode ?? 'Country code'})',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, decoration: TextDecoration.underline, color: Colors.blue[400]),
                    ),
                    onTap: () => _onPressedShowBottomSheet()
                  ),
                ],
              )
              ) : Container(),
            ),
            !codeSent ? Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0),
              child: TextFormField(
                style: TextStyle(fontSize: 20.0),
                keyboardType: TextInputType.phone,
                decoration: textInputDecoration.copyWith(hintText: "Enter Mobile Number"),
                validator: (val) => val.isEmpty ? 'Please provide a mobile number' : (val.length != 10) ? "Please enter a valid mobile number" : null,
                onChanged: (val){
                  setState(() {
                    this.phoneNo = val;
                  });
                },
              ),
            ) : Container(),
            codeSent ? Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0),
              child: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: textInputDecoration.copyWith(hintText: "Enter OTP"),
                onChanged: (val){
                  setState(() {
                    this.smsCode = val;
                  });
                },
              ),
            ) : Container(),
            Padding(
              padding: EdgeInsets.all(25.0),
              child: RaisedButton(
                color: Colors.blue,
                child: Center(
                  child: codeSent ? Text('Login') : Text('Send OTP'),
                ),
                onPressed: (){
                  if(_formKey.currentState.validate()){
                    codeSent ? auth.signInWithOTP(smsCode, verificationId) : verifyPhone(_selectedCountry?.callingCode + phoneNo);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
