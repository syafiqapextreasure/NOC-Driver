import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:location/location.dart';
import 'package:nocdriver/CabService/verify_otp_screen.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/CabOrderModel.dart';
import 'package:nocdriver/model/User.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:nocdriver/ui/chat_screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:url_launcher/url_launcher.dart';

class CabHomeScreen extends StatefulWidget {
  final VoidCallback refresh;

  const CabHomeScreen({Key? key, required this.refresh}) : super(key: key);

  @override
  State<CabHomeScreen> createState() => _CabHomeScreenState();
}

class _CabHomeScreenState extends State<CabHomeScreen>
    with SingleTickerProviderStateMixin {
  final fireStoreUtils = FireStoreUtils();

  GoogleMapController? _mapController;
  bool canShowSheet = true;

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;
  final Location currentLocation = Location();
  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  final Map<String, Marker> _markers = {};

  setIcons() async {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/pickup.png")
        .then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/dropoff.png")
        .then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/ic_taxi.png")
        .then((value) {
      taxiIcon = value;
    });
  }

  updateDriverOrder() async {
    await FireStoreUtils().getDriverOrderSetting();
    setState(() {});
    Timestamp startTimestamp = Timestamp.now();
    DateTime currentDate = startTimestamp.toDate();
    currentDate = currentDate.subtract(Duration(hours: 3));
    startTimestamp = Timestamp.fromDate(currentDate);

    List<CabOrderModel> orders = [];

    print('-->startTime${startTimestamp.toDate()}');
    await FirebaseFirestore.instance
        .collection(RIDESORDER)
        .where('status',
            whereIn: [ORDER_STATUS_PLACED, ORDER_STATUS_DRIVER_REJECTED])
        .where('createdAt', isGreaterThan: startTimestamp)
        .get()
        .then((value) async {
          print('---->${value.docs.length}');
          await Future.forEach(value.docs,
              (QueryDocumentSnapshot<Map<String, dynamic>> element) {
            try {
              orders.add(CabOrderModel.fromJson(element.data()));
            } catch (e, s) {
              print('watchOrdersStatus parse error ${element.id}$e $s');
            }
          });
        });

    orders.forEach((element) {
      CabOrderModel orderModel = element;
      print('---->${orderModel.id}');
      orderModel.trigger_delevery = Timestamp.now();
      FirebaseFirestore.instance
          .collection(RIDESORDER)
          .doc(element.id)
          .set(orderModel.toJson(), SetOptions(merge: true))
          .then((order) {
        print('Done.');
      });
    });
  }

  AnimationController? _animationController;
  late LatLng currentsLocation;
  Location location = Location();

  void _getCurrentLocation() async {
    try {
      var userLocation = await location.getLocation();
      if (userLocation != null) {
        setState(() {
          currentsLocation = LatLng(
              userLocation.latitude ?? 0.0, userLocation.longitude ?? 0.0);
        });
        _mapController!.animateCamera(CameraUpdate.newLatLng(currentsLocation));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // initBackgroundFetch();
    getDriver();
    setIcons();
    updateDriverOrder();
    getLocation();
    getCurrentLocation();
    _getCurrentLocation();

    print('---->$enableOTPTripStart');
    print('======>$driverOrderAcceptRejectDuration');

    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 700));
    _animationController!.repeat(reverse: true);
  }

  getLocation() async {
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locationDataFinal!.latitude ?? 0.0,
              locationDataFinal!.longitude ?? 0.0),
          zoom: 20,
          bearing: double.parse(_driverModel!.rotation.toString()),
        ),
      ),
    );
    setState(() {});
  }

  Future<void> dispose() async {
    _mapController!.dispose();
    audioPlayer.dispose();
    // await FireStoreUtils().driverStreamController.close();
    FireStoreUtils().driverStreamSub.cancel();

    FireStoreUtils().cabOrdersStreamController.close();
    FireStoreUtils().cabOrdersStreamSub.cancel();
    if (_timer != null) {
      _timer!.cancel();
    }
    audioPlayer.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    isDarkMode(context)
        ? _mapController?.setMapStyle('[{"featureType": "all","'
            'elementType": "'
            'geo'
            'met'
            'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]')
        : _mapController?.setMapStyle(null);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 130,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/DriverTopHeader.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Image.asset('assets/images/DriverTopHeader.png'),
              Visibility(
                visible: _driverModel!.inProgressOrderID == null &&
                    _driverModel!.walletAmount <=
                        double.parse(minimumDepositToRideAccept),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${"You have to minimum ".tr()}${amountShow(amount: minimumDepositToRideAccept)} ${"wallet amount to receiving Order".tr()}",
                        style: TextStyle(
                            fontFamily: "GlacialIndifference",
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) async {
                    _mapController = controller;

                    LocationData location = await currentLocation.getLocation();
                    _mapController!.moveCamera(CameraUpdate.newLatLngZoom(
                        LatLng(location.latitude ?? 0.0,
                            location.longitude ?? 0.0),
                        14));
                  },
                  myLocationEnabled:
                      _driverModel!.inProgressOrderID != null ? false : true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.terrain,
                  zoomControlsEnabled: false,
                  polylines: Set<Polyline>.of(polyLines.values),
                  markers: _markers.values.toSet(),
                  initialCameraPosition: CameraPosition(
                    zoom: 15,
                    target: LatLng(_driverModel!.location.latitude,
                        _driverModel!.location.longitude),
                  ),
                ),
              ),
              _driverModel!.inProgressOrderID != null &&
                      currentOrder != null &&
                      isShow == true
                  ? buildOrderActionsCard()
                  : Container(),
              _driverModel!.ordercabRequestData != null
                  ? showDriverBottomSheet()
                  : Container(),
            ],
          ),
          Visibility(
            visible: currentOrder != null &&
                (currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED ||
                    currentOrder!.status == ORDER_STATUS_IN_TRANSIT),
            child: GestureDetector(
              onTap: () async {
                currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED
                    ? showNavigationChoiceDialog(
                        _driverModel!.location.latitude,
                        _driverModel!.location.longitude,
                        currentOrder!.sourceLocation.latitude,
                        currentOrder!.sourceLocation.longitude,
                      )
                    : showNavigationChoiceDialog(
                        _driverModel!.location.latitude,
                        _driverModel!.location.longitude,
                        currentOrder!.destinationLocation.latitude,
                        currentOrder!.destinationLocation.longitude,
                      );
              },
              child: LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      top: constraints.maxHeight * 0.33,
                      right: constraints.maxWidth * 0.03,
                      child: Image.asset(
                        'assets/images/navigator.png',
                        width: 50,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          GestureDetector(
            onTap: () {
              onPressedButton();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      top: constraints.maxHeight * 0.45,
                      right: constraints.maxWidth * 0.001,
                      child: Image.asset(
                        'assets/images/sosicon.png',
                        width: 80,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _driverModel!.ordercabRequestData != null ||
              _driverModel!.inProgressOrderID == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (isShow == true) {
                    isShow = false;
                  } else {
                    isShow = true;
                  }
                });
              },
              child: Icon(
                isShow ? Icons.close : Icons.remove_red_eye,
                color: Colors.white,
                size: 29,
              ),
              backgroundColor: Colors.black,
              tooltip: 'Capture Picture',
              elevation: 5,
              splashColor: Colors.grey,
            ),
    );
  }

  launchWaze(double endLat, double endLng) async {
    final Uri wazeUrl = Uri.parse('waze://?ll=$endLat,$endLng&navigate=yes');

    if (await canLaunchUrl(wazeUrl)) {
      await launchUrl(wazeUrl);
    } else {
      // If Waze is not installed, open the web browser with the Waze web page
      final webUrl =
          Uri.parse('https://www.waze.com/ul?ll=$endLat,$endLng&navigate=yes');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      } else {
        print('Could not launch Waze');
      }
    }
  }

  launchMaps(
      double startLat, double startLng, double endLat, double endLng) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng');

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  onPressedButton() async {
    // The phone number to dial
    final Uri phoneNumber = Uri.parse('tel:999');

    // Check if the device can handle the URL
    if (await canLaunchUrl(phoneNumber)) {
      // Launch the phone app with the specified number
      await launchUrl(phoneNumber);
    } else {
      // Handle the case where the URL could not be launched
      print('Could not launch $phoneNumber');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (isDarkMode(context))
      _mapController?.setMapStyle('[{"featureType": "all","'
          'elementType": "'
          'geo'
          'met'
          'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]');
  }

  Widget showDriverBottomSheet() {
    print("HUD HDH ${_driverModel!.ordercabRequestData}");
    if (!isPlaying) {
      playSound();
    }
    // setState(() {
    //   playSound();
    // });

    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xff212121),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(
                    "Trip Distance".tr(),
                    style: TextStyle(
                        fontFamily: "GlacialIndifference",
                        color: Color(0xffADADAD),
                        letterSpacing: 0.5),
                  ),
                ),
                Text(
                  "${_driverModel!.ordercabRequestData!.distance.toString()} km",
                  style: TextStyle(
                      fontFamily: "GlacialIndifference",
                      color: Color(0xffFFFFFF),
                      letterSpacing: 0.5),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(
                    "Delivery charge".tr(),
                    style: TextStyle(
                        fontFamily: "GlacialIndifference",
                        color: Color(0xffADADAD),
                        letterSpacing: 0.5),
                  ),
                ),
                Text(
                  "${amountShow(amount: _driverModel!.ordercabRequestData!.subTotal.toString())}",
                  style: TextStyle(
                      fontFamily: "GlacialIndifference",
                      color: Color(0xffFFFFFF),
                      letterSpacing: 0.5),
                ),
              ],
            ),
            SizedBox(height: 5),
            Card(
              color: Color(0xffFFFFFF),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/location3x.png',
                      height: 55,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 270,
                          child: Text(
                            "${_driverModel!.ordercabRequestData!.sourceLocationName} ",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: "GlacialIndifference",
                                color: Color(0xff333333),
                                letterSpacing: 0.5),
                          ),
                        ),
                        SizedBox(height: 22),
                        SizedBox(
                          width: 270,
                          child: Text(
                            "${_driverModel!.ordercabRequestData!.destinationLocationName}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: "GlacialIndifference",
                                color: Color(0xff333333),
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      backgroundColor: Color(COLOR_PRIMARY),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(
                          fontFamily: "GlacialIndifference",
                          color: Color(0xff000000),
                          letterSpacing: 0.5),
                    ),
                    onPressed: () async {
                      if (isPlaying) {
                        stopSound();
                      }
                      // setState(() {
                      //   audioPlayer.stop();
                      // });
                      await FireStoreUtils.getCabOrderByOrderId(
                              currentCabOrderID)
                          .then((value) async {
                        print("----->1111${value!.status}");
                        if (value.status == ORDER_STATUS_REJECTED) {
                          Navigator.pop(context);

                          MyAppState.currentUser!.ordercabRequestData = null;
                          MyAppState.currentUser!.inProgressOrderID = null;

                          await FireStoreUtils.updateCurrentUser(
                              MyAppState.currentUser!);
                          final snack = SnackBar(
                            content: Text(
                              "This Ride is already reject by customer.".tr(),
                              style: TextStyle(
                                  fontFamily: "GlacialIndifference",
                                  color: Colors.white),
                            ),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.black,
                          );
                          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                              .showSnackBar(snack);
                          setState(() {});
                        } else {
                          //Navigator.pop(context);
                          showProgress(
                              context, "Rejecting Ride...".tr(), false);
                          try {
                            await rejectOrder();
                            hideProgress();
                          } catch (e) {
                            hideProgress();
                            print('HomeScreenState.showDriverBottomSheet $e');
                          }
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        backgroundColor: Color(COLOR_PRIMARY),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                      child: Text(
                        'Accept'.tr(),
                        style: TextStyle(
                            fontFamily: "GlacialIndifference",
                            color: Colors.black,
                            letterSpacing: 0.5),
                      ),
                      onPressed: () async {
                        if (isPlaying) {
                          stopSound();
                        }
                        // setState(() {
                        //   audioPlayer.stop();
                        // });
                        await FireStoreUtils.getCabOrderByOrderId(
                                currentCabOrderID)
                            .then((value) async {
                          print("ACCEPT----->${value!.status}");
                          print("VALUE");
                          if (value.status == ORDER_STATUS_REJECTED) {
                            print("----->11111s}");
                            Navigator.pop(context);

                            MyAppState.currentUser!.ordercabRequestData = null;
                            MyAppState.currentUser!.inProgressOrderID = null;

                            await FireStoreUtils.updateCurrentUser(
                                MyAppState.currentUser!);
                            final snack = SnackBar(
                              content: Text(
                                "This Ride is reject by customer.".tr(),
                                style: TextStyle(
                                    fontFamily: "GlacialIndifference",
                                    color: Colors.white),
                              ),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.black,
                            );
                            ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                                .showSnackBar(snack);
                            setState(() {});
                          } else {
                            // showProgress(context, 'Accepting Ride....'.tr(), false);
                            try {
                              if (_timer != null) {
                                _timer!.cancel();
                              }
                              await acceptOrder();
                              hideProgress();
                            } catch (e) {
                              hideProgress();
                              print('HomeScreenState.showDriverBottomSheet $e');
                            }
                          }
                        });
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  acceptOrder() async {
    CabOrderModel orderModel = _driverModel!.ordercabRequestData!;

    _driverModel!.ordercabRequestData = null;
    _driverModel!.inProgressOrderID = orderModel.id;
    await FireStoreUtils.updateCurrentUser(_driverModel!);

    orderModel.status = ORDER_STATUS_DRIVER_ACCEPTED;
    orderModel.driverID = _driverModel!.userID;
    orderModel.driver = _driverModel!;

    if (enableOTPTripStart) {
      orderModel.otpCode = (Random().nextInt(900000) + 100000).toString();
    }

    await FireStoreUtils.updateCabOrder(orderModel);

    await getCurrentOrder();
    Map<String, dynamic> payLoad = <String, dynamic>{
      "type": "cab_order",
      "orderId": currentOrder!.id
    };
    await FireStoreUtils.sendFcmMessage(
        cabAccepted, orderModel.author.fcmToken, payLoad);

    setState(() {
      isShow = true;
    });
  }

  rejectOrder() async {
    if (_timer != null) {
      _timer!.cancel();
    }
    CabOrderModel orderModel = _driverModel!.ordercabRequestData!;
    if (orderModel.rejectedByDrivers == null) {
      orderModel.rejectedByDrivers = [];
    }
    orderModel.rejectedByDrivers!.add(_driverModel!.userID);
    orderModel.status = ORDER_STATUS_DRIVER_REJECTED;
    await FireStoreUtils.updateCabOrder(orderModel);
    _driverModel!.ordercabRequestData = null;
    await FireStoreUtils.updateCurrentUser(_driverModel!);
  }

  getDirections() async {
    if (currentOrder != null) {
      if (currentOrder!.status == ORDER_STATUS_SHIPPED) {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(_driverModel!.location.latitude,
              _driverModel!.location.longitude),
          PointLatLng(currentOrder!.sourceLocation.latitude,
              currentOrder!.sourceLocation.longitude),
          travelMode: TravelMode.driving,
        );

        print("----?${result.points}");
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        setState(() {
          _markers.remove("Driver");
          _markers['Driver'] = Marker(
              markerId: const MarkerId('Driver'),
              infoWindow: const InfoWindow(title: "Driver"),
              position: LatLng(_driverModel!.location.latitude,
                  _driverModel!.location.longitude),
              icon: taxiIcon!,
              rotation: double.parse(_driverModel!.rotation.toString()));
        });

        _markers.remove("Departure");
        _markers['Departure'] = Marker(
          markerId: const MarkerId('Departure'),
          infoWindow: const InfoWindow(title: "Departure"),
          position: LatLng(currentOrder!.sourceLocation.latitude,
              currentOrder!.sourceLocation.longitude),
          icon: departureIcon!,
        );

        _markers.remove("Destination");
        _markers['Destination'] = Marker(
          markerId: const MarkerId('Destination'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(currentOrder!.destinationLocation.latitude,
              currentOrder!.destinationLocation.longitude),
          icon: destinationIcon!,
        );
        addPolyLine(polylineCoordinates);
      } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT ||
          currentOrder!.status == ORDER_REACHED_DESTINATION) {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(_driverModel!.location.latitude,
              _driverModel!.location.longitude),
          PointLatLng(currentOrder!.destinationLocation.latitude,
              currentOrder!.destinationLocation.longitude),
          travelMode: TravelMode.driving,
        );

        print("----?${result.points}");
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        _markers.remove("Driver");
        _markers['Driver'] = Marker(
          markerId: const MarkerId('Driver'),
          infoWindow: const InfoWindow(title: "Driver"),
          position: LatLng(_driverModel!.location.latitude,
              _driverModel!.location.longitude),
          rotation: double.parse(_driverModel!.rotation.toString()),
          icon: taxiIcon!,
        );

        _markers.remove("Departure");
        _markers['Departure'] = Marker(
          markerId: const MarkerId('Departure'),
          infoWindow: const InfoWindow(title: "Departure"),
          position: LatLng(currentOrder!.sourceLocation.latitude,
              currentOrder!.sourceLocation.longitude),
          icon: departureIcon!,
        );
        _markers.remove("Destination");
        _markers['Destination'] = Marker(
          markerId: const MarkerId('Destination'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(currentOrder!.destinationLocation.latitude,
              currentOrder!.destinationLocation.longitude),
          icon: destinationIcon!,
        );
        addPolyLine(polylineCoordinates);
      } else {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(currentOrder!.sourceLocation.latitude,
              currentOrder!.sourceLocation.longitude),
          PointLatLng(currentOrder!.destinationLocation.latitude,
              currentOrder!.destinationLocation.longitude),
          travelMode: TravelMode.driving,
        );

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        _markers.remove("Departure");
        _markers['Departure'] = Marker(
          markerId: const MarkerId('Departure'),
          infoWindow: const InfoWindow(title: "Departure"),
          position: LatLng(currentOrder!.sourceLocation.latitude,
              currentOrder!.sourceLocation.longitude),
          icon: departureIcon!,
        );
        _markers.remove("Destination");
        _markers['Destination'] = Marker(
          markerId: const MarkerId('Destination'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(currentOrder!.destinationLocation.latitude,
              currentOrder!.destinationLocation.longitude),
          icon: destinationIcon!,
        );
        addPolyLine(polylineCoordinates);
      }
    }
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: source,
          zoom: 20,
          bearing: double.parse(_driverModel!.rotation.toString()),
        ),
      ),
    );
    //   if (mapController == null) return;
    //
    //   LatLngBounds bounds;
    //
    //   if (source.latitude > destination.latitude &&
    //       source.longitude > destination.longitude) {
    //     bounds = LatLngBounds(southwest: destination, northeast: source);
    //   } else if (source.longitude > destination.longitude) {
    //     bounds = LatLngBounds(
    //         southwest: LatLng(source.latitude, destination.longitude),
    //         northeast: LatLng(destination.latitude, source.longitude));
    //   } else if (source.latitude > destination.latitude) {
    //     bounds = LatLngBounds(
    //         southwest: LatLng(destination.latitude, source.longitude),
    //         northeast: LatLng(source.latitude, destination.longitude));
    //   } else {
    //     bounds = LatLngBounds(southwest: source, northeast: destination);
    //   }
    //
    //   CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);
    //
    //   return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color(COLOR_PRIMARY),
      points: polylineCoordinates,
      width: 4,
      geodesic: true,
    );
    polyLines[id] = polyline;
    updateCameraLocation(
        polylineCoordinates.first, polylineCoordinates.last, _mapController);
    setState(() {});
  }

  late Stream<CabOrderModel?> ordersFuture;
  CabOrderModel? currentOrder;

  late Stream<User> driverStream;
  User? _driverModel = User();

  getCurrentOrder() async {
    ordersFuture = FireStoreUtils()
        .getCabOrderByID(MyAppState.currentUser!.inProgressOrderID.toString());
    ordersFuture.listen((event) {
      print("------->${event!.status}");
      setState(() {
        currentOrder = event;
        getDirections();
      });
    });
  }

  Timer? _timer;

  void startTimer(User _driverModel) {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (driverOrderAcceptRejectDuration == 0) {
          timer.cancel();
          if (_driverModel.ordercabRequestData != null) {
            await rejectOrder();
            // Navigator.pop(context);
          }
        } else {
          driverOrderAcceptRejectDuration--;
        }
      },
    );
  }

  getDriver() async {
    driverStream = FireStoreUtils().getDriver(MyAppState.currentUser!.userID);
    driverStream.listen((event) {
      print("--->${event.location.latitude} ${event.location.longitude}");
      setState(() => _driverModel = event);
      setState(() => MyAppState.currentUser = _driverModel);

      getDirections();
      if (_driverModel!.isActive) {
        if (_driverModel!.ordercabRequestData != null) {
          ////  showDriverBottomSheet(_driverModel!);
          currentCabOrderID = _driverModel!.ordercabRequestData!.id;
          //    startTimer(_driverModel!);
        }
      }
      if (_driverModel!.inProgressOrderID != null) {
        getCurrentOrder();
      }

      if (_driverModel!.ordercabRequestData == null) {
        setState(() {
          _markers.clear();
          polyLines.clear();
        });
      }
      setState(() {});
    });
  }

  Widget buildOrderActionsCard({pedding = 10, width = 60}) {
    bool isPickedUp = false;
    String? buttonText;
    if (currentOrder!.status == ORDER_STATUS_SHIPPED ||
        currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED) {
      buttonText = enableOTPTripStart
          ? "Verify Code to customer".tr()
          : "Pickup Customer".tr();
      isPickedUp = true;
    } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
      // buttonText = 'Complete Pick Up'.tr();
      buttonText = "Reached To destination".tr();
      isPickedUp = false;
    } else if (currentOrder!.status == ORDER_REACHED_DESTINATION) {
      buttonText = "Complete Ride".tr();
      polyLines.clear();
      _markers.clear();
      isPickedUp = false;
    }
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      padding: EdgeInsets.symmetric(vertical: 15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(18)),
        color: isDarkMode(context) ? Color(0xff000000) : Color(0xffFFFFFF),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentOrder!.status == ORDER_STATUS_SHIPPED ||
                currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED)
              Column(
                children: [
                  ListTile(
                    tileColor: Color(0xffF1F4F8),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    title: Row(
                      children: [
                        Text(
                          "ORDER ID ".tr(),
                          style: TextStyle(
                              fontFamily: "GlacialIndifference",
                              fontSize: 14,
                              color: isDarkMode(context)
                                  ? Color(0xffFFFFFF)
                                  : Color(0xff555555),
                              letterSpacing: 0.5),
                        ),
                        Expanded(
                          child: Text(
                            '${currentOrder!.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: "GlacialIndifference",
                                fontSize: 14,
                                color: isDarkMode(context)
                                    ? Color(0xffFFFFFF)
                                    : Color(0xff000000),
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${currentOrder!.author.firstName} ${currentOrder!.author.lastName}',
                        style: TextStyle(
                            fontFamily: "GlacialIndifference",
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            letterSpacing: 0.5),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                side: BorderSide(color: Color(0xff3DAE7D)),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: Size(100, 30),
                              alignment: Alignment.center,
                              backgroundColor: Color(0xffFFFFFF),
                            ),
                            onPressed: () => openChatWithCustomer(),
                            icon: Icon(
                              Icons.message,
                              size: 16,
                              color: Color(0xff3DAE7D),
                            ),
                            // Image.asset(
                            //   'assets/images/call3x.png',
                            //   height: 14,
                            //   width: 14,
                            // ),
                            label: Text(
                              "Message".tr(),
                              style: TextStyle(
                                  fontFamily: "GlacialIndifference",
                                  color: Color(0xff3DAE7D),
                                  letterSpacing: 0.5),
                            )),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/user3x.png',
                      height: 42,
                      width: 42,
                      color: Color(COLOR_PRIMARY),
                    ),
                    title: Text(
                      '${currentOrder!.author.shippingAddress.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: "GlacialIndifference",
                          color: isDarkMode(context)
                              ? Color(0xffFFFFFF)
                              : Color(0xff000000),
                          letterSpacing: 0.5),
                    ),
                    subtitle: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'ORDER ID '.tr(),
                            style: TextStyle(
                                fontFamily: "GlacialIndifference",
                                color: Color(0xff555555),
                                fontSize: 12,
                                letterSpacing: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Text(
                              '${currentOrder!.id} ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: "GlacialIndifference",
                                  fontSize: 12,
                                  color: isDarkMode(context)
                                      ? Color(0xffFFFFFF)
                                      : Color(0xff000000),
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                side: BorderSide(color: Color(0xff3DAE7D)),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: Size(85, 30),
                              alignment: Alignment.center,
                              backgroundColor: Color(0xffFFFFFF),
                            ),
                            onPressed: () {
                              UrlLauncher.launch(
                                  "tel://${currentOrder!.author.phoneNumber}");
                            },
                            icon: Image.asset(
                              'assets/images/call3x.png',
                              height: 14,
                              width: 14,
                            ),
                            label: Text(
                              "CALL".tr(),
                              style: TextStyle(
                                  fontFamily: "GlacialIndifference",
                                  color: Color(0xff3DAE7D),
                                  letterSpacing: 0.5),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT)
              Column(
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/images/user3x.png',
                      height: 42,
                      width: 42,
                      color: Color(COLOR_PRIMARY),
                    ),
                    title: Text(
                      '${currentOrder!.author.shippingAddress.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: "GlacialIndifference",
                          color: isDarkMode(context)
                              ? Color(0xffFFFFFF)
                              : Color(0xff000000),
                          letterSpacing: 0.5),
                    ),
                    subtitle: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "ORDER ID ".tr(),
                            style: TextStyle(
                                fontFamily: "GlacialIndifference",
                                color: Color(0xff555555),
                                fontSize: 12,
                                letterSpacing: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Text(
                              '${currentOrder!.id} ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: "GlacialIndifference",
                                  color: isDarkMode(context)
                                      ? Color(0xffFFFFFF)
                                      : Color(0xff000000),
                                  fontSize: 12,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                side: BorderSide(color: Color(0xff3DAE7D)),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: Size(85, 30),
                              alignment: Alignment.center,
                              backgroundColor: Color(0xffFFFFFF),
                            ),
                            onPressed: () {
                              UrlLauncher.launch(
                                  "tel://${currentOrder!.author.phoneNumber}");
                            },
                            icon: Image.asset(
                              'assets/images/call3x.png',
                              height: 14,
                              width: 14,
                            ),
                            label: Text(
                              "CALL".tr(),
                              style: TextStyle(
                                  fontFamily: "GlacialIndifference",
                                  color: Color(0xff3DAE7D),
                                  letterSpacing: 0.5),
                            )),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/delivery_location3x.png',
                      height: 42,
                      width: 42,
                      color: Color(COLOR_PRIMARY),
                    ),
                    title: Text(
                      'Destination'.tr(),
                      style: TextStyle(
                          fontFamily: "GlacialIndifference",
                          color: Color(0xff9091A4),
                          letterSpacing: 0.5),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${currentOrder!.destinationLocationName}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "GlacialIndifference",
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            letterSpacing: 0.5),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                side: BorderSide(color: Color(0xff3DAE7D)),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: Size(100, 30),
                              alignment: Alignment.center,
                              backgroundColor: Color(0xffFFFFFF),
                            ),
                            onPressed: () => openChatWithCustomer(),
                            icon: Icon(
                              Icons.message,
                              size: 16,
                              color: Color(0xff3DAE7D),
                            ),
                            // Image.asset(
                            //   'assets/images/call3x.png',
                            //   height: 14,
                            //   width: 14,
                            // ),
                            label: Text(
                              "Message".tr(),
                              style: TextStyle(
                                  fontFamily: "GlacialIndifference",
                                  color: Color(0xff3DAE7D),
                                  letterSpacing: 0.5),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT ||
                currentOrder!.status == ORDER_REACHED_DESTINATION)
              SizedBox(height: 25),
            isPickedUp
                ? FadeTransition(
                    opacity: _animationController!,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AnimatedContainer(
                        duration: Duration(seconds: 2),
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            backgroundColor: Color(COLOR_PRIMARY),
                          ),
                          onPressed: () async {
                            print("currentOrder!.status");
                            print(currentOrder!.status);
                            if (currentOrder!.status == ORDER_STATUS_SHIPPED ||
                                currentOrder!.status ==
                                    ORDER_STATUS_DRIVER_ACCEPTED) {
                              completePickUp();
                            } else if (currentOrder!.status ==
                                ORDER_STATUS_IN_TRANSIT) {
                              reachedDestination();
                            } else if (currentOrder!.status ==
                                ORDER_REACHED_DESTINATION) {
                              if (currentOrder!.paymentStatus == true) {
                                completeOrder();
                              } else {
                                final snack = SnackBar(
                                  content: Text(
                                    "Customer payment is pending.".tr(),
                                    style: TextStyle(
                                        fontFamily: "GlacialIndifference",
                                        color: Colors.white),
                                  ),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.black,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snack);
                              }
                            }
                          },
                          child: Text(
                            buttonText ?? "",
                            style: TextStyle(
                                fontFamily: "GlacialIndifference",
                                color: Colors.black,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AnimatedContainer(
                      duration: Duration(seconds: 2),
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          backgroundColor: Color(COLOR_PRIMARY),
                        ),
                        onPressed: () async {
                          if (currentOrder!.status == ORDER_STATUS_SHIPPED ||
                              currentOrder!.status ==
                                  ORDER_STATUS_DRIVER_ACCEPTED) {
                            completePickUp();
                          } else if (currentOrder!.status ==
                              ORDER_STATUS_IN_TRANSIT) {
                            reachedDestination();
                          } else if (currentOrder!.status ==
                              ORDER_REACHED_DESTINATION) {
                            if (currentOrder!.paymentStatus == true) {
                              completeOrder();
                            } else {
                              final snack = SnackBar(
                                content: Text(
                                  "Customer payment is pending.".tr(),
                                  style: TextStyle(
                                      fontFamily: "GlacialIndifference",
                                      color: Colors.white),
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.black,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snack);
                            }
                          }
                        },
                        child: Text(
                          buttonText ?? "",
                          style: TextStyle(
                              fontFamily: "GlacialIndifference",
                              color: Color(0xff000000),
                              letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  completePickUp() async {
    if (enableOTPTripStart) {
      final isComplete = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => VerifyOtpScreen(
                otp: currentOrder!.otpCode,
              )));
      if (isComplete != null) {
        if (isComplete == true) {
          print('HomeScreenState.completePickUp');
          // showProgress(context, "Updating Ride...".tr(), false);
          currentOrder!.status = ORDER_STATUS_IN_TRANSIT;
          await FireStoreUtils.updateCabOrder(currentOrder!);

          //hideProgress();
          setState(() {});
        }
      }
    } else {
      print('HomeScreenState.completePickUp');
      // showProgress(context, 'Updating Ride...'.tr(), false);
      currentOrder!.status = ORDER_STATUS_IN_TRANSIT;
      await FireStoreUtils.updateCabOrder(currentOrder!);

      hideProgress();
      setState(() {});
    }
  }

  reachedDestination() async {
    // showProgress(context, "Ride update...".tr(), false);
    currentOrder!.status = ORDER_REACHED_DESTINATION;
    await FireStoreUtils.updateCabOrder(currentOrder!);
    hideProgress();
    setState(() {});
  }

  completeOrder() async {
    showProgress(context, 'Completing Delivery...'.tr(), false);
    polyLines.clear();
    _markers.clear();
    currentOrder!.status = ORDER_STATUS_COMPLETED;
    updateCabWalletAmount(currentOrder!);
    await FireStoreUtils.updateCabOrder(currentOrder!);
    Position? locationData = await getCurrentLocation();
    await FireStoreUtils.getFirestOrderOrNOtCabService(currentOrder!)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateReferralAmountCabService(currentOrder!);
      }
    });
    Map<String, dynamic> payLoad = <String, dynamic>{
      "type": "cab_order",
      "orderId": currentOrder!.id
    };
    await FireStoreUtils.sendFcmMessage(
        cabCompleted, currentOrder!.author.fcmToken, payLoad);
    await FireStoreUtils.getCabFirstOrderOrNOt(currentOrder!)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateCabReferralAmount(currentOrder!);
      }
    });
    _driverModel!.inProgressOrderID = null;
    _driverModel!.location = UserLocation(
        latitude: locationData.latitude, longitude: locationData.longitude);
    _driverModel!.geoFireData = GeoFireData(
        geohash: GeoFlutterFire()
            .point(
                latitude: locationData.latitude,
                longitude: locationData.longitude)
            .hash,
        geoPoint: GeoPoint(locationData.latitude, locationData.longitude));

    currentOrder = null;

    await FireStoreUtils.updateCurrentUser(_driverModel!);
    hideProgress();
    _markers.clear();
    polyLines.clear();

    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(locationData.latitude, locationData.longitude),
            zoom: 15),
      ),
    );

    setState(() {});
  }

  openChatWithCustomer() async {
    await showProgress(context, "Please wait".tr(), false);

    User? customer =
        await FireStoreUtils.getCurrentUser(currentOrder!.authorID);
    print(currentOrder!.driverID);
    User? driver =
        await FireStoreUtils.getCurrentUser(currentOrder!.driverID.toString());

    hideProgress();
    push(
        context,
        ChatScreens(
          type: "cab_parcel_chat",
          customerName: customer!.firstName + " " + customer.lastName,
          restaurantName: driver!.firstName + " " + driver.lastName,
          orderId: currentOrder!.id,
          restaurantId: driver.userID,
          customerId: customer.userID,
          customerProfileImage: customer.profilePictureURL,
          restaurantProfileImage: driver.profilePictureURL,
          token: customer.fcmToken,
          chatType: 'Driver',
        ));
  }

  goOnline(User user) async {
    await showProgress(context, 'Going online...'.tr(), false);
    Position locationData = await getCurrentLocation();
    print('HomeScreenState.goOnline');
    user.isActive = true;
    user.location = UserLocation(
        latitude: locationData.latitude, longitude: locationData.longitude);
    user.geoFireData = GeoFireData(
        geohash: GeoFlutterFire()
            .point(
                latitude: locationData.latitude,
                longitude: locationData.longitude)
            .hash,
        geoPoint: GeoPoint(locationData.latitude, locationData.longitude));
    MyAppState.currentUser = user;
    await FireStoreUtils.updateCurrentUser(user);
    updateDriverOrder();
    await hideProgress();
  }

  // void initBackgroundFetch() async {
  //   await BackgroundFetch.configure(
  //     BackgroundFetchConfig(
  //       minimumFetchInterval: 15, // minimumFetchInterval is in minutes
  //       stopOnTerminate: false,
  //       enableHeadless: true,
  //       startOnBoot: true,
  //       requiresBatteryNotLow: false,
  //       requiresCharging: false,
  //       requiresStorageNotLow: false,
  //       requiresDeviceIdle: false,
  //       requiredNetworkType: NetworkType.ANY,
  //     ),
  //         (String taskId) async {
  //       // Background task logic (e.g., play sound)
  //       playSound();
  //       BackgroundFetch.finish(taskId);
  //     },
  //   );
  // }

  // Future<void> playSound() async {
  //   try {
  //     final ByteData data = await rootBundle.load("assets/audio/noc-driver-new-order.mp3");
  //     final Uint8List bytes = data.buffer.asUint8List();
  //
  //     await audioPlayer.setUrl(''); // Reset the URL
  //     await audioPlayer.setReleaseMode(ReleaseMode.release);
  //     await audioPlayer.playBytes(
  //       bytes,
  //       volume: 0.15, // Adjust the volume (0.0 to 1.0)
  //       respectSilence: false,
  //     );
  //   } catch (e) {
  //     print("Error playing sound: $e");
  //   }
  // }

  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  void stopSound() {
    audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  playSound() async {
    final path = await rootBundle.load("assets/audio/noc-driver-new-order.mp3");
    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.release);
    //audioPlayer.setSourceUrl(url);
    audioPlayer.play(
      BytesSource(path.buffer.asUint8List()),
      volume: 15,
      ctx: AudioContext(
        android: AudioContextAndroid(
          contentType: AndroidContentType.music,
          isSpeakerphoneOn: true,
          stayAwake: true,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: [],
        ),
      ),
    );
  }

  showNavigationChoiceDialog(
      double startLat, double startLng, double endLat, double endLng) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Navigation App'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  backgroundColor: Color(COLOR_PRIMARY),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
                onPressed: () {
                  launchMaps(startLat, startLng, endLat, endLng);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.map, color: Colors.black),
                label: Text(
                  'Maps',
                  style: TextStyle(
                    fontFamily: "GlacialIndifference",
                    color: Color(0xff000000),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  backgroundColor: Color(COLOR_PRIMARY),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
                onPressed: () {
                  launchWaze(endLat, endLng);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.directions_car, color: Colors.black),
                label: Text(
                  'Waze',
                  style: TextStyle(
                    fontFamily: "GlacialIndifference",
                    color: Color(0xff000000),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
