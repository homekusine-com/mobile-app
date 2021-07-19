import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:homekusine/model/db.model.dart';
import 'package:homekusine/screens/authenticate/register.dart';
import 'package:homekusine/services/fireStoreDB.services.dart';
import 'package:homekusine/services/storage.services.dart';
import 'package:homekusine/services/user.services.dart';
import 'package:homekusine/services/utility.services.dart';
import 'package:homekusine/shared/widgets/toaster.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:homekusine/providers/auth.provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homekusine/constance/constance.dart';


class createPost extends StatefulWidget {
  @override
  _createPostState createState() => _createPostState();
}

class _createPostState extends State<createPost> {

  final _formKey = new GlobalKey<FormState>();
  final FireStoreDBServices _fireStoreDbServices = FireStoreDBServices();
  final UserServices userServices = UserServices();
  final StorageServices _storageServices = StorageServices();
  final UtilityServices _utility = UtilityServices();

  String postTitle, deliveryOption, postDescription, availability, uploadImageSourceType;
  DateTime postFromDate, postToDate;
  Cuisine _cuisineOption;
  DishCategory categoryOption;
  var dateRangeController, price;
  List<String> dishItemName = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final TextEditingController _dishNametextController = new TextEditingController();
  final Toaster toast = new Toaster();
  bool isCreatingPost = false;
  final geo = Geoflutterfire();

  File postPicFile;
  bool isUploadImg = false;

  PageController _pageController;

  @override
  void initState() {
    super.initState();
    dateRangeController = TextEditingController(text: "");
    _pageController = PageController();
    // focusProfileNameNode = FocusNode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // focusProfileNameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    Future getPrePopulateInfo() async {
      QuerySnapshot cuisineListSnapshot = await _fireStoreDbServices.cuisineCollection.getDocuments();
      List<Cuisine> cuisineList = cuisineListSnapshot.documents.map((doc) {
        Cuisine item = new Cuisine();
        item.name = doc['name'].toString();
        item.id = doc['id'].toString();
        return item;
      }).toList();

      QuerySnapshot dishCategoryListSnapshot = await _fireStoreDbServices.dishCategoryCollection.getDocuments();
      var dishCategoryList = dishCategoryListSnapshot.documents.map((doc) {
        DishCategory item = new DishCategory();
        item.name = doc['name'].toString();
        item.id = doc['id'].toString();
        return item;
      }).toList();
      return {'cuisineList': cuisineList, 'dishCategoryList': dishCategoryList};
    }

    addPost() async {
      setState(() {
        this.isCreatingPost = true;
      });
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      var locationObj = position.toString().split(',').map((String point) => point.split(": ")[1]);
      var lat = double.parse(locationObj.first);
      var long = double.parse(locationObj.last);
      GeoFirePoint myLocation = geo.point(latitude: lat, longitude: long);

      _fireStoreDbServices.cuisineCollection.where('name', isEqualTo: _cuisineOption.name);
      _fireStoreDbServices.dishCategoryCollection.where('name', isEqualTo: categoryOption.name);
      userServices.userCollection.document(auth.uid).get();

      var postInfo = {
        'title':  postTitle,
        'fromDate': postFromDate,
        'toDate': postToDate,
        'delivery': deliveryOption,
        'cuisine': Firestore.instance.document('cuisine/' + _cuisineOption.id),
        'dish_category': Firestore.instance.document('dish_category/' + categoryOption.id),
        'description': postDescription,
        'availability': availability,
        'price': price,
        'itemName': dishItemName,
        'location': myLocation.data,
        'users': Firestore.instance.document('users/' + auth.uid)
      };

      await _fireStoreDbServices.postCollection.add(postInfo).then((postDocRef) {
        if(postPicFile != null ) {
          StorageUploadTask task = _storageServices.startPostPicUpload(postDocRef.documentID, postPicFile);
          new Timer.periodic(new Duration(seconds: 1), (timer) {
            if(task.isSuccessful){
              timer.cancel();
              _formKey?.currentState?.reset();
              _dishNametextController.clear();

              _fireStoreDbServices.postCollection.document(postDocRef.documentID).updateData({'imgURL': '${storagePaths['postImage']}/${postDocRef.documentID}.png'});
              toast.showSuccessToast('Post successfully created');
              Navigator.pop(context);
            }
            if(task.isCanceled){
              _utility.popRoute(context);
              Toaster().showToast("Failed to upload your image, Please try again");
              timer.cancel();
              setState(() {
                this.isCreatingPost = false;
              });
            }
          });
        } else {
          _formKey?.currentState?.reset();
          _dishNametextController.clear();
          toast.showSuccessToast('Post successfully created');
          Navigator.pop(context);
        }

      }).catchError((onError){
        print(onError.toString());
        toast.showToast('Post creation failed, Please try after some time');
      });
    }

