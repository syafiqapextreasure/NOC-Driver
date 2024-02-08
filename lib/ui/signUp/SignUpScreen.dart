import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/CarMakes.dart';
import 'package:nocdriver/model/CarModel.dart';
import 'package:nocdriver/model/SectionModel.dart';
import 'package:nocdriver/model/User.dart';
import 'package:nocdriver/model/VehicleType.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:nocdriver/ui/auth/AuthScreen.dart';
import 'package:nocdriver/ui/container/ContainerScreen.dart';
import 'package:nocdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:url_launcher/url_launcher.dart';

File? _image;
File? _carImage;
File? _passportImage;
File? _licenceImage;
File? _diskImage;
File? _insuranceImage;

class SignUpScreen extends StatefulWidget {
  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _carNameController = TextEditingController();
  TextEditingController _carPlateController = TextEditingController();
  TextEditingController _carColorController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  GlobalKey<FormState> _deliveryKey = GlobalKey();
  GlobalKey<FormState> _cabServiceKey = GlobalKey();
  GlobalKey<FormState> _parcelServiceKey = GlobalKey();
  GlobalKey<FormState> _rentalServiceKey = GlobalKey();
  bool isUserImage = true;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  TextEditingController _companyNameController = TextEditingController();
  TextEditingController _companyAddressController = TextEditingController();

  List<String> _locations = [
    'Delivery service',
    'Cab service',
    'Parcel service',
    'Rental Service'
  ]; // Option 2
  String? _selectedServiceType;

  @override
  void initState() {
    getCarMakes();
    super.initState();
  } // Option 2

  List<CarMakes> carMakesList = [];
  List<CarModel> carModelList = [];

  CarMakes? selectedCarMakes;
  CarModel? selectedCarModel;
  List<VehicleType> vehicleType = [];
  List<VehicleType> rentalVehicleType = [];
  VehicleType? selectedRentalVehicleType;
  VehicleType? selectedVehicleType;

  List<SectionModel>? sectionsVal = [];
  SectionModel? selectedSection;

