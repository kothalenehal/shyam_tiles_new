import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shyam_tiles/model/user.dart';

class Userdetails extends StatefulWidget {
  const Userdetails({Key? key}) : super(key: key);

  @override
  State<Userdetails> createState() => _UserdetailsState();
}

class _UserdetailsState extends State<Userdetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Color(0xff333333)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 190.0),
                child: Text(
                  "Vendor Details",
                  style: GoogleFonts.poppins(
                    fontSize: 29,
                    color: Colors.white54,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .1,
                  ),
                ),
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 45, bottom: 0),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        // labelText: 'Email Id',
                        // labelStyle: TextStyle(
                        //     fontSize: 16,
                        //     color: const Color(0xFFACACAC).withOpacity(1)),
                        hintText: AppUser.sharedInstance.name,
                        hintStyle:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        fillColor: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 22, bottom: 0),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: TextField(
                      readOnly: true,
                      obscureText: false,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          hintText: AppUser.sharedInstance.email,
                          hintStyle: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          fillColor: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 25, bottom: 0),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        // labelText: 'Email Id',
                        // labelStyle: TextStyle(
                        //     fontSize: 16,
                        //     color: const Color(0xFFACACAC).withOpacity(1)),
                        hintText: AppUser.sharedInstance.contact,
                        hintStyle:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        fillColor: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 22, bottom: 0),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: TextField(
                      readOnly: true,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          hintText: AppUser.sharedInstance.location,
                          hintStyle: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          fillColor: Colors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  //,
                  //  MaterialPageRoute(builder: (_) => profilescreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 45),
                  child: Container(
                    height: 50,
                    width: 160,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.6),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto-Thin',
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
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
