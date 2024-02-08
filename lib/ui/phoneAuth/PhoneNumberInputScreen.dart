import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:easy_localization/easy_localization.dart' as Easy;
import 'package:nocdriver/CabService/dashboard_cab_service.dart';
import 'package:nocdriver/Parcel_service/parcel_service_dashboard.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/CarMakes.dart';
import 'package:nocdriver/model/CarModel.dart';
import 'package:nocdriver/model/SectionModel.dart';
import 'package:nocdriver/model/VehicleType.dart';
import 'package:nocdriver/rental_service/rental_service_dashboard.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:nocdriver/ui/auth/AuthScreen.dart';
import 'package:nocdriver/ui/container/ContainerScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../model/User.dart';

File? _image;
File? _carImage;
File? _passportImage;
File? _licenceImage;
File? _diskImage;
File? _insuranceImage;

class PhoneNumberInputScreen extends StatefulWidget {
  final bool login;

  const PhoneNumberInputScreen({Key? key, required this.login})
      : super(key: key);

  @override
  _PhoneNumberInputScreenState createState() => _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState extends State<PhoneNumberInputScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _carNameController = TextEditingController();
  TextEditingController _carPlateController = TextEditingController();
  TextEditingController _carColorController = TextEditingController();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  GlobalKey<FormState> _deliveryKey = GlobalKey();
  GlobalKey<FormState> _cabServiceKey = GlobalKey();
  GlobalKey<FormState> _parcelServiceKey = GlobalKey();
  GlobalKey<FormState> _rentalServiceKey = GlobalKey();
  bool isUserImage = true;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  // TextEditingController _companyNameController = TextEditingController();
  // TextEditingController _companyAddressController = TextEditingController();

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
  List<VehicleType> vehicleType = [];
  CarMakes? selectedCarMakes;
  CarModel? selectedCarModel;
  VehicleType? selectedVehicleType;

  List<VehicleType> rentalVehicleType = [];
  VehicleType? selectedRentalVehicleType;

  List<SectionModel>? sectionsVal = [];
  SectionModel? selectedSection;

