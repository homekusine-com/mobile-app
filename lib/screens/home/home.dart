import 'package:flutter/material.dart';
import 'package:homekusine/services/auth.services.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Center(
            child: RaisedButton(
              child: Text('Sign out'),
              onPressed: () {
                AuthService().signOut();
              },
            ),
          ),
        ),
      ),
    );
  }
}
