import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shyam_tiles/contactus.dart';
import 'package:shyam_tiles/login.dart';
import 'package:shyam_tiles/model/user.dart';
import 'package:shyam_tiles/userdetails.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({Key? key}) : super(key: key);
  @override
  State<Profilescreen> createState() => ProfilescreenState();
}

class ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    ///print(MediaQuery.of(context).size.height);
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/probg.webp'), fit: BoxFit.fill),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              'Profile',
              style: GoogleFonts.poppins(
                fontSize: 29,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: .1,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage('images/bg.webp'),
              //foregroundImage: AssetImage('images/bg.webp'),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              AppUser.sharedInstance.name.toUpperCase().trim(),
              style: GoogleFonts.poppins(
                fontSize: 26,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                letterSpacing: .1,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 4.0),
            //   child: Text(
            //     AppUser.sharedInstance.email,
            //     style: GoogleFonts.notoSerif(
            //       fontSize: 18,
            //       color: Colors.black,
            //       fontWeight: FontWeight.w700,
            //       letterSpacing: .1,
            //     ),
            //   ),
            // ),

            const SizedBox(
              height: 0,
            ),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xff8D99AE).withOpacity(.3)),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              height: 130,
              margin: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Userdetails()));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, top: 0),
                          child: Icon(
                            Icons.contact_mail,
                            color: Color(0xff000000),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, top: 0),
                          child: Text(
                            'Personal Info',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              letterSpacing: .1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(top: 0, right: 15),
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xff000000),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 50,
                      right: 20,
                    ),
                    height: 1,
                    color: Color(0xff8D99AE).withOpacity(.4),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ContactScreen()));
                    },
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, top: 0),
                          child: Icon(
                            Icons.wifi_calling,
                            color: Color(0xff000000),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, top: 0),
                          child: Text(
                            'Contact Us',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              letterSpacing: .1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(top: 0, right: 15),
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xff000000),
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

            SizedBox(
              height: 20,
            ),

            GestureDetector(
              onTap: () {
                AppUser().setUserDetailInSharedInstance();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff8D99AE).withOpacity(.3)),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                height: 60,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 0),
                      child: Icon(
                        Icons.logout,
                        color: Color(0xff000000),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 0),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          letterSpacing: .1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 0, right: 15),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
