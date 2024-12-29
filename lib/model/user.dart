import 'dart:io';
import 'package:shyam_tiles/common/request.dart';

import '../common/api_constant.dart';
import '../common/reponse.dart';
import '../shared_preference.dart';
import '../common/app_constant.dart';

class AppUser {
  static final sharedInstance = AppUser();
  //id: 1, name: Bhopal, email: bhopal@gmail.com, password: 1234,
  // vendor_location: Shiroli, contact: 123456789, status: 0,
  // created_at: 2022-09-10 09:45:04, updated_at: 2022-09-23 14:46:45
  int id = 0;
  var email = "";
  var name = "";
  var password = "";
  var location = "";
  var contact = "";
  var status = 0;
  var user_type = 0;

  void dictToObject(json) {
    print(json);
    if (json['id'] is int) {
      this.id = json['id'];
    } else if (json['id'] is String) {
      this.id = int.parse(json['id']);
    }

    if (json['email'] is String) {
      this.email = json['email'];
    }
    if (json['name'] is String) {
      this.name = json['name'];
    }
    if (json['user_type'] is int) {
      this.user_type = json['user_type'];
    } else if (json['user_type'] is String) {
      this.user_type = int.parse(json['user_type']);
    }
    if (json['location'] is String) {
      this.location = json['location'];
    }
    if (json['contact'] is String) {
      this.contact = json['contact'];
    }
    print("User Data fetched");
    print(this.user_type);
    print(this.location);
    //

    if (json['status'] is int) {
      this.status = json['status'];
    } else if (json['status'] is String) {
      this.status = int.parse(json['status']);
    }
  }

  void reSetSharedPrefrence() {}

  Future<bool> getSharedPreferences() async {
    return await SharedPreference.getUserDetailFromPreference();
  }

  Future<void> setUserDetailInSharedInstance() async {
    AppUser.sharedInstance.id = this.id;
    AppUser.sharedInstance.name = this.name;
    AppUser.sharedInstance.contact = this.contact;
    AppUser.sharedInstance.email = this.email;
    AppUser.sharedInstance.location = this.location;
    AppUser.sharedInstance.user_type = this.user_type;

    await SharedPreference.setUserDetailInPreference(AppUser.sharedInstance);
  }

  Future<ResponseSmartAuditor> userLogin() async {
    try {
      final String url = APIConstant.userLogin;

      final Map<String, dynamic> body = {
        "contact": contact,
        "password": password,
      };
      return await Request.sharedInstance.postRequest(body, url);
    } catch (e) {
      print(e);
      return ResponseSmartAuditor();
    }
  }
}
