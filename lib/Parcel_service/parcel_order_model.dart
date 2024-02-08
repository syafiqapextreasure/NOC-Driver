import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nocdriver/model/TaxModel.dart';
import 'package:nocdriver/model/User.dart';

class ParcelOrderModel {
  ParcelUserDetails? sender;
  ParcelUserDetails? receiver;

  String id;
  String? note;
  String? parcelType;
  String? parcelCategoryID;
  String? status;
  String? subTotal;
  String? discount;
  String? adminCommission;
  String? adminCommissionType;
  String? discountType;
  String? discountLabel;
  String? parcelWeightCharge;
  List<dynamic>? parcelImages;
  List<dynamic>? rejectedByDrivers = [];

  String? parcelWeight;
  String? distance;
  Timestamp? senderPickupDateTime;
  Timestamp? receiverPickupDateTime;
  UserLocation? senderLatLong;
  UserLocation? receiverLatLong;
  bool? isSchedule;

  String authorID;
  String paymentMethod;
  bool? paymentCollectByReceiver;
  User? author;
  User? driver;
  String? driverID;
  Timestamp? createdAt;
  Timestamp? trigger_delevery;
  String? sectionId;
  bool? sendToDriver;
  List<TaxModel>? taxModel;

  ParcelOrderModel({
    this.id = '',
    this.note,
    this.parcelType,
    this.parcelCategoryID,
    this.status,
    this.subTotal,
    this.discount,
    this.adminCommission,
    this.adminCommissionType,
    this.discountType,
    this.discountLabel,
    this.isSchedule,
    this.senderPickupDateTime,
    this.receiverPickupDateTime,
    this.parcelWeight,
    this.sender,
    this.receiver,
    this.distance,
    this.senderLatLong,
    this.receiverLatLong,
    this.parcelWeightCharge,
    this.parcelImages,
    this.rejectedByDrivers,
    this.sendToDriver,
    this.driver,
    this.author,
    this.driverID,
    this.authorID = '',
    this.paymentMethod = '',
    this.paymentCollectByReceiver = false,
    this.createdAt,
    this.sectionId ,
    this.trigger_delevery, this.taxModel,
  });

  factory ParcelOrderModel.fromJson(Map<String, dynamic> json) {
    print('Value : ${json['id']} ${json['senderPickupDateTime']} ${json['senderPickupDateTime'].runtimeType}');


    List<TaxModel>? taxList;
    if (json['taxSetting'] != null) {
      taxList = <TaxModel>[];
      json['taxSetting'].forEach((v) {
        taxList!.add(TaxModel.fromJson(v));
      });
    }

    return ParcelOrderModel(
      id: json['id'] ?? "",
      status: json['status'] ?? "",
      note: json['note'] ?? "",
      parcelType: json['parcelType'] ?? "",
      parcelCategoryID: json['parcelCategoryID'] ?? "",
      subTotal: json['subTotal'] ?? "",
      discount: json['discount'] ?? "",
      adminCommission: json['adminCommission'] ?? "",
      adminCommissionType: json['adminCommissionType'] ?? "",
      discountLabel: json['discountLabel'] ?? "",
      discountType: json['discountType'] ?? "",
      taxModel: taxList,
      parcelWeightCharge: json['parcelWeightCharge'] ?? "",
      parcelImages: json['parcelImages'] ?? [],
      rejectedByDrivers: json['rejectedByDrivers'],
      isSchedule: json['isSchedule'] ?? false,
      parcelWeight: json['parcelWeight'] ?? "",
      sendToDriver: json['sendToDriver'] ?? false,
      senderPickupDateTime: json['senderPickupDateTime'] ?? Timestamp.now(),
      receiverPickupDateTime: json['receiverPickupDateTime'] ?? Timestamp.now(),
      distance: json['distance'],
      senderLatLong: json['senderLatLong'] != null ? UserLocation.fromJson(json['senderLatLong']) : UserLocation(),
      receiverLatLong: json['receiverLatLong'] != null ? UserLocation.fromJson(json['receiverLatLong']) : UserLocation(),
      sender: json['sender'] != null ? ParcelUserDetails.fromJson(json['sender']) : ParcelUserDetails(),
      receiver: json['receiver'] != null ? ParcelUserDetails.fromJson(json['receiver']) : ParcelUserDetails(),
      author: json.containsKey('author') ? User.fromJson(json['author']) : User(),
      authorID: json['authorID'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      paymentCollectByReceiver: json['paymentCollectByReceiver'] ?? false,
      trigger_delevery: json['trigger_delevery'] ?? Timestamp.now(),
      driver: json.containsKey('driver') ? User.fromJson(json['driver']) : null,
      driverID: json.containsKey('driverID') ? json['driverID'] : null,
      sectionId: json['sectionId'] ??"",
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "id": id,
      "status": status,
      "note": note,
      "parcelType": parcelType,
      "parcelCategoryID": parcelCategoryID,
      "subTotal": subTotal,
      "discount": discount,
      "adminCommission": adminCommission,
      "adminCommissionType": adminCommissionType,
      "discountLabel": discountLabel,
      "discountType": discountType,
      "taxSetting": taxModel != null ? taxModel!.map((v) => v.toJson()).toList() : null,
      "isSchedule": isSchedule,
      "senderPickupDateTime": senderPickupDateTime,
      "receiverPickupDateTime": receiverPickupDateTime,
      "receiver": receiver!.toJson(),
      "sender": sender!.toJson(),
      "senderLatLong": senderLatLong!.toJson(),
      "receiverLatLong": receiverLatLong!.toJson(),
      "distance": distance,
      "parcelWeight": parcelWeight,
      "parcelWeightCharge": parcelWeightCharge,
      "parcelImages": parcelImages,
      "rejectedByDrivers": rejectedByDrivers,
      "sendToDriver": sendToDriver,
      'author': author!.toJson(),
      'authorID': authorID,
      'payment_method': paymentMethod,
      'createdAt': createdAt,
      'trigger_delevery': trigger_delevery,
      'paymentCollectByReceiver': paymentCollectByReceiver,
      'sectionId': sectionId,
    };
    if (driver != null) {
      json.addAll({'driverID': driverID, 'driver': driver!.toJson()});
    }
    return json;
  }
}

class ParcelUserDetails {
  String? name;
  String? phone;
  String? address;

  ParcelUserDetails({this.name, this.phone, this.address});

  factory ParcelUserDetails.fromJson(Map<String, dynamic> json) {
    return ParcelUserDetails(
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      phone: json['phone'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "address": address, "phone": phone};
  }
}
