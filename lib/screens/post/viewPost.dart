import 'package:flutter/material.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:homekusine/model/user.model.dart';
import 'package:homekusine/services/storage.services.dart';
import 'package:homekusine/services/utility.services.dart';

class ViewPost extends StatelessWidget {

  // Declare a field that holds the post.
  final post;
  ViewPost({this.post});
  StorageServices _storageServices = new StorageServices();
  final UtilityServices _utility = UtilityServices();
  String profilePicPath = defaultProfileImage;
  IconData cur_symbol;
  var currencySymbol;

  Future getPostNProfilePic() async {
    var downloadUrl = await _storageServices.getPostPicDownloadUrl(post['imgURL']);
    var profileDownloadUrl = await _storageServices.getProfilePicDownloadUrl(post['users'].documentID);
    return {
      'post': downloadUrl.toString(),
      'profile': profileDownloadUrl.toString()
    };
  }

  Future getUserInfo() async {
    return post['users'].get().then((docRef){
      currencySymbol = _utility.getCurrencySymbol(docRef.data['country']);
      if(currencySymbol['type'] == 'icon') {
        cur_symbol = IconData(currencySymbol['value'], fontFamily: 'MaterialIcons');
        return {
          'cur_symbol': cur_symbol,
          'currencySymbol': currencySymbol
        };
      }
      return {
        'currencySymbol': currencySymbol
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request booking'),
        backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
          child: Container(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      FutureBuilder(
                        future: getPostNProfilePic(),
                        builder: (context, snapshot) {
                          return Container(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: <Widget>[
                                ColorFiltered(
                                  colorFilter: new ColorFilter.mode(Colors.black.withOpacity((snapshot.hasData && snapshot.data['post'].length > 0) ? 0.1 : 0.6), BlendMode.darken),
                                  child: Container(
                                    decoration: new BoxDecoration(
                                      image: new DecorationImage(image: new AssetImage(defaultPostImage), fit: BoxFit.cover,),
                                    ),
                                    child: (snapshot.hasData && snapshot.data['post'].length > 0) ? Image.network(
                                      snapshot.data['post'],
                                      height: 250,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.fitWidth,
                                    ) : Image(
                                      image: AssetImage(defaultPostImage),
                                      height: 250,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                                  Container(
                                    decoration: new BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    ),
                                    height: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 10.0),
                                            child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              strutStyle: StrutStyle(fontSize: 30.0),
                                              text: TextSpan(
                                                style: TextStyle(color: Colors.white, fontSize: 30.0),
                                                text: post['title'],
                                              ),
                                            ),
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 33.0,
                                            backgroundImage: (snapshot.hasData && snapshot.data['profile'].length > 0) ? NetworkImage(snapshot.data['profile']) : AssetImage(profilePicPath),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }
                      ),
                      Card(
                        margin: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 0),
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Text('post by - '),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("About the food", style: TextStyle(fontSize: 20.0, decoration: TextDecoration.underline, color: Colors.redAccent)),
                                  FutureBuilder(
                                    future: getUserInfo(),
                                    builder: (context, snapshot) {
                                        if(snapshot.hasData) {
                                          if(snapshot.data['currencySymbol']['type'] == "icon") {
                                           return Wrap(
                                             children: <Widget>[
                                               Icon(cur_symbol, size: 18, color: Colors.black,),
                                               Padding(
                                                 padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                 child: Text( post['price'], style: TextStyle(color: Colors.black, fontSize: 16.00)),
                                               )
                                             ],
                                           );
                                          } else {
                                            return Text('${snapshot.data['currencySymbol']['value']} ${post['price']}', style: TextStyle(color: Colors.black, fontSize: 16.00));
                                          }
                                        } else {
                                          return Text('');
                                        }
                                    }
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(post['description'], style: TextStyle(fontSize: 20.0,)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Text('Cuisine', style: TextStyle(fontSize: 18.0, decoration: TextDecoration.underline, color: Colors.redAccent)),
                                        Text('Britin'),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text('Category', style: TextStyle(fontSize: 18.0, decoration: TextDecoration.underline, color: Colors.redAccent)),
                                        Text('Eggtarian'),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text('Availability', style: TextStyle(fontSize: 18.0, decoration: TextDecoration.underline, color: Colors.redAccent)),
                                        Text('Breakfast'),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: RaisedButton(
                                color: Colors.redAccent,
                                onPressed: (){

                                },
                                child: Text(
                                  "Request for order",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0
                                  ),
                                )
                            ),
                          ),
                        ),
                      )
                  ],
                )
              ]
            )
          ),
      ),
    );
  }
}