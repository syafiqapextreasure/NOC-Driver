import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/User.dart';
import 'package:nocdriver/model/conversation_model.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AddDriverScreen extends StatefulWidget {
  User? driverDetails;
  bool? isDashBoard;

  AddDriverScreen({Key? key, required this.driverDetails, this.isDashBoard})
      : super(key: key);

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  ///driver info
  TextEditingController dNameController = TextEditingController();
  TextEditingController dEmailController = TextEditingController();
  TextEditingController dPasswordController = TextEditingController();
  TextEditingController dPhoneController = TextEditingController();

  TextEditingController driverRateController = TextEditingController();

  ///Vehicle info
  TextEditingController carNameController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController carRateController = TextEditingController();

  TextEditingController noOfPassengersController = TextEditingController();
  TextEditingController noOfDoorController = TextEditingController();

  TextEditingController carNumberController = TextEditingController();
  TextEditingController maxPowerController = TextEditingController();
  TextEditingController mphController = TextEditingController();
  TextEditingController topSpeedController = TextEditingController();

  String airConditioning = "Yes";
  String gear = "Manual";
  String fuelFilling = "Full to full";
  List<String> fuelFillingList = ['Full to full', 'Half'];
  String mileage = "Average";
  String fuelType = "Petrol";

  GlobalKey<FormState> _key = GlobalKey();

  List<String> vehicleTypeName = [];
  String? selectedVehicleType;

  @override
  void initState() {
    getVehicle();
    getDriver();
    super.initState();
  } // Option 2

  getDriver() {
    print("CARNAME11" + carNameController.text);
    if (widget.driverDetails != null) {
      print("CARNAME22" + widget.driverDetails!.carName);
      setState(() {
        carNameController.clear();
        print("CARNAME33" + carNameController.text);
        dNameController.text = widget.driverDetails!.firstName;
        dEmailController.text = widget.driverDetails!.email;
        dPhoneController.text = widget.driverDetails!.phoneNumber;
        driverRateController.text = widget.driverDetails!.driverRate;
        carNameController.text = widget.driverDetails!.carName;
        carModelController.text = widget.driverDetails!.carMakes;
        carRateController.text = widget.driverDetails!.carRate;
        carNumberController.text = widget.driverDetails!.carNumber;
        noOfPassengersController.text =
            widget.driverDetails!.carInfo!.passenger.toString();
        noOfDoorController.text =
            widget.driverDetails!.carInfo!.doors.toString();
        maxPowerController.text =
            widget.driverDetails!.carInfo!.maxPower.toString();
        mphController.text = widget.driverDetails!.carInfo!.mph.toString();
        topSpeedController.text =
            widget.driverDetails!.carInfo!.topSpeed.toString();
        airConditioning =
            widget.driverDetails!.carInfo!.airConditioning.toString().isEmpty
                ? "Yes"
                : widget.driverDetails!.carInfo!.airConditioning.toString();
        gear = widget.driverDetails!.carInfo!.gear.toString().isEmpty
            ? "Manual"
            : widget.driverDetails!.carInfo!.gear.toString();
        fuelFilling =
            widget.driverDetails!.carInfo!.fuelFilling.toString().isEmpty
                ? "Full to full"
                : widget.driverDetails!.carInfo!.fuelFilling.toString();
        mileage = widget.driverDetails!.carInfo!.mileage.toString().isEmpty
            ? "Average"
            : widget.driverDetails!.carInfo!.mileage.toString();
        fuelType = widget.driverDetails!.carInfo!.fuelType.toString().isEmpty
            ? "Petrol"
            : widget.driverDetails!.carInfo!.fuelType.toString();
        carImages = widget.driverDetails!.carInfo!.carImage;
        profilePicUrl = widget.driverDetails!.profilePictureURL;
        selectedVehicleType = widget.driverDetails!.vehicleType.toString();
      });
      print("CARNAME1" + widget.driverDetails!.carName);
    }
  }

  getVehicle() async {
    await FireStoreUtils.getRentalVehicleType().then((value) {
      value.forEach((element) {
        if (!vehicleTypeName.contains(element.name.toString())) {
          setState(() {
            vehicleTypeName.add(element.name.toString());
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.isDashBoard == true
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  "Add Driver",
                  style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black87),
                ),
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  ),
                ),
              ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _key,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  buildDriverInfo(),
                  buildVehicleInfo(),
                  parcelImageWidget(),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 30),
                    child: buildButton(title: "Save"),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  addDriver() {}

  File? _image;

  buildDriverInfo() {
    return Column(
      children: [
        buildHeader(no: "1", title: "Driver Info"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 550,
                  ),
                  child: Container(
                    color: Colors.black38,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          profilePicUrl.isNotEmpty
                              ? ClipOval(
                                  child: SizedBox.fromSize(
                                    size: Size.fromRadius(40), // Image radius
                                    child: Image.network(profilePicUrl,
                                        fit: BoxFit.cover),
                                  ),
                                )
                              : ClipOval(
                                  child: SizedBox.fromSize(
                                    size: Size.fromRadius(40), // Image radius
                                    child: _image == null
                                        ? Image.asset(
                                            'assets/images/placeholder.jpg',
                                            fit: BoxFit.fill,
                                          )
                                        : Image.file(_image!,
                                            fit: BoxFit.cover),
                                  ),
                                ),
                          Positioned(
                            left: 45,
                            right: 0,
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              child: FloatingActionButton(
                                heroTag: 'profileImage',
                                backgroundColor: Color(COLOR_ACCENT),
                                child: Icon(
                                  CupertinoIcons.camera,
                                  size: 14,
                                  color: isDarkMode(context)
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                mini: true,
                                onPressed: () => _onCameraClick(true),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      buildTextFormField(
                          title: "Driver Name",
                          controller: dNameController,
                          validator: validateEmptyField),
                      buildTextFormField(
                        title: "Email",
                        controller: dEmailController,
                        validator: validateEmail,
                        // isEnable: widget.driverDetails == null ? true : false
                        readOnly: widget.driverDetails == null ? false : true,
                      ),
                      widget.driverDetails == null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    "Phone Number",
                                    style:
                                        TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade600),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                          color: Colors.grey.shade400)),
                                  child: InternationalPhoneNumberInput(
                                    onInputChanged: (PhoneNumber number) =>
                                        dPhoneController.text =
                                            number.phoneNumber.toString(),
                                    ignoreBlank: true,
                                    validator: validateEmptyField,
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    inputDecoration: InputDecoration(
                                      hintText: 'Phone Number'.tr(),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    inputBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    selectorConfig: SelectorConfig(
                                        selectorType:
                                            PhoneInputSelectorType.DIALOG),
                                  ),
                                ),
                              ],
                            )
                          : buildTextFormField(
                              title: "Phone number",
                              controller: dPhoneController,
                              //  isEnable: false
                              readOnly:
                                  widget.driverDetails == null ? false : true,
                            ),
                      buildRateTextForm(
                          title: "Driver Rate (per day)",
                          controller: driverRateController,
                          validator: validateEmptyField),
                      widget.driverDetails == null
                          ? buildTextFormField(
                              title: "Password",
                              textInputType: TextInputType.phone,
                              controller: dPasswordController,
                              validator: validatePassword)
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildVehicleInfo() {
    return Column(
      children: [
        buildHeader(no: "2", title: "Car Info".tr()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 870,
                  ),
                  child: Container(
                    color: Colors.black38,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextFormField(
                          title: "Car Name".tr(),
                          controller: carNameController,
                          validator: validateEmptyField),
                      buildTextFormField(
                          title: "Car Model".tr(),
                          controller: carModelController,
                          validator: validateEmptyField),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          "Select vehicle type".tr(),
                          style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade600),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              fillColor: Colors.white,
                              hintText: 'Select vehicle type'.tr(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade400)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(COLOR_PRIMARY))),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade400)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade400)),
                              focusColor: Color(COLOR_PRIMARY)),
                          validator: (value) =>
                              value == null ? 'field required' : null,
                          value: selectedVehicleType,
                          onChanged: (value) async {
                            setState(() {
                              selectedVehicleType = value;
                            });
                          },
                          hint: Text('Select vehicle type'.tr()),
                          items: vehicleTypeName.map((String item) {
                            return DropdownMenuItem<String>(
                              child: Text(item.toString()),
                              value: item,
                            );
                          }).toList()),
                      buildRateTextForm(
                          title: "Car Rate (per day)".tr(),
                          controller: carRateController,
                          validator: validateEmptyField),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextFormField(
                                title: "Passengers".tr(),
                                controller: noOfPassengersController,
                                textInputType: TextInputType.number,
                                validator: validateEmptyField),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: buildTextFormField(
                                title: "Doors".tr(),
                                controller: noOfDoorController,
                                textInputType: TextInputType.number,
                                validator: validateEmptyField),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: buildAirConditioningDropDown(
                              title: "Air Conditioning".tr(),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: buildGearDropDown(
                              title: "Gear".tr(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: buildMileageDown(
                              title: "Mileage".tr(),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: buildFuelFillingDown(
                              title: "Fuel Filling".tr(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextFormField(
                                title: "Car Number".tr(),
                                controller: carNumberController,
                                validator: validateEmptyField),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: buildFuelTypeDown(
                              title: "Fuel Type".tr(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextFormField(
                                title: "Max Power",
                                textInputType: TextInputType.number,
                                controller: maxPowerController,
                                validator: validateEmptyField),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: buildTextFormField(
                                title: "0-60 mph(second)",
                                controller: mphController,
                                textInputType: TextInputType.number,
                                validator: validateEmptyField),
                          ),
                        ],
                      ),
                      buildTextFormField(
                          title: "Top Speed",
                          controller: topSpeedController,
                          textInputType: TextInputType.number,
                          validator: validateEmptyField),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildHeader({required String no, required String title}) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(COLOR_PRIMARY),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              no,
              style: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            title,
            style: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 18),
          ),
        ),
      ],
    );
  }

  buildTextFormField({
    required String title,
    TextInputType textInputType = TextInputType.text,
    validator,
    isEnable = true,
    readOnly = false,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            title,
            style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade600),
          ),
        ),
        Card(
          elevation: 1,
          child: TextFormField(
            keyboardType: textInputType,
            controller: controller,
            cursorColor: Color(COLOR_PRIMARY),
            validator: validator,
            enabled: isEnable,
            readOnly: readOnly,
            decoration: InputDecoration(
                floatingLabelStyle: TextStyle(fontFamily: "GlacialIndifference",color: Color(COLOR_PRIMARY)),
                labelStyle: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade500),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: title,
                hintText: title,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                hintStyle: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey),
                alignLabelWithHint: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(COLOR_PRIMARY))),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400)),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400)),
                focusColor: Color(COLOR_PRIMARY)),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  buildRateTextForm({
    required String title,
    int maxLine = 1,
    validator,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade600),
          ),
        ),
        Card(
          elevation: 1,
          child: TextFormField(
            keyboardType: const TextInputType.numberWithOptions(
                signed: false, decimal: false),
            minLines: 1,
            style: const TextStyle(fontFamily: "GlacialIndifference",fontSize: 18),
            maxLines: maxLine,
            textAlign: TextAlign.start,
            controller: controller,
            cursorColor: Color(COLOR_PRIMARY),
            validator: (value) =>
                value == null || value.isEmpty || int.parse(value) < 1
                    ? "This field can't be 0.".tr()
                    : null,
            decoration: InputDecoration(
                hintText: title,
                hintStyle: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                prefixIconConstraints: const BoxConstraints(maxWidth: 50),
                prefixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${currencyData!.symbol}",
                      style:
                          TextStyle(fontFamily: "GlacialIndifference",fontSize: 20, color: Color(COLOR_PRIMARY)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "|",
                        style: TextStyle(fontFamily: "GlacialIndifference",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black38),
                      ),
                    ),
                  ],
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400)),
                border: const OutlineInputBorder(borderSide: BorderSide()),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(COLOR_PRIMARY))),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400)),
                focusColor: Color(COLOR_PRIMARY)),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  buildAirConditioningDropDown({
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            title,
            style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade600),
          ),
        ),
        SizedBox(
          height: 50,
          child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: title,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Color(COLOR_PRIMARY),
                )),
              ),
              value: airConditioning,
              items: const [
                DropdownMenuItem(value: "Yes", child: Text("Yes")),
                DropdownMenuItem(value: "No", child: Text("No")),
              ],
              onChanged: (value) {
                setState(() {
                  airConditioning = value!;
                });
              }),
        ),
      ],
    );
  }

  buildGearDropDown({
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            title,
            style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade600),
          ),
        ),
        DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: title,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: Color(COLOR_PRIMARY),
              )),
            ),
            value: gear,
            items: const [
              DropdownMenuItem(value: "Manual", child: Text("Manual")),
              DropdownMenuItem(value: "Auto", child: Text("Auto")),
            ],
            onChanged: (value) {
              setState(() {
                gear = value!;
              });
            }),
      ],
    );
  }

  buildFuelFillingDown({
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            title,
            style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade600),
          ),
        ),
        DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: title,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: Color(COLOR_PRIMARY),
              )),
            ),
            value: fuelFillingList[0],
            items: const [
              DropdownMenuItem(
                  value: "Full to full", child: Text("Full to full")),
              DropdownMenuItem(value: "Half", child: Text("Half")),
            ],
            onChanged: (value) {
              setState(() {
                fuelFilling = value!;
              });
            }),
      ],
    );
  }

  buildMileageDown({
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            title,
            style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade600),
          ),
        ),
        DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: title,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: Color(COLOR_PRIMARY),
              )),
            ),
            value: mileage,
            items: const [
              DropdownMenuItem(value: "Ultimated", child: Text("Ultimated")),
              DropdownMenuItem(value: "Average", child: Text("Average")),
            ],
            onChanged: (value) {
              setState(() {
                mileage = value!;
              });
            }),
      ],
    );
  }

  buildFuelTypeDown({
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            title,
            style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade600),
          ),
        ),
        Card(
          elevation: 1,
          child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: title,
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Color(COLOR_PRIMARY),
                )),
              ),
              value: fuelType,
              items: const [
                DropdownMenuItem(value: "Petrol", child: Text("Petrol")),
                DropdownMenuItem(value: "Diesel", child: Text("Diesel")),
              ],
              onChanged: (value) {
                setState(() {
                  fuelType = value!;
                });
              }),
        ),
      ],
    );
  }

  parcelImageWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          buildHeader(no: "3", title: "Upload Vehicle Image"),
          const SizedBox(
            height: 6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: SizedBox(
                  width: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 150,
                    ),
                    child: Container(
                      color: Colors.black38,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: 100,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Visibility(
                              visible: widget.driverDetails != null,
                              child: ListView.builder(
                                itemCount: carImages!.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Container(
                                      width: 100,
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                carImages![index])),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8.0)),
                                      ),
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              carImages!.removeAt(index);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.remove_circle,
                                            size: 30,
                                          )),
                                    ),
                                  );
                                },
                              )),
                          Visibility(
                              visible: images!.isNotEmpty,
                              child: ListView.builder(
                                itemCount: images!.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Container(
                                      width: 100,
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                                File(images![index].path))),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8.0)),
                                      ),
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              images!.removeAt(index);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.remove_circle,
                                            size: 30,
                                          )),
                                    ),
                                  );
                                },
                              )),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: InkWell(
                              onTap: () {
                                _onCameraClick(false);
                              },
                              child: Image.asset('assets/images/add_img.png',
                                  height: 100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  List<XFile>? images = [];

  _onCameraClick(bool isSingle) {
    final action = CupertinoActionSheet(
      message: const Text(
        'Add your Vehicle image.',
        style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            if (isSingle) {
              XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (singleImage != null) {
                setState(() {
                  _image = File(singleImage.path);
                });
              }
            } else {
              List<XFile>? multipalImage = await ImagePicker().pickMultiImage();
              multipalImage.forEach((element) {
                setState(() {
                  images!.add(element);
                });
              });
            }
          },
          child: const Text('Choose image from gallery'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            if (isSingle) {
              final XFile? singleImage =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (singleImage != null) {
                setState(() {
                  _image = File(singleImage.path);
                });
              }
            } else {
              final XFile? photo =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (photo != null) {
                setState(() {
                  images!.add(photo);
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

  List<dynamic>? carImages = [];
  String profilePicUrl = '';

  buildButton({title}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: MaterialButton(
          height: 45,
          color: Color(COLOR_PRIMARY),
          onPressed: () async {
            if (_key.currentState?.validate() ?? false) {
              _key.currentState!.save();
              FocusManager.instance.primaryFocus?.unfocus();

              if (widget.driverDetails != null) {
                await showProgress(context, 'Driver update...'.tr(), false);
                setState(() {});

                if (_image != null) {
                  updateProgress('Uploading image, Please wait...'.tr());
                  profilePicUrl =
                      await FireStoreUtils.uploadUserImageToFireStorage(
                          _image!, widget.driverDetails!.userID);
                }
                if (images!.isNotEmpty) {
                  for (var element in images!) {
                    Url url = await FireStoreUtils()
                        .uploadChatImageToFireStorage(
                            File(element.path), context);
                    carImages!.add(url.url);
                  }
                }

                CarInfo carInfo = CarInfo(
                    carImage: carImages,
                    carName: carNameController.text,
                    airConditioning: airConditioning,
                    doors: noOfDoorController.text,
                    fuelFilling: fuelFilling,
                    fuelType: fuelType,
                    gear: gear,
                    mileage: mileage,
                    maxPower: maxPowerController.text,
                    mph: mphController.text,
                    topSpeed: topSpeedController.text,
                    passenger: noOfPassengersController.text);
                User user = User(
                    email: dEmailController.text,
                    settings: UserSettings(),
                    lastOnlineTimestamp: Timestamp.now(),
                    isActive: true,
                    active: true,
                    phoneNumber: dPhoneController.text,
                    firstName: dNameController.text,
                    userID: widget.driverDetails!.userID,
                    lastName: widget.driverDetails!.lastName,
                    fcmToken:
                        await FireStoreUtils.firebaseMessaging.getToken() ?? '',
                    profilePictureURL: profilePicUrl,
                    carName: carNameController.text,
                    carMakes: carModelController.text,
                    carNumber: carNumberController.text,
                    role: USER_ROLE_DRIVER,
                    serviceType: "rental-service",
                    carInfo: carInfo,
                    carRate: carRateController.text,
                    driverRate: driverRateController.text,
                    vehicleType: selectedVehicleType.toString(),
                    createdAt: widget.driverDetails!.createdAt,
                location:UserLocation(
                    latitude: widget.driverDetails!.location.latitude,
                    longitude: widget.driverDetails!.location.longitude),
                geoFireData: GeoFireData(
                    geohash: GeoFlutterFire()
                        .point(
                        latitude: widget.driverDetails!.location.latitude
                            .toDouble(),
                        longitude: widget.driverDetails!.location.longitude
                            .toDouble())
                        .hash,
                    geoPoint: GeoPoint(
                        widget.driverDetails!.location.latitude.toDouble(),
                        widget.driverDetails!.location.longitude.toDouble()))
                );
                String? errorMessage =
                    await FireStoreUtils.firebaseCreateNewUser(user);



                if (errorMessage == null) {
                  print("--->1");
                  hideProgress();
                  if (widget.isDashBoard == true) {
                    showAlertDialog(context, 'Saved'.tr(),
                        'Data Save Successfully'.tr(), true);
                  } else {
                    Navigator.pop(context, true);
                  }
                } else {
                  showAlertDialog(context, 'Failed'.tr(),
                      'Failed to create driver.'.tr(), true);
                }
              } else {
                await showProgress(context, 'Driver create...'.tr(), false);

                FirebaseApp secondaryApp = await Firebase.initializeApp(
                  name: 'SecondaryApp',
                  options: Firebase.app().options,
                );

                auth.UserCredential result =
                    await auth.FirebaseAuth.instanceFor(app: secondaryApp)
                        .createUserWithEmailAndPassword(
                            email: dEmailController.text,
                            password: dPasswordController.text);

                String profilePicUrl = '';
                if (_image != null) {
                  updateProgress('Uploading image, Please wait...'.tr());
                  profilePicUrl =
                      await FireStoreUtils.uploadUserImageToFireStorage(
                          _image!, result.user?.uid ?? '');
                }

                if (images!.isNotEmpty) {
                  for (var element in images!) {
                    Url url = await FireStoreUtils()
                        .uploadChatImageToFireStorage(
                            File(element.path), context);
                    carImages!.add(url.url);
                  }
                }

                CarInfo carInfo = CarInfo(
                    carImage: carImages,
                    carName: carNameController.text,
                    airConditioning: airConditioning,
                    doors: noOfDoorController.text,
                    fuelFilling: fuelFilling,
                    fuelType: fuelType,
                    gear: gear,
                    mileage: mileage,
                    maxPower: maxPowerController.text,
                    mph: mphController.text,
                    topSpeed: topSpeedController.text,
                    passenger: noOfPassengersController.text);
                User user = User(
                  email: dEmailController.text,
                  settings: UserSettings(),
                  lastOnlineTimestamp: Timestamp.now(),
                  isActive: true,
                  active: true,
                  phoneNumber: dPhoneController.text,
                  firstName: dNameController.text,
                  userID: result.user?.uid ?? '',
                  lastName: "",
                  fcmToken:
                      await FireStoreUtils.firebaseMessaging.getToken() ?? '',
                  profilePictureURL: profilePicUrl,
                  carName: carNameController.text,
                  carMakes: carModelController.text,
                  carNumber: carNumberController.text,
                  role: USER_ROLE_DRIVER,
                  serviceType: "rental-service",
                  carInfo: carInfo,
                  carRate: carRateController.text,
                  driverRate: driverRateController.text,
                  vehicleType: selectedVehicleType!.toString(),
                );
                String? errorMessage =
                    await FireStoreUtils.firebaseCreateNewUser(user);
                if (errorMessage == null) {
                  hideProgress();
                  if (widget.isDashBoard == true) {
                    showAlertDialog(context, 'Saved'.tr(),
                        'Data Save Successfully'.tr(), true);
                  } else {
                    Navigator.pop(context, true);
                  }
                } else {
                  showAlertDialog(context, 'Failed'.tr(),
                      'Failed to create driver.'.tr(), true);
                }
              }
            }
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            title,
            style: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.white),
          ),
        ),
      ),
    );
  }
}
