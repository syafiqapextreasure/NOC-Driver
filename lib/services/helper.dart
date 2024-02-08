import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/Parcel_service/parcel_order_model.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/CabOrderModel.dart';
import 'package:nocdriver/model/OrderModel.dart';
import 'package:nocdriver/model/TaxModel.dart';
import 'package:nocdriver/model/withdrawHistoryModel.dart';
import 'package:nocdriver/rental_service/model/rental_order_model.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

String? validateName(String? value) {
  String pattern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.length == 0) {
    return 'Name is required'.tr();
  } else if (!regExp.hasMatch(value ?? '')) {
    return 'Name must be valid'.tr();
  }
  return null;
}

String? validateMobile(String? value) {
  String pattern = r'(^\+?[0-9]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.length == 0) {
    return 'Mobile is required'.tr();
  } else if (!regExp.hasMatch(value ?? '')) {
    return 'Mobile Number must be digits'.tr();
  } else if (value!.length < 10 || value.length > 10) {
    return 'please enter valid number'.tr();
  }
  return null;
}

String? validateOthers(String? value) {
  if (value?.length == 0) {
    return '*required'.tr();
  }
  return null;
}

String? validatePassword(String? value) {
  if ((value?.length ?? 0) < 6)
    return 'Password length must be more than 6 chars.'.tr();
  else
    return null;
}

String? validateEmail(String? value) {
  String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value ?? ''))
    return 'Please use a valid mail'.tr();
  else
    return null;
}

String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (password != confirmPassword) {
    return 'Password must match'.tr();
  } else if (confirmPassword?.length == 0) {
    return 'Confirm password is required'.tr();
  } else {
    return null;
  }
}

String? validateEmptyField(String? text) => text == null || text.isEmpty ? "This field can't be empty.".tr() : null;

//helper method to show progress
late ProgressDialog progressDialog;

showProgress(BuildContext context, String message, bool isDismissible) async {
  progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: isDismissible);
  progressDialog.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: Colors.yellow,
      progressWidget: Container(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.black,
          valueColor: AlwaysStoppedAnimation(
            Colors.yellow,
          ),
        ),
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

  await progressDialog.show();
}

updateProgress(String message) {
  progressDialog.update(message: message);
}

hideProgress() async {
  await progressDialog.hide();
}

//helper method to show alert dialog
showAlertDialog(BuildContext context, String title, String content, bool addOkButton) {
  // set up the AlertDialog
  Widget? okButton;
  if (addOkButton) {
    okButton = TextButton(
      child: Text('OK').tr(),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  if (Platform.isIOS) {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [if (okButton != null) okButton],
    );
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  } else {
    AlertDialog alert = AlertDialog(title: Text(title), content: Text(content), actions: [if (okButton != null) okButton]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

pushReplacement(BuildContext context, Widget destination) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => destination));
}

push(BuildContext context, Widget destination) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => destination));
}

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => destination), (Route<dynamic> route) => predict);
}

String setLastSeen(int seconds) {
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  var diff = DateTime.now().millisecondsSinceEpoch - (seconds * 1000);
  if (diff < 24 * HOUR_MILLIS) {
    return format.format(date);
  } else if (diff < 48 * HOUR_MILLIS) {
    return 'Yesterday At {}'.tr(args: ['${format.format(date)}']);
  } else {
    format = DateFormat('MMM d');
    return '${format.format(date)}';
  }
}

Widget displayCircleImage(String picUrl, double size, hasBorder) => CachedNetworkImage(
    height: size,
    width: size,
    imageBuilder: (context, imageProvider) => _getCircularImageProvider(imageProvider, size, hasBorder),
    imageUrl: picUrl,
    placeholder: (context, url) => _getPlaceholderOrErrorImage(size, hasBorder),
    errorWidget: (context, url, error) => _getPlaceholderOrErrorImage(size, hasBorder));

