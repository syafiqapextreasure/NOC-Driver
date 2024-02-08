// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:nocdriver/constants.dart';
// import 'package:nocdriver/main.dart';
// import 'package:nocdriver/model/SectionModel.dart';
// import 'package:nocdriver/model/User.dart';
// import 'package:nocdriver/model/VehicleType.dart';
// import 'package:nocdriver/services/FirebaseHelper.dart';
// import 'package:nocdriver/services/helper.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
//
// class AddCabDriverScreen extends StatefulWidget {
//   User? driverDetails;
//   bool? isDashBoard;
//
//   AddCabDriverScreen({Key? key, required this.driverDetails, this.isDashBoard}) : super(key: key);
//
//   @override
//   State<AddCabDriverScreen> createState() => _AddCabDriverScreenState();
// }
//
// class _AddCabDriverScreenState extends State<AddCabDriverScreen> {
//   TextEditingController _firstNameController = TextEditingController();
//   TextEditingController _lastNameController = TextEditingController();
//   TextEditingController _carPlateController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _mobileController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//
//   GlobalKey<FormState> _key = GlobalKey();
//
//   List<VehicleType> vehicleTypeList = [];
//   VehicleType? selectedVehicleType;
//
//   @override
//   void initState() {
//     getDriver();
//     super.initState();
//   } // Option 2
//
//   List<String> carMakesList = [];
//   List<String> carModelList = [];
//
//   String? selectedCarMakes;
//   String? selectedCarModel;
//   String profilePicUrl = '';
//   String carPicUrl = '';
//
//   List<SectionModel>? sectionsVal = [];
//   SectionModel? selectedSection;
//
//
//   getDriver()  async {
//     await FireStoreUtils.getSections().then((value) {
//       setState(() {
//         sectionsVal = value;
//       });
//     });
//
//     await FireStoreUtils.getCarMakes().then((value) {
//       value.forEach((element) {
//         if (!carMakesList.contains(element.name.toString())) {
//           setState(() {
//             carMakesList.add(element.name.toString());
//           });
//         }
//       });
//     });
//
//     if (widget.driverDetails != null) {
//       _firstNameController.text = widget.driverDetails!.firstName;
//       _lastNameController.text = widget.driverDetails!.lastName;
//       _emailController.text = widget.driverDetails!.email;
//       _mobileController.text = widget.driverDetails!.phoneNumber;
//       selectedCarMakes = widget.driverDetails!.carMakes;
//       selectedCarModel = widget.driverDetails!.carName;
//       _carPlateController.text = widget.driverDetails!.carNumber;
//       profilePicUrl = widget.driverDetails!.profilePictureURL;
//       carPicUrl = widget.driverDetails!.carPictureURL;
//
//       sectionsVal!.forEach((element) async {
//         if (element.id == widget.driverDetails!.sectionId) {
//           setState(() {
//             selectedSection = element;
//           });
//         }
//       });
//
//
//       await FireStoreUtils.getCarModel(context, selectedCarMakes!.toString()).then((value) {
//         value.forEach((element) {
//           if (!carModelList.contains(element.name.toString())) {
//             setState(() {
//               carModelList.add(element.name.toString());
//             });
//           }
//         });
//       });
//
//       await FireStoreUtils.getVehicleType(selectedSection).then((value) {
//         setState(() {
//           vehicleTypeList  = value;
//         });
//       });
//
//       for(int i = 0;i<vehicleTypeList.length ; i++){
//         if(vehicleTypeList[i].id == widget.driverDetails!.vehicleId){
//           setState(() {
//             selectedVehicleType = vehicleTypeList[i];
//           });
//         }
//       }
//     }
//   }
//
//   File? _image;
//   File? _carImage;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: widget.isDashBoard == true
//             ? null
//             : AppBar(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 centerTitle: true,
//                 title: Text(
//                   widget.driverDetails != null ? "Edit Driver" : "Add Driver",
//                   style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black87),
//                 ),
//                 leading: IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(
//                     Icons.arrow_back_ios,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//         body: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Form(
//                   key: _key,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Stack(
//                               alignment: Alignment.bottomCenter,
//                               children: <Widget>[
//                                 profilePicUrl.isNotEmpty
//                                     ? ClipOval(
//                                         child: SizedBox.fromSize(
//                                           size: Size.fromRadius(40), // Image radius
//                                           child: Image.network(profilePicUrl, fit: BoxFit.cover),
//                                         ),
//                                       )
//                                     : ClipOval(
//                                         child: SizedBox.fromSize(
//                                           size: Size.fromRadius(40), // Image radius
//                                           child: _image == null
//                                               ? Image.asset(
//                                                   'assets/images/placeholder.jpg',
//                                                   fit: BoxFit.fill,
//                                                 )
//                                               : Image.file(_image!, fit: BoxFit.cover),
//                                         ),
//                                       ),
//                                 Positioned(
//                                   left: 45,
//                                   right: 0,
//                                   child: Container(
//                                     height: 40.0,
//                                     width: 40.0,
//                                     child: FloatingActionButton(
//                                       heroTag: 'profileImage',
//                                       backgroundColor: Color(COLOR_ACCENT),
//                                       child: Icon(
//                                         CupertinoIcons.camera,
//                                         size: 14,
//                                         color: isDarkMode(context) ? Colors.black : Colors.white,
//                                       ),
//                                       mini: true,
//                                       onPressed: () => _onCameraClick(true),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                             SizedBox(
//                               width: 20,
//                             ),
//                             Stack(
//                               alignment: Alignment.bottomCenter,
//                               children: <Widget>[
//                                 carPicUrl.isNotEmpty
//                                     ? ClipOval(
//                                         child: SizedBox.fromSize(
//                                           size: Size.fromRadius(40), // Image radius
//                                           child: Image.network(carPicUrl, fit: BoxFit.cover),
//                                         ),
//                                       )
//                                     : ClipOval(
//                                         child: SizedBox.fromSize(
//                                           size: Size.fromRadius(40), // Image radius
//                                           child: _carImage == null
//                                               ? Image.asset(
//                                                   'assets/images/car_default_image.png',
//                                                   fit: BoxFit.fill,
//                                                 )
//                                               : Image.file(_carImage!, fit: BoxFit.cover),
//                                         ),
//                                       ),
//                                 Positioned(
//                                   left: 45,
//                                   right: 0,
//                                   child: Container(
//                                     height: 40.0,
//                                     width: 40.0,
//                                     child: FloatingActionButton(
//                                       heroTag: 'profileImage',
//                                       backgroundColor: Color(COLOR_ACCENT),
//                                       child: Icon(
//                                         CupertinoIcons.camera,
//                                         size: 14,
//                                         color: isDarkMode(context) ? Colors.black : Colors.white,
//                                       ),
//                                       mini: true,
//                                       onPressed: () => _onCameraClick(false),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ],
//                         ),
//                         ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: double.infinity),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                             child: TextFormField(
//                               controller: _firstNameController,
//                               cursorColor: Color(COLOR_PRIMARY),
//                               textAlignVertical: TextAlignVertical.center,
//                               validator: validateName,
//                               textInputAction: TextInputAction.next,
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                 fillColor: Colors.white,
//                                 hintText: "First Name".tr(),
//                                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                                 focusedErrorBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: double.infinity),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                             child: TextFormField(
//                               controller: _lastNameController,
//                               validator: validateName,
//                               textAlignVertical: TextAlignVertical.center,
//                               cursorColor: Color(COLOR_PRIMARY),
//                               textInputAction: TextInputAction.next,
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                 fillColor: Colors.white,
//                                 hintText: 'Last Name'.tr(),
//                                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                                 focusedErrorBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: double.infinity),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                             child: DropdownButtonFormField<SectionModel>(
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                   fillColor: Colors.white,
//                                   hintText: 'Select Section'.tr(),
//                                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                   errorBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                   focusedErrorBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Colors.grey.shade200),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                 ),
//                                 validator: (value) => value == null ? 'field required' : null,
//                                 value: selectedSection,
//                                 onChanged: (value) async {
//                                   setState(() {
//                                     selectedSection = value;
//                                   });
//                                   if (selectedSection != null) {
//                                     await FireStoreUtils.getVehicleType(selectedSection!).then((value) {
//                                       setState(() {
//                                         vehicleTypeList = value;
//                                         selectedVehicleType = null;
//                                       });
//                                     });
//                                   }
//                                 },
//                                 hint: Text('Select Section'.tr()),
//                                 items: sectionsVal!.map((SectionModel item) {
//                                   return DropdownMenuItem<SectionModel>(
//                                     child: Text(item.name.toString()),
//                                     value: item,
//                                   );
//                                 }).toList()),
//                           ),
//                         ),
//                         ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: double.infinity),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                             child: DropdownButtonFormField<VehicleType>(
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                   fillColor: Colors.white,
//                                   hintText: "Select vehicle type".tr(),
//                                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                   errorBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                   focusedErrorBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Colors.grey.shade200),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                 ),
//                                 validator: (value) => value == null ? "field required".tr() : null,
//                                 value: selectedVehicleType,
//                                 onChanged: (value) async {
//                                   setState(() {
//                                     selectedVehicleType = value;
//                                   });
//                                 },
//                                 hint: Text('Select vehicle type'.tr()),
//                                 items: vehicleTypeList.map((VehicleType item) {
//                                   return DropdownMenuItem<VehicleType>(
//                                     child: Text(item.name.toString()),
//                                     value: item,
//                                   );
//                                 }).toList()),
//                           ),
//                         ),
//                         ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: double.infinity),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                             child: DropdownButtonFormField<String>(
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                   errorBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                   focusedErrorBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Colors.grey.shade200),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                 ),
//                                 validator: (value) => value == null ? 'field required'.tr() : null,
//                                 value: selectedCarMakes,
//                                 onChanged: (value) async {
//                                   carModelList.clear();
//                                   selectedCarModel = null;
//                                   setState(() {
//                                     selectedCarMakes = value;
//                                   });
//                                   await FireStoreUtils.getCarModel(context, selectedCarMakes!.toString()).then((value) {
//                                     value.forEach((element) {
//                                       if (!carModelList.contains(element.name.toString())) {
//                                         setState(() {
//                                           carModelList.add(element.name.toString());
//                                         });
//                                       }
//                                     });
//                                   });
//                                 },
//                                 hint: Text("Select Car Makes".tr()),
//                                 items: carMakesList.map((String item) {
//                                   return DropdownMenuItem<String>(
//                                     child: Text(item.toString()),
//                                     value: item,
//                                   );
//                                 }).toList()),
//                           ),
//                         ),
//                         ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: double.infinity),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                             child: DropdownButtonFormField<String>(
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                   errorBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                   focusedErrorBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: Colors.grey.shade200),
//                                     borderRadius: BorderRadius.circular(25.0),
//                                   ),
//                                 ),
//                                 validator: (value) => value == null ? 'field required' : null,
//                                 value: selectedCarModel,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     selectedCarModel = value;
//                                   });
//                                 },
//                                 hint: Text("Select Car Model".tr()),
//                                 items: carModelList.map((String item) {
//                                   return DropdownMenuItem<String>(
//                                     child: Text(item.toString()),
//                                     value: item,
//                                   );
//                                 }).toList()),
//                           ),
//                         ),
//                         ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: double.infinity),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                             child: TextFormField(
//                               controller: _carPlateController,
//                               validator: validateEmptyField,
//                               textAlignVertical: TextAlignVertical.center,
//                               cursorColor: Color(COLOR_PRIMARY),
//                               textInputAction: TextInputAction.next,
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                 fillColor: Colors.white,
//                                 hintText: "Car Plate".tr(),
//                                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                                 focusedErrorBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         widget.driverDetails != null
//                             ? ConstrainedBox(
//                                 constraints: BoxConstraints(minWidth: double.infinity),
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                                   child: TextFormField(
//                                     controller: _mobileController,
//                                     validator: validateEmptyField,
//                                     textAlignVertical: TextAlignVertical.center,
//                                     cursorColor: Color(COLOR_PRIMARY),
//                                     textInputAction: TextInputAction.next,
//                                     decoration: InputDecoration(
//                                       contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                       fillColor: Colors.white,
//                                       enabled: false,
//                                       hintText: "Phone Number".tr(),
//                                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                       errorBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                         borderRadius: BorderRadius.circular(25.0),
//                                       ),
//                                       focusedErrorBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                         borderRadius: BorderRadius.circular(25.0),
//                                       ),
//                                       enabledBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(color: Colors.grey.shade200),
//                                         borderRadius: BorderRadius.circular(25.0),
//                                       ),
//                                       disabledBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(color: Colors.grey.shade200),
//                                         borderRadius: BorderRadius.circular(25.0),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : Padding(
//                                 padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(horizontal: 16),
//                                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), shape: BoxShape.rectangle, border: Border.all(color: Colors.grey.shade200)),
//                                   child: InternationalPhoneNumberInput(
//                                     onInputChanged: (PhoneNumber number) => _mobileController.text = number.phoneNumber.toString(),
//                                     ignoreBlank: true,
//                                     autoValidateMode: AutovalidateMode.onUserInteraction,
//                                     inputDecoration: InputDecoration(
//                                       hintText: "Phone Number".tr(),
//                                       border: OutlineInputBorder(
//                                         borderSide: BorderSide.none,
//                                       ),
//                                       isDense: true,
//                                       errorBorder: OutlineInputBorder(
//                                         borderSide: BorderSide.none,
//                                       ),
//                                     ),
//                                     inputBorder: OutlineInputBorder(
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     selectorConfig: SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
//                                   ),
//                                 ),
//                               ),
//                         ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: double.infinity),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                             child: TextFormField(
//                               controller: _emailController,
//                               keyboardType: TextInputType.emailAddress,
//                               textAlignVertical: TextAlignVertical.center,
//                               textInputAction: TextInputAction.next,
//                               cursorColor: Color(COLOR_PRIMARY),
//                               validator: validateEmail,
//                               enabled: widget.driverDetails == null ? true : false,
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                 fillColor: Colors.white,
//                                 hintText: "Email Address".tr(),
//                                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                                 focusedErrorBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                                 disabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(25.0),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         widget.driverDetails != null
//                             ? Container()
//                             : ConstrainedBox(
//                                 constraints: BoxConstraints(minWidth: double.infinity),
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//                                   child: TextFormField(
//                                     obscureText: true,
//                                     textAlignVertical: TextAlignVertical.center,
//                                     textInputAction: TextInputAction.next,
//                                     controller: _passwordController,
//                                     validator: validatePassword,
//                                     style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 18.0),
//                                     cursorColor: Color(COLOR_PRIMARY),
//                                     decoration: InputDecoration(
//                                       contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                       fillColor: Colors.white,
//                                       hintText: 'Password'.tr(),
//                                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
//                                       errorBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                         borderRadius: BorderRadius.circular(25.0),
//                                       ),
//                                       focusedErrorBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                         borderRadius: BorderRadius.circular(25.0),
//                                       ),
//                                       enabledBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(color: Colors.grey.shade200),
//                                         borderRadius: BorderRadius.circular(25.0),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         buildButton(title: widget.driverDetails != null ? "Edit Driver" : "Add Driver".tr()),
//                       ],
//                     ),
//                   ),
//                 ),
//         ));
//   }
//
//   buildButton({title}) {
//     final size = MediaQuery.of(context).size;
//     return SizedBox(
//       width: size.width,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: MaterialButton(
//           height: 45,
//           color: Color(COLOR_PRIMARY),
//           onPressed: () async {
//             if (_key.currentState?.validate() ?? false) {
//               _key.currentState!.save();
//
//               if (widget.driverDetails != null) {
//                 await showProgress(context, "Driver update...".tr(), false);
//
//                 if (_image != null) {
//                   updateProgress("Uploading image, Please wait...".tr());
//                   profilePicUrl = await FireStoreUtils.uploadUserImageToFireStorage(_image!, widget.driverDetails!.userID);
//                 }
//
//                 if (_carImage != null) {
//                   updateProgress("Uploading image, Please wait...".tr());
//                   carPicUrl = await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, DateTime.now().millisecondsSinceEpoch.toString());
//                 }
//
//                 User user = User(
//                     email: _emailController.text,
//                     settings: UserSettings(),
//                     lastOnlineTimestamp: Timestamp.now(),
//                     isActive: true,
//                     active: true,
//                     phoneNumber: _mobileController.text,
//                     firstName: _firstNameController.text,
//                     userID: widget.driverDetails!.userID,
//                     lastName: _lastNameController.text,
//                     fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
//                     profilePictureURL: profilePicUrl,
//                     carPictureURL: carPicUrl,
//                     carName: selectedCarModel.toString(),
//                     carMakes: selectedCarMakes.toString(),
//                     carNumber: _carPlateController.text,
//                     isCompany: false,
//                     companyId: MyAppState.currentUser!.userID,
//                     companyName: MyAppState.currentUser!.companyName,
//                     companyAddress: MyAppState.currentUser!.companyAddress,
//                     role: USER_ROLE_DRIVER,
//                     serviceType: "cab-service",
//                     vehicleType: selectedVehicleType!.name.toString(),
//                     vehicleId: selectedVehicleType!.id.toString(),
//                     sectionId: selectedSection!.id);
//                 String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
//                 if (errorMessage == null) {
//                   print("--->1");
//                   if (widget.isDashBoard == true) {
//                     Navigator.pop(context, user);
//                   } else {
//                     Navigator.pop(context, user);
//                     Navigator.pop(context, user);
//                   }
//                 } else {
//                   showAlertDialog(context, 'Failed'.tr(), "Failed to create driver.".tr(), true);
//                 }
//               } else {
//                 await showProgress(context, "Driver create...".tr(), false);
//
//                 try {
//                   FirebaseApp secondaryApp = await Firebase.initializeApp(
//                     name: 'SecondaryApp',
//                     options: Firebase.app().options,
//                   );
//                   auth.UserCredential result = await auth.FirebaseAuth.instanceFor(app: secondaryApp).createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
//
//                   if (_image != null) {
//                     updateProgress("Uploading image, Please wait...".tr());
//                     profilePicUrl = await FireStoreUtils.uploadUserImageToFireStorage(_image!, result.user?.uid ?? '');
//                   }
//                   if (_carImage != null) {
//                     updateProgress("Uploading image, Please wait...".tr());
//                     carPicUrl = await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, DateTime.now().millisecondsSinceEpoch.toString());
//                   }
//
//                   User user = User(
//                     email: _emailController.text,
//                     settings: UserSettings(),
//                     lastOnlineTimestamp: Timestamp.now(),
//                     isActive: true,
//                     active: true,
//                     phoneNumber: _mobileController.text,
//                     firstName: _firstNameController.text,
//                     userID: result.user?.uid ?? '',
//                     lastName: _lastNameController.text,
//                     fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
//                     profilePictureURL: profilePicUrl,
//                     carPictureURL: carPicUrl,
//                     carName: selectedCarModel.toString(),
//                     carMakes: selectedCarMakes.toString(),
//                     carNumber: _carPlateController.text,
//                     isCompany: false,
//                     companyId: MyAppState.currentUser!.userID,
//                     companyName: MyAppState.currentUser!.companyName,
//                     companyAddress: MyAppState.currentUser!.companyAddress,
//                     role: USER_ROLE_DRIVER,
//                     serviceType: "cab-service",
//                     sectionId: selectedSection!.id.toString(),
//                     vehicleId: selectedVehicleType!.id.toString(),
//                     vehicleType: selectedVehicleType!.name.toString(),
//                   );
//
//                   String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
//                   if (errorMessage == null) {
//                     if (widget.isDashBoard == true) {
//                       Navigator.pop(context, user);
//                     } else {
//                       Navigator.pop(context, user);
//                       Navigator.pop(context, user);
//                     }
//                   } else {
//                     showAlertDialog(context, 'Failed'.tr(), 'Failed to create driver.'.tr(), true);
//                   }
//                 } catch (e) {
//                   hideProgress();
//                   showAlertDialog(context, 'Failed'.tr(), 'Failed to create driver.'.tr(), true);
//                 }
//               }
//             }
//           },
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           child: Text(
//             title,
//             style: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
//
//   _onCameraClick(bool isSingle) {
//     final action = CupertinoActionSheet(
//       message: const Text(
//         "Add your Vehicle image.",
//         style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 15.0),
//       ).tr(),
//       actions: <Widget>[
//         CupertinoActionSheetAction(
//           isDefaultAction: false,
//           onPressed: () async {
//             Navigator.pop(context);
//             if (isSingle) {
//               XFile? singleImage = await ImagePicker().pickImage(source: ImageSource.gallery);
//               if (singleImage != null) {
//                 setState(() {
//                   profilePicUrl = '';
//                   _image = File(singleImage.path);
//                 });
//               }
//             } else {
//               XFile? singleImage = await ImagePicker().pickImage(source: ImageSource.gallery);
//               if (singleImage != null) {
//                 setState(() {
//                   carPicUrl = "";
//                   _carImage = File(singleImage.path);
//                 });
//               }
//             }
//           },
//           child: const Text("Choose image from gallery").tr(),
//         ),
//         CupertinoActionSheetAction(
//           isDestructiveAction: false,
//           onPressed: () async {
//             Navigator.pop(context);
//             if (isSingle) {
//               if (isSingle) {
//                 XFile? singleImage = await ImagePicker().pickImage(source: ImageSource.camera);
//                 if (singleImage != null) {
//                   setState(() {
//                     _image = File(singleImage.path);
//                   });
//                 }
//               } else {
//                 XFile? singleImage = await ImagePicker().pickImage(source: ImageSource.camera);
//                 if (singleImage != null) {
//                   setState(() {
//                     _carImage = File(singleImage.path);
//                   });
//                 }
//               }
//             }
//           },
//           child: const Text('Take a picture'),
//         ),
//       ],
//       cancelButton: CupertinoActionSheetAction(
//         child: const Text(
//           'Cancel',
//         ).tr(),
//         onPressed: () {
//           Navigator.pop(context);
//         },
//       ),
//     );
//     showCupertinoModalPopup(context: context, builder: (context) => action);
//   }
// }
