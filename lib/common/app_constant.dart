import 'dart:ui';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  NavigationService._();

  factory NavigationService() => instance;

  static final sharedInstance = NavigationService();
  static final NavigationService instance = NavigationService._();

  Future<void> init() async {}
}

extension NumberParsing on String {
  bool isTrue() {
    if (this == "1" || this.toLowerCase() == "true") {
      return true;
    } else {
      return false;
    }
  }

  bool isNull() {
    if (this == "0" || this.trim() == "") {
      return true;
    } else {
      return false;
    }
  }

  int parseInt() {
    return int.parse(this);
  }
// ···
}

class AppConstant with ChangeNotifier {
  static final sharedInstance = AppConstant();

  static var uvid = "";
  static const APP_NAME = "Relief";
  String _selectedTitle = "";

  String getSelectedTitle() {
    return _selectedTitle;
  }

  void changeSelectedTitle(String string) {
    _selectedTitle = string;
    notifyListeners();
  }
}

class ColorConstant {
  static const APP_MAIN_COLOR = Color(0xFF980DCD);

  static const TMP_TEST_COLOR = Color(0xFF6e6b72);
  static const BLACK_COLOR = Colors.black;
  static const APP_MAIN_TEXT_COLOR = Color(0xFF6B606E);
  static const BLACK_TEXT_COLOR = Color(0xFF424b60);
  static const LINK_GREEN_BUTTON_COLOR = Color(0xFF00b0ad);

  static const LIGHT_GRAY_PLACE_HOLDER_TEXT_COLOR = Color(0xFFcccccc);
  static const LIGHT_GRAY_BOTTOM_BAR = Color(0xFFababab);
  static const SEPARATOR_COLOR = Color(0xFFebebeb);

  static const ORANGE_LIGHT_BACK_SHADOW = Color(0xFFf57e20);
  static const ORANGE_DARK_BACK_SHADOW = Color(0xFFf05223);

  static const BLUE_DARK_BACK_SHADOW = Color(0xFF266e98);
  static const BLUE_LIGHT_BACK_SHADOW = Color(0xFF4ebbc9);

  static const PURPLE_DARK_BACK_SHADOW = Color(0xFF6236ff);
  static const PURPLE_LIGHT_BACK_SHADOW = Color(0xFFa642cc);

  static const PURPLE_TEXT_COLOR = Color(0xFF6236ff);
}

class ReliefFonts {
  static TextStyle bold(double size, Color color) {
    return TextStyle(
        fontFamily: 'ROBOTO',
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color,
        decoration: TextDecoration.none);
    // return TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w700,fontSize: size, color: color, decoration: TextDecoration.none);
  }

  static TextStyle medium(double size, Color color) {
    return TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.w500,
        fontSize: size,
        color: color,
        decoration: TextDecoration.none);
    // return TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w500,fontSize: size, color: color, decoration: TextDecoration.none);
  }

  static TextStyle regular(double size, Color color) {
    return TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.w400,
        fontSize: size,
        color: color,
        decoration: TextDecoration.none);
    // return TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w400,fontSize: size, color: color, decoration: TextDecoration.none);
  }

  static TextStyle italicRegular(double size, Color color) {
    return TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.w400,
        fontSize: size,
        color: color,
        decoration: TextDecoration.none);
  }

  static TextStyle italicBold(double size, Color color) {
    return TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color,
        decoration: TextDecoration.none);
    // return TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w700,fontSize: size, color: color, fontStyle: FontStyle.italic, decoration: TextDecoration.none);
  }
}

class UtilFunctions {
  static String language = "";
  static bool isLoading = false;

  static bool isEnglish() {
    if (language == "English") {
      return true;
    } else {
      return false;
    }
  }

  static hideLoader() {
    if (isLoading) {
      isLoading = false;
      Navigator.pop(
          NavigationService.instance.navigatorKey.currentState!.context);
    }
  }

  // Widget showLoader() {
  //   return Container(
  //     child: new Padding(padding: const EdgeInsets.all(5.0),child: new Center(child: new CircularProgressIndicator(
  //       valueColor:AlwaysStoppedAnimation<Color>(ColorConstant.APP_MAIN_COLOR) ,
  //     ))),
  //   );
  // }

  static loader(Color color, [String? title]) {
    Future.delayed(const Duration(milliseconds: 1), () {
      if (!isLoading) {
        isLoading = true;
        showDialog(
            barrierDismissible: false,
            context:
                NavigationService.instance.navigatorKey.currentState!.context,
            builder: (_) {
              return WillPopScope(
                  child: Container(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                            minWidth: 100, maxWidth: 300, maxHeight: 100),
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: new Center(
                                      child: new CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                  ))),
                              title != null
                                  ? SizedBox(
                                      width: 10,
                                    )
                                  : Container(),
                              title != null
                                  ? Flexible(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                            fontFamily: 'Eina04',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: Colors.black,
                                            decoration: TextDecoration.none),
                                        maxLines: 5,
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  onWillPop: () async => false);
            });
      }
    });
  }
}
