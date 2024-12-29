import 'package:flutter/material.dart';

class Productlisting extends StatefulWidget {
  const Productlisting({Key? key}) : super(key: key);

  @override
  State<Productlisting> createState() => _ProductlistingState();
}

class _ProductlistingState extends State<Productlisting> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15),
          child: RichText(
              text: const TextSpan(
            children: [
              TextSpan(
                text: '300 X 300 mm Tiles - 233 Designs',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Roboto-Thin",
                  fontSize: 16,
                  // shadows: <Shadow>[
                  //   Shadow(
                  //     offset: Offset(
                  //       1,
                  //       1.0,
                  //     ),
                  //     blurRadius: 3.0,
                  //     color: Color.fromARGB(255, 0, 0, 0),
                  //   ),
                  // ],
                ),
              ),
            ],
          )),
        ),
        IntrinsicHeight(
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 225,
                width: MediaQuery.of(context).size.width / 2 - 7,
                child: Container(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 30, right: 15),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 119,
                        child: Image.asset(
                          'images/Image 22.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(top: 5),
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              WidgetSpan(
                                child: Center(
                                  child: Text(
                                    '10074 HL1',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Roboto-Thin",
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              WidgetSpan(
                                child: Center(
                                  child: Text(
                                    '300 x 300mm',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Roboto-Thin",
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              WidgetSpan(
                                child: Center(
                                  child: Text(
                                    'Scratch Resistent',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Roboto-Thin",
                                      fontSize: 14,
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
              ),
              const VerticalDivider(
                thickness: 2,
                width: 5,
              ),
              SizedBox(
                height: 225,
                width: MediaQuery.of(context).size.width / 2,
                child: Container(
                  padding:
                      const EdgeInsets.only(top: 15.0, right: 30, left: 15),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 119,
                        child: Image.asset(
                          'images/Image 22.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(top: 5),
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              WidgetSpan(
                                child: Center(
                                  child: Text(
                                    '10074 HL1',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Roboto-Thin",
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              WidgetSpan(
                                child: Center(
                                  child: Text(
                                    '300 x 300mm',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Roboto-Thin",
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              WidgetSpan(
                                child: Center(
                                  child: Text(
                                    'Scratch Resistent',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Roboto-Thin",
                                      fontSize: 14,
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
              ),
            ],
          ),
        ),
        const Divider(
          thickness: 2,
          indent: 30,
          endIndent: 30,
        ),
      ],
    );
  }
}
