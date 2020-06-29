import 'package:flutter/material.dart';
import 'package:homekusine/services/user.services.dart';
import 'package:homekusine/providers/auth.provider.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final UserServices _userServices = UserServices();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Center(
            child: RaisedButton(
              child: Text('Sign out'),
              onPressed: () {
                auth.signOut();
              },
            ),
          ),
        ),
      ),
    );
  }
}
