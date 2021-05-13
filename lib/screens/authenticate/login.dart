import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:homekusine/providers/auth.provider.dart';
import 'package:homekusine/screens/splash.dart';
import 'package:homekusine/shared/widgets/toaster.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homekusine/services/utility.services.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formKey = new GlobalKey<FormState>();
  final UtilityServices  _utility = new UtilityServices();

  String phoneNo, verificationId, smsCode;
  bool codeSent = false;
  SharedPreferences prefs;
  bool isCountryCodeReady = false;
  bool isprocessing = false;

  Country _selectedCountry;

  @override

  void initState() {
    initCountry();
    super.initState();
  }

  void initCountry() async {
    final country = await getCountryByCountryCode(context, 'IN');

    setState(() {
      _selectedCountry = country;
      isCountryCodeReady = true;
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

    signIn() {
      _utility.showLoader(context);
      auth.signInWithOTP(smsCode, verificationId, context);
    }
    Future<void> verifyPhone(phoneNoWtihCode) async {
      setState(() {
        isprocessing = true;
      });
      prefs = await SharedPreferences.getInstance();
      prefs.setString(localStorage['MOBILE'], phoneNo);
      prefs.setString(localStorage['COUNTRY_CODE'], _selectedCountry?.callingCode);
      prefs.setString(localStorage['COUNTRY'], _selectedCountry?.name);

      final PhoneVerificationCompleted verified = (AuthCredential authResult) {
        _utility.showLoader(context);
        auth.signIn(authResult, context);
      };

      final PhoneVerificationFailed verificationFailed = (AuthException exception) {
        // print('exception.message: ${exception.message.toString()}');
        Toaster().showToast("mobile number entered is not valid");
      };

      final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
        this.verificationId = verId;
        setState(() {
          this.codeSent = true;
          isprocessing = false;
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
      body: !isCountryCodeReady ? Splash() : DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
              image: AssetImage('assets/vada.jpg'),
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
          ),
        ),
        child: Form(
        key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 50.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      _selectedCountry.flag,
                      package: countryCodePackageName,
                      width: 40,
                    ),
                    SizedBox(width: 10.0,),
                    InkWell(
                      child: Text(
                        _selectedCountry == null
                            ? ''
                            : '${_selectedCountry?.callingCode ?? '+code'} - (${_selectedCountry?.countryCode ?? 'Country code'})',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30, decoration: TextDecoration.underline, color: Colors.black),
                      ),
                      onTap: () => _onPressedShowBottomSheet()
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 20.0),
                child: TextFormField(
                  style: TextStyle(fontSize: 25.0),
                  keyboardType: TextInputType.phone,
                  decoration: FormInputDecoration.copyWith(hintText: "Enter Mobile Number"),
                  validator: (val) => val.isEmpty ? Text('Please provide a mobile number', style: TextStyle(fontSize: 20),) : (val.length != 10) ? ("Please enter a valid mobile number") : null,
                  onChanged: (val){
                    setState(() {
                      this.phoneNo = val;
                      if(this.codeSent) this.codeSent = false;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.0, right: 25.0),
                child: TextFormField(
                  enabled: codeSent,
                  style: TextStyle(fontSize: 25.0),
                  keyboardType: TextInputType.phone,
                  decoration: FormInputDecoration.copyWith(hintText: "Enter OTP"),
                  onChanged: (val){
                    setState(() {
                      this.smsCode = val;
                    });
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(25.0),
                      child: !isprocessing ? RaisedButton(
                        color: Colors.transparent,
                        child: Center(
                          child: !codeSent ? Text('Send OTP') : Text('Login'),
                        ),
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                            !codeSent ? verifyPhone(_selectedCountry?.callingCode + phoneNo) : signIn();
                          }
                        },
                      )
                      : SpinKitThreeBounce(
                        color: Colors.black45,
                        size: 30.0,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}