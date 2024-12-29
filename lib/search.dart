import 'package:flutter/material.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/model/appProducts.dart';
import 'package:shyam_tiles/product_details.dart';

class SearchScreen extends StatefulWidget {
  var search;
  SearchScreen(this.search, {super.key});
  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  List<AppProducts> searchProducts = [];
  List<AppProducts> suggestedProducts = [];

  void fetchSearchList() async {
    searchProducts.clear();
    suggestedProducts.clear();
    ResponseSmartAuditor responseSmartAuditor =
        await AppProducts().searchProducts(widget.search);
    if (responseSmartAuditor.status) {
      var appWishList = responseSmartAuditor.body;
      if (appWishList != null && appWishList is List<dynamic>) {
        setState(() {
          try {
            for (Map<String, dynamic> dict in appWishList) {
              AppProducts appProd = AppProducts();
              appProd.dictToObject(dict);
              searchProducts.add(appProd);
            }
          } catch (e) {
            var appWishList = responseSmartAuditor.body[1];
            if (appWishList != null && appWishList is List<dynamic>) {
              for (Map<String, dynamic> dict in appWishList) {
                AppProducts appProd = AppProducts();
                appProd.dictToObject(dict);
                suggestedProducts.add(appProd);
              }
            }
          }
        });
      }
    } else {}
  }

  @override
  void initState() {
    super.initState();
    fetchSearchList();
  }

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('My Personal Journal');
  @override
  Widget build(BuildContext context) {
    //print("Found Products :${searchProducts.length}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff333333),
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Search for ${widget.search}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/hmbg.webp'), fit: BoxFit.cover)),
        child: Column(
          children: [
            if (searchProducts.isNotEmpty)
              Expanded(
                  child: ListView.builder(
                      itemCount: (searchProducts.length / 2).ceil(),
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
                                      MediaQuery.of(context).size.height * .32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      if (i < searchProducts.length)
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ProductDetails(
                                                    searchProducts[i]),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            width: itemWidth - 10,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.25,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: DecorationImage(
                                                      image: searchProducts[i]
                                                              .image
                                                              .isNotEmpty
                                                          ? NetworkImage(
                                                              searchProducts[i]
                                                                  .image[0])
                                                          : const AssetImage(
                                                                  "images/shyamtiles.png")
                                                              as ImageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  searchProducts[i].name,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  searchProducts[i].size,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (i + 1 < searchProducts.length)
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ProductDetails(
                                                    searchProducts[i + 1]),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(left: 5),
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
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.25,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: DecorationImage(
                                                      image: searchProducts[
                                                                  i + 1]
                                                              .image
                                                              .isNotEmpty
                                                          ? NetworkImage(
                                                              searchProducts[
                                                                      i + 1]
                                                                  .image[0])
                                                          : const AssetImage(
                                                                  "images/shyamtiles.png")
                                                              as ImageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  searchProducts[i + 1].name,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  searchProducts[i + 1].size,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }))
            else ...[
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(
                  "0 results found for ${widget.search}\r\n best matches",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: (suggestedProducts.length / 2).ceil(),
                      itemBuilder: (context, index) {
                        int i = index * 2;

                        //print("Loading Index $i ${i + 1}");
                        return Column(
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ProductDetails(
                                                  suggestedProducts[i])));
                                    },
                                    child: SizedBox(
                                      height: 225,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          7,
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 15.0, left: 30, right: 15),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 119,
                                              child: (suggestedProducts[i]
                                                      .image
                                                      .isNotEmpty)
                                                  ? Image.network(
                                                      suggestedProducts[i]
                                                          .image[0],
                                                      fit: BoxFit.contain,
                                                    )
                                                  : Image.asset(
                                                      "images/shyamtiles.png",
                                                      fit: BoxFit.contain,
                                                    ),
                                            ),
                                            FittedBox(
                                              fit: BoxFit.cover,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: Center(
                                                          child: Text(
                                                            suggestedProducts[i]
                                                                .name,
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "Roboto-Thin",
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      WidgetSpan(
                                                        child: Center(
                                                          child: Text(
                                                            suggestedProducts[i]
                                                                .size,
                                                            textAlign:
                                                                TextAlign.left,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "Roboto-Thin",
                                                              fontSize: 14,
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
                                  ),
                                  if (i + 1 < suggestedProducts.length) ...[
                                    const VerticalDivider(
                                      thickness: 2,
                                      width: 5,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => ProductDetails(
                                                    suggestedProducts[i + 1])));
                                      },
                                      child: SizedBox(
                                        height: 225,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              top: 15.0, right: 30, left: 15),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 119,
                                                child: (suggestedProducts[i + 1]
                                                        .image
                                                        .isNotEmpty)
                                                    ? Image.network(
                                                        suggestedProducts[i + 1]
                                                            .image[0],
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Image.asset(
                                                        "images/shyamtiles.png",
                                                        fit: BoxFit.contain,
                                                      ),
                                              ),
                                              FittedBox(
                                                fit: BoxFit.cover,
                                                child: Container(
                                                  width: MediaQuery.of(context)
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
                                                              suggestedProducts[
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
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        WidgetSpan(
                                                          child: Center(
                                                            child: Text(
                                                              suggestedProducts[
                                                                      i + 1]
                                                                  .size,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
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
                                                                fontSize: 14,
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
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 2,
                              indent: 30,
                              endIndent: 30,
                            )
                          ],
                        );
                      })),
            ]
          ],
        ),
      ),
    );
  }
}
