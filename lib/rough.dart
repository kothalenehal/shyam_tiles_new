// import 'dart:io';
//
// import 'package:fed/models/user_model.dart';
// import 'package:fed/screens/home_screen/homescreen.dart';
// import 'package:fed/screens/reset_psw/reset_password1.dart';
// import 'package:fed/screens/signup/signup_main.dart';
// import 'package:fed/screens/signup/signup_social.dart';
// import 'package:fed/ui_components/ui_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:vibration/vibration.dart';
//
// class LoginScreen extends StatefulWidget {
//   final String? emailID;
//   const LoginScreen(this.emailID, {Key? key}) : super(key: key);
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   bool _obscureText = true;
//
//   bool isValidEmail(String value) {
//     return RegExp(r'^[a-zA-Z\d._%+-]+@[a-zA-Z\d.-]+\.[a-zA-Z]{2,}$')
//         .hasMatch(value);
//   }
//
//   bool _showError = false;
//   var _message = '';
//   bool hideBackScreen = false;
//   var emailimputController = TextEditingController();
//   var passwordController = TextEditingController();
//
//   void _toggleError() {
//     setState(() {
//       _showError = !_showError;
//     });
//   }
//
//   Future<bool> _onWillPop() async {
//     return (await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Are you sure?'),
//         content: const Text('Do you want to exit the app?'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => exit(0),
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     )) ??
//         false;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.emailID != '') {
//       emailimputController.text = widget.emailID!;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = CustomStyles.getDeviceDimension(context).width;
//     final double screenHeight = CustomStyles.getDeviceDimension(context).height;
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         body: (hideBackScreen)
//             ? Container(
//           color: Colors.black,
//         )
//             : LayoutBuilder(
//           builder: (context, cont) {
//             return SingleChildScrollView(
//               physics: const NeverScrollableScrollPhysics(),
//               child: Container(
//                 height: screenHeight,
//                 width: screenWidth,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                       image: AssetImage("assets/images/bgsignup.png"),
//                       fit: BoxFit.cover,
//                       filterQuality: FilterQuality.high),
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       alignment: Alignment.centerLeft,
//                       padding: const EdgeInsets.only(
//                         top: 70,
//                         left: 30,
//                         right: 30,
//                       ),
//                       child: Text('Log in',
//                           textAlign: TextAlign.left,
//                           style: CustomStyles.splashTextStyle()),
//                     ),
//                     _showError
//                         ? const Expanded(child: SizedBox())
//                         : const Expanded(child: SizedBox()),
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       curve: Curves.easeInOut,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                           color: const Color(0xFFFF484E).withOpacity(.2),
//                           borderRadius:
//                           const BorderRadius.all(Radius.circular(4))),
//                       width: screenWidth,
//                       height: _showError ? 48 : 0,
//                       margin: const EdgeInsets.only(
//                           top: 0, left: 30, right: 30),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const Expanded(
//                             child: SizedBox(),
//                           ),
//                           Text(_message,
//                               style: CustomStyles.errorTextStyle()),
//                           const Expanded(
//                             child: SizedBox(),
//                           ),
//                           Opacity(
//                             opacity: _showError ? 1 : 0,
//                             child: GestureDetector(
//                               onTap: _toggleError,
//                               child: const Icon(
//                                 Icons.close,
//                                 color: CustomStyles.errorTextColor,
//                               ),
//                             ),
//                           ),
//                           const Expanded(
//                             child: SizedBox(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       width:
//                       CustomStyles.getDeviceDimension(context).width,
//                       alignment: Alignment.center,
//                       height: 48,
//                       margin: const EdgeInsets.only(
//                           top: 16, left: 30, right: 30),
//                       child: TextFormField(
//                         textAlign: TextAlign.left,
//                         controller: emailimputController,
//                         textAlignVertical: TextAlignVertical.center,
//                         cursorColor: Colors.white.withOpacity(.6),
//                         decoration: const InputDecoration(
//                           hintText: 'Enter your email..',
//                           hintStyle: TextStyle(
//                               color: Colors.grey,
//                               fontSize: CustomStyles.smallFontSize,
//                               letterSpacing: .5,
//                               fontWeight:
//                               CustomStyles.verysmallFontWeight,
//                               height: 1.5),
//                           focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   color: CustomStyles.secondaryColor)),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: BorderSide(
//                                 color:
//                                 CustomStyles.primaryBackgroundColor),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 10),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         autocorrect: false,
//                         style: const TextStyle(
//                           color: CustomStyles.secondaryTextColor,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       width:
//                       CustomStyles.getDeviceDimension(context).width,
//                       alignment: Alignment.center,
//                       height: 48,
//                       margin: const EdgeInsets.only(
//                           left: 30, right: 30, bottom: 8, top: 16),
//                       child: TextFormField(
//                         controller: passwordController,
//                         textAlign: TextAlign.left,
//                         textAlignVertical: TextAlignVertical.center,
//                         cursorColor: Colors.white.withOpacity(.6),
//                         decoration: InputDecoration(
//                           hintText: 'Enter your Password...',
//                           hintStyle: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: CustomStyles.smallFontSize,
//                               letterSpacing: .5,
//                               fontWeight:
//                               CustomStyles.verysmallFontWeight,
//                               height: 1.5),
//                           focusedBorder: const OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   color: CustomStyles.secondaryColor)),
//                           enabledBorder: const OutlineInputBorder(
//                             borderSide: BorderSide(
//                                 color:
//                                 CustomStyles.primaryBackgroundColor),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 10),
//                           suffixIcon: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _obscureText = !_obscureText;
//                               });
//                             },
//                             child: Icon(
//                               _obscureText
//                                   ? Icons.visibility_outlined
//                                   : Icons.visibility_off_outlined,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         keyboardType: TextInputType.text,
//                         style: const TextStyle(
//                           color: CustomStyles.secondaryTextColor,
//                         ),
//                         obscureText: _obscureText,
//                       ),
//                     ),
//                     Container(
//                       alignment: Alignment.centerLeft,
//                       padding:
//                       const EdgeInsets.only(bottom: 32, left: 30),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             PageTransition(
//                               type:
//                               PageTransitionType.rightToLeftWithFade,
//                               child: const ResetPassword1(),
//                               duration: const Duration(milliseconds: 200),
//                             ),
//                           );
//                         },
//                         child: Text(
//                           'Forgot your password?',
//                           style: GoogleFonts.inter(
//                             fontSize: CustomStyles.verysmallFontSize,
//                             color: CustomStyles.secondaryColor,
//                             fontWeight: CustomStyles.verysmallFontWeight,
//                             letterSpacing: .1,
//                           ),
//                         ),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         if (emailimputController.text.trim().isNotEmpty &&
//                             isValidEmail(emailimputController.text) &&
//                             passwordController.text.trim().isNotEmpty) {
//                           UserModel userModel = UserModel();
//                           userModel.email = emailimputController.text;
//                           userModel.password = passwordController.text;
//
//                           userModel.loginUser().then((value) {
//                             if (value.status) {
//                               userModel.dictToObject(value.body);
//
//                               if (userModel.detail.message == "") {
//                                 userModel.getUserProfile().then((value) {
//                                   setState(() {
//                                     hideBackScreen = true;
//                                   });
//                                   UserModel.sharedInstance.accessToken =
//                                       userModel.accessToken;
//                                   UserModel.sharedInstance
//                                       .dictToObject(value.body);
//                                   UserModel.sharedInstance
//                                       .saveUserInfoInSharedPref();
//
//                                   Navigator.pushReplacement(
//                                     context,
//                                     PageRouteBuilder(
//                                       pageBuilder: (context, animation,
//                                           secondaryAnimation) =>
//                                           HomeScreen(imageUrls: []),
//                                       transitionsBuilder: (context,
//                                           animation,
//                                           secondaryAnimation,
//                                           child) {
//                                         var tween =
//                                         Tween(begin: 0.0, end: 1.0);
//                                         var rotationAnimation =
//                                         tween.animate(
//                                           CurvedAnimation(
//                                             parent: animation,
//                                             curve: Curves.easeInOut,
//                                           ),
//                                         );
//
//                                         return Transform(
//                                           alignment: Alignment.center,
//                                           transform: Matrix4.identity()
//                                             ..setEntry(3, 2, 0.001)
//                                             ..rotateY(
//                                                 rotationAnimation.value *
//                                                     3.141592),
//                                           child: Transform(
//                                             alignment: Alignment.center,
//                                             transform: Matrix4.identity()
//                                               ..rotateY(rotationAnimation
//                                                   .value *
//                                                   -3.141592),
//                                             child: child,
//                                           ),
//                                         );
//                                       },
//                                       transitionDuration:
//                                       Duration(milliseconds: 700),
//                                     ),
//                                   );
//                                 });
//
//                                 // Navigator.pushReplacement(
//                                 //   context,
//                                 //   PageTransition(
//                                 //     type: PageTransitionType.scale,
//                                 //     alignment: Alignment.centerRight,
//                                 //     child: HomeScreen(),
//                                 //     duration: const Duration(milliseconds: 1800),
//                                 //   ),
//                                 // );
//                               } else {
//                                 setState(() {
//                                   _showError = true;
//                                   _message =
//                                   "Incorrect user name or password";
//                                 });
//                               }
//                             }
//                           });
//                         } else {
//                           setState(() {
//                             _showError = true;
//                             Vibration.vibrate(
//                                 duration: 100, amplitude: 255);
//                             if (emailimputController.text
//                                 .trim()
//                                 .isEmpty ||
//                                 !isValidEmail(
//                                     emailimputController.text)) {
//                               _message = "Please Enter Correct user name";
//                             } else if (passwordController.text
//                                 .trim()
//                                 .isEmpty) {
//                               _message = "Please Enter Password";
//                             }
//                           });
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         fixedSize: Size(
//                             MediaQuery.of(context).size.width - 60, 48),
//                         elevation: 5,
//                         backgroundColor: const Color(0xff000000),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Text('Login',
//                           style: CustomStyles.elebtnTextStyle()),
//                     ),
//                     const SizedBox(height: 32),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         const SizedBox(
//                           width: 32,
//                         ),
//                         Container(
//                           margin:
//                           const EdgeInsets.only(left: 0, right: 10),
//                           height: 1,
//                           width: CustomStyles.getDeviceDimension(context)
//                               .width /
//                               4 -
//                               5,
//                           color: Colors.white,
//                         ),
//                         Text('Or continue with',
//                             textAlign: TextAlign.center,
//                             style: CustomStyles.elebtnTextStyle()),
//                         Container(
//                           margin:
//                           const EdgeInsets.only(right: 0, left: 10),
//                           height: 1,
//                           width: CustomStyles.getDeviceDimension(context)
//                               .width /
//                               4 -
//                               5,
//                           color: Colors.white,
//                         ),
//                         const SizedBox(
//                           width: 32,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 32),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (BuildContext context) =>
//                                 const SignUpSocialScreen(),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             height: 57,
//                             width: 57,
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(.4),
//                               borderRadius: const BorderRadius.all(
//                                   Radius.circular(8)),
//                             ),
//                             child: Center(
//                               child: SizedBox(
//                                 height: 25,
//                                 width: 25,
//                                 child: SvgPicture.asset(
//                                   'assets/svg/apple.svg',
//                                   alignment: Alignment.center,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 16,
//                         ),
//                         Container(
//                           height: 57,
//                           width: 57,
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(.4),
//                             borderRadius: const BorderRadius.all(
//                                 Radius.circular(8)),
//                           ),
//                           child: Center(
//                             child: SizedBox(
//                               height: 25,
//                               width: 25,
//                               child: SvgPicture.asset(
//                                 'assets/svg/fb.svg',
//                                 alignment: Alignment.center,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 16,
//                         ),
//                         Container(
//                           height: 57,
//                           width: 57,
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(.4),
//                             borderRadius: const BorderRadius.all(
//                                 Radius.circular(8)),
//                           ),
//                           child: Center(
//                             child: SizedBox(
//                               height: 25,
//                               width: 25,
//                               child: SvgPicture.asset(
//                                 'assets/svg/google.svg',
//                                 alignment: Alignment.center,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Expanded(
//                       child: SizedBox(),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.only(
//                         bottom: 20,
//                       ),
//                       child: Text('Don’t have an account yet?',
//                           style: CustomStyles.elebtnTextStyle()),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(
//                           bottom:
//                           MediaQuery.of(context).size.height * .078),
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             PageTransition(
//                               type: PageTransitionType.fade,
//                               child: const SignUpMainScreen(),
//                               duration: const Duration(milliseconds: 20),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           fixedSize: Size(
//                               MediaQuery.of(context).size.width - 60, 48),
//                           elevation: 0,
//                           backgroundColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(
//                             side: const BorderSide(
//                                 color:
//                                 CustomStyles.primaryBackgroundColor,
//                                 width: 2),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text('Sign up',
//                             style: CustomStyles.elebtnTextStyle()),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
