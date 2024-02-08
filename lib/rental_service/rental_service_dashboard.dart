import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/CurrencyModel.dart';
import 'package:nocdriver/model/User.dart';
import 'package:nocdriver/rental_service/add_driver_screen.dart';
import 'package:nocdriver/rental_service/driver_list_screen.dart';
import 'package:nocdriver/rental_service/rental_booking_screen.dart';
import 'package:nocdriver/rental_service/rental_home_screen.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:nocdriver/ui/Language/language_choose_screen.dart';
import 'package:nocdriver/ui/auth/AuthScreen.dart';
import 'package:nocdriver/ui/bank_details/bank_details_Screen.dart';
import 'package:nocdriver/ui/chat_screen/inbox_screen.dart';
import 'package:nocdriver/ui/privacy_policy/privacy_policy.dart';
import 'package:nocdriver/ui/profile/ProfileScreen.dart';
import 'package:nocdriver/ui/termsAndCondition/terms_and_codition.dart';
import 'package:nocdriver/ui/wallet/walletScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

enum DrawerSelection { Home, Drivers, Profile, Orders, inbox, Logout, Wallet, BankInfo, chooseLanguage, termsCondition, privacyPolicy }

class RentalServiceDashBoard extends StatefulWidget {
  final User user;

  // final String? appBarTitle;
  // final Widget? currentWidget;
  // final DrawerSelection? drawerSelection;

  const RentalServiceDashBoard({
    Key? key,
    required this.user,
    // this.appBarTitle,
    // this.currentWidget,
    // this.drawerSelection
  }) : super(key: key);

  @override
  State<RentalServiceDashBoard> createState() => _RentalServiceDashBoardState();
}

class _RentalServiceDashBoardState extends State<RentalServiceDashBoard> {
  late String _appBarTitle;
  final fireStoreUtils = FireStoreUtils();
  late Widget _currentWidget;
  late DrawerSelection _drawerSelection;

  bool isLanguageShown = false;

