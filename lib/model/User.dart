import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nocdriver/Parcel_service/parcel_order_model.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/model/AddressModel.dart';
import 'package:nocdriver/model/CabOrderModel.dart';
import 'package:nocdriver/model/OrderModel.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  String rideType;
  String email;

  String firstName;

  String lastName;

  UserSettings settings;

  String phoneNumber;

  bool active;
  bool isActive;

  Timestamp lastOnlineTimestamp;

  String userID;

  String profilePictureURL;
  String passportUrl;
  String licenceUrl;
  String diskUrl;
  String insuranceUrl;
  String driverEvpNo;
  String evpPictureURL;
  String carProofPictureURL;
  String driverProofPictureURL;

  String appIdentifier;

  String fcmToken;

  UserLocation location;

  AddressModel shippingAddress;

  String role;

  String carName;

  String carNumber;
  String carColor;

  String carPictureURL;

  String? inProgressOrderID;

  OrderModel? orderRequestData;
  CabOrderModel? ordercabRequestData;
  ParcelOrderModel? orderParcelRequestData;
  UserBankDetails userBankDetails;
  GeoFireData geoFireData;
  GeoPoint coordinates;
  String serviceType;
  String vehicleType;
  String vehicleId;
  String carMakes;
  // bool isCompany;
  // String companyId;
  // String companyName;
  // String companyAddress;

  num walletAmount;
  num? rotation;
  num reviewsCount;
  num reviewsSum;
  String driverRate;
  String carRate;
  String? sectionId;
  CarInfo? carInfo;
  List<dynamic>? rentalBookingDate;
  Timestamp? createdAt;

  User(
      {this.email = '',
      this.rideType = '',
      this.userID = '',
      this.insuranceUrl = '',
      this.diskUrl = '',
      this.licenceUrl = '',
      this.passportUrl = '',
      this.profilePictureURL = '',
      this.driverEvpNo = '',
      this.evpPictureURL = '',
      this.carProofPictureURL = '',
      this.driverProofPictureURL = '',
      this.firstName = '',
      this.phoneNumber = '',
      this.lastName = '',
      this.active = false,
      this.isActive = false,
      lastOnlineTimestamp,
      settings,
      this.fcmToken = '',
      location,
      shippingAddress,
      this.role = USER_ROLE_DRIVER,
      this.carName = 'Uber Car',
      this.carNumber = 'No Plates',
      this.carColor = '',
      this.carPictureURL = DEFAULT_CAR_IMAGE,
      this.inProgressOrderID,
      this.walletAmount = 0.0,
      this.serviceType = "",
      this.vehicleType = "",
      this.vehicleId = "",
      this.carMakes = "",
      // this.isCompany = false,
      // this.companyId = "",
      // this.companyName = "",
      // this.companyAddress = "",
      this.rotation,
      this.rentalBookingDate,
      this.reviewsCount = 0,
      this.reviewsSum = 0,
      this.driverRate = "0",
      this.carRate = "0",
      userBankDetails,
      geoFireData,
      coordinates,
      carInfo,
      this.orderRequestData,
      this.ordercabRequestData,
      this.orderParcelRequestData,
      this.createdAt,
      this.sectionId})
      : this.lastOnlineTimestamp = lastOnlineTimestamp ?? Timestamp.now(),
        this.settings = settings ?? UserSettings(),
        this.appIdentifier = 'eMart Driver ${Platform.operatingSystem}',
        this.shippingAddress = shippingAddress ?? AddressModel(),
        this.userBankDetails = userBankDetails ?? UserBankDetails(),
        this.location = location ?? UserLocation(),
        this.coordinates = coordinates ?? GeoPoint(0.0, 0.0),
        this.carInfo = carInfo ?? CarInfo(),
        this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );

  String fullName() {
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
        email: parsedJson['email'] ?? '',
        rideType: parsedJson['rideType'] ?? '',
        walletAmount: parsedJson['wallet_amount'] ?? 0.0,
        userBankDetails: parsedJson.containsKey('userBankDetails')
            ? UserBankDetails.fromJson(parsedJson['userBankDetails'])
            : UserBankDetails(),
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        geoFireData: parsedJson.containsKey('g')
            ? GeoFireData.fromJson(parsedJson['g'])
            : GeoFireData(
                geohash: "",
                geoPoint: GeoPoint(0.0, 0.0),
              ),
        coordinates: parsedJson['coordinates'] ?? GeoPoint(0.0, 0.0),
        isActive: parsedJson['isActive'] ?? false,
        rotation: parsedJson['rotation'] ?? 0.0,
        active: parsedJson['active'] ?? true,
        vehicleType: parsedJson['vehicleType'] ?? '',
        vehicleId: parsedJson['vehicleId'] ?? '',
        carMakes: parsedJson['carMakes'] ?? '',
        lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
        settings: parsedJson.containsKey('settings')
            ? UserSettings.fromJson(parsedJson['settings'])
            : UserSettings(),
        phoneNumber: parsedJson['phoneNumber'] ?? '',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '',
        passportUrl: parsedJson['passportUrl'] ?? '',
        licenceUrl: parsedJson['licenceUrl'] ?? '',
        diskUrl: parsedJson['diskUrl'] ?? '',
        insuranceUrl: parsedJson['insuaranceUrl'] ?? '',
        driverEvpNo: parsedJson['driverEvpNo'] ?? '',
        evpPictureURL: parsedJson['evpPictureURL'] ?? '',
        driverProofPictureURL: parsedJson['driverProofPictureURL'] ?? '',
        carProofPictureURL: parsedJson['carProofPictureURL'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        serviceType: parsedJson['serviceType'] ?? '',
        driverRate: parsedJson['driverRate'] ?? '0',
        carRate: parsedJson['carRate'] ?? '0',
        rentalBookingDate: parsedJson['rentalBookingDate'] ?? [],
        carInfo: parsedJson.containsKey('carInfo')
            ? CarInfo.fromJson(parsedJson['carInfo'])
            : CarInfo(),
        location: parsedJson.containsKey('location')
            ? UserLocation.fromJson(parsedJson['location'])
            : UserLocation(),
        shippingAddress: parsedJson.containsKey('shippingAddress')
            ? AddressModel.fromJson(parsedJson['shippingAddress'])
            : AddressModel(),
        role: parsedJson['role'] ?? '',
        carName: parsedJson['carName'] ?? '',
        carNumber: parsedJson['carNumber'] ?? '',
        carColor: parsedJson['carColor'] ?? '',
        // isCompany: parsedJson['isCompany'] ?? false,
        // companyId: parsedJson['companyId'] ?? '',
        // companyName: parsedJson['companyName'] ?? '',
        // companyAddress: parsedJson['companyAddress'] ?? '',
        carPictureURL: parsedJson['carPictureURL'] ?? '',
        inProgressOrderID: parsedJson['inProgressOrderID'],
        reviewsCount: parsedJson['reviewsCount'] ?? 0,
        reviewsSum: parsedJson['reviewsSum'] ?? 0,
        sectionId: parsedJson['sectionId'] ?? '',
        createdAt: parsedJson['createdAt'],
        orderRequestData: parsedJson.containsKey('orderRequestData') &&
                parsedJson['orderRequestData'] != null
            ? OrderModel.fromJson(parsedJson['orderRequestData'])
            : null,
        ordercabRequestData: parsedJson.containsKey('ordercabRequestData') &&
                parsedJson['ordercabRequestData'] != null
            ? CabOrderModel.fromJson(parsedJson['ordercabRequestData'])
            : null,
        orderParcelRequestData: parsedJson
                    .containsKey('orderParcelRequestData') &&
                parsedJson['orderParcelRequestData'] != null
            ? ParcelOrderModel.fromJson(parsedJson['orderParcelRequestData'])
            : null);
  }

  factory User.fromPayload(Map<String, dynamic> parsedJson) {
    return User(
        rideType: parsedJson['rideType'] ?? '',
        email: parsedJson['email'] ?? '',
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        walletAmount: parsedJson['wallet_amount'] ?? 0.0,
        rotation: parsedJson['rotation'] ?? 0.0,
        userBankDetails: parsedJson.containsKey('userBankDetails')
            ? UserBankDetails.fromJson(parsedJson['userBankDetails'])
            : UserBankDetails(),
        isActive: parsedJson['isActive'] ?? false,
        active: parsedJson['active'] ?? true,
        serviceType: parsedJson['serviceType'] ?? '',
        geoFireData: parsedJson.containsKey('g')
            ? GeoFireData.fromJson(parsedJson['g'])
            : GeoFireData(
                geohash: "",
                geoPoint: GeoPoint(0.0, 0.0),
              ),
        coordinates: parsedJson['coordinates'] ?? GeoPoint(0.0, 0.0),
        lastOnlineTimestamp: Timestamp.fromMillisecondsSinceEpoch(
            parsedJson['lastOnlineTimestamp']),
        settings: parsedJson.containsKey('settings')
            ? UserSettings.fromJson(parsedJson['settings'])
            : UserSettings(),
        phoneNumber: parsedJson['phoneNumber'] ?? '',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '',
        passportUrl: parsedJson['passportUrl'] ?? '',
        licenceUrl: parsedJson['licenceUrl'] ?? '',
        diskUrl: parsedJson['diskUrl'] ?? '',
        insuranceUrl: parsedJson['insuaranceUrl'] ?? '',
        driverEvpNo: parsedJson['driverEvpNo'] ?? '',
        evpPictureURL: parsedJson['evpPictureURL'] ?? '',
        driverProofPictureURL: parsedJson['driverProofPictureURL'] ?? '',
        carProofPictureURL: parsedJson['carProofPictureURL'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        location: parsedJson.containsKey('location')
            ? UserLocation.fromJson(parsedJson['location'])
            : UserLocation(),
        shippingAddress: parsedJson.containsKey('shippingAddress')
            ? AddressModel.fromJson(parsedJson['shippingAddress'])
            : AddressModel(),
        role: parsedJson['role'] ?? '',
        carName: parsedJson['carName'] ?? '',
        carNumber: parsedJson['carNumber'] ?? '',
        carColor: parsedJson['carColor'] ?? '',
        vehicleType: parsedJson['vehicleType'] ?? '',
        vehicleId: parsedJson['vehicleId'] ?? '',
        carMakes: parsedJson['carMakes'] ?? '',
        // isCompany: parsedJson['isCompany'] ?? false,
        // companyId: parsedJson['companyId'] ?? '',
        // companyName: parsedJson['companyName'] ?? '',
        // companyAddress: parsedJson['companyAddress'] ?? '',
        carPictureURL: parsedJson['carPictureURL'] ?? '',
        inProgressOrderID: parsedJson['inProgressOrderID'],
        reviewsCount: parsedJson['reviewsCount'] ?? 0,
        reviewsSum: parsedJson['reviewsSum'] ?? 0,
        driverRate: parsedJson['driverRate'] ?? '',
        carRate: parsedJson['carRate'] ?? '',
        sectionId: parsedJson['sectionId'] ?? '',
        rentalBookingDate: parsedJson['rentalBookingDate'] ?? [],
        carInfo: parsedJson.containsKey('carInfo')
            ? CarInfo.fromJson(parsedJson['carInfo'])
            : CarInfo(),
        orderRequestData: parsedJson.containsKey('orderRequestData') &&
                parsedJson['orderRequestData'] != null
            ? OrderModel.fromJson(parsedJson['orderRequestData'])
            : null,
        ordercabRequestData: parsedJson.containsKey('ordercabRequestData') &&
                parsedJson['ordercabRequestData'] != null
            ? CabOrderModel.fromJson(parsedJson['ordercabRequestData'])
            : null,
        orderParcelRequestData: parsedJson
                    .containsKey('orderParcelRequestData') &&
                parsedJson['orderParcelRequestData'] != null
            ? ParcelOrderModel.fromJson(parsedJson['orderParcelRequestData'])
            : null);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'wallet_amount': this.walletAmount,
      "userBankDetails": this.userBankDetails.toJson(),
      'id': this.userID,
      'isActive': this.isActive,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'profilePictureURL': this.profilePictureURL,
      'passportUrl': this.passportUrl,
      'licenceUrl': this.licenceUrl,
      'diskUrl': this.diskUrl,
      'insuaranceUrl': this.insuranceUrl,
      'driverEvpNo': this.driverEvpNo,
      'evpPictureURL': this.evpPictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      'shippingAddress': this.shippingAddress.toJson(),
      'role': this.role,
      "g": this.geoFireData.toJson(),
      'coordinates': this.coordinates,
      'createdAt': this.createdAt,
    };
    if (this.role == USER_ROLE_DRIVER) {
      json.addAll({
        'rideType': this.rideType,
        'role': this.role,
        'carName': this.carName,
        'carNumber': this.carNumber,
        'carColor': this.carColor,
        'carPictureURL': this.carPictureURL,
        'vehicleType': this.vehicleType,
        'vehicleId': this.vehicleId,
        'carMakes': this.carMakes,
        'rotation': this.rotation,
        'reviewsCount': this.reviewsCount,
        'reviewsSum': this.reviewsSum,
        // 'isCompany': this.isCompany,
        // 'companyId': this.companyId,
        // 'companyName': this.companyName,
        // 'companyAddress': this.companyAddress,
        'serviceType': this.serviceType,
        'driverRate': this.driverRate,
        'carRate': this.carRate,
        'carInfo': this.carInfo!.toJson(),
        'rentalBookingDate': this.rentalBookingDate,
        'driverProofPictureURL': this.driverProofPictureURL,
        'carProofPictureURL': this.carProofPictureURL,
        'sectionId': this.sectionId,
      });
    }
    if (this.inProgressOrderID != null) {
      json.addAll({'inProgressOrderID': this.inProgressOrderID});
    }
    return json;
  }

  Map<String, dynamic> toPayload() {
    Map<String, dynamic> json = {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'isActive': this.isActive,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp.millisecondsSinceEpoch,
      'profilePictureURL': this.profilePictureURL,
      'passportUrl': this.passportUrl,
      'licenceUrl': this.licenceUrl,
      'diskUrl': this.diskUrl,
      'insuaranceUrl': this.insuranceUrl,
      'driverEvpNo': this.driverEvpNo,
      'evpPictureURL': this.evpPictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      'shippingAddress': this.shippingAddress.toJson(),
      'role': this.role,
      'wallet_amount': this.walletAmount,
      "userBankDetails": this.userBankDetails.toJson(),
      "g": this.geoFireData.toJson(),
      'coordinates': this.coordinates,
      'createdAt': this.createdAt,
    };
    if (this.role == USER_ROLE_DRIVER) {
      json.addAll({
        'role': this.role,
        'rideType': this.rideType,
        'carName': this.carName,
        'carNumber': this.carNumber,
        'carColor': this.carColor,
        'carPictureURL': this.carPictureURL,
        'vehicleType': this.vehicleType,
        'vehicleId': this.vehicleId,
        'carMakes': this.carMakes,
        'rotation': this.rotation,
        'reviewsCount': this.reviewsCount,
        'reviewsSum': this.reviewsSum,
        // 'isCompany': this.isCompany,
        // 'companyId': this.companyId,
        // 'companyName': this.companyName,
        // 'companyAddress': this.companyAddress,
        'serviceType': this.serviceType,
        'driverRate': this.driverRate,
        'carRate': this.carRate,
        'carInfo': this.carInfo!.toJson(),
        'rentalBookingDate': this.rentalBookingDate,
        'driverProofPictureURL': this.driverProofPictureURL,
        'carProofPictureURL': this.carProofPictureURL,
        'sectionId': this.sectionId,
      });
    }
    if (this.inProgressOrderID != null) {
      json.addAll({'inProgressOrderID': this.inProgressOrderID});
    }
    return json;
  }

  @override
  String toString() {
    return 'User{email: $email, firstName: $firstName, lastName: $lastName, settings: ${settings.toJson()}, phoneNumber: $phoneNumber, active: $active,isActive : $isActive, lastOnlineTimestamp: $lastOnlineTimestamp, userID: $userID, profilePictureURL: $profilePictureURL, passportUrl : $passportUrl, licenceUrl : $licenceUrl,diskUrl : $diskUrl, insuaranceUrl : $insuranceUrl, driverEvpNo: $driverEvpNo, evpPictureURL: $evpPictureURL, appIdentifier: $appIdentifier, fcmToken: $fcmToken, location: $location, shippingAddress: ${shippingAddress.toJson()}, role: $role, carName: $carName, carNumber: $carNumber, carPictureURL: $carPictureURL, inProgressOrderID: $inProgressOrderID, orderRequestData: ${orderRequestData?.toJson()}, ordercabRequestData: ${ordercabRequestData?.toJson()}, orderParcelRequestData: ${orderParcelRequestData?.toJson()}}';
  }
}

