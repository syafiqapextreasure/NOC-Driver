// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:nocdriver/constants.dart';
// import 'package:nocdriver/main.dart';
// import 'package:nocdriver/model/User.dart';
// import 'package:nocdriver/rental_service/add_driver_screen.dart';
// import 'package:nocdriver/rental_service/driver_details_screen.dart';
// import 'package:nocdriver/rental_service/driver_order_list.dart';
// import 'package:nocdriver/services/FirebaseHelper.dart';
// import 'package:nocdriver/services/helper.dart';
// import 'package:flutter/material.dart';
//
// class DriverListScreen extends StatefulWidget {
//   const DriverListScreen({Key? key}) : super(key: key);
//
//   @override
//   State<DriverListScreen> createState() => _DriverListScreenState();
// }
//
// class _DriverListScreenState extends State<DriverListScreen> {
//   List<User> driverList = [];
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     getCompanyDriver();
//     super.initState();
//   }
//
//   getCompanyDriver() async {
//     await FireStoreUtils().getRentalCompanyDriver(MyAppState.currentUser!.userID).then((value) {
//       setState(() {
//         driverList = value;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: driverList.isEmpty
//           ? Center(child: showEmptyState('Driver not found'))
//           : Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: ListView.builder(
//                 itemCount: driverList.length,
//                 shrinkWrap: true,
//                 itemBuilder: (context, index) {
//                   return InkWell(
//                     onTap: () {
//                       push(
//                           context,
//                           DriverDetailsScreen(
//                             driverDetails: driverList[index],
//                           ));
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: isDarkMode(context) ? Colors.grey.shade700 : Colors.white,
//                           borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 2,
//                               blurRadius: 2,
//                               offset: const Offset(0, 2), // changes position of shadow
//                             ),
//                           ],
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   driverList[index].profilePictureURL.isEmpty
//                                       ? CircleAvatar(
//                                           radius: 20.0,
//                                           backgroundImage: AssetImage('assets/images/placeholder.jpg'),
//                                           backgroundColor: Colors.transparent,
//                                         )
//                                       : CircleAvatar(
//                                           radius: 20.0,
//                                           backgroundImage: NetworkImage(driverList[index].profilePictureURL.toString()),
//                                           backgroundColor: Colors.transparent,
//                                         ),
//                                   const SizedBox(
//                                     width: 5,
//                                   ),
//                                   Expanded(
//                                     child: Text(driverList[index].firstName.toString(),
//                                         style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 16, color: Colors.black, letterSpacing: 1, fontWeight: FontWeight.w600)),
//                                   ),
//                                   InkWell(
//                                     onTap: () {
//                                       push(
//                                           context,
//                                           DriverOrderList(
//                                             driverId: driverList[index].userID,
//                                           ));
//                                     },
//                                     child: Text("View Order".tr(), style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 16, color: Color(COLOR_PRIMARY), letterSpacing: 1, fontWeight: FontWeight.w600)),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 child: CachedNetworkImage(
//                                   height: MediaQuery.of(context).size.height * 0.20,
//                                   imageUrl: driverList[index].carInfo!.carImage!.first,
//                                   imageBuilder: (context, imageProvider) => Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                                     ),
//                                   ),
//                                   placeholder: (context, url) => Center(
//                                       child: CircularProgressIndicator.adaptive(
//                                     valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
//                                   )),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               Text(
//                                 "${driverList[index].carName.toString()} ${driverList[index].carMakes.toString()}",
//                                 style: const TextStyle(fontFamily: "GlacialIndifference",color: Colors.black, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.w600),
//                               ),
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Row(
//                                       children: [
//                                         Icon(Icons.people, color: Colors.black.withOpacity(0.50), size: 16),
//                                         const SizedBox(
//                                           width: 5,
//                                         ),
//                                         Text(
//                                           "${driverList[index].carInfo!.passenger.toString()} " + "seater".tr(),
//                                           style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black.withOpacity(0.50), letterSpacing: 2, fontWeight: FontWeight.w600),
//                                         ),
//                                         const SizedBox(
//                                           width: 10,
//                                         ),
//                                         Icon(Icons.star, color: Colors.orange.withOpacity(0.80), size: 16),
//                                         const SizedBox(
//                                           width: 5,
//                                         ),
//                                         Text(
//                                             driverList[index].reviewsCount != 0 ? (driverList[index].reviewsSum / driverList[index].reviewsCount).toStringAsFixed(1) : 0.toString(),
//                                             style: const TextStyle(fontFamily: "GlacialIndifference",
//                                               fontFamily: "Poppinssr",
//                                               letterSpacing: 0.5,
//                                             )),
//                                       ],
//                                     ),
//                                   ),
//                                   Text(
//                                     amountShow(amount : driverList[index].carRate.toString()),
//                                     style: TextStyle(fontFamily: "GlacialIndifference",color: Color(COLOR_PRIMARY), letterSpacing: 0.5, fontWeight: FontWeight.w900),
//                                   ),
//                                   Text(
//                                     "/day".tr(),
//                                     style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.black.withOpacity(0.50), letterSpacing: 0.5, fontWeight: FontWeight.w600),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Color(COLOR_PRIMARY),
//         onPressed: () async {
//           final result = await Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => AddDriverScreen(
//                     driverDetails: null,
//                     isDashBoard: false,
//                   )));
//           print(result);
//           if (result != null) {
//             getCompanyDriver();
//           }
//         },
//         child: Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