  getCarMakes() async {
    await FireStoreUtils.getCarMakes().then((value) {
      setState(() {
        carMakesList = value;
      });
    });

    await FireStoreUtils.getRentalVehicleType().then((value) {
      setState(() {
        rentalVehicleType = value;
      });
    });

    await FireStoreUtils.getSections().then((value) {
      setState(() {
        sectionsVal = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      retrieveLostData();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
            color: isDarkMode(context) ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: Column(
            children: [
              Align(
                  alignment: Directionality.of(context) == TextDirection.ltr
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  child: Text(
                    'Create new account',
                    style: TextStyle(
                        fontFamily: "GlacialIndifference",
                        color: Color(COLOR_PRIMARY),
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0),
                  ).tr()),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, top: 32, right: 8, bottom: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade400,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: _image == null
                                        ? Image.asset(
                                            'assets/images/placeholder.jpg',
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _image!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 60,
                                right: 0,
                                child: FloatingActionButton(
                                  heroTag: 'profileImage',
                                  backgroundColor: Color(COLOR_ACCENT),
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    color: isDarkMode(context)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  mini: true,
                                  onPressed: () => _onCameraClick(true),
                                ),
                              ),
                            ],
                          ),
                          Text('Driver Image'),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade400,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: _carImage == null
                                        ? Image.asset(
                                            'assets/images/car_default_image.png',
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _carImage!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 60,
                                right: 0,
                                child: FloatingActionButton(
                                  heroTag: 'carImage',
                                  backgroundColor: Color(COLOR_ACCENT),
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    color: isDarkMode(context)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  mini: true,
                                  onPressed: () => _onCameraClick(false),
                                ),
                              )
                            ],
                          ),
                          Text('Car Picture')
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade400,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: _passportImage == null
                                        ? Image.asset(
                                            'assets/images/passport.jpg',
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _passportImage!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 60,
                                right: 0,
                                child: FloatingActionButton(
                                  heroTag: 'IC/Passport',
                                  backgroundColor: Color(COLOR_ACCENT),
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    color: isDarkMode(context)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  mini: true,
                                  onPressed: () => _onCameraClick1(true),
                                ),
                              )
                            ],
                          ),
                          Text('PSV Image')
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade400,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: _licenceImage == null
                                        ? Image.asset(
                                            'assets/images/licence.png',
                                            fit: BoxFit.contain,
                                          )
                                        : Image.file(
                                            _licenceImage!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 60,
                                right: 0,
                                child: FloatingActionButton(
                                  heroTag: 'PSV License',
                                  backgroundColor: Color(COLOR_ACCENT),
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    color: isDarkMode(context)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  mini: true,
                                  onPressed: () => _onCameraClick1(false),
                                ),
                              )
                            ],
                          ),
                          Text('License Image')
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade400,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: _diskImage == null
                                        ? Image.asset(
                                            'assets/images/disk.jpg',
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _diskImage!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 60,
                                right: 0,
                                child: FloatingActionButton(
                                  heroTag: 'Puspakom Disc',
                                  backgroundColor: Color(COLOR_ACCENT),
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    color: isDarkMode(context)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  mini: true,
                                  onPressed: () => _onCameraClick2(true),
                                ),
                              )
                            ],
                          ),
                          Text('  Puspakom Disc')
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade400,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: _insuranceImage == null
                                        ? Image.asset(
                                            'assets/images/insuarnce.jpg',
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _insuranceImage!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 60,
                                right: 0,
                                child: FloatingActionButton(
                                  heroTag: 'Insurance Policy ',
                                  backgroundColor: Color(COLOR_ACCENT),
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    color: isDarkMode(context)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  mini: true,
                                  onPressed: () => _onCameraClick2(false),
                                ),
                              )
                            ],
                          ),
                          Text('Insurance Image')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: DropdownButtonFormField(
                  hint: Text('Please choose a service type.'),
                  // Not necessary for Option 1
                  value: _selectedServiceType,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedServiceType = newValue.toString();
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                            color: Color(COLOR_PRIMARY), width: 2.0)),
                  ),
                  items: _locations.map((location) {
                    return DropdownMenuItem(
                      child: new Text(location),
                      value: location,
                    );
                  }).toList(),
                ),
              ),
              _selectedServiceType == "Delivery service"
                  ? Form(
                      key: _deliveryKey,
                      autovalidateMode: _validate,
                      child: formUI(),
                    )
                  : _selectedServiceType == "Parcel service"
                      ? Form(
                          key: _parcelServiceKey,
                          autovalidateMode: _validate,
                          child: formParcelServiceUI(),
                        )
                      : _selectedServiceType == "Rental Service"
                          ? Form(
                              key: _rentalServiceKey,
                              autovalidateMode: _validate,
                              child: formRentalServiceUI(),
                            )
                          : _selectedServiceType == "Cab service"
                              ? Form(
                                  key: _cabServiceKey,
                                  autovalidateMode: _validate,
                                  child: formCabServiceUI(),
                                )
                              : Container(),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'OR',
                    style: TextStyle(
                        fontFamily: "GlacialIndifference",
                        color:
                            isDarkMode(context) ? Colors.white : Colors.black),
                  ).tr(),
                ),
              ),
              InkWell(
                onTap: () {
                  push(context, PhoneNumberInputScreen(login: false));
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                  child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: Color(COLOR_PRIMARY), width: 1)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.phone,
                              color: isDarkMode(context)
                                  ? Colors.yellow
                                  : Colors.black,
                            ),
                            Text(
                              'Sign up with phone number'.tr(),
                              style: TextStyle(
                                  fontFamily: "GlacialIndifference",
                                  color: isDarkMode(context)
                                      ? Colors.yellow
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1),
                            ),
                          ])),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                  onTap: _launchURL,
                  child: Text('I hereby agreed to T&C for using Noc apps'))
            ],
          ),
        ),
      ),
    );
  }

  _launchURL() async {
    final Uri url = Uri.parse('https://noc-global.com/terms-of-service');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse? response = await _imagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (isUserImage) {
          _image = File(response.file!.path);
        } else {
          _carImage = File(response.file!.path);
        }
      });
    }
  }

  File? _carProofPictureFile;
  File? _driverProofPictureURLFile;

  _onPickupCarProofAndDriverProof(bool isDriver) {
    final action = CupertinoActionSheet(
      message: const Text(
        'Add your Vehicle image.',
        style: TextStyle(fontFamily: "GlacialIndifference", fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            if (isDriver) {
              XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (singleImage != null) {
                setState(() {
                  _driverProofPictureURLFile = File(singleImage.path);
                });
              }
            } else {
              XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (singleImage != null) {
                setState(() {
                  _carProofPictureFile = File(singleImage.path);
                });
              }
            }
          },
          child: const Text('Choose image from gallery'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            if (isDriver) {
              final XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (singleImage != null) {
                setState(() {
                  _driverProofPictureURLFile = File(singleImage.path);
                });
              }
            } else {
              final XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (singleImage != null) {
                setState(() {
                  _carProofPictureFile = File(singleImage.path);
                });
              }
            }
          },
          child: const Text('Take a picture'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text(
          'Cancel',
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _onCameraClick(bool isUserImage) {
    isUserImage = isUserImage;
    final action = CupertinoActionSheet(
      message: Text(
        isUserImage ? 'Add profile picture'.tr() : 'Add Car Image'.tr(),
        style: TextStyle(fontFamily: "GlacialIndifference", fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                isUserImage
                    ? _image = File(image.path)
                    : _carImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                isUserImage
                    ? _image = File(image.path)
                    : _carImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Remove picture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isUserImage ? _image = null : _carImage = null;
            });
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _onCameraClick1(bool isUserImage) {
    isUserImage = isUserImage;
    final action = CupertinoActionSheet(
      message: Text(
        isUserImage ? 'Add profile picture'.tr() : 'Add Car Image'.tr(),
        style: TextStyle(fontFamily: "GlacialIndifference", fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                isUserImage
                    ? _passportImage = File(image.path)
                    : _licenceImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                isUserImage
                    ? _passportImage = File(image.path)
                    : _licenceImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Remove picture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isUserImage ? _passportImage = null : _licenceImage = null;
            });
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _onCameraClick2(bool isUserImage) {
    isUserImage = isUserImage;
    final action = CupertinoActionSheet(
      message: Text(
        isUserImage ? 'Add profile picture'.tr() : 'Add Car Image'.tr(),
        style: TextStyle(fontFamily: "GlacialIndifference", fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                isUserImage
                    ? _diskImage = File(image.path)
                    : _insuranceImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                isUserImage
                    ? _diskImage = File(image.path)
                    : _passportImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Remove picture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isUserImage ? _diskImage = null : _passportImage = null;
            });
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Widget formUI() {
    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _firstNameController,
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validateName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: easyLocal.tr('First Name'),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _lastNameController,
              validator: validateName,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Last Name'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carNameController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Car Model'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carPlateController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Car Plate'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.grey.shade200)),
            child: InternationalPhoneNumberInput(
              initialValue: PhoneNumber(isoCode: "MY"),
              onInputChanged: (PhoneNumber number) =>
                  _mobileController.text = number.phoneNumber.toString(),
              ignoreBlank: true,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              inputDecoration: InputDecoration(
                hintText: 'Phone Number'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              inputBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmail,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Email Address'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              obscureText: true,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              controller: _passwordController,
              validator: validatePassword,
              style:
                  TextStyle(fontFamily: "GlacialIndifference", fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Password'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: _confirmPasswordController,
              validator: (val) =>
                  validateConfirmPassword(_passwordController.text, val),
              style:
                  TextStyle(fontFamily: "GlacialIndifference", fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Confirm Password'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 20),
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Expanded(
        //           child: Column(
        //         children: [
        //           Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Text(
        //               "Pickup Car proof",
        //               style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //             ),
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.all(10.0),
        //             child: Stack(
        //               alignment: Alignment.bottomCenter,
        //               children: <Widget>[
        //                 SizedBox(
        //                   width: 90,
        //                   height: 90,
        //                   child: _carProofPictureFile == null
        //                       ? Image.network(
        //                           placeholderImage,
        //                           fit: BoxFit.cover,
        //                         )
        //                       : Image.file(
        //                           _carProofPictureFile!,
        //                           fit: BoxFit.cover,
        //                         ),
        //                 ),
        //                 Positioned(
        //                   left: 55,
        //                   right: 0,
        //                   child: FloatingActionButton(
        //                     heroTag: 'profileImage',
        //                     backgroundColor: Color(COLOR_ACCENT),
        //                     child: Icon(
        //                       CupertinoIcons.camera,
        //                       color: isDarkMode(context) ? Colors.black : Colors.white,
        //                     ),
        //                     mini: true,
        //                     onPressed: () => _onPickupCarProofAndDriverProof(false),
        //                   ),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ],
        //       )),
        //       Expanded(
        //           child: Column(
        //         children: [
        //           Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Text(
        //               "Pickup Driver proof",
        //               style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //             ),
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.all(10.0),
        //             child: Stack(
        //               alignment: Alignment.bottomCenter,
        //               children: <Widget>[
        //                 SizedBox(
        //                   width: 90,
        //                   height: 90,
        //                   child: _driverProofPictureURLFile == null
        //                       ? Image.network(
        //                           placeholderImage,
        //                           fit: BoxFit.cover,
        //                         )
        //                       : Image.file(
        //                           _driverProofPictureURLFile!,
        //                           fit: BoxFit.cover,
        //                         ),
        //                 ),
        //                 Positioned(
        //                   left: 55,
        //                   right: 0,
        //                   child: FloatingActionButton(
        //                     heroTag: 'profileImage',
        //                     backgroundColor: Color(COLOR_ACCENT),
        //                     child: Icon(
        //                       CupertinoIcons.camera,
        //                       color: isDarkMode(context) ? Colors.black : Colors.white,
        //                     ),
        //                     mini: true,
        //                     onPressed: () => _onPickupCarProofAndDriverProof(true),
        //                   ),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ],
        //       )),
        //     ],
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(COLOR_PRIMARY),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              child: Text(
                'Sign Up'.tr(),
                style: TextStyle(
                  fontFamily: "GlacialIndifference",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
      ],
    );
  }

  Widget formCabServiceUI() {
    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _firstNameController,
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validateName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: easyLocal.tr('First Name'),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _lastNameController,
              validator: validateName,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Last Name'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // Row(
        //   children: [
        //     Expanded(
        //       child: Row(
        //         children: [
        //           Radio(
        //             value: "individual",
        //             groupValue: companyOrNot,
        //             onChanged: (value) {
        //               setState(() {
        //                 companyOrNot = value.toString();
        //               });
        //             },
        //           ),
        //           Text("As an Individual").tr()
        //         ],
        //       ),
        //     ),
        // Expanded(
        //   child: Row(
        //     children: [
        //       Radio(
        //         value: "company",
        //         groupValue: companyOrNot,
        //         onChanged: (value) {
        //           setState(() {
        //             companyOrNot = value.toString();
        //           });
        //         },
        //       ),
        //       Text("As a Company").tr()
        //     ],
        //   ),
        // ),
        //   ],
        // ),
        // companyOrNot == "company"
        //     ? Column(
        //         children: [
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _companyNameController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Company Name'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).errorColor),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).errorColor),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _companyAddressController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 maxLines: 5,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Company address'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).errorColor),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).errorColor),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       )
        //     : Container(),
        //  companyOrNot == "individual" ?
        Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: DropdownButtonFormField<SectionModel>(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      fillColor: Colors.white,
                      hintText: 'Select Section'.tr(),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 2.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'field required' : null,
                    value: selectedSection,
                    onChanged: (value) async {
                      setState(() {
                        selectedSection = value;
                      });

                      if (selectedSection != null) {
                        await FireStoreUtils.getVehicleType(selectedSection!)
                            .then((value) {
                          setState(() {
                            vehicleType = value;
                          });
                        });
                      } else {}
                    },
                    hint: Text('Select Section'.tr()),
                    items: sectionsVal!.map((SectionModel item) {
                      return DropdownMenuItem<SectionModel>(
                        child: Text(item.name.toString()),
                        value: item,
                      );
                    }).toList()),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: DropdownButtonFormField<VehicleType>(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      fillColor: Colors.white,
                      hintText: 'Select vehicle type'.tr(),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 2.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'field required' : null,
                    value: selectedVehicleType,
                    onChanged: (value) async {
                      setState(() {
                        selectedVehicleType = value;
                      });
                    },
                    hint: Text('Select vehicle type'.tr()),
                    items: vehicleType.map((VehicleType item) {
                      return DropdownMenuItem<VehicleType>(
                        child: Text(item.name.toString()),
                        value: item,
                      );
                    }).toList()),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: DropdownButtonFormField<CarMakes>(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 2.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'field required'.tr() : null,
                    value: selectedCarMakes,
                    onChanged: (value) async {
                      carModelList.clear();
                      selectedCarModel = null;
                      setState(() {
                        selectedCarMakes = value;
                      });
                      await FireStoreUtils.getCarModel(
                              context, selectedCarMakes!.name.toString())
                          .then((value) {
                        setState(() {
                          carModelList = value;
                        });
                      });
                    },
                    hint: Text('Select Car Makes'.tr()),
                    items: carMakesList.map((CarMakes item) {
                      return DropdownMenuItem<CarMakes>(
                        child: Text(item.name.toString()),
                        value: item,
                      );
                    }).toList()),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: DropdownButtonFormField<CarModel>(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 2.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'field required'.tr() : null,
                    value: selectedCarModel,
                    onChanged: (value) {
                      setState(() {
                        selectedCarModel = value;
                      });
                    },
                    hint: Text('Select Car Model'.tr()),
                    items: carModelList.map((CarModel item) {
                      return DropdownMenuItem<CarModel>(
                        child: Text(item.name.toString()),
                        value: item,
                      );
                    }).toList()),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                  controller: _carPlateController,
                  validator: validateEmptyField,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Color(COLOR_PRIMARY),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    fillColor: Colors.white,
                    hintText: 'Car Plate'.tr(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Color(COLOR_PRIMARY), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                  controller: _carColorController,
                  validator: validateEmptyField,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Color(COLOR_PRIMARY),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    fillColor: Colors.white,
                    hintText: 'Car Color'.tr(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Color(COLOR_PRIMARY), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        //  : Container(),
        Padding(
          padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.grey.shade200)),
            child: InternationalPhoneNumberInput(
              initialValue: PhoneNumber(isoCode: "MY"),
              onInputChanged: (PhoneNumber number) =>
                  _mobileController.text = number.phoneNumber.toString(),
              ignoreBlank: true,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              inputDecoration: InputDecoration(
                hintText: 'Phone Number'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              inputBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              selectorConfig:
                  SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmail,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Email Address'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              obscureText: true,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              controller: _passwordController,
              validator: validatePassword,
              style:
                  TextStyle(fontFamily: "GlacialIndifference", fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Password'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: _confirmPasswordController,
              validator: (val) =>
                  validateConfirmPassword(_passwordController.text, val),
              style:
                  TextStyle(fontFamily: "GlacialIndifference", fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Confirm Password'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // companyOrNot == "individual"
        //     ? Padding(
        //         padding: const EdgeInsets.only(top: 20),
        //         child: Row(
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Expanded(
        //                 child: Column(
        //               children: [
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     "Pickup Car proof",
        //                     style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //                   ),
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.all(10.0),
        //                   child: Stack(
        //                     alignment: Alignment.bottomCenter,
        //                     children: <Widget>[
        //                       SizedBox(
        //                         width: 90,
        //                         height: 90,
        //                         child: _carProofPictureFile == null
        //                             ? Image.network(
        //                                 placeholderImage,
        //                                 fit: BoxFit.cover,
        //                               )
        //                             : Image.file(
        //                                 _carProofPictureFile!,
        //                                 fit: BoxFit.cover,
        //                               ),
        //                       ),
        //                       Positioned(
        //                         left: 55,
        //                         right: 0,
        //                         child: FloatingActionButton(
        //                           heroTag: 'profileImage',
        //                           backgroundColor: Color(COLOR_ACCENT),
        //                           child: Icon(
        //                             CupertinoIcons.camera,
        //                             color: isDarkMode(context) ? Colors.black : Colors.white,
        //                           ),
        //                           mini: true,
        //                           onPressed: () => _onPickupCarProofAndDriverProof(false),
        //                         ),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             )),
        //             Expanded(
        //                 child: Column(
        //               children: [
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     "Pickup Driver proof",
        //                     style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //                   ),
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.all(10.0),
        //                   child: Stack(
        //                     alignment: Alignment.bottomCenter,
        //                     children: <Widget>[
        //                       SizedBox(
        //                         width: 90,
        //                         height: 90,
        //                         child: _driverProofPictureURLFile == null
        //                             ? Image.network(
        //                                 placeholderImage,
        //                                 fit: BoxFit.cover,
        //                               )
        //                             : Image.file(
        //                                 _driverProofPictureURLFile!,
        //                                 fit: BoxFit.cover,
        //                               ),
        //                       ),
        //                       Positioned(
        //                         left: 55,
        //                         right: 0,
        //                         child: FloatingActionButton(
        //                           heroTag: 'profileImage',
        //                           backgroundColor: Color(COLOR_ACCENT),
        //                           child: Icon(
        //                             CupertinoIcons.camera,
        //                             color: isDarkMode(context) ? Colors.black : Colors.white,
        //                           ),
        //                           mini: true,
        //                           onPressed: () => _onPickupCarProofAndDriverProof(true),
        //                         ),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             )),
        //           ],
        //         ),
        //       )
        //     : Container(),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(COLOR_PRIMARY),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              child: Text(
                'Sign Up'.tr(),
                style: TextStyle(
                  fontFamily: "GlacialIndifference",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
      ],
    );
  }

  Widget formParcelServiceUI() {
    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _firstNameController,
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validateName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: easyLocal.tr('First Name'),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _lastNameController,
              validator: validateName,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Last Name'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carNameController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Car Model'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carPlateController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Car Plate'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.grey.shade200)),
            child: InternationalPhoneNumberInput(
              initialValue: PhoneNumber(isoCode: "MY"),
              onInputChanged: (PhoneNumber number) =>
                  _mobileController.text = number.phoneNumber.toString(),
              ignoreBlank: true,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              inputDecoration: InputDecoration(
                hintText: 'Phone Number'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              inputBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              selectorConfig:
                  SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmail,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Email Address'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              obscureText: true,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              controller: _passwordController,
              validator: validatePassword,
              style:
                  TextStyle(fontFamily: "GlacialIndifference", fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Password'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: _confirmPasswordController,
              validator: (val) =>
                  validateConfirmPassword(_passwordController.text, val),
              style:
                  TextStyle(fontFamily: "GlacialIndifference", fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Confirm Password'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 20),
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Expanded(
        //           child: Column(
        //         children: [
        //           Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Text(
        //               "Pickup Car proof",
        //               style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //             ),
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.all(10.0),
        //             child: Stack(
        //               alignment: Alignment.bottomCenter,
        //               children: <Widget>[
        //                 SizedBox(
        //                   width: 90,
        //                   height: 90,
        //                   child: _carProofPictureFile == null
        //                       ? Image.network(
        //                           placeholderImage,
        //                           fit: BoxFit.cover,
        //                         )
        //                       : Image.file(
        //                           _carProofPictureFile!,
        //                           fit: BoxFit.cover,
        //                         ),
        //                 ),
        //                 Positioned(
        //                   left: 55,
        //                   right: 0,
        //                   child: FloatingActionButton(
        //                     heroTag: 'profileImage',
        //                     backgroundColor: Color(COLOR_ACCENT),
        //                     child: Icon(
        //                       CupertinoIcons.camera,
        //                       color: isDarkMode(context) ? Colors.black : Colors.white,
        //                     ),
        //                     mini: true,
        //                     onPressed: () => _onPickupCarProofAndDriverProof(false),
        //                   ),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ],
        //       )),
        //       Expanded(
        //           child: Column(
        //         children: [
        //           Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Text(
        //               "Pickup Driver proof",
        //               style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        //             ),
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.all(10.0),
        //             child: Stack(
        //               alignment: Alignment.bottomCenter,
        //               children: <Widget>[
        //                 SizedBox(
        //                   width: 90,
        //                   height: 90,
        //                   child: _driverProofPictureURLFile == null
        //                       ? Image.network(
        //                           placeholderImage,
        //                           fit: BoxFit.cover,
        //                         )
        //                       : Image.file(
        //                           _driverProofPictureURLFile!,
        //                           fit: BoxFit.cover,
        //                         ),
        //                 ),
        //                 Positioned(
        //                   left: 55,
        //                   right: 0,
        //                   child: FloatingActionButton(
        //                     heroTag: 'profileImage',
        //                     backgroundColor: Color(COLOR_ACCENT),
        //                     child: Icon(
        //                       CupertinoIcons.camera,
        //                       color: isDarkMode(context) ? Colors.black : Colors.white,
        //                     ),
        //                     mini: true,
        //                     onPressed: () => _onPickupCarProofAndDriverProof(true),
        //                   ),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ],
        //       )),
        //     ],
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(COLOR_PRIMARY),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              child: Text(
                'Sign Up'.tr(),
                style: TextStyle(
                  fontFamily: "GlacialIndifference",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
      ],
    );
  }

  String? companyOrNot = "individual";

  Widget formRentalServiceUI() {
    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _firstNameController,
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validateName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: easyLocal.tr('First Name'),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _lastNameController,
              validator: validateName,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Last Name'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // Row(
        //   children: [
        //     Expanded(
        //       child: Row(
        //         children: [
        //           Radio(
        //             value: "individual",
        //             groupValue: companyOrNot,
        //             onChanged: (value) {
        //               setState(() {
        //                 companyOrNot = value.toString();
        //               });
        //             },
        //           ),
        //           Text("As an Individual").tr()
        //         ],
        //       ),
        //     ),
        // Expanded(
        //   child: Row(
        //     children: [
        //       Radio(
        //         value: "company",
        //         groupValue: companyOrNot,
        //         onChanged: (value) {
        //           setState(() {
        //             companyOrNot = value.toString();
        //           });
        //         },
        //       ),
        //       Text("As a Company").tr()
        //     ],
        //   ),
        // ),
        // ],
        //  ),
        // companyOrNot == "company"
        //     ? Column(
        //         children: [
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _companyNameController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Company Name'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).errorColor),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).errorColor),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _companyAddressController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 maxLines: 5,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Company address'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).errorColor),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).errorColor),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   enabledBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.grey.shade200),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       )
        //      :
        Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: DropdownButtonFormField<VehicleType>(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      fillColor: Colors.white,
                      hintText: 'Select vehicle type'.tr(),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                              color: Color(COLOR_PRIMARY), width: 2.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'field required'.tr() : null,
                    value: selectedRentalVehicleType,
                    onChanged: (value) async {
                      setState(() {
                        selectedRentalVehicleType = value;
                      });
                    },
                    hint: Text('Select vehicle type'.tr()),
                    items: rentalVehicleType.map((VehicleType item) {
                      return DropdownMenuItem<VehicleType>(
                        child: Text(item.name.toString()),
                        value: item,
                      );
                    }).toList()),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                  controller: _carNameController,
                  validator: validateEmptyField,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Color(COLOR_PRIMARY),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    fillColor: Colors.white,
                    hintText: 'Car Model'.tr(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Color(COLOR_PRIMARY), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                  controller: _carPlateController,
                  validator: validateEmptyField,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Color(COLOR_PRIMARY),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    fillColor: Colors.white,
                    hintText: 'Car Plate'.tr(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Color(COLOR_PRIMARY), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.grey.shade200)),
            child: InternationalPhoneNumberInput(
              initialValue: PhoneNumber(isoCode: "MY"),
              onInputChanged: (PhoneNumber number) =>
                  _mobileController.text = number.phoneNumber.toString(),
              ignoreBlank: true,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              inputDecoration: InputDecoration(
                hintText: 'Phone Number'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              inputBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              selectorConfig:
                  SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmail,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Email Address'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              obscureText: true,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              controller: _passwordController,
              validator: validatePassword,
              style:
                  TextStyle(fontFamily: "GlacialIndifference", fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Password'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: _confirmPasswordController,
              validator: (val) =>
                  validateConfirmPassword(_passwordController.text, val),
              style:
                  TextStyle(fontFamily: "GlacialIndifference", fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Confirm Password'.tr(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(COLOR_PRIMARY),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              child: Text(
                'Sign Up'.tr(),
                style: TextStyle(
                  fontFamily: "GlacialIndifference",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
      ],
    );
  }

  /// if the fields are validated and location is enabled we create a new user
  /// and navigate to [ContainerScreen] else we show error
  _signUp() async {
    print("---->1$_selectedServiceType");
    if (_selectedServiceType == "Delivery service") {
      if (_deliveryKey.currentState?.validate() ?? false) {
        _deliveryKey.currentState!.save();
        await _signUpWithEmailAndPasswordInDeliveryService();
      } else {
        setState(() {
          _validate = AutovalidateMode.onUserInteraction;
        });
      }
    } else if (_selectedServiceType == "Parcel service") {
      print("---->1");
      if (_parcelServiceKey.currentState?.validate() ?? false) {
        _parcelServiceKey.currentState!.save();
        await _signUpWithEmailAndPasswordInParcelService();
      } else {
        print("---->2");
        setState(() {
          _validate = AutovalidateMode.onUserInteraction;
        });
      }
    } else if (_selectedServiceType == "Rental Service") {
      if (_rentalServiceKey.currentState?.validate() ?? false) {
        _rentalServiceKey.currentState!.save();
        await _signUpWithEmailAndPasswordInRentalService();
      } else {
        setState(() {
          _validate = AutovalidateMode.onUserInteraction;
        });
      }
    } else {
      if (_cabServiceKey.currentState?.validate() ?? false) {
        _cabServiceKey.currentState!.save();
        await _signUpWithEmailAndPasswordInCabService();
      } else {
        setState(() {
          _validate = AutovalidateMode.onUserInteraction;
        });
      }
    }
  }

  _signUpWithEmailAndPasswordInDeliveryService() async {
    await showProgress(
        context, 'Creating new account, Please wait...'.tr(), false);
    dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _image,
        _carImage,
        _passportImage,
        _licenceImage,
        _diskImage,
        _insuranceImage,
        _driverProofPictureURLFile,
        _carProofPictureFile,
        _carNameController.text,
        _carPlateController.text,
        _firstNameController.text,
        _lastNameController.text,
        _mobileController.text,
        "delivery-service");
    await hideProgress();
    if (result != null && result is User) {
      MyAppState.currentUser = result;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else if (result != null && result is String) {
      showAlertDialog(context, 'Failed'.tr(), result, true);
    } else {
      showAlertDialog(context, 'Failed'.tr(), "Couldn't sign up".tr(), true);
    }
  }

  _signUpWithEmailAndPasswordInRentalService() async {
    await showProgress(
        context, 'Creating new account, Please wait...'.tr(), false);
    dynamic result =
        await FireStoreUtils.firebaseSignUpWithEmailAndPasswordRentalService(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _image,
            _carImage,
            _passportImage,
            _licenceImage,
            _diskImage,
            _insuranceImage,
            _driverProofPictureURLFile,
            _carProofPictureFile,
            _carNameController.text,
            _carPlateController.text,
            _firstNameController.text,
            _lastNameController.text,
            _mobileController.text,
            "rental-service",
            companyOrNot == "company"
                ? ""
                : selectedRentalVehicleType!.name.toString(),
            companyOrNot.toString(),
            _companyNameController.text,
            _companyAddressController.text);

    print(result);
    await hideProgress();
    if (result != null && result is User) {
      MyAppState.currentUser = result;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else if (result != null && result is String) {
      showAlertDialog(context, 'Failed'.tr(), result, true);
    } else {
      showAlertDialog(context, 'Failed'.tr(), "Couldn't sign up".tr(), true);
    }
  }

  _signUpWithEmailAndPasswordInParcelService() async {
    await showProgress(
        context, 'Creating new account, Please wait...'.tr(), false);
    dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _image,
        _carImage,
        _passportImage,
        _licenceImage,
        _diskImage,
        _insuranceImage,
        _driverProofPictureURLFile,
        _carProofPictureFile,
        _carNameController.text,
        _carPlateController.text,
        _firstNameController.text,
        _lastNameController.text,
        _mobileController.text,
        "parcel_delivery");
    await hideProgress();
    if (result != null && result is User) {
      MyAppState.currentUser = result;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else if (result != null && result is String) {
      showAlertDialog(context, 'Failed'.tr(), result, true);
    } else {
      showAlertDialog(context, 'Failed'.tr(), "Couldn't sign up".tr(), true);
    }
  }

  _signUpWithEmailAndPasswordInCabService() async {
    await showProgress(
        context, 'Creating new account, Please wait...'.tr(), false);
    dynamic result =
        await FireStoreUtils.firebaseSignUpWithEmailAndPasswordCabService(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _image,
            _carImage,
            _passportImage,
            _licenceImage,
            _diskImage,
            _insuranceImage,
            _driverProofPictureURLFile,
            _carProofPictureFile,
            selectedVehicleType != null
                ? selectedVehicleType!.name.toString()
                : "",
            selectedCarMakes != null ? selectedCarMakes!.name.toString() : "",
            selectedCarModel != null ? selectedCarModel!.name.toString() : "",
            _carPlateController.text,
            _carColorController.text,
            _firstNameController.text,
            _lastNameController.text,
            _mobileController.text,
            "cab-service",
            companyOrNot.toString(),
            _companyNameController.text,
            _companyAddressController.text,
            selectedSection != null ? selectedSection!.id.toString() : "",
            selectedVehicleType != null
                ? selectedVehicleType!.id.toString()
                : "");
    await hideProgress();
    if (result != null && result is User) {
      MyAppState.currentUser = result;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else if (result != null && result is String) {
      showAlertDialog(context, 'Failed'.tr(), result, true);
    } else {
      showAlertDialog(context, 'Failed'.tr(), "Couldn't sign up".tr(), true);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _image = null;
    _carImage = null;
    _passportImage = null;
    _licenceImage = null;
    _diskImage = null;
    _insuranceImage = null;
    super.dispose();
  }
}
