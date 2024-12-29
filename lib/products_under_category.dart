import 'package:flutter/material.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/model/appProducts.dart';
import 'package:shyam_tiles/model/user.dart';
import 'package:shyam_tiles/product_details.dart';
import 'package:shyam_tiles/search.dart';

class ProductsUnderCategory extends StatefulWidget {
  var catId;
  var categoryName;

  ProductsUnderCategory(this.categoryName, this.catId, {super.key});
  @override
  ProductsUnderCategoryState createState() => ProductsUnderCategoryState();
}

class ProductsUnderCategoryState extends State<ProductsUnderCategory> {
  var appliedFilters = [];
  String? userLocation;

  int totalProducts = 0;
  int page = 0;
  int perPage = 20;
  bool isFirstLoad = false;
  bool isPageLoading = false;
  bool hasNextPage = true;
  bool isLoadMoreRunning = false;
  bool _isLastPage = false;
  List<String> sizeFilters = [];
  List<AppProducts> searchProducts = [];
  List<AppProducts> filterProducts = [];

  late ScrollController scrollController;
  void _firstLoad() {
    setState(() {
      isFirstLoad = true;
      page = 0;
      searchProducts.clear();
      sizeFilters.clear();
      filterProducts.clear();
      totalProducts = 0;
      fetchSearchList();
    });
  }

  void loadMore() {
    if (!_isLastPage) {
      //  print("Call Load More ${_isLastPage}");
      if (hasNextPage && !isLoadMoreRunning) {
        setState(() {
          isLoadMoreRunning = true;
          page++;
          fetchSearchList();
        });
      }

      setState(() {
        isLoadMoreRunning = false;
      });
    }
  }

  void fetchSearchList() async {
    if (!_isLastPage && !isPageLoading) {
      isPageLoading = true;
      List<AppProducts> allSearchData = [];

      ResponseSmartAuditor responseSmartAuditor = await AppProducts()
          .getProductsByCat(widget.categoryName,
              page: page, perPage: perPage, location: userLocation);

      if (responseSmartAuditor.status) {
        var appWishList = responseSmartAuditor.body;
        if (appWishList != null && appWishList is List) {
          setState(() {
            var recDataCnt = 0;
            for (var product in appWishList) {
              recDataCnt++;
              if (product is AppProducts) {
                allSearchData.add(product);
                if (!sizeFilters.contains(product.size)) {
                  sizeFilters.add(product.size);
                }
              } else {
                print('Unexpected type in appWishList: ${product.runtimeType}');
              }
            }
            isFirstLoad = false;
            filterProducts.addAll(allSearchData);
            searchProducts.addAll(allSearchData);
            totalProducts = searchProducts.length; // Update totalProducts here
            isPageLoading = false;
            _isLastPage = recDataCnt < perPage;
            if (_isLastPage) {
              scrollController.removeListener(loadMore);
            }
          });
        }
      } else {
        // Handle error
        print("Error fetching products: ${responseSmartAuditor.errorMessage}");
      }
    }
  }

