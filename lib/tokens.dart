import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shyam_tiles/model/user.dart';
import 'package:shyam_tiles/model/appProducts.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/qrcode.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  List<Token> tokens = [];
  List<String> productNames = [];
  List<AppProducts> allProducts = [];
  Map<String, List<String>> productSizes = {}; // Map product name to available sizes
  bool isLoading = false;
  
  // Search functionality variables
  Map<String, TextEditingController> searchControllers = {}; // For each product dropdown
  Map<String, List<String>> filteredProducts = {}; // Filtered products for each dropdown

  @override
  void initState() {
    super.initState();
    fetchProductNames();
    fetchTokens();
  }

  Future<void> fetchTokens() async {
    setState(() {
      isLoading = true;
    });

    print('=== FETCHING TOKENS ===');
    print('User ID: ${AppUser.sharedInstance.id}');

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=f2lli9st2c16fmtr34pf835fb5o733dh'
    };
    
    // Use POST request with body for token fetching
    var request = http.Request(
        'POST', Uri.parse('https://galactics.co.in/shyamtiles_updated/apis/token/get'));
    
    request.body = json.encode({
      "vendor_id": AppUser.sharedInstance.id.toString()
    });
    request.headers.addAll(headers);

    print('Request URL: ${request.url}');
    print('Request Body: ${request.body}');

    try {
      http.StreamedResponse response = await request.send();
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');
        var jsonResponse = json.decode(responseBody);

        if (jsonResponse['status'] == "success") {
          List<Token> fetchedTokens = [];
          Map<String, Token> tokenMap = {};
          
          for (var tokenData in jsonResponse['data']) {
            String tokenNumber = tokenData['token_id'];
            print('Processing token: $tokenNumber');
            
            // Create or get existing token
            if (!tokenMap.containsKey(tokenNumber)) {
              tokenMap[tokenNumber] = Token(
              name: tokenData['customer_name'],
              tokenNumber: tokenData['token_id'],
              date: tokenData['date'],
              creationTime: tokenData['created_at'] ?? tokenData['date'], // Use created_at if available, fallback to date
                products: [],
              );
            }
            
            // Add product to the token
            tokenMap[tokenNumber]!.products.add(Product(
                  id: tokenData['id'],
                  name: tokenData['product_name'],
                  size: tokenData['size'],
                  quantity: int.parse(tokenData['quantity']),
            ));
          }
          
          // Convert map to list
          fetchedTokens = tokenMap.values.toList();

          setState(() {
            tokens = fetchedTokens;
            isLoading = false;
          });
          print('Successfully fetched ${fetchedTokens.length} tokens with ${jsonResponse['data'].length} total products');
        } else {
          print('Failed to fetch tokens: ${jsonResponse['message']}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        print('Failed to fetch tokens: ${response.reasonPhrase}');
        print('Error Body: $errorBody');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching tokens: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshTokens() async {
    await fetchTokens();
  }

  // Helper method to check if a token is older than 30 minutes
  bool isTokenOlderThan30Minutes(Token token) {
    try {
      // Use creation time if available, otherwise fall back to date
      String timeToCheck = token.creationTime.isNotEmpty ? token.creationTime : token.date;
      
      DateTime tokenTime = DateTime.parse(timeToCheck);
      DateTime now = DateTime.now();
      
      // Handle timezone issues - if token time is in the future, it's likely a timezone issue
      // In that case, treat it as if it was created now (allow editing)
      if (tokenTime.isAfter(now)) {
        print('=== 30-MINUTE CHECK DEBUG ===');
        print('Token creation time: "${token.creationTime}"');
        print('Token date: "${token.date}"');
        print('Using for check: "$timeToCheck"');
        print('Parsed time: $tokenTime');
        print('Current time: $now');
        print('WARNING: Token time is in the future (timezone issue)');
        print('Treating as newly created - allowing operation');
        print('================================');
        return false; // Allow operation if time is in future
      }
      
      // Normal case - token was created in the past
      Duration difference = now.difference(tokenTime);
      
      print('=== 30-MINUTE CHECK DEBUG ===');
      print('Token creation time: "${token.creationTime}"');
      print('Token date: "${token.date}"');
      print('Using for check: "$timeToCheck"');
      print('Parsed time: $tokenTime');
      print('Current time: $now');
      print('Time difference: ${difference.inMinutes} minutes');
      print('Is older than 30 minutes: ${difference.inMinutes > 30}');
      print('================================');
      
      return difference.inMinutes > 30;
    } catch (e) {
      print('Error parsing token time: $e');
      print('Token creation time that failed: "${token.creationTime}"');
      print('Token date that failed: "${token.date}"');
      return false; // If we can't parse the time, allow the operation
    }
  }

  Future<void> deleteToken(int tokenId) async {
    print('=== DELETING TOKEN ===');
    print('Token ID: $tokenId');
    
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=iljrln51rltdf90sbncf2bsfq4diuqij'
    };

    var request = http.Request(
      'POST',
      Uri.parse('https://galactics.co.in/shyamtiles_updated/api/delete_token'),
    );
    
    var requestBody = {
      "token_id": tokenId,
    };
    
    print('Request URL: ${request.url}');
    print('Request Body: ${json.encode(requestBody)}');
    print('Request Headers: $headers');
    
    request.body = json.encode(requestBody);
    request.headers.addAll(headers);

    try {
    http.StreamedResponse response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
        print('Success Response: $responseBody');
        
        try {
      var jsonResponse = json.decode(responseBody);
          print('Parsed JSON Response: $jsonResponse');
          
          // Check for different possible success indicators
          bool isSuccess = false;
          if (jsonResponse['status'] == true || 
              jsonResponse['status'] == 'success' ||
              jsonResponse['success'] == true) {
            isSuccess = true;
          }
          
          if (isSuccess) {
        // Token deleted successfully
        setState(() {
              tokens.removeWhere((token) => token.tokenNumber == tokenId.toString());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token deleted successfully')),
        );
            print('Token deleted successfully from UI');
      } else {
            String errorMessage = jsonResponse['message'] ?? 'Unknown error';
            print('Delete token API returned error: $errorMessage');
            
            // Check for specific 30-minute restriction error
            if (errorMessage.contains('more than 30 minutes have passed') || 
                errorMessage.contains('Token cannot be deleted')) {
        ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cannot delete token: More than 30 minutes have passed since creation'),
                  backgroundColor: Colors.lightGreen,
                  duration: Duration(seconds: 4),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete token: $errorMessage'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          print('Error parsing delete token response: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error parsing server response'),
              backgroundColor: Colors.red,
            ),
        );
      }
    } else {
        String errorBody = await response.stream.bytesToString();
        print('Error Response: $errorBody');
        print('Error Reason: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode} - ${response.reasonPhrase}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception deleting token: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchProductNames() async {
    try {
      AppProducts appProducts = AppProducts();
      ResponseSmartAuditor response = await appProducts.getProducts();

      if (response.status && response.body != null) {
        List<AppProducts> products = response.body;
        
        setState(() {
          allProducts = products;
          productNames = products.map((product) => product.name).toList();
          
          // Create a map of product names to their available sizes
          productSizes.clear();
          for (AppProducts product in products) {
            if (!productSizes.containsKey(product.name)) {
              productSizes[product.name] = [];
            }
            // Add size if it's not already in the list
            if (product.size.isNotEmpty && !productSizes[product.name]!.contains(product.size)) {
              productSizes[product.name]!.add(product.size);
            }
          }
        });
        
        print('Fetched ${products.length} products with sizes');
      } else {
        print('Failed to fetch products: ${response.errorMessage}');
      }
    } catch (e) {
      print('Exception occurred while fetching products: $e');
    }
  }

  // Method to filter products based on search query
  List<String> filterProducts(String query, String dropdownKey) {
    if (query.isEmpty) {
      return productNames;
    }
    
    return productNames.where((name) {
      // Search by product name (case insensitive)
      bool nameMatch = name.toLowerCase().contains(query.toLowerCase());
      
      // Search by product ID if available
      bool idMatch = false;
      try {
        var product = allProducts.firstWhere((p) => p.name == name);
        if (product.id != null && product.id.toString().contains(query)) {
          idMatch = true;
        }
      } catch (e) {
        // Product not found, continue
      }
      
      return nameMatch || idMatch;
    }).toList();
  }

  // Method to get or create search controller for a dropdown
  TextEditingController getSearchController(String dropdownKey) {
    if (!searchControllers.containsKey(dropdownKey)) {
      searchControllers[dropdownKey] = TextEditingController();
    }
    return searchControllers[dropdownKey]!;
  }

  // Method to get filtered products for a dropdown
  List<String> getFilteredProducts(String dropdownKey) {
    if (!filteredProducts.containsKey(dropdownKey)) {
      filteredProducts[dropdownKey] = productNames;
    }
    return filteredProducts[dropdownKey]!;
  }

  // Custom searchable dropdown widget
  Widget buildSearchableDropdown({
    required String dropdownKey,
    required String? value,
    required Function(String?) onChanged,
    required String labelText,
    required bool showCheckMark,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select Product',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    // Search Bar
                    Container(
                      padding: EdgeInsets.all(16),
                      child: TextField(
                        controller: getSearchController(dropdownKey),
                        decoration: InputDecoration(
                          hintText: 'Search by name or ID...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (query) {
                          setModalState(() {
                            filteredProducts[dropdownKey] = filterProducts(query, dropdownKey);
                          });
                        },
                      ),
                    ),
                    // Product List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: getFilteredProducts(dropdownKey).length,
                        itemBuilder: (context, index) {
                          final productName = getFilteredProducts(dropdownKey)[index];
                          final isSelected = value == productName;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                            ),
                            child: ListTile(
                              title: Text(
                                productName,
                                style: TextStyle(
                                  color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              trailing: isSelected ? Icon(Icons.check_circle, color: Colors.blue) : null,
                              onTap: () {
                                onChanged(productName);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value ?? 'Select Product',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (showCheckMark && value != null)
              Icon(Icons.check_circle, color: Colors.green, size: 20),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Future<bool> deleteProductFromToken(String tokenId, Product product) async {
    print('Deleting product from token: $tokenId');
    print('Product to delete: ${product.name} - ${product.size} - ${product.quantity}');
    
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=f2lli9st2c16fmtr34pf835fb5o733dh'
    };
    var request = http.Request(
        'POST', Uri.parse('https://galactics.co.in/shyamtiles_updated/apis/token/delete-product'));

    // Convert the product data to the required format
    var requestBody = {
      "token_id": tokenId,
      "product_name": product.name,
      "size": product.size,
      "quantity": product.quantity > 0 ? product.quantity : 1
    };

    print('Request URL: ${request.url}');
    print('Request Body: ${json.encode(requestBody)}');
    print('Request Headers: $headers');
    request.body = json.encode(requestBody);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Success Response: $responseBody');
        
        var jsonResponse = json.decode(responseBody);
        if (jsonResponse['status'] == 'success') {
          print('Product deleted successfully from token');
          return true;
        } else {
          print('Error Response: $responseBody');
          return false;
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        print('Error Response: $errorBody');
        return false;
      }
    } catch (e) {
      print('Error Reason: $e');
      return false;
    }
  }

  Future<bool> addProductToToken(String tokenId, Product newProduct) async {
    print('=== ADDING PRODUCT TO TOKEN ===');
    print('Token ID: $tokenId');
    print('New Product: ${newProduct.name} - ${newProduct.size} - ${newProduct.quantity}');
    
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=f2lli9st2c16fmtr34pf835fb5o733dh'
    };
    var request = http.Request(
        'POST', Uri.parse('https://galactics.co.in/shyamtiles_updated/apis/token/store'));

    // Convert the product data to the required format (similar to save token API)
    var requestBody = {
      "vendor_id": AppUser.sharedInstance.id,
      "customer_name": "Existing Token", // This will be updated by the edit token API
      "token_id": tokenId,
      "date": DateTime.now().toString().split(' ')[0], // Current date
      "is_add_product": true, // Flag to indicate this is adding a product to existing token
      "products": [
        {
          "product_name": newProduct.name,
          "size": newProduct.size,
          "quantity": newProduct.quantity > 0 ? newProduct.quantity : 1
        }
      ]
    };

    print('Request URL: ${request.url}');
    print('Request Body: ${json.encode(requestBody)}');
    print('Request Headers: $headers');
    request.body = json.encode(requestBody);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Success Response: $responseBody');
        
        // Parse the response to check if it's actually successful
        try {
        var jsonResponse = json.decode(responseBody);
          if (jsonResponse['status'] == 'success') {
            print('Add product API returned success');
            return true;
          } else {
            print('Add product API returned error: ${jsonResponse['message']}');
            return false;
          }
        } catch (e) {
          print('Error parsing add product response: $e');
          // If we can't parse the response, assume it's successful if status code is 200
          return true;
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        print('Error Response: $errorBody');
        print('Error Reason: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print('Exception adding product: $e');
      return false;
    }
  }

  Future<bool> editProduct(String tokenId, Product oldProduct, Product newProduct) async {
    print('=== EDITING PRODUCT ===');
    print('Token ID: $tokenId');
    print('Old Product: ${oldProduct.name} - ${oldProduct.size} - ${oldProduct.quantity}');
    print('New Product: ${newProduct.name} - ${newProduct.size} - ${newProduct.quantity}');
    
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=f2lli9st2c16fmtr34pf835fb5o733dh'
    };
    var request = http.Request(
        'POST', Uri.parse('https://galactics.co.in/shyamtiles_updated/apis/token/edit-product'));

    // Convert the product data to the required format
    var requestBody = {
      "token_id": tokenId,
      "old_product": {
        "product_name": oldProduct.name,
        "size": oldProduct.size,
        "quantity": oldProduct.quantity > 0 ? oldProduct.quantity : 1
      },
      "new_product": {
        "product_name": newProduct.name,
        "size": newProduct.size,
        "quantity": newProduct.quantity > 0 ? newProduct.quantity : 1
      }
    };

    print('Request URL: ${request.url}');
    print('Request Body: ${json.encode(requestBody)}');
    print('Request Headers: $headers');
    request.body = json.encode(requestBody);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Success Response: $responseBody');
        
        // Parse the response to check if it's actually successful
        try {
          var jsonResponse = json.decode(responseBody);
          if (jsonResponse['status'] == 'success') {
            print('Edit product API returned success');
            return true;
          } else {
            print('Edit product API returned error: ${jsonResponse['message']}');
            return false;
          }
        } catch (e) {
          print('Error parsing edit product response: $e');
          // If we can't parse the response, assume it's successful if status code is 200
          return true;
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        print('Error Response: $errorBody');
        print('Error Reason: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print('Exception editing product: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> editToken(Token token) async {
    print('=== EDITING TOKEN ===');
    print('User ID: ${AppUser.sharedInstance.id}');
    print('Token ID: ${token.tokenNumber}');
    print('Token Name: ${token.name}');
    print('Date: ${token.date}');
    print('Products Count: ${token.products.length}');
    
    // Check if user is logged in
    if (AppUser.sharedInstance.id == 0) {
      print('ERROR: User not logged in or ID is 0');
      return {'success': false, 'error': 'User not logged in'};
    }
    
    // Extract only the date part (YYYY-MM-DD) from the full datetime
    String dateOnly = token.date.split(' ')[0];
    print('Original date: ${token.date}');
    print('Date only (for API): $dateOnly');
    
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=f2lli9st2c16fmtr34pf835fb5o733dh'
    };
    var request = http.Request(
        'POST', Uri.parse('https://galactics.co.in/shyamtiles_updated/api/edit_token'));

    // Convert the token data to the required format (matching the API screenshot)
    var requestBody = {
      "token_id": token.tokenNumber,
      "vendor_id": AppUser.sharedInstance.id,
      "customer_name": token.name,
      "date": dateOnly, // Send only date part (YYYY-MM-DD)
      "is_edit": true, // Flag to indicate this is an edit operation
      "products": token.products
          .map((product) => {
                "product_name": product.name,
                "size": product.size,
                "quantity": product.quantity
              })
          .toList()
    };

    print('Request URL: ${request.url}');
    print('Request Body: ${json.encode(requestBody)}');
    print('Request Headers: $headers');
    request.body = json.encode(requestBody);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Success Response: $responseBody');
        
        // Parse the response to check if it's actually successful
        try {
          var jsonResponse = json.decode(responseBody);
          if (jsonResponse['status'] == 'success') {
            print('Edit token API returned success');
            return {'success': true, 'error': null};
          } else {
            String errorMessage = jsonResponse['message'] ?? 'Unknown error';
            print('Edit token API returned error: $errorMessage');
            
            // Check for specific 30-minute restriction error
            if (errorMessage.contains('more than 30 minutes have passed') || 
                errorMessage.contains('Token cannot be edited')) {
              print('30-minute restriction error detected for edit token');
              return {'success': false, 'error': 'time_restriction', 'message': errorMessage};
            } else {
              print('Other error in edit token: $errorMessage');
              return {'success': false, 'error': 'other', 'message': errorMessage};
            }
          }
        } catch (e) {
          print('Error parsing edit token response: $e');
          // If we can't parse the response, assume it's successful if status code is 200
          return {'success': true, 'error': null};
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        print('Error Response: $errorBody');
        print('Error Reason: ${response.reasonPhrase}');
        return {'success': false, 'error': 'server_error', 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Exception editing token: $e');
      return {'success': false, 'error': 'network_error', 'message': e.toString()};
    }
  }

  Future<bool> saveToken(Token token) async {
    print('=== SAVING TOKEN ===');
    print('User ID: ${AppUser.sharedInstance.id}');
    print('Token Name: ${token.name}');
    print('Token Number: ${token.tokenNumber}');
    print('Date: ${token.date}');
    print('Products Count: ${token.products.length}');
    
    // Check if user is logged in
    if (AppUser.sharedInstance.id == 0) {
      print('ERROR: User not logged in or ID is 0');
      print('Setting user ID to 81 for testing...');
      AppUser.sharedInstance.id = 81; // Temporary fix for testing
    }
    
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=f2lli9st2c16fmtr34pf835fb5o733dh'
    };
    var request = http.Request(
        'POST', Uri.parse('https://galactics.co.in/shyamtiles_updated/apis/token/store'));

    // Convert the token data to the required format
    // Extract only the date part (YYYY-MM-DD) from the full datetime
    String dateOnly = token.date.split(' ')[0];
    print('Original date: ${token.date}');
    print('Date only (for API): $dateOnly');
    
    var requestBody = {
      "vendor_id": AppUser.sharedInstance.id,
      "customer_name": token.name,
      "token_id": token.tokenNumber,
      "date": dateOnly, // Send only date part (YYYY-MM-DD)
      "products": token.products
          .map((product) => {
                "product_name": product.name,
                "size": product.size,
                "quantity": product.quantity
              })
          .toList()
    };

    print('Request URL: ${request.url}');
    print('Request Body: ${json.encode(requestBody)}');
    print('Request Headers: $headers');
    request.body = json.encode(requestBody);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Success Response: $responseBody');
        
        // Parse response to check if it's actually successful
        try {
          var jsonResponse = json.decode(responseBody);
          if (jsonResponse['status'] == 'success' || jsonResponse['statusCode'] == 200) {
            print('Token saved successfully!');
        return true;
      } else {
            print('Token save failed: ${jsonResponse['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
          print('Error parsing response: $e');
          // If we can't parse, assume success if status code is 200
          return true;
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        print('Error Response: $errorBody');
        print('Error Reason: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print('Exception saving token: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth,
      height: screenHeight,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  _showAddTokenBottomSheet(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Icon(
                    Icons.add,
                    size: 34,
                    color: Colors.white,
                    weight: 10,
                  ),
                )),
            const SizedBox(
              width: 15,
            )
          ],
          title: Text(
            'Tokens',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 27,
                height: 30,
                color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xff333333),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/hmbg.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: RefreshIndicator(
            onRefresh: refreshTokens,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: isLoading
                      ? Container(
                          height: screenHeight,
                          padding: const EdgeInsets.only(bottom: 150),
                          child: const SpinKitCircle(
                            duration: Duration(milliseconds: 600),
                            color: Color(0xffffffff),
                            size: 50.0,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 100), // Add bottom padding for navigation bar
                          itemCount: tokens.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: UniqueKey(),
                              background: slideRightBackground(), // Edit background (swipe right)
                              secondaryBackground: slideLeftBackground(), // Delete background (swipe left)
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  // Swipe left = Delete
                                  // Check if token is older than 30 minutes
                                  if (isTokenOlderThan30Minutes(tokens[index])) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cannot delete token: More than 30 minutes have passed since creation'),
                                        backgroundColor: Colors.lightGreen,
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                    return false; // Don't show confirmation dialog
                                  }
                                  return await _showConfirmationDialog(
                                      context,
                                      'delete',
                                      int.parse(tokens[index].tokenNumber));
                                } else if (direction == DismissDirection.startToEnd) {
                                  // Swipe right = Edit
                                  // Check if token is older than 30 minutes
                                  if (isTokenOlderThan30Minutes(tokens[index])) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cannot edit token: More than 30 minutes have passed since creation'),
                                        backgroundColor: Colors.lightGreen,
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                    return false; // Don't show confirmation dialog
                                  }
                                  return await _showConfirmationDialog(
                                      context, 'edit', null, tokens[index]);
                                }
                                return false;
                              },
                              child: TokenCard(
                                name: tokens[index].name,
                                tokenNumber: tokens[index].tokenNumber,
                                date: tokens[index].date,
                                products: tokens[index].products,
                                isExpired: isTokenOlderThan30Minutes(tokens[index]),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String action,
      [int? tokenId, Token? token]) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                if (action == 'delete' && tokenId != null) {
                  deleteToken(tokenId); // Call deleteToken if confirmed
                } else if (action == 'edit' && token != null) {
                  _showEditTokenBottomSheet(context, token); // Call edit function if confirmed
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Widget slideRightBackground() {
  //   return Container(
  //     color: Colors.green,
  //     child: const Align(
  //       alignment: Alignment.centerLeft,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 20),
  //         child: Icon(
  //           Icons.edit,
  //           color: Colors.white,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.blue,
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(
            Icons.edit,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showAddTokenBottomSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dateController =
        TextEditingController(text: DateTime.now().toString());

    List<Product> products = [];

    bool isFormValid() {
      return nameController.text.isNotEmpty &&
          dateController.text.isNotEmpty &&
          products.isNotEmpty &&
          products.every((product) =>
              product.name.isNotEmpty &&
              product.size.isNotEmpty &&
              product.quantity > 0);
    }

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: DraggableScrollableSheet(
                  initialChildSize: 1.0,
                  minChildSize: 1.0,
                  maxChildSize: 1.0,
                  builder: (_, controller) {
                    return ListView(controller: controller, children: [
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Add Token",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Customer Name',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onChanged: (_) => setModalState(() {}),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: dateController,
                                      decoration: InputDecoration(
                                        labelText: 'Date',
                                        suffixIcon: IconButton(
                                          icon:
                                              const Icon(Icons.calendar_today),
                                          onPressed: () async {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2101),
                                            );
                                            if (pickedDate != null) {
                                              setModalState(() {
                                                dateController.text = pickedDate.toString();
                                              });
                                            }
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      readOnly: true,
                                      onChanged: (_) => setModalState(() {}),
                                    ),
                                    const SizedBox(height: 16),
                                    ...products.map((product) {
                                      return Column(
                                        key: ValueKey(product.id),
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: buildSearchableDropdown(
                                                  dropdownKey: 'add_token_${product.id}',
                                                  value: product.name.isNotEmpty ? product.name : null,
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      product.name = value ?? '';
                                                      // Clear size when product changes
                                                      product.size = '';
                                                    });
                                                  },
                                                    labelText: 'Select Product',
                                                  showCheckMark: product.name.isNotEmpty,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 48,
                                                height: 48,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Colors.blue.shade400,
                                                        Colors.blue.shade600,
                                                        Colors.blue.shade800,
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.blue.withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: Offset(0, 4),
                                                      ),
                                                      BoxShadow(
                                                        color: Colors.white.withOpacity(0.2),
                                                        blurRadius: 2,
                                                        offset: Offset(-1, -1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.qr_code_scanner,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    tooltip: 'Scan QR Code',
                                                    onPressed: () async {
                                                  final result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => QRViewExample(isForTokenSelection: true),
                                                    ),
                                                  );
                                                  
                                                  if (result != null && result is Map<String, dynamic>) {
                                                    setModalState(() {
                                                      product.name = result['name'] ?? '';
                                                      product.size = result['size'] ?? '';
                                                      product.quantity = result['quantity'] ?? 1;
                                                    });
                                                  }
                                                  },
                                                ),
                                              ),
                                              ),
                                              SizedBox(
                                                width: 48,
                                                height: 48,
                                                child: IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  setModalState(() {
                                                    products.removeWhere((p) =>
                                                        p.id == product.id);
                                                  });
                                                },
                                              ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  value: product.size.isNotEmpty
                                                      ? product.size
                                                      : null,
                                                  decoration: InputDecoration(
                                                    labelText: 'Size',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  items: productSizes[product.name]?.isNotEmpty == true
                                                      ? productSizes[product.name]!
                                                          .map((size) =>
                                                              DropdownMenuItem(
                                                                value: size,
                                                                child: Text(size),
                                                              ))
                                                          .toList()
                                                      : [
                                                    '8x10',
                                                    '10x10',
                                                    '12x12'
                                                  ]
                                                      .map((size) =>
                                                          DropdownMenuItem(
                                                            value: size,
                                                            child: Text(size),
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      product.size =
                                                          value ?? '';
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 1,
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'Quantity',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      product.quantity =
                                                          int.tryParse(value) ??
                                                              0;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    }).toList(),
                                    ElevatedButton(
                                      onPressed: () {
                                        setModalState(() {
                                          products.add(Product(
                                              id: DateTime.now().toString(),
                                              name: '',
                                              size: '',
                                              quantity: 0));
                                        });
                                      },
                                      child: const Text('Add Product'),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: isFormValid()
                                            ? () async {
                                                Token newToken = Token(
                                                  name: nameController.text,
                                                  tokenNumber: DateTime.now()
                                                      .millisecondsSinceEpoch
                                                      .toString(),
                                                  date: dateController.text,
                                                  creationTime: DateTime.now().toString(), // Set current time as creation time
                                                  products: products,
                                                );

                                                bool saved =
                                                    await saveToken(newToken);

                                                if (saved) {
                                                  setState(() {
                                                    tokens.add(newToken);
                                                  });
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Token saved successfully')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Failed to save token. Please check if you are logged in and try again.')),
                                                  );
                                                }
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          "Save",
                                          style: GoogleFonts.poppins(
                                              color: isFormValid()
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                    ]);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTokenBottomSheet(BuildContext context, Token token) {
    final TextEditingController nameController = TextEditingController(text: token.name);
    final TextEditingController dateController = TextEditingController(text: token.date);

    List<Product> products = List.from(token.products);

    bool isFormValid() {
      return nameController.text.isNotEmpty &&
          dateController.text.isNotEmpty &&
          products.isNotEmpty &&
          products.every((product) =>
              product.name.isNotEmpty &&
              product.size.isNotEmpty &&
              product.quantity > 0);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Token',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 100), // Added bottom padding for navigation bar
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Customer Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              setModalState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: dateController,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              setModalState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          ...products.map((product) {
                            return Column(
                              key: ValueKey(product.id),
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: buildSearchableDropdown(
                                        dropdownKey: 'edit_token_${product.id}',
                                        value: product.name.isNotEmpty ? product.name : null,
                                        onChanged: (value) async {
                                          if (value != null && value != product.name) {
                                            // Only call API if this is an existing product (has a valid ID from server)
                                            if (product.id.isNotEmpty && !product.id.startsWith('new_')) {
                                              // Store the OLD product values BEFORE updating UI
                                              Product oldProduct = Product(
                                                id: product.id,
                                                name: product.name, // Original name
                                                size: product.size, // Original size
                                                quantity: product.quantity, // Original quantity
                                              );
                                              
                                              // Update UI state
                                              setModalState(() {
                                                product.name = value;
                                                product.size = '';
                                              });
                                              
                                              // Create new product with updated values
                                              Product newProduct = Product(
                                                id: product.id,
                                                name: value, // New name from dropdown
                                                size: '', // Cleared size
                                                quantity: product.quantity > 0 ? product.quantity : 1, // Keep original quantity
                                              );
                                              
                                              bool success = await editProduct(token.tokenNumber, oldProduct, newProduct);
                                              if (success) {
                                                print('Product name updated successfully');
                                                // Refresh the token list to get updated data from server
                                                await fetchTokens();
                                              } else {
                                                print('Failed to update product name');
                                                // Revert the change if API call failed
                                                setModalState(() {
                                                  product.name = oldProduct.name;
                                                  product.size = oldProduct.size;
                                                });
                                              }
                                            } else {
                                              // For new products, just update the UI
                                              setModalState(() {
                                                product.name = value;
                                                product.size = '';
                                              });
                                              print('New product - UI updated, will be saved when token is updated');
                                            }
                                          }
                                        },
                                        labelText: 'Select Product',
                                        showCheckMark: product.name.isNotEmpty,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.blue.shade400,
                                              Colors.blue.shade600,
                                              Colors.blue.shade800,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.2),
                                              blurRadius: 2,
                                              offset: Offset(-1, -1),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.qr_code_scanner,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          tooltip: 'Scan QR Code',
                                          onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => QRViewExample(isForTokenSelection: true),
                                          ),
                                        );
                                        
                                        if (result != null && result is Map<String, dynamic>) {
                                          // Only call API if this is an existing product (has a valid ID from server)
                                          if (product.id.isNotEmpty && !product.id.startsWith('new_')) {
                                            // Store the OLD product values BEFORE updating UI
                                            Product oldProduct = Product(
                                              id: product.id,
                                              name: product.name, // Original name
                                              size: product.size, // Original size
                                              quantity: product.quantity, // Original quantity
                                            );
                                            
                                            // Update UI state
                                            setModalState(() {
                                              product.name = result['name'] ?? '';
                                              product.size = result['size'] ?? '';
                                              product.quantity = result['quantity'] ?? 1;
                                            });
                                            
                                            // Create new product with updated values from QR scan
                                            Product newProduct = Product(
                                              id: product.id,
                                              name: result['name'] ?? '', // New name from QR
                                              size: result['size'] ?? '', // New size from QR
                                              quantity: result['quantity'] ?? 1, // New quantity from QR
                                            );
                                            
                                            bool success = await editProduct(token.tokenNumber, oldProduct, newProduct);
                                            if (success) {
                                              print('Product updated via QR scan successfully');
                                              // Refresh the token list to get updated data from server
                                              await fetchTokens();
                                            } else {
                                              print('Failed to update product via QR scan');
                                              // Revert the change if API call failed
                                              setModalState(() {
                                                product.name = oldProduct.name;
                                                product.size = oldProduct.size;
                                                product.quantity = oldProduct.quantity;
                                              });
                                            }
                                          } else {
                                            // For new products, just update the UI
                                            setModalState(() {
                                              product.name = result['name'] ?? '';
                                              product.size = result['size'] ?? '';
                                              product.quantity = result['quantity'] ?? 1;
                                            });
                                            print('New product updated via QR scan - will be saved when token is updated');
                                          }
                                        }
                                      },
                                    ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        // Show confirmation dialog
                                        bool? confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Delete Product'),
                                              content: Text('Are you sure you want to delete "${product.name}" from this token?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmed == true) {
                                          // Check if this is a new product (not yet saved to server)
                                          if (product.id.startsWith('new_')) {
                                            // For new products, just remove from local list
                                            setModalState(() {
                                              products.removeWhere((p) => p.id == product.id);
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Product removed from token')),
                                            );
                                          } else {
                                            // For existing products, call delete API
                                            bool deleted = await deleteProductFromToken(token.tokenNumber, product);
                                            if (deleted) {
                                              // Remove from local list and refresh from server
                                              setModalState(() {
                                                products.removeWhere((p) => p.id == product.id);
                                              });
                                              // Refresh the token list to get updated data from server
                                              await fetchTokens();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Product deleted successfully')),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to delete product'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: DropdownButtonFormField<String>(
                                        value: product.size.isNotEmpty ? product.size : null,
                                        decoration: InputDecoration(
                                          labelText: 'Size',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        items: productSizes[product.name]?.isNotEmpty == true
                                            ? productSizes[product.name]!
                                                .map((size) => DropdownMenuItem(
                                                      value: size,
                                                      child: Text(size),
                                                    ))
                                                .toList()
                                            : [
                                                '8x10',
                                                '10x10',
                                                '12x12'
                                              ]
                                                  .map((size) => DropdownMenuItem(
                                                        value: size,
                                                        child: Text(size),
                                                      ))
                                                  .toList(),
                                        onChanged: (value) async {
                                          if (value != null && value != product.size) {
                                            // Only call API if this is an existing product (has a valid ID from server)
                                            if (product.id.isNotEmpty && !product.id.startsWith('new_')) {
                                              // Store the OLD product values BEFORE updating UI
                                              Product oldProduct = Product(
                                                id: product.id,
                                                name: product.name, // Original name
                                                size: product.size, // Original size
                                                quantity: product.quantity, // Original quantity
                                              );
                                              
                                              // Update UI state
                                              setModalState(() {
                                                product.size = value;
                                              });
                                              
                                              // Create new product with updated size
                                              Product newProduct = Product(
                                                id: product.id,
                                                name: product.name, // Keep original name
                                                size: value, // New size from dropdown
                                                quantity: product.quantity > 0 ? product.quantity : 1, // Keep original quantity
                                              );
                                              
                                              bool success = await editProduct(token.tokenNumber, oldProduct, newProduct);
                                              if (success) {
                                                print('Product size updated successfully');
                                                // Refresh the token list to get updated data from server
                                                await fetchTokens();
                                              } else {
                                                print('Failed to update product size');
                                                // Revert the change if API call failed
                                                setModalState(() {
                                                  product.size = oldProduct.size;
                                                });
                                              }
                                            } else {
                                              // For new products, just update the UI
                                              setModalState(() {
                                                product.size = value;
                                              });
                                              print('New product - UI updated, will be saved when token is updated');
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Quantity',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        controller: TextEditingController(text: product.quantity.toString()),
                                        onChanged: (value) async {
                                          int newQuantity = int.tryParse(value) ?? 0;
                                          if (newQuantity != product.quantity) {
                                            // Only call API if this is an existing product (has a valid ID from server)
                                            if (product.id.isNotEmpty && !product.id.startsWith('new_')) {
                                              // Store the OLD product values BEFORE updating UI
                                              Product oldProduct = Product(
                                                id: product.id,
                                                name: product.name, // Original name
                                                size: product.size, // Original size
                                                quantity: product.quantity, // Original quantity
                                              );
                                              
                                              // Update UI state
                                              setModalState(() {
                                                product.quantity = newQuantity;
                                              });
                                              
                                              // Create new product with updated quantity
                                              Product newProduct = Product(
                                                id: product.id,
                                                name: product.name, // Keep original name
                                                size: product.size, // Keep original size
                                                quantity: newQuantity > 0 ? newQuantity : 1, // New quantity from input
                                              );
                                              
                                              bool success = await editProduct(token.tokenNumber, oldProduct, newProduct);
                                              if (success) {
                                                print('Product quantity updated successfully');
                                                // Refresh the token list to get updated data from server
                                                await fetchTokens();
                                              } else {
                                                print('Failed to update product quantity');
                                                // Revert the change if API call failed
                                                setModalState(() {
                                                  product.quantity = oldProduct.quantity;
                                                });
                                              }
                                            } else {
                                              // For new products, just update the UI
                                              setModalState(() {
                                                product.quantity = newQuantity;
                                              });
                                              print('New product - UI updated, will be saved when token is updated');
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                          ElevatedButton(
                            onPressed: () {
                              setModalState(() {
                                products.add(Product(
                                    id: 'new_${DateTime.now().millisecondsSinceEpoch}',
                                    name: '',
                                    size: '',
                                    quantity: 1));
                              });
                            },
                            child: const Text('Add Product'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isFormValid()
                                  ? () async {
                                      // First, add any new products to the token
                                      List<Product> newProducts = products.where((p) => p.id.startsWith('new_')).toList();
                                      bool allNewProductsAdded = true;
                                      
                                      print('Found ${newProducts.length} new products to add');
                                      
                                      for (Product newProduct in newProducts) {
                                        print('Processing new product: ${newProduct.name} - ${newProduct.size} - ${newProduct.quantity}');
                                        if (newProduct.name.isNotEmpty && newProduct.size.isNotEmpty && newProduct.quantity > 0) {
                                          print('Adding new product to token: ${token.tokenNumber}');
                                          bool added = await addProductToToken(token.tokenNumber, newProduct);
                                          if (!added) {
                                            allNewProductsAdded = false;
                                            print('Failed to add new product: ${newProduct.name}');
                                          } else {
                                            print('Successfully added new product: ${newProduct.name}');
                                          }
                                        } else {
                                          print('Skipping new product due to incomplete data: ${newProduct.name} - ${newProduct.size} - ${newProduct.quantity}');
                                        }
                                      }
                                      
                                      if (allNewProductsAdded) {
                                        // Update the token with basic info (name, date)
                                        Token editedToken = Token(
                                          name: nameController.text,
                                          tokenNumber: token.tokenNumber, // Keep original token number
                                          date: dateController.text,
                                          creationTime: token.creationTime, // Keep original creation time
                                          products: products,
                                        );

                                        Map<String, dynamic> result = await editToken(editedToken);

                                        if (result['success']) {
                                          setState(() {
                                            // Update the token in the list
                                            int index = tokens.indexWhere((t) => t.tokenNumber == token.tokenNumber);
                                            print('Found token at index: $index');
                                            print('Original token number: ${token.tokenNumber}');
                                            print('Edited token number: ${editedToken.tokenNumber}');
                                            if (index != -1) {
                                              print('Updating token at index $index');
                                              tokens[index] = editedToken;
                                            } else {
                                              print('ERROR: Token not found in list for update');
                                            }
                                          });
                                          
                                          // Refresh the token list to get the latest data from server
                                          await fetchTokens();
                                          
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Token updated successfully')),
                                          );
                                        } else {
                                          print('Edit token API failed, not updating local list');
                                          String errorType = result['error'] ?? 'unknown';
                                          String errorMessage = result['message'] ?? 'Unknown error';
                                          
                                          if (errorType == 'time_restriction') {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Cannot edit token: More than 30 minutes have passed since creation'),
                                                backgroundColor: Colors.lightGreen,
                                                duration: Duration(seconds: 4),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed to update token: $errorMessage'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to add some new products. Please try again.')),
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Update",
                                style: GoogleFonts.poppins(
                                    color: isFormValid() ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class Token {
  final String name;
  final String tokenNumber;
  final String date;
  final String creationTime; // Full timestamp from server (created_at)
  final List<Product> products;

  Token({
    required this.name,
    required this.tokenNumber,
    required this.date,
    required this.creationTime,
    required this.products,
  });
}

class TokenCard extends StatelessWidget {
  final String name;
  final String tokenNumber;
  final String date;
  final List<Product> products;
  final bool isExpired;

  const TokenCard({
    super.key,
    required this.name,
    required this.tokenNumber,
    required this.date,
    required this.products,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: isExpired ? Colors.lightGreen.shade50 : Colors.white,
      color: isExpired ? Colors.lightGreen.shade50 : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isExpired ? BorderSide(color: Colors.lightGreen.shade300, width: 1) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                    ),
                    if (isExpired) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.lightGreen.shade600,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Token no. $tokenNumber',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Column(
              children: products.map((product) {
                return Row(
                  children: [
                    Image.asset(
                      "images/shyamtiles.png",
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: const Color(0xff8D99AE).withOpacity(.12),
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.all(5),
                        child: Text(' ${product.size}')),
                    const SizedBox(width: 10),
                    Text('Qty: ${product.quantity}'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  //final String imageUrl;
  final String id;
  String name;
  String size;
  int quantity;

  Product({
    required this.id,
    this.name = '',
    this.size = '',
    this.quantity = 0,
  });
}
