import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage.dart';
import 'login.dart';
import 'package:shyam_tiles/model/user.dart';
import 'package:shyam_tiles/model/app_settings.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Load user session + cached settings instantly (no network needed)
    await Future.wait([
      AppUser.sharedInstance.getSharedPreferences(),
      AppSettings.sharedInstance.loadCached(),
    ]);

    // 2. Refresh settings from API in background — never blocks navigation
    AppSettings.sharedInstance
        .fetchSettings()
        .timeout(const Duration(seconds: 5), onTimeout: () => false)
        .catchError((_) => false);

    final bool isLoggedIn = AppUser.sharedInstance.id > 0;

    if (isLoggedIn) {
      await Future.delayed(const Duration(seconds: 1));
    } else {
      await Future.delayed(const Duration(seconds: 3));
    }

    if (mounted) {
      final Widget destination =
          isLoggedIn ? const HomeScreen() : const Login();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => destination,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xff333333)),
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

