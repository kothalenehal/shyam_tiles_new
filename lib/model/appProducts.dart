import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shyam_tiles/common/request.dart';
import 'package:shyam_tiles/model/user.dart';
import 'package:shyam_tiles/qrcode.dart';
import '../common/api_constant.dart';
import '../common/reponse.dart';
import '../shared_preference.dart';
import '../common/app_constant.dart';

class AppProducts {
  int? id;
  bool filterVisible = true;
  var name = "";
  List<String> image = [];
  var pdf = "";
  var description = "";
  var quantity = 0;
  var size = "";
  var batch = "";
  var status = 0;
  var bestprice_deal = 0;
  var trending = 0;
  var latest_product = 0;
  String? category; // New field
  String? locations; // New field
  String createdAt = "";
  String updatedAt = "";
  String visibility = "";

  void dictToObject(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    name = json['name']?.toString() ?? "";

    image.clear();
    if (json['image'] != null &&
        json['image'] is String &&
        json['image'] != "") {
      var imageSep = json["image"].toString().split(",");
      for (var img in imageSep) {
        image.add(
            '${APIConstant.baseUrl}/public/uploads/all_products/thumb_front/$img');
      }
    }

    quantity = json['quantity'] != null
        ? int.tryParse(json['quantity'].toString()) ?? 0
        : 0;
    size = json['size']?.toString() ?? "";
    batch = json['batch']?.toString() ?? "";
    status = json['status'] != null
        ? int.tryParse(json['status'].toString()) ?? 0
        : 0;
    bestprice_deal = json['bestprice_deal'] != null
        ? int.tryParse(json['bestprice_deal'].toString()) ?? 0
        : 0;
    trending = json['trending'] != null
        ? int.tryParse(json['trending'].toString()) ?? 0
        : 0;
    latest_product = json['latest_product'] != null
        ? int.tryParse(json['latest_product'].toString()) ?? 0
        : 0;

    category = json['category']?.toString();
    locations = json['locations']?.toString();

    createdAt = json['created_at']?.toString() ?? "";
    updatedAt = json['updated_at']?.toString() ?? "";
    visibility = json['visibility']?.toString() ?? "";
  }

  Future<ResponseSmartAuditor> getProductsByCat(String category,
      {int page = 0, int perPage = 0, String? location}) async {
    try {
      final String url = APIConstant.appProducts;

      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'ci_session=vo6oejguc6mfvhmru7pf9keqf2quge8p'
      };

      final Map<String, dynamic> body = {
        "category": category,
        "page": page,
        "per_page": perPage,
        "locations": location ?? AppUser.sharedInstance.location
      };

      var request = http.Request('POST', Uri.parse(url));
      request.body = json.encode(body);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        List<AppProducts> products = [];
        if (jsonResponse['data'] != null) {
          for (var item in jsonResponse['data']) {
            if (item['locations'] ==
                (location ?? AppUser.sharedInstance.location)) {
              AppProducts product = AppProducts();
              product.dictToObject(item);
              products.add(product);
            }
          }
        }

        return ResponseSmartAuditor()
          ..status = true
          ..statusMessage = "Success"
          ..body = products;
      } else {
        return ResponseSmartAuditor()
          ..status = false
          ..statusMessage = "Error"
          ..errorMessage = response.reasonPhrase ?? "Unknown error";
      }
    } catch (e) {
      print(e);
      return ResponseSmartAuditor()
        ..status = false
        ..statusMessage = "Exception"
        ..errorMessage = e.toString();
    }
  }

  Future<ResponseSmartAuditor> searchProducts(var qry) async {
    try {
      final String url = APIConstant.appProducts;

      final Map<String, dynamic> body = {
        "search": qry,
      };
      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }

  Future<ResponseSmartAuditor> getProducts() async {
    try {
      final String url = 'http://16.171.177.96/index.php/apis/getProducts';

      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'ci_session=vo6oejguc6mfvhmru7pf9keqf2quge8p'
      };

      final Map<String, dynamic> body = {
        "location": AppUser.sharedInstance.location
      };

      var request = http.Request('POST', Uri.parse(url));
      request.body = json.encode(body);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        List<AppProducts> products = [];
        if (jsonResponse['data'] != null) {
          for (var item in jsonResponse['data']) {
            if (item['locations'] == AppUser.sharedInstance.location) {
              AppProducts product = AppProducts();
              product.dictToObject(item);
              products.add(product);
            }
          }
        }

        return ResponseSmartAuditor()
          ..status = true
          ..statusMessage = "Success"
          ..body = products;
      } else {
        return ResponseSmartAuditor()
          ..status = false
          ..statusMessage = "Error"
          ..errorMessage = response.reasonPhrase!;
      }
    } catch (e) {
      print(e);
      return ResponseSmartAuditor()
        ..status = false
        ..statusMessage = "Exception"
        ..errorMessage = e.toString();
    }
  }

  Future<ResponseSmartAuditor> getProductById(String productId) async {
    try {
      final String url =
          "http://16.171.177.96/index.php/api/product/$productId";
      print("Calling API: $url");

      final ResponseSmartAuditor response =
          await Request.sharedInstance.getRequest(url);

      print("Response status: ${response.status}");
      print("Response statusMessage: ${response.statusMessage}");
      print("Response errorMessage: ${response.errorMessage}");
      print("Response body: ${response.body}");

      return response;
    } catch (e, stackTrace) {
      print("Error in getProductById: $e");
      print("Stack trace: $stackTrace");
      return ResponseSmartAuditor()
        ..status = false
        ..statusMessage = "Exception occurred"
        ..errorMessage = e.toString();
    }
  }

  // QR Code Scanner Functionality
  Future<void> scanQRCode(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRViewExample()),
    );
  }
}
