import 'package:flutter/material.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homekusine/constance/constance.dart';
import 'dart:convert';

class chefProfile extends StatefulWidget {
  @override
  _chefProfileState createState() => _chefProfileState();
}

class _chefProfileState extends State<chefProfile> {

  SharedPreferences prefs;

  Future chefProfileConstructor() async {
    print('future start');
    prefs = await SharedPreferences.getInstance();
    var userProfile = prefs.getString(localStorage['USER_INFO']);
    var result = {
      "userInfo": jsonDecode(userProfile)
    };
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: SafeArea(child:
            Padding(
              padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                child: FutureBuilder(
                        future: chefProfileConstructor(),
                        builder: (context, snapshot) {
                          print('snapshot: $snapshot.data');
                          if(snapshot.data != null){
                            var userInfo = snapshot.data['userInfo'];
                            if(userInfo['isChef'] == null){
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'willing to join our home chef squard',
                                    style: TextStyle(fontSize: 20.0, color: Colors.redAccent),
                                  ),

                                ],
                              );
                            }else{
                              return Container(
                                child: Text('Chef Profile'),
                              );
                            }

                          }else{
                            return Container(
                              child: Text('Loading...'),
                            );
                          }
                        }
              )
            ),
          ),
        )
    );
  }
}
