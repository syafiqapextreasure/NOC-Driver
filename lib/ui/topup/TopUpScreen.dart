import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/topupTranHistory.dart';
import 'package:flutter/material.dart';
class TopUpScreen extends StatefulWidget {

  const TopUpScreen({Key? key}) : super(key: key);

  @override
  TopUpScreenState createState() => TopUpScreenState();
}

class TopUpScreenState extends State<TopUpScreen> {

  Stream<QuerySnapshot>? topupHistoryQuery;
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final userId = MyAppState.currentUser!.userID;


  void initState(){
    getPaymentSettingData();
  }
  getPaymentSettingData() async {
    topupHistoryQuery =
        fireStore.collection(Wallet).where('user_id', isEqualTo: userId)
            .orderBy('date', descending: true)
            .snapshots();
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : Text("TopUp History".tr(),style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black),),
        leading: GestureDetector(
          onTap: () {
           Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color:Colors.black
          ),
        ),
        backgroundColor: Color(COLOR_PRIMARY),
      ),

      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: showTopupHistory(context),
        ),
      ),
    );
  }
  Widget showTopupHistory(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: topupHistoryQuery,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'.tr()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SizedBox(height: 35, width: 35, child: CircularProgressIndicator()));
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
                "No Transaction History".tr(),
                style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 18),
              ));
        } else {
          return ListView(
            physics: BouncingScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {

              final topUpData = TopupTranHistoryModel.fromJson(document.data() as Map<String, dynamic>);

              //Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return buildTransactionCard(
                topupTranHistory: topUpData,
                date: topUpData.date.toDate(),
              );
            }).toList(),
          );
        }
      },
    );
  }
  Widget buildTransactionCard({
    required TopupTranHistoryModel topupTranHistory,
    required DateTime date,
  }) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3),
      child: GestureDetector(
        onTap: () => showTransactionDetails(topupTranHistory: topupTranHistory),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Container(
                    color: Color(COLOR_PRIMARY).withOpacity(0.06),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(COLOR_PRIMARY)),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.78,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width * 0.48,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topupTranHistory.isTopup ? "Wallet Topup".tr() : "Wallet Amount Deducted".tr(),
                              style: TextStyle(fontFamily: "GlacialIndifference",
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Opacity(
                              opacity: 0.65,
                              child: Text(
                                "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(topupTranHistory.date.toDate()).toUpperCase()}",
                                style: TextStyle(fontFamily: "GlacialIndifference",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0, left: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${topupTranHistory.isTopup ? "+" : "-"} ${amountShow(amount: topupTranHistory.amount.toString())}",
                              style: TextStyle(fontFamily: "GlacialIndifference",
                                fontWeight: FontWeight.w600,
                                color: topupTranHistory.isTopup ? Colors.green : Colors.red,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showTransactionDetails({
    required TopupTranHistoryModel topupTranHistory,
  }) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: size.height * 0.80,
              width: size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: Text(
                        "Transaction Details".tr(),
                        style: TextStyle(fontFamily: "GlacialIndifference",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                      child: Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Transaction ID".tr(),
                                    style: TextStyle(fontFamily: "GlacialIndifference",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Opacity(
                                    opacity: 0.8,
                                    child: Text(
                                      topupTranHistory.id,
                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 30),
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: Container(
                                    color: Color(COLOR_PRIMARY).withOpacity(0.05),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(COLOR_PRIMARY)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.48,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(topupTranHistory.date.toDate())}",
                                        style: TextStyle(fontFamily: "GlacialIndifference",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          topupTranHistory.isTopup ? "Wallet Topup".tr() : "Wallet Amount Deducted".tr(),
                                          style: TextStyle(fontFamily: "GlacialIndifference",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${topupTranHistory.isTopup ? "+" : "-"} ${amountShow(amount: topupTranHistory.amount.toString())}",
                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontWeight: FontWeight.w600,
                                        color: topupTranHistory.isTopup ? Colors.green : Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Payment Details".tr(),
                                        style: TextStyle(fontFamily: "GlacialIndifference",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Opacity(
                                            opacity: 0.7,
                                            child: Text(
                                              "Pay Via".tr(),
                                              style: TextStyle(fontFamily: "GlacialIndifference",
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: !topupTranHistory.isTopup,
                                            child: Text(
                                              "  " + topupTranHistory.paymentMethod.toUpperCase(),
                                              style: TextStyle(fontFamily: "GlacialIndifference",
                                                fontWeight: FontWeight.w600,
                                                color: Color(COLOR_PRIMARY),
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                    },
                                    child: Text(
                                      topupTranHistory.isTopup ? topupTranHistory.paymentMethod.toUpperCase() : "".tr().toUpperCase(),
                                      style: TextStyle(fontFamily: "GlacialIndifference",
                                        fontWeight: FontWeight.w600,
                                        color: Color(COLOR_PRIMARY),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date in UTC Format".tr(),
                                        style: TextStyle(fontFamily: "GlacialIndifference",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(topupTranHistory.date.toDate()).toUpperCase()}",
                                          style: TextStyle(fontFamily: "GlacialIndifference",
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}