import 'dart:convert';
import 'dart:math';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shyam_tiles/model/appProducts.dart';
import 'package:shyam_tiles/model/banner_model.dart';
import 'package:shyam_tiles/model/user.dart';
import 'package:shyam_tiles/common/animated_success_popup.dart';


class AnimatedCheckButton extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const AnimatedCheckButton({
    Key? key,
    required this.isEnabled,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<AnimatedCheckButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation controller for pop-in/pop-out effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Bounce animation controller for additional bounce effect
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Pulse animation controller for subtle pulsing when enabled
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Scale animation: starts at 1.0, scales down to 0.95, then back to 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Bounce animation: adds a subtle bounce effect
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 0.98),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.0),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    // Pulse animation: subtle pulsing when button is enabled
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.02),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start pulsing if button is initially enabled
    if (widget.isEnabled) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() async {
    if (!widget.isEnabled) return;
    
    // Trigger scale animation
    await _scaleController.forward();
    _scaleController.reverse();
    
    // Trigger bounce animation
    _bounceController.forward();
    
    // Call the actual onTap function
    widget.onTap();
  }
  
  @override
  void didUpdateWidget(AnimatedCheckButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && !oldWidget.isEnabled) {
      // Start pulsing when button becomes enabled
      _pulseController.repeat();
    } else if (!widget.isEnabled && oldWidget.isEnabled) {
      // Stop pulsing when button becomes disabled
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _bounceAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _bounceAnimation.value * (widget.isEnabled ? _pulseAnimation.value : 1.0),
          child: GestureDetector(
            onTap: _onTap,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 55.0,
                  right: 55.0,
                  top: 5,
                  bottom: 30),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: widget.isEnabled
                      ? const Color(0xff333333)  // Dark gray when active
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                  border: widget.isEnabled ? Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ) : null,
                  boxShadow: widget.isEnabled ? [
                    BoxShadow(
                      color: const Color(0xff333333).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ] : null,
                  gradient: widget.isEnabled ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff333333),
                      Color(0xff555555),
                    ],
                  ) : null,
                ),
                child: Center(
                  child: Text(
                    'Check',
                    style: TextStyle(
                      color: widget.isEnabled
                          ? Colors.white
                          : Colors.white24,
                      fontFamily: 'Roboto-Thin',
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PrettyWaveButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;

  const PrettyWaveButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.backgroundColor = const Color(0xff333333),
    this.textColor = Colors.white54,
    this.width = 130,
    this.height = 30,
  }) : super(key: key);

  @override
  State<PrettyWaveButton> createState() => _PrettyWaveButtonState();
}

