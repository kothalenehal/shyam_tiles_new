import 'dart:convert';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shyam_tiles/model/appProducts.dart';
import 'package:shyam_tiles/model/banner_model.dart';
import 'package:shyam_tiles/model/user.dart';

class ProductDetails extends StatefulWidget {
  AppProducts appProducts;
  ProductDetails(this.appProducts, {super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String activeTile = "";
  bool checkAllLocations = false;
  TextEditingController txtQuantity = TextEditingController(text: '');

  void setActiveTile(int index) {
    setState(() {
      activeTile = widget.appProducts.image[index];
    });
  }

  Future<Map<String, dynamic>> checkQuantityAvailability(
      String name, bool checkAllLocations, int requestedQuantity) async {
    var headers = {'Cookie': 'ci_session=3b420cal6pr1eg2t3n61qusjmgqk0m7s'};
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://16.171.177.96/index.php/api/check-quantity-availability'));
    request.fields.addAll({
      'name': name,
      'check_all_locations': checkAllLocations.toString(),
      'requested_quantity': requestedQuantity.toString(),
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      return data;
    } else {
      throw Exception('Failed to check quantity availability');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activeTile == "") {
      if (widget.appProducts.image.isNotEmpty) {
        activeTile = widget.appProducts.image[0];
      } else {
        activeTile = "aaa";
      }
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: const Color(0xff333333),
        surfaceTintColor: const Color(0xff333333),
        backgroundColor: const Color(0xff333333),
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white54),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.appProducts.name,
          style: GoogleFonts.notoSerif(
            fontSize: 18,
            color: Colors.white54,
            fontWeight: FontWeight.w600,
            letterSpacing: .1,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xff333333)
              // gradient: LinearGradient(
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomRight,
              //     colors: <Color>[Color(0xff7e7e7e), Color(0xff7e7e7e)]),
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(20),
                child: (activeTile != "aaa")
                    ? Image.network(
                        activeTile,
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width,
                      )
                    : Image.asset(
                        "images/shyamtiles.png",
                        fit: BoxFit.fitHeight,
                        filterQuality: FilterQuality.high,
                        width: MediaQuery.of(context).size.width,
                      )),
            CarouselSlider(
              items: [
                for (int i = 0; i < widget.appProducts.image.length; i++)
                  GestureDetector(
                    onTap: () {
                      setActiveTile(i);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.0),
                        image: DecorationImage(
                          image: NetworkImage(widget.appProducts.image[i]),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
              ],
              options: CarouselOptions(
                height: 80.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.3,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, top: 10),
              width: MediaQuery.of(context).size.width,
              child: Text(
                widget.appProducts.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, top: 5),
              width: MediaQuery.of(context).size.width,
              child: Text(
                widget.appProducts.size,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 15, top: 5),
              child: const Text(
                "Scratch Resistent",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 5, top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Availability: ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    (widget.appProducts.quantity > 0)
                        ? "In Stock"
                        : "Out of Stock",
                    style: TextStyle(
                      color: (widget.appProducts.quantity > 0)
                          ? Colors.green
                          : Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 80),
                  Container(
                    margin: const EdgeInsets.only(top: 13),
                    height: 30,
                    width: 130,
                    decoration: BoxDecoration(
                        color: const Color(0xff333333),
                        borderRadius: BorderRadius.circular(10)),
                    child: GestureDetector(
                      onTap: () async {
                        await WishList()
                            .addToWishList(widget.appProducts.id!)
                            .then((value) {
                          if (value.status) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              backgroundColor: Color(0xff333333),
                              content: Text("Added to wishlist"),
                            ));
                          }
                        });
                      },
                      child: Center(
                        child: Text(
                          "Add to wishlist",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                            letterSpacing: .1,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            GestureDetector(
              onTap: () async {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            backgroundColor: const Color(0xff333333),
                            title: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: const Center(
                                    child: Text(
                                      'Quantity:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Roboto-Thin',
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 230,
                                  height: 43,
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Center(
                                    child: TextField(
                                      controller: txtQuantity,
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        filled: true,
                                        hintStyle: const TextStyle(
                                            color: Color(0xffB4B4B4),
                                            fontSize: 14),
                                        hintText:
                                            "Please enter tiles quantity here..",
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                if (widget.appProducts.quantity < 20 &&
                                    widget.appProducts.quantity > 0)
                                  Container(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: const Center(
                                      child: Text(
                                        "Available, but low quantity!!!",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                CheckboxListTile(
                                  title: const Text("Check all locations",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white)),
                                  value: checkAllLocations,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkAllLocations = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              GestureDetector(
                                onTap: () async {
                                  if (txtQuantity.text.isNotEmpty) {
                                    try {
                                      int requestedQuantity =
                                          int.parse(txtQuantity.text);
                                      Map<String, dynamic> availabilityData =
                                          await checkQuantityAvailability(
                                              widget.appProducts.name,
                                              checkAllLocations,
                                              requestedQuantity);
                                      Navigator.of(context).pop();
                                      showAvailabilityResultDialog(
                                          context, availabilityData);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to check availability: $e')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Please enter a quantity')),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 55.0,
                                      right: 55.0,
                                      top: 5,
                                      bottom: 30),
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff000000),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Check',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontFamily: 'Roboto-Thin',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }));
              },
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                decoration: BoxDecoration(
                    color: const Color(0xff000000),
                    // gradient: const LinearGradient(
                    //     begin: Alignment.topLeft,
                    //     end: Alignment.bottomRight,
                    //     colors: <Color>[Color(0xff7e7e7e), Color(0xff7e7e7e)]),
                    borderRadius: BorderRadius.circular(15)),
                child: Center(
                  child: Text(
                    "Check Availability",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  void showAvailabilityResultDialog(
      BuildContext context, Map<String, dynamic> availabilityData) {
    List<Map<String, dynamic>> locations = [];
    if (availabilityData['data'] is List) {
      locations = List<Map<String, dynamic>>.from(availabilityData['data']);
    }

    print(
        "All locations from API: ${locations.map((l) => l['locations']).toList()}");
    print("Check all locations flag: $checkAllLocations");

    List<Map<String, dynamic>> displayLocations = checkAllLocations
        ? locations
        : locations
            .where((location) =>
                location['locations'].toString().toLowerCase().trim() ==
                AppUser.sharedInstance.location.toLowerCase().trim())
            .toList();

    print(
        "Filtered locations: ${displayLocations.map((l) => l['locations']).toList()}");

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        backgroundColor: const Color(0xff333333),
        title: const Text(
          'Availability Result',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: displayLocations.isEmpty
                ? [
                    Text(
                        "Not available for ${checkAllLocations ? 'any location' : AppUser.sharedInstance.location}",
                        style: TextStyle(color: Colors.white))
                  ]
                : displayLocations.map((location) {
                    int availableQuantity =
                        int.tryParse(location['quantity'].toString()) ?? 0;
                    int requestedQuantity = int.tryParse(txtQuantity.text) ?? 0;
                    bool isAvailable = availableQuantity >= requestedQuantity;
                    String availabilityText =
                        isAvailable ? 'Available' : 'Unavailable';
                    Color textColor = isAvailable ? Colors.green : Colors.red;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location['locations'] ?? 'Unknown',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Text(
                            availabilityText,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