  getCarMakes() async {
    await FireStoreUtils.getCarMakes().then((value) {
      setState(() {
        carMakesList = value;
      });
    });

    // await FireStoreUtils.getVehicleType().then((value) {
    //   setState(() {
    //     vehicleType = value;
    //   });
    // });

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
                    widget.login ? 'Sign In'.tr() : 'Create new account'.tr(),
                    style: TextStyle(fontFamily: "GlacialIndifference",
                        color: Color(COLOR_PRIMARY),
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0),
                  ).tr()),
              !_codeSent && widget.login
                  ? Column(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                shape: BoxShape.rectangle,
                                border:
                                    Border.all(color: Colors.grey.shade200)),
                            child: InternationalPhoneNumberInput(
                              initialValue: PhoneNumber(isoCode: "MY"),
                              onInputChanged: (PhoneNumber number) =>
                                  _mobileController.text =
                                      number.phoneNumber.toString(),
                              ignoreBlank: true,
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                  selectorType: PhoneInputSelectorType.DIALOG),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 40.0, left: 40.0, top: 40.0),
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(minWidth: double.infinity),
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
                                widget.login ? 'Login'.tr() : 'Sign Up'.tr(),
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode(context)
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              onPressed: () => _signUp(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              _codeSent
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: PinCodeTextField(
                        length: 6,
                        appContext: context,
                        keyboardType: TextInputType.phone,
                        backgroundColor: Colors.transparent,
                        pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 40,
                            fieldWidth: 40,
                            activeColor: Color(COLOR_PRIMARY),
                            activeFillColor: isDarkMode(context)
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                            selectedFillColor: Colors.transparent,
                            selectedColor: Color(COLOR_PRIMARY),
                            inactiveColor: Colors.grey.shade600,
                            inactiveFillColor: Colors.transparent),
                        enableActiveFill: true,
                        onCompleted: (v) {
                          _submitCode(v);
                        },
                        onChanged: (value) {
                          print(value);
                        },
                      ),
                    )
                  : Container(),
              Visibility(
                visible: !widget.login && !_codeSent,
                child: Column(
                  children: [
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
                                          color: isDarkMode(context) ? Colors.black : Colors.white,
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
                                          color: isDarkMode(context) ? Colors.black : Colors.white,
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
                                          color: isDarkMode(context) ? Colors.black : Colors.white,
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
                                          color: isDarkMode(context) ? Colors.black : Colors.white,
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
                                          color: isDarkMode(context) ? Colors.black : Colors.white,
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
                                          color: isDarkMode(context) ? Colors.black : Colors.white,
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
                      padding: const EdgeInsets.only(
                          top: 16.0, right: 8.0, left: 8.0),
                      child: DropdownButtonFormField(
                        hint: Text('Please choose a service type.'.tr()),
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
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _submitCode(String code) async {
    await showProgress(
        context,
        widget.login
            ? 'Login, Please Wait....'
            : 'Creating new account, Please wait...'.tr(),
        false);

    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(
        verificationId: _verificationID, smsCode: code);

    try {
      // Sign the user in (or link) with the credential
      auth.UserCredential userCredential =
          await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
      User? user =
          await FireStoreUtils.getCurrentUser(userCredential.user?.uid ?? '');
      if (user == null) {
        hideProgress();
        if (_selectedServiceType == "Delivery service") {
          _deliveryService(userCredential.user!.uid);
        } else if (_selectedServiceType == "Parcel service") {
          _parcelService(userCredential.user!.uid);
        } else if (_selectedServiceType == "Rental Service") {
          _rentalService(userCredential.user!.uid);
        } else {
          _cabService(userCredential.user!.uid);
        }
      } else {
        hideProgress();
        if (user.active) {
          await FireStoreUtils.updateCurrentUser(user);
          MyAppState.currentUser = user;
          if (user.serviceType == "cab-service") {
            pushAndRemoveUntil(
                context,
                DashBoardCabService(
                  user: user,
                ),
                false);
          } else if (user.serviceType == "parcel_delivery") {
            pushAndRemoveUntil(
                context, ParcelServiceDashBoard(user: user), false);
          } else if (user.serviceType == "rental-service") {
            pushAndRemoveUntil(
                context, RentalServiceDashBoard(user: user), false);
          } else {
            pushAndRemoveUntil(context, ContainerScreen(user: user), false);
          }
        } else {
          hideProgress();
          showAlertDialog(
              context,
              "Couldn't Log In".tr(),
              'Driver is not activated yet. Please contact to admin to activate it. Thanks.'
                  .tr(),
              true);
        }
      }
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        showAlertDialog(context, 'Failed'.tr(), 'Otp Invalid', true);
      }
    } catch (e) {
      showAlertDialog(context, 'Failed'.tr(), e.toString(), true);
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




  _onCameraClick(bool isUserImage) {
    isUserImage = isUserImage;
    final action = CupertinoActionSheet(
      message: Text(
        isUserImage ? 'Add profile picture'.tr() : 'Add Car Image'.tr(),
        style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 15.0),
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
        style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                isUserImage ? _passportImage = File(image.path) : _licenceImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                isUserImage ? _passportImage = File(image.path) : _licenceImage = File(image.path);
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
        style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                isUserImage ? _diskImage = File(image.path) : _insuranceImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                isUserImage ? _diskImage = File(image.path) : _passportImage = File(image.path);
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
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
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'OR',
              style: TextStyle(fontFamily: "GlacialIndifference",
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ).tr(),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            widget.login
                ? 'Login with E-mail'.tr()
                : 'Sign up with E-mail'.tr(),
            style: TextStyle(fontFamily: "GlacialIndifference",
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1),
          ),
        )
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
        //     Expanded(
        //       child: Row(
        //         children: [
        //           Radio(
        //             value: "company",
        //             groupValue: companyOrNot,
        //             onChanged: (value) {
        //               setState(() {
        //                 companyOrNot = value.toString();
        //               });
        //             },
        //           ),
        //           Text("As a Company").tr()
        //         ],
        //       ),
        //     ),
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
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
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
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
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
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<SectionModel>(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Select Section'.tr(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) => value == null ? 'field required' : null,
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
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<VehicleType>(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Select vehicle type'.tr(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) =>
                    value == null ? 'field required'.tr() : null,
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
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<CarMakes>(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
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
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DropdownButtonFormField<CarModel>(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
        // companyOrNot == "company"
        //     ? Container()
        //     : Padding(
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
        //                     "Pickup Car proof".tr(),
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
        //       ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
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
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'OR',
              style: TextStyle(fontFamily: "GlacialIndifference",
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ).tr(),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            widget.login
                ? 'Login with E-mail'.tr()
                : 'Sign up with E-mail'.tr(),
            style: TextStyle(fontFamily: "GlacialIndifference",
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1),
          ),
        )
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
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
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'OR',
              style: TextStyle(fontFamily: "GlacialIndifference",
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ).tr(),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            widget.login
                ? 'Login with E-mail'.tr()
                : 'Sign up with E-mail'.tr(),
            style: TextStyle(fontFamily: "GlacialIndifference",
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1),
          ),
        )
      ],
    );
  }

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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
        //     Expanded(
        //       child: Row(
        //         children: [
        //           Radio(
        //             value: "company",
        //             groupValue: companyOrNot,
        //             onChanged: (value) {
        //               setState(() {
        //                 companyOrNot = value.toString();
        //               });
        //             },
        //           ),
        //           Text("As a Company").tr()
        //         ],
        //       ),
        //     ),
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
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
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
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
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
        //     : Column(
        //         children: [
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: DropdownButtonFormField<VehicleType>(
        //                   decoration: InputDecoration(
        //                     contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                     fillColor: Colors.white,
        //                     hintText: 'Select vehicle type'.tr(),
        //                     focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                     errorBorder: OutlineInputBorder(
        //                       borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                       borderRadius: BorderRadius.circular(25.0),
        //                     ),
        //                     focusedErrorBorder: OutlineInputBorder(
        //                       borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                       borderRadius: BorderRadius.circular(25.0),
        //                     ),
        //                     enabledBorder: OutlineInputBorder(
        //                       borderSide: BorderSide(color: Colors.grey.shade200),
        //                       borderRadius: BorderRadius.circular(25.0),
        //                     ),
        //                   ),
        //                   validator: (value) => value == null ? 'field required' : null,
        //                   value: selectedRentalVehicleType,
        //                   onChanged: (value) async {
        //                     setState(() {
        //                       selectedRentalVehicleType = value;
        //                     });
        //                   },
        //                   hint: Text('Select vehicle type'.tr()),
        //                   items: rentalVehicleType.map((VehicleType item) {
        //                     return DropdownMenuItem<VehicleType>(
        //                       child: Text(item.name.toString()),
        //                       value: item,
        //                     );
        //                   }).toList()),
        //             ),
        //           ),
        //           ConstrainedBox(
        //             constraints: BoxConstraints(minWidth: double.infinity),
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //               child: TextFormField(
        //                 controller: _carNameController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Car Model'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
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
        //                 controller: _carPlateController,
        //                 validator: validateEmptyField,
        //                 textAlignVertical: TextAlignVertical.center,
        //                 cursorColor: Color(COLOR_PRIMARY),
        //                 textInputAction: TextInputAction.next,
        //                 decoration: InputDecoration(
        //                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //                   fillColor: Colors.white,
        //                   hintText: 'Car Plate'.tr(),
        //                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //                   errorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        //                     borderRadius: BorderRadius.circular(25.0),
        //                   ),
        //                   focusedErrorBorder: OutlineInputBorder(
        //                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
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
        //       ),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
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
        // companyOrNot == "company"
        //     ? Container()
        //     : Padding(
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
        //                     "Pickup Car proof".tr(),
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
        //       ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
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
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'OR',
              style: TextStyle(fontFamily: "GlacialIndifference",
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ).tr(),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            widget.login
                ? 'Login with E-mail'.tr()
                : 'Sign up with E-mail'.tr(),
            style: TextStyle(fontFamily: "GlacialIndifference",
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1),
          ),
        )
      ],
    );
  }

  /// if the fields are validated and location is enabled we create a new user
  /// and navigate to [ContainerScreen] else we show error
  _signUp() async {
    if (widget.login) {
      await _submitPhoneNumber();
    } else {
      if (_selectedServiceType == "Delivery service") {
        if (_deliveryKey.currentState?.validate() ?? false) {
          _deliveryKey.currentState!.save();
          await _submitPhoneNumber();
        } else {
          setState(() {
            _validate = AutovalidateMode.onUserInteraction;
          });
        }
      } else if (_selectedServiceType == "Parcel service") {
        if (_parcelServiceKey.currentState?.validate() ?? false) {
          _parcelServiceKey.currentState!.save();
          await _submitPhoneNumber();
        } else {
          setState(() {
            _validate = AutovalidateMode.onUserInteraction;
          });
        }
      } else if (_selectedServiceType == "Rental Service") {
        if (_rentalServiceKey.currentState?.validate() ?? false) {
          _rentalServiceKey.currentState!.save();
          await _submitPhoneNumber();
        } else {
          setState(() {
            _validate = AutovalidateMode.onUserInteraction;
          });
        }
      } else {
        if (_cabServiceKey.currentState?.validate() ?? false) {
          _cabServiceKey.currentState!.save();
          await _submitPhoneNumber();
        } else {
          setState(() {
            _validate = AutovalidateMode.onUserInteraction;
          });
        }
      }
    }
  }

  _deliveryService(String uid) async {
    String profilePicUrl = '';
    String carPicUrl = DEFAULT_CAR_IMAGE;
    String passportUrl = '';
    String licenceUrl = '';
    String diskUrl = '';
    String InsuranceUrl = '';
    String driverProofUrl = '';
    String carProofUrl = '';
    if (_image != null) {
      updateProgress('Uploading image, Please wait...'.tr());
      profilePicUrl =
          await FireStoreUtils.uploadUserImageToFireStorage(_image!, uid);
    }
    if (_carImage != null) {
      updateProgress('Uploading car image, Please wait...'.tr());
      carPicUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, uid);
    }
    if (_passportImage != null) {
      updateProgress('Uploading passport image, Please wait...'.tr());
      passportUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_passportImage!, uid);
    }
    if (_licenceImage != null) {
      updateProgress('Uploading Licence image, Please wait...'.tr());
      licenceUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_licenceImage!, uid);
    }
    if (_diskImage != null) {
      updateProgress('Uploading diskUrl image, Please wait...'.tr());
      diskUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_diskImage!, uid);
    }
    if (_insuranceImage != null) {
      updateProgress('Uploading insurance image, Please wait...'.tr());
      InsuranceUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_insuranceImage!, uid);
    }


    User user = User(
      email: _emailController.text,
      settings: UserSettings(),
      lastOnlineTimestamp: Timestamp.now(),
      isActive: false,
      active: false,
      phoneNumber: _mobileController.text,
      firstName: _firstNameController.text,
      userID: uid,
      lastName: _lastNameController.text,
      fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
      profilePictureURL: profilePicUrl,
      carPictureURL: carPicUrl,
      diskUrl: diskUrl,
      passportUrl: passportUrl,
      insuranceUrl: InsuranceUrl,
      licenceUrl: licenceUrl,
      carNumber: _carNameController.text,
      carName: _carNameController.text,
      role: USER_ROLE_DRIVER,
      carProofPictureURL: carProofUrl,
      driverProofPictureURL: driverProofUrl,
      serviceType: "delivery-service",
      createdAt: Timestamp.now(),
    );
    String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
    await hideProgress();

    if (errorMessage == null) {
      MyAppState.currentUser = user;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else {
      return "Couldn't sign up for firebase, Please try again.".tr();
    }
  }

  _parcelService(String uid) async {
    String profilePicUrl = '';
    String carPicUrl = DEFAULT_CAR_IMAGE;
    String passportUrl = '';
    String licenceUrl = '';
    String diskUrl = '';
    String InsuranceUrl = '';
    String driverProofUrl = '';
    String carProofUrl = '';
    print("ABABAB");
    if (_image != null) {
      updateProgress('Uploading image, Please wait...'.tr());
      profilePicUrl =
          await FireStoreUtils.uploadUserImageToFireStorage(_image!, uid);
    }
    if (_carImage != null) {
      updateProgress('Uploading car image, Please wait...'.tr());
      carPicUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, uid);
    }
    if (_passportImage != null) {
      updateProgress('Uploading passport image, Please wait...'.tr());
      passportUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_passportImage!, uid);
    }
    if (_licenceImage != null) {
      updateProgress('Uploading Licence image, Please wait...'.tr());
      licenceUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_licenceImage!, uid);
    }
    if (_diskImage != null) {
      updateProgress('Uploading diskUrl image, Please wait...'.tr());
      diskUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_diskImage!, uid);
    }
    if (_insuranceImage != null) {
      updateProgress('Uploading insurance image, Please wait...'.tr());
      InsuranceUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_insuranceImage!, uid);
    }



    User user = User(
        email: _emailController.text,
        settings: UserSettings(),
        lastOnlineTimestamp: Timestamp.now(),
        isActive: false,
        active: false,
        phoneNumber: _mobileController.text,
        firstName: _firstNameController.text,
        userID: uid,
        lastName: _lastNameController.text,
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
        profilePictureURL: profilePicUrl,
        carPictureURL: carPicUrl,
        diskUrl: diskUrl,
        passportUrl: passportUrl,
        insuranceUrl: InsuranceUrl,
        licenceUrl: licenceUrl,
        carNumber: _carNameController.text,
        carName: _carNameController.text,
        role: USER_ROLE_DRIVER,
        carProofPictureURL: carProofUrl,
        driverProofPictureURL: driverProofUrl,
        serviceType: "parcel_delivery",
        createdAt: Timestamp.now());

    print("QWERT");
    print(user.toJson());
    String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
    await hideProgress();

    if (errorMessage == null) {
      MyAppState.currentUser = user;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else {
      return "Couldn't sign up for firebase, Please try again.".tr();
    }
  }

  _rentalService(String uid) async {
    String profilePicUrl = '';
    String carPicUrl = DEFAULT_CAR_IMAGE;
    String passportUrl = '';
    String licenceUrl = '';
    String diskUrl = '';
    String InsuranceUrl = '';
    String driverProofUrl = '';
    String carProofUrl = '';
    if (_image != null) {
      updateProgress('Uploading image, Please wait...'.tr());
      profilePicUrl =
          await FireStoreUtils.uploadUserImageToFireStorage(_image!, uid);
    }
    if (_carImage != null) {
      updateProgress('Uploading car image, Please wait...'.tr());
      carPicUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, uid);
    }
    if (_passportImage != null) {
      updateProgress('Uploading passport image, Please wait...'.tr());
      passportUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_passportImage!, uid);
    }
    if (_licenceImage != null) {
      updateProgress('Uploading Licence image, Please wait...'.tr());
      licenceUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_licenceImage!, uid);
    }
    if (_diskImage != null) {
      updateProgress('Uploading diskUrl image, Please wait...'.tr());
      diskUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_diskImage!, uid);
    }
    if (_insuranceImage != null) {
      updateProgress('Uploading insurance image, Please wait...'.tr());
      InsuranceUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_insuranceImage!, uid);
    }

    User user = User(
        email: _emailController.text,
        settings: UserSettings(),
        lastOnlineTimestamp: Timestamp.now(),
        isActive: false,
        active: false,
        phoneNumber: _mobileController.text,
        firstName: _firstNameController.text,
        userID: uid,
        lastName: _lastNameController.text,
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
        profilePictureURL: profilePicUrl,
        carPictureURL: carPicUrl,
        diskUrl: diskUrl,
        passportUrl: passportUrl,
        insuranceUrl: InsuranceUrl,
        licenceUrl: licenceUrl,
        carNumber: _carPlateController.text,
        carName: _carNameController.text,
        role: USER_ROLE_DRIVER,
        carProofPictureURL: carProofUrl,
        driverProofPictureURL: driverProofUrl,
        vehicleType: selectedRentalVehicleType!.name.toString(),
        serviceType: "rental-service",
        createdAt: Timestamp.now());
    String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
    await hideProgress();

    if (errorMessage == null) {
      MyAppState.currentUser = user;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else {
      return "Couldn't sign up for firebase, Please try again.".tr();
    }
  }

  _cabService(String uid) async {
    String profilePicUrl = '';
    String carPicUrl = DEFAULT_CAR_IMAGE;
    String passportUrl = '';
    String licenceUrl = '';
    String diskUrl = '';
    String InsuranceUrl = '';
    String driverProofUrl = '';
    String carProofUrl = '';
    if (_image != null) {
      updateProgress('Uploading image, Please wait...'.tr());
      profilePicUrl =
          await FireStoreUtils.uploadUserImageToFireStorage(_image!, uid);
    }
    if (_carImage != null) {
      updateProgress('Uploading car image, Please wait...'.tr());
      carPicUrl =
          await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, uid);
    }
    if (_passportImage != null) {
      updateProgress('Uploading passport image, Please wait...'.tr());
      passportUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_passportImage!, uid);
    }
    if (_licenceImage != null) {
      updateProgress('Uploading Licence image, Please wait...'.tr());
      licenceUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_licenceImage!, uid);
    }
    if (_diskImage != null) {
      updateProgress('Uploading diskUrl image, Please wait...'.tr());
      diskUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_diskImage!, uid);
    }
    if (_insuranceImage != null) {
      updateProgress('Uploading insurance image, Please wait...'.tr());
      InsuranceUrl =
      await FireStoreUtils.uploadCarImageToFireStorage(_insuranceImage!, uid);
    }


    User user = User(
        email: _emailController.text,
        settings: UserSettings(),
        lastOnlineTimestamp: Timestamp.now(),
        isActive: false,
        active: false,
        phoneNumber: _mobileController.text,
        firstName: _firstNameController.text,
        userID: uid,
        lastName: _lastNameController.text,
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
        profilePictureURL: profilePicUrl,
        carPictureURL: carPicUrl,
        diskUrl: diskUrl,
        passportUrl: passportUrl,
        insuranceUrl: InsuranceUrl,
        licenceUrl: licenceUrl,
        carNumber: _carPlateController.text,
        carName:  selectedCarModel != null ? selectedCarModel!.name.toString() : "",
        carMakes: selectedCarMakes != null ? selectedCarMakes!.name.toString() : "",
        vehicleType: selectedVehicleType != null ? selectedVehicleType!.name.toString() : "",
        serviceType: "cab-service",
        carColor: _carColorController.text,
        carProofPictureURL: carProofUrl,
        driverProofPictureURL: driverProofUrl,
        role: USER_ROLE_DRIVER,
        sectionId: selectedSection!.id,
        rideType: 'ride',
        vehicleId: selectedVehicleType!.id.toString(),
        createdAt: Timestamp.now());
    String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
    await hideProgress();

    if (errorMessage == null) {
      MyAppState.currentUser = user;
      MyAppState.currentUser!.isActive = false;
      MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      await auth.FirebaseAuth.instance.signOut();
      MyAppState.currentUser = null;
      pushAndRemoveUntil(context, AuthScreen(), false);
    } else {
      return "Couldn't sign up for firebase, Please try again.".tr();
    }
  }

  //
  // _signUpWithEmailAndPasswordInRentalService() async {
  //   await showProgress(context, 'Creating new account, Please wait...'.tr(), false);
  //   dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPasswordRentalService(
  //       _emailController.text.trim(),
  //       _passwordController.text.trim(),
  //       _image,
  //       _carImage,
  //       _carNameController.text,
  //       _carPlateController.text,
  //       _firstNameController.text,
  //       _lastNameController.text,
  //       _mobileController.text,
  //       "rental-service",
  //       _companyNameController.text,
  //       _companyAddressController.text);
  //   await hideProgress();
  //   if (result != null && result is User) {
  //     MyAppState.currentUser = result;
  //     MyAppState.currentUser!.isActive = false;
  //     MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
  //     await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
  //     await auth.FirebaseAuth.instance.signOut();
  //     MyAppState.currentUser = null;
  //     pushAndRemoveUntil(context, AuthScreen(), false);
  //   } else if (result != null && result is String) {
  //     showAlertDialog(context, 'Failed'.tr(), result, true);
  //   } else {
  //     showAlertDialog(context, 'Failed'.tr(), 'Couldn\'t sign up'.tr(), true);
  //   }
  // }
  //
  // _signUpWithEmailAndPasswordInParcelService() async {
  //   await showProgress(context, 'Creating new account, Please wait...'.tr(), false);
  //   dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(
  //       _emailController.text.trim(),
  //       _passwordController.text.trim(),
  //       _image,
  //       _carImage,
  //       _carNameController.text,
  //       _carPlateController.text,
  //       _firstNameController.text,
  //       _lastNameController.text,
  //       _mobileController.text,
  //       "parcel_delivery");
  //   await hideProgress();
  //   if (result != null && result is User) {
  //     MyAppState.currentUser = result;
  //     MyAppState.currentUser!.isActive = false;
  //     MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
  //     await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
  //     await auth.FirebaseAuth.instance.signOut();
  //     MyAppState.currentUser = null;
  //     pushAndRemoveUntil(context, AuthScreen(), false);
  //   } else if (result != null && result is String) {
  //     showAlertDialog(context, 'Failed'.tr(), result, true);
  //   } else {
  //     showAlertDialog(context, 'Failed'.tr(), 'Couldn\'t sign up'.tr(), true);
  //   }
  // }
  //
  // _signUpWithEmailAndPasswordInCabService() async {
  //   await showProgress(context, 'Creating new account, Please wait...'.tr(), false);
  //   dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPasswordCabService(
  //     _emailController.text.trim(),
  //     _passwordController.text.trim(),
  //     _image,
  //     _carImage,
  //     selectedVehicleType!.name.toString(),
  //     selectedCarMakes!.name.toString(),
  //     selectedCarModel!.name.toString(),
  //     _carPlateController.text,
  //     _firstNameController.text,
  //     _lastNameController.text,
  //     _mobileController.text,
  //     "cab-service",
  //   );
  //   await hideProgress();
  //   if (result != null && result is User) {
  //     MyAppState.currentUser = result;
  //     MyAppState.currentUser!.isActive = false;
  //     MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
  //     await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
  //     await auth.FirebaseAuth.instance.signOut();
  //     MyAppState.currentUser = null;
  //     pushAndRemoveUntil(context, AuthScreen(), false);
  //   } else if (result != null && result is String) {
  //     showAlertDialog(context, 'Failed'.tr(), result, true);
  //   } else {
  //     showAlertDialog(context, 'Failed'.tr(), 'Couldn\'t sign up'.tr(), true);
  //   }
  // }

  bool _codeSent = false;
  String _verificationID = "";

  _submitPhoneNumber() async {
    //send code
    await showProgress(context, 'Sending code...'.tr(), true);
    await auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _mobileController.text,
      verificationCompleted: (auth.PhoneAuthCredential credential) {},
      verificationFailed: (auth.FirebaseAuthException e) {
        hideProgress();
        String message = "errorOccurredTryAgain".tr();
        switch (e.code) {
          case 'invalid-verification-code':
            message = "Invalid Code Expired".tr();
            break;
          case 'user-disabled':
            message = "User is Disabled".tr();
            break;
          default:
            message = "Error Occurred Try Again".tr();
            break;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            message.tr(),
          ),
        ));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          hideProgress();
          _codeSent = true;
          _verificationID = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void dispose() {
    _image = null;
    _carImage = null;
    _passportImage = null;
    _licenceImage = null;
    _diskImage = null;
    _insuranceImage = null;
    super.dispose();
  }
}
