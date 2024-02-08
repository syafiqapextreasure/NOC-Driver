import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/OrderModel.dart';
import 'package:nocdriver/model/ProductModel.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderModel>> ordersFuture;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<OrderModel> ordersList = [];

  @override
  void initState() {
    super.initState();
    print("------>${ordersList.length}");
    ordersFuture = _fireStoreUtils.getDriverOrders(MyAppState.currentUser!.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<OrderModel>>(
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
                child: showEmptyState('No Previous Orders'.tr(), description: "Let's deliver food!".tr()),
              );
            } else {
              ordersList = snapshot.data!;
              return ListView.builder(itemCount: ordersList.length, padding: const EdgeInsets.all(12), itemBuilder: (context, index) => buildOrderItem(ordersList[index]));
            }
          }),
    );
  }

  Widget buildOrderItem(OrderModel orderModel) {
    double total = 0.0;
    total = 0.0;
    String extrasDisVal = '';
    orderModel.products.forEach((element) {
      total += element.quantity * double.parse(element.price);

      for (int i = 0; i < element.extras.length; i++) {
        extrasDisVal += '${element.extras[i].toString().replaceAll("\"", "")} ${(i == element.extras.length - 1) ? "" : ","}';
      }
    });

    print("id is ${orderModel.id}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade100, width: 0.1),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade200, blurRadius: 2.0, spreadRadius: 0.4, offset: Offset(0.2, 0.2)),
            ],
            color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(orderModel.products.first.photo),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${orderDate(orderModel.createdAt)} - ${orderModel.status}',
                    style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.white, fontSize: 17),
                  ),
                ),
              ),
            ),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderModel.products.length,
                padding: EdgeInsets.only(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  ProductModel product = orderModel.products[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        minLeadingWidth: 10,
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                        leading: CircleAvatar(
                          radius: 13,
                          backgroundColor: Color(COLOR_PRIMARY),
                          child: Text(
                            '${product.quantity}',
                            style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(fontFamily: "GlacialIndifference",color: isDarkMode(context) ? Colors.black : Color(0XFF333333), fontSize: 18, letterSpacing: 0.5, ),
                        ),
                        trailing: Text(
                          amountShow(amount: double.parse((product.extras_price!.isNotEmpty && double.parse(product.extras_price!) != 0.0) ? (double.parse(product.extras_price!) + double.parse(product.price)).toString() : product.price).toString()),
                          style: TextStyle(fontFamily: "GlacialIndifference",color: isDarkMode(context) ? Colors.grey.shade200 : Color(0XFF333333), fontSize: 17, letterSpacing: 0.5, ),
                        ),
                      ),
                      product.variant_info != null && product.variant_info!.variant_options != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Wrap(
                                spacing: 6.0,
                                runSpacing: 6.0,
                                children: List.generate(
                                  product.variant_info!.variant_options!.length,
                                  (i) {
                                    return _buildChip(
                                        "${product.variant_info!.variant_options!.keys.elementAt(i)} : ${product.variant_info!.variant_options![product.variant_info.variant_options!.keys.elementAt(i)]}",
                                        i);
                                  },
                                ).toList(),
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 10),
                        child: extrasDisVal.isEmpty
                            ? Container()
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  extrasDisVal,
                                  style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 16, color: Colors.grey,),
                                ),
                              ),
                      ),
                    ],
                  );
                }),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderModel.products.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  ProductModel product = orderModel.products[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        border: Border.all(color: Color(COLOR_PRIMARY)),
                      ),
                      child: Text(
                        '${product.quantity}',
                        style: TextStyle(fontFamily: "GlacialIndifference",color: Color(COLOR_PRIMARY), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: TextStyle(fontFamily: "GlacialIndifference",fontWeight: FontWeight.bold,color: Colors.black),
                    ),
                    trailing: Text(
                      amountShow(amount: product.price),
                      style: TextStyle(fontFamily: "GlacialIndifference",fontWeight: FontWeight.bold,color: Colors.black),
                    ),
                  );
                }),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Center(
                child: Text(
                  'Total : '.tr() + amountShow(amount: total.toString()),
                  style: TextStyle(fontFamily: "GlacialIndifference",color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  final audioPlayer = AudioPlayer(playerId: "playerId");
  bool isPlaying = false;

  playSound() async {
    final path = await rootBundle.load("assets/audio/mixkit-happy-bells-notification-937.mp3");

    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    //audioPlayer.setSourceUrl(url);
    audioPlayer.play(BytesSource(path.buffer.asUint8List()),
        volume: 15,
        ctx: AudioContext(
            android:
                AudioContextAndroid(contentType: AndroidContentType.music, isSpeakerphoneOn: true, stayAwake: true, usageType: AndroidUsageType.alarm, audioFocus: AndroidAudioFocus.gainTransient),
            iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: [])));
  }
}

Widget _buildChip(String label, int attributesOptionIndex) {
  return Container(
    decoration: BoxDecoration(color: const Color(0xffEEEDED), borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: const TextStyle(fontFamily: "GlacialIndifference",
          color: Colors.black,
        ),
      ),
    ),
  );
}
