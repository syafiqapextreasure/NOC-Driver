import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/rental_service/model/rental_order_model.dart';
import 'package:nocdriver/rental_service/renatal_summary_screen.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:flutter/material.dart';

class DriverOrderList extends StatefulWidget {
  String? driverId;

  DriverOrderList({Key? key, this.driverId}) : super(key: key);

  @override
  State<DriverOrderList> createState() => _DriverOrderListState();
}

class _DriverOrderListState extends State<DriverOrderList> {
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<RentalOrderModel> ordersList = [];

  @override
  void initState() {
    // TODO: implement initState
    getBookedData();
    super.initState();
  }

  bool isLoading = true;

  getBookedData() async {
    await _fireStoreUtils.getRentalOrderByDriverOrder(widget.driverId.toString(), MyAppState.currentUser!.userID).then((value) {
      setState(() {
        ordersList = value;
        print("111");
        print(ordersList.length);
        isLoading = false;
        print("--->");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text("Booking".tr()),
        centerTitle: true,
        leading: GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ordersList.isEmpty
              ? Center(
                  child: Text(
                  "Booking not found".tr(),
                  style: TextStyle(fontFamily: "GlacialIndifference",fontWeight: FontWeight.bold, fontSize: 20),
                ))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: ordersList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return buildRides(ordersList[index]);
                  },
                ),
    );
  }

  buildRides(RentalOrderModel orderModel) {




    return GestureDetector(
      onTap: () {
        push(context, RenatalSummaryScreen(rentalOrderModel: orderModel));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Color(COLOR_PRIMARY),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(
                          height: 50,
                          width: 50,
                          imageUrl: orderModel.author!.profilePictureURL,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                          )),
                          errorWidget: (context, url, error) => ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                placeholderImage,
                                fit: BoxFit.cover,
                              )),
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderModel.author!.firstName + " " + orderModel.author!.lastName,
                                style: const TextStyle(fontFamily: "GlacialIndifference",fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Visibility(
                                visible: orderModel.bookWithDriver == true ? true : false,
                                child: const Text(
                                  "With driver trip",
                                  style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 14, color: Colors.white),
                                ).tr(),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                amountShow(amount : orderModel.subTotal.toString()),
                                style: const TextStyle(fontFamily: "GlacialIndifference",fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            buildUsersDetails(context,
                                address: orderModel.pickupAddress.toString(), time: DateFormat('yyyy-MM-dd hh:mm a').format(orderModel.pickupDateTime!.toDate())),
                            const SizedBox(
                              height: 10,
                            ),
                            buildUsersDetails(context,
                                isSender: false, address: orderModel.dropAddress.toString(), time: DateFormat('yyyy-MM-dd hh:mm a').format(orderModel.dropDateTime!.toDate())),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildUsersDetails(
    context, {
    bool isSender = true,
    required String time,
    required String address,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), border: Border.all(color: Colors.grey.withOpacity(0.30), width: 2.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSender ? "PickUp".tr() + " " : "Drop off".tr() + " ",
              style: const TextStyle(fontFamily: "GlacialIndifference",fontSize: 18, color: Colors.black),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                    ),
                    child: Icon(
                      Icons.access_time_outlined,
                      size: 20,
                      color: Color(COLOR_PRIMARY),
                    )),
                Expanded(
                  child: Text(
                    time,
                    style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 16, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 20,
                      color: Color(COLOR_PRIMARY),
                    )),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 16, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
