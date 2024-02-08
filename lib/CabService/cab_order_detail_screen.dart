import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/model/TaxModel.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../model/CabOrderModel.dart';
import '../services/helper.dart';

class CabOrderDetailScreen extends StatefulWidget {
  final CabOrderModel orderModel;

  const CabOrderDetailScreen({Key? key, required this.orderModel})
      : super(key: key);

  @override
  State<CabOrderDetailScreen> createState() => _CabOrderDetailScreenState();
}

class _CabOrderDetailScreenState extends State<CabOrderDetailScreen> {
  CabOrderModel? orderModel;
  String totalAmount = "";
  double taxAmount = 0.0;
  double adminComm = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    orderModel = widget.orderModel;
    //totalAmount = "$symbol ${(double.parse(orderModel!.subTotal!.toString()) - double.parse(orderModel!.discount!.toString()) + double.parse(orderModel!.tipValue!.toString()) + taxCalculation(orderModel!)).toStringAsFixed(decimal)}";
    if (orderModel!.taxModel != null) {
      for (var element in orderModel!.taxModel!) {
        taxAmount = taxAmount +
            calculateTax(
                amount: (double.parse(orderModel!.subTotal!.toString()) -
                        double.parse(orderModel!.discount!.toString()) +
                        double.parse(orderModel!.tipValue!.toString()))
                    .toString(),
                taxModel: element);
      }
    }

    totalAmount = amountShow(
        amount: (double.parse(orderModel!.subTotal!.toString()) -
                double.parse(orderModel!.discount!.toString()) +
                double.parse(orderModel!.tipValue!.toString()) +
                taxAmount)
            .toString());

