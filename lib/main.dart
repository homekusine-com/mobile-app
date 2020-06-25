import 'package:flutter/material.dart';
import 'package:homekusine/services/auth.services.dart';
import 'package:homekusine/screens/authenticate/login.dart';
import 'package:homekusine/screens/home/home.dart';
import 'package:homekusine/services/user.services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final UserServices _userServices = UserServices();

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: AuthService().authInstance.onAuthStateChanged,
          builder: (BuildContext context, snapshot) {
            if(snapshot.hasData){
                return Home();
            }else{
              return Login();
            }
          },
        ),
      );
  }
}