    void _showImageUpload() {
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
            height: 200,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: <Widget>[
                    Container(
                      height: 50,
                      child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                child: Icon(Icons.grid_on, color: Colors.blue),
                              ),
                              Text('Upload From Gallery', style: linkStyleBlue,),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              this.uploadImageSourceType = "gallery";
                            });
                            Navigator.pop(context);
                            _pageController.animateToPage(
                              1,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear,
                            );
                          }
                      ),
                    ),
                    Container(
                      height: 50,
                      child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                child: Icon(Icons.camera_alt, color: Colors.blue),
                              ),
                              Text('Capture your food', style: linkStyleBlue,),
                            ],
                          ),
                          onTap: () async {
                            setState(() {
                              this.uploadImageSourceType = "camera";
                            });
                            Navigator.pop(context);
                            _pageController.animateToPage(
                              1,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear,
                            );
                          }
                      ),
                    ),
                    Container(
                      height: 50,
                      child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                child: Icon(Icons.cancel, color: Colors.redAccent),
                              ),
                              Text('Cancel', style: linkStyle.copyWith(color: Colors.redAccent),),
                            ],
                          ),
                          onTap: () => Navigator.pop(context)
                      ),
                    ),
                  ],
                )
            )
        );
      });
    }

    onImageUpload(File newFilePath) {
      setState(() {
        postPicFile = newFilePath;
        isUploadImg = true;
      });
    }

    createPostScreen(_pageController) {
      return Container(
          child: FutureBuilder(
              future: getPrePopulateInfo(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            ColorFiltered(
                              child: Image(
                                image: isUploadImg ? FileImage(postPicFile) : AssetImage(defaultPostImage),
                                height: 200.0,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fitWidth,
                              ),
                              colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                            ),
                            Center(
                                child: InkWell(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: Icon(Icons.camera_alt, size: 20.0, color: Colors.grey[400],),
                                          ),
                                          TextSpan(
                                            text: " Upload Post Image",
                                            style: TextStyle(fontSize: 20.0, color: Colors.grey[400], fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () => _showImageUpload()
                                ),
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
                                          Column(
                                            children: <Widget>[
                                              Text('if you want to select single day, double tap on the same day'),
                                              TextFormField(
                                                // controller: _dobController,
                                                showCursor: true,
                                                controller: dateRangeController,
                                                readOnly: true,
                                                validator: (val) => val.isEmpty ? 'Provide Time duration' : null,
                                                style: TextStyle(fontSize: 20.0),
                                                decoration: FormInputBottomDecoration.copyWith(hintText: "Post Duration*"),
                                                onTap: () async {
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
                                                    dateRangeController = TextEditingController(text: dateRange);
                                                    this.postFromDate = picked[0];
                                                    this.postToDate = picked[1];
                                                    FocusScope.of(context).unfocus();
                                                  }
                                                },
                                              )
                                            ],
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                Text('Dish Info', style: TextStyle(fontSize: 22.0)),
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
                                                      Text('Cuisine', style: TextStyle(fontSize: 18.0)),
                                                      DropdownButton<Cuisine>(
                                                        icon: const Icon(Icons.arrow_drop_down),
                                                        iconSize: 24,
                                                        elevation: 16,
                                                        underline: Container(
                                                          height: 2,
                                                          color: Colors.lightBlue,
                                                        ),
                                                        items: snapshot.data['cuisineList']
                                                            .map<DropdownMenuItem<Cuisine>>(
                                                                (Cuisine value) {
                                                              return DropdownMenuItem<Cuisine>(
                                                                value: value,
                                                                child: Text(value.name, style: TextStyle(color: Colors.lightBlue)),
                                                              );
                                                            }).toList(),
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            _cuisineOption = newValue;
                                                          });
                                                        },
                                                        value: _cuisineOption ?? null,
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Expanded(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text('Categroy', style: TextStyle(fontSize: 18.0)),
                                                      DropdownButton<DishCategory>(
                                                        value: categoryOption,
                                                        icon: const Icon(Icons.arrow_drop_down),
                                                        iconSize: 24,
                                                        elevation: 16,
                                                        underline: Container(
                                                          height: 2,
                                                          color: Colors.lightBlue,
                                                        ),
                                                        onChanged: (DishCategory newValue) {
                                                          setState(() {
                                                            categoryOption = newValue;
                                                          });
                                                        },
                                                        items: snapshot.data['dishCategoryList']
                                                            .map<DropdownMenuItem<DishCategory>>((DishCategory value) {
                                                          return DropdownMenuItem<DishCategory>(
                                                            value: value,
                                                            child: Text(value.name, style: TextStyle(color: Colors.lightBlue)),
                                                          );
                                                        }).toList(),
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Expanded(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text('Delivery', style: TextStyle(fontSize: 18.0)),
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
                                                            child: Text(value, style: TextStyle(color: Colors.lightBlue)),
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
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                              children: <Widget>[
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('Description *', textAlign: TextAlign.left, style: TextStyle(fontSize: 18.0)),
                                                ),
                                                TextFormField(
                                                  cursorColor: Theme.of(context).cursorColor,
                                                  keyboardType: TextInputType.multiline,
                                                  textInputAction: TextInputAction.newline,
                                                  minLines: 1,
                                                  maxLines: 5,
                                                  style: TextStyle(fontSize: 20.0, color: Colors.lightBlue),
                                                  decoration: FormInputBottomDecoration.copyWith(hintText: "enter info about quantity and nature of food posted*"),
                                                  // validator: (val) => val.isEmpty ? 'provide some dish info' : RegExp(REGEX_PATTERN['ALPHANUMERIC_SPACE']).hasMatch(val) ? null : 'no special character allowed',
                                                  validator: (val) => val.isEmpty ? 'provide some dish info' : null,
                                                  onChanged: (val){
                                                    setState(() {
                                                      this.postDescription = val;
                                                    });
                                                  },
                                                ),
                                              ]
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  child: TextFormField(
                                                    cursorColor: Theme.of(context).cursorColor,
                                                    keyboardType: TextInputType.number,
                                                    style: TextStyle(fontSize: 20.0, color: Colors.lightBlue),
                                                    decoration: FormInputBottomDecoration.copyWith(hintText: "Price*"),
                                                    validator: (val) => val.isEmpty ? 'Provide a price value' : RegExp('^[0-9]').hasMatch(val) ? null : 'only numbers are allowed',
                                                    onChanged: (val){
                                                      setState(() {
                                                        this.price = val;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text('Availability', style: TextStyle(fontSize: 18.0)),
                                                      DropdownButton<String>(
                                                        icon: const Icon(Icons.arrow_drop_down),
                                                        iconSize: 24,
                                                        elevation: 16,
                                                        underline: Container(
                                                          height: 2,
                                                          color: Colors.lightBlue,
                                                        ),
                                                        items: ['Breakfast', 'Lunch', 'Evening Snack', 'Dinner', 'All Time']
                                                            .map<DropdownMenuItem<String>>(
                                                                (String value) {
                                                              return DropdownMenuItem<String>(
                                                                value: value,
                                                                child: Text(value, style: TextStyle(color: Colors.lightBlue)),
                                                              );
                                                            }).toList(),
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            availability = newValue;
                                                          });
                                                        },
                                                        value: availability ?? null,
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ]
                                          )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: <Widget>[
                                            Wrap(
                                              alignment: WrapAlignment.start,
                                              direction: Axis.horizontal,
                                              children:  <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Text(
                                                    'You can add your dish name here, so when people search specific dish your post will get listed, multiple names can also be entered',
                                                    style: TextStyle(fontSize: 16.0),
                                                  ),
                                                )
                                              ],
                                            ),
                                            RawKeyboardListener(
                                                child: TextFormField(
                                                    cursorColor: Theme.of(context).cursorColor,
                                                    textInputAction: TextInputAction.go,
                                                    controller: _dishNametextController,
                                                    style: TextStyle(fontSize: 20.0, color: Colors.lightBlue),
                                                    decoration: FormInputBottomDecoration.copyWith(hintText: "Enter dish name and hit enter"),
                                                    onFieldSubmitted: (val) async {
                                                      if(val != null && val != ''){
                                                        setState(() {
                                                          this.dishItemName.add(
                                                              val);
                                                        });
                                                        _dishNametextController.clear();
                                                      }
                                                    }
                                                ),
                                                focusNode: FocusNode(),
                                                onKey: (RawKeyEvent event) {
                                                  if(event.data.logicalKey
                                                      .keyId == 4295426088) {
                                                    if(_dishNametextController.text != null && _dishNametextController.text != '') {
                                                      setState(() {
                                                        this.dishItemName.add(
                                                            _dishNametextController
                                                                .text);
                                                      });
                                                      _dishNametextController
                                                          .clear();
                                                    }
                                                  }
                                                }
                                            ),
                                            Wrap(
                                              alignment: WrapAlignment.start,
                                              direction: Axis.horizontal,
                                              children:
                                              List.generate(dishItemName.length,(index){
                                                // return Text(dishItemName[index].toString());
                                                return Container(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Chip(
                                                      backgroundColor: Colors.amberAccent,
                                                      // avatar: CircleAvatar(child: Text(actor.initials)),
                                                      label: Text(dishItemName[index].toString()),
                                                      onDeleted: () {
                                                        setState(() {
                                                          this.dishItemName.removeWhere((name) {
                                                            return name == dishItemName[index];
                                                          });
                                                        });
                                                      },
                                                    )
                                                );
                                              }),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: !isCreatingPost ? RaisedButton(
                                            color: Colors.lightBlue,
                                            padding: const EdgeInsets.all(15.0),
                                            onPressed: () {
                                              if(_formKey.currentState.validate()){
                                                addPost();
                                              }
                                            },
                                            child: Text(
                                              "Create Post",
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.white
                                              ),
                                            )
                                        ) : Center(
                                          child: Column(
                                            children: <Widget>[
                                              SpinKitWave(
                                                color: Colors.redAccent,
                                                size: 25.0,
                                              ),
                                              Text('Creating Post...', style: TextStyle(color: Colors.redAccent, fontSize: 16.0),)
                                            ],
                                          ),
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
      );
    }

    profilePicUpload(_pageController, sourceType, onImageUpload) {
      return Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: ImageCapture(pageController: _pageController, uploadImageType: sourceType, onImageUpload: onImageUpload),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
        ),
        body: Center(
          child: SafeArea(
            child: PageView(
                physics:new NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  Container(
                    child: createPostScreen(_pageController),
                  ),
                  Container(
                      child: profilePicUpload(_pageController, this.uploadImageSourceType, onImageUpload)
                  )
                ]
            )
          )
        )
    );
  }
}


