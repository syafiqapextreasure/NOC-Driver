import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/CabService/cab_home_screen.dart';
import 'package:nocdriver/CabService/cab_order_screen.dart';
import 'package:nocdriver/CabService/driver_cab_list_screen.dart';
import 'package:nocdriver/ui/evp/driver_evp_screen.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/CurrencyModel.dart';
import 'package:nocdriver/model/User.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:nocdriver/ui/ChatSupport/ChatSupport.dart';
import 'package:nocdriver/ui/Language/language_choose_screen.dart';
import 'package:nocdriver/ui/auth/AuthScreen.dart';
import 'package:nocdriver/ui/bank_details/bank_details_Screen.dart';
import 'package:nocdriver/ui/chat_screen/inbox_screen.dart';
import 'package:nocdriver/ui/container/ContainerScreen.dart';
import 'package:nocdriver/ui/privacy_policy/privacy_policy.dart';
import 'package:nocdriver/ui/profile/ProfileScreen.dart';
import 'package:nocdriver/ui/termsAndCondition/terms_and_codition.dart';
import 'package:nocdriver/ui/wallet/walletScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'ride_setting_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DashBoardCabService extends StatefulWidget {
  final User user;

  const DashBoardCabService({Key? key, required this.user}) : super(key: key);

  @override
  State<DashBoardCabService> createState() => _DashBoardCabServiceState();
}

class _DashBoardCabServiceState extends State<DashBoardCabService> {
  String _appBarTitle = '';
  final fireStoreUtils = FireStoreUtils();
  late Widget _currentWidget;
  DrawerSelection _drawerSelection = DrawerSelection.Home;

