import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shyam_tiles/category.dart';
import 'package:shyam_tiles/hometabcontent.dart';
import 'package:shyam_tiles/model/appProducts.dart';
import 'package:shyam_tiles/qrcode.dart';
import 'package:shyam_tiles/tokens.dart';
import 'package:shyam_tiles/wishlist.dart';

import 'productlist.dart';
import 'profile.dart';
import 'search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final controller = ScrollController();

  final numbers = List.generate(100, (index) => '$index');
  final images = [
    Image.asset(
      'images/Image 22.png',
      fit: BoxFit.cover,
    ),
    Image.asset('images/Image 25.png'),
    Image.asset('images/Image 24.png'),
    Image.asset('images/Image 23.png'),
    Image.asset('images/Image 25.png'),
    Image.asset('images/Image 22.png'),
  ];

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    HomeContent(() {}, () {}),
    CategoryScreen(() {}),
    const WishlistItem(),
    TokenScreen(),
    const Profilescreen(),
  ];
  void fetchFilters() {}
  @override
  void initState() {
    super.initState();

    _widgetOptions[0] = HomeContent((int index) {
      setState(() {
        istileclicked = true;
        _selectedIndex = 0;
      });
    }, refreshDrawer);
  }

  bool istileclicked = false;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      istileclicked = false;
    });
  }

  void refreshDrawer() {
    setState(() {
      istileclicked = istileclicked;
    });
  }

  TextEditingController txtSearch = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: true,
      key: _scaffoldKey,
      // backgroundColor: Colors.white,
      backgroundColor: const Color(0xff333333),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            if (_selectedIndex != 3 && _selectedIndex != 4)
              Container(
                  height: 50,
                  margin: const EdgeInsets.all(10),
                  child: TextField(
                    controller: txtSearch,
                    onSubmitted: (val) {
                      if (txtSearch.text.isNotEmpty) {
                        var search = txtSearch.text;
                        txtSearch.text = "";
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SearchScreen(search)),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(top: 5, bottom: 5, left: 15),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: .1,
                            color: Colors.white
                                .withOpacity(.6)), // Border color set to white
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: .3,
                            color: Colors.white.withOpacity(
                                .5)), // Border color set to white for enabled state
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors
                                .white), // Border color set to white for focused state
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      filled: true,
                      fillColor: const Color(0xff474747),
                      hintText: "Search for product..",
                      hintStyle: const TextStyle(color: Color(0xffB4B4B4)),
                      prefixIcon: GestureDetector(
                        onTap: () {
                          if (txtSearch.text.isNotEmpty) {
                            var search = txtSearch.text;
                            txtSearch.text = "";
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SearchScreen(search)),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.search,
                          color: Color(0xffB4B4B4),
                        ),
                      ),
                    ),
                  )),
            _widgetOptions[(!istileclicked) ? _selectedIndex : 4],
          ],
        ),
      ),
      floatingActionButton: (istileclicked)
          ? Center(
              child: Container(
                padding: const EdgeInsets.only(top: 220, right: 200),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    // Add your onPressed code here!
                  },
                  label: const Text(''),
                  icon: const ImageIcon(
                    AssetImage('images/tune_black_24dp.png'),
                  ),
                  backgroundColor: const Color(0xffF3C507),
                ),
              ),
            )
          : null,
      appBar: (_selectedIndex != 3 && _selectedIndex != 4)
          ? AppBar(
              titleSpacing: 6,
              actions: const [SizedBox(width: 18)],
              title: Column(
                children: [
                  Container(
                    color: const Color(0xff333333),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Hero(
                          tag: 'logo',
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIndex = 0;
                                istileclicked = false;
                              });
                            },
                            child: Image.asset(
                              'images/bg.webp',
                              height: 45,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Hero(
                          tag: 'logo1',
                          child: Text(
                            'SHYAM TILES',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 27,
                                height: 30,
                                color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QRViewExample()),
                            );
                            // Handle the scanned result if needed
                            print('Scanned QR code data: $result');
                          },
                          child: Image.asset(
                            'images/qr-code.png',
                            height: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  color: Color(0xff333333),
                  // gradient: LinearGradient(
                  //     begin: Alignment.topLeft,
                  //     end: Alignment.bottomRight,
                  //     colors: <Color>[Color(0xff7e7e7e), Color(0xff7e7e7e)]),
                ),
              ),
            )
          : null,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xffffffff).withOpacity(1),
              const Color(0xffffffff).withOpacity(1)
            ],
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            _buildBottomNavigationBarItem(
                0, 'images/1s.png', 'images/1u.png', 'Home'),
            _buildBottomNavigationBarItem(
                1, 'images/2s.png', 'images/2u.png', 'Category'),
            _buildBottomNavigationBarItem(
                2, 'images/3s.png', 'images/3u.png', 'Wishlist'),
            _buildBottomNavigationBarItem(
                3, 'images/5u.png', 'images/5u.png', 'Token'),
            _buildBottomNavigationBarItem(
                4, 'images/4u.png', 'images/4u.png', 'Profile'),
          ],
          elevation: 5,
          backgroundColor: Colors.white,
          selectedIconTheme: IconThemeData(color: Colors.black),
          selectedLabelStyle: GoogleFonts.lora(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w700,
            letterSpacing: .1,
          ),
          unselectedLabelStyle: GoogleFonts.lora(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            letterSpacing: .1,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      int index, String selectedImage, String unselectedImage, String label) {
    return BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage(_selectedIndex == index ? selectedImage : unselectedImage),
        // color: _selectedIndex == index ? Colors.black : Colors.black,
      ),
      label: label,
    );
  }

  Widget buildGridView() => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 20 / 18,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final item = images[index];
          return buildNumber(item);
        },
      );

  Widget buildNumber(Widget number) => Container(
      color: Colors.white,
      padding: const EdgeInsets.only(right: 8, left: 8, bottom: 30),
      child: Center(child: number));
}
