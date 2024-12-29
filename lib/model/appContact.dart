import 'package:shyam_tiles/common/api_constant.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/common/request.dart';
import 'package:shyam_tiles/model/user.dart';

class AppContact {
  var address = "";
  var email = "";
  var contact = "";

  void dictToObject(json) {
    if (json['address'] is String) {
      address = json['address'];
    }
    if (json['email'] is String) {
      email = json['email'];
    }
    if (json['contact'] is int) {
      contact = json['contact'].toString();
    } else if (json['contact'] is String) {
      contact = json['contact'];
    }
  }

  Future<ResponseSmartAuditor> getContact() async {
    try {
      final String url = APIConstant.appContact;

      // Fetch user's location
      String userLocation = AppUser.sharedInstance.location;

      final Map<String, dynamic> body = {
        "location": userLocation // Include user's location
      };

      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      return ResponseSmartAuditor();
    }
  }
}

class AppSettings {
  var key = "";
  var value = "";
  void dictToObject(json) {
    //print(json);
    if (json['s_key'] is String) {
      key = json['s_key'];
    }
    if (json['s_value'] is String) {
      value = json['s_value'];
    }
  }
}