class _PrettyWaveButtonState extends State<PrettyWaveButton>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Wave animation controller
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Wave animation
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    
    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _waveController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Wave effect
                Positioned.fill(
                  child: CustomPaint(
                    painter: WavePainter(
                      animation: _waveAnimation.value,
                      color: widget.textColor.withOpacity(0.2),
                    ),
                  ),
                ),
                // Button content
                GestureDetector(
                  onTap: widget.onTap,
                  child: Center(
                    child: Text(
                      widget.text,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: widget.textColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: .1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color color;

  WavePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create wave effect
    final waveHeight = size.height * 0.3;
    final waveWidth = size.width;
    final waveOffset = animation * waveWidth * 2;
    
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    
    // Draw wave
    for (double x = 0; x <= waveWidth; x += 5) {
      final y = size.height * 0.5 + 
                waveHeight * 
                sin(animation * 2 * pi) * 
                sin((x + waveOffset) / waveWidth * 2 * pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(waveWidth, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.color != color;
  }
}

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
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://galactics.co.in/shyamtiles_updated/api/check-quantity-availability'));
    
    // If checkAllLocations is true, don't send specific location to get all locations
    String requestBody;
    if (checkAllLocations) {
      requestBody = 'name=${Uri.encodeComponent(name)}';
      print('Requesting availability for ALL locations');
    } else {
      requestBody = 'name=${Uri.encodeComponent(name)}&locations=${Uri.encodeComponent(AppUser.sharedInstance.location)}';
      print('Requesting availability for user location: ${AppUser.sharedInstance.location}');
    }
    
    request.body = requestBody;
    request.headers.addAll(headers);
    
    print('API Request URL: ${request.url}');
    print('API Request Body: ${request.body}');
    print('API Request Headers: ${request.headers}');
    
    http.StreamedResponse response = await request.send();
    print('API Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      print('API Response Body: $responseBody');
      Map<String, dynamic> data = json.decode(responseBody);
      return data;
    } else {
      String errorBody = await response.stream.bytesToString();
      print('API Error Response: $errorBody');
      throw Exception('Failed to check quantity availability: ${response.statusCode}');
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
                    child: PrettyWaveButton(
                      text: "Add to wishlist",
                      onTap: () async {
                        await WishList()
                            .addToWishList(widget.appProducts.id!)
                            .then((value) {
                          if (value.status) {
                            showAnimatedSuccessPopup(
                              context,
                              "Product added to wishlist successfully!",
                            );
                          }
                        });
                      },
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
                                      keyboardType: TextInputType.number,
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          // This will trigger rebuild and enable/disable button
                                        });
                                      },
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
                                            "Please enter tiles quantity (minimum 1)..",
                                        fillColor: Colors.white,
                                      ),
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
                              AnimatedCheckButton(
                                isEnabled: txtQuantity.text.isNotEmpty && (int.tryParse(txtQuantity.text) ?? 0) > 0,
                                onTap: () async {
                                  if (txtQuantity.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          "Please enter a quantity",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  int requestedQuantity = int.tryParse(txtQuantity.text) ?? 0;
                                  
                                  if (requestedQuantity <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          "Please enter a valid quantity (greater than 0)",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  try {
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
                                },
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
    print('Availability Data: $availabilityData');
    print('User Location: ${AppUser.sharedInstance.location}');
    
    List<Map<String, dynamic>> locations = [];
    if (availabilityData['data'] is List) {
      locations = List<Map<String, dynamic>>.from(availabilityData['data']);
    }

    print("All locations from API: ${locations.map((l) => l['locations']).toList()}");
    
    // Filter locations based on checkbox selection
    List<Map<String, dynamic>> displayLocationData;
    
    if (checkAllLocations) {
      // Show all locations when checkbox is marked
      displayLocationData = locations;
      print("Showing all locations: ${displayLocationData.map((l) => l['locations']).toList()}");
    } else {
      // Show only user's location when checkbox is not marked
      displayLocationData = locations.where((location) {
        String apiLocation = location['locations']?.toString().toLowerCase().trim() ?? '';
        String userLocation = AppUser.sharedInstance.location.toLowerCase().trim();
        print('Comparing: API Location="$apiLocation" vs User Location="$userLocation"');
        return apiLocation == userLocation;
      }).toList();
      print("Filtered for user location: ${displayLocationData.map((l) => l['locations']).toList()}");
    }

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
            children: displayLocationData.isEmpty
                ? [
                    Text(
                        checkAllLocations 
                            ? "No data available for any location"
                            : "Not available for ${AppUser.sharedInstance.location}",
                        style: TextStyle(color: Colors.white))
                  ]
                : displayLocationData.map((location) {
                    int availableQuantity =
                        int.tryParse(location['quantity'].toString()) ?? 0;
                    int requestedQuantity = int.tryParse(txtQuantity.text) ?? 0;
                    bool isAvailable = availableQuantity >= requestedQuantity;
                    
                    print('Available: $availableQuantity, Requested: $requestedQuantity, IsAvailable: $isAvailable');
                    
                    // Determine stock status based on user's requested quantity
                    String availabilityText;
                    Color textColor;
                    
                    if (isAvailable) {
                      // If requested quantity is available, show Available
                      availabilityText = 'Available';
                      textColor = Colors.green;
                    } else {
                      // If requested quantity is not available, show Unavailable
                      availabilityText = 'Unavailable';
                      textColor = Colors.red;
                    }

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
