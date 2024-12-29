import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage.dart';
import 'login.dart';
import 'package:shyam_tiles/model/user.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    AppUser.sharedInstance.getSharedPreferences().then((value) {
      if (AppUser.sharedInstance.id > 0) {
        Timer(
            const Duration(seconds: 1),
            () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeScreen())));
      } else {
        Timer(
            const Duration(seconds: 3),
            () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Login())));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xff333333)
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: <Color>[Color(0xffb4b4b4), Color(0xffA5A5A5)],
            // ),
            ),
        height: MediaQuery.of(context).size.height,
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - 75),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Hero(
                tag: 'logo',
                child: Image.asset(
                  'images/bg.webp',
                  height: 170,
                ),
              ),
            ),
            Hero(
              tag: 'logo1',
              child: Text(
                'SHYAM TILES',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
