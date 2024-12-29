import 'package:flutter/material.dart';
import 'package:shyam_tiles/common/app_constant.dart';

import 'splash.dart';

//Main function is the starting point for all our flutter apps.
void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.sharedInstance.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}
