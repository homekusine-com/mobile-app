import 'package:flutter/material.dart';
import 'package:homekusine/screens/home/home.dart';
import 'package:homekusine/providers/auth.provider.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return StreamBuilder(
      stream: auth.userData,
      builder: (BuildContext context, snapshot) {
        print("users");
        print(snapshot);
        return Home();
//        if(snapshot.hasData){
//          return Home();
//        }else{
//          return Register();
//        }
      },
    );
  }
}
