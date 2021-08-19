import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:homekusine/screens/chef/chefProfile.dart';
import 'package:homekusine/screens/post/createPost.dart';
import 'package:homekusine/services/fireStoreDB.services.dart';
import 'package:homekusine/services/storage.services.dart';
import 'package:homekusine/services/user.services.dart';
import 'package:homekusine/providers/auth.provider.dart';
import 'package:homekusine/shared/widgets/postList/postTile.dart';
import 'package:provider/provider.dart';
import 'package:geocoder/geocoder.dart' as Gc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homekusine/shared/widgets/toaster.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;

  StorageServices _storageServices = new StorageServices();

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  final UserServices _userServices = UserServices();
  SharedPreferences prefs;
  final FireStoreDBServices _fireStoreDbServices = FireStoreDBServices();


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future getScreenInfo() async {
    prefs = await SharedPreferences.getInstance();
    String location = prefs.getString(localStorage['LOCATION']);
    var locationObj = location.split(',').map((String point) => point.split(": ")[1]);
    var lat = double.parse(locationObj.first);
    var lon = double.parse(locationObj.last);
    final coordinates = new Gc.Coordinates(lat, lon);
    var addresses = await Gc.Geocoder.local.findAddressesFromCoordinates(coordinates);
    var addressMap = addresses.first.toMap();

    prefs.setString(localStorage['LOCATIONINFO'], addressMap.toString());

    String userInfo = prefs.getString(localStorage['USER_INFO']);
    var result = {
      "currectLocation": (addressMap['subLocality'] != null) ? addressMap['subLocality'] :  (addressMap['thoroughfare'] != null) ? "${addressMap['thoroughfare']}" : addressMap['postalCode'],
      "userInfo": userInfo,
      "lat": lat,
      "lon": lon
    };
    return result;
  }

  Future getProfileScreenInfo() async {
    prefs = await SharedPreferences.getInstance();
    String userInfo = prefs.getString(localStorage['USER_INFO']);
    if(userInfo != null) {
      var result = {
        "userInfo": jsonDecode(userInfo)
      };
      return result;
    }else {
      return false;
    }

  }

  Future _getProfileImage(context, uid) async {
    var downloadUrl = await _storageServices.getProfilePicDownloadUrl(uid);
    return downloadUrl.toString();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final List<Widget> _widgetOptions = <Widget>[
      Container(
        child: Column(
          children: <Widget>[
              FutureBuilder(
                future: getScreenInfo(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    var userInfo = jsonDecode(snapshot.data['userInfo']);
                    return Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            FlatButton(
                                onPressed: null,
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.location_on, color: Colors.redAccent, size: 35.0,),
                                    SizedBox(width: 5.0,),
                                    Text(snapshot.data['currectLocation'], style: TextStyle(color: Colors.black,fontSize: 30.0, decoration: TextDecoration.underline),),
                                  ],
                                )
                            )
                          ],
                        ),
                        Container(
                          height: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  Chip(
//                                    avatar: CircleAvatar(
//                                      backgroundColor: Colors.red,
//                                      child: Text('AB'),
//                                    ),
                                    backgroundColor: Colors.white,
                                    shape: StadiumBorder(side: BorderSide()),
                                    label: Text('Filter'),
                                  ),
                                  SizedBox(width: 5.0,),
                                  Chip(
                                    backgroundColor: Colors.white,
                                    shape: StadiumBorder(side: BorderSide()),
                                    label: Text('Near me'),
                                  ),
                                  SizedBox(width: 5.0,),
                                  Chip(
                                    backgroundColor: Colors.white,
                                    shape: StadiumBorder(side: BorderSide()),
                                    label: Text('Top rated'),
                                  ),
                                  SizedBox(width: 5.0,),
                                  Chip(
                                    backgroundColor: Colors.white,
                                    shape: StadiumBorder(side: BorderSide()),
                                    label: Text('Sort by less price'),
                                  ),
                                ]
                            ),
                          )
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.69,
                          child: StreamBuilder(
                                  stream: _fireStoreDbServices.getPost(snapshot.data['lat'], snapshot.data['lon']),
                                  builder:
                                  (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                                    if(snapshot.hasData) {
                                      if (snapshot.data.length > 0) {
                                        return Container(
                                          color: Colors.white,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: snapshot.data.length,
                                              // itemExtent: 150.0,
                                              itemBuilder: (BuildContext context, int index) {
                                                // return Text(userInfo['profileName']);
                                                return PostTile(post: snapshot.data[index], user: userInfo);
                                              }
                                          )
                                        );
                                      }else {
                                        return Padding(
                                          padding: EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                                          child: Text('no post found at the moment in your locality'),
                                        );
                                      }
                                    }else {
                                      return SingleChildScrollView(
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context).size.height - 100,
                                                width: MediaQuery.of(context).size.width,
                                                color: Colors.white,
                                                child: Center(
                                                  child: SpinKitDualRing(
                                                    color: Colors.redAccent,
                                                    size: 50.0,
                                                  ),
                                                ),
                                              )
                                            ]
                                        ),
                                      );
                                    }
                                  }
                          )
                        )
                      ],
                    );
                  }else{
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height - 100,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Center(
                            child: SpinKitDualRing(
                              color: Colors.redAccent,
                              size: 50.0,
                            ),
                          ),
                        )
                        ]
                    );
                  }
                }
            )
          ],
        ),
      ),
      Text(
        'Index 1: Cuisine',
        style: optionStyle,
      ),
      Container(
        child:
          FutureBuilder(
            future: getProfileScreenInfo(),
            builder: (context, snapshot) {
                if(snapshot.data != null){
                  var userInfo = snapshot.data['userInfo'];
                  return Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: FutureBuilder(
                              future: _getProfileImage(context, auth.uid),
                              builder: (context, snapshot) {
                                if(snapshot.data != null){
                                  return CircleAvatar(
                                    radius: 42,
                                    backgroundColor: Colors.grey[100],
                                    child: CircleAvatar(
                                      radius: 40.0,
                                      backgroundImage: NetworkImage(snapshot.data),
                                    ),
                                  );
                                }else {
                                  return CircleAvatar(
                                    radius: 42,
                                    backgroundColor: Colors.grey[100],
                                    child: CircleAvatar(
                                      radius: 40.0,
                                      backgroundImage: AssetImage(defaultProfileImage),
                                    ),
                                  );
                                }
                              }
                            ),
                            flex: 1,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(userInfo['profileName'], style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold)),
                                SizedBox(height: 10,),
                                Text(userInfo['mobileNo'], style: TextStyle(fontSize: 20.0),),
                              ],
                            ),
                            flex: 3,
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Center(
                        child: FlatButton(
                          onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => ( chefProfile() )),),
                          child: Text('Home Chef'), color: Colors.transparent,
                        ),
                      ),
                      Center(
                        child: FlatButton(
                          onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => ( createPost() )),),
                          child: Text('create post'), color: Colors.transparent,
                        ),
                      ),
                      Center(
                        child: FlatButton(onPressed: () => auth.signOut(), child: Text('Sign Out'), color: Colors.transparent,),
                      ),
                    ],
                  );
                }else{
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height - 100,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Center(
                            child: SpinKitDualRing(
                              color: Colors.redAccent,
                              size: 50.0,
                            ),
                          ),
                        )
                      ]
                  );
                }
            }
          )
      ),
    ];

    return Scaffold(
        body: Center(
            child: SafeArea(child: Padding(
              padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              child: _widgetOptions.elementAt(_selectedIndex),
            )),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text('Discover'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fastfood),
              title: Text('Cuisine'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        )
    );
  }
}

