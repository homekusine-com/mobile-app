import 'package:flutter/material.dart';
import 'package:homekusine/services/user.services.dart';
import 'package:homekusine/providers/auth.provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  final UserServices _userServices = UserServices();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final List<Widget> _widgetOptions = <Widget>[
      Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.location_on, color: Colors.lightGreen, size: 35.0,),
                SizedBox(width: 5.0,),
                Text('Location', style: TextStyle(fontSize: 30.0),),
              ],
            )
          ],
        ),
      ),
      Text(
        'Index 1: Cuisine',
        style: optionStyle,
      ),
      Container(
        child: Center(
          child: FlatButton(onPressed: () => auth.signOut(), child: Text('Sign Out'), color: Colors.transparent,),
        ),
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