Widget _getPlaceholderOrErrorImage(double size, hasBorder) => ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: const Color(COLOR_ACCENT),
            borderRadius: BorderRadius.all(Radius.circular(size / 2)),
            border: Border.all(
              color: Colors.white,
              style: hasBorder ? BorderStyle.solid : BorderStyle.none,
              width: 2.0,
            ),
            image: DecorationImage(
                image: Image.asset(
              'assets/images/placeholder.jpg',
              fit: BoxFit.cover,
              height: size,
              width: size,
            ).image)),
      ),
    );

Widget _getCircularImageProvider(ImageProvider provider, double size, bool hasBorder) {
  return ClipOval(
      child: Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        border: Border.all(
          color: Colors.white,
          style: hasBorder ? BorderStyle.solid : BorderStyle.none,
          width: 1.0,
        ),
        image: DecorationImage(
          image: provider,
          fit: BoxFit.cover,
        )),
  ));
}

Widget displayCarImage(String picUrl, double size, hasBorder) => CachedNetworkImage(
    height: size,
    width: size,
    imageBuilder: (context, imageProvider) => _getCircularImageProvider(imageProvider, size, hasBorder),
    imageUrl: picUrl,
    placeholder: (context, url) => ClipOval(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: const Color(COLOR_ACCENT),
                borderRadius: BorderRadius.all(Radius.circular(size / 2)),
                border: Border.all(
                  color: Colors.white,
                  style: hasBorder ? BorderStyle.solid : BorderStyle.none,
                  width: 2.0,
                ),
                image: DecorationImage(
                    image: Image.asset(
                  'assets/images/car_default_image.png',
                  fit: BoxFit.cover,
                  height: size,
                  width: size,
                ).image)),
          ),
        ),
    errorWidget: (context, url, error) => ClipOval(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: const Color(COLOR_ACCENT),
                borderRadius: BorderRadius.all(Radius.circular(size / 2)),
                border: Border.all(
                  color: Colors.white,
                  style: hasBorder ? BorderStyle.solid : BorderStyle.none,
                  width: 2.0,
                ),
                image: DecorationImage(
                    image: Image.asset(
                  'assets/images/car_default_image.png',
                  fit: BoxFit.cover,
                  height: size,
                  width: size,
                ).image)),
          ),
        ));

bool isDarkMode(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.light) {
    return false;
  } else {
    return true;
  }
}
bool isLightMode(BuildContext context) {
  var brightness = MediaQuery.of(context).platformBrightness;
  return brightness == Brightness.light;
}



Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied'.tr());
    }
  }

  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    Location location = Location();
    await location.requestService();
    // return Future.error('Location services are disabled.');
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error('Location permissions are permanently denied, we cannot request permissions.'.tr());
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

String audioMessageTime(Duration audioDuration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes = twoDigits(audioDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(audioDuration.inSeconds.remainder(60));
  return '${twoDigitsHours(audioDuration.inHours)}$twoDigitMinutes:$twoDigitSeconds';
}

String updateTime(Timer timer) {
  Duration callDuration = Duration(seconds: timer.tick);
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes = twoDigits(callDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(callDuration.inSeconds.remainder(60));
  return '${twoDigitsHours(callDuration.inHours)}$twoDigitMinutes:$twoDigitSeconds';
}

Widget showEmptyState(String title, {String? description, String? buttonTitle, bool? isDarkMode, VoidCallback? action}) {
  return Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 30),
      Text(title, style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.40))),
      const SizedBox(height: 15),
      Text(
        description == null ? "" : description.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: "GlacialIndifference",fontSize: 16),
      ),
      const SizedBox(height: 25),
      if (action != null)
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
                child: Text(
                  buttonTitle!,
                  style: TextStyle(fontFamily: "GlacialIndifference",color: isDarkMode! ? Colors.black.withOpacity(0.60) : Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Color(COLOR_PRIMARY),
                ),
                onPressed: action),
          ),
        )
    ]),
  );
}

