import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/CabService/cab_order_detail_screen.dart';
import 'package:nocdriver/Parcel_service/parcel_order_detail_screen.dart';
import 'package:nocdriver/Parcel_service/parcel_order_model.dart';
import 'package:nocdriver/model/CabOrderModel.dart';
import 'package:nocdriver/model/FlutterWaveSettingDataModel.dart';
import 'package:nocdriver/model/MercadoPagoSettingsModel.dart';
import 'package:nocdriver/model/OrderModel.dart';
import 'package:nocdriver/model/PayFastSettingData.dart';
import 'package:nocdriver/model/PayStackSettingsModel.dart';
import 'package:nocdriver/model/StripePayFailedModel.dart';
import 'package:nocdriver/model/createRazorPayOrderModel.dart';
import 'package:nocdriver/model/getPaytmTxtToken.dart';
import 'package:nocdriver/model/payStackURLModel.dart';
import 'package:nocdriver/model/paypalSettingData.dart';
import 'package:nocdriver/model/paytmSettingData.dart';
import 'package:nocdriver/model/razorpayKeyModel.dart';
import 'package:nocdriver/model/stripeSettingData.dart';
import 'package:nocdriver/model/withdrawHistoryModel.dart';
import 'package:nocdriver/rental_service/model/rental_order_model.dart';
import 'package:nocdriver/rental_service/renatal_summary_screen.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:nocdriver/services/payStackScreen.dart';
import 'package:nocdriver/services/paystack_url_genrater.dart';
import 'package:nocdriver/services/show_toast_dialog.dart';
import 'package:nocdriver/ui/topup/TopUpScreen.dart';
import 'package:nocdriver/ui/wallet/MercadoPagoScreen.dart';
import 'package:nocdriver/ui/wallet/PayFastScreen.dart';
import 'package:nocdriver/userPrefrence.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:flutter_paypal_native/models/custom/currency_code.dart';
import 'package:flutter_paypal_native/models/custom/environment.dart';
import 'package:flutter_paypal_native/models/custom/order_callback.dart';
import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
import 'package:flutter_paypal_native/models/custom/user_action.dart';
import 'package:flutter_paypal_native/str_helper.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../main.dart';
import '../../model/User.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:nocdriver/model/paypalPaymentSettle.dart' as payPalSettel;
import 'package:nocdriver/model/PayPalCurrencyCodeErrorModel.dart'
    as payPalCurrModel;
import 'package:flutterwave_standard/flutterwave.dart';

