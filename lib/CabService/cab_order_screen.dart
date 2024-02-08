import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/CabOrderModel.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:flutter/material.dart';

import 'cab_order_detail_screen.dart';

class CabOrderScreen extends StatefulWidget {
  const CabOrderScreen({Key? key}) : super(key: key);

  @override
  State<CabOrderScreen> createState() => _CabOrderScreenState();
}

class _CabOrderScreenState extends State<CabOrderScreen> {
  late Future<List<CabOrderModel>> ordersFuture;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<CabOrderModel> ordersList = [];

  @override
  void initState() {
    super.initState();
    ordersFuture = _fireStoreUtils.getCabDriverOrders(MyAppState.currentUser!.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CabOrderModel>>(
          future: ordersFuture,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(
                      Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
              );
            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return Center(
                child: showEmptyState('No Rides Found'.tr()),
              );
            } else {
              ordersList = snapshot.data!;
              return ListView.builder(itemCount: ordersList.length, padding: const EdgeInsets.all(12), itemBuilder: (context, index) => buildOrderItem(ordersList[index]));
            }
          }),
    );
  }

  Widget buildOrderItem(CabOrderModel orderModel) {
    final size = MediaQuery.of(context).size;
print(orderModel.id);
    //String totalAmount = "$symbol ${(double.parse(orderModel.subTotal!.toString())).toStringAsFixed(decimal)}";
    String totalAmount = amountShow(amount: orderModel.subTotal!.toString());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), //border corner radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), //color of shadow
              spreadRadius: 3, //spread radius
              blurRadius: 7, // blur radius
              offset: const Offset(0, 2), // changes position of shadow
              //first paramerter of offset is left-right
              //second parameter is top to down
            ),
            //you can set more BoxShadow() here
          ],
        ), // Change
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => push(
                context,
                CabOrderDetailScreen(
                  orderModel: orderModel,
                )),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                child: Column(
                  children: [
                    orderModel.driver != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                CachedNetworkImage(
                                  height: 50,
                                  width: 50,
                                  imageUrl: orderModel.author.profilePictureURL,
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              orderModel.author.firstName + " " + orderModel.author.lastName,
                                              style: const TextStyle(fontFamily: "GlacialIndifference",
                                                fontSize: 18,color: Colors.black
                                              ),
                                            ),
                                            Text(
                                              totalAmount,
                                              style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 18, color: Color(COLOR_PRIMARY)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              orderDate(orderModel.createdAt).trim(),
                                              style: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 14),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                              child: Container(
                                                width: 7,
                                                height: 7,
                                                decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                                              ),
                                            ),
                                            Text(
                                              orderModel.paymentStatus ? "Paid".tr() : "UnPaid".tr(),
                                              style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 15, color: orderModel.paymentStatus ? Colors.green : Colors.deepOrangeAccent),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(),

                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/ic_pic_drop_location.png",
                          height: 80,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      orderModel.sourceLocationName.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.black,)
                                    )),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: const Divider(),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      orderModel.destinationLocationName.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.black,)
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(15.0),
                    //   child: Text(
                    //     'Order status - ${orderModel.status}',
                    //     style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.grey.shade800,),
                    //   ),
                    // ),
                    // const SizedBox(height: 16),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     Text(
                    //       'Total:'.tr()+symbol+(double.parse(orderModel.subTotal!.toString()) - double.parse(orderModel.discount!.toString())+ double.parse(orderModel.tipValue!.toString()) + taxCalculation(orderModel)).toStringAsFixed(decimal),
                    //       style: const TextStyle(fontFamily: "GlacialIndifference",fontWeight: FontWeight.bold),
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