  @override
  void initState() {
    super.initState();
    // if (MyAppState.currentUser!.isCompany) {
    //   setState(() {
    //     _drawerSelection = DrawerSelection.Drivers;
    //     _appBarTitle = 'Drivers'.tr();
    //     _currentWidget = DriverCabListScreen();
    //   });
    // } else {
    setState(() {
      _drawerSelection = DrawerSelection.Home;
      _appBarTitle = '';
      _currentWidget = CabHomeScreen(
        refresh: () {
          if (mounted) setState(() {});
        },
      );
    });
    // }
    setCurrency();
    updateCurrentLocation();

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
    await FireStoreUtils().getCurrency().then((value) {
      if (value != null) {
        currencyData = value;
      } else {
        currencyData = CurrencyModel(
            id: "",
            code: "USD",
            decimal: 2,
            isactive: true,
            name: "US Dollar",
            symbol: "\$",
            symbolatright: false);
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

  Location location = Location();

  updateCurrentLocation() async {
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.granted) {
      print("---->");
      location.enableBackgroundMode(enable: true);
      location.changeSettings(
          accuracy: LocationAccuracy.navigation, distanceFilter: 3);
      locationDataFinal = await location.getLocation();
      location.onLocationChanged.listen((locationData) async {
        locationDataFinal = locationData;
        await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID)
            .then((value) {
          if (value != null) {
            User driverUserModel = value;
            if (driverUserModel.isActive == true) {
              driverUserModel.location = UserLocation(
                  latitude: locationData.latitude ?? 0.0,
                  longitude: locationData.longitude ?? 0.0);
              driverUserModel.rotation = locationData.heading;
              FireStoreUtils.updateCurrentUser(driverUserModel);
            }
          }
        });
      });
    } else {
      await openBackgroundLocationDialog();
      await location.requestPermission().then((permissionStatus) {
        if (permissionStatus == PermissionStatus.granted) {
          print("---->");
          location.enableBackgroundMode(enable: true);
          location.changeSettings(
              accuracy: LocationAccuracy.navigation, distanceFilter: 3);
          location.onLocationChanged.listen((locationData) async {
            locationDataFinal = locationData;
            await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID)
                .then((value) {
              if (value != null) {
                User driverUserModel = value;
                if (driverUserModel.isActive == true) {
                  driverUserModel.location = UserLocation(
                      latitude: locationData.latitude ?? 0.0,
                      longitude: locationData.longitude ?? 0.0);
                  driverUserModel.rotation = locationData.heading;
                  FireStoreUtils.updateCurrentUser(driverUserModel);
                }
              }
            });
          });
        }
      });
    }
  }

  openBackgroundLocationDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              //width: 300.0,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: Text(
                      "Background Location permission".tr(),
                      style: TextStyle(
                          fontFamily: "GlacialIndifference",
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: Text(
                        "This app collects location data to enable location fetching at the time of you are on the way to deliver order or even when the app is in background."
                            .tr()),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16.0),
                            bottomRight: Radius.circular(16.0)),
                      ),
                      child: Text(
                        "Okay",
                        style: TextStyle(
                            fontFamily: "GlacialIndifference",
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  DateTime pre_backpress = DateTime.now();

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
              "Press Back button again to Exit".tr(),
              style: TextStyle(
                  fontFamily: "GlacialIndifference", color: Colors.white),
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
          builder: (context, user1, _) {
            return Scaffold(
              drawer: Drawer(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Consumer<User>(builder: (context, user, _) {
                            return SizedBox(
                              height: 230,
                              child: DrawerHeader(
                                margin: EdgeInsets.all(0.0),
                                padding: EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        displayCircleImage(
                                            user.profilePictureURL, 60, false),
                                        Spacer(),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Image.asset(
                                            "assets/images/darklogo.png",
                                            width: 70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      user.fullName(),
                                      style: TextStyle(
                                          fontFamily: "GlacialIndifference",
                                          color: Colors.black),
                                    ),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                          fontFamily: "GlacialIndifference",
                                          color: Colors.black),
                                    ),
                                    SwitchListTile(
                                      visualDensity: VisualDensity(
                                          horizontal: 0, vertical: -4),
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        "Online".tr(),
                                        style: TextStyle(
                                            fontFamily: "GlacialIndifference",
                                            color: Colors.black),
                                      ),
                                      value: MyAppState.currentUser!.isActive,
                                      onChanged: (value) {
                                        setState(() {
                                          MyAppState.currentUser!.isActive =
                                              value;
                                        });
                                        if (MyAppState.currentUser!.isActive ==
                                            true) {
                                          updateCurrentLocation();
                                        }
                                        FireStoreUtils.updateCurrentUser(
                                            MyAppState.currentUser!);
                                      },
                                    ),
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: Color(COLOR_PRIMARY),
                                ),
                              ),
                            );
                          }),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected:
                                  _drawerSelection == DrawerSelection.Home,
                              title: Text('Home').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Home;
                                  _appBarTitle = '';
                                  _currentWidget = CabHomeScreen(
                                    refresh: () {
                                      if (mounted) setState(() {});
                                    },
                                  );
                                });
                                // }
                              },
                              leading: Icon(CupertinoIcons.home),
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected:
                                  _drawerSelection == DrawerSelection.Orders,
                              leading: Image.asset(
                                'assets/images/truck.png',
                                color:
                                    _drawerSelection == DrawerSelection.Orders
                                        ? Color(COLOR_PRIMARY)
                                        : isDarkMode(context)
                                            ? Colors.grey.shade200
                                            : Colors.grey.shade600,
                                width: 24,
                                height: 24,
                              ),
                              title: Text('Rides').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Orders;
                                  _appBarTitle = 'Rides'.tr();
                                  _currentWidget = CabOrderScreen();
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection == DrawerSelection.EVP,
                              leading: Icon(Icons.badge_sharp),
                              title: Text('EVP').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.EVP;
                                  _appBarTitle = 'EVP'.tr();
                                  _currentWidget = DriverEVPScreen(
                                    user: user1,
                                  );
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            child: ListTile(
                              leading: Image.asset(
                                'assets/images/rewards.png',
                                color: isDarkMode(context)
                                    ? Colors.grey.shade200
                                    : Colors.grey.shade600,
                                width: 24,
                                height: 24,
                              ),
                              title: Text('Reward').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  launchUrl(Uri.parse(
                                      'https://noc-global.com/rewards'));
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            child: ListTile(
                              leading: Image.asset(
                                'assets/images/incentives.png',
                                color: isDarkMode(context)
                                    ? Colors.grey.shade200
                                    : Colors.grey.shade600,
                                width: 24,
                                height: 24,
                              ),
                              title: Text('Incentives').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  launchUrl(Uri.parse(
                                      'https://noc-global.com/incentives'));
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            child: ListTile(
                              leading: Image.asset(
                                'assets/images/tutorial_icon.png',
                                color: isDarkMode(context)
                                    ? Colors.grey.shade200
                                    : Colors.grey.shade600,
                                width: 24,
                                height: 24,
                              ),
                              title: Text('Tutorial').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _appBarTitle = 'Tutorial'.tr();
                                  launchUrl(Uri.parse(
                                      'https://noc-global.com/tutorial'));
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected:
                                  _drawerSelection == DrawerSelection.Wallet,
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
                              selected:
                                  _drawerSelection == DrawerSelection.BankInfo,
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
                              selected: _drawerSelection ==
                                  DrawerSelection.rideSetting,
                              leading: Icon(CupertinoIcons.settings),
                              title: Text('Settings').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection =
                                      DrawerSelection.rideSetting;
                                  _appBarTitle = 'Settings'.tr();
                                  _currentWidget = RideSettingScreen();
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected:
                                  _drawerSelection == DrawerSelection.Profile,
                              leading: Icon(CupertinoIcons.person),
                              title: Text('Profile').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Profile;
                                  _appBarTitle = 'My Profile'.tr();
                                  _currentWidget = ProfileScreen(
                                    user: user1,
                                  );
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection ==
                                  DrawerSelection.chooseLanguage,
                              leading: Icon(
                                Icons.language,
                                color: _drawerSelection ==
                                        DrawerSelection.chooseLanguage
                                    ? Color(COLOR_PRIMARY)
                                    : isDarkMode(context)
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade600,
                              ),
                              title: const Text('Language').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection =
                                      DrawerSelection.chooseLanguage;
                                  _appBarTitle = 'Language'.tr();
                                  _currentWidget = LanguageChooseScreen(
                                    isContainer: true,
                                  );
                                });
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected: _drawerSelection ==
                                  DrawerSelection.termsCondition,
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
                              selected: _drawerSelection ==
                                  DrawerSelection.privacyPolicy,
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
                              selected:
                                  _drawerSelection == DrawerSelection.inbox,
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
                              selected: _drawerSelection ==
                                  DrawerSelection.chatSupport,
                              leading: Icon(Icons.support_agent_outlined),
                              title: Text('Customer Support').tr(),
                              onTap: () {
                                if (MyAppState.currentUser == null) {
                                  Navigator.pop(context);
                                  push(context, AuthScreen());
                                } else {
                                  Navigator.pop(context);
                                  setState(() {
                                    _drawerSelection =
                                        DrawerSelection.chatSupport;
                                    _appBarTitle = 'Customer Support'.tr();
                                    _currentWidget = CustomerSupport();
                                  });
                                }
                              },
                            ),
                          ),
                          ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: Color(COLOR_PRIMARY),
                            child: ListTile(
                              selected:
                                  _drawerSelection == DrawerSelection.Logout,
                              leading: Icon(Icons.logout),
                              title: Text('Log out').tr(),
                              onTap: () async {
                                Navigator.pop(context);
                                await FireStoreUtils.getCurrentUser(
                                        MyAppState.currentUser!.userID)
                                    .then((value) {
                                  MyAppState.currentUser = value;
                                });
                                MyAppState.currentUser!.isActive = false;
                                MyAppState.currentUser!.lastOnlineTimestamp =
                                    Timestamp.now();
                                await FireStoreUtils.updateCurrentUser(
                                    MyAppState.currentUser!);
                                await auth.FirebaseAuth.instance.signOut();
                                MyAppState.currentUser = null;
                                location.enableBackgroundMode(enable: false);
                                pushAndRemoveUntil(
                                    context, AuthScreen(), false);
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
                title: Text(
                  _appBarTitle,
                  style: TextStyle(
                    fontFamily: "GlacialIndifference",
                    color: Colors.black,
                  ),
                ),
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                centerTitle:
                    _drawerSelection == DrawerSelection.Wallet ? true : false,
                backgroundColor: Color(0xFFFEDF00),
              ),
              body: _currentWidget,
            );
          },
        ),
      ),
    );
  }
}
