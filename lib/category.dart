import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/model/category_model.dart';
import 'package:shyam_tiles/products_under_category.dart';

class CategoryScreen extends StatefulWidget {
  final Function setTab;
  CategoryScreen(this.setTab);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<AppCategories> categoriesList = [];
  bool showNoCategoriesMessage = false;

  void fetchCategories() async {
    categoriesList.clear();
    AppCategories appCategories = AppCategories();

    ResponseSmartAuditor responseSmartAuditor =
        await appCategories.getCategories();

    if (responseSmartAuditor.status) {
      var appCategoriesList = responseSmartAuditor.body;
      if (appCategoriesList != null && appCategoriesList is List<dynamic>) {
        setState(() {
          for (Map<String, dynamic> dict in appCategoriesList) {
            appCategories = AppCategories();
            appCategories.dictToObject(dict);
            categoriesList.add(appCategories);
          }
        });
      }
    } else {}
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      if (categoriesList.isEmpty) {
        setState(() {
          showNoCategoriesMessage = true;
        });
      }
    });
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (categoriesList.isEmpty) {
      return Container(
        height: screenHeight,
        padding: const EdgeInsets.only(bottom: 150),
        child: showNoCategoriesMessage
            ? Center(
                child: Text(
                  "No categories available",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : const SpinKitCircle(
                duration: Duration(milliseconds: 600),
                color: Color(0xffffffff),
                size: 50.0,
              ),
      );
    }

    int crossAxisCount = screenWidth < 600 ? 2 : 3;
    double imageHeight = screenWidth < 380
        ? MediaQuery.of(context).size.height * .19
        : MediaQuery.of(context).size.height * .2;
    double fontSize = screenWidth < 600 ? 17 : 20;

    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/hmbg.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Categories',
                    style: GoogleFonts.notoSerif(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Adjust based on screen width
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: .9, // Adjust height relative to width
              ),
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    var Name = categoriesList[index].name;
                    var id = categoriesList[index].id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductsUnderCategory(Name, id),
                      ),
                    );
                  },
                  child: buildCategory(
                      categoriesList[index], imageHeight, fontSize),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategory(
      AppCategories product, double imageHeight, double fontSize) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            height: imageHeight,
            width: MediaQuery.of(context).size.width / 2,
            child: Image.network(
              product.image,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          height: 25,
          width: double.infinity, // Use full width of grid cell
          color: Colors.white.withOpacity(.6),
          child: Center(
            child: Text(
              product.name.trim(),
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                letterSpacing: .1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
