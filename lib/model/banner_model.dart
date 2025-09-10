import 'package:shyam_tiles/common/request.dart';
import 'package:shyam_tiles/model/appProducts.dart';
import 'package:shyam_tiles/model/user.dart';
import 'package:vibration/vibration.dart';

import '../common/api_constant.dart';
import '../common/reponse.dart';

class AppBanners {
  var image = "";

  void dictToObject(json) {
    if (json['image'] is String) {
      this.image =
          '${APIConstant.baseUrl}/public/uploads/banner/thumb_front/${json['image']}';
    }
  }

  Future<ResponseSmartAuditor> getBanners() async {
    try {
      final String url = APIConstant.appBanners;

      // Fetch user's location
      String userLocation = AppUser.sharedInstance.location;

      final Map<String, dynamic> body = {
        "location": userLocation // Include user's location
      };

      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }
}

class AppGallery {
  var image = "";
  var location = "";
  var instagramUrl = "";

  void dictToObject(json) {
    if (json['image'] is String) {
      image =
          '${APIConstant.baseUrl}/public/uploads/gallery/thumb_front/${json['image']}';
    }

    if (json['location'] is String) {
      location = json['location'];
    }

    if (json['instagram_url'] is String) {
      instagramUrl = json['instagram_url'];
    }
  }

  Future<ResponseSmartAuditor> getGallery() async {
    try {
      final String url = APIConstant.appGallery;

      // Fetch user's location
      String userLocation = AppUser.sharedInstance.location;

      final Map<String, dynamic> body = {
        "location": userLocation // Include user's location
      };

      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }
}

class WishList {
  List<AppProducts> products = [];

  void dictToObject(json) {
    print(json);
  }

  Future<ResponseSmartAuditor> removeFromWishList(int prodId) async {
    try {
      final String url = APIConstant.removeFromWishList;

      final Map<String, dynamic> body = {
        "uid": AppUser.sharedInstance.id,
        "prod_id": prodId
      };

      Vibration.hasVibrator().then((value) {
        Vibration.vibrate();
      });

      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }

  Future<ResponseSmartAuditor> addToWishList(int prodId) async {
    try {
      final String url = APIConstant.addWishList;

      final Map<String, dynamic> body = {
        "uid": AppUser.sharedInstance.id,
        "prod_id": prodId
      };
      Vibration.hasVibrator().then((value) {
        Vibration.vibrate();
      });

      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }

  Future<ResponseSmartAuditor> getWishlist() async {
    try {
      final String url = APIConstant.getWishList;

      final Map<String, dynamic> body = {"uid": AppUser.sharedInstance.id};
      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }
}

class Enquiry {
  Future<ResponseSmartAuditor> sendEnquiry(
      int prodId, var qty, bool checkAllLocations) async {
    try {
      final String url = APIConstant.sendEnquiry;

      final Map<String, dynamic> body = {
        "uid": AppUser.sharedInstance.id,
        "prod_id": prodId,
        "qty": qty
      };
      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }
}

class Booking {
  Future<ResponseSmartAuditor> sendEnquiry(int prodId, var qty) async {
    try {
      final String url = APIConstant.sendBookings;

      final Map<String, dynamic> body = {
        "uid": AppUser.sharedInstance.id,
        "prod_id": prodId,
        "qty": qty
      };
      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }
}
