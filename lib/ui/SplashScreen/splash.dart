import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nocdriver/main.dart';


class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    Timer(
      const Duration(seconds: 5),
          () {
        Navigator.push(context, MaterialPageRoute(builder: (ctx)=> OnBoarding()));
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEDF00),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/RiderSplashScreen.png"),
              fit: BoxFit.contain, // Use BoxFit.contain to prevent stretching
            ),
          ),
        ),
      ),
    );
  }
}