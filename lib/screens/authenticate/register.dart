import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:homekusine/model/user.model.dart';
import 'package:homekusine/services/storage.services.dart';
import 'package:homekusine/services/user.services.dart';
import 'package:provider/provider.dart';
import 'package:homekusine/providers/auth.provider.dart';
import 'package:homekusine/constance/constance.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

enum ImageUploadStatus {Initialised, SourceInit, Selected, Uploading, Completed}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final _formKey = new GlobalKey<FormState>();
  final StorageServices _storageServices = StorageServices();
  final UserServices _userService = UserServices();

  String firstName, lastName, profileName, gender, DOB, doorNo, streetName, city, postCode, isChef, dob, uploadImageSourceType;
  TextEditingController _dobController = new TextEditingController(text: DateFormat('MMMM dd yyyy').format(new DateTime(1993, 1, 1)));
  bool isProfileNameAvailable = true;

  var genderList = ['Male', 'Female', 'TransGender'];

  File profilePicFile;
  String profilePicPath = defaultProfileImage;
  FocusNode focusProfileNameNode;


  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    focusProfileNameNode = FocusNode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    focusProfileNameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final auth = Provider.of<AuthProvider>(context);



    onImageUpload(File newFilePath) {
      setState(() {
        profilePicFile = newFilePath;
        profilePicPath = newFilePath.path;
      });
    }

    addListnerToTextField() {
      focusProfileNameNode.addListener(() async {
        // TextField lost focus
        if (!focusProfileNameNode.hasFocus && this.profileName != null) {
          // Execute your API validation here
          await _userService.userCollection
            ..where("profileName",isEqualTo: this.profileName)
                .getDocuments().then((query) {
              if(query.documents.length == 0){
                setState(() {
                  isProfileNameAvailable = true;
                });
              }else {
                setState(() {
                  isProfileNameAvailable = false;
                });
              }
            });
        }
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
                          Text('Upload From Gallery', style: linkStyle,),
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
                          Text('Take a selfie', style: linkStyle,),
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

    void _showDatePicker() {
      showModalBottomSheet(context: context, builder: (context) {
        DateTime selectedDOB;
        return Container(
          height: 350.0,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime(1993, 1, 1),
                    onDateTimeChanged: (DateTime newDateTime) => selectedDOB = newDateTime,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: FlatButton(
                      color: Colors.blue,
                      onPressed: (){

                        this.dob = (selectedDOB != null) ? DateFormat('yyyyMMdd').format(selectedDOB) : DateFormat('yyyyMMdd').format(new DateTime(1993, 1, 1));
                        print(this.dob);
                        _dobController.value = (selectedDOB != null) ? TextEditingValue(text: DateFormat('MMMM dd yyyy').format(selectedDOB)): DateFormat('MMMM dd yyyy').format(new DateTime(1993, 1, 1));
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Select Date of Birth",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0
                        ),
                      )
                  ),
                )
              ]
            ),
          ),
        );
      });
    }

    updatePersonalInformation() {
      if(profilePicPath != defaultProfileImage){
        _storageServices.startProfilePicUpload(auth.uid, profilePicFile);
      }
      dynamic userInfo = {
        "firstName" : this.firstName,
        "lastName": this.lastName,
        "gender": this.gender,
        "profileName": this.profileName,
        "DOB": this.dob,
        "doorNo": this.doorNo,
        "streetName": this.streetName,
        "city": this.city,
        "postCode": this.postCode,
        "isChef": this.isChef,
        "isRegistered": true,
        "updatedAt": new DateTime.now()
      };
      _userService.userCollection.document(auth.uid).updateData(userInfo)
          .then((onValue){
            print('saved data');
          })
          .catchError((onError) {
            print(onError.toString());
          });
    }

    personalInfoForm(_pageController) {
      return Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: CircleAvatar(
                          radius: 85,
                          backgroundColor: Colors.blue,
                          child: CircleAvatar(
                            radius: 80.0,
                            backgroundImage: AssetImage(profilePicPath),
                          ),
                        )
                      ),
                    ),
                    Center(
                      child: InkWell(
                          child: new Text('Upload Profile Picture', style: linkStyle),
                          onTap: () => _showImageUpload()
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20.0),
                        decoration: textInputDecoration.copyWith(hintText: "First Name*"),
                        validator: (val) => val.isEmpty ? 'Please provide a First Name' : RegExp(REGEX_PATTERN['ONLY_ALPHABETS']).hasMatch(val) ? null : 'only alphabets are allowed',
                        onChanged: (val){
                          setState(() {
                            this.firstName = val;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20.0),
                        decoration: textInputDecoration.copyWith(hintText: "Last Name*"),
                        validator: (val) => val.isEmpty ? 'Please provide a Last Name' : RegExp(REGEX_PATTERN['ONLY_ALPHABETS']).hasMatch(val) ? null : 'only alphabets are allowed',
                        onChanged: (val){
                          setState(() {
                            this.lastName = val;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20.0),
                        decoration: textInputDecoration.copyWith(hintText: "Profile Name*"),
                        validator: (val) => val.isEmpty ? 'Please provide a Profile Name' : RegExp(REGEX_PATTERN['ONLY_ALPHANUMERIC']).hasMatch(val) ? null : 'Only Alpha numeric characters',
                        onChanged: (val){
                         addListnerToTextField();
                          setState(() {
                            this.profileName = val;
                          });
                        },
                        focusNode: focusProfileNameNode,
                      ),
                    ),
                    isProfileNameAvailable ? Container() : Text('Profile Name taken, please try with some other name', style: TextStyle(color: Colors.red),),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: TextField(
                                controller: _dobController,
                                showCursor: true,
                                readOnly: true,
                                style: TextStyle(fontSize: 20.0),
                                decoration: textInputDecoration.copyWith(hintText: "DOB*"),
                                onTap: () => _showDatePicker(),
                              ),
                            ),
                            flex: 1,
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            child: Container(
                                child: DropdownButtonFormField(
                                    items: genderList.map((String genderItem) {
                                      return new DropdownMenuItem(
                                          value: genderItem,
                                          child: Row(
                                            children: <Widget>[
                                              Text(genderItem),
                                            ],
                                          )
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      // do other stuff with _category
                                      setState(() => this.gender = newValue);
                                    },
                                    value: this.gender,
                                    decoration: dropDownInputDecoration.copyWith(hintText: "Select a Gender"),
                                    validator: (val) => val == null ? 'Please select a gender' : null,
                                )
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: TextFormField(
                                style: TextStyle(fontSize: 20.0),
                                decoration: textInputDecoration.copyWith(hintText: "Door No*"),
                                validator: (val) => val.isEmpty ? 'Please provide a Door No' : RegExp(REGEX_PATTERN['ALPHANUMERIC_SPACE_SOMESPL']).hasMatch(val) ? null : 'No Special chars allowed except / , -',
                                onChanged: (val){
                                  setState(() {
                                    this.doorNo = val;
                                  });
                                },
                              ),
                            ),
                            flex: 1,
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            child: Container(
                              child: TextFormField(
                                style: TextStyle(fontSize: 20.0),
                                decoration: textInputDecoration.copyWith(hintText: "Street Name*"),
                                validator: (val) => val.isEmpty ? 'Please provide a Street Name' : RegExp(REGEX_PATTERN['ALPHANUMERIC_SPACE_SOMESPL']).hasMatch(val) ? null : 'No Special chars allowed except / , -',
                                onChanged: (val){
                                  setState(() {
                                    this.streetName = val;
                                  });
                                },
                              ),
                            ),
                            flex: 2,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: TextFormField(
                                style: TextStyle(fontSize: 20.0),
                                decoration: textInputDecoration.copyWith(hintText: "City*"),
                                validator: (val) => val.isEmpty ? 'Please provide city name' : RegExp(REGEX_PATTERN['ONLY_ALPHABETS']).hasMatch(val) ? null : 'Only Alphabets are allowed',
                                onChanged: (val){
                                  setState(() {
                                    this.city = val;
                                  });
                                },
                              ),
                            ),
                            flex: 2,
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            child: Container(
                              child: TextFormField(
                                style: TextStyle(fontSize: 20.0),
                                keyboardType: TextInputType.phone,
                                decoration: textInputDecoration.copyWith(hintText: "Postcode*"),
                                validator: (val) => val.isEmpty ? 'Please provide a Postcode' : RegExp(REGEX_PATTERN['ONLY_ALPHANUMERIC']).hasMatch(val) ? null : 'No special char allowed',
                                onChanged: (val){
                                  setState(() {
                                    this.postCode = val;
                                  });
                                },
                              ),
                            ),
                            flex: 2,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                          color: Colors.blue,
                          padding: const EdgeInsets.all(15.0),
                          onPressed: () {
                            if(_formKey.currentState.validate() && isProfileNameAvailable){
                              updatePersonalInformation();
                              auth.registrationCompleted();
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
              ),
            )
        ),
      );
    }

    profilePicUpload(_pageController, sourceType, onImageUpload) {
      return Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: ImageCapture(pageController: _pageController, uploadImageType: sourceType, onImageUpload: onImageUpload),
      );
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          Container(
            child: personalInfoForm(_pageController),
          ),
          Container(
            child: profilePicUpload(_pageController, this.uploadImageSourceType, onImageUpload)
          )
        ]
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
      print(selected.path);
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

  Future<void> _cropImage(uid) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        )
    );
    if (cropped != null) {
      setState(() {
        _imageFile = cropped;
      });
      widget.onImageUpload(cropped);
      backToPrevPage();
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
        color: Colors.amber,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: FlatButton(
                    color: Colors.amber,
                    onPressed: () => _cropImage(auth.uid),
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
                      color: Colors.amber,
                      onPressed: () {
                        widget.onImageUpload(_imageFile);
                        backToPrevPage();
                      },
                      child: RichText(
                          text: TextSpan(
                              children:[
                                WidgetSpan(
                                  child: Icon(Icons.save, size: 20.0, color: Colors.white),
                                ),
                                TextSpan(
                                    text: "  Save",
                                    style: TextStyle(
                                        fontSize: 20.0
                                    )
                                ),
                              ]
                          )
                      )
                  )
              )
            ),
            Expanded(
              child: Container(
                child: FlatButton(
                  color: Colors.amber,
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
