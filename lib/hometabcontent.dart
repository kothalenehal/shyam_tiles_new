import 'dart:async';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/model/appContact.dart';
import 'package:shyam_tiles/model/appProducts.dart';
import 'package:shyam_tiles/model/banner_model.dart';
import 'package:shyam_tiles/model/category_model.dart';
import 'package:shyam_tiles/model/user.dart';
import 'package:shyam_tiles/product_details.dart';
import 'package:shyam_tiles/products_under_category.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeContent extends StatefulWidget {
  final Function setTab;
  final Function refreshDrawer;
  const HomeContent(this.setTab, this.refreshDrawer, {super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int _currentIndex = 0;
  var now = DateTime.now().year;
  final List<AppBanners> bannersList = [];
  final List<AppProducts> allProducts = [];
  final List<AppProducts> trendingProducts = [];
  AppProducts bestDealProducts = AppProducts();
  final List<AppProducts> latestProducts = [];
  final List<AppSettings> lstAppSettings = [];

  final List<AppGallery> galleryList = [];
  final AppContact appContact = AppContact();

  late final ScrollController _scrollController1;
  late final ScrollController _scrollController2;
  late final ScrollController _scrollController3;
  bool _dataLoaded = false;

  bool isLoading = true;

  void fetchContactData() async {
    ResponseSmartAuditor responseSmartAuditor = await appContact.getContact();

    if (responseSmartAuditor.status) {
      var appCategoriesList = responseSmartAuditor.body["contact"];
      var appCategoriesSettings = responseSmartAuditor.body["settings"];
      if (appCategoriesList != null) {
        setState(() {
          appContact.dictToObject(appCategoriesList);
        });
      }
      if (appCategoriesSettings != null) {
        if (appCategoriesSettings != null &&
            appCategoriesSettings is List<dynamic>) {
          setState(() {
            for (Map<String, dynamic> dict in appCategoriesSettings) {
              AppSettings appSettings = AppSettings();
              appSettings.dictToObject(dict);
              lstAppSettings.add(appSettings);
            }
          });
        }
      }
    } else {}
  }

  List<AppCategories> categoriesList = [];

  void fetchCategories() async {
    categoriesList.clear();
    AppCategories appCategories = AppCategories();

    ResponseSmartAuditor responseSmartAuditor =
        await appCategories.getCategories();

    if (responseSmartAuditor.status) {
      var appCategoriesList = responseSmartAuditor.body;

      setState(() {
        if (appCategoriesList != null && appCategoriesList is List<dynamic>) {
          for (Map<String, dynamic> dict in appCategoriesList) {
            appCategories = AppCategories();
            appCategories.dictToObject(dict);
            categoriesList.add(appCategories);
          }
        }
      });
    } else {}
  }

  void fetchGallery() async {
    galleryList.clear();
    AppGallery appGallery = AppGallery();

    ResponseSmartAuditor responseSmartAuditor = await appGallery.getGallery();

    if (responseSmartAuditor.status) {
      var appCategoriesList = responseSmartAuditor.body;

      if (appCategoriesList != null && appCategoriesList is List<dynamic>) {
        setState(() {
          for (Map<String, dynamic> dict in appCategoriesList) {
            appGallery = AppGallery();
            appGallery.dictToObject(dict);
            galleryList.add(appGallery);
          }
        });
      }
    }
  }

  void fetchProducts() async {
    allProducts.clear();
    trendingProducts.clear();

    latestProducts.clear();
    AppProducts appProducts = AppProducts();

    ResponseSmartAuditor responseSmartAuditor = await appProducts.getProducts();

    if (responseSmartAuditor.status) {
      var appCategoriesList = responseSmartAuditor.body;
      if (appCategoriesList != null && appCategoriesList is List<dynamic>) {
        setState(() {
          for (Map<String, dynamic> dict in appCategoriesList) {
            appProducts = AppProducts();
            appProducts.dictToObject(dict);
            allProducts.add(appProducts);

            if (appProducts.trending == 1) trendingProducts.add(appProducts);
            if (appProducts.bestprice_deal == 1) bestDealProducts = appProducts;
            if (appProducts.latest_product == 1) {
              latestProducts.add(appProducts);
            }
          }
          widget.refreshDrawer();
        });
      }
    } else {}
  }

  void fetchBanners() async {
    bannersList.clear();
    AppBanners appBanners = AppBanners();

    ResponseSmartAuditor responseSmartAuditor = await appBanners.getBanners();

    if (responseSmartAuditor.status) {
      var appCategoriesList = responseSmartAuditor.body;
      if (appCategoriesList != null && appCategoriesList is List<dynamic>) {
        setState(() {
          for (Map<String, dynamic> dict in appCategoriesList) {
            appBanners = AppBanners();
            appBanners.dictToObject(dict);
            bannersList.add(appBanners);
          }
        });
      }
    } else {}
  }

  Future<void> refreshData() async {
    if (AppUser.sharedInstance.user_type == 1) fetchBanners();
    fetchGallery();
    fetchProducts();
    fetchCategories();
    fetchContactData();
  }

  @override
  void initState() {
    super.initState();
    if (AppUser.sharedInstance.user_type == 1) fetchBanners();
    fetchGallery();
    fetchProducts();
    fetchCategories();
    fetchContactData();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController3 = ScrollController();
    _autoScroll(_scrollController1);
    _autoScroll(_scrollController2, reverse: true);
    _autoScroll(_scrollController3);
    _fetchData();
  }

  void _fetchData() async {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _dataLoaded = true;
          isLoading = false;
        });
      }
    });
  }

  void _autoScroll(ScrollController controller, {bool reverse = false}) {
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (!mounted) return;

      double maxScroll = controller.position.maxScrollExtent;
      double minScroll = controller.position.minScrollExtent;
      double currentScroll = controller.position.pixels;

      double targetScroll = reverse
          ? (currentScroll <= minScroll ? maxScroll : minScroll)
          : (currentScroll >= maxScroll ? minScroll : maxScroll);

      controller.animateTo(
        targetScroll,
        duration: const Duration(seconds: 5),
        curve: Curves.easeInOut,
      );
    });
  }

  final numbers = List.generate(100, (index) => '$index');
  final images = [
    Image.asset(
      'images/Image 22.png',
      fit: BoxFit.cover,
    ),
    Image.asset('images/Image 23.png'),
    Image.asset('images/Image 24.png'),
    Image.asset('images/Image 25.png'),
  ];

  final controller = ScrollController();

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<AppGallery> row1 = galleryList.take(3).toList();
    List<AppGallery> row2 = galleryList.skip(3).take(1).toList();
    List<AppGallery> row3 = galleryList.skip(4).take(5).toList();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/hmbg.webp'), fit: BoxFit.cover),
      ),
      height: MediaQuery.of(context).size.height - 00,
