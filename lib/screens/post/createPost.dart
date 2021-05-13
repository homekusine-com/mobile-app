import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:homekusine/services/fireStoreDB.services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homekusine/constance/constance.dart';


class createPost extends StatefulWidget {
  @override
  _createPostState createState() => _createPostState();
}

class _createPostState extends State<createPost> {

  final _formKey = new GlobalKey<FormState>();
  final FireStoreDBServices _fireStoreDbServices = FireStoreDBServices();

  String postTitle, postDateRange, deliveryOption, categoryOption, cuisineOption;
  var dateRangeController;
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    dateRangeController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {

    openDateRangePicker() async {
      final List<DateTime> picked = await DateRagePicker.showDatePicker(
          context: context,
          initialFirstDate: new DateTime.now(),
          initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
          firstDate: new DateTime(2020),
          lastDate: new DateTime(2021)
      );
      if (picked != null && picked.length == 2) {
        print(picked);
      }
    }

    Future getPrePopulateInfo() async {
      QuerySnapshot cuisineListSnapshot = await _fireStoreDbServices.cuisineCollection.getDocuments();
      var cuisineList = cuisineListSnapshot.documents.map((doc) {
        return doc['name'].toString();
      }).toList();

      QuerySnapshot dishCategoryListSnapshot = await _fireStoreDbServices.dishCategoryCollection.getDocuments();
      var dishCategoryList = dishCategoryListSnapshot.documents.map((doc) {
        return doc['name'].toString();
      }).toList();
      return {'cuisineList': cuisineList, 'dishCategoryList': dishCategoryList};
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
        ),
        body: Center(
          child: SafeArea(
            child: Container(
              child: FutureBuilder(
              future: getPrePopulateInfo(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              ColorFiltered(
                                child: Image(
                                  image: AssetImage(defaultPostImage),
                                  height: 200.0,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.fitWidth,
                                ),
                                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                              ),
                              Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.camera_alt, size: 20.0, color: Colors.grey[400],),
                                        ),
                                        TextSpan(text: " Upload Post Image",style: TextStyle(fontSize: 20.0, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                              )
                            ]
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                          child: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                  child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: TextFormField(
                                            cursorColor: Theme.of(context).cursorColor,
                                            style: TextStyle(fontSize: 20.0, color: Colors.lightBlue),
                                            decoration: FormInputBottomDecoration.copyWith(hintText: "Title*"),
                                            validator: (val) => val.isEmpty ? 'Provide a Title' : RegExp(REGEX_PATTERN['ALPHANUMERIC_SPACE']).hasMatch(val) ? null : 'only alphabets are allowed',
                                            onChanged: (val){
                                              setState(() {
                                                this.postTitle = val;
                                              });
                                            },
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(20),
                                            child:
                                            TextField(
                                              // controller: _dobController,
                                              showCursor: true,
                                              controller: dateRangeController,
                                              readOnly: true,
                                              style: TextStyle(fontSize: 20.0),
                                              decoration: FormInputBottomDecoration.copyWith(hintText: "Post Duration*"),
                                              onTap: () async {
                                                print('tapped');
                                                final List<DateTime> picked = await DateRagePicker.showDatePicker(
                                                    context: context,
                                                    initialFirstDate: new DateTime.now(),
                                                    initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
                                                    firstDate: new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                                    lastDate: new DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day)
                                                );
                                                if (picked != null && picked.length == 2) {
                                                  print(picked);
                                                  var dateRange = formatter.format(picked[0]).toString().split(" ")[0] + ' - ' + formatter.format(picked[1]).toString().split(" ")[0];
                                                  print(dateRange);
                                                  dateRangeController = TextEditingController(text: dateRange);
                                                  this.postDateRange = dateRange;
                                                  FocusScope.of(context).unfocus();
                                                }
                                              },
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: <Widget>[
                                                  Text('Dish Info', style: TextStyle(fontSize: 25.0, color: Colors.black)),
                                                  Divider(
                                                    color: Colors.black,
                                                  )
                                                ]
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text('Cuisine'),
                                                        DropdownButton<String>(
                                                          value: cuisineOption,
                                                          icon: const Icon(Icons.arrow_drop_down),
                                                          iconSize: 24,
                                                          elevation: 16,
                                                          underline: Container(
                                                            height: 2,
                                                            color: Colors.lightBlue,
                                                          ),
                                                          onChanged: (String newValue) {
                                                            setState(() {
                                                              cuisineOption = newValue;
                                                            });
                                                          },
                                                          items: snapshot.data['cuisineList']
                                                              .map<DropdownMenuItem<String>>((String value) {
                                                            return DropdownMenuItem<String>(
                                                              value: value,
                                                              child: Text(value),
                                                            );
                                                          }).toList(),
                                                        )
                                                      ],
                                                    )
                                                ),
                                                Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text('Categroy'),
                                                        DropdownButton<String>(
                                                          value: categoryOption,
                                                          icon: const Icon(Icons.arrow_drop_down),
                                                          iconSize: 24,
                                                          elevation: 16,
                                                          underline: Container(
                                                            height: 2,
                                                            color: Colors.lightBlue,
                                                          ),
                                                          onChanged: (String newValue) {
                                                            setState(() {
                                                              categoryOption = newValue;
                                                            });
                                                          },
                                                          items: snapshot.data['dishCategoryList']
                                                              .map<DropdownMenuItem<String>>((String value) {
                                                            return DropdownMenuItem<String>(
                                                              value: value,
                                                              child: Text(value),
                                                            );
                                                          }).toList(),
                                                        )
                                                      ],
                                                    )
                                                ),
                                                Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text('Delivery'),
                                                        DropdownButton<String>(
                                                          value: deliveryOption,
                                                          icon: const Icon(Icons.arrow_drop_down),
                                                          iconSize: 24,
                                                          elevation: 16,
                                                          underline: Container(
                                                            height: 2,
                                                            color: Colors.lightBlue,
                                                          ),
                                                          onChanged: (String newValue) {
                                                            setState(() {
                                                              deliveryOption = newValue;
                                                            });
                                                          },
                                                          items: <String>['Self-pickup', 'Delivery']
                                                              .map<DropdownMenuItem<String>>((String value) {
                                                            return DropdownMenuItem<String>(
                                                              value: value,
                                                              child: Text(value),
                                                            );
                                                          }).toList(),
                                                        )
                                                      ],
                                                    )
                                                ),
                                              ],
                                            )
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),

                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: RaisedButton(
                                              color: Colors.lightBlue,
                                              padding: const EdgeInsets.all(15.0),
                                              onPressed: () {
                                                if(_formKey.currentState.validate()){
                                                  print(_formKey);
                                                  print(_formKey.currentState);
                                                }
                                              },
                                              child: Text(
                                                "Update Personal Info",
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    color: Colors.white
                                                ),
                                              )
                                          ),
                                        )
                                      ]
                                  )
                              )
                          ),
                        )
                      ],
                    );
                  }else {
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
            )
          )
        )
    );
  }
}
