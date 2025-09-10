import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/model/appProducts.dart';
import 'package:shyam_tiles/model/banner_model.dart';
import 'package:shyam_tiles/product_details.dart';

class WishlistItem extends StatefulWidget {
  const WishlistItem({Key? key}) : super(key: key);

  @override
  State<WishlistItem> createState() => _WishlistItemState();
}

class _WishlistItemState extends State<WishlistItem> {
  List<AppProducts> userWishlist = [];
  bool isLoading = false;

  Future<void> fetchWishlist() async {
    setState(() {
      isLoading = true;
    });
    try {
      userWishlist.clear();
      ResponseSmartAuditor responseSmartAuditor =
          await WishList().getWishlist();
      if (responseSmartAuditor.status) {
        var appWishList = responseSmartAuditor.body;
        if (appWishList != null && appWishList is List<dynamic>) {
          setState(() {
            for (Map<String, dynamic> dict in appWishList) {
              AppProducts appProd = AppProducts();
              appProd.dictToObject(dict);
              userWishlist.add(appProd);
            }
          });
        }
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshWishlist() async {
    await fetchWishlist();
  }

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Wishlist',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshWishlist,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : userWishlist.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height - 299,
                              child: Center(
                                child: Text(
                                  "Your wishlist is empty",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: userWishlist.length,
                          itemBuilder: (context, index) {
                            return SwipeActionCell(
                              key: ObjectKey(userWishlist[index]),
                              trailingActions: <SwipeAction>[
                                SwipeAction(
                                    title: "Delete",
                                    onTap: (CompletionHandler handler) async {
                                      await WishList()
                                          .removeFromWishList(
                                              userWishlist[index].id!)
                                          .then((value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          backgroundColor: Colors.white54,
                                          content: Text(
                                            "Removed from wishlist",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ));
                                        if (value.status) fetchWishlist();
                                      });
                                    },
                                    color: Colors.redAccent),
                              ],
                              child: ItemWidget(item: userWishlist[index]),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... rest of the code remains the same ...

class ItemWidget extends StatelessWidget {
  final AppProducts item;
  TextEditingController quantityController = TextEditingController();

  ItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.transparent),
              top: BorderSide(color: Colors.grey))),
      margin: const EdgeInsets.only(bottom: 1, top: 0),
      padding: const EdgeInsets.only(bottom: 0, left: 0),
      child: Row(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProductDetails(item)));
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: (item.image.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.image[0],
                        fit: BoxFit.fill,
                      ),
                    )
                  : Image.asset(
                      "images/shyamtiles.png",
                      fit: BoxFit.fill,
                    ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 20, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              fontFamily: 'Roboto-Thin'),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item.size,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              fontFamily: 'Roboto-Thin'),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        backgroundColor: const Color(0xffB4B4B4),
                        title: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: const Center(
                                child: Text(
                                  'Quantity :',
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
                              height: 40,
                              padding: const EdgeInsets.only(top: 8),
                              child: Center(
                                child: TextField(
                                  controller: quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    filled: true,
                                    hintStyle: const TextStyle(
                                        color: Color(0xffB4B4B4), fontSize: 14),
                                    hintText:
                                        "Please enter tiles quantity (minimum 1)..",
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          GestureDetector(
                            onTap: () {
                              if (quantityController.text.isEmpty) {
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
                              
                              int quantity = int.tryParse(quantityController.text) ?? 0;
                              
                              if (quantity <= 0) {
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
                              
                              if (quantity > item.quantity) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      "Quantity exceeds available stock (${item.quantity})",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                                return;
                              }
                              
                              if (quantityController.text != "" &&
                                  quantity > 0 &&
                                  quantity <= item.quantity) {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                    ),
                                    backgroundColor: const Color(0xffB4B4B4),
                                    title: Column(
                                      children: [
                                        Image.asset('images/check.png'),
                                        Container(
                                          margin: const EdgeInsets.only(top: 0),
                                          child: const Center(
                                            child: Text(
                                              'Available',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Roboto-Thin',
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 290,
                                          height: 40,
                                          child: Center(
                                            child: Text(
                                              'Click below to Enquire',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Roboto-Thin',
                                                color: Colors.black,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 60.0, right: 60.0, top: 1),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 20),
                                          height: 40,
                                          decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: <Color>[
                                                    Color(0xff7e7e7e),
                                                    Color(0xff7e7e7e)
                                                  ]),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: GestureDetector(
                                            onTap: () async {
                                              // await Enquiry()
                                              //     .sendEnquiry(item.id!,
                                              //         quantityController.text)
                                              //     .then((value) {
                                              //   if (value.status) {
                                              //     Navigator.pop(context);
                                              //     Navigator.pop(context);
                                              //   }
                                              // });
                                              // // showDialog<String>(
                                              // //     context:
                                              // //         context,
                                              // //     builder:
                                              // //         (BuildContext
                                              // //             context) {
                                              // //       return Container();
                                              // //     });
                                            },
                                            child: const Center(
                                              child: Text(
                                                'Enquire',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: 'Roboto-Thin',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 19,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        backgroundColor:
                                            const Color(0xffB4B4B4),
                                        title: Column(
                                          children: [
                                            Image.asset('images/uncheck.png'),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 0),
                                              child: const Center(
                                                child: Text(
                                                  'Unavailable',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Roboto-Thin',
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 290,
                                              height: 40,
                                              child: Center(
                                                child: Text(
                                                  'Click below to Notify',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Roboto-Thin',
                                                    color: Colors.black,
                                                    fontSize: 19,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 60.0,
                                                right: 60.0,
                                                top: 1),
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 20),
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: <Color>[
                                                        Color(0xff7e7e7e),
                                                        Color(0xff7e7e7e)
                                                      ]),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Center(
                                                  child: Text(
                                                    'Notify',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'Roboto-Thin',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 19,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 55.0, right: 55.0, top: 5, bottom: 30),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Color(0xff000000),
                                    // gradient: const LinearGradient(
                                    //     begin: Alignment.topLeft,
                                    //     end: Alignment.bottomRight,
                                    //     colors: <Color>[
                                    //       Color(0xff7e7e7e),
                                    //       Color(0xff7e7e7e)
                                    //     ]),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                  child: Text(
                                    'Check',
                                    style: TextStyle(
                                      color: Colors.black,
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
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 15, right: 15),
                    child: Container(
                      height: 39,
                      decoration: BoxDecoration(
                          color: Color(0xff000000),
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                        child: Text(
                          'Check Availability',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
