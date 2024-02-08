import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/Parcel_service/parcel_order_model.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/BlockUserModel.dart';
import 'package:nocdriver/model/CabOrderModel.dart';
import 'package:nocdriver/model/CarMakes.dart';
import 'package:nocdriver/model/CarModel.dart';
import 'package:nocdriver/model/ChatVideoContainer.dart';
import 'package:nocdriver/model/CurrencyModel.dart';
import 'package:nocdriver/model/DeliveryChargeModel.dart';
import 'package:nocdriver/model/FlutterWaveSettingDataModel.dart';
import 'package:nocdriver/model/MercadoPagoSettingsModel.dart';
import 'package:nocdriver/model/OrderModel.dart';
import 'package:nocdriver/model/PayFastSettingData.dart';
import 'package:nocdriver/model/PayStackSettingsModel.dart';
import 'package:nocdriver/model/Ratingmodel.dart';
import 'package:nocdriver/model/SectionModel.dart';
import 'package:nocdriver/model/User.dart';
import 'package:nocdriver/model/VehicleType.dart';
import 'package:nocdriver/model/VendorModel.dart';
import 'package:nocdriver/model/conversation_model.dart';
import 'package:nocdriver/model/email_template_model.dart';
import 'package:nocdriver/model/inbox_model.dart';
import 'package:nocdriver/model/notification_model.dart';
import 'package:nocdriver/model/paypalSettingData.dart';
import 'package:nocdriver/model/paytmSettingData.dart';
import 'package:nocdriver/model/razorpayKeyModel.dart';
import 'package:nocdriver/model/referral_model.dart';
import 'package:nocdriver/model/stripeSettingData.dart';
import 'package:nocdriver/model/withdrawHistoryModel.dart';
import 'package:nocdriver/rental_service/model/rental_order_model.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:nocdriver/ui/reauthScreen/reauth_user_screen.dart';
import 'package:nocdriver/userPrefrence.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FireStoreUtils {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static Reference storage = FirebaseStorage.instance.ref();
  List<BlockUserModel> blockedList = [];

  static Future addDriverInbox(InboxModel inboxModel) async {
    return await firestore
        .collection("chat_driver")
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future addDriverChat(ConversationModel conversationModel) async {
    return await firestore
        .collection("chat_driver")
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  Future<List<RatingModel>> getReviewByDriverId(String driverId) async {
    List<RatingModel> vendorreview = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(Order_Rating)
        .where('driverId', isEqualTo: driverId)
        // .orderBy('createdAt', descending: true)
        .get();
    await Future.forEach(vendorsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      print(document);
      try {
        vendorreview.add(RatingModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getOrders Parse error ${document.id} $e');
      }
    });
    return vendorreview;
  }

  Future<String?> getDriverOrderSetting() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery =
        await firestore.collection(Setting).doc('DriverNearBy').get();
    if (codQuery.data() != null) {
      minimumDepositToRideAccept = codQuery['minimumDepositToRideAccept'];
      driverOrderAcceptRejectDuration =
          int.parse(codQuery["driverOrderAcceptRejectDuration"].toString());
      enableOTPParcelReceive = codQuery["enableOTPParcelReceive"] ?? false;
      enableOTPTripStart = codQuery["enableOTPTripStart"] ?? false;
    } else {
      return "";
    }
    return null;
  }

  Future<List<RentalOrderModel>> getRentalBook(
      String userID, bool isCompany) async {
    List<RentalOrderModel> orders = [];
    QuerySnapshot<Map<String, dynamic>> ordersQuery;
    if (isCompany) {
      ordersQuery = await firestore
          .collection(RENTALORDER)
          .where('companyID', isEqualTo: userID)
          .where("status", isEqualTo: ORDER_STATUS_PLACED)
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      ordersQuery = await firestore
          .collection(RENTALORDER)
          .where('driverID', isEqualTo: userID)
          .where("status", whereIn: [
            ORDER_STATUS_PLACED,
            ORDER_STATUS_DRIVER_ACCEPTED,
            ORDER_STATUS_IN_TRANSIT
          ])
          .orderBy('createdAt', descending: true)
          .get();
    }

    await Future.forEach(ordersQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        orders.add(RentalOrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  Future<List<RentalOrderModel>> getRentalBookStatus(
      String userID, bool isCompany, String status) async {
    List<RentalOrderModel> orders = [];
    QuerySnapshot<Map<String, dynamic>> ordersQuery;
    if (status.isEmpty) {
      if (isCompany) {
        ordersQuery = await firestore
            .collection(RENTALORDER)
            .where('companyID', isEqualTo: userID)
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        ordersQuery = await firestore
            .collection(RENTALORDER)
            .where('driverID', isEqualTo: userID)
            .orderBy('createdAt', descending: true)
            .get();
      }
    } else {
      if (isCompany) {
        ordersQuery = await firestore
            .collection(RENTALORDER)
            .where('companyID', isEqualTo: userID)
            .where("status", isEqualTo: status)
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        ordersQuery = await firestore
            .collection(RENTALORDER)
            .where('driverID', isEqualTo: userID)
            .where("status", isEqualTo: status)
            .orderBy('createdAt', descending: true)
            .get();
      }
    }

    await Future.forEach(ordersQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        orders.add(RentalOrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  Future<List<RentalOrderModel>> getRentalOrderByDriverOrder(
      String userID, String companyId) async {
    List<RentalOrderModel> orders = [];
    QuerySnapshot<Map<String, dynamic>> ordersQuery;
    ordersQuery = await firestore
        .collection(RENTALORDER)
        .where('driverID', isEqualTo: userID)
        .get();

    await Future.forEach(ordersQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        orders.add(RentalOrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  Future<List<CabOrderModel>> getCabOrderByDriverOrder(
      String userID, String companyId) async {
    List<CabOrderModel> orders = [];
    QuerySnapshot<Map<String, dynamic>> ordersQuery;
    ordersQuery = await firestore
        .collection(RIDESORDER)
        .where('driverID', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .get();

    await Future.forEach(ordersQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        orders.add(CabOrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  late StreamController<User> driverStreamController;
  late StreamSubscription driverStreamSub;

  Stream<User> getDriver(String userId) async* {
    driverStreamController = StreamController();
    driverStreamSub = firestore
        .collection(USERS)
        .doc(userId)
        .snapshots()
        .listen((onData) async {
      if (onData.data() != null) {
        User? user = User.fromJson(onData.data()!);
        driverStreamController.sink.add(user);
      }
    });
    yield* driverStreamController.stream;
  }

  static Future<List<VehicleType>> getVehicleType(
      SectionModel? sectionModel) async {
    print("----------->");
    print(sectionModel!.id);
    List<VehicleType> vehicleType = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore
        .collection(VEHICLETYPE)
        .where('sectionId', isEqualTo: sectionModel.id)
        .where("isActive", isEqualTo: true)
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        vehicleType.add(VehicleType.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return vehicleType;
  }

  static Future<List<SectionModel>> getSections() async {
    List<SectionModel> sections = [];
    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore
        .collection(SECTION)
        .where("isActive", isEqualTo: true)
        .where('serviceTypeFlag', isEqualTo: "cab-service")
        .get();
    await Future.forEach(productsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        if (document.data()['name'] != "Banner") {
          sections.add(SectionModel.fromJson(document.data()));
        }
      } catch (e) {
        print('**-FireStoreUtils.getSection Parse error $e');
      }
    });

    return sections;
  }

  static Future<List<VehicleType>> getRentalVehicleType() async {
    List<VehicleType> vehicleType = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore
        .collection(RENTALVEHICLETYPE)
        .where("isActive", isEqualTo: true)
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        vehicleType.add(VehicleType.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return vehicleType;
  }

  static Future<List<CarMakes>> getCarMakes() async {
    List<CarMakes> carMakesList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore
        .collection(CARMAKES)
        .where("isActive", isEqualTo: true)
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        carMakesList.add(CarMakes.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return carMakesList;
  }

  static Future<List<CarModel>> getCarModel(
      BuildContext context, String name) async {
    // showProgress(context, 'Please wait...'.tr(), false);

    List<CarModel> carMakesList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore
        .collection(CARMODEL)
        .where("car_make_name", isEqualTo: name)
        .where("isActive", isEqualTo: true)
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        carMakesList.add(CarModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    hideProgress();
    return carMakesList;
  }

  static Future<User?> getCurrentUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await firestore.collection(USERS).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      // print('milaa');

      return User.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  static Future<CabOrderModel?> getCabOrderByOrderId(String orderID) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await firestore.collection(RIDESORDER).doc(orderID).get();
    if (userDocument.data() != null && userDocument.exists) {
      return CabOrderModel.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  /*Future<List<CurrencyModel>> getCurrency() async {
    List<CurrencyModel> currency = [];

    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(Currency).where('isActive', isEqualTo: true).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        currency.add(CurrencyModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return currency;
  }*/
  Future<CurrencyModel?> getCurrency() async {
    CurrencyModel? currency;
    await firestore
        .collection(Currency)
        .where("isActive", isEqualTo: true)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        currency = CurrencyModel.fromJson(value.docs.first.data());
        print("CURRENCY ${currency!.code.toString()}");
        print("CURRENCY22 ${currency!.decimal.toString()}");
        print("CURRENCY33 ${currency!.id.toString()}");
        print("CURRENCY44 ${currency!.isactive.toString()}");
        print("CURRENCY55 ${currency!.name.toString()}");
        print("CURRENCY66 ${currency!.symbol.toString()}");
        print("CURRENCY77 ${currency!.symbolatright.toString()}");
        print("CURRENCY88 ${currency!.rounding.toString()}");
      }
    });
    return currency;
  }

  Future<VendorModel> getVendorByVendorID(String vendorID) async {
    late VendorModel vendor;
    print(vendorID.toString() + "----VENDORIDPLACEORDER");
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(VENDORS)
        .where('id', isEqualTo: vendorID)
        .get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        vendor = VendorModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return vendor;
  }

  Future<DeliveryChargeModel?> getDeliveryCharges() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery =
        await firestore.collection(Setting).doc('DeliveryCharge').get();
    if (codQuery.data() != null) {
      return DeliveryChargeModel.fromJson(codQuery.data()!);
    } else {
      return null;
    }
  }

  static Future<User?> updateCurrentUser(User user) async {
    return await firestore
        .collection(USERS)
        .doc(user.userID)
        .set(user.toJson())
        .then((document) {
      return user;
    });
  }

  getContactUs() async {
    Map<String, dynamic> contactData = {};
    await firestore.collection(Setting).doc(CONTACT_US).get().then((value) {
      if (value != null) {
        contactData = value.data()!;
      }
    });

    return contactData;
  }

  static Future orderTransaction(
      {required OrderModel orderModel,
      required num amount,
      required num driveramount}) async {
    DocumentReference documentReference =
        firestore.collection(OrderTransaction).doc();
    Map<String, dynamic> data = {
      "order_id": orderModel.id,
      "id": documentReference.id,
      "date": DateTime.now(),
    };
    print("Error is false called transaction");
    if (orderModel.takeAway!) {
      data.addAll({"vendorId": orderModel.vendorID, "vendorAmount": amount});
    } else {
      data.addAll({
        "vendorId": orderModel.vendorID,
        "vendorAmount": amount,
        "driverId": orderModel.driverID,
        "driverAmount": driveramount
      });
    }

    await firestore
        .collection(OrderTransaction)
        .doc(documentReference.id)
        .set(data)
        .then((value) {});
    return "updated transaction".tr();
  }

  static Future cabOrderTransaction(
      {required CabOrderModel orderModel, required num driveramount}) async {
    DocumentReference documentReference =
        firestore.collection(OrderTransaction).doc();
    Map<String, dynamic> data = {
      "order_id": orderModel.id,
      "id": documentReference.id,
      "date": DateTime.now(),
    };
    print("Error is false called transaction");
    data.addAll({
      "vendorId": "",
      "vendorAmount": "",
      "driverId": orderModel.driverID,
      "driverAmount": driveramount
    });

    await firestore
        .collection(OrderTransaction)
        .doc(documentReference.id)
        .set(data)
        .then((value) {});
    return "updated transaction".tr();
  }

  static Future parcelOrderTransaction(
      {required ParcelOrderModel orderModel, required num driveramount}) async {
    DocumentReference documentReference =
        firestore.collection(OrderTransaction).doc();

    Map<String, dynamic> data = {
      "order_id": orderModel.id,
      "id": documentReference.id,
      "date": DateTime.now(),
    };
    print("Error is false called transaction");
    data.addAll({
      "vendorId": "",
      "vendorAmount": "",
      "driverId": orderModel.driverID,
      "driverAmount": driveramount
    });

    await firestore
        .collection(OrderTransaction)
        .doc(documentReference.id)
        .set(data)
        .then((value) {});
    return "updated transaction".tr();
  }

  static Future rentalOrderTransaction(
      {required RentalOrderModel orderModel, required num driveramount}) async {
    DocumentReference documentReference =
        firestore.collection(OrderTransaction).doc();
    Map<String, dynamic> data = {
      "order_id": orderModel.id,
      "id": documentReference.id,
      "date": DateTime.now(),
    };
    print("Error is false called transaction");

    // if (MyAppState.currentUser!.isCompany == false) {
    //   data.addAll({"vendorId": "", "vendorAmount": "", "driverId": MyAppState.currentUser!.companyId, "driverAmount": driveramount});
    // } else {
    data.addAll({
      "vendorId": "",
      "vendorAmount": "",
      "driverId": orderModel.driverID,
      "driverAmount": driveramount
    });
    // }
    await firestore
        .collection(OrderTransaction)
        .doc(documentReference.id)
        .set(data)
        .then((value) {});
    return "updated transaction".tr();
  }

  static Future createPaymentId({collectionName = "wallet"}) async {
    DocumentReference documentReference =
        firestore.collection(collectionName).doc();
    final paymentId = documentReference.id;
    //UserPreference.setPaymentId(paymentId: paymentId);
    return paymentId;
  }

  static Future topUpWalletAmount(
      {String serviceType = "",
      String paymentMethod = "test",
      bool isTopup = true,
      required amount,
      required id,
      orderId = "",
      required String userID}) async {
    print("this is te payment id");
    print(id);

    await firestore.collection(Wallet).doc(id).set({
      "serviceType": serviceType,
      "user_id": userID,
      "payment_method": paymentMethod,
      "amount": amount,
      "id": id,
      "order_id": orderId,
      "isTopUp": isTopup,
      "payment_status": "success",
      "date": DateTime.now(),
    }).then((value) {
      firestore.collection(Wallet).doc(id).get().then((value) {
        DocumentSnapshot<Map<String, dynamic>> documentData = value;
        print("nato");
        print(documentData.data());
      });
    });

    return "updated Amount".tr();
  }

  static Future updateWalletAmount(
      {required String userId, required amount}) async {
    dynamic walletAmount = 0;
    await firestore.collection(USERS).doc(userId).get().then((value) async {
      DocumentSnapshot<Map<String, dynamic>> userDocument = value;
      if (userDocument.data() != null && userDocument.exists) {
        try {
          print(userDocument.data());
          await firestore.collection(USERS).doc(userId).update({
            "wallet_amount": userDocument.data()!['wallet_amount'] + amount
          }).then((value) => print("north"));

          DocumentSnapshot<Map<String, dynamic>> newUserDocument =
              await firestore.collection(USERS).doc(userId).get();
          MyAppState.currentUser = User.fromJson(newUserDocument.data()!);
          print(MyAppState.currentUser);
        } catch (error) {
          print(error);
          if (error.toString() ==
              "Bad state: field does not exist within the DocumentSnapshotPlatform") {
            print("does not exist");
          } else {
            print("went wrong!!");
            walletAmount = "ERROR";
          }
        }
        print("data val");
        print(walletAmount);
        return walletAmount; //User.fromJson(userDocument.data()!);
      } else {
        return 0.111;
      }
    });
  }

  static Future updateUserWalletAmount(
      {required String userId, required amount}) async {
    await firestore.collection(USERS).doc(userId).get().then((value) async {
      DocumentSnapshot<Map<String, dynamic>> userDocument = value;
      if (userDocument.data() != null && userDocument.exists) {
        try {
          print("--->amount---- $amount");
          print(userDocument.data());
          User user = User.fromJson(userDocument.data()!);
          await firestore
              .collection(USERS)
              .doc(userId)
              .update({"wallet_amount": user.walletAmount + amount}).then(
                  (value) => print("north"));
        } catch (error) {
          print(error);
          if (error.toString() ==
              "Bad state: field does not exist within the DocumentSnapshotPlatform") {
            print("does not exist");
          } else {
            print("went wrong!!");
          }
        }
        print("data val");
        return ""; //User.fromJson(userDocument.data()!);
      } else {
        return 0.111;
      }
    });
  }

  static Future withdrawWalletAmount(
      {required WithdrawHistoryModel withdrawHistory}) async {
    print("this is te payment id");
    print(withdrawHistory.id);
    print(MyAppState.currentUser!.userID);

    await firestore
        .collection(driverPayouts)
        .doc(withdrawHistory.id)
        .set(withdrawHistory.toJson())
        .then((value) {
      firestore
          .collection(driverPayouts)
          .doc(withdrawHistory.id)
          .get()
          .then((value) {
        DocumentSnapshot<Map<String, dynamic>> documentData = value;
        print(documentData.data());
      });
    });
    return "updated Amount".tr();
  }

  static Future updateCurrentUserWallet(
      {required String userId, required amount}) async {
    await firestore.collection(USERS).doc(userId).get().then((value) async {
      DocumentSnapshot<Map<String, dynamic>> userDocument = value;

      if (userDocument.data() != null && userDocument.exists) {
        try {
          print("--->amount---- $amount");
          print(userDocument.data());
          User user = User.fromJson(userDocument.data()!);
          MyAppState.currentUser = user;
          await firestore
              .collection(USERS)
              .doc(userId)
              .update({"wallet_amount": user.walletAmount + amount}).then(
                  (value) => print("north"));
          DocumentSnapshot<Map<String, dynamic>> newUserDocument =
              await firestore.collection(USERS).doc(userId).get();
          MyAppState.currentUser = User.fromJson(newUserDocument.data()!);
        } catch (error) {
          print(error);
          if (error.toString() ==
              "Bad state: field does not exist within the DocumentSnapshotPlatform") {
            print("does not exist");
          } else {
            print("went wrong!!");
          }
        }
        print("data val");
        return ""; //User.fromJson(userDocument.data()!);
      } else {
        return 0.111;
      }
    });
  }

  // static Future updateCompanyWalletAmount({required String companyId, required amount}) async {
  //   await firestore.collection(USERS).doc(companyId).get().then((value) async {
  //     DocumentSnapshot<Map<String, dynamic>> userDocument = value;
  //
  //     if (userDocument.data() != null && userDocument.exists) {
  //       try {
  //         print("--->amount---- $amount");
  //         print(userDocument.data());
  //         User user = User.fromJson(userDocument.data()!);
  //         await firestore.collection(USERS).doc(companyId).update({"wallet_amount": user.walletAmount + amount}).then((value) => print("north"));
  //       } catch (error) {
  //         print(error);
  //         if (error.toString() == "Bad state: field does not exist within the DocumentSnapshotPlatform") {
  //           print("does not exist");
  //         } else {
  //           print("went wrong!!");
  //         }
  //       }
  //       print("data val");
  //       return ""; //User.fromJson(userDocument.data()!);
  //     } else {
  //       return 0.111;
  //     }
  //   });
  // }

  static Future updateVendorAmount(
      {required String userId, required amount}) async {
    await firestore.collection(USERS).doc(userId).get().then((value) async {
      DocumentSnapshot<Map<String, dynamic>> userDocument = value;

      if (userDocument.data() != null && userDocument.exists) {
        try {
          print("--->amount---- $amount");
          print(userDocument.data());
          User user = User.fromJson(userDocument.data()!);
          await firestore
              .collection(USERS)
              .doc(userId)
              .update({"wallet_amount": user.walletAmount + amount}).then(
                  (value) => print("north"));
        } catch (error) {
          print(error);
          if (error.toString() ==
              "Bad state: field does not exist within the DocumentSnapshotPlatform") {
            print("does not exist");
          } else {
            print("went wrong!!");
          }
        }
        print("data val");
        return ""; //User.fromJson(userDocument.data()!);
      } else {
        return 0.111;
      }
    });
  }

  static Future<VendorModel?> getVendor(String vid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await firestore.collection(VENDORS).doc(vid).get();
    if (userDocument.data() != null && userDocument.exists) {
      print("dataaaaaa");
      return VendorModel.fromJson(userDocument.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  static Future<String> uploadUserImageToFireStorage(
      File image, String userID) async {
    Reference upload = storage.child(STORAGE_ROOT + '/images/$userID.png');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<String> uploadCarImageToFireStorage(
      File image, String userID) async {
    Reference upload =
        storage.child(STORAGE_ROOT + '/drivers/carImages/$userID.png');
    File compressedCarImage = await compressImage(image);
    UploadTask uploadTask = upload.putFile(compressedCarImage);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Future<Url> uploadChatImageToFireStorage(
      File image, BuildContext context) async {
    showProgress(context, 'Uploading image...'.tr(), false);
    var uniqueID = Uuid().v4();
    Reference upload =
        storage.child(STORAGE_ROOT + '/chat/images/$uniqueID.png');
    File compressedImage = await compressImage(image);
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          '${"Uploading image ".tr()}${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(currencyData!.decimal)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(currencyData!.decimal)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  Future<ChatVideoContainer> uploadChatVideoToFireStorage(
      File video, BuildContext context) async {
    showProgress(context, 'Uploading video...', false);
    var uniqueID = Uuid().v4();
    Reference upload =
        storage.child(STORAGE_ROOT + '/emart/chat/videos/$uniqueID.mp4');
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          '${"Uploading video".tr()} ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(currencyData!.decimal)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(currencyData!.decimal)} '
          'KB');
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(
        video: downloadUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG);
    final file = File(uint8list ?? '');
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    hideProgress();
    return ChatVideoContainer(
        videoUrl: Url(
            url: downloadUrl.toString(), mime: metaData.contentType ?? 'video'),
        thumbnailUrl: thumbnailDownloadUrl);
  }

  Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = Uuid().v4();
    Reference upload =
        storage.child(STORAGE_ROOT + '/thumbnails/$uniqueID.png');
    File compressedImage = await compressImage(file);
    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Stream<User> getUserByID(String id) async* {
    StreamController<User> userStreamController = StreamController();
    firestore.collection(USERS).doc(id).snapshots().listen((user) {
      try {
        User userModel = User.fromJson(user.data() ?? {});
        userStreamController.sink.add(userModel);
      } catch (e) {
        print(
            'FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* userStreamController.stream;
  }

  Future<bool> blockUser(User blockedUser, String type) async {
    bool isSuccessful = false;
    BlockUserModel blockUserModel = BlockUserModel(
        type: type,
        source: MyAppState.currentUser!.userID,
        dest: blockedUser.userID,
        createdAt: Timestamp.now());
    await firestore
        .collection(REPORTS)
        .add(blockUserModel.toJson())
        .then((onValue) {
      isSuccessful = true;
    });
    return isSuccessful;
  }

  Stream<bool> getBlocks() async* {
    StreamController<bool> refreshStreamController = StreamController();
    firestore
        .collection(REPORTS)
        .where('source', isEqualTo: MyAppState.currentUser!.userID)
        .snapshots()
        .listen((onData) {
      List<BlockUserModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> block in onData.docs) {
        list.add(BlockUserModel.fromJson(block.data() ?? {}));
      }
      blockedList = list;
      refreshStreamController.sink.add(true);
    });
    yield* refreshStreamController.stream;
  }

  bool validateIfUserBlocked(String userID) {
    for (BlockUserModel blockedUser in blockedList) {
      if (userID == blockedUser.dest) {
        return true;
      }
    }
    return false;
  }

  Future<Url> uploadAudioFile(File file, BuildContext context) async {
    showProgress(context, 'Uploading Audio...', false);
    var uniqueID = Uuid().v4();
    Reference upload =
        storage.child(STORAGE_ROOT + '/chat/audio/$uniqueID.mp3');
    SettableMetadata metadata = SettableMetadata(contentType: 'audio');
    UploadTask uploadTask = upload.putFile(file, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          '${"Uploading Audio".tr()} ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(currencyData!.decimal)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(currencyData!.decimal)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(
        mime: metaData.contentType ?? 'audio', url: downloadUrl.toString());
  }

  Future<List<OrderModel>> getDriverOrders(String userID) async {
    List<OrderModel> orders = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore
        .collection(ORDERS)
        .where('driverID', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .get();

    print("------>${ordersQuery.docs.length}");
    await Future.forEach(ordersQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        orders.add(OrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  Future<List<User>> getRentalCompanyDriver(String companyId) async {
    List<User> driverList = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore
        .collection(USERS)
        .where('companyId', isEqualTo: companyId)
        .where("serviceType", isEqualTo: "rental-service")
        .get();
    await Future.forEach(ordersQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        driverList.add(User.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return driverList;
  }

  Future<List<User>> getCabCompanyDriver(String companyId) async {
    List<User> driverList = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore
        .collection(USERS)
        .where('companyId', isEqualTo: companyId)
        .where("serviceType", isEqualTo: "cab-service")
        .get();
    await Future.forEach(ordersQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        driverList.add(User.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return driverList;
  }

  Future<List<CabOrderModel>> getCabDriverOrders(String userID) async {
    List<CabOrderModel> orders = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore
        .collection(RIDESORDER)
        .where('driverID', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .get();
    await Future.forEach(ordersQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        orders.add(CabOrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  Future<List<ParcelOrderModel>> getParcelDriverOrders(String userID) async {
    List<ParcelOrderModel> orders = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore
        .collection(PARCELORDER)
        .where('driverID', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .get();
    await Future.forEach(ordersQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        orders.add(ParcelOrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  static Future updateOrder(OrderModel orderModel) async {
    await firestore
        .collection(ORDERS)
        .doc(orderModel.id)
        .set(orderModel.toJson(), SetOptions(merge: true));
  }

  static Future<SectionModel?> getSectionBySectionId(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await firestore.collection(SECTION).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      // print('milaa');

      return SectionModel.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  static Future<bool> getRentalFirstOrderOrNOt(
      RentalOrderModel orderModel) async {
    bool isFirst = true;
    await firestore
        .collection(RENTALORDER)
        .where('authorID', isEqualTo: orderModel.authorID)
        .get()
        .then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateRentalReferralAmount(RentalOrderModel orderModel) async {
    ReferralModel? referralModel;
    SectionModel? sectionModel;
    print(orderModel.authorID);
    await getSectionBySectionId(orderModel.sectionId.toString()).then((value) {
      sectionModel = value;
    });
    await firestore
        .collection(REFERRAL)
        .doc(orderModel.authorID)
        .get()
        .then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });

    if (referralModel != null) {
      if (referralModel!.referralBy != null &&
          referralModel!.referralBy!.isNotEmpty) {
        await firestore
            .collection(USERS)
            .doc(referralModel!.referralBy)
            .get()
            .then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              print(userDocument.data());
              User user = User.fromJson(userDocument.data()!);
              await firestore.collection(USERS).doc(user.userID).update({
                "wallet_amount": user.walletAmount +
                    double.parse(sectionModel!.referralAmount.toString())
              }).then((value) => print("north"));

              await FireStoreUtils.createPaymentId().then((value) async {
                final paymentID = value;
                await FireStoreUtils.topUpWalletAmountRefral(
                    paymentMethod: "Referral Amount",
                    amount:
                        double.parse(sectionModel!.referralAmount.toString()),
                    id: paymentID,
                    userId: referralModel!.referralBy);
              });
            } catch (error) {
              print(error);
              if (error.toString() ==
                  "Bad state: field does not exist within the DocumentSnapshotPlatform") {
                print("does not exist");
                //await firestore.collection(USERS).doc(userId).update({"wallet_amount": 0});
                //walletAmount = 0;
              } else {
                print("went wrong!!");
              }
            }
            print("data val");
          }
        });
      } else {
        return;
      }
    }
  }

  static Future<bool> getParcelFirstOrderOrNOt(
      ParcelOrderModel orderModel) async {
    bool isFirst = true;
    await firestore
        .collection(PARCELORDER)
        .where('authorID', isEqualTo: orderModel.authorID)
        .get()
        .then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateParcelReferralAmount(ParcelOrderModel orderModel) async {
    ReferralModel? referralModel;
    SectionModel? sectionModel;
    print(orderModel.authorID);
    await getSectionBySectionId(orderModel.sectionId.toString()).then((value) {
      sectionModel = value;
    });
    await firestore
        .collection(REFERRAL)
        .doc(orderModel.authorID)
        .get()
        .then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });

    if (referralModel != null) {
      if (referralModel!.referralBy != null &&
          referralModel!.referralBy!.isNotEmpty) {
        await firestore
            .collection(USERS)
            .doc(referralModel!.referralBy)
            .get()
            .then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              print(userDocument.data());
              User user = User.fromJson(userDocument.data()!);
              await firestore.collection(USERS).doc(user.userID).update({
                "wallet_amount": user.walletAmount +
                    double.parse(sectionModel!.referralAmount.toString())
              }).then((value) => print("north"));

              await FireStoreUtils.createPaymentId().then((value) async {
                final paymentID = value;
                await FireStoreUtils.topUpWalletAmountRefral(
                    paymentMethod: "Referral Amount",
                    amount:
                        double.parse(sectionModel!.referralAmount.toString()),
                    id: paymentID,
                    userId: referralModel!.referralBy);
              });
            } catch (error) {
              print(error);
              if (error.toString() ==
                  "Bad state: field does not exist within the DocumentSnapshotPlatform") {
                print("does not exist");
                //await firestore.collection(USERS).doc(userId).update({"wallet_amount": 0});
                //walletAmount = 0;
              } else {
                print("went wrong!!");
              }
            }
            print("data val");
          }
        });
      } else {
        return;
      }
    }
  }

  static Future<bool> getCabFirstOrderOrNOt(CabOrderModel orderModel) async {
    bool isFirst = true;
    await firestore
        .collection(RIDESORDER)
        .where('authorID', isEqualTo: orderModel.authorID)
        .get()
        .then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateCabReferralAmount(CabOrderModel orderModel) async {
    ReferralModel? referralModel;
    SectionModel? sectionModel;
    print(orderModel.authorID);
    await getSectionBySectionId(orderModel.sectionId.toString()).then((value) {
      sectionModel = value;
    });
    await firestore
        .collection(REFERRAL)
        .doc(orderModel.authorID)
        .get()
        .then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });

    if (referralModel != null) {
      if (referralModel!.referralBy != null &&
          referralModel!.referralBy!.isNotEmpty) {
        await firestore
            .collection(USERS)
            .doc(referralModel!.referralBy)
            .get()
            .then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              print(userDocument.data());
              User user = User.fromJson(userDocument.data()!);
              await firestore.collection(USERS).doc(user.userID).update({
                "wallet_amount": user.walletAmount +
                    double.parse(sectionModel!.referralAmount.toString())
              }).then((value) => print("north"));

              await FireStoreUtils.createPaymentId().then((value) async {
                final paymentID = value;
                await FireStoreUtils.topUpWalletAmountRefral(
                    paymentMethod: "Referral Amount",
                    amount:
                        double.parse(sectionModel!.referralAmount.toString()),
                    id: paymentID,
                    userId: referralModel!.referralBy);
              });
            } catch (error) {
              print(error);
              if (error.toString() ==
                  "Bad state: field does not exist within the DocumentSnapshotPlatform") {
                print("does not exist");
                //await firestore.collection(USERS).doc(userId).update({"wallet_amount": 0});
                //walletAmount = 0;
              } else {
                print("went wrong!!");
              }
            }
            print("data val");
          }
        });
      } else {
        return;
      }
    }
  }

  static Future<bool> getFirestOrderOrNOt(OrderModel orderModel) async {
    bool isFirst = true;
    await firestore
        .collection(ORDERS)
        .where('authorID', isEqualTo: orderModel.authorID)
        .where('section_id', isEqualTo: orderModel.sectionId)
        .get()
        .then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateReferralAmount(OrderModel orderModel) async {
    ReferralModel? referralModel;
    print(orderModel.authorID);
    print(orderModel.sectionId);
    await getSectionBySectionId(orderModel.sectionId)
        .then((valueSection) async {
      await firestore
          .collection(REFERRAL)
          .doc(orderModel.authorID)
          .get()
          .then((value) {
        if (value.data() != null) {
          referralModel = ReferralModel.fromJson(value.data()!);
        } else {
          return;
        }
      });

      print("refferealAMount----->${valueSection!.referralAmount.toString()}");
      print("refferealAMount----->${referralModel!.referralBy}");

      if (referralModel != null) {
        if (referralModel!.referralBy != null &&
            referralModel!.referralBy!.isNotEmpty) {
          await firestore
              .collection(USERS)
              .doc(referralModel!.referralBy)
              .get()
              .then((value) async {
            DocumentSnapshot<Map<String, dynamic>> userDocument = value;
            if (userDocument.data() != null && userDocument.exists) {
              try {
                print(userDocument.data());
                User user = User.fromJson(userDocument.data()!);
                await firestore.collection(USERS).doc(user.userID).update({
                  "wallet_amount": user.walletAmount +
                      double.parse(valueSection.referralAmount.toString())
                }).then((value) => print("north"));

                await FireStoreUtils.createPaymentId().then((value) async {
                  final paymentID = value;
                  await FireStoreUtils.topUpWalletAmountRefral(
                      paymentMethod: "Referral Amount",
                      amount:
                          double.parse(valueSection.referralAmount.toString()),
                      id: paymentID,
                      userId: referralModel!.referralBy);
                });
              } catch (error) {
                print(error);
                if (error.toString() ==
                    "Bad state: field does not exist within the DocumentSnapshotPlatform") {
                  print("does not exist");
                  //await firestore.collection(USERS).doc(userId).update({"wallet_amount": 0});
                  //walletAmount = 0;
                } else {
                  print("went wrong!!");
                }
              }
              print("data val");
            }
          });
        } else {
          return;
        }
      }
    });
  }

  static Future<bool> getFirestOrderOrNOtCabService(
      CabOrderModel orderModel) async {
    bool isFirst = true;
    await firestore
        .collection(ORDERS)
        .where('authorID', isEqualTo: orderModel.authorID)
        .get()
        .then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateReferralAmountCabService(CabOrderModel orderModel) async {
    ReferralModel? referralModel;
    SectionModel? sectionModel;
    print(orderModel.authorID);
    await getSectionBySectionId(orderModel.sectionId.toString()).then((value) {
      sectionModel = value;
    });
    await firestore
        .collection(REFERRAL)
        .doc(orderModel.authorID)
        .get()
        .then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });

    if (referralModel != null) {
      if (referralModel!.referralBy != null &&
          referralModel!.referralBy!.isNotEmpty) {
        await firestore
            .collection(USERS)
            .doc(referralModel!.referralBy)
            .get()
            .then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              print(userDocument.data());
              User user = User.fromJson(userDocument.data()!);
              await firestore.collection(USERS).doc(user.userID).update({
                "wallet_amount": user.walletAmount +
                    double.parse(sectionModel!.referralAmount.toString())
              }).then((value) => print("north"));

              await FireStoreUtils.createPaymentId().then((value) async {
                final paymentID = value;
                await FireStoreUtils.topUpWalletAmountRefral(
                    paymentMethod: "Referral Amount",
                    amount:
                        double.parse(sectionModel!.referralAmount.toString()),
                    id: paymentID,
                    userId: referralModel!.referralBy);
              });
            } catch (error) {
              print(error);
              if (error.toString() ==
                  "Bad state: field does not exist within the DocumentSnapshotPlatform") {
                print("does not exist");
                //await firestore.collection(USERS).doc(userId).update({"wallet_amount": 0});
                //walletAmount = 0;
              } else {
                print("went wrong!!");
              }
            }
            print("data val");
          }
        });
      } else {
        return;
      }
    }
  }

  static sendTopUpMail(
      {required String amount,
      required String paymentMethod,
      required String tractionId}) async {
    EmailTemplateModel? emailTemplateModel =
        await FireStoreUtils.getEmailTemplates(walletTopup);

    String newString = emailTemplateModel!.message.toString();
    newString = newString.replaceAll(
        "{username}",
        MyAppState.currentUser!.firstName +
            " " +
            MyAppState.currentUser!.lastName);
    newString = newString.replaceAll(
        "{date}", DateFormat('dd-MM-yyyy').format(Timestamp.now().toDate()));
    newString = newString.replaceAll("{amount}", amountShow(amount: amount));
    newString =
        newString.replaceAll("{paymentmethod}", paymentMethod.toString());
    newString = newString.replaceAll("{transactionid}", tractionId.toString());
    newString = newString.replaceAll("{newwalletbalance}.",
        amountShow(amount: MyAppState.currentUser!.walletAmount.toString()));
    await sendMail(
        subject: emailTemplateModel.subject,
        isAdmin: emailTemplateModel.isSendToAdmin,
        body: newString,
        recipients: [MyAppState.currentUser!.email]);
  }

  static sendPayoutMail(
      {required String amount, required String payoutrequestid}) async {
    EmailTemplateModel? emailTemplateModel =
        await FireStoreUtils.getEmailTemplates(payoutRequest);

    String body = emailTemplateModel!.subject.toString();
    body = body.replaceAll("{userid}", MyAppState.currentUser!.userID);

    String newString = emailTemplateModel.message.toString();
    newString = newString.replaceAll(
        "{username}",
        MyAppState.currentUser!.firstName +
            " " +
            MyAppState.currentUser!.lastName);
    newString =
        newString.replaceAll("{userid}", MyAppState.currentUser!.userID);
    newString = newString.replaceAll("{amount}", amountShow(amount: amount));
    newString = newString.replaceAll(
        "{date}", DateFormat('dd-MM-yyyy').format(Timestamp.now().toDate()));
    newString =
        newString.replaceAll("{payoutrequestid}", payoutrequestid.toString());
    newString = newString.replaceAll("{usercontactinfo}",
        "${MyAppState.currentUser!.email}\n${MyAppState.currentUser!.phoneNumber}");
    await sendMail(
        subject: body,
        isAdmin: emailTemplateModel.isSendToAdmin,
        body: newString,
        recipients: [MyAppState.currentUser!.email]);
  }

  static Future<EmailTemplateModel?> getEmailTemplates(String type) async {
    EmailTemplateModel? emailTemplateModel;
    await firestore
        .collection(emailTemplates)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());
        emailTemplateModel =
            EmailTemplateModel.fromJson(value.docs.first.data());
      }
    });
    return emailTemplateModel;
  }

  static Future topUpWalletAmountRefral(
      {String paymentMethod = "test",
      bool isTopup = true,
      required amount,
      required id,
      orderId = "",
      userId}) async {
    print("this is te payment id");
    print(id);
    print(userId);

    await firestore.collection(Wallet).doc(id).set({
      "user_id": userId,
      "payment_method": paymentMethod,
      "amount": amount,
      "id": id,
      "order_id": orderId,
      "isTopUp": isTopup,
      "payment_status": "success",
      "date": DateTime.now(),
      "transactionUser": "driver",
    }).then((value) {
      firestore.collection(Wallet).doc(id).get().then((value) {
        DocumentSnapshot<Map<String, dynamic>> documentData = value;
        print("nato");
        print(documentData.data());
      });
    });

    return "updated Amount".tr();
  }

  static Future updateCabOrder(CabOrderModel orderModel) async {
    print("------->${orderModel.adminCommission}");
    await firestore
        .collection(RIDESORDER)
        .doc(orderModel.id)
        .set(orderModel.toJson(), SetOptions(merge: true));
  }

  late StreamController<OrderModel> ordersStreamController;
  late StreamSubscription ordersStreamSub;

  Stream<OrderModel?> getOrderByID(String inProgressOrderID) async* {
    ordersStreamController = StreamController();
    ordersStreamSub = firestore
        .collection(ORDERS)
        .doc(inProgressOrderID)
        .snapshots()
        .listen((onData) async {
      if (onData.data() != null) {
        OrderModel? orderModel = OrderModel.fromJson(onData.data()!);
        ordersStreamController.sink.add(orderModel);
      }
    });
    yield* ordersStreamController.stream;
  }

  late StreamController<CabOrderModel> cabOrdersStreamController;
  late StreamSubscription cabOrdersStreamSub;

  Stream<CabOrderModel?> getCabOrderByID(String inProgressOrderID) async* {
    cabOrdersStreamController = StreamController();
    cabOrdersStreamSub = firestore
        .collection(RIDESORDER)
        .doc(inProgressOrderID)
        .snapshots()
        .listen((onData) async {
      if (onData.data() != null) {
        CabOrderModel? orderModel = CabOrderModel.fromJson(onData.data()!);
        cabOrdersStreamController.sink.add(orderModel);
      }
    });
    yield* cabOrdersStreamController.stream;
  }

  late StreamController<ParcelOrderModel> parcelOrdersStreamController;
  late StreamSubscription parcelOrdersStreamSub;

  Stream<ParcelOrderModel?> getParcelOrderByID(
      String inProgressOrderID) async* {
    parcelOrdersStreamController = StreamController();
    parcelOrdersStreamSub = firestore
        .collection(PARCELORDER)
        .doc(inProgressOrderID)
        .snapshots()
        .listen((onData) async {
      if (onData.data() != null) {
        ParcelOrderModel? orderModel =
            ParcelOrderModel.fromJson(onData.data()!);
        parcelOrdersStreamController.sink.add(orderModel);
      }
    });
    yield* parcelOrdersStreamController.stream;
  }

  static Future updateParcelOrder(ParcelOrderModel orderModel) async {
    await firestore
        .collection(PARCELORDER)
        .doc(orderModel.id)
        .set(orderModel.toJson(), SetOptions(merge: true));
  }

  static Future updateRentalOrder(RentalOrderModel orderModel) async {
    await firestore
        .collection(RENTALORDER)
        .doc(orderModel.id)
        .set(orderModel.toJson(), SetOptions(merge: true));
  }

  /// compress image file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the image after
  /// being compressed(100 = max quality - 0 = low quality)
  /// @param file the image file that will be compressed
  /// @return File a new compressed file with smaller size
  static Future<File> compressImage(File file) async {
    File compressedImage = await FlutterNativeImage.compressImage(file.path,
        quality: 25, targetWidth: 300, targetHeight: 300);
    return compressedImage;
  }

  /// compress video file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the video after
  /// being compressed
  /// @param file the video file that will be compressed
  /// @return File a new compressed file with smaller size
  Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static loginWithFacebook() async {
    /// creates a user for this facebook login when this user first time login
    /// and save the new user object to firebase and firebase auth
    FacebookAuth facebookAuth = FacebookAuth.instance;
    bool isLogged = await facebookAuth.accessToken != null;
    if (!isLogged) {
      LoginResult result = await facebookAuth
          .login(); // by default we request the email and the public profile
      if (result.status == LoginStatus.success) {
        // you are logged
        AccessToken? token = await facebookAuth.accessToken;
        return await handleFacebookLogin(
            await facebookAuth.getUserData(), token!);
      }
    } else {
      AccessToken? token = await facebookAuth.accessToken;
      return await handleFacebookLogin(
          await facebookAuth.getUserData(), token!);
    }
  }

  static handleFacebookLogin(
      Map<String, dynamic> userData, AccessToken token) async {
    auth.UserCredential authResult = await auth.FirebaseAuth.instance
        .signInWithCredential(
            auth.FacebookAuthProvider.credential(token.token));
    print(authResult.user!.uid);
    User? user = await getCurrentUser(authResult.user?.uid ?? '');
    List<String> fullName = (userData['name'] as String).split(' ');
    String firstName = '';
    String lastName = '';
    if (fullName.isNotEmpty) {
      firstName = fullName.first;
      lastName = fullName.skip(1).join(' ');
    }
    if (user != null && user.role == USER_ROLE_DRIVER) {
      print('if');
      user.profilePictureURL = userData['picture']['data']['url'];
      user.firstName = firstName;
      user.lastName = lastName;
      user.email = userData['email'];
      user.isActive = false;
      user.role = USER_ROLE_DRIVER;
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      dynamic result = await updateCurrentUser(user);
      return result;
    } else if (user == null) {
      print('else');
      user = User(
          email: userData['email'] ?? '',
          firstName: firstName,
          profilePictureURL: userData['picture']['data']['url'] ?? '',
          userID: authResult.user?.uid ?? '',
          lastOnlineTimestamp: Timestamp.now(),
          lastName: lastName,
          isActive: false,
          role: USER_ROLE_DRIVER,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          carName: 'Uber Car',
          carNumber: 'No Plates',
          carPictureURL: DEFAULT_CAR_IMAGE,
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  static loginWithApple() async {
    final appleCredential = await apple.TheAppleSignIn.performRequests([
      apple.AppleIdRequest(
          requestedScopes: [apple.Scope.email, apple.Scope.fullName])
    ]);
    if (appleCredential.error != null) {
      return "Couldn't login with apple.".tr();
    }

    if (appleCredential.status == apple.AuthorizationStatus.authorized) {
      final auth.AuthCredential credential =
          auth.OAuthProvider('apple.com').credential(
        accessToken: String.fromCharCodes(
            appleCredential.credential?.authorizationCode ?? []),
        idToken: String.fromCharCodes(
            appleCredential.credential?.identityToken ?? []),
      );
      return await handleAppleLogin(credential, appleCredential.credential!);
    } else {
      return "Couldn't login with apple.".tr();
    }
  }

  static handleAppleLogin(
    auth.AuthCredential credential,
    apple.AppleIdCredential appleIdCredential,
  ) async {
    auth.UserCredential authResult =
        await auth.FirebaseAuth.instance.signInWithCredential(credential);
    User? user = await getCurrentUser(authResult.user?.uid ?? '');
    if (user != null) {
      user.isActive = false;
      user.role = USER_ROLE_DRIVER;
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      dynamic result = await updateCurrentUser(user);
      return result;
    } else {
      user = User(
          email: appleIdCredential.email ?? '',
          firstName: appleIdCredential.fullName?.givenName ?? '',
          profilePictureURL: '',
          userID: authResult.user?.uid ?? '',
          lastOnlineTimestamp: Timestamp.now(),
          lastName: appleIdCredential.fullName?.familyName ?? '',
          role: USER_ROLE_DRIVER,
          active: true,
          isActive: false,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          carName: 'Uber Car',
          carNumber: 'No Plates',
          carPictureURL: DEFAULT_CAR_IMAGE,
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  /// save a new user document in the USERS table in firebase firestore
  /// returns an error message on failure or null on success
  static Future<String?> firebaseCreateNewUser(User user) async {
    try {
      await firestore.collection(USERS).doc(user.userID).set(user.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return "Couldn't sign up".tr();
    }
    return null;
  }

  /// login with email and password with firebase
  /// @param email user email
  /// @param password user password
  static Future<dynamic> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      print('FireStoreUtils.loginWithEmailAndPassword');
      auth.UserCredential result = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await firestore.collection(USERS).doc(result.user?.uid ?? '').get();
      User? user;
      if (documentSnapshot.exists) {
        user = User.fromJson(documentSnapshot.data() ?? {});
        user.fcmToken = await firebaseMessaging.getToken() ?? '';
        user.role = USER_ROLE_DRIVER;
        user.isActive = false;
      }
      return user;
    } on auth.FirebaseAuthException catch (exception, s) {
      print(exception.toString() + '$s');
      switch ((exception).code) {
        case 'invalid-email':
          return 'Email address is malformed.'.tr();
        case 'wrong-password':
          return "Wrong password.".tr();
        case 'user-not-found':
          return 'No user corresponding to the given email address.'.tr();
        case 'user-disabled':
          return 'This user has been disabled.'.tr();
        case 'too-many-requests':
          return 'Too many attempts to sign in as this user.'.tr();
      }
      return 'Unexpected firebase error, Please try again.'.tr();
    } catch (e, s) {
      print(e.toString() + '$s');
      return 'Login failed, Please try again.'.tr();
    }
  }

  ///submit a phone number to firebase to receive a code verification, will
  ///be used later to login
  static firebaseSubmitPhoneNumber(
    String phoneNumber,
    auth.PhoneCodeAutoRetrievalTimeout? phoneCodeAutoRetrievalTimeout,
    auth.PhoneCodeSent? phoneCodeSent,
    auth.PhoneVerificationFailed? phoneVerificationFailed,
    auth.PhoneVerificationCompleted? phoneVerificationCompleted,
  ) {
    auth.FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(minutes: 2),
      phoneNumber: phoneNumber,
      verificationCompleted: phoneVerificationCompleted!,
      verificationFailed: phoneVerificationFailed!,
      codeSent: phoneCodeSent!,
      codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout!,
    );
  }

  /// submit the received code to firebase to complete the phone number
  /// verification process
  static Future<dynamic> firebaseSubmitPhoneNumberCode(
      String verificationID, String code, String phoneNumber,
      {String firstName = 'Anonymous',
      String lastName = 'User',
      File? image,
      File? carImage,
      String carName = '',
      String carPlates = '',
      String? serviceType = ''}) async {
    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: code);
    auth.UserCredential userCredential =
        await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
    User? user = await getCurrentUser(userCredential.user?.uid ?? '');
    if (user != null && user.role == USER_ROLE_DRIVER) {
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      user.role = USER_ROLE_DRIVER;
      user.isActive = false;
      await updateCurrentUser(user);
      return user;
    } else if (user == null) {
      /// create a new user from phone login
      String profileImageUrl = '';
      String carPicUrl = DEFAULT_CAR_IMAGE;
      if (image != null) {
        profileImageUrl = await uploadUserImageToFireStorage(
            image, userCredential.user?.uid ?? '');
      }
      if (carImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carPicUrl = await uploadCarImageToFireStorage(
            carImage, userCredential.user?.uid ?? '');
      }
      User user = User(
          firstName: firstName,
          lastName: lastName,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: phoneNumber,
          profilePictureURL: profileImageUrl,
          userID: userCredential.user?.uid ?? '',
          isActive: false,
          active: false,
          lastOnlineTimestamp: Timestamp.now(),
          settings: UserSettings(),
          email: '',
          role: USER_ROLE_DRIVER,
          carName: carName,
          carNumber: carPlates,
          carPictureURL: carPicUrl,
          serviceType: serviceType.toString());
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return "Couldn't create new user with phone number.".tr();
      }
    }
  }

  static Future<dynamic> firebaseSubmitPhoneNumberCodeParcelService(
      String verificationID, String code, String phoneNumber,
      {String firstName = 'Anonymous',
      String lastName = 'User',
      File? image,
      File? carImage,
      String carName = '',
      String carPlates = '',
      String? serviceType = ''}) async {
    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: code);
    auth.UserCredential userCredential =
        await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
    User? user = await getCurrentUser(userCredential.user?.uid ?? '');
    if (user != null && user.role == USER_ROLE_DRIVER) {
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      user.role = USER_ROLE_DRIVER;
      user.isActive = false;
      await updateCurrentUser(user);
      return user;
    } else if (user == null) {
      /// create a new user from phone login
      String profileImageUrl = '';
      String carPicUrl = DEFAULT_CAR_IMAGE;
      if (image != null) {
        profileImageUrl = await uploadUserImageToFireStorage(
            image, userCredential.user?.uid ?? '');
      }
      if (carImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carPicUrl = await uploadCarImageToFireStorage(
            carImage, userCredential.user?.uid ?? '');
      }
      User user = User(
          firstName: firstName,
          lastName: lastName,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: phoneNumber,
          profilePictureURL: profileImageUrl,
          userID: userCredential.user?.uid ?? '',
          isActive: false,
          active: false,
          lastOnlineTimestamp: Timestamp.now(),
          settings: UserSettings(),
          email: '',
          role: USER_ROLE_DRIVER,
          carName: carName,
          carNumber: carPlates,
          carPictureURL: carPicUrl,
          serviceType: serviceType.toString());
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return "Couldn't create new user with phone number.".tr();
      }
    }
  }

  static Future<dynamic> firebaseSubmitPhoneNumberCodeCabService(
      String verificationID, String code, String phoneNumber,
      {String firstName = 'Anonymous',
      String lastName = 'User',
      File? image,
      File? carImage,
      String carMakes = '',
      String carName = '',
      String carPlates = '',
      String? vehicleType = '',
      String? serviceType = ''}) async {
    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: code);
    auth.UserCredential userCredential =
        await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
    User? user = await getCurrentUser(userCredential.user?.uid ?? '');
    if (user != null && user.role == USER_ROLE_DRIVER) {
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      user.role = USER_ROLE_DRIVER;
      user.isActive = false;
      await updateCurrentUser(user);
      return user;
    } else if (user == null) {
      /// create a new user from phone login
      String profileImageUrl = '';
      String carPicUrl = DEFAULT_CAR_IMAGE;
      if (image != null) {
        profileImageUrl = await uploadUserImageToFireStorage(
            image, userCredential.user?.uid ?? '');
      }
      if (carImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carPicUrl = await uploadCarImageToFireStorage(
            carImage, userCredential.user?.uid ?? '');
      }
      User user = User(
        firstName: firstName,
        lastName: lastName,
        fcmToken: await firebaseMessaging.getToken() ?? '',
        phoneNumber: phoneNumber,
        profilePictureURL: profileImageUrl,
        userID: userCredential.user?.uid ?? '',
        isActive: false,
        active: false,
        lastOnlineTimestamp: Timestamp.now(),
        settings: UserSettings(),
        email: '',
        role: USER_ROLE_DRIVER,
        carName: carName,
        carMakes: carMakes,
        carNumber: carPlates,
        carPictureURL: carPicUrl,
        vehicleType: vehicleType.toString(),
        serviceType: serviceType.toString(),
      );
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return "Couldn't create new user with phone number.".tr();
      }
    }
  }

  static firebaseSignUpWithEmailAndPassword(
      String emailAddress,
      String password,
      File? image,
      File? carImage,
      File? passportImage,
      File? licenceImage,
      File? diskimage,
      File? insuaranceImage,
      File? driverProofImage,
      File? carProofImage,
      String carName,
      String carPlate,
      String firstName,
      String lastName,
      String mobile,
      String serviceType) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailAddress, password: password);
      String profilePicUrl = '';
      String carPicUrl = DEFAULT_CAR_IMAGE;
      String passportPicUrl = '';
      String licenceUrl = '';
      String diskUrl = '';
      String insuranceUrl = '';

      String driverProofUrl = '';
      String carProofUrl = '';

      if (image != null) {
        updateProgress('Uploading image, Please wait...'.tr());
        profilePicUrl =
            await uploadUserImageToFireStorage(image, result.user?.uid ?? '');
      }
      if (carImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carPicUrl =
            await uploadCarImageToFireStorage(carImage, result.user?.uid ?? '');
      }
      if (passportImage != null) {
        updateProgress('Uploading passportImage, Please wait...'.tr());
        passportPicUrl = await uploadCarImageToFireStorage(
            passportImage, result.user?.uid ?? '');
      }
      if (licenceImage != null) {
        updateProgress('Uploading licenceImage, Please wait...'.tr());
        licenceUrl = await uploadCarImageToFireStorage(
            licenceImage, result.user?.uid ?? '');
      }
      if (diskimage != null) {
        updateProgress('Uploading diskimage, Please wait...'.tr());
        diskUrl = await uploadCarImageToFireStorage(
            diskimage, result.user?.uid ?? '');
      }
      if (insuaranceImage != null) {
        updateProgress('Uploading insuaranceImage, Please wait...'.tr());
        insuranceUrl = await uploadCarImageToFireStorage(
            insuaranceImage, result.user?.uid ?? '');
      }

      if (driverProofImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        driverProofUrl = await uploadCarImageToFireStorage(
            driverProofImage, Timestamp.now().toString() ?? '');
      }
      if (carProofImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carProofUrl = await uploadCarImageToFireStorage(
            carProofImage, Timestamp.now().toString() ?? '');
      }

      User user = User(
        email: emailAddress,
        settings: UserSettings(),
        lastOnlineTimestamp: Timestamp.now(),
        isActive: false,
        active: false,
        phoneNumber: mobile,
        firstName: firstName,
        userID: result.user?.uid ?? '',
        lastName: lastName,
        fcmToken: await firebaseMessaging.getToken() ?? '',
        profilePictureURL: profilePicUrl,
        carPictureURL: carPicUrl,
        passportUrl: passportPicUrl,
        licenceUrl: licenceUrl,
        diskUrl: diskUrl,
        insuranceUrl: insuranceUrl,
        carNumber: carPlate,
        carName: carName,
        role: USER_ROLE_DRIVER,
        serviceType: serviceType,
        carProofPictureURL: carProofUrl,
        driverProofPictureURL: driverProofUrl,
        createdAt: Timestamp.now(),
      );
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return "Couldn't sign up for firebase, Please try again.".tr();
      }
    } on auth.FirebaseAuthException catch (error) {
      print(error.toString() + '${error.stackTrace}');
      String message = "Couldn't sign up".tr();
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use, Please pick another email!'.tr();
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail'.tr();
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled'.tr();
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters'.tr();
          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.'.tr();
          break;
      }
      return message;
    } catch (e) {
      return "Couldn't sign up".tr();
    }
  }

  static firebaseSignUpWithEmailAndPasswordRentalService(
      String emailAddress,
      String password,
      File? image,
      File? carImage,
      File? driverProofImage,
      File? carProofImage,
      File? passportImage,
      File? licenceImage,
      File? diskimage,
      File? insuaranceImage,
      String carName,
      String carPlate,
      String firstName,
      String lastName,
      String mobile,
      String serviceType,
      String vehicleType,
      String companyOrNot,
      String companyName,
      String companyAddress) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailAddress, password: password);
      String profilePicUrl = '';
      String carPicUrl = DEFAULT_CAR_IMAGE;
      String driverProofUrl = '';
      String carProofUrl = '';
      String passportPicUrl = '';
      String licenceUrl = '';
      String diskUrl = '';
      String insuranceUrl = '';
      if (image != null) {
        updateProgress('Uploading image, Please wait...'.tr());
        profilePicUrl =
            await uploadUserImageToFireStorage(image, result.user?.uid ?? '');
      }
      if (carImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carPicUrl =
            await uploadCarImageToFireStorage(carImage, result.user?.uid ?? '');
      }
      if (passportImage != null) {
        updateProgress('Uploading passportImage, Please wait...'.tr());
        passportPicUrl = await uploadCarImageToFireStorage(
            passportImage, result.user?.uid ?? '');
      }
      if (licenceImage != null) {
        updateProgress('Uploading licenceImage, Please wait...'.tr());
        licenceUrl = await uploadCarImageToFireStorage(
            licenceImage, result.user?.uid ?? '');
      }
      if (diskimage != null) {
        updateProgress('Uploading diskimage, Please wait...'.tr());
        diskUrl = await uploadCarImageToFireStorage(
            diskimage, result.user?.uid ?? '');
      }
      if (insuaranceImage != null) {
        updateProgress('Uploading insuaranceImage, Please wait...'.tr());
        insuranceUrl = await uploadCarImageToFireStorage(
            insuaranceImage, result.user?.uid ?? '');
      }

      if (driverProofImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        driverProofUrl = await uploadCarImageToFireStorage(
            driverProofImage, Timestamp.now().toString() ?? '');
      }
      if (carProofImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carProofUrl = await uploadCarImageToFireStorage(
            carProofImage, Timestamp.now().toString() ?? '');
      }

      User user = User(
        email: emailAddress,
        settings: UserSettings(),
        lastOnlineTimestamp: Timestamp.now(),
        isActive: false,
        active: false,
        phoneNumber: mobile,
        firstName: firstName,
        userID: result.user?.uid ?? '',
        lastName: lastName,
        fcmToken: await firebaseMessaging.getToken() ?? '',
        profilePictureURL: profilePicUrl,
        carPictureURL: carPicUrl,
        carNumber: carPlate,
        carName: carName,
        passportUrl: passportPicUrl,
        licenceUrl: licenceUrl,
        diskUrl: diskUrl,
        insuranceUrl: insuranceUrl,
        // isCompany: companyOrNot == "company" ? true : false,
        // companyName: companyName,
        // companyAddress: companyAddress,
        role: USER_ROLE_DRIVER,
        serviceType: serviceType,
        vehicleType: vehicleType,
        carProofPictureURL: carProofUrl,
        driverProofPictureURL: driverProofUrl,
        createdAt: Timestamp.now(),
      );
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return "Couldn't sign up for firebase, Please try again.".tr();
      }
    } on auth.FirebaseAuthException catch (error) {
      print(error.toString() + '${error.stackTrace}');
      String message = "Couldn't sign up".tr();
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use, Please pick another email!'.tr();
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail'.tr();
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled'.tr();
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters'.tr();
          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.'.tr();
          break;
      }
      return message;
    } catch (e) {
      return "Couldn't sign up".tr();
    }
  }

  static firebaseSignUpWithEmailAndPasswordCabService(
    String emailAddress,
    String password,
    File? image,
    File? carImage,
    File? driverProofImage,
    File? carProofImage,
    File? passportImage,
    File? licenceImage,
    File? diskimage,
    File? insuaranceImage,
    String vehicleType,
    String carMakes,
    String carModel,
    String carPlate,
    String carColor,
    String firstName,
    String lastName,
    String mobile,
    String serviceType,
    String companyOrNot,
    String companyName,
    String companyAddress,
    String sectionId,
    String vehicleId,
  ) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailAddress, password: password);
      String profilePicUrl = '';
      String carPicUrl = DEFAULT_CAR_IMAGE;
      String driverProofUrl = '';
      String passportPicUrl = '';
      String licenceUrl = '';
      String diskUrl = '';
      String insuranceUrl = '';
      String carProofUrl = '';
      if (image != null) {
        updateProgress('Uploading image, Please wait...'.tr());
        profilePicUrl =
            await uploadUserImageToFireStorage(image, result.user?.uid ?? '');
      }
      if (carImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carPicUrl =
            await uploadCarImageToFireStorage(carImage, result.user?.uid ?? '');
      }

      if (driverProofImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        driverProofUrl = await uploadCarImageToFireStorage(
            driverProofImage, Timestamp.now().toString() ?? '');
      }
      if (carProofImage != null) {
        updateProgress('Uploading car image, Please wait...'.tr());
        carProofUrl = await uploadCarImageToFireStorage(
            carProofImage, Timestamp.now().toString() ?? '');
      }
      if (passportImage != null) {
        updateProgress('Uploading passportImage, Please wait...'.tr());
        passportPicUrl = await uploadCarImageToFireStorage(
            passportImage, result.user?.uid ?? '');
      }
      if (licenceImage != null) {
        updateProgress('Uploading licenceImage, Please wait...'.tr());
        licenceUrl = await uploadCarImageToFireStorage(
            licenceImage, result.user?.uid ?? '');
      }
      if (diskimage != null) {
        updateProgress('Uploading diskimage, Please wait...'.tr());
        diskUrl = await uploadCarImageToFireStorage(
            diskimage, result.user?.uid ?? '');
      }
      if (insuaranceImage != null) {
        updateProgress('Uploading insuaranceImage, Please wait...'.tr());
        insuranceUrl = await uploadCarImageToFireStorage(
            insuaranceImage, result.user?.uid ?? '');
      }

      User user = User(
          email: emailAddress,
          settings: UserSettings(),
          lastOnlineTimestamp: Timestamp.now(),
          isActive: false,
          active: false,
          phoneNumber: mobile,
          firstName: firstName,
          userID: result.user?.uid ?? '',
          lastName: lastName,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          profilePictureURL: profilePicUrl,
          carPictureURL: carPicUrl,
          carNumber: carPlate,
          passportUrl: passportPicUrl,
          licenceUrl: licenceUrl,
          diskUrl: diskUrl,
          insuranceUrl: insuranceUrl,
          carName: carModel,
          carMakes: carMakes,
          vehicleType: vehicleType,
          serviceType: serviceType,
          role: USER_ROLE_DRIVER,
          // isCompany: companyOrNot == "company" ? true : false,
          // companyName: companyName,
          // companyAddress: companyAddress,
          carProofPictureURL: carProofUrl,
          driverProofPictureURL: driverProofUrl,
          carColor: carColor,
          sectionId: sectionId,
          rideType: 'ride',
          vehicleId: vehicleId,
          createdAt: Timestamp.now());
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t sign up for firebase, Please try again.'.tr();
      }
    } on auth.FirebaseAuthException catch (error) {
      print(error.toString() + '${error.stackTrace}');
      String message = 'Couldn\'t sign up';
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use, Please pick another email!';
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters';
          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.';
          break;
      }
      return message;
    } catch (e) {
      return 'Couldn\'t sign up';
    }
  }

  static Future<auth.UserCredential?> reAuthUser(AuthProviders provider,
      {String? email,
      String? password,
      String? smsCode,
      String? verificationId,
      AccessToken? accessToken,
      apple.AuthorizationResult? appleCredential}) async {
    late auth.AuthCredential credential;
    switch (provider) {
      case AuthProviders.PASSWORD:
        credential = auth.EmailAuthProvider.credential(
            email: email!, password: password!);
        break;
      case AuthProviders.PHONE:
        credential = auth.PhoneAuthProvider.credential(
            smsCode: smsCode!, verificationId: verificationId!);
        break;
      case AuthProviders.FACEBOOK:
        credential = auth.FacebookAuthProvider.credential(accessToken!.token);
        break;
      case AuthProviders.APPLE:
        credential = auth.OAuthProvider('apple.com').credential(
          accessToken: String.fromCharCodes(
              appleCredential!.credential?.authorizationCode ?? []),
          idToken: String.fromCharCodes(
              appleCredential.credential?.identityToken ?? []),
        );
        break;
    }
    return await auth.FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(credential);
  }

  static resetPassword(String emailAddress) async =>
      await auth.FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailAddress);

  static deleteUser() async {
    try {
      // delete user records from CHANNEL_PARTICIPATION table

      // delete user records from REPORTS table
      await firestore
          .collection(REPORTS)
          .where('source', isEqualTo: MyAppState.currentUser!.userID)
          .get()
          .then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from REPORTS table
      await firestore
          .collection(REPORTS)
          .where('dest', isEqualTo: MyAppState.currentUser!.userID)
          .get()
          .then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from users table
      await firestore
          .collection(USERS)
          .doc(auth.FirebaseAuth.instance.currentUser!.uid)
          .delete();

      // delete user  from firebase auth
      await auth.FirebaseAuth.instance.currentUser!.delete();
    } catch (e, s) {
      print('FireStoreUtils.deleteUser $e $s');
    }
  }

  Future deleteOtherUser(String uid) async {
    try {
      // delete user records from REPORTS table
      await firestore
          .collection(REPORTS)
          .where('source', isEqualTo: uid)
          .get()
          .then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from REPORTS table
      await firestore
          .collection(REPORTS)
          .where('dest', isEqualTo: uid)
          .get()
          .then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      await firestore.collection(USERS).doc(uid).delete();

      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('deleteUser');
      final resp = await callable.call(<String, dynamic>{
        'uid': uid,
      });
      print("result: ${resp.data}");
    } catch (e, s) {
      print('FireStoreUtils.deleteUser $e $s');
    }
  }

  static Future<NotificationModel?> getNotificationContent(String type) async {
    NotificationModel? notificationModel;
    await firestore
        .collection(dynamicNotification)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());

        notificationModel = NotificationModel.fromJson(value.docs.first.data());
      } else {
        notificationModel = NotificationModel(
            id: "",
            message: "Notification setup is pending",
            subject: "setup notification",
            type: "");
      }
    });
    return notificationModel;
  }

  static Future<bool> sendFcmMessage(
      String type, String token, Map<String, dynamic>? payload) async {
    try {
      NotificationModel? notificationModel = await getNotificationContent(type);
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=$SERVER_KEY",
      };
      var request = {
        "notification": {
          "title": notificationModel!.subject ?? '',
          "body": notificationModel.message ?? '',
          "sound": "default",
        },
        "priority": "high",
        'data': payload ?? <String, dynamic>{},
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "to": token
      };

      var client = new http.Client();
      await client.post(Uri.parse(url),
          headers: header, body: json.encode(request));
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> sendChatFcmMessage(String title, String message,
      String token, Map<String, dynamic>? payload) async {
    print(token.toString() + "====================TOKEN");
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=$SERVER_KEY",
      };
      var request = {
        "notification": {
          "title": title,
          "body": message,
          "sound": "default",
          // "color": COLOR_PRIMARY,
        },
        "priority": "high",
        // 'data': <String, dynamic>{'id': '1', 'status': 'done'},
        'data': payload ?? <String, dynamic>{},
        "to": token,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
      };

      var client = new http.Client();
      await client.post(Uri.parse(url),
          headers: header, body: json.encode(request));

      print('done........');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static getPayFastSettingData() async {
    firestore
        .collection(Setting)
        .doc("payFastSettings")
        .get()
        .then((payFastData) {
      debugPrint(payFastData.data().toString());
      try {
        PayFastSettingData payFastSettingData =
            PayFastSettingData.fromJson(payFastData.data() ?? {});
        debugPrint(">122");
        debugPrint(payFastSettingData.toJson().toString());
        UserPreference.setPayFastData(payFastSettingData);
      } catch (error) {
        debugPrint("error>>>122");
        debugPrint(error.toString());
      }
    });
  }

  static getMercadoPagoSettingData() async {
    firestore.collection(Setting).doc("MercadoPago").get().then((mercadoPago) {
      try {
        MercadoPagoSettingData mercadoPagoDataModel =
            MercadoPagoSettingData.fromJson(mercadoPago.data() ?? {});
        UserPreference.setMercadoPago(mercadoPagoDataModel);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }

  static getPaypalSettingData() async {
    firestore
        .collection(Setting)
        .doc("paypalSettings")
        .get()
        .then((paypalData) {
      try {
        PaypalSettingData paypalDataModel =
            PaypalSettingData.fromJson(paypalData.data() ?? {});
        UserPreference.setPayPalData(paypalDataModel);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }

  static getStripeSettingData() async {
    firestore
        .collection(Setting)
        .doc("stripeSettings")
        .get()
        .then((stripeData) {
      try {
        StripeSettingData stripeSettingData =
            StripeSettingData.fromJson(stripeData.data() ?? {});
        UserPreference.setStripeData(stripeSettingData);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }

  static getFlutterWaveSettingData() async {
    firestore
        .collection(Setting)
        .doc("flutterWave")
        .get()
        .then((flutterWaveData) {
      try {
        FlutterWaveSettingData flutterWaveSettingData =
            FlutterWaveSettingData.fromJson(flutterWaveData.data() ?? {});
        UserPreference.setFlutterWaveData(flutterWaveSettingData);
      } catch (error) {
        debugPrint("error>>>122");
        debugPrint(error.toString());
      }
    });
  }

  static getPayStackSettingData() async {
    firestore.collection(Setting).doc("payStack").get().then((payStackData) {
      try {
        PayStackSettingData payStackSettingData =
            PayStackSettingData.fromJson(payStackData.data() ?? {});
        UserPreference.setPayStackData(payStackSettingData);
      } catch (error) {
        debugPrint("error>>>122");
        debugPrint(error.toString());
      }
    });
  }

  static getPaytmSettingData() async {
    firestore.collection(Setting).doc("PaytmSettings").get().then((paytmData) {
      try {
        PaytmSettingData paytmSettingData =
            PaytmSettingData.fromJson(paytmData.data() ?? {});
        UserPreference.setPaytmData(paytmSettingData);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }

  static getWalletSettingData() {
    firestore
        .collection(Setting)
        .doc('walletSettings')
        .get()
        .then((walletSetting) {
      try {
        bool walletEnable = walletSetting.data()!['isEnabled'];

        UserPreference.setWalletData(walletEnable);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  getRazorPayDemo() async {
    RazorPayModel userModel;
    firestore.collection(Setting).doc("razorpaySettings").get().then((user) {
      debugPrint(user.data().toString());
      try {
        userModel = RazorPayModel.fromJson(user.data() ?? {});
        UserPreference.setRazorPayData(userModel);
        RazorPayModel fhg = UserPreference.getRazorPayData();
        debugPrint(fhg.razorpayKey);
        //
        // RazorPayController().updateRazorPayData(razorPayData: userModel);
      } catch (e) {
        debugPrint(
            'FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });

    //yield* razorPayStreamController.stream;
  }

  static getDriverNearByValue() async {
    try {
      print(MyAppState.currentUser!.userID);
      await firestore
          .collection(Setting)
          .doc("DriverNearBy")
          .get()
          .then((value) {
        minimumDepositToRideAccept =
            value.data()!['minimumDepositToRideAccept'];
        minimumAmountToWithdrawal = value.data()!['minimumAmountToWithdrawal'];
      });
      print(minimumDepositToRideAccept);
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
  }
}
