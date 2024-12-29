import 'package:flutter/material.dart';
import 'package:shyam_tiles/model/user.dart';

import 'common/app_constant.dart';
import 'common/reponse.dart';
import 'homepage.dart';

TextEditingController txtMobileNumber = TextEditingController(text: "");
TextEditingController txtPassword = TextEditingController(text: "");

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool buttonEnable = false;
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xffb4b4b4), Color(0xffA5A5A5)]),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 190.0),
                child: Image.asset(
                  'images/shyamtiles.png',
                  height: 160,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Roboto-Thin',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 15, bottom: 0),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: txtMobileNumber,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (txtPassword.text.isNotEmpty) {
                          setState(() {
                            buttonEnable = true;
                          });
                        } else {
                          setState(() {
                            buttonEnable = false;
                          });
                        }
                      } else {
                        setState(() {
                          buttonEnable = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        // labelText: 'Email Id',
                        // labelStyle: TextStyle(
                        //     fontSize: 16,
                        //     color: const Color(0xFFACACAC).withOpacity(1)),
                        hintText: 'User Id',
                        hintStyle: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFFACACAC).withOpacity(1)),
                        fillColor: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 22, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),

                child: SizedBox(
                  height: 50,
                  child: TextField(
                    //controller: passwordController,
                    controller: txtPassword,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (txtMobileNumber.text.isNotEmpty) {
                          setState(() {
                            buttonEnable = true;
                          });
                        } else {
                          setState(() {
                            buttonEnable = false;
                          });
                        }
                      } else {
                        setState(() {
                          buttonEnable = false;
                        });
                      }
                    },
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      // labelText: 'Password',
                      // labelStyle: TextStyle(
                      //     fontSize: 16,
                      //     color: const Color(0xFFACACAC).withOpacity(1)),
                      hintText: 'Password',
                      hintStyle: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFACACAC).withOpacity(1)),
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(
                          _obscureText
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () {
              //     //TODO FORGOT PASSWORD SCREEN GOES HERE
              //   },
              //   child: Padding(
              //     padding:
              //         const EdgeInsets.only(left: 160, top: 13, right: 0),
              //     child: Text(
              //       'Forgot Password?',
              //       style: TextStyle(
              //         fontSize: 18,
              //         fontFamily: 'Roboto-Thin',
              //         fontWeight: FontWeight.w500,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
              GestureDetector(
                onTap: (buttonEnable)
                    ? () async {
                        if (txtMobileNumber.text != "") {
                          if (txtPassword.text != "") {
                            UtilFunctions.loader(ColorConstant.APP_MAIN_COLOR);
                            AppUser appUser = AppUser();
                            appUser.contact = txtMobileNumber.text;
                            appUser.password = txtPassword.text;

                            ResponseSmartAuditor responseSmartAuditor =
                                await appUser.userLogin();

                            UtilFunctions.hideLoader();
                            if (responseSmartAuditor.status &&
                                responseSmartAuditor.body != null) {
                              var data = responseSmartAuditor.body;
                              appUser.dictToObject(data);
                              appUser.setUserDetailInSharedInstance();

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeScreen()));
                            } else {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  backgroundColor: const Color(0xff333333),
                                  title: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 0),
                                        child: const Center(
                                          child: Text(
                                            'Login failed!! Invalid credentials',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Roboto-Thin',
                                              color: Colors.white,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    GestureDetector(
                                      onTap: () async {
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 60.0, right: 60.0, top: 1),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 20),
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: const Color(0xff000000),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: const Center(
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontFamily: 'Roboto-Thin',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        }
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 30.0, right: 30.0, top: 22, bottom: 0),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: (buttonEnable)
                            ? const Color(0xffF3C507)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(10)),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto-Thin',
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
