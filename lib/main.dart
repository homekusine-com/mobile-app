import 'package:flutter/material.dart';
import 'package:homekusine/providers/auth.provider.dart';
import 'package:homekusine/screens/authenticate/register.dart';
import 'package:homekusine/screens/home/home.dart';
import 'package:homekusine/screens/splash.dart';
import 'package:homekusine/screens/authenticate/login.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: AuthProvider.initialize())
  ],
    child: MyApp(),));
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
          home: ScreensController(),
      );
  }
}

class ScreensController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if(auth.status == Status.Loading){
      return Splash();
    }else{
      if(auth.status == Status.Authenticated){
        return Home();
      }else if(auth.status == Status.Register){
        return Register();
      }else{
        return Login();
      }
    }
  }
}