import 'rozorpayConroller.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? withdrawalHistoryQuery;
  Stream<QuerySnapshot>? dailyEarningQuery;
  Stream<QuerySnapshot>? monthlyEarningQuery;
  Stream<QuerySnapshot>? yearlyEarningQuery;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? userQuery;

  String? selectedRadioTile;

  GlobalKey<FormState> _globalKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _amountController =
      TextEditingController(text: 50.toString());
  TextEditingController _noteController = TextEditingController(text: '');

  getData() async {
    try {
      userQuery = fireStore.collection(USERS).doc(userId).snapshots();
      print(userQuery!.isEmpty);
    } catch (e) {
      print(e);
    }

    /// withdrawal History
    withdrawalHistoryQuery = fireStore
        .collection(driverPayouts)
        .where('driverID', isEqualTo: userId)
        .orderBy('paidDate', descending: true)
        .snapshots();

    DateTime nowDate = DateTime.now();

    if (MyAppState.currentUser!.serviceType == "cab-service") {
      ///earnings History

      dailyEarningQuery = fireStore
          .collection(RIDESORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(nowDate.year, nowDate.month, nowDate.day)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      monthlyEarningQuery = fireStore
          .collection(RIDESORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                nowDate.year,
                nowDate.month,
              )))
          .orderBy('createdAt', descending: true)
          .snapshots();

      yearlyEarningQuery = fireStore
          .collection(RIDESORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                nowDate.year,
              )))
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else if (MyAppState.currentUser!.serviceType == "parcel_delivery") {
      ///earnings History
      dailyEarningQuery = fireStore
          .collection(PARCELORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(nowDate.year, nowDate.month, nowDate.day)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      monthlyEarningQuery = fireStore
          .collection(PARCELORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                nowDate.year,
                nowDate.month,
              )))
          .orderBy('createdAt', descending: true)
          .snapshots();

      yearlyEarningQuery = fireStore
          .collection(PARCELORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                nowDate.year,
              )))
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else if (MyAppState.currentUser!.serviceType == "rental-service") {
      ///earnings History

      dailyEarningQuery = fireStore
          .collection(RENTALORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(nowDate.year, nowDate.month, nowDate.day)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      monthlyEarningQuery = fireStore
          .collection(RENTALORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                nowDate.year,
                nowDate.month,
              )))
          .orderBy('createdAt', descending: true)
          .snapshots();

      yearlyEarningQuery = fireStore
          .collection(RENTALORDER)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                nowDate.year,
              )))
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      ///earnings History

      dailyEarningQuery = fireStore
          .collection(ORDERS)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(nowDate.year, nowDate.month, nowDate.day)))
          .orderBy('createdAt', descending: true)
          .snapshots();

      monthlyEarningQuery = fireStore
          .collection(ORDERS)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                nowDate.year,
                nowDate.month,
              )))
          .orderBy('createdAt', descending: true)
          .snapshots();

      yearlyEarningQuery = fireStore
          .collection(ORDERS)
          .where('driverID', isEqualTo: driverId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                nowDate.year,
              )))
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  Map<String, dynamic>? paymentIntentData;

  showAlert(context, {required String response, required Color colors}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response),
      backgroundColor: colors,
      duration: Duration(seconds: 8),
    ));
  }

  final userId = MyAppState.currentUser!.userID;
  final driverId =
      MyAppState.currentUser!.userID; //'8BBDG88lB4dqRaCcLIhdonuwQtU2';
  UserBankDetails? userBankDetail = MyAppState.currentUser!.userBankDetails;
  String walletAmount = "0.0";

  paymentCompleted({required String paymentMethod}) async {
    await FireStoreUtils.createPaymentId().then((value) async {
      final paymentID = value;
      await FireStoreUtils.topUpWalletAmount(
              paymentMethod: paymentMethod,
              amount: double.parse(_amountController.text),
              id: paymentID,
              userID: MyAppState.currentUser!.userID)
          .then((value) {
        FireStoreUtils.updateWalletAmount(
                userId: userId, amount: double.parse(_amountController.text))
            .then((value) {
          FireStoreUtils.sendTopUpMail(
              paymentMethod: paymentMethod,
              amount: _amountController.text,
              tractionId: paymentID);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text("Payment Successful!!".tr() + "\n"),
            backgroundColor: Colors.green,
          ));
        });
      });
    });
  }

  @override
  void initState() {
    print("here demo");
    print(MyAppState.currentUser!.lastOnlineTimestamp.toDate());

    print(MyAppState.currentUser!.lastOnlineTimestamp
        .toDate()
        .toString()
        .contains(DateTime.now().year.toString()));

    getData();
    getPaymentSettingData();
    selectedRadioTile = "Stripe";

    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // TODO: implement initState
    super.initState();
  }

  Stream<QuerySnapshot>? topupHistoryQuery;
  Razorpay _razorPay = Razorpay();
  RazorPayModel? razorPayData;
  StripeSettingData? stripeData;
  PaytmSettingData? paytmSettingData;
  PaypalSettingData? paypalSettingData;
  PayStackSettingData? payStackSettingData;
  FlutterWaveSettingData? flutterWaveSettingData;
  PayFastSettingData? payFastSettingData;
  MercadoPagoSettingData? mercadoPagoSettingData;

  getPaymentSettingData() async {
    topupHistoryQuery = fireStore
        .collection(Wallet)
        .where('user_id', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
    userQuery = fireStore
        .collection(USERS)
        .doc(MyAppState.currentUser!.userID)
        .snapshots();

    await UserPreference.getStripeData().then((value) async {
      stripeData = value;
      stripe1.Stripe.publishableKey = stripeData!.stripeKey;
      stripe1.Stripe.merchantIdentifier = 'NOC';
      await stripe1.Stripe.instance.applySettings();
    });

    razorPayData = await UserPreference.getRazorPayData();
    paytmSettingData = await UserPreference.getPaytmData();
    paypalSettingData = await UserPreference.getPayPalData();
    payStackSettingData = await UserPreference.getPayStackData();
    flutterWaveSettingData = await UserPreference.getFlutterWaveData();
    payFastSettingData = await UserPreference.getPayFastData();
    mercadoPagoSettingData = await UserPreference.getMercadoPago();
    setRef();
    initPayPal();
  }
  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;
  void initPayPal() async {
    //set debugMode for error logging
    FlutterPaypalNative.isDebugMode = paypalSettingData!.isLive == false ? true : false;
    //initiate payPal plugin
    await _flutterPaypalNativePlugin.init(
      returnUrl: "com.noc.driver://paypalpay",
      clientID: paypalSettingData!.paypalClient,
      payPalEnvironment: paypalSettingData!.isLive == true ? FPayPalEnvironment.live : FPayPalEnvironment.sandbox,
      currencyCode: FPayPalCurrencyCode.usd,
      action: FPayPalUserAction.payNow,
    );

    //call backs for payment
    _flutterPaypalNativePlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          //user canceled the payment
          Navigator.pop(context);
          ShowToastDialog.showToast("Payment canceled");
        },
        onSuccess: (data) {
          //successfully paid
          //remove all items from queue
          Navigator.pop(context);
          _flutterPaypalNativePlugin.removeAllPurchaseItems();
          ShowToastDialog.showToast("Payment Successfully");
          paymentCompleted(paymentMethod: "Paypal");
        },
        onError: (data) {
          //an error occured
          Navigator.pop(context);
          ShowToastDialog.showToast("error: ${data.reason}");
        },
        onShippingChange: (data) {
          //the user updated the shipping address
          Navigator.pop(context);
          ShowToastDialog.showToast("shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.black.withOpacity(0.03),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage("assets/images/earning_bg_@3x.png"))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            "Total Balance".tr(),
                            style: TextStyle(fontFamily: "GlacialIndifference",
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 25.0),
                            child: StreamBuilder<
                                DocumentSnapshot<Map<String, dynamic>>>(
                              stream: userQuery,
                              builder: (context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      asyncSnapshot) {
                                if (asyncSnapshot.hasError) {
                                  return Text(
                                    "error".tr(),
                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  );
                                }
                                if (asyncSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 0.8,
                                            color: Colors.white,
                                            backgroundColor: Colors.transparent,
                                          )));
                                }
                                User userData =
                                    User.fromJson(asyncSnapshot.data!.data()!);
                                walletAmount = userData.walletAmount.toString();
                                return Text(
                                  "${amountShow(amount: userData.walletAmount.toString())}",
                                  style: TextStyle(fontFamily: "GlacialIndifference",
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 28.0, right: 15, left: 15),
                      child: buildTopUpButton(),
                    ),
                  ],
                ),
              ),
            ),
            tabController(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 5),
        child: MyAppState.currentUser!.serviceType == "rental-service" ||
                MyAppState.currentUser!.serviceType == "cab-service"
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton(context, width: 0.32, title: 'WITHDRAW'.tr(),
                      onPress: () {
                    if (MyAppState.currentUser!.userBankDetails.accountNumber
                        .isNotEmpty) {
                      withdrawAmountBottomSheet(context);
                    } else {
                      final snackBar = SnackBar(
                        backgroundColor: Colors.red[400],
                        content: Text(
                          'Please add your Bank Details first'.tr(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }),
                  buildTransButton(context,
                      width: 0.55,
                      title: 'WITHDRAWAL HISTORY'.tr(), onPress: () {
                    if (MyAppState.currentUser!.userBankDetails.accountNumber
                        .isNotEmpty) {
                      withdrawalHistoryBottomSheet(context);
                    } else {
                      final snackBar = SnackBar(
                        backgroundColor: Colors.red[400],
                        content: Text(
                          'Please add your Bank Details first'.tr(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton(context, width: 0.32, title: 'WITHDRAW'.tr(),
                      onPress: () {
                    if (MyAppState.currentUser!.userBankDetails.accountNumber
                        .isNotEmpty) {
                      withdrawAmountBottomSheet(context);
                    } else {
                      final snackBar = SnackBar(
                        backgroundColor: Colors.red[400],
                        content: Text(
                          'Please add your Bank Details first'.tr(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }),
                  buildTransButton(context,
                      width: 0.55,
                      title: 'WITHDRAWAL HISTORY'.tr(), onPress: () {
                    if (MyAppState.currentUser!.userBankDetails.accountNumber
                        .isNotEmpty) {
                      withdrawalHistoryBottomSheet(context);
                    } else {
                      final snackBar = SnackBar(
                        backgroundColor: Colors.red[400],
                        content: Text(
                          'Please add your Bank Details first'.tr(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }),
                ],
              ),
      ),
    );
  }

  Widget buildTopUpButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            topUpBalance();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
              child: Text(
                "TOPUP WALLET".tr(),
                style: TextStyle(fontFamily: "GlacialIndifference",
                    color: Color(DARK_CARD_BG_COLOR),
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TopUpScreen()));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
              child: Text(
                "TOPUP HISTORY".tr(),
                style: TextStyle(fontFamily: "GlacialIndifference",
                    color: Color(DARK_CARD_BG_COLOR),
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool stripe = true;

  bool razorPay = false;
  bool payTm = false;
  bool paypal = false;
  bool payStack = false;
  bool flutterWave = false;
  bool payFast = false;
  bool mercadoPago = false;

  topUpBalance() {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        elevation: 5,
        enableDrag: true,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => Container(
              //height: size.height * 0.85,
              width: size.width,
              height: size.height * 0.95,
              child: Form(
                key: _globalKey,
                autovalidateMode: AutovalidateMode.always,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: "Topup Wallet".tr(),
                                  style: TextStyle(fontFamily: "GlacialIndifference",
                                    fontSize: 20,
                                    color: isDarkMode(context)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5),
                            child: RichText(
                              text: TextSpan(
                                text: "Add Topup Amount".tr(),
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                    fontSize: 16,
                                    color: isDarkMode(context)
                                        ? Colors.white54
                                        : Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 2),
                        child: Card(
                          elevation: 2.0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 8),
                            child: TextFormField(
                              controller: _amountController,
                              style: TextStyle(fontFamily: "GlacialIndifference",
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              //initialValue:"50",
                              maxLines: 1,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "*required Field".tr();
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefix: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 2),
                                  child: Text(
                                    currencyData!.symbol.toString(),
                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                      color: Colors.blueGrey.shade900,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5),
                            child: RichText(
                              text: TextSpan(
                                text: "Select Payment Option".tr(),
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode(context)
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: stripeData?.isEnabled??false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: stripe ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: stripe
                                          ? Color(0xffFFDF00)
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "Stripe",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  flutterWave = false;
                                  stripe = true;
                                  mercadoPago = false;
                                  payFast = false;
                                  payStack = false;
                                  razorPay = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: stripe,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/stripe.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Stripe"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: payStackSettingData?.isEnabled?? false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: payStack ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: payStack
                                          ? Color(COLOR_PRIMARY)
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayStack",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  flutterWave = false;
                                  payStack = true;
                                  mercadoPago = false;
                                  stripe = false;
                                  payFast = false;
                                  razorPay = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: payStack,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/paystack.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("PayStack".tr()),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: flutterWaveSettingData != null &&
                            flutterWaveSettingData!.isEnable,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: flutterWave ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: flutterWave
                                          ? Color(COLOR_PRIMARY)
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "FlutterWave",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  flutterWave = true;
                                  payStack = false;
                                  mercadoPago = false;
                                  payFast = false;
                                  stripe = false;
                                  razorPay = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: flutterWave,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/flutterwave.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("FlutterWave".tr()),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: razorPayData?.isEnabled??false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: razorPay ? 0 : 2,
                            child: RadioListTile(
                              //toggleable: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: razorPay
                                          ? Color(COLOR_PRIMARY)
                                          : Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "RazorPay",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  mercadoPago = false;
                                  flutterWave = false;
                                  stripe = false;
                                  razorPay = true;
                                  payTm = false;
                                  payFast = false;
                                  paypal = false;
                                  payStack = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: razorPay,
                              //selectedRadioTile == "strip" ? true : false,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.0, horizontal: 10),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Image.asset(
                                                "assets/images/razorpay_@3x.png")),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("RazorPay").tr(),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: payFastSettingData != null &&
                            payFastSettingData!.isEnable,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: payFast ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: payFast
                                          ? Color(COLOR_PRIMARY)
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "payFast",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  payFast = true;
                                  stripe = false;
                                  mercadoPago = false;
                                  razorPay = false;
                                  payStack = false;
                                  flutterWave = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: payFast,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/payfast.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Pay Fast"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: paytmSettingData?.isEnabled??false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: payTm ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: payTm
                                          ? Color(COLOR_PRIMARY)
                                          : Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayTm",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  stripe = false;
                                  flutterWave = false;
                                  payTm = true;
                                  mercadoPago = false;
                                  razorPay = false;
                                  paypal = false;
                                  payFast = false;
                                  payStack = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: payTm,
                              //selectedRadioTile == "strip" ? true : false,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.0, horizontal: 10),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Image.asset(
                                                "assets/images/paytm_@3x.png",
                                              ),
                                            )),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Paytm"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: mercadoPagoSettingData != null &&
                            mercadoPagoSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: mercadoPago ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: mercadoPago
                                          ? Color(COLOR_PRIMARY)
                                          : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "MercadoPago",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  mercadoPago = true;
                                  payFast = false;
                                  stripe = false;
                                  razorPay = false;
                                  payStack = false;
                                  flutterWave = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: mercadoPago,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/mercadopago.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Mercado Pago"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: paypalSettingData != null &&
                            paypalSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: paypal ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: paypal
                                          ? Color(COLOR_PRIMARY)
                                          : Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayPal",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  stripe = false;
                                  payTm = false;
                                  mercadoPago = false;
                                  flutterWave = false;
                                  razorPay = false;
                                  paypal = true;
                                  payFast = false;
                                  payStack = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: paypal,
                              //selectedRadioTile == "strip" ? true : false,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.0, horizontal: 10),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Image.asset(
                                                  "assets/images/paypal_@3x.png"),
                                            )),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("PayPal"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 22),
                        child: GestureDetector(
                          onTap: () async {
                            await FireStoreUtils.createPaymentId();

                            if (selectedRadioTile == "Stripe" &&
                                stripeData?.isEnabled == true) {
                              showLoadingAlert();
                              Navigator.pop(context);
                              stripeMakePayment(amount: _amountController.text);
                              // push(context, CardDetailsScreen(paymentMode: selectedRadioTile,),);
                            } else if (selectedRadioTile == "MercadoPago") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              mercadoPagoMakePayment();
                            } else if (selectedRadioTile == "payFast") {
                              showLoadingAlert();
                              PayStackURLGen.getPayHTML(
                                      payFastSettingData: payFastSettingData!,
                                      amount: _amountController.text)
                                  .then((value) async {
                                bool isDone = await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => PayFastScreen(
                                              htmlData: value,
                                              payFastSettingData:
                                                  payFastSettingData!,
                                            )));
                                if (isDone) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  paymentCompleted(paymentMethod: "payFast");
                                } else {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      "Payment Unsuccessful!!".tr() + "\n",
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                    duration: Duration(seconds: 6),
                                  ));
                                }
                              });
                            } else if (selectedRadioTile == "RazorPay") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              RazorPayController()
                                  .createOrderRazorPay(
                                      amount: int.parse(_amountController.text))
                                  .then((value) {
                                if (value != null) {
                                  CreateRazorPayOrderModel result = value;
                                  print("RAZORPAY");
                                  print(value);

                                  openCheckout(
                                    amount: _amountController.text,
                                    orderId: result.id,
                                  );
                                } else {
                                  Navigator.pop(context);
                                  showAlert(_globalKey.currentContext!,
                                      response:
                                          "Something went wrong, please contact admin."
                                              .tr(),
                                      colors: Colors.red);
                                }
                              });
                            } else if (selectedRadioTile == "PayTm") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              getPaytmCheckSum(context,
                                  amount: double.parse(_amountController.text));
                            } else if (selectedRadioTile == "PayPal") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              //_paypalPayment();
                              paypalPaymentSheet();
                            } else if (selectedRadioTile == "PayStack") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              payStackPayment();
                            } else if (selectedRadioTile == "FlutterWave") {
                              _flutterWaveInitiatePayment(context);
                            }
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Color(0xffFFDF00),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                                child: Text(
                              "CONTINUE".tr(),
                              style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  ///FlutterWave Payment Method
  String? _ref;

  setRef() {
    Random numRef = Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      setState(() {
        _ref = "AndroidRef$year$refNumber";
      });
    } else if (Platform.isIOS) {
      setState(() {
        _ref = "IOSRef$year$refNumber";
      });
    }
  }

  _flutterWaveInitiatePayment(
    BuildContext context,
  ) async {
    final style = FlutterwaveStyle(
      appBarText: "Foodie Driver",
      buttonColor: Color(COLOR_PRIMARY),
      buttonTextStyle: TextStyle(fontFamily: "GlacialIndifference",
        color: Colors.white,
        fontSize: 20,
      ),
      appBarColor: Color(COLOR_PRIMARY),
      dialogCancelTextStyle: TextStyle(fontFamily: "GlacialIndifference",
        color: Colors.black,
        fontSize: 18,
      ),
      dialogContinueTextStyle: TextStyle(fontFamily: "GlacialIndifference",
        color: Color(COLOR_PRIMARY),
        fontSize: 18,
      ),
      mainTextStyle:
          TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 19, letterSpacing: 2),
      dialogBackgroundColor: Colors.white,
      appBarTitleTextStyle: TextStyle(fontFamily: "GlacialIndifference",
        color: Colors.white,
        fontSize: 18,
      ),
    );
    final flutterwave = Flutterwave(
      amount: _amountController.text.toString().trim(),
      currency: currencyData!.code,
      style: style,
      customer: Customer(
          name: MyAppState.currentUser!.firstName,
          phoneNumber: MyAppState.currentUser!.phoneNumber.trim(),
          email: MyAppState.currentUser!.email.trim()),
      context: context,
      publicKey: flutterWaveSettingData!.publicKey.trim(),
      paymentOptions: "card, payattitude",
      customization: Customization(title: "Foodies"),
      txRef: _ref!,
      redirectUrl: '${GlobalURL}success',
      isTestMode: flutterWaveSettingData!.isSandbox,
    );
    final ChargeResponse response = await flutterwave.charge();
    if (response.toString().isNotEmpty) {
      if (response.success!) {
        Navigator.pop(_scaffoldKey.currentContext!);
        paymentCompleted(paymentMethod: "FlutterWave");
      } else {
        this.showLoading(message: response.status!);
      }
      print("${response.toJson()}");
    } else {
      this.showLoading(message: "No Response!".tr(), txtColor: Colors.red);
    }
  }

  Future<void> showLoading(
      {required String message, Color txtColor = Colors.black}) {
    return showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 30,
            child: Text(
              message,
              style: TextStyle(fontFamily: "GlacialIndifference",color: txtColor),
            ),
          ),
        );
      },
    );
  }

  ///PayStack Payment Method
  payStackPayment() async {
    await PayStackURLGen.payStackURLGen(
      amount: (double.parse(_amountController.text) * 100).toString(),
      currency: currencyData!.code,
      secretKey: payStackSettingData!.secretKey,
    ).then((value) async {
      if (value != null) {
        PayStackUrlModel _payStackModel = value;

        bool isDone = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PayStackScreen(
                  secretKey: payStackSettingData!.secretKey,
                  callBackUrl: payStackSettingData!.callbackURL,
                  initialURl: _payStackModel.data.authorizationUrl,
                  amount: _amountController.text,
                  reference: _payStackModel.data.reference,
                )));
        Navigator.pop(_scaffoldKey.currentContext!);

        if (isDone) {
          paymentCompleted(paymentMethod: "PayStack");
        } else {
          hideProgress();
          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        hideProgress();

        ScaffoldMessenger.of(_scaffoldKey.currentContext!)
            .showSnackBar(SnackBar(
          content: Text("Error while transaction!".tr() + "\n"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  /// PayPal Payment Gateway

  paypalPaymentSheet() {
    //add 1 item to cart. Max is 4!
    if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
      _flutterPaypalNativePlugin.addPurchaseUnit(
        FPayPalPurchaseUnit(
          // random prices
          amount: double.parse(_amountController.text),

          ///please use your own algorithm for referenceId. Maybe ProductID?
          referenceId: FPayPalStrHelper.getRandomString(16),
        ),
      );
    }
    // initPayPal();
    _flutterPaypalNativePlugin.makeOrder(
      action: FPayPalUserAction.payNow,
    );
  }

  // _paypalPayment() async {
  //   PayPalClientTokenGen.paypalClientToken(
  //           paypalSettingData: paypalSettingData!)
  //       .then((value) async {
  //     final String tokenizationKey = paypalSettingData!
  //         .braintreeTokenizationKey; //"sandbox_w3dpbsks_5whrtf2sbrp4vx74";
  //
  //     var request = BraintreePayPalRequest(
  //         amount: _amountController.text,
  //         currencyCode: currencyData!.code,
  //         billingAgreementDescription: "djsghxghf",
  //         displayName: 'Foodies company');
  //
  //     BraintreePaymentMethodNonce? resultData;
  //
  //     try {
  //       resultData =
  //           await Braintree.requestPaypalNonce(tokenizationKey, request);
  //     } on Exception catch (ex) {
  //       print("Stripe error");
  //       showAlert(context,
  //           response:
  //               "Something went wrong, please contact admin.".tr() + " $ex",
  //           colors: Colors.red);
  //     }
  //     print(resultData?.nonce);
  //     print(resultData?.paypalPayerId);
  //     if (resultData?.nonce != null) {
  //       PayPalClientTokenGen.paypalSettleAmount(
  //         paypalSettingData: paypalSettingData!,
  //         nonceFromTheClient: resultData?.nonce,
  //         amount: _amountController.text,
  //         deviceDataFromTheClient: resultData?.typeLabel,
  //       ).then((value) {
  //         if (value['success'] == "true" || value['success'] == true) {
  //           if (value['data']['success'] == "true" ||
  //               value['data']['success'] == true) {
  //             payPalSettel.PayPalClientSettleModel settleResult =
  //                 payPalSettel.PayPalClientSettleModel.fromJson(value);
  //             if (settleResult.data.success) {
  //               Navigator.pop(context);
  //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                 content: Text(
  //                   "Status : ${settleResult.data.transaction.status}\n"
  //                   "Transaction id : ${settleResult.data.transaction.id}\n"
  //                   "Amount : ${settleResult.data.transaction.amount}",
  //                 ),
  //                 duration: Duration(seconds: 8),
  //                 backgroundColor: Colors.green,
  //               ));
  //
  //               paymentCompleted(paymentMethod: "Paypal");
  //             }
  //           } else {
  //             payPalCurrModel.PayPalCurrencyCodeErrorModel settleResult =
  //                 payPalCurrModel.PayPalCurrencyCodeErrorModel.fromJson(value);
  //             Navigator.pop(_scaffoldKey.currentContext!);
  //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //               content:
  //                   Text("Status :".tr() + " ${settleResult.data.message}"),
  //               duration: Duration(seconds: 8),
  //               backgroundColor: Colors.red,
  //             ));
  //           }
  //         } else {
  //           PayPalErrorSettleModel settleResult =
  //               PayPalErrorSettleModel.fromJson(value);
  //           Navigator.pop(_scaffoldKey.currentContext!);
  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //             content: Text("Status :".tr() + " ${settleResult.data.message}"),
  //             duration: Duration(seconds: 8),
  //             backgroundColor: Colors.red,
  //           ));
  //         }
  //       });
  //     } else {
  //       Navigator.pop(_scaffoldKey.currentContext!);
  //       ScaffoldMessenger.of(_scaffoldKey.currentContext!)
  //           .showSnackBar(SnackBar(
  //         content: Text('Status : Payment Incomplete!!'.tr()),
  //         duration: Duration(seconds: 8),
  //         backgroundColor: Colors.red,
  //       ));
  //     }
  //   });
  // }

  /// Stripe Payment Gateway
  Future<void> stripeMakePayment({required String amount}) async {
    try {
      paymentIntentData = await createStripeIntent(
        amount,
      );
      print("payment intent: $paymentIntentData");
      if (paymentIntentData!.containsKey("error")) {
        Navigator.pop(context);
        showAlert(_scaffoldKey.currentContext,
            response: "Something went wrong, please contact admin.".tr(),
            colors: Colors.red);
      } else {
        await stripe1.Stripe.instance
            .initPaymentSheet(
            paymentSheetParameters: stripe1.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: const stripe1.PaymentSheetApplePay(
                merchantCountryCode: 'US',
              ),
              allowsDelayedPaymentMethods: false,
              googlePay: stripe1.PaymentSheetGooglePay(
                merchantCountryCode: 'US',
                testEnv: true,
                currencyCode: currencyData!.code,
              ),
              style: ThemeMode.system,
              customFlow: false,
              appearance: stripe1.PaymentSheetAppearance(
                colors: stripe1.PaymentSheetAppearanceColors(
                  primary: Color(COLOR_PRIMARY),
                ),
                primaryButton: stripe1.PaymentSheetPrimaryButtonAppearance(
                  shapes: stripe1.PaymentSheetPrimaryButtonShape(blurRadius: 8),
                  colors: stripe1.PaymentSheetPrimaryButtonTheme(
                    light: stripe1.PaymentSheetPrimaryButtonThemeColors(
                      background: Colors.yellow,
                      text: Colors.black,
                      border: Colors.yellow,
                    ),
                    dark: stripe1.PaymentSheetPrimaryButtonThemeColors(
                      background: Colors.yellow,
                      text: Colors.black,
                      border: Colors.yellow,
                    ),
                  ),
                ),
              ),
              merchantDisplayName: 'NOC',
            ))
            .then((value) {});
        setState(() {});
        displayStripePaymentSheet();
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayStripePaymentSheet() async {
    try {
      await stripe1.Stripe.instance.presentPaymentSheet().then((value) {
        paymentCompleted(paymentMethod: "Stripe");
        Navigator.pop(context);
        paymentIntentData = null;
      });
    } on stripe1.StripeException catch (e) {
      Navigator.pop(context);
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text("${lom.error.message}"),
          ));
    } catch (e) {
      print('$e');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$e"),
        duration: Duration(seconds: 8),
        backgroundColor: Colors.red,
      ));
    }
  }

  createStripeIntent(
    String amount,
  ) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currencyData!.code,
        'payment_method_types[0]': 'card',
        // 'payment_method_types[1]': 'ideal',
        "description": "${MyAppState.currentUser?.userID} Wallet Topup",
        "shipping[name]":
            "${MyAppState.currentUser?.firstName} ${MyAppState.currentUser?.lastName}",
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ${stripeData?.stripeSecret}',
            //$_paymentIntentClientSecret',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print("RESP===============${response.body}");
      return jsonDecode(response.body);
      print("RESP===============${response.body}");
    } catch (err) {
      print('error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  /// RazorPay Payment Gateway
  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': razorPayData!.razorpayKey,
      'amount': amount * 100,
      'name': 'Foodies',
      'order_id': orderId,
      "currency": currencyData?.code,
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': MyAppState.currentUser!.phoneNumber,
        'email': MyAppState.currentUser!.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorPay.open(options);
    } catch (e) {
      debugPrint('error'.tr() + ': $e');
    }
  }

  ///MercadoPago Payment Method

  mercadoPagoMakePayment() {
    makePreference().then((result) async {
      if (result.isNotEmpty) {
        var preferenceId = result['response']['id'];

        final bool isDone = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MercadoPagoScreen(
                    initialURl: result['response']['init_point'])));
        print(isDone);
        print(result.toString());
        print(preferenceId);

        if (isDone) {
          paymentCompleted(paymentMethod: "MercadoPago");
        } else {
          Navigator.pop(_scaffoldKey.currentContext!);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        hideProgress();

        ScaffoldMessenger.of(_scaffoldKey.currentContext!)
            .showSnackBar(SnackBar(
          content: Text("Error while transaction!".tr() + "\n"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  Future<Map<String, dynamic>> makePreference() async {
    final mp = MP.fromAccessToken(mercadoPagoSettingData!.accessToken);
    var pref = {
      "items": [
        {
          "title": "Wallet TopUp",
          "quantity": 1,
          "unit_price": double.parse(_amountController.text)
        }
      ],
      "auto_return": "all",
      "back_urls": {
        "failure": "${GlobalURL}payment/failure",
        "pending": "${GlobalURL}payment/pending",
        "success": "${GlobalURL}payment/success"
      },
    };

    var result = await mp.createPreference(pref);
    return result;
  }

  /// Paytm Payment Gateway
  bool isStaging = true;
  String callbackUrl =
      "http://162.241.125.167/~foodie/payments/paytmpaymentcallback?ORDER_ID=";
  bool restrictAppInvoke = false;
  bool enableAssist = true;
  String result = "";

  getPaytmCheckSum(
    context, {
    required double amount,
  }) async {
    final String orderId = UserPreference.getPaymentId();
    String getChecksum = "${GlobalURL}payments/getpaytmchecksum";

    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.paytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.paytmMerchantKey,
        });

    final data = jsonDecode(response.body);

    await verifyCheckSum(
            checkSum: data["code"], amount: amount, orderId: orderId)
        .then((value) {
      initiatePayment(context, amount: amount, orderId: orderId).then((value) {
        GetPaymentTxtTokenModel result = value;
        String callback = "";
        if (paytmSettingData!.isSandboxEnabled) {
          callback = callback +
              "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        } else {
          callback = callback +
              "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        }

        _startTransaction(
          context,
          txnTokenBy: result.body.txnToken,
          orderId: orderId,
          amount: amount,
        );
      });
    });
  }

  Future<GetPaymentTxtTokenModel> initiatePayment(BuildContext context,
      {required double amount, required orderId}) async {
    String initiateURL = "${GlobalURL}payments/initiatepaytmpayment";
    String callback = "";
    if (paytmSettingData!.isSandboxEnabled) {
      callback = callback +
          "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback = callback +
          "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response = await http.post(
        Uri.parse(
          initiateURL,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.paytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.paytmMerchantKey.toString(),
          "amount": amount.toString(),
          "currency": currencyData!.code,
          "callback_url": callback,
          "custId": MyAppState.currentUser!.userID,
          "issandbox": paytmSettingData!.isSandboxEnabled ? "1" : "2",
        });
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null ||
        data["body"]["txnToken"].toString().isEmpty) {
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!,
          response: "something went wrong, please contact admin.".tr(),
          colors: Colors.red);
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  Future<void> _startTransaction(
    context, {
    required String txnTokenBy,
    required orderId,
    required double amount,
  }) async {
    try {
      var response = AllInOneSdk.startTransaction(
        paytmSettingData!.paytmMID,
        orderId,
        amount.toString(),
        txnTokenBy,
        "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId",
        isStaging,
        true,
        enableAssist,
      );

      response.then((value) {
        if (value!["RESPMSG"] == "Txn Success") {
          paymentCompleted(paymentMethod: "Paytm");
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          Navigator.pop(_scaffoldKey.currentContext!);

          result =
              onError.message.toString() + " \n  " + onError.code.toString();
          showAlert(_scaffoldKey.currentContext!,
              response: onError.message.toString(), colors: Colors.red);
        } else {
          result = onError.toString();
          Navigator.pop(_scaffoldKey.currentContext!);
          showAlert(_scaffoldKey.currentContext!,
              response: result, colors: Colors.red);
        }
      });
    } catch (err) {
      result = err.toString();
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!,
          response: result, colors: Colors.red);
    }
  }

  Future verifyCheckSum(
      {required String checkSum,
      required double amount,
      required orderId}) async {
    String getChecksum = "${GlobalURL}payments/validatechecksum";
    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.paytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.paytmMerchantKey,
          "checksum_value": checkSum,
        });
    final data = jsonDecode(response.body);
    return data['status'];
  }

  tabController() {
    return Expanded(
      child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  height: 40,
                  child: TabBar(
                    //indicator: BoxDecoration(color: const Color(COLOR_PRIMARY), borderRadius: BorderRadius.circular(2.0)),
                    indicatorColor: Color(COLOR_PRIMARY),
                    labelColor: Color(COLOR_PRIMARY),
                    automaticIndicatorColorAdjustment: true,
                    dragStartBehavior: DragStartBehavior.start,
                    unselectedLabelColor:
                        isDarkMode(context) ? Colors.white70 : Colors.black54,
                    indicatorWeight: 1.5,
                    //indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                    enableFeedback: true,
                    //unselectedLabelColor: const Colors,
                    tabs: [
                      Tab(text: 'Daily'.tr()),
                      Tab(
                        text: 'Monthly'.tr(),
                      ),
                      Tab(
                        text: 'Yearly'.tr(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: TabBarView(
                    children: [
                      showEarningsHistory(context, query: dailyEarningQuery),
                      showEarningsHistory(context, query: monthlyEarningQuery),
                      showEarningsHistory(context, query: yearlyEarningQuery),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget showEarningsHistory(BuildContext context,
      {required Stream<QuerySnapshot>? query}) {
    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
                  height: 35, width: 35, child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return ListView(
            shrinkWrap: true,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final earningData;
              print("-------->" + MyAppState.currentUser!.serviceType);
              if (MyAppState.currentUser!.serviceType == "cab-service") {
                earningData = CabOrderModel.fromJson(
                    document.data() as Map<String, dynamic>);
              } else if (MyAppState.currentUser!.serviceType ==
                  "parcel_delivery") {
                earningData = ParcelOrderModel.fromJson(
                    document.data() as Map<String, dynamic>);
              } else if (MyAppState.currentUser!.serviceType ==
                  "rental-service") {
                earningData = RentalOrderModel.fromJson(
                    document.data() as Map<String, dynamic>);
              } else {
                earningData = OrderModel.fromJson(
                    document.data() as Map<String, dynamic>);
              }

              return buildEarningCard(
                orderModel: earningData,
              );
            }).toList(),
          );
        } else {
          return Center(
              child: Text(
            "No Transaction History".tr(),
            style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 18),
          ));
        }
      },
    );
  }

  Widget buildEarningCard({required var orderModel}) {
    final size = MediaQuery.of(context).size;
    double amount = 0;
    double adminComm = 0.0;
    if (MyAppState.currentUser!.serviceType == "cab-service") {
      double totalTax = 0.0;

      /*  if (orderModel.taxType!.isNotEmpty) {
        if (orderModel.taxType == "percent") {
          totalTax = (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())) * double.parse(orderModel.tax.toString()) / 100;
        } else {
          totalTax = double.parse(orderModel.tax.toString());
        }
      }*/
      if (orderModel!.taxModel != null) {
        for (var element in orderModel!.taxModel!) {
          totalTax = totalTax +
              calculateTax(
                  amount: (double.parse(orderModel.subTotal.toString()) -
                          double.parse(orderModel.discount.toString()))
                      .toString(),
                  taxModel: element);
        }
      }
      print(totalTax);
      double subTotal = double.parse(orderModel.subTotal.toString()) -
          double.parse(orderModel.discount.toString());
      // double adminComm = 0.0;
      if (orderModel.adminCommission!.isNotEmpty) {
        adminComm = (orderModel.adminCommissionType == 'Percent')
            ? (subTotal * double.parse(orderModel.adminCommission!)) / 100
            : double.parse(orderModel.adminCommission!);
      }

      print("--->finalAmount---- $subTotal");
      double tipValue = orderModel.tipValue!.isEmpty
          ? 0.0
          : double.parse(orderModel.tipValue.toString());
      // if (orderModel.paymentMethod.toLowerCase() != "cod") {
      //   amount = subTotal + totalTax + tipValue + adminComm;
      // } else {
      //   amount = -(subTotal + totalTax + tipValue + adminComm);
      // }
      amount = subTotal + totalTax + tipValue;
      adminComm = adminComm;
    } else if (MyAppState.currentUser!.serviceType == "parcel_delivery") {
      double totalTax = 0.0;

      /* if (orderModel.taxType!.isNotEmpty) {
        if (orderModel.taxType == "percent") {
          totalTax = (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())) * double.parse(orderModel.tax.toString()) / 100;
        } else {
          totalTax = double.parse(orderModel.tax.toString());
        }
      */
      if (orderModel!.taxModel != null) {
        for (var element in orderModel!.taxModel!) {
          totalTax = totalTax +
              calculateTax(
                  amount: (double.parse(orderModel.subTotal.toString()) -
                          double.parse(orderModel.discount.toString()))
                      .toString(),
                  taxModel: element);
        }
      }
      double subTotal = double.parse(orderModel.subTotal.toString()) -
          double.parse(orderModel.discount.toString());
      // double adminComm = 0.0;
      if (orderModel.adminCommission!.isNotEmpty) {
        adminComm = (orderModel.adminCommissionType == 'Percent')
            ? (subTotal * double.parse(orderModel.adminCommission!)) / 100
            : double.parse(orderModel.adminCommission!);
      }

      print("--->finalAmount---- $subTotal");
      // if (orderModel.paymentMethod.toLowerCase() != "cod") {
      //   amount = subTotal + totalTax + adminComm;
      // } else {
      //   amount = -(subTotal + totalTax + adminComm);
      // }
      amount = subTotal + totalTax;
      adminComm = adminComm;
    } else if (MyAppState.currentUser!.serviceType == "rental-service") {
      double totalTax = 0.0;
      double subTotal = (double.parse(orderModel.subTotal.toString()) +
              double.parse(orderModel.driverRate.toString())) -
          double.parse(orderModel.discount.toString());

      /*if (orderModel.taxType!.isNotEmpty) {
        if (orderModel.taxType == "percent") {
          totalTax = subTotal * double.parse(orderModel.tax.toString()) / 100;
        } else {
          totalTax = double.parse(orderModel.tax.toString());
        }
      }*/
      if (orderModel!.taxModel != null) {
        for (var element in orderModel!.taxModel!) {
          totalTax = totalTax +
              calculateTax(amount: (subTotal.toString()), taxModel: element);
        }
      }
      // double adminComm = 0.0;
      if (orderModel.adminCommission!.isNotEmpty) {
        adminComm = (orderModel.adminCommissionType == 'Percent')
            ? (subTotal * double.parse(orderModel.adminCommission!)) / 100
            : double.parse(orderModel.adminCommission!);
      }

      /*if (orderModel.paymentMethod.toLowerCase() != "cod") {
        amount = subTotal + totalTax + adminComm;
      } else {
        amount = -(subTotal + totalTax + adminComm);
      }*/

      amount = subTotal + totalTax;
      adminComm = adminComm;
    } else {
      if (orderModel.deliveryCharge != null &&
          orderModel.deliveryCharge!.isNotEmpty) {
        amount += double.parse(orderModel.deliveryCharge!);
      }

      if (orderModel.tipValue != null && orderModel.tipValue!.isNotEmpty) {
        amount += double.parse(orderModel.tipValue!);
      }
    }
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
        child: MyAppState.currentUser!.serviceType == "delivery-service"
            ? Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width * 0.52,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${DateFormat('dd-MM-yyyy, KK:mma').format(orderModel.createdAt.toDate()).toUpperCase()}",
                              style: TextStyle(fontFamily: "GlacialIndifference",
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Opacity(
                              opacity: 0.75,
                              child: Text(
                                orderModel.status,
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: orderModel.status == "Order Completed"
                                      ? Colors.green
                                      : Colors.deepOrangeAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              " ${amountShow(amount: amount.toString())}",
                              style: TextStyle(fontFamily: "GlacialIndifference",
                                fontWeight: FontWeight.w600,
                                color: orderModel.status == "Order Completed"
                                    ? amount < 0
                                        ? Colors.red
                                        : Colors.green
                                    : Colors.deepOrange,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // Icon(
                            //   Icons.arrow_forward_ios,
                            //   size: 15,
                            // )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: () => showTransactionDetails(orderModel: orderModel),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 2.0, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Container(
                            color: Color(COLOR_PRIMARY).withOpacity(0.06),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(Icons.account_balance_wallet_rounded,
                                  size: 28, color: Color(COLOR_PRIMARY)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.78,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: size.width * 0.48,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order Amount".tr(),
                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Admin commission Deducted".tr(),
                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Opacity(
                                      opacity: 0.65,
                                      child: Text(
                                        "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(orderModel.createdAt.toDate()).toUpperCase()}",
                                        style: TextStyle(fontFamily: "GlacialIndifference",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 4.0, left: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      // "(${orderModel.paymentMethod.toLowerCase() != "cod" ? "+" : "-"} ${amountShow(amount: amount.toString())})",
                                      orderModel.paymentMethod.toLowerCase() !=
                                              "cod"
                                          ? "${"+"} ${amountShow(amount: amount.toString())}"
                                          : "(${amountShow(amount: amount.toString())})",

                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontWeight: FontWeight.w600,
                                        color: orderModel.paymentMethod
                                                    .toLowerCase() !=
                                                "cod"
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      //  "${orderModel.paymentMethod.toLowerCase() != "cod" ? "+" : "-"} ${amountShow(amount: adminComm.toString())}",
                                      "(-${amountShow(amount: adminComm.toString())})",
                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 15,
                                    )
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
              ));
  }

  showTransactionDetails({
    required orderModel,
  }) {
    double amount = 0;
    double adminComm = 0.0;
    if (MyAppState.currentUser!.serviceType == "cab-service") {
      double totalTax = 0.0;
      if (orderModel!.taxModel != null) {
        for (var element in orderModel!.taxModel!) {
          totalTax = totalTax +
              calculateTax(
                  amount: (double.parse(orderModel.subTotal.toString()) -
                          double.parse(orderModel.discount.toString()))
                      .toString(),
                  taxModel: element);
        }
      }
      print(totalTax);
      double subTotal = double.parse(orderModel.subTotal.toString()) -
          double.parse(orderModel.discount.toString());
      // double adminComm = 0.0;
      if (orderModel.adminCommission!.isNotEmpty) {
        adminComm = (orderModel.adminCommissionType == 'Percent')
            ? (subTotal * double.parse(orderModel.adminCommission!)) / 100
            : double.parse(orderModel.adminCommission!);
      }

      print("--->finalAmount---- $subTotal");
      double tipValue = orderModel.tipValue!.isEmpty
          ? 0.0
          : double.parse(orderModel.tipValue.toString());

      amount = subTotal + totalTax + tipValue;
      adminComm = adminComm;
    } else if (MyAppState.currentUser!.serviceType == "parcel_delivery") {
      double totalTax = 0.0;
      if (orderModel!.taxModel != null) {
        for (var element in orderModel!.taxModel!) {
          totalTax = totalTax +
              calculateTax(
                  amount: (double.parse(orderModel.subTotal.toString()) -
                          double.parse(orderModel.discount.toString()))
                      .toString(),
                  taxModel: element);
        }
      }
      double subTotal = double.parse(orderModel.subTotal.toString()) -
          double.parse(orderModel.discount.toString());
      // double adminComm = 0.0;
      if (orderModel.adminCommission!.isNotEmpty) {
        adminComm = (orderModel.adminCommissionType == 'Percent')
            ? (subTotal * double.parse(orderModel.adminCommission!)) / 100
            : double.parse(orderModel.adminCommission!);
      }

      amount = subTotal + totalTax;
      adminComm = adminComm;
    } else if (MyAppState.currentUser!.serviceType == "rental-service") {
      double totalTax = 0.0;
      double subTotal = (double.parse(orderModel.subTotal.toString()) +
              double.parse(orderModel.driverRate.toString())) -
          double.parse(orderModel.discount.toString());

      if (orderModel!.taxModel != null) {
        for (var element in orderModel!.taxModel!) {
          totalTax = totalTax +
              calculateTax(amount: (subTotal.toString()), taxModel: element);
        }
      }
      if (orderModel.adminCommission!.isNotEmpty) {
        adminComm = (orderModel.adminCommissionType == 'Percent')
            ? (subTotal * double.parse(orderModel.adminCommission!)) / 100
            : double.parse(orderModel.adminCommission!);
      }

      amount = subTotal + totalTax;
      adminComm = adminComm;
    }
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Text(
                    "Transaction Details".tr(),
                    style: TextStyle(fontFamily: "GlacialIndifference",
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Transaction ID".tr(),
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Opacity(
                                opacity: 0.8,
                                child: Text(
                                  orderModel.id,
                                  style: TextStyle(fontFamily: "GlacialIndifference",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 30),
                    child: Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Container(
                                color: Color(COLOR_PRIMARY).withOpacity(0.05),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                      Icons.account_balance_wallet_rounded,
                                      size: 28,
                                      color: Color(COLOR_PRIMARY)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.70,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.40,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Order Amount".tr(),
                                          style: TextStyle(fontFamily: "GlacialIndifference",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Admin commission Deducted".tr(),
                                          style: TextStyle(fontFamily: "GlacialIndifference",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Opacity(
                                          opacity: 0.65,
                                          child: Text(
                                            "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(orderModel.createdAt.toDate()).toUpperCase()}",
                                            style: TextStyle(fontFamily: "GlacialIndifference",
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 4.0, left: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                       //   "(${orderModel.paymentMethod.toLowerCase() != "cod" ? "+" : "-"} ${amountShow(amount: amount.toString())})",
                                          orderModel.paymentMethod.toLowerCase() !=
                                              "cod"
                                              ? "${"+"} ${amountShow(amount: amount.toString())}"
                                              : "(${"-"} ${amountShow(amount: amount.toString())})",
                                          style: TextStyle(fontFamily: "GlacialIndifference",
                                            fontWeight: FontWeight.w600,
                                            color: orderModel.paymentMethod
                                                        .toLowerCase() !=
                                                    "cod"
                                                ? Colors.green
                                                : Colors.red,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          "(-${amountShow(amount: adminComm.toString())})",
                                          style: TextStyle(fontFamily: "GlacialIndifference",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
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
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Date in UTC Format".tr(),
                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Opacity(
                                      opacity: 0.7,
                                      child: Text(
                                        "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(orderModel.createdAt.toDate()).toUpperCase()}",
                                        style: TextStyle(fontFamily: "GlacialIndifference",
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (MyAppState.currentUser!.serviceType ==
                                "cab-service") {
                              await FireStoreUtils.firestore
                                  .collection(RIDESORDER)
                                  .doc(orderModel.id)
                                  .get()
                                  .then((value) {
                                CabOrderModel orderModel =
                                    CabOrderModel.fromJson(value.data()!);
                                push(
                                    context,
                                    CabOrderDetailScreen(
                                      orderModel: orderModel,
                                    ));
                              });
                            } else if (MyAppState.currentUser!.serviceType ==
                                "parcel_delivery") {
                              await FireStoreUtils.firestore
                                  .collection(PARCELORDER)
                                  .doc(orderModel.id)
                                  .get()
                                  .then((value) {
                                ParcelOrderModel orderModel =
                                    ParcelOrderModel.fromJson(value.data()!);
                                push(
                                    context,
                                    ParcelOrderDetailScreen(
                                      orderModel: orderModel,
                                    ));
                              });
                            } else if (MyAppState.currentUser!.serviceType ==
                                "rental-service") {
                              await FireStoreUtils.firestore
                                  .collection(RENTALORDER)
                                  .doc(orderModel.id)
                                  .get()
                                  .then((value) {
                                RentalOrderModel orderModel =
                                    RentalOrderModel.fromJson(value.data()!);
                                push(
                                    context,
                                    RenatalSummaryScreen(
                                      rentalOrderModel: orderModel,
                                    ));
                              });
                            }
                          },
                          child: Text(
                            "View Order".tr().toUpperCase(),
                            style: TextStyle(fontFamily: "GlacialIndifference",
                              fontWeight: FontWeight.w600,
                              color: Color(COLOR_PRIMARY),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            );
          });
        });
  }

  // Widget buildEarningCard({required var orderModel}) {
  //   final size = MediaQuery.of(context).size;
  //   double amount = 0;
  //   if (MyAppState.currentUser!.serviceType == "cab-service") {
  //     double totalTax = 0.0;
  //
  //   /*  if (orderModel.taxType!.isNotEmpty) {
  //       if (orderModel.taxType == "percent") {
  //         totalTax = (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())) * double.parse(orderModel.tax.toString()) / 100;
  //       } else {
  //         totalTax = double.parse(orderModel.tax.toString());
  //       }
  //     }*/
  //     if (orderModel!.taxModel != null) {
  //       for (var element in orderModel!.taxModel!) {
  //         totalTax = totalTax + calculateTax(amount: (double.parse(orderModel.subTotal.toString()) -
  //             double.parse(orderModel.discount.toString())).toString(),
  //             taxModel: element);
  //       }
  //     }
  //     print(totalTax);
  //     double subTotal = double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString());
  //     double adminComm = 0.0;
  //     if (orderModel.adminCommission!.isNotEmpty) {
  //       adminComm = (orderModel.adminCommissionType == 'Percent') ? (subTotal * double.parse(orderModel.adminCommission!)) / 100 : double.parse(orderModel.adminCommission!);
  //     }
  //
  //     print("--->finalAmount---- $subTotal");
  //     double tipValue = orderModel.tipValue!.isEmpty ? 0.0 : double.parse(orderModel.tipValue.toString());
  //     if (orderModel.paymentMethod.toLowerCase() != "cod") {
  //       amount = subTotal + totalTax + tipValue + adminComm;
  //     } else {
  //       amount = -(subTotal + totalTax + tipValue + adminComm);
  //     }
  //   } else if (MyAppState.currentUser!.serviceType == "parcel_delivery") {
  //     double totalTax = 0.0;
  //
  //    /* if (orderModel.taxType!.isNotEmpty) {
  //       if (orderModel.taxType == "percent") {
  //         totalTax = (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())) * double.parse(orderModel.tax.toString()) / 100;
  //       } else {
  //         totalTax = double.parse(orderModel.tax.toString());
  //       }
  //     */
  //     if (orderModel!.taxModel != null) {
  //       for (var element in orderModel!.taxModel!) {
  //         totalTax = totalTax + calculateTax(amount: (double.parse(orderModel.subTotal.toString()) -
  //             double.parse(orderModel.discount.toString())).toString(),
  //             taxModel: element);
  //       }
  //     }
  //     double subTotal = double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString());
  //     double adminComm = 0.0;
  //     if (orderModel.adminCommission!.isNotEmpty) {
  //       adminComm = (orderModel.adminCommissionType == 'Percent') ? (subTotal * double.parse(orderModel.adminCommission!)) / 100 : double.parse(orderModel.adminCommission!);
  //     }
  //
  //     print("--->finalAmount---- $subTotal");
  //     print("11111");
  //     print(orderModel.paymentMethod.toLowerCase());
  //     if (orderModel.paymentMethod.toLowerCase() != "cod") {
  //       amount = subTotal + totalTax + adminComm;
  //     } else {
  //       amount = -(subTotal + totalTax + adminComm);
  //     }
  //   } else if (MyAppState.currentUser!.serviceType == "rental-service") {
  //     double totalTax = 0.0;
  //     double subTotal = (double.parse(orderModel.subTotal.toString()) + double.parse(orderModel.driverRate.toString())) - double.parse(orderModel.discount.toString());
  //
  //     /*if (orderModel.taxType!.isNotEmpty) {
  //       if (orderModel.taxType == "percent") {
  //         totalTax = subTotal * double.parse(orderModel.tax.toString()) / 100;
  //       } else {
  //         totalTax = double.parse(orderModel.tax.toString());
  //       }
  //     }*/
  //     if (orderModel!.taxModel != null) {
  //       for (var element in orderModel!.taxModel!) {
  //         totalTax = totalTax + calculateTax(amount: (orderModel.subTotal.toString()),
  //             taxModel: element);
  //       }
  //     }
  //     double adminComm = 0.0;
  //     if (orderModel.adminCommission!.isNotEmpty) {
  //       adminComm = (orderModel.adminCommissionType == 'Percent')
  //           ? (double.parse(orderModel.subTotal.toString()) + double.parse(orderModel.driverRate.toString()) * double.parse(orderModel.adminCommission!)) / 100
  //           : double.parse(orderModel.adminCommission!);
  //     }
  //
  //     if (orderModel.paymentMethod.toLowerCase() != "cod") {
  //       amount = subTotal + totalTax + adminComm;
  //     } else {
  //       amount = -(subTotal + totalTax + adminComm);
  //     }
  //   } else {
  //     print("delv charge ${orderModel.deliveryCharge}");
  //     if (orderModel.deliveryCharge != null && orderModel.deliveryCharge!.isNotEmpty) {
  //       amount += double.parse(orderModel.deliveryCharge!);
  //     }
  //
  //     if (orderModel.tipValue != null && orderModel.tipValue!.isNotEmpty) {
  //       amount += double.parse(orderModel.tipValue!);
  //     }
  //   }
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
  //     child: Card(
  //       elevation: 2,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             SizedBox(
  //               width: size.width * 0.52,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "${DateFormat('dd-MM-yyyy, KK:mma').format(orderModel.createdAt.toDate()).toUpperCase()}",
  //                     style: TextStyle(fontFamily: "GlacialIndifference",
  //                       fontWeight: FontWeight.w500,
  //                       fontSize: 17,
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Opacity(
  //                     opacity: 0.75,
  //                     child: Text(
  //                       orderModel.status,
  //                       style: TextStyle(fontFamily: "GlacialIndifference",
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: 17,
  //                         color: orderModel.status == "Order Completed" ? Colors.green : Colors.deepOrangeAccent,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(right: 3.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.end,
  //                 children: [
  //                   Text(
  //                     " ${amountShow(amount: amount.toString())}",
  //                     style: TextStyle(fontFamily: "GlacialIndifference",
  //                       fontWeight: FontWeight.w600,
  //                       color: orderModel.status == "Order Completed"
  //                           ? amount < 0
  //                               ? Colors.red
  //                               : Colors.green
  //                           : Colors.deepOrange,
  //                       fontSize: 18,
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 20,
  //                   ),
  //                   // Icon(
  //                   //   Icons.arrow_forward_ios,
  //                   //   size: 15,
  //                   // )
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget showWithdrawalHistory(BuildContext context,
      {required Stream<QuerySnapshot>? query}) {
    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'.tr()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
                  height: 35, width: 35, child: CircularProgressIndicator()));
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
            "No Transaction History".tr(),
            style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 18),
          ));
        } else {
          return ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final topUpData = WithdrawHistoryModel.fromJson(
                  document.data() as Map<String, dynamic>);
              //Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return buildTransactionCard(
                withdrawHistory: topUpData,
                date: topUpData.paidDate.toDate(),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget buildTransactionCard({
    required WithdrawHistoryModel withdrawHistory,
    required DateTime date,
  }) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
      child: GestureDetector(
        onTap: () => showWithdrawalModelSheet(context, withdrawHistory),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      child: Icon(Icons.account_balance_wallet_rounded,
                          size: 28, color: Color(0xFF00B761)),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: SizedBox(
                          width: size.width * 0.52,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${DateFormat('MMM dd, yyyy, KK:mma').format(withdrawHistory.paidDate.toDate()).toUpperCase()}",
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Opacity(
                                opacity: 0.75,
                                child: Text(
                                  withdrawHistory.paymentStatus,
                                  style: TextStyle(fontFamily: "GlacialIndifference",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: withdrawHistory.paymentStatus ==
                                            "Success"
                                        ? Colors.green
                                        : Colors.deepOrangeAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              " ${amountShow(amount: withdrawHistory.amount.toString())}",
                              style: TextStyle(fontFamily: "GlacialIndifference",
                                fontWeight: FontWeight.w600,
                                color:
                                    withdrawHistory.paymentStatus == "Success"
                                        ? Colors.green
                                        : Colors.deepOrangeAccent,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                            )
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
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    paymentCompleted(paymentMethod: "RazorPay");
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Processing Via".tr() + "\n" + response.walletName!,
      ),
      backgroundColor: Colors.blue.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Failed!!".tr() +
            "\n" +
            jsonDecode(response.message!)['error']['description'],
      ),
      backgroundColor: Colors.red.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  withdrawAmountBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 5),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                      child: Text(
                        "Withdraw".tr(),
                        style: TextStyle(fontFamily: "GlacialIndifference",
                          fontSize: 18,
                          color: isDarkMode(context)
                              ? Colors.white
                              : Color(DARK_COLOR),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 25),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.yellow, width: 4)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userBankDetail!.bankName,
                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode(context)
                                          ? Colors.white
                                          : Color(DARK_COLOR),
                                    ),
                                  ),
                                  Icon(
                                    Icons.account_balance,
                                    size: 40,
                                    color: Colors.yellow,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                userBankDetail!.accountNumber,
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode(context)
                                      ? Colors.white.withOpacity(0.9)
                                      : Color(DARK_COLOR).withOpacity(0.9),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                userBankDetail!.holderName,
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode(context)
                                      ? Colors.white.withOpacity(0.7)
                                      : Color(DARK_COLOR).withOpacity(0.7),
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userBankDetail!.otherDetails,
                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                      fontSize: 20,
                                      color: isDarkMode(context)
                                          ? Colors.white.withOpacity(0.9)
                                          : Color(DARK_COLOR).withOpacity(0.9),
                                    ),
                                  ),
                                  Text(
                                    userBankDetail!.branchName,
                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                      fontSize: 18,
                                      color: isDarkMode(context)
                                          ? Colors.white.withOpacity(0.7)
                                          : Color(DARK_COLOR).withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 5),
                          child: RichText(
                            text: TextSpan(
                              text: "Amount to Withdraw".tr(),
                              style: TextStyle(fontFamily: "GlacialIndifference",
                                fontSize: 16,
                                color: isDarkMode(context)
                                    ? Colors.white70
                                    : Color(DARK_COLOR).withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Form(
                      key: _globalKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 8),
                          child: TextFormField(
                            controller: _amountController,
                            style: TextStyle(fontFamily: "GlacialIndifference",
                              color: isDarkMode(context)
                                  ? Colors.white
                                  : Color(DARK_COLOR),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            //initialValue:"50",
                            maxLines: 1,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "*required Field".tr();
                              } else {
                                if (double.parse(value) <= 0) {
                                  return "*Invalid Amount".tr();
                                } else if (double.parse(value) >
                                    double.parse(MyAppState
                                        .currentUser!.walletAmount
                                        .toString())) {
                                  return "*withdraw is more then wallet balance"
                                      .tr();
                                } else {
                                  return null;
                                }
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefix: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 2),
                                child: Text(
                                  "${currencyData!.symbol}",
                                  style: TextStyle(fontFamily: "GlacialIndifference",
                                    color: isDarkMode(context)
                                        ? Colors.white
                                        : Color(DARK_COLOR),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              fillColor: Colors.grey[200],
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                      color: Color(COLOR_PRIMARY),
                                      width: 1.50)),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).errorColor),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).errorColor),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: TextFormField(
                        controller: _noteController,
                        style: TextStyle(fontFamily: "GlacialIndifference",
                          color: isDarkMode(context)
                              ? Colors.white
                              : Color(DARK_COLOR),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        //initialValue:"50",
                        maxLines: 1,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "*required Field".tr();
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Add note'.tr(),
                          fillColor: Colors.grey[200],
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                  color: Color(COLOR_PRIMARY), width: 1.50)),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Theme.of(context).errorColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Theme.of(context).errorColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: buildButton(context, title: "WITHDRAW".tr(),
                          onPress: () {
                        if (_globalKey.currentState!.validate()) {
                          print("------->");
                          print(minimumAmountToWithdrawal);
                          print(_amountController.text);
                          if (double.parse(minimumAmountToWithdrawal) >
                              double.parse(_amountController.text)) {
                            showAlertDialog(
                                context,
                                "Failed!".tr(),
                                '${"Withdraw amount must be greater or equal to".tr()} ${amountShow(amount: minimumAmountToWithdrawal)}'
                                    .tr(),
                                true);
                          } else {
                            withdrawRequest();
                          }
                        }
                      }),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  withdrawRequest() {
    Navigator.pop(context);
    showLoadingAlert();
    FireStoreUtils.createPaymentId(collectionName: driverPayouts).then((value) {
      final paymentID = value;

      WithdrawHistoryModel withdrawHistory = WithdrawHistoryModel(
        amount: double.parse(_amountController.text),
        driverID: userId,
        paymentStatus: "Pending".tr(),
        paidDate: Timestamp.now(),
        id: paymentID.toString(),
        note: _noteController.text,
      );

      print(withdrawHistory.driverID);

      FireStoreUtils.withdrawWalletAmount(withdrawHistory: withdrawHistory)
          .then((value) {
        FireStoreUtils.updateCurrentUserWallet(
                userId: userId, amount: -double.parse(_amountController.text))
            .whenComplete(() {
          Navigator.pop(_scaffoldKey.currentContext!);
          FireStoreUtils.sendPayoutMail(
              amount: _amountController.text,
              payoutrequestid: paymentID.toString());
          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text("Payment Successful!! \n".tr()),
            backgroundColor: Colors.green,
          ));
        });
      });
    });
  }

  withdrawalHistoryBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: size.height,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: showWithdrawalHistory(context,
                        query: withdrawalHistoryQuery),
                  ),
                  Positioned(
                    top: 40,
                    left: 15,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  buildButton(context,
      {required String title,
      double width = 0.9,
      required Function()? onPress}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * width,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Color(0xffFFDF00),
        height: 45,
        elevation: 0.0,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 15, color: Colors.black),
        ),
      ),
    );
  }

  buildTransButton(context,
      {required String title,
      double width = 0.9,
      required Function()? onPress}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * width,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: isDarkMode(context) ? Colors.yellow : Colors.black, width: 1),
            borderRadius: BorderRadius.circular(6)),
        color: Colors.transparent,
        height: 45,
        elevation: 0.0,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 15, color: isDarkMode(context) ? Colors.yellow : Colors.black),
        ),
      ),
    );
  }

  showLoadingAlert() {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
              Text('Please wait!!'.tr()),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Please wait!! while completing Transaction'.tr(),
                  style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 16),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