class ImageCapture extends StatefulWidget {

  const ImageCapture({
    @required this.uploadImageType,
    @required this.pageController,
    @required this.onImageUpload,
    Key key
  }): super(key: key);

  final String uploadImageType;
  final Function(File) onImageUpload;
  final PageController pageController;

  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {

  //Active image file
  File _imageFile;
  final picker = ImagePicker();

  ImageUploadStatus _status = ImageUploadStatus.Initialised;

  backToPrevPage() {
    widget.pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  //select image via Gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final selected = await picker.getImage(source: source);
    if(selected != null && selected.path != null){
      setState(() {
        _imageFile = File(selected.path);
      });
    }else{
      backToPrevPage();
    }
  }

  void _clearImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Future<void> _cropImage(uid, context) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        maxHeight: 512,
        maxWidth: 512,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.black38,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        )
    );
    if (cropped != null) {
      var result = await FlutterImageCompress.compressAndGetFile(cropped.path, _imageFile.path, quality: 50);
      widget.onImageUpload(result);
      backToPrevPage();
      // need to trigger on post save
      // _uploadProfileImg(uid, result, context);
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if(_imageFile == null && _status == ImageUploadStatus.Initialised){
      _pickImage(widget.uploadImageType == "gallery" ? ImageSource.gallery : ImageSource.camera);
      _status = ImageUploadStatus.SourceInit;
    }else if(_imageFile == null && _status == ImageUploadStatus.SourceInit){
      backToPrevPage();
    }else if(_imageFile != null){
      _status = ImageUploadStatus.Selected;
    }
    return Scaffold(
      body: ListView(
        children: <Widget>[
          (_status == ImageUploadStatus.Selected) ? Container(
            child: Column(
              children: <Widget>[
                Image.file(_imageFile),
              ],
            ),
          ) : Container()
        ],
      ),
      bottomNavigationBar : BottomAppBar(
        color: Colors.grey,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: FlatButton(
                    color: Colors.grey,
                    onPressed: () => _cropImage(auth.uid, context),
                    child: RichText(
                        text: TextSpan(
                            children:[
                              WidgetSpan(
                                child: Icon(Icons.crop, size: 20.0, color: Colors.white),
                              ),
                              TextSpan(
                                  text: "  Crop",
                                  style: TextStyle(
                                      fontSize: 20.0
                                  )
                              ),
                            ]
                        )
                    )
                ),
              ),
              flex: 1,
            ),
            Expanded(
                child: Container(
                    child: FlatButton(
                        color: Colors.grey,
                        onPressed: backToPrevPage,
                        child: RichText(
                            text: TextSpan(
                                children:[
                                  WidgetSpan(
                                    child: Icon(Icons.cancel, size: 20.0, color: Colors.white),
                                  ),
                                  TextSpan(
                                      text: "  Cancel",
                                      style: TextStyle(
                                          fontSize: 20.0
                                      )
                                  ),
                                ]
                            )
                        )
                    )
                )
            )
          ],
        ),
      ),
    );
  }
}