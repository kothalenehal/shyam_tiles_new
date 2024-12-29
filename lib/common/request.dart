import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'reponse.dart';

class SendImage {
  var key = "";
  File file = File("");
}

class Request {
  static final sharedInstance = Request();

  String version = "";

  Future<Map<String, String>> getHeaderParam() async {
    Map<String, String> header = {};
    header["Content-Type"] = "application/json";
    print("header: $header");
    return header;
  }

  Future<ResponseSmartAuditor> postRequest(
      Map<String, dynamic> requestDict, String requestURL) async {
    try {
      print("request body $requestDict");
      print("url $requestURL");
      Map<String, String> headerParam = await getHeaderParam();

      Uri url = Uri.parse(requestURL);
      http.Response response = await http.post(url,
          headers: headerParam,
          body: json.encode(requestDict),
          encoding: Encoding.getByName("utf-8"));

      final ResponseSmartAuditor objResponse = ResponseSmartAuditor();
      print("request body $requestDict");
      print("url $requestURL");

      objResponse.dictToObject(response.body.toString());
      return objResponse;
    } catch (e) {
      print(e);
      print("request body $requestDict");
      print("url $requestURL");
      final ResponseSmartAuditor objResponse = ResponseSmartAuditor();
      objResponse.errorMessage = e.toString();
      objResponse.status = false;
      return objResponse;
    } finally {}
  }

  Future<ResponseSmartAuditor> getRequest(String requestURL) async {
    try {
      print("url $requestURL");
      Map<String, String> headerParam = await getHeaderParam();

      // Add the Cookie header
      headerParam['Cookie'] = 'ci_session=gal346jsj7e89noj7vb4ebg7bvu5dpmi';

      Uri url = Uri.parse(requestURL);
      var request = http.Request('GET', url);
      request.headers.addAll(headerParam);

      http.StreamedResponse response = await request.send();

      print("Response status code: ${response.statusCode}");

      final ResponseSmartAuditor objResponse = ResponseSmartAuditor();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        objResponse.dictToObject(responseBody);
      } else {
        objResponse.status = false;
        objResponse.statusMessage = "HTTP Error: ${response.statusCode}";
        objResponse.errorMessage = response.reasonPhrase!;
      }

      return objResponse;
    } catch (e, stackTrace) {
      print("Error in getRequest: $e");
      print("Stack trace: $stackTrace");
      final ResponseSmartAuditor objResponse = ResponseSmartAuditor();
      objResponse.errorMessage = e.toString();
      objResponse.status = false;
      return objResponse;
    }
  }

  String getYoutubeThumbnail(String videoUrl) {
    final Uri uri = Uri.parse(videoUrl);
    if (uri == null) {
      return "";
    }

    return 'https://img.youtube.com/vi/${uri.queryParameters['v']}/0.jpg';
  }

  Future<void> multipartPostRequestWithMultipalImage1(
      Map<String, String> requestDict,
      List<SendImage> imagesArray,
      String requestURL,
      Function(ResponseSmartAuditor) onCompletion) async {
    Map<String, String> headerParam = await getHeaderParam();

    try {
      print("request body $requestDict");
      print("url $requestURL");

      HttpClient httpClient = new HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      IOClient ioClient = new IOClient(httpClient);

      var request = http.MultipartRequest("POST", Uri.parse(requestURL));
      request.fields.addAll(requestDict);

      for (SendImage image in imagesArray) {
        print("selected Image Path: " + image.file.path);

        var multipartFile =
            http.MultipartFile.fromPath(image.key, image.file.path);
        request.files.add(await multipartFile);
      }
      request.headers.addAll(headerParam);

      var response = await ioClient.send(request);

      var isResponseReceived = false;
      response.stream.transform(utf8.decoder).listen((data) {
        isResponseReceived = true;
        print("listen");
        print("url $requestURL");
        final ResponseSmartAuditor objResponse = ResponseSmartAuditor();
        objResponse.dictToObject(data.toString());
        onCompletion(objResponse);
      }, onDone: () {
        if (!isResponseReceived) {
          final ResponseSmartAuditor objResponse = ResponseSmartAuditor();
          objResponse.status = true;
          onCompletion(objResponse);
          print("isResponseReceived >> onDone");
        }
        print("onDone");
      }, onError: (error) {
        print(error);
        print("error");
        isResponseReceived = true;
        final ResponseSmartAuditor objResponse = ResponseSmartAuditor();
        objResponse.errorMessage = error.toString();
        objResponse.status = false;
        onCompletion(objResponse);
      });
    } catch (e) {
      print("catch");
      print("request body $requestDict");
      print("url $requestURL");
      print(e);
      final ResponseSmartAuditor objResponse = ResponseSmartAuditor();
      objResponse.errorMessage = e.toString();
      objResponse.status = false;
      onCompletion(objResponse);
    } finally {}
  }
}
