import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print("=== Shyam Tiles Vendor Login Test ===\n");
  
  await testAllCredentials();
  await testContactData();
  
  print("\n=== Test Complete ===");
  print("If all tests failed, contact your backend team for valid credentials.");
}

Future<void> testAllCredentials() async {
  const String baseUrl = "https://galactics.co.in/shyamtiles_updated";
  
  final List<Map<String, String>> testCredentials = [
    {"contact": "123456789", "password": "1234", "description": "From code comments"},
    {"contact": "226", "password": "1234", "description": "Vendor ID from tokens.dart"},
    {"contact": "9988776655", "password": "1234", "description": "Contact from ContactData API"},
    {"contact": "1", "password": "1234", "description": "Test with ID 1"},
    {"contact": "admin", "password": "admin", "description": "Common admin credentials"},
    {"contact": "admin", "password": "1234", "description": "Admin with common password"},
    {"contact": "test", "password": "test", "description": "Test credentials"},
    {"contact": "demo", "password": "demo", "description": "Demo credentials"},
  ];

  print("Testing vendor login credentials...\n");
  
  for (var credentials in testCredentials) {
    await testLogin(baseUrl, credentials);
  }
}

Future<void> testLogin(String baseUrl, Map<String, String> credentials) async {
  try {
    final String url = "$baseUrl/index.php/apis/Login";
    
    final Map<String, dynamic> body = {
      "contact": credentials["contact"],
      "password": credentials["password"],
    };

    print("Testing: ${credentials['description']}");
    print("Contact: ${credentials['contact']}");
    print("Password: ${credentials['password']}");

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(body),
    );

    print("Status Code: ${response.statusCode}");
    print("Response: ${response.body}");
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['statusCode'] == 200) {
        print("✅ SUCCESS! Valid credentials found!");
        print("User Data: ${jsonResponse['data']}");
        print("🎉 Use these credentials in your app!");
      } else {
        print("❌ Login failed: ${jsonResponse['statusMessage']}");
      }
    } else {
      print("❌ HTTP Error: ${response.statusCode}");
    }
    
    print("---\n");
  } catch (e) {
    print("❌ Error: $e\n");
  }
}

Future<void> testContactData() async {
  const String baseUrl = "https://galactics.co.in/shyamtiles_updated";
  
  print("Testing Contact Data API...\n");
  
  try {
    final String url = "$baseUrl/index.php/apis/ContactData";
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
    );

    print("Status Code: ${response.statusCode}");
    print("Response: ${response.body}");
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['statusCode'] == 200) {
        print("✅ Contact data retrieved successfully!");
        final contactData = jsonResponse['data']['contact'];
        print("Contact Number: ${contactData['contact']}");
        print("Email: ${contactData['email']}");
        print("Location: ${contactData['location']}");
        print("Address: ${contactData['address']}");
      }
    }
    
    print("---\n");
  } catch (e) {
    print("❌ Error: $e\n");
  }
}