//
      // margin: new EdgeInsets.all(20.0),
      child: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: refreshData,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            semanticChildCount: 0,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
                child: Column(children: [
                  if (AppUser.sharedInstance.user_type == 1)
                    (bannersList.length > 0)
                        ? CarouselSlider(
                            items: [
                              for (int i = 0; i < bannersList.length; i++)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(bannersList[i].image),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                )
                            ],
                            options: CarouselOptions(
                              height: 210.0,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              aspectRatio: 16 / 9,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                              viewportFraction: 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                          )
                        : Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 230,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Colors.white,
                              ),
                            ),
                          ),
                  (bannersList.length > 0)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: bannersList.asMap().entries.map((entry) {
                            int index = entry.key;
                            return Container(
                              width: _currentIndex == index
                                  ? 18.0
                                  : 8.0, // Width changes for the selected indicator
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: _currentIndex == index
                                    ? BoxShape.rectangle
                                    : BoxShape
                                        .circle, // Rectangle for selected, circle for others
                                borderRadius: _currentIndex == index
                                    ? BorderRadius.circular(4.0)
                                    : null, // Optional: rounded corners for the rectangle
                                color: _currentIndex == index
                                    ? const Color(0xff333333)
                                    : const Color(0xff333333).withOpacity(.2),
                              ),
                            );
                          }).toList(),
                        )
                      : Container(),

                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: RichText(
                        text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Explore Products',
                          style: GoogleFonts.poppins(
                            fontSize: 27,
                            height: 1,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .1,
                          ),
                        ),
                      ],
                    )),
                  ),
                  if (categoriesList.length > 0)
                    Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 0),
                        child: buildGridView(false)),
                  if (AppUser.sharedInstance.user_type == 1)
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 40,
                            child: Column(
                              children: [
                                Text(
                                  'BEST PRICE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: .1,
                                  ),
                                ),
                                const Text(
                                  "DEAL!!",
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontFamily: 'Roboto-Thin',
                                      fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  height: 23,
                                  width: 88,
                                  decoration: BoxDecoration(
                                      color: const Color(0xffF3C507),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xA3000000),
                                          offset: Offset(
                                            1.0,
                                            1.0,
                                          ),
                                          blurRadius: 6.0,
                                          spreadRadius: 1.0,
                                        ), //BoxShadow
                                        BoxShadow(
                                          color: Colors.white,
                                          offset: Offset(0.0, 0.0),
                                          blurRadius: 0.0,
                                          spreadRadius: 0.0,
                                        ), //BoxShadow
                                      ],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ProductDetails(
                                                  bestDealProducts)));
                                    },
                                    child: Center(
                                      child: Text(
                                        'Know More',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: .1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)),
                              width: 20 + MediaQuery.of(context).size.width / 2,
                              child: (bestDealProducts.image.isNotEmpty)
                                  ? Image.network(
                                      bestDealProducts.image[0],
                                      fit: BoxFit.fill,
                                      height: 100,
                                    )
                                  : Image.asset(
                                      "images/shyamtiles.png",
                                      fit: BoxFit.fill,
                                      height: 100,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (latestProducts.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 35),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Latest Products',
                            style: GoogleFonts.poppins(
                              fontSize: 27,
                              height: 1,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              letterSpacing: .0,
                            ),
                          )),
                    ),
                  if (latestProducts.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 0),
                      child: CarouselSlider(
                        items: [
                          //1st Image of Slider
                          for (int i = 0; i < latestProducts.length; i++)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetails(latestProducts[i])));
                              },
                              child: Card(
                                elevation: 30,
                                color: Colors.white,
                                borderOnForeground: true,
                                surfaceTintColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                margin: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: (latestProducts[i]
                                                    .image
                                                    .isNotEmpty)
                                                ? Image.network(
                                                    latestProducts[i].image[0],
                                                    fit: BoxFit.fill,
                                                    height: 160,
                                                  )
                                                : Image.asset(
                                                    "images/shyamtiles.png",
                                                    fit: BoxFit.fill,
                                                    height: 160,
                                                  ),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.only(
                                              top: 8, left: 15),
                                          child: Row(
                                            children: [
                                              Text(
                                                latestProducts[i].name,
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 19,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: .1,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                latestProducts[i].size,
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  color:
                                                      const Color(0xff8D99AE),
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: .1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        height: 23,
                                        width: 88,
                                        decoration: const BoxDecoration(
                                          color: Color(0xffF3C507),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xA3000000),
                                              offset: Offset(
                                                1.0,
                                                1.0,
                                              ),
                                              blurRadius: 6.0,
                                              spreadRadius: 1.0,
                                            ), //BoxShadow
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: Offset(0.0, 0.0),
                                              blurRadius: 0.0,
                                              spreadRadius: 0.0,
                                            ), //BoxShadow
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'New Arrival',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Roboto-Thin',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],

                        //Slider Container properties
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: false,
                          initialPage: 1,
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: true,
                          disableCenter: true,
                          padEnds: false,
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 80),
                          viewportFraction: .92,
                        ),
                      ),
                    ),

                  if (trendingProducts.length > 1)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 5.0, right: 5, top: 25),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width,
                        //height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xff333333).withOpacity(.9),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Column(
                          children: [
                            RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Trending Now',
                                      style: GoogleFonts.poppins(
                                        fontSize: 26,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: .1,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '\n New and Trending Tiles collections',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.grey.shade100,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: .1,
                                      ),
                                    )
                                  ],
                                )),
                            // buildGridView(true),
                            const SizedBox(
                              height: 10,
                            ),
                            CarouselSlider(
                              items: [
                                //1st Image of Slider
                                for (int i = 0;
                                    i < trendingProducts.length;
                                    i++)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            trendingProducts[i].image[0]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              ],

                              //Slider Container properties
                              options: CarouselOptions(
                                height: 180.0,
                                enlargeCenterPage: true,
                                autoPlay: true,
                                aspectRatio: 16 / 9,
                                autoPlayCurve: Curves.easeInToLinear,
                                enableInfiniteScroll: false,
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 1500),
                                viewportFraction: .8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_dataLoaded == true ||
                      (row1.isNotEmpty ||
                              row2.isNotEmpty ||
                              row3.isNotEmpty ||
                              index < row1.length ||
                              index < row2.length ||
                              index < row3.length) &&
                          ((row1[index].image.length > 1) ||
                              (row2[index].image.length > 1) ||
                              (row3[index].image.length > 1)))
                    Padding(
                      padding: const EdgeInsets.only(top: 35.0, bottom: 15),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Browse Our Gallery',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: .1,
                                ),
                              ),
                            ],
                          )),
                    ),

                  if (row1.isNotEmpty &&
                      index < row1.length &&
                      row1[index].image.length > 1)
                    SizedBox(
                      height: 210,
                      child: ListView.builder(
                        semanticChildCount: 0,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController1,
                        itemCount: row1.length,
                        itemBuilder: (context, index) {
                          return buildImageContainer(row1[index].image);
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Second Row: 3 images
                  if (row2.isNotEmpty &&
                      index < row2.length &&
                      row2[index].image.length > 1)
                    Container(
                      height: 170,
                      padding: const EdgeInsets.only(left: 10),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: ListView.builder(
                        semanticChildCount: 0,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController2,
                        itemCount: row2.length,
                        itemBuilder: (context, index) {
                          return buildImageContainer(row2[index].image);
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Third Row: 5 images
                  if (row3.isNotEmpty &&
                      index < row3.length &&
                      row3[index].image.length > 1)
                    SizedBox(
                      height: 210,
                      child: Center(
                        child: ListView.builder(
                          semanticChildCount: 0,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController3,
                          itemCount: row3.length,
                          itemBuilder: (context, index) {
                            return buildImageContainer(row3[index].image);
                          },
                        ),
                      ),
                    ),

                  Container(
                    margin:
                        const EdgeInsets.only(bottom: 10, top: 30, left: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Features",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .1,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 10,
                        height: 200,
                        child: Card(
                          color: Colors.white,
                          surfaceTintColor: Colors.white,
                          elevation: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Image.asset(
                                  'images/setting.png',
                                  //fit: BoxFit.cover,
                                  height: 50,
                                  alignment: Alignment.topCenter,
                                ),
                              ), //
                              Text(
                                'Easy Installation',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: .1,
                                ),
                              ),

                              FittedBox(
                                child: const Text(
                                  '\n Get your new tiles easily \n installed in the most \n professional manner. ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: "Roboto-Thin",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 10,
                        height: 200,
                        child: Card(
                          surfaceTintColor: Colors.white,
                          color: Colors.white,
                          elevation: 10,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20.0, bottom: 5),
                                child: Image.asset(
                                  'images/home.png',
                                  //fit: BoxFit.cover,
                                  height: 50,
                                  alignment: Alignment.topCenter,
                                ),
                              ), //
                              Text(
                                'Low Maintanance',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: .1,
                                ),
                              ),

                              FittedBox(
                                child: const Text(
                                  '\n Hard, durable,eco-friedly \n & water resistant lasting \n for decades.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: "Roboto-Thin",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 165,
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 30,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Image.asset(
                              'images/right.png',
                              //fit: BoxFit.cover,
                              height: 50,
                              alignment: Alignment.topCenter,
                            ),
                          ), //
                          Text(
                            'Best Quality',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .1,
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(
                              '\n Assuring some of the best quality in the market for all  products.',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: "Roboto-Thin",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if ((appContact.address != "") &&
                      (appContact.email != "") &&
                      (appContact.contact != ""))
                    Container(
                      padding: const EdgeInsets.only(bottom: 35),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xff333333),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double containerWidth = constraints.maxWidth;

                          // Calculate font sizes based on container width
                          double titleFontSize = containerWidth * 0.065;
                          double contentFontSize = containerWidth * 0.038;

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  "Store Address",
                                  style: GoogleFonts.poppins(
                                    fontSize: titleFontSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 18.0, top: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: Text(
                                          appContact.address,
                                          overflow: TextOverflow.clip,
                                          softWrap: true,
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
                                padding:
                                    const EdgeInsets.only(left: 18.0, top: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: Colors.grey.shade300,
                                      size: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        appContact.email,
                                        overflow: TextOverflow.clip,
                                        style: GoogleFonts.poppins(
                                          fontSize: contentFontSize,
                                          color: Colors.grey.shade300,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: .1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 18.0, top: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        launchUrl(Uri.parse(
                                            "tel://${appContact.contact}"));
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          appContact.contact,
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
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 18.0, top: 10),
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
                            ],
                          );
                        },
                      ),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .33,
                  ),
                ]),
              );
            }),
      ),
    );
  }

  Widget buildGridView(bool trending) {
    return Column(
      children: [
        GridView.builder(
          semanticChildCount: 0,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 1, // Only 1 item in the first row
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // 1 item per row
            childAspectRatio: 16 / 9,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemBuilder: (context, index) {
            if (isLoading) {
              return shimmerGridItem(aspectRatio: 16 / 9);
            }
            return GestureDetector(
              onTap: () {
                widget.setTab(4);
              },
              child: (trending)
                  ? buildNumber(trendingProducts[index])
                  : buildCategory(categoriesList[index]),
            );
          },
        ),
        GridView.builder(
          semanticChildCount: 0,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount:
              (trending ? trendingProducts.length : categoriesList.length) - 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            childAspectRatio: 7 / 8,
            mainAxisSpacing: 0,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            if (isLoading) {
              return shimmerGridItem(aspectRatio: 7 / 8);
            }
            return GestureDetector(
              onTap: () {
                widget.setTab(4);
              },
              child: (trending)
                  ? buildNumber(trendingProducts[index + 1])
                  : buildCategory(categoriesList[index + 1]),
            );
          },
        ),
      ],
    );
  }

  Widget shimmerGridItem({required double aspectRatio}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget buildImageContainer(String imageUrl) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Widget getSocialIcon(AppSettings settings) {
  //   return GestureDetector(
  //       onTap: () {
  //         launchUrl(Uri.parse(settings.value));
  //       },
  //       child: (settings.key == "Twitter")
  //           ? const ImageIcon(
  //               AssetImage('images/twitter.png'),
  //               size: 30,
  //               color: Colors.white,
  //             )
  //           : (settings.key == "Facebook")
  //               ? const ImageIcon(
  //                   AssetImage('images/fb.png'),
  //                   color: Colors.white,
  //                   size: 30,
  //                 )
  //               : (settings.key == "Instagram")
  //                   ? const ImageIcon(
  //                       AssetImage('images/insta.png'),
  //                       color: Colors.white,
  //                       size: 30,
  //                     )
  //                   : Container());
  // }

  Widget buildCategory(AppCategories product) => GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ProductsUnderCategory(product.name, product.id)));
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                height: MediaQuery.of(context).size.height * 0.2,
                child: Image.network(
                  product.image,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
            Container(
              height: 25,
              width: MediaQuery.of(context).size.width,
              color: Colors.white.withOpacity(.6),
              child: Center(
                  child: Text(
                product.name.trim(),
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .1,
                ),
              )),
            )
          ],
        ),
      );

  Widget buildNumber(AppProducts product) => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
      ),
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ProductDetails(product)));
          },
          child: Stack(
            children: [
              (product.image.isNotEmpty)
                  ? Image.network(
                      product.image[0],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width / 2,
                    )
                  : Image.asset(
                      "images/shyamtiles.png",
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width / 2,
                    ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 25,
                  width: MediaQuery.of(context).size.width / 2,
                  color: Colors.white.withOpacity(.6),
                  child: Center(
                      child: Text(
                    product.name.trim(),
                    style: GoogleFonts.lora(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .1,
                    ),
                  )),
                ),
              )
            ],
          ),
        ),
      ));
}
