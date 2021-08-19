import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:homekusine/screens/post/viewPost.dart';
import 'package:homekusine/services/storage.services.dart';
import 'package:homekusine/services/utility.services.dart';

class PostTile extends StatelessWidget {
  final UtilityServices _utility = UtilityServices();
  StorageServices _storageServices = new StorageServices();
  final post;
  final user;
  PostTile({ this.post, this.user });

  Future getPostPic() async {
      var downloadUrl = await _storageServices.getPostPicDownloadUrl(post['imgURL']);
      return downloadUrl.toString();
  }

  onClick(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ( ViewPost(post: this.post) )));
  }

  @override
  Widget build(BuildContext context) {
    var currencySymbol = _utility.getCurrencySymbol(user['country']);
    IconData cur_symbol;

    if(currencySymbol['type'] == 'icon') {
      cur_symbol = IconData(currencySymbol['value'], fontFamily: 'MaterialIcons');
    }
    return Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
            margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0),
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 5,
            child: InkWell(
              onTap: () => onClick(context),
              child: FutureBuilder(
                future: getPostPic(),
                builder: (context, snapshot) {
                  return Column(
                    children: <Widget>[
                      ColorFiltered(
                        colorFilter: new ColorFilter.mode(Colors.black.withOpacity((snapshot.hasData) ? 0.1 : 0.6), BlendMode.darken),
                        child: Container(
                          decoration: new BoxDecoration(
                            image: new DecorationImage(image: new AssetImage(defaultPostImage), fit: BoxFit.cover,),
                          ),
                          child: (snapshot.hasData) ? Image.network(
                              snapshot.data,
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitWidth,
                          ) : Image(
                            image: AssetImage(defaultPostImage),
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Padding(
                          padding: EdgeInsets.fromLTRB(0, 5.0, 0, 10.0),
                          child: Text(
                              post['title'],
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(color: Colors.black,fontSize: 20.0, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)
                          ),
                        ),
                        subtitle: Text('Available for - ${post['availability']}'),
                        trailing: (currencySymbol['type'] == "icon") ? Wrap(
                          children: <Widget>[
                            Icon(cur_symbol, size: 18, color: Colors.black,),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Text( post['price'], style: TextStyle(color: Colors.black, fontSize: 16.00)),
                            )
                          ],
                        ) : Text('${currencySymbol['value']} ${post['price']}', style: TextStyle(color: Colors.black, fontSize: 16.00)),
                      )
                    ],
                  );
                },
              )
            )
        )
    );
  }
}