String orderDate(Timestamp timestamp) {
  return DateFormat('EEE MMM d yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch));
}

updateWallateAmount(OrderModel orderModel) async {
  double total = 0.0;
  double discount = 0.0;
  double specialDiscount = 0.0;
  double taxAmount = 0.0;
  orderModel.products.forEach((element) {
    if (element.extras_price != null && element.extras_price!.isNotEmpty && double.parse(element.extras_price!) != 0.0) {
      total += element.quantity * double.parse(element.extras_price!);
    }
    total += element.quantity * double.parse(element.price);
  });

  if (orderModel.specialDiscount != null || orderModel.specialDiscount!['special_discount'] != null) {
    specialDiscount = double.parse(orderModel.specialDiscount!['special_discount'].toString());
  }

  if (orderModel.discount != null) {
    discount = double.parse(orderModel.discount.toString());
  }

  var totalamount = total - discount - specialDiscount;

  if (orderModel.taxModel != null) {
    for (var element in orderModel.taxModel!) {
      taxAmount = taxAmount + calculateTax(amount: totalamount.toString(), taxModel: element);
    }
  }

  num driverAmount = 0;
  if (orderModel.payment_method.toLowerCase() != "cod") {
    driverAmount += (double.parse(orderModel.deliveryCharge!) + double.parse(orderModel.tipValue!));
  } else {
    // driverAmount += -totalamount - taxAmount;
  }
  await FireStoreUtils.updateWalletAmount(userId: orderModel.driverID!, amount: num.parse(driverAmount.toStringAsFixed(2)));
}

/*updateWallateAmount(OrderModel orderModel) {
  double total = 0.0;
  var discount;
  var specialDiscount;
  orderModel.products.forEach((element) {
    if (element.extras_price != null && element.extras_price!.isNotEmpty && double.parse(element.extras_price!) != 0.0) {
      total += element.quantity * double.parse(element.extras_price!);
    }
    total += element.quantity * double.parse(element.price);
  });
  discount = orderModel.discount;

  if (orderModel.specialDiscount != null || specialDiscount!['special_discount'] != null) {
    specialDiscount = double.parse(orderModel.specialDiscount!['special_discount'].toString());
  }
  var totalamount = total - discount - specialDiscount;



  double adminComm = (orderModel.adminCommissionType == 'Percent') ? (totalamount * double.parse(orderModel.adminCommission!)) / 100 : double.parse(orderModel.adminCommission!);

  var finalAmount = (totalamount - adminComm).toStringAsFixed(currencyData!.decimal);

  num driverAmount = 0;
  if (orderModel.payment_method.toLowerCase() != "cod") {
    driverAmount += (double.parse(orderModel.deliveryCharge!) + double.parse(orderModel.tipValue!));
  } else {
    num taxVal = (orderModel.taxModel == null) ? 0 : getTaxValue(orderModel.taxModel, totalamount);
    driverAmount += -num.parse(finalAmount) - num.parse(adminComm.toStringAsFixed(currencyData!.decimal)) - taxVal;
  }

  FireStoreUtils.updateCurrentUserWallet(userId: orderModel.driverID!, amount: num.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
  FireStoreUtils.orderTransaction(orderModel: orderModel, amount: double.parse(finalAmount), driveramount: double.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
  FireStoreUtils.getVendor(orderModel.vendorID).then((value) {
    if (value != null) {
      FireStoreUtils.updateVendorAmount(userId: value.author, amount: num.parse(double.parse(finalAmount).toStringAsFixed(currencyData!.decimal))).then((value) {});
    }
  });
}*/

updateCabWalletAmount(CabOrderModel orderModel) {
  double totalTax = 0.0;

  /*if (orderModel.taxType!.isNotEmpty) {
    if (orderModel.taxType == "percent") {
      totalTax = (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())) * double.parse(orderModel.tax.toString()) / 100;
    } else {
      totalTax = double.parse(orderModel.tax.toString());
    }
  }*/

  double subTotal = double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString());

  if (orderModel.taxModel != null) {
    for (var element in orderModel.taxModel!) {
      totalTax = totalTax + calculateTax(amount: subTotal.toString(), taxModel: element);
    }
  }
  double adminComm = 0.0;
  if (orderModel.adminCommission!.isNotEmpty) {
    adminComm = (orderModel.adminCommissionType == 'Percent') ? (subTotal * double.parse(orderModel.adminCommission!)) / 100 : double.parse(orderModel.adminCommission!);
  }

  print("--->finalAmount---- $subTotal");
  double tipValue = orderModel.tipValue!.isEmpty ? 0.0 : double.parse(orderModel.tipValue.toString());
  double driverAmount = 0;
  if (orderModel.paymentMethod.toLowerCase() != "cod") {
    driverAmount = (subTotal + totalTax + tipValue) - adminComm;
  } else {
    //driverAmount = -(subTotal + totalTax + tipValue + adminComm);
    driverAmount = -adminComm;
  }

  print("----->$driverAmount");

  print("--->driverAmount---- $driverAmount");

  // if (orderModel.driver!.companyId.isNotEmpty) {
  //   FireStoreUtils.updateCompanyWalletAmount(companyId: orderModel.driver!.companyId, amount: num.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
  // } else {
  FireStoreUtils.updateCurrentUserWallet(userId: orderModel.driverID!, amount: num.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
  // }

  // FireStoreUtils.updateWalletAmount(userId: orderModel.driverID!, amount: num.parse(driverAmount.toStringAsFixed(decimal)));
 // FireStoreUtils.cabOrderTransaction(orderModel: orderModel, driveramount: double.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
}

updateParcelWalletAmount(ParcelOrderModel orderModel) {
  double totalTax = 0.0;

/*  if (orderModel.taxType!.isNotEmpty) {
    if (orderModel.taxType == "percent") {
      totalTax = (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())) * double.parse(orderModel.tax.toString()) / 100;
    } else {
      totalTax = double.parse(orderModel.tax.toString());
    }
  }*/

  double subTotal = double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString());

  if (orderModel.taxModel != null) {
    for (var element in orderModel.taxModel!) {
      totalTax = totalTax + calculateTax(amount: subTotal.toString(), taxModel: element);
    }
  }

  double adminComm = 0.0;
  if (orderModel.adminCommission!.isNotEmpty) {
    adminComm = (orderModel.adminCommissionType == 'Percent') ? (subTotal * double.parse(orderModel.adminCommission!)) / 100 : double.parse(orderModel.adminCommission!);
  }

  print("--->finalAmount---- $subTotal");
  double driverAmount = 0;
  if (orderModel.paymentMethod.toLowerCase() != "cod") {
    driverAmount = (subTotal + totalTax) - adminComm;
  } else {
    // driverAmount = -(subTotal + totalTax + adminComm);
    driverAmount = -((subTotal + totalTax) - adminComm);
  }
  print("----->$driverAmount");

  print("--->driverAmount---- $driverAmount");

  FireStoreUtils.updateCurrentUserWallet(userId: orderModel.driverID!, amount: num.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
//  FireStoreUtils.parcelOrderTransaction(orderModel: orderModel, driveramount: double.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
}

updateRentalWalletAmount(RentalOrderModel orderModel) {
  double totalTax = 0.0;

  double subTotal = (double.parse(orderModel.subTotal.toString()) + double.parse(orderModel.driverRate.toString())) - double.parse(orderModel.discount.toString());

  if (orderModel.taxModel != null) {
    for (var element in orderModel.taxModel!) {
      totalTax = totalTax + calculateTax(amount: subTotal.toString(), taxModel: element);
    }
  }

  double adminComm = 0.0;
  if (orderModel.adminCommission!.isNotEmpty) {
    adminComm = (orderModel.adminCommissionType == 'Percent')
        ? (subTotal * double.parse(orderModel.adminCommission!)) / 100
        : double.parse(orderModel.adminCommission!);
  }

  print("--->finalAmount---- $subTotal");
  print("--->admin commison---- $adminComm");
  print("--->Tax---- $totalTax");
  double driverAmount = 0;

  if (orderModel.paymentMethod.toLowerCase() != "cod") {
    driverAmount = (subTotal + totalTax) - adminComm;
  } else {
   // driverAmount = -(subTotal + totalTax + adminComm);
    driverAmount = -((subTotal + totalTax) - adminComm);
  }

  print("----->$driverAmount");

  print("--->driverAmount---- $driverAmount");

  // if (orderModel.driver!.companyId.isNotEmpty) {
  //   FireStoreUtils.updateCompanyWalletAmount(companyId: MyAppState.currentUser!.companyId, amount: num.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
  // } else {
  FireStoreUtils.updateCurrentUserWallet(userId: orderModel.driverID!, amount: num.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
  // }
  //FireStoreUtils.rentalOrderTransaction(orderModel: orderModel, driveramount: double.parse(driverAmount.toStringAsFixed(currencyData!.decimal)));
}

/*double getTaxValue(TaxModel? taxModel, double amount) {
  double taxVal = 0;
  if (taxModel != null) {
    if (taxModel.tax_type == "fix") {
      taxVal = taxModel.tax_amount!.toDouble();
    } else {
      taxVal = (amount * taxModel.tax_amount!.toDouble()) / 100;
    }
  }
  return double.parse(taxVal.toStringAsFixed(currencyData!.decimal));
*/

showWithdrawalModelSheet(BuildContext context, WithdrawHistoryModel withdrawHistoryModel) {
  final size = MediaQuery.of(context).size;
  return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 5, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Withdrawal Details'.tr(),
                      style: TextStyle(fontFamily: "GlacialIndifference",
                        fontSize: 18,
                         
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: size.width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: SizedBox(
                              width: size.width * 0.52,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Transaction ID".tr(),
                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Opacity(
                                    opacity: 0.55,
                                    child: Text(
                                      withdrawHistoryModel.id,
                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Container(
                            color: Colors.green.withOpacity(0.06),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(0xFF00B761)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: SizedBox(
                                      width: size.width * 0.52,
                                      child: Text(
                                        "${DateFormat('MMM dd, yyyy').format(withdrawHistoryModel.paidDate.toDate()).toUpperCase()}",
                                        style: TextStyle(fontFamily: "GlacialIndifference",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: 0.75,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        withdrawHistoryModel.paymentStatus,
                                        style: TextStyle(fontFamily: "GlacialIndifference",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17,
                                          color: withdrawHistoryModel.paymentStatus == "Success" ? Colors.green : Colors.deepOrangeAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 3.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      " ${amountShow(amount: withdrawHistoryModel.amount.toString())}",
                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontWeight: FontWeight.w600,
                                        color: withdrawHistoryModel.paymentStatus == "Success" ? Colors.green : Colors.deepOrangeAccent,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date".tr(),
                          style: TextStyle(fontFamily: "GlacialIndifference",
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        Opacity(
                          opacity: 0.75,
                          child: Text(
                            "${DateFormat('MMM dd, yyyy, KK:mma').format(withdrawHistoryModel.paidDate.toDate()).toUpperCase()}",
                            style: TextStyle(fontFamily: "GlacialIndifference",
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: withdrawHistoryModel.note != null && withdrawHistoryModel.note.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Note".tr(),
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              Opacity(
                                opacity: 0.75,
                                child: Text(
                                  withdrawHistoryModel.note,
                                  style: TextStyle(fontFamily: "GlacialIndifference",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: withdrawHistoryModel.note != null && withdrawHistoryModel.note.isNotEmpty && withdrawHistoryModel.adminNote != null && withdrawHistoryModel.adminNote.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Divider(
                            thickness: 2,
                            height: 1,
                            color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      Visibility(
                          visible: withdrawHistoryModel.adminNote != null && withdrawHistoryModel.adminNote.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Admin Note".tr(),
                                  style: TextStyle(fontFamily: "GlacialIndifference",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                  ),
                                ),
                                Opacity(
                                  opacity: 0.75,
                                  child: Text(
                                    withdrawHistoryModel.adminNote,
                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ));
      });
}