class UserSettings {
  bool pushNewMessages;

  bool orderUpdates;

  bool newArrivals;

  bool promotions;

  UserSettings(
      {this.pushNewMessages = true,
      this.orderUpdates = true,
      this.newArrivals = true,
      this.promotions = true});

  factory UserSettings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserSettings(
      pushNewMessages: parsedJson['pushNewMessages'] ?? true,
      orderUpdates: parsedJson['orderUpdates'] ?? true,
      newArrivals: parsedJson['newArrivals'] ?? true,
      promotions: parsedJson['promotions'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNewMessages': this.pushNewMessages,
      'orderUpdates': this.orderUpdates,
      'newArrivals': this.newArrivals,
      'promotions': this.promotions,
    };
  }
}

class UserLocation {
  double latitude;

  double longitude;

  UserLocation({this.latitude = 0.01, this.longitude = 0.01});

  factory UserLocation.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserLocation(
      latitude: parsedJson['latitude'] ?? 00.1,
      longitude: parsedJson['longitude'] ?? 00.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
    };
  }
}

class GeoFireData {
  String? geohash;
  GeoPoint? geoPoint;

  GeoFireData({this.geohash, this.geoPoint});

  factory GeoFireData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeoFireData(
      geohash: parsedJson['geohash'] ?? '',
      geoPoint: parsedJson['geopoint'] ?? GeoPoint(0.0, 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': this.geohash,
      'geopoint': this.geoPoint,
    };
  }
}

