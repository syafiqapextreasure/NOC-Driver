import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nocdriver/model/DeliveryChargeModel.dart';
import 'package:nocdriver/model/User.dart';

class VendorModel {
  String author;

  String authorName;

  String authorProfilePic;

  String categoryID;

  String fcmToken;

  String categoryPhoto;

  String categoryTitle = "";
  Timestamp? createdAt;

  String description;
  String phonenumber;

  dynamic filters;

  String id;

  double latitude;

  double longitude;

  String photo;

  List<dynamic> photos;

  String location;

  String price;

  num reviewsCount;

  num reviewsSum;

  String title;

  String opentime;

  String closetime;

  bool hidephotos;

  bool reststatus;

  GeoFireData geoFireData;
  DeliveryChargeModel? DeliveryCharge;
  VendorModel(
      {this.author = '',
      this.hidephotos = false,
      this.authorName = '',
      this.authorProfilePic = '',
      this.categoryID = '',
      this.categoryPhoto = '',
      this.categoryTitle = '',
      this.createdAt,
      this.filters = const {},
      this.description = '',
      this.phonenumber = '',
      this.fcmToken = '',
      this.id = '',
      this.latitude = 0.1,
      this.longitude = 0.1,
      this.photo = '',
      this.photos = const [],
      this.location = '',
      this.price = '',
      this.reviewsCount = 0,
      this.reviewsSum = 0,
      this.closetime = '',
      this.opentime = '',
      this.title = '',
      this.reststatus = false,
        this.DeliveryCharge,
      geoFireData})
      : this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );

  // ,this.filters = filters ?? Filters(cuisine: '');

  factory VendorModel.fromJson(Map<String, dynamic> parsedJson) {
    num walVal = 0;
    if (parsedJson['walletAmount'] != null) {
      if (parsedJson['walletAmount'] is int) {
        walVal = parsedJson['walletAmount'];
      } else if (parsedJson['walletAmount'] is double) {
        walVal = parsedJson['walletAmount'].toInt();
      } else if (parsedJson['walletAmount'] is String) {
        if (parsedJson['walletAmount'].isNotEmpty) {
          walVal = num.parse(parsedJson['walletAmount']);
        } else {
          walVal = 0;
        }
      }
    }
    return new VendorModel(
        author: parsedJson['author'] ?? '',
        hidephotos: parsedJson['hidephotos'] ?? false,
        authorName: parsedJson['authorName'] ?? '',
        authorProfilePic: parsedJson['authorProfilePic'] ?? '',
        categoryID: parsedJson['categoryID'] ?? '',
        categoryPhoto: parsedJson['categoryPhoto'] ?? '',
        categoryTitle: parsedJson['categoryTitle'] ?? '',
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        DeliveryCharge: (parsedJson.containsKey('deliveryCharge') && parsedJson['deliveryCharge'] != null) ? DeliveryChargeModel.fromJson(parsedJson['deliveryCharge']) : null,

        geoFireData: parsedJson.containsKey('g')
            ? GeoFireData.fromJson(parsedJson['g'])
            : GeoFireData(
                geohash: "",
                geoPoint: GeoPoint(0.0, 0.0),
              ),
        description: parsedJson['description'] ?? '',
        phonenumber: parsedJson['phonenumber'] ?? '',
        filters:
            // parsedJson.containsKey('filters') ?
            parsedJson['filters'] ?? [],
        // : Filters(cuisine: ''),
        id: parsedJson['id'] ?? '',
        latitude: parsedJson['latitude'] ?? 0.1,
        longitude: parsedJson['longitude'] ?? 0.1,
        photo: parsedJson['photo'] ?? '',
        photos: parsedJson['photos'] ?? [],
        location: parsedJson['location'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        price: parsedJson['price'] ?? '',
        reviewsCount: parsedJson['reviewsCount'] ?? 0,
        reviewsSum: parsedJson['reviewsSum'] ?? 0,
        title: parsedJson['title'] ?? '',
        closetime: parsedJson['closetime'] ?? '',
        opentime: parsedJson['opentime'] ?? '',
        reststatus: parsedJson['reststatus'] ?? false);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'author': this.author,
      'hidephotos': this.hidephotos,
      'authorName': this.authorName,
      'authorProfilePic': this.authorProfilePic,
      'categoryID': this.categoryID,
      'categoryPhoto': this.categoryPhoto,
      'categoryTitle': this.categoryTitle,
      'createdAt': this.createdAt,
      "g": this.geoFireData.toJson(),
      'description': this.description,
      'phonenumber': this.phonenumber,
      'filters': this.filters,
      'id': this.id,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'photo': this.photo,
      'photos': this.photos,
      'location': this.location,
      'fcmToken': this.fcmToken,
      'price': this.price,
      'reviewsCount': this.reviewsCount,
      'reviewsSum': this.reviewsSum,
      'title': this.title,
      'opentime': this.opentime,
      'closetime': this.closetime,
      'reststatus': this.reststatus
    };
    if (DeliveryCharge != null) {
      json.addAll({'deliveryCharge': DeliveryCharge!.toJson()});
    }
    return json;
  }
}