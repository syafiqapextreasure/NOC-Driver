import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nocdriver/model/TaxModel.dart';
import 'package:nocdriver/model/User.dart';
import 'package:nocdriver/model/VehicleType.dart';

class CabOrderModel {
  String authorID;
  String paymentMethod;
  bool paymentStatus;

  User author;
  User? driver;
  String? driverID;
  String? otpCode;
  Timestamp createdAt;
  Timestamp? trigger_delevery;
  String status;
  String id;
  num? discount;
  String? couponCode;
  String? couponId;
  String? tipValue;
  String? adminCommission;
  String? adminCommissionType;
 // String? tax;
  //String? taxType;
  List<TaxModel>? taxModel;
  String? subTotal;
  UserLocationData sourceLocation;
  UserLocationData destinationLocation;

  VehicleType? vehicleType;
  String? vehicleId;
  String? distance;
  String? duration;
  List<dynamic>? rejectedByDrivers = [];

  String? sourceLocationName;
  String? destinationLocationName;
  String? sectionId;

  CabOrderModel(
      {author,
      this.driver,
      this.driverID,
      this.authorID = '',
      this.otpCode = '',
      this.paymentMethod = '',
      this.paymentStatus = false,
      createdAt,
      trigger_delevery,
      sourceLocation,
      destinationLocation,
      this.id = '',
      this.status = '',
      this.discount = 0,
      this.couponCode = '',
      this.couponId = '',
      this.tipValue,
      this.adminCommission,
      this.adminCommissionType,
      this.sourceLocationName,
      this.destinationLocationName,
      this.subTotal = "0.0",
      this.vehicleType,
      this.vehicleId,
      this.distance,
      this.duration,
        this.sectionId ,
        this.taxModel,
      this.rejectedByDrivers})
      : author = author ?? User(),
        sourceLocation = sourceLocation ?? UserLocationData(),
        this.trigger_delevery = trigger_delevery ?? Timestamp.now(),
        destinationLocation = destinationLocation ?? UserLocationData(),
        createdAt = createdAt ?? Timestamp.now();

  factory CabOrderModel.fromJson(Map<String, dynamic> parsedJson) {
    num discountVal = 0;
    if (parsedJson['discount'] == null || parsedJson['discount'] == double.nan) {
      discountVal = 0;
    } else if (parsedJson['discount'] is String) {
      discountVal = double.parse(parsedJson['discount']);
    } else {
      discountVal = parsedJson['discount'];
    }
    List<TaxModel>? taxList;
    if (parsedJson['taxSetting'] != null) {
      taxList = <TaxModel>[];
      parsedJson['taxSetting'].forEach((v) {
        taxList!.add(TaxModel.fromJson(v));
      });
    }

    return CabOrderModel(
      author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
      authorID: parsedJson['authorID'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      trigger_delevery: parsedJson['trigger_delevery'] ?? Timestamp.now(),
      id: parsedJson['id'] ?? '',
      paymentStatus: parsedJson['paymentStatus'] ?? false,
      status: parsedJson['status'] ?? '',
      discount: discountVal,
      couponCode: parsedJson['couponCode'] ?? '',
      couponId: parsedJson['couponId'] ?? '',
      driver: parsedJson.containsKey('driver') ? User.fromJson(parsedJson['driver']) : null,
      driverID: parsedJson.containsKey('driverID') ? parsedJson['driverID'] : null,
      adminCommission: parsedJson["adminCommission"] ?? "",
      otpCode: parsedJson["otpCode"] ?? "",
      adminCommissionType: parsedJson["adminCommissionType"] ?? "",
      tipValue: parsedJson["tip_amount"] ?? "",
      paymentMethod: parsedJson['paymentMethod'] ?? '',
      taxModel: taxList,
      subTotal: parsedJson['subTotal'] ?? '0.0',
      sourceLocationName: parsedJson['sourceLocationName'] ?? '',
      destinationLocationName: parsedJson['destinationLocationName'] ?? '',
      vehicleType: parsedJson.containsKey('vehicleType') ? VehicleType.fromJson(parsedJson['vehicleType']) : null,
      vehicleId: parsedJson['vehicleId'] ?? '',
      distance: parsedJson['distance'] ?? 0,
      duration: parsedJson['duration'] ?? '',
      sectionId: parsedJson['sectionId'] ??"",
      rejectedByDrivers: parsedJson["rejectedByDrivers"],
     sourceLocation: parsedJson.containsKey('sourceLocation') ? UserLocationData.fromJson(parsedJson['sourceLocation']) : UserLocationData(),
      destinationLocation: parsedJson.containsKey('destinationLocation') ? UserLocationData.fromJson(parsedJson['destinationLocation']) : UserLocationData(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'author': author.toJson(),
      'authorID': authorID,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      'id': id,
      'status': status,
      'discount': discount,
      'couponCode': couponCode,
      'couponId': couponId,
      'adminCommission': adminCommission,
      'adminCommissionType': adminCommissionType,
      "tip_amount": tipValue,
      "taxSetting": taxModel != null ? taxModel!.map((v) => v.toJson()).toList() : null,
      "sourceLocation": sourceLocation.toJson(),
      "destinationLocation": destinationLocation.toJson(),
      "vehicleType": vehicleType!.toJson(),
      "vehicleId": vehicleId,
      "distance": distance,
      "distance": distance,
      "duration": duration,
      "subTotal": subTotal,
      "otpCode": otpCode,
      "rejectedByDrivers": this.rejectedByDrivers,
      "trigger_delevery": this.trigger_delevery,
      "sourceLocationName": this.sourceLocationName,
      "destinationLocationName": this.destinationLocationName,
      "sectionId": sectionId,
    };
    if (this.driver != null) {
      json.addAll({'driverID': this.driverID, 'driver': this.driver!.toJson()});
    }
    return json;
  }
}

class UserLocationData {
  double latitude;
  double longitude;

  UserLocationData({this.latitude = 0.01, this.longitude = 0.01});

  factory UserLocationData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserLocationData(
      latitude: parsedJson['latitude'] ?? 00.1,
      longitude: parsedJson['longitude'] ?? 00.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