class UserBankDetails {
  String bankName;

  String branchName;

  String holderName;

  String accountNumber;

  String otherDetails;

  UserBankDetails({
    this.bankName = '',
    this.otherDetails = '',
    this.branchName = '',
    this.accountNumber = '',
    this.holderName = '',
  });

  factory UserBankDetails.fromJson(Map<String, dynamic> parsedJson) {
    return UserBankDetails(
      bankName: parsedJson['bankName'] ?? '',
      branchName: parsedJson['branchName'] ?? '',
      holderName: parsedJson['holderName'] ?? '',
      accountNumber: parsedJson['accountNumber'] ?? '',
      otherDetails: parsedJson['otherDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': this.bankName,
      'branchName': this.branchName,
      'holderName': this.holderName,
      'accountNumber': this.accountNumber,
      'otherDetails': this.otherDetails,
    };
  }
}

class CarInfo {
  String? passenger;
  String? doors;
  String? carName;
  String? airConditioning;
  String? gear;
  String? mileage;
  String? fuelFilling;
  String? fuelType;
  String? maxPower;
  String? mph;
  String? topSpeed;
  List<dynamic>? carImage;

  CarInfo({
    this.passenger,
    this.doors,
    this.carName,
    this.airConditioning,
    this.gear,
    this.mileage,
    this.fuelFilling,
    this.fuelType,
    this.carImage,
    this.maxPower,
    this.mph,
    this.topSpeed,
  });

  CarInfo.fromJson(Map<String, dynamic> json) {
    passenger = json['passenger'] ?? "";
    doors = json['doors'] ?? "";
    carName = json['carName'] ?? "";
    airConditioning = json['air_conditioning'] ?? "";
    gear = json['gear'] ?? "";
    mileage = json['mileage'] ?? "";
    fuelFilling = json['fuel_filling'] ?? "";
    fuelType = json['fuel_type'] ?? "";
    carImage = json['car_image'] ?? [];
    maxPower = json['maxPower'] ?? "";
    mph = json['mph'] ?? "";
    topSpeed = json['topSpeed'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['passenger'] = this.passenger;
    data['doors'] = this.doors;
    data['carName'] = this.carName;
    data['air_conditioning'] = this.airConditioning;
    data['gear'] = this.gear;
    data['mileage'] = this.mileage;
    data['fuel_filling'] = this.fuelFilling;
    data['fuel_type'] = this.fuelType;
    data['car_image'] = this.carImage;
    data['maxPower'] = this.maxPower;
    data['mph'] = this.mph;
    data['topSpeed'] = this.topSpeed;
    return data;
  }
}
