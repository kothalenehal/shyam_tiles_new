import 'dart:convert';

class ResponseSmartAuditor {
  bool status = false;
  String errorMessage = "Something went wrong";
  String statusMessage = "";
  dynamic body;

  ResponseSmartAuditor({
    this.status = false,
    this.errorMessage = "Something went wrong",
    this.statusMessage = "",
    this.body,
  });

  void dictToObject(String strResponse) {
    try {
      dynamic json = jsonDecode(strResponse);
      print("Parsed JSON: $json");

      if (json is Map<String, dynamic>) {
        if (json.containsKey('status') && json.containsKey('data')) {
          // New API format
          status = json['status'] == 'success';
          body = json['data'];
          statusMessage = json['status'];
          errorMessage = status ? "" : (json['message'] ?? "Unknown error");
        } else if (json.containsKey('statusCode')) {
          // Old API format
          int statusCode = json["statusCode"];
          if (statusCode == 200) {
            status = true;
            statusMessage = json["statusMessage"] ?? "";
            body = json["data"];
          } else {
            status = false;
            statusMessage = json["statusMessage"] ?? "";
            errorMessage = json["statusMessage"] ?? "Unknown error";
          }
        } else {
          throw FormatException("Unexpected JSON structure");
        }
      } else {
        throw FormatException("Response is not a JSON object");
      }
    } catch (e) {
      print("Error parsing JSON: $e");
      status = false;
      errorMessage = "Error parsing JSON: $e";
    }
  }
}
