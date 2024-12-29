import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shyam_tiles/common/app_constant.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/model/user.dart';
import 'homepage.dart';
import 'package:google_fonts/google_fonts.dart';

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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    print(height * .47);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/bgn.webp'),
                opacity: 1,
                filterQuality: FilterQuality.high,
                fit: BoxFit.fill)),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(top: height * 0.14, bottom: height * 0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'images/bg.webp',
                        height: 45,
                      ),
                    ),
                    SizedBox(width: 20),
                    Hero(
                      tag: 'logo1',
                      child: Text(
                        'SHYAM TILES',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 27,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black54,
                        blurRadius: 15.0,
                        offset: Offset(0.0, 0.75)),
                  ],
                ),
                height: height * .47,
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    SizedBox(height: height * .05),
                    Text(
                      'Login',
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 22),
                    ),
                    SizedBox(height: height * .01),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 15, bottom: 0),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: txtMobileNumber,
                          onChanged: (value) {
                            setState(() {
                              buttonEnable = value.isNotEmpty &&
                                  txtPassword.text.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.grey)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            hintText: 'User Id',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFFACACAC).withOpacity(1)),
                            fillColor: Color(0xff8D99AE).withOpacity(.2),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 25, bottom: 0),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          obscuringCharacter: '*',
                          controller: txtPassword,
                          onChanged: (value) {
                            setState(() {
                              buttonEnable = value.isNotEmpty &&
                                  txtMobileNumber.text.isNotEmpty;
                            });
                          },
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.grey)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            hintText: 'Password',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFFACACAC).withOpacity(1)),
                            fillColor: Color(0xff8D99AE).withOpacity(.2),
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
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (buttonEnable)
                          ? () async {
                              if (txtMobileNumber.text != "") {
                                if (txtPassword.text != "") {
                                  UtilFunctions.loader(
                                      ColorConstant.APP_MAIN_COLOR);
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
                                            builder: (_) =>
                                                const HomeScreen()));
                                  } else {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        backgroundColor:
                                            const Color(0xff333333),
                                        title: Column(
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 0),
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
                                                  left: 60.0,
                                                  right: 60.0,
                                                  top: 1),
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 20),
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff000000),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: const Center(
                                                  child: Text(
                                                    'OK',
                                                    style: TextStyle(
                                                      color: Colors.white54,
                                                      fontFamily: 'Roboto-Thin',
                                                      fontWeight:
                                                          FontWeight.w600,
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
                            left: 20.0, right: 20.0, top: 32, bottom: 0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: (buttonEnable)
                                  ? const Color(0xff000000)
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10)),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: const Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto-Thin',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
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
            ],
          ),
        ),
      ),
    );
  }
}