    adminComm = (orderModel!.adminCommissionType == 'Percent') ? ((double.parse(orderModel!.subTotal.toString()) - double.parse(orderModel!.discount.toString())) * double.parse(orderModel!.adminCommission!)) / 100 : double.parse(orderModel!.adminCommission!);


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ride Detail".tr(),
          style: TextStyle(fontFamily: "GlacialIndifference",
            color: isDarkMode(context) ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
                  child: Column(
                    children: [
                      widget.orderModel.driver != null
                          ? Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      CachedNetworkImage(
                                        height: 50,
                                        width: 50,
                                        imageUrl:
                                            orderModel!.author.profilePictureURL,
                                        imageBuilder: (context, imageProvider) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator
                                                .adaptive(
                                          valueColor: AlwaysStoppedAnimation(
                                              Color(COLOR_PRIMARY)),
                                        )),
                                        errorWidget: (context, url, error) =>
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  placeholderImage,
                                                  fit: BoxFit.cover,
                                                )),
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    orderModel!.author.firstName +
                                                        " " +
                                                        orderModel!
                                                            .author.lastName,
                                                    style: const TextStyle(fontFamily: "GlacialIndifference",
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    totalAmount,
                                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                                        fontSize: 18,
                                                        color:
                                                            Color(COLOR_PRIMARY)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 6,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    orderDate(
                                                            orderModel!.createdAt)
                                                        .trim(),
                                                    style: const TextStyle(fontFamily: "GlacialIndifference",
                                                        color: Colors.black,
                                                        fontSize: 14),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15.0),
                                                    child: Container(
                                                      width: 7,
                                                      height: 7,
                                                      decoration:
                                                          const BoxDecoration(
                                                              color: Colors.grey,
                                                              shape: BoxShape
                                                                  .circle),
                                                    ),
                                                  ),
                                                  Text(
                                                    orderModel!.paymentStatus
                                                        ? "Paid".tr()
                                                        : "UnPaid".tr(),
                                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                                        fontSize: 15,
                                                        color: orderModel!
                                                                .paymentStatus
                                                            ? Colors.green
                                                            : Colors
                                                                .deepOrangeAccent),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const Divider(thickness: 1),
                                buildCabDetail(),
                              ],
                            )
                          : Container(),
                      const Divider(thickness: 1),
                      SizedBox(
                        height: 10,
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
                                        orderModel!.sourceLocationName.toString(),
                                        maxLines: 2,
                                      )),
                                      const Text(""),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        orderModel!.destinationLocationName
                                            .toString(),
                                        maxLines: 2,
                                      )),
                                      const Text(""),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const Divider(thickness: 1),
                      buildPaymentDetails(),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              color: isDarkMode(context) ? const Color(DARK_CARD_BG_COLOR) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Admin commission",
                          ),
                        ),
                        Text(
                          "(-${amountShow(amount: adminComm.toString())})",
                          style: TextStyle(fontFamily: "GlacialIndifference",fontWeight: FontWeight.w600, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Note : Admin commission will be debited from your wallet balance. \nAdmin commission will apply on order Amount minus Discount (if applicable).",
                      style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.red),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildCabDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 30),
          child: Text(
            "Cab Details :".tr(),
            style: TextStyle(fontFamily: "GlacialIndifference",
              color: isDarkMode(context) ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              orderModel!.driver!.carNumber,
              style: TextStyle(fontFamily: "GlacialIndifference",
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode(context) ? Colors.white : Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "|",
                style: TextStyle(fontFamily: "GlacialIndifference",
                    color:
                        isDarkMode(context) ? Colors.white54 : Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              orderModel!.driver!.carMakes,
              style: TextStyle(fontFamily: "GlacialIndifference",
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode(context) ? Colors.white : Colors.black,
              ),
            )
          ],
        ),
      ],
    );
  }

  buildPaymentDetails() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Payment Details".tr(),
              style: TextStyle(fontFamily: "GlacialIndifference",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode(context) ? Colors.white : Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sub Total".tr(),
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                amountShow(amount: orderModel!.subTotal.toString()),
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
              )
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Discount".tr(),
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                "(-${amountShow(amount: orderModel!.discount!.toString())})",
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              )
            ],
          ),
          const Divider(),
          ListView.builder(
            itemCount: orderModel!.taxModel!.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              TaxModel taxModel = orderModel!.taxModel![index];
              return Column(
                children: [
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    title: Text(
                      '${taxModel.title.toString()} (${taxModel.type == "fix" ? amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})',
                      style: TextStyle(fontFamily: "GlacialIndifference",
                        fontSize: 16,
                        letterSpacing: 0.5,
                        color: isDarkMode(context)
                            ? Colors.grey.shade300
                            : const Color(0xff9091A4),
                      ),
                    ),
                    trailing: Text(
                      amountShow(
                          amount: calculateTax(
                                  amount: (double.parse(
                                              orderModel!.subTotal.toString()) -
                                          double.parse(
                                              orderModel!.discount!.toString()))
                                      .toString(),
                                  taxModel: taxModel)
                              .toString()),
                      style: TextStyle(fontFamily: "GlacialIndifference",
                            
                        letterSpacing: 0.5,
                        fontSize: 16,
                        color: isDarkMode(context)
                            ? Colors.grey.shade300
                            : const Color(0xff333333),
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tax".tr(),
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(

                amountShow(amount: taxCalculation(orderModel!).toString()),
                style: TextStyle(fontFamily: "GlacialIndifference",fontFamily: "Poppinssm", color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 16),
              ),
            ],
          ),*/

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tip".tr(),
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                orderModel!.tipValue!.toString().isEmpty
                    ? amountShow(amount: "0.0")
                    : amountShow(amount: orderModel!.tipValue!.toString()),
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
              )
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total".tr(),
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
              ),
              Text(
                amountShow(amount: getTotalAmount().toString()),
                style: TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(COLOR_PRIMARY),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  double getTotalAmount() {
    double taxAmount = 0.0;
    if (orderModel!.taxModel != null) {
      for (var element in orderModel!.taxModel!) {
        taxAmount = taxAmount +
            calculateTax(
                amount: (double.parse(orderModel!.subTotal.toString()) -
                        double.parse(orderModel!.discount.toString()))
                    .toString(),
                taxModel: element);
      }
    }
    return double.parse(orderModel!.subTotal.toString()) -
        double.parse(orderModel!.discount.toString()) +
        taxAmount +
        double.parse(orderModel!.tipValue!.isEmpty
            ? "0.0"
            : orderModel!.tipValue.toString());
  }

/*double getTotalAmount() {
    return double.parse(orderModel!.subTotal.toString()) -
        double.parse(orderModel!.discount.toString()) +
        taxCalculation(orderModel!) +
        double.parse(orderModel!.tipValue!.isEmpty ? "0.0" : orderModel!.tipValue.toString());
  }

  double taxCalculation(CabOrderModel orderModel) {
    double totalTax = 0.0;

    if (orderModel.taxType!.isNotEmpty) {
      if (orderModel.taxType == "percent") {
        totalTax = (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())) * double.parse(orderModel.tax.toString()) / 100;
      } else {
        totalTax = double.parse(orderModel.tax.toString());
      }
    }
    return totalTax;
    }
  */
}
