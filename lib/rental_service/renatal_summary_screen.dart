import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/model/TaxModel.dart';
import 'package:nocdriver/rental_service/model/rental_order_model.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:flutter/material.dart';

class RenatalSummaryScreen extends StatefulWidget {
  RentalOrderModel rentalOrderModel;

  RenatalSummaryScreen({Key? key, required this.rentalOrderModel})
      : super(key: key);

  @override
  State<RenatalSummaryScreen> createState() => _RenatalSummaryScreenState();
}

class _RenatalSummaryScreenState extends State<RenatalSummaryScreen> {
  RentalOrderModel? orderModel;

  @override
  void initState() {
    // TODO: implement initState

    setState(() {
      orderModel = widget.rentalOrderModel;
    });
    calculateAmount();
    super.initState();
  }

  calculateAmount() {
    // taxType = orderModel!.taxType.toString();
    // taxLable = orderModel!.taxLabel.toString();
    //taxAmount = double.parse(orderModel!.tax.toString());
    subTotal = double.parse(orderModel!.subTotal.toString());
    driverRate = double.parse(orderModel!.driverRate.toString());
    discountAmount = double.parse(orderModel!.discount.toString());

    adminComm = (orderModel!.adminCommissionType == 'Percent')
        ? (((subTotal + driverRate) - discountAmount) *
                double.parse(orderModel!.adminCommission!)) /
            100
        : double.parse(orderModel!.adminCommission!);
  }

  double getTotalAmount() {
    double taxAmount = 0.0;
    if (orderModel!.taxModel != null) {
      for (var element in orderModel!.taxModel!) {
        taxAmount = taxAmount +
            calculateTax(
                amount: ((subTotal + driverRate) - discountAmount).toString(),
                taxModel: element);
      }
    }
    return (subTotal + driverRate) - discountAmount + taxAmount;
  }

  /* double getTotalAmount() {
    return (subTotal + driverRate) - discountAmount + getTaxAmount();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Booking Details",
          style: TextStyle(fontFamily: "GlacialIndifference",),
        ).tr(),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios)),
      ),
      body: buildRides(),
    );
  }

  buildRides() {
    return SingleChildScrollView(
      child: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(COLOR_PRIMARY),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CachedNetworkImage(
                                height: 50,
                                width: 50,
                                imageUrl: orderModel!.author!.profilePictureURL,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator.adaptive(
                                  valueColor: AlwaysStoppedAnimation(
                                      Color(COLOR_PRIMARY)),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      orderModel!.author!.firstName +
                                          " " +
                                          orderModel!.author!.lastName,
                                      style: const TextStyle(fontFamily: "GlacialIndifference",
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Visibility(
                                      visible:
                                          orderModel!.bookWithDriver == true
                                              ? true
                                              : false,
                                      child: const Text(
                                        "With driver trip",
                                        style: TextStyle(fontFamily: "GlacialIndifference",
                                            fontSize: 14, color: Colors.white),
                                      ).tr(),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      amountShow(
                                          amount:
                                              orderModel!.subTotal.toString()),
                                      style: const TextStyle(fontFamily: "GlacialIndifference",
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800),
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
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
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
                                      address:
                                          orderModel!.pickupAddress.toString(),
                                      time: DateFormat('yyyy-MM-dd hh:mm a')
                                          .format(orderModel!.pickupDateTime!
                                              .toDate())),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  buildUsersDetails(context,
                                      isSender: false,
                                      address:
                                          orderModel!.dropAddress.toString(),
                                      time: DateFormat('yyyy-MM-dd hh:mm a')
                                          .format(orderModel!.dropDateTime!
                                              .toDate())),
                                ],
                              ),
                            ),
                            orderModel!.driver != null
                                ? buildRequestSection()
                                : Container(),
                            const SizedBox(
                              height: 5,
                            ),
                            Visibility(
                              visible: orderModel!.companyID!.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: CachedNetworkImage(
                                        width: 46,
                                        height: 46,
                                        imageUrl: orderModel!
                                            .company!.profilePictureURL,
                                        placeholder: (context, url) => Image.asset(
                                            'assets/images/img_placeholder.png'),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                'assets/images/placeholder.jpg',
                                                fit: BoxFit.fill),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Column(
                                    //       crossAxisAlignment: CrossAxisAlignment.start,
                                    //       children: [
                                    //         Text(orderModel!.company!.companyName, style: const TextStyle(fontFamily: "GlacialIndifference",fontSize: 16, color: Colors.black, letterSpacing: 1, fontWeight: FontWeight.w600)),
                                    //         const SizedBox(
                                    //           height: 4,
                                    //         ),
                                    //         Row(
                                    //           children: [
                                    //             const Icon(
                                    //               Icons.location_on,
                                    //               color: Colors.grey,
                                    //               size: 18,
                                    //             ),
                                    //             Text(orderModel!.company!.companyAddress, style: const TextStyle(fontFamily: "GlacialIndifference",fontSize: 12, color: Colors.grey, letterSpacing: 1, fontWeight: FontWeight.w600)),
                                    //           ],
                                    //         )
                                    //       ],
                                    //     )
                                    //   ],
                                    // )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Divider(
                              color: Color(0xffE2E8F0),
                              height: 0.1,
                            ),
                            buildTotalRow(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                color: isDarkMode(context)
                    ? const Color(DARK_CARD_BG_COLOR)
                    : Colors.white,
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
                            style: TextStyle(fontFamily: "GlacialIndifference",
                                fontWeight: FontWeight.w600, color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Note : Admin commission will be debited from your wallet balance. \nAdmin commission will apply on order Amount  plus DriverRate and minus Discount (if applicable).",
                        style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.red),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double adminComm = 0.0;
  double subTotal = 0.0;
  double driverRate = 0.0;
  String tabString = "About";

  // bool? taxActive = false;
  bool? isEnableCommission = false;

  // double taxAmount = 0.0;
  //String taxLable = "";
  // String taxType = "";
  String commissionAmount = "";
  String commissionType = "";

  double discountAmount = 0.0;
  String discountType = "";
  String discountLable = "";

  /* double getTaxAmount() {
    double totalTax = 0.0;
    if (taxType.isNotEmpty) {
      if (taxType == "percent") {
        totalTax = ((subTotal + driverRate) - discountAmount) * taxAmount / 100;
      } else {
        totalTax = taxAmount;
      }
    }

    return totalTax;
  }*/