  @override
  void initState() {
    super.initState();
    setCurrency();
    updateLocation();
    _currentWidget = RentalHomeScreen();
    _drawerSelection = DrawerSelection.Home;
    _appBarTitle = 'Home'.tr();
    getLanguages();

    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  setCurrency() async {
    /* await FireStoreUtils()
        .getCurrency()
        .then((value) => value.forEach((element) {
              if (element.isactive = true) {
                currencyData = element;
              }
            }));*/
    await FireStoreUtils().getCurrency().then((value) {
      if (value != null) {
        currencyData = value;
      } else {
        currencyData = CurrencyModel(id: "", code: "USD", decimal: 2, isactive: true, name: "US Dollar", symbol: "\$", symbolatright: false);
      }
      setState(() {});
    });
    await FireStoreUtils().getRazorPayDemo();
    await FireStoreUtils.getPaypalSettingData();
    await FireStoreUtils.getStripeSettingData();
    await FireStoreUtils.getPayStackSettingData();
    await FireStoreUtils.getFlutterWaveSettingData();
    await FireStoreUtils.getPaytmSettingData();
    await FireStoreUtils.getWalletSettingData();
    await FireStoreUtils.getPayFastSettingData();
    await FireStoreUtils.getMercadoPagoSettingData();
    await FireStoreUtils.getDriverNearByValue();
  }

  DateTime pre_backpress = DateTime.now();

  updateLocation() async {

    MyAppState.currentUser!.isActive = true;
    Position? locationData = await getCurrentLocation();
    MyAppState.currentUser!.location = UserLocation(latitude: locationData.latitude, longitude: locationData.longitude);
    MyAppState.currentUser!.geoFireData = GeoFireData(
        geohash: GeoFlutterFire().point(latitude: locationData.latitude.toDouble(), longitude: locationData.longitude.toDouble()).hash,
        geoPoint: GeoPoint(locationData.latitude.toDouble(), locationData.longitude.toDouble()));

    await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= Duration(seconds: 2);
        pre_backpress = DateTime.now();
        if (cantExit) {
          //show snackbar
          final snack = SnackBar(
            content: Text(
              'Press Back button again to Exit'.tr(),
              style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black,
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
          return false; // false will do nothing when back press
        } else {
          return true; // true will exit the app
        }
      },
      child: ChangeNotifierProvider.value(
        value: MyAppState.currentUser,
        child: Consumer<User>(
          builder: (context, user, _) {
            return Scaffold(
              drawer: Drawer(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Consumer<User>(builder: (context, user, _) {
                            return DrawerHeader(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  displayCircleImage(user.profilePictureURL, 70, false),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      user.fullName(),
                                      style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        user.email,
                                        style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.white),
                                      )),
                                  // Padding(
                                  //     padding: const EdgeInsets.only(top: 4.0),
                                  //     child: Text(
                                  //       user.isCompany
                                  //           ? "Company Owner".tr() +
                                  //               " - ${user.companyName}"
                                  //           : user.companyId.isNotEmpty
                                  //               ? "Company Driver".tr() +
                                  //                   " - ${user.companyName}"
                                  //               : "As a Individual".tr(),
                                  //       style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.white),
                                  //     )),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: Color(COLOR_PRIMARY),
                              ),
                            );
                          }),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.Home,
                              title: Text('Home').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Home;
                                  _appBarTitle = 'Home'.tr();
                                  _currentWidget = RentalHomeScreen();
                                });
                              },
                              leading: Icon(CupertinoIcons.home),
                            ),
                          ),
                          // Visibility(
                          //   visible: MyAppState.currentUser!.isCompany,
                          //   child: ListTileTheme(
                          //     style: ListTileStyle.drawer,
                          //     selectedColor: Color(COLOR_PRIMARY),
                          //     child: ListTile(
                          //       selected: _drawerSelection == DrawerSelection.Drivers,
                          //       leading: Icon(
                          //         Icons.drive_eta_rounded,
                          //         color: _drawerSelection == DrawerSelection.Drivers
                          //             ? Color(COLOR_PRIMARY)
                          //             : isDarkMode(context)
                          //                 ? Colors.grey.shade200
                          //                 : Colors.grey.shade600,
                          //       ),
                          //       title: Text('Drivers').tr(),
                          //       onTap: () {
                          //         Navigator.pop(context);
                          //         setState(() {
                          //           _drawerSelection = DrawerSelection.Drivers;
                          //           _appBarTitle = 'Drivers'.tr();
                          //           _currentWidget = DriverListScreen();
                          //         });
                          //       },
                          //     ),
                          //   ),
                          // ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.Drivers,
                              leading: Icon(
                                Icons.drive_eta_rounded,
                                color: _drawerSelection == DrawerSelection.Drivers
                                    ? Color(COLOR_PRIMARY)
                                    : isDarkMode(context)
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade600,
                              ),
                              title: Text('Car Details').tr(),
                              onTap: () async {
                                Navigator.pop(context);
                                User? user = await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Drivers;
                                  _appBarTitle = 'Car Details'.tr();
                                  _currentWidget = AddDriverScreen(
                                    driverDetails: user,
                                    isDashBoard: true,
                                  );
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.Orders,
                              leading: Image.asset(
                                'assets/images/truck.png',
                                color: _drawerSelection == DrawerSelection.Orders
                                    ? Color(COLOR_PRIMARY)
                                    : isDarkMode(context)
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade600,
                                width: 24,
                                height: 24,
                              ),
                              title: Text('Booking History').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Orders;
                                  _appBarTitle = 'Booking History'.tr();
                                  _currentWidget = RentalBookingScreen();
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.Wallet,
                              leading: Icon(Icons.account_balance_wallet_sharp),
                              title: Text('Wallet').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Wallet;
                                  _appBarTitle = 'Earnings'.tr();
                                  _currentWidget = WalletScreen();
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.BankInfo,
                              leading: Icon(Icons.account_balance),
                              title: Text('Bank Details').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.BankInfo;
                                  _appBarTitle = 'Bank Info'.tr();
                                  _currentWidget = BankDetailsScreen();
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.Profile,
                              leading: Icon(CupertinoIcons.person),
                              title: Text('Profile').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Profile;
                                  _appBarTitle = 'My Profile'.tr();
                                  _currentWidget = ProfileScreen(
                                    user: user,
                                  );
                                });
                              },
                            ),
                          ),
                          Visibility(
                            visible: isLanguageShown,
                            child: ListTileTheme(
                              style: ListTileStyle.drawer,
                              selectedColor: Color(COLOR_PRIMARY),
                              child: ListTile(
                                selected: _drawerSelection == DrawerSelection.chooseLanguage,
                                leading: Icon(
                                  Icons.language,
                                  color: _drawerSelection == DrawerSelection.chooseLanguage
                                      ? Color(COLOR_PRIMARY)
                                      : isDarkMode(context)
                                          ? Colors.grey.shade200
                                          : Colors.grey.shade600,
                                ),
                                title: const Text('Language').tr(),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _drawerSelection = DrawerSelection.chooseLanguage;
                                    _appBarTitle = 'Language'.tr();
                                    _currentWidget = LanguageChooseScreen(
                                      isContainer: true,
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.termsCondition,
                              leading: const Icon(Icons.policy),
                              title: const Text('Terms and Condition').tr(),
                              onTap: () async {
                                push(context, const TermsAndCondition());
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.privacyPolicy,
                              leading: const Icon(Icons.privacy_tip),
                              title: const Text('Privacy policy').tr(),
                              onTap: () async {
                                push(context, const PrivacyPolicyScreen());
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.inbox,
                              leading: Icon(CupertinoIcons.chat_bubble_2_fill),
                              title: Text('Inbox').tr(),
                              onTap: () {
                                if (MyAppState.currentUser == null) {
                                  Navigator.pop(context);
                                  push(context, AuthScreen());
                                } else {
                                  Navigator.pop(context);
                                  setState(() {
                                    _drawerSelection = DrawerSelection.inbox;
                                    _appBarTitle = 'My Inbox'.tr();
                                    _currentWidget = InboxScreen();
                                  });
                                }
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.Logout,
                              leading: Icon(Icons.logout),
                              title: Text('Log out').tr(),
                              onTap: () async {
                                Navigator.pop(context);
                                await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
                                  MyAppState.currentUser = value;
                                });
                                MyAppState.currentUser!.isActive = false;
                                MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
                                await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
                                await auth.FirebaseAuth.instance.signOut();
                                MyAppState.currentUser = null;
                                pushAndRemoveUntil(context, AuthScreen(), false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("V : $appVersion"),
                    )
                  ],
                ),
              ),
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: isDarkMode(context) ? Colors.white : Color(DARK_COLOR),
                ),
                centerTitle: _drawerSelection == DrawerSelection.Wallet ? true : false,
                backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : Colors.white,
                title: Text(
                  _appBarTitle,
                  style: TextStyle(fontFamily: "GlacialIndifference",
                    color: isDarkMode(context) ? Colors.white : Colors.black,
                  ),
                ),
              ),
              body: _currentWidget,
            );
          },
        ),
      ),
    );
  }

  curcy(CurrencyModel currency) {
    if (currency.isactive == true) {
      //symbol = currency.symbol;
      // isRight = currency.symbolatright;
      // decimal = currency.decimal;
      return Center();
    }
    return Center();
  }

  Future<void> getLanguages() async {
    await FireStoreUtils.firestore.collection(Setting).doc("languages").get().then((value) {
      if (value != null) {
        List list = value.data()!["list"];
        isLanguageShown = (list.length > 0);
        setState(() {});
      }
    });
  }
}
