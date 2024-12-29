import 'dart:io';
import 'package:shyam_tiles/common/request.dart';
import 'package:shyam_tiles/model/user.dart';

import '../common/api_constant.dart';
import '../common/reponse.dart';
import '../shared_preference.dart';
import '../common/app_constant.dart';

class AppCategories {
  int id = 0;
  var name = "";
  var image = "";
  var status = 0;
  var category = "";

  void dictToObject(json) {
    if (json['id'] is int) {
      this.id = json['id'];
    } else if (json['id'] is String) {
      this.id = int.parse(json['id']);
    }

    if (json['name'] is String) {
      this.name = json['name'];
    }
    if (json['image'] is String) {
      this.image =
          '${APIConstant.baseUrl}/public/uploads/category/thumb/${json['image']}';
    }

    if (json['status'] is int) {
      this.status = json['status'];
    } else if (json['status'] is String) {
      this.status = int.parse(json['status']);
    }

    if (json['category'] is String) {
      this.category = json['category'];
    }
  }

  Future<ResponseSmartAuditor> getCategories() async {
    try {
      final String url = APIConstant.productCategories;

      // Fetch user's location
      String userLocation = AppUser.sharedInstance.location;

      final Map<String, dynamic> body = {
        "location": userLocation // Include user's location in the request body
      };

      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }
}