  Widget buildTotalRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Booking summary".tr(),
              style: const TextStyle(fontFamily: "GlacialIndifference",
                  fontSize: 16,
                  color: Colors.black,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal".tr(),
                  style: TextStyle(fontFamily: "GlacialIndifference",
                       
                      color: Colors.black.withOpacity(0.50)),
                ),
                Text(
                  amountShow(amount: subTotal.toString()),
                  style: TextStyle(fontFamily: "GlacialIndifference",
                       
                      color: isDarkMode(context)
                          ? Colors.black
                          : const Color(0xff333333),
                      fontSize: 16),
                ),
              ],
            )),
        const Divider(
          color: Color(0xffE2E8F0),
          height: 0.1,
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Driver Amount".tr(),
                  style: TextStyle(fontFamily: "GlacialIndifference",
                       
                      color: Colors.black.withOpacity(0.50)),
                ),
                Text(
                  amountShow(amount: driverRate.toString()),
                  style: TextStyle(fontFamily: "GlacialIndifference",
                       
                      color: isDarkMode(context)
                          ? Colors.black
                          : const Color(0xff333333),
                      fontSize: 16),
                ),
              ],
            )),
        const Divider(
          color: Color(0xffE2E8F0),
          height: 0.1,
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Discount".tr(),
                  style: TextStyle(fontFamily: "GlacialIndifference",
                       
                      color: Colors.black.withOpacity(0.50)),
                ),
                Text(
                  "(-" + amountShow(amount: discountAmount.toString()) + ")",
                  style: TextStyle(fontFamily: "GlacialIndifference",
                        color: Colors.red, fontSize: 16),
                ),
              ],
            )),
        const Divider(
          color: Color(0xffE2E8F0),
          height: 0.1,
        ),
        orderModel!.taxModel != null
            ? ListView.builder(
                itemCount: orderModel!.taxModel!.length,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  TaxModel taxModel = orderModel!.taxModel![index];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${taxModel.title.toString()} (${taxModel.type == "fix" ? amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                style: const TextStyle(fontFamily: "GlacialIndifference",
                                  color: Colors.black54,
                                   
                                ),
                              ),
                            ),
                            Text(
                              amountShow(
                                  amount: calculateTax(
                                          amount: ((subTotal + driverRate) -
                                                  discountAmount)
                                              .toString(),
                                          taxModel: taxModel)
                                      .toString()),
                              style: TextStyle(fontFamily: "GlacialIndifference",
                                   
                                  color: isDarkMode(context)
                                      ? Colors.black
                                      : const Color(0xff333333),
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Color(0xffE2E8F0),
                        height: 0.1,
                      ),
                    ],
                  );
                },
              )
            : Container(),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total".tr(),
                  style: TextStyle(fontFamily: "GlacialIndifference",
                       
                      color: Colors.black.withOpacity(0.50)),
                ),
                Text(
                  amountShow(amount: getTotalAmount().toString()),
                  style: TextStyle(fontFamily: "GlacialIndifference",
                       
                      color: Color(COLOR_PRIMARY),
                      fontSize: 16),
                ),
              ],
            )),
      ],
    );
  }

  buildRequestSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 8,
          ),
          ClipOval(
            child: CachedNetworkImage(
              width: 46,
              height: 46,
              imageUrl: orderModel!.driver!.profilePictureURL,
              placeholder: (context, url) =>
                  Image.asset('assets/images/img_placeholder.png'),
              errorWidget: (context, url, error) => Image.asset(
                  'assets/images/placeholder.jpg',
                  fit: BoxFit.fill),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Driver by",
                  style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black38),
                ).tr(),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  orderModel!.driver!.firstName +
                      " " +
                      orderModel!.driver!.lastName,
                  style: const TextStyle(fontFamily: "GlacialIndifference",fontSize: 17, color: Colors.black),
                ),
              ],
            ),
          ),
          Text(
            orderModel!.status == ORDER_STATUS_COMPLETED
                ? "Completed".tr()
                : orderModel!.status == ORDER_STATUS_IN_TRANSIT
                    ? "On Ride".tr()
                    : orderModel!.status == ORDER_STATUS_REJECTED
                        ? "Canceled".tr()
                        : "Pending".tr(),
            style: TextStyle(fontFamily: "GlacialIndifference",
                color: orderModel!.status == ORDER_STATUS_COMPLETED
                    ? Colors.green
                    : orderModel!.status == ORDER_STATUS_IN_TRANSIT
                        ? Colors.amber
                        : Colors.red,
                fontWeight: FontWeight.bold),
          )
        ],
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
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey.withOpacity(0.30), width: 2.0)),
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
