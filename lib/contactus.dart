import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/model/appContact.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);
  @override
  ContactScreenScreenState createState() => ContactScreenScreenState();
}

class ContactScreenScreenState extends State<ContactScreen> {
  AppContact appContact = AppContact();

  void fetchContactData() async {
    ResponseSmartAuditor responseSmartAuditor = await appContact.getContact();

    if (responseSmartAuditor.status) {
      var appCategoriesList = responseSmartAuditor.body;
      if (appCategoriesList != null) {
        setState(() {
          appContact.dictToObject(appCategoriesList['contact']);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchContactData();
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now().year;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double containerWidth = constraints.maxWidth;
          double paddingValue = constraints.maxWidth * 0.05;
          double fontSizeTitle = constraints.maxWidth * 0.07;
          double fontSizeContent = constraints.maxWidth * 0.04;
          double topPadding = constraints.maxHeight * 0.25;
          double contentFontSize = containerWidth * 0.038;

          return SingleChildScrollView(
            child: Container(
              height: constraints.maxHeight,
              padding: EdgeInsets.only(top: topPadding),
              decoration: const BoxDecoration(
                color: Color(0xff333333),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Store Address",
                      style: GoogleFonts.poppins(
                        fontSize: fontSizeTitle,
                        color: Colors.white54,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: paddingValue, top: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 10),
                            child: Text(
                              appContact.address,
                              maxLines: 3,
                              style: GoogleFonts.poppins(
                                fontSize: contentFontSize,
                                color: Colors.grey.shade300,
                                fontWeight: FontWeight.w500,
                                letterSpacing: .1,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: paddingValue, top: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email,
                          color: Colors.white,
                          size: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            appContact.email,
                            style: GoogleFonts.poppins(
                              fontSize: fontSizeContent,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: .1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: paddingValue, top: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse("tel://${appContact.contact}"));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              appContact.contact,
                              style: GoogleFonts.poppins(
                                fontSize: fontSizeContent,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: .1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: paddingValue, top: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.copyright,
                          color: Colors.white,
                          size: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Text(
                              '$now-${now + 1} Shyam Tiles All Rights Reserved.',
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.poppins(
                                fontSize: contentFontSize,
                                color: Colors.grey.shade300,
                                fontWeight: FontWeight.w500,
                                letterSpacing: .1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingValue,
                        vertical: 50,
                      ),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Back to Profile',
                            style: GoogleFonts.inter(
                              fontSize: fontSizeContent * 1.2,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: .1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