  void applyFilter() {
    filterProducts.clear();

    if (appliedFilters.isNotEmpty) {
      for (int i = 0; i < searchProducts.length; i++) {
        if (appliedFilters.contains(searchProducts[i].size)) {
          filterProducts.add(searchProducts[i]);
        }
      }
    } else {
      filterProducts.addAll(searchProducts);
    }

    totalProducts = filterProducts.length; // Update totalProducts here
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      var nextPageTrigger = 0.8 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > nextPageTrigger && !_isLastPage) {
        loadMore();
      }
    });
    getUserLocation();
    _firstLoad();

    // fetchSearchList();
  }

  void getUserLocation() async {
    // Assume UserSession.getUserLocation() returns the logged-in user's location
    userLocation = await AppUser.sharedInstance.location;
    _firstLoad(); // Reload products with the user's location
  }

  TextEditingController txtSearch = TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('My Personal Journal');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xffFAFAFA),
        drawerEnableOpenDragGesture: true,
        drawer: Drawer(
          backgroundColor: Color(0xff333333),
          child: ListView.builder(
              itemCount: sizeFilters.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    if (!appliedFilters.contains(sizeFilters[index])) {
                      appliedFilters.add(sizeFilters[index]);
                    } else {
                      appliedFilters.remove(sizeFilters[index]);
                    }
                    setState(() {
                      applyFilter();
                    });
                  },
                  //leading: Icon(Icons.list),
                  title: Text(
                    sizeFilters[index],
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    Icons.done,
                    size: 25,
                    weight: 16,
                    color: (appliedFilters.contains(sizeFilters[index]))
                        ? Colors.grey
                        : Colors.white,
                  ),
                );
              }),
          //elevation: 20.0,
          //semanticLabel: 'endDrawer',
        ),
        // floatingActionButton: Center(
        //   child: Container(
        //     padding: const EdgeInsets.only(top: 220, right: 200),
        //     child: (sizeFilters.isNotEmpty)
        //         ? FloatingActionButton.extended(
        //             onPressed: () {
        //               _scaffoldKey.currentState!.openDrawer();
        //               // Add your onPressed code here!
        //             },
        //             label: const Text(''),
        //             icon: const ImageIcon(
        //               AssetImage('images/tune_black_24dp.png'),
        //             ),
        //             backgroundColor: const Color(0xff000000).withOpacity(.8),
        //           )
        //         : null,
        //   ),
        // ),
        appBar: AppBar(
          elevation: 0.0,
          actions: [
            Container(
              child: (sizeFilters.isNotEmpty)
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                        // Add your onPressed code here!
                      },
                      label: const Text(''),
                      icon: Icon(
                        Icons.filter_list,
                        color: Colors.white,
                      ),
                      backgroundColor: Color(0xff333333),
                    )
                  : null,
            )
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text("${widget.categoryName}",
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.normal,
              )),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xff333333),
              // gradient: LinearGradient(
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomRight,
              //     colors: <Color>[Color(0xff7e7e7e), Color(0xff7e7e7e)]),
            ),
          ),
        ),
        body: (isFirstLoad)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/hmbg.webp'), fit: BoxFit.cover),
                ),
                // height: MediaQuery.of(context).size.height,
                // width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    //Text("Current Location: $userLocation"),
                    //Text("Total Products: ${filterProducts.length}"),
                    if (filterProducts.isNotEmpty)
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xffFAFAFA),
                        ),
                        child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('images/hmbg.webp'),
                                  fit: BoxFit.cover),
                            ),
                            margin: const EdgeInsets.all(18),
                            child: SizedBox(
                              height: 49,
                              child: TextField(
                                controller: txtSearch,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  filled: true,
                                  hintStyle: const TextStyle(
                                      color: Color(0xffB4B4B4),
                                      fontWeight: FontWeight.w600),
                                  hintText: "Search for products..",
                                  fillColor: Colors.white,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      if (txtSearch.text.isNotEmpty) {
                                        var search = txtSearch.text;
                                        txtSearch.text = "";
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    SearchScreen(search)));
                                      }
                                    },
                                    child: Container(
                                      color: const Color(0xff3a3b3c)
                                          .withOpacity(.7),
                                      margin: const EdgeInsets.only(
                                          top: 0.6, right: 1, bottom: .6),
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    if (filterProducts.isEmpty)
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 160,
                        child: Center(
                          child: Text(
                              "Products not found under this ${widget.categoryName}"),
                        ),
                      ),
                    Expanded(
                        child: ListView.builder(
                            //controller: scrollController,
                            itemCount: (filterProducts.length / 2).ceil(),
                            itemBuilder: (context, index) {
                              int i = index * 2;

                              return Column(
                                children: [
                                  LayoutBuilder(
                                      builder: (context, constraints) {
                                    double itemWidth = constraints.maxWidth / 2;

                                    return Container(
                                      margin: const EdgeInsets.all(10),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .32,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          ProductDetails(
                                                              filterProducts[
                                                                  i])));
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 5),
                                              width: itemWidth - 10,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.25,
                                                    child: (filterProducts[i]
                                                            .image
                                                            .isNotEmpty)
                                                        ? Image.network(
                                                            filterProducts[i]
                                                                .image[0],
                                                            fit: BoxFit.fill,
                                                          )
                                                        : Image.asset(
                                                            "images/shyamtiles.png",
                                                            fit: BoxFit.contain,
                                                          ),
                                                  ),
                                                  FittedBox(
                                                    fit: BoxFit.cover,
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            WidgetSpan(
                                                              child: Center(
                                                                child: Text(
                                                                  filterProducts[
                                                                          i]
                                                                      .name,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontFamily:
                                                                        "Roboto-Thin",
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            WidgetSpan(
                                                              child: Center(
                                                                child: Text(
                                                                  filterProducts[
                                                                          i]
                                                                      .size,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontFamily:
                                                                        "Roboto-Thin",
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (i + 1 <
                                              filterProducts.length) ...[
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            ProductDetails(
                                                                filterProducts[
                                                                    i + 1])));
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                width: itemWidth - 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 5,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.25,
                                                      child:
                                                          (filterProducts[i + 1]
                                                                  .image
                                                                  .isNotEmpty)
                                                              ? Image.network(
                                                                  filterProducts[
                                                                          i + 1]
                                                                      .image[0],
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )
                                                              : Image.asset(
                                                                  "images/shyamtiles.png",
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                    ),
                                                    FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              WidgetSpan(
                                                                child: Center(
                                                                  child: Text(
                                                                    filterProducts[
                                                                            i + 1]
                                                                        .name,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontFamily:
                                                                          "Roboto-Thin",
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              WidgetSpan(
                                                                child: Center(
                                                                  child: Text(
                                                                    filterProducts[
                                                                            i + 1]
                                                                        .size,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontFamily:
                                                                          "Roboto-Thin",
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                    );
                                  })
                                ],
                              );
                            })),
                    if (isLoadMoreRunning == true)
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ));
  }
}
