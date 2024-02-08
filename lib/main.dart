import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/CabService/dashboard_cab_service.dart';
import 'package:nocdriver/Parcel_service/parcel_service_dashboard.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/model/mail_setting.dart';
import 'package:nocdriver/rental_service/rental_service_dashboard.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:nocdriver/services/notification_service.dart';
import 'package:nocdriver/ui/SplashScreen/splash.dart';
import 'package:nocdriver/ui/auth/AuthScreen.dart';
import 'package:nocdriver/ui/container/ContainerScreen.dart';
import 'package:nocdriver/ui/onBoarding/OnBoardingScreen.dart';
import 'package:nocdriver/userPrefrence.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nocdriver/utils/DarkThemeProvider.dart';
import 'package:nocdriver/utils/Styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/User.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SharedPreferences sp = await SharedPreferences.getInstance();
  await UserPreference.init();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ms')],
        path: 'assets/translations',
        fallbackLocale: sp.getString('languageCode') != null
            ? Locale(sp.getString('languageCode')!)
            : Locale('en'),
        saveLocale: true,
        useOnlyLangCode: true,
        useFallbackTranslations: true,
        child: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  /// this key is used to navigate to the appropriate screen when the
  /// notification is clicked from the system tray
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: 'Main Navigator');

  static User? currentUser;

  NotificationService notificationService = NotificationService();

  notificationInit() {
    notificationService.initInfo().then((value) async {
      String token = await NotificationService.getToken();
      log(":::::::TOKEN:::::: $token");
      if (currentUser != null) {
        await FireStoreUtils.getCurrentUser(currentUser!.userID).then((value) {
          if (value != null) {
            currentUser = value;
            currentUser!.fcmToken = token;
            FireStoreUtils.updateCurrentUser(currentUser!);
          }
        });
      }
    });
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("globalSettings")
          .get()
          .then((dineinresult) {
        if (dineinresult.exists &&
            dineinresult.data() != null &&
            dineinresult.data()!.containsKey("website_color")) {
          COLOR_PRIMARY = int.parse(
              dineinresult.data()!["website_color"].replaceFirst("#", "0xff"));
        }
      });

      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("Version")
          .get()
          .then((value) {
        print(value.data());
        appVersion = value.data()!['app_version'].toString();
      });
      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("emailSetting")
          .get()
          .then((value) {
        if (value.exists) {
          mailSettings = MailSettings.fromJson(value.data()!);
        }
      });
      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("googleMapKey")
          .get()
          .then((value) {
        print(value.data());
        GOOGLE_API_KEY = value.data()!['key'].toString();
      });

      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("serverKey")
          .get()
          .then((value) {
        print(value.data());
        SERVER_KEY = value.data()!['serverKey'].toString();
      });

      await FireStoreUtils().getDriverOrderSetting();
    } catch (e) {}
  }

  setUpToken() async {
    if (MyAppState.currentUser != null) {
      await FireStoreUtils.firebaseMessaging.getToken().then((value) {
        MyAppState.currentUser!.fcmToken = value!;
        FireStoreUtils.updateCurrentUser(currentUser!);
      });
    }
  }
  // DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: notificationService.navigatorKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'NOC Driver'.tr(),
        builder: EasyLoading.init(),
        // theme: Styles.themeData(themeChangeProvider.darkTheme, context),
        theme: ThemeData(
            appBarTheme: AppBarTheme(
                centerTitle: true,
                color: Colors.transparent,
                elevation: 0,
                actionsIconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
                iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                toolbarTextStyle: TextTheme(
                        titleLarge: TextStyle(
                            fontFamily: "GlacialIndifference",
                            color: Colors.black,
                            fontSize: 17.0,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700))
                    .bodyMedium,
                titleTextStyle:
                    TextTheme(titleLarge: TextStyle(fontFamily: "GlacialIndifference", color: Colors.black, fontSize: 17.0, letterSpacing: 0, fontWeight: FontWeight.w700))
                        .titleLarge),
            bottomSheetTheme:
                BottomSheetThemeData(backgroundColor: Colors.white),
            textSelectionTheme:
                TextSelectionThemeData(selectionColor: Colors.black),
            primaryColor: Color(COLOR_PRIMARY),
            brightness: Brightness.light),
        darkTheme: ThemeData(
            appBarTheme: AppBarTheme(
                centerTitle: true,
                color: Colors.transparent,
                elevation: 0,
                actionsIconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
                iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
                toolbarTextStyle: TextTheme(
                        titleLarge: TextStyle(
                            fontFamily: "GlacialIndifference",
                            color: Colors.grey[200],
                            fontSize: 17.0,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700))
                    .bodyMedium,
                titleTextStyle: TextTheme(titleLarge: TextStyle(fontFamily: "GlacialIndifference", color: Colors.grey[200], fontSize: 17.0, letterSpacing: 0, fontWeight: FontWeight.w700)).titleLarge,
                systemOverlayStyle: SystemUiOverlayStyle.light),
            textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.yellow),
            bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
            primaryColor: Color(COLOR_PRIMARY),
            brightness: Brightness.dark),
        debugShowCheckedModeBanner: false,
        color: Color(COLOR_PRIMARY),
        home: Splash()

        // OnBoarding()
        );
  }

  @override
  void initState() {
    notificationInit();
    initializeFlutterFire();
    WidgetsBinding.instance.addObserver(this);
    setUpToken();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

/*  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (auth.FirebaseAuth.instance.currentUser != null && currentUser != null) {
      await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
        MyAppState.currentUser = value;
        if (state == AppLifecycleState.paused) {
          //user offline
          MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
          if (MyAppState.currentUser!.inProgressOrderID != null) {
            MyAppState.currentUser!.isActive = false;
          } else {
            MyAppState.currentUser!.isActive = MyAppState.currentUser!.isActive == true ? false : true;
          }
          FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
        } else if (state == AppLifecycleState.resumed) {
          //user online
          if (MyAppState.currentUser!.inProgressOrderID != null) {
            MyAppState.currentUser!.isActive = false;
          } else {
            MyAppState.currentUser!.isActive = MyAppState.currentUser!.isActive == false ? true : false;
          }
          FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
        }
      });
    }
  }*/
}

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  Future hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        if (user != null && user.role == USER_ROLE_DRIVER) {
          if (user.active) {
            user.isActive = true;
            user.role = USER_ROLE_DRIVER;
            user.fcmToken =
                await FireStoreUtils.firebaseMessaging.getToken() ?? '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            if (user.serviceType == "cab-service") {
              pushAndRemoveUntil(
                  context,
                  DashBoardCabService(
                    user: user,
                  ),
                  false);
            } else if (user.serviceType == "parcel_delivery") {
              pushAndRemoveUntil(
                  context, ParcelServiceDashBoard(user: user), false);
            } else if (user.serviceType == "rental-service") {
              pushAndRemoveUntil(
                  context, RentalServiceDashBoard(user: user), false);
            } else {
              pushAndRemoveUntil(context, ContainerScreen(user: user), false);
            }
          } else {
            user.isActive = false;
            user.lastOnlineTimestamp = Timestamp.now();
            await FireStoreUtils.updateCurrentUser(user);
            await auth.FirebaseAuth.instance.signOut();
            MyAppState.currentUser = null;
            pushAndRemoveUntil(context, AuthScreen(), false);
          }
        } else {
          pushReplacement(context, AuthScreen());
        }
      } else {
        pushReplacement(context, AuthScreen());
      }
    } else {
      pushReplacement(context, OnBoardingScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(
            Color(COLOR_PRIMARY),
          ),
        ),
      ),
    );
  }
}

Future<dynamic> backgroundMessageHandler(RemoteMessage remoteMessage) async {
  Map<dynamic, dynamic> message = remoteMessage.data;
  if (message.containsKey('data')) {
    // Handle data message
    print('backgroundMessageHandler message.containsKey(data)');
  }

  if (message.containsKey('notification')) {
    // Handle notification message
  }
}
//hello