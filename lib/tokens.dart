import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shyam_tiles/model/user.dart';
import 'package:shyam_tiles/qrcode.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  List<Token> tokens = [];
  List<String> productNames = [];
  bool isLoading = false;

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

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=f2lli9st2c16fmtr34pf835fb5o733dh'
    };
    var request = http.Request(
        'GET', Uri.parse('https://galactics.co.in/shyamtiles_updated/apis/token/get?vendor_id=${AppUser.sharedInstance.id}'));
    request.headers.addAll(headers);

    try {
      print('Token API Request - URL: ${request.url}');
      print('Token API Request - Vendor ID: ${AppUser.sharedInstance.id}');
      
      http.StreamedResponse response = await request.send();

      print('Token API Response - Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Token API Response - Body: $responseBody');
        var jsonResponse = json.decode(responseBody);

        if (jsonResponse['status'] == "success") {
          // Group products by token_id and customer_name
          Map<String, Token> tokenMap = {};
          
          for (var tokenData in jsonResponse['data']) {
            // Only process non-deleted tokens
            if (tokenData['is_deleted'] == "0" && tokenData['deleted_at'] == null) {
              String tokenKey = '${tokenData['token_id']}_${tokenData['customer_name']}';
              
              if (tokenMap.containsKey(tokenKey)) {
                // Add product to existing token
                tokenMap[tokenKey]!.products.add(Product(
                  id: tokenData['id'],
                  name: tokenData['product_name'],
                  size: tokenData['size'],
                  quantity: int.parse(tokenData['quantity']),
                ));
              } else {
                // Create new token
                tokenMap[tokenKey] = Token(
                  name: tokenData['customer_name'],
                  tokenNumber: tokenData['token_id'],
                  date: tokenData['date'],
                  products: [
                    Product(
                      id: tokenData['id'],
                      name: tokenData['product_name'],
                      size: tokenData['size'],
                      quantity: int.parse(tokenData['quantity']),
                    )
                  ],
                );
              }
            }
          }
          
          List<Token> fetchedTokens = tokenMap.values.toList();
          
          print('Token API - Total entries: ${jsonResponse['data'].length}');
          print('Token API - Active tokens: ${fetchedTokens.length}');
          print('Token API - Tokens filtered out (deleted): ${jsonResponse['data'].length - fetchedTokens.length}');

          setState(() {
            tokens = fetchedTokens;
            isLoading = false;
          });
        } else {
          print('Failed to fetch tokens: ${jsonResponse['message']}');
          print('Token API Response Status: ${jsonResponse['status']}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch tokens: ${response.reasonPhrase}');
        print('Token API Response Status Code: ${response.statusCode}');
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

  Future<void> deleteToken(int tokenId) async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=427siah4dsn3kuq14sveq9kejok1ub57'
    };

    var request = http.Request(
      'POST',
      Uri.parse('https://galactics.co.in/shyamtiles_updated/api/delete_token'),
    );
    request.body = json.encode({
      "token_id": tokenId,
    });
    request.headers.addAll(headers);

    print('Delete Token API Request - URL: ${request.url}');
    print('Delete Token API Request - Body: ${request.body}');
    print('Delete Token API Request - Token ID: $tokenId');

    try {
      http.StreamedResponse response = await request.send();

      print('Delete Token API Response - Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Delete Token API Response - Body: $responseBody');
        var jsonResponse = json.decode(responseBody);
        
        if (jsonResponse['status'] == true || jsonResponse['status'] == "success") {
          // Token deleted successfully
          setState(() {
            tokens.removeWhere((token) => token.tokenNumber == tokenId.toString());
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token deleted successfully')),
          );
        } else {
          print('Delete Token API Error: ${jsonResponse['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete token: ${jsonResponse['message'] ?? 'Unknown error'}')),
          );
        }
      } else {
        print('Delete Token API Error: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete token: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      print('Error deleting token: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting token: $e')),
      );
    }
  }

  Future<void> fetchProductNames() async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=hf8j8cr99f4lnftihourp6bqktqd22ji'
    };
    var request = http.Request(
        'POST', Uri.parse('https://galactics.co.in/shyamtiles_updated/apis/product_names'));

    // Add location to the request body
    request.body = json.encode({"location": AppUser.sharedInstance.location});

    request.headers.addAll(headers);

    try {
      print('Product Names API Request - URL: ${request.url}');
      print('Product Names API Request - Body: ${request.body}');
      print('Product Names API Request - Location: ${AppUser.sharedInstance.location}');
      
      http.StreamedResponse response = await request.send();

      print('Product Names API Response - Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Product Names API Response - Body: $responseBody');
        var jsonResponse = json.decode(responseBody);
        if (jsonResponse['status'] == true) {
          setState(() {
            productNames = List<String>.from(jsonResponse['data']
                .where((item) =>
                    item['locations'] == AppUser.sharedInstance.location)
                .map((item) => item['name']));
          });
          print('Product Names API - Loaded ${productNames.length} products');
        } else {
          print('Product Names API Error: ${jsonResponse['message']}');
        }
      } else {
        print('Product Names API Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Product Names API Exception: $e');
    }
  }

  Future<bool> saveToken(Token token) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://galactics.co.in/shyamtiles_updated/index.php/api/token/store'));

    // Convert the token data to the required format
    var requestBody = {
      "vendor_id": AppUser.sharedInstance.id,
      "customer_name": token.name,
      "token_id": token.tokenNumber,
      "date": token.date,
      "products": token.products
          .map((product) => {
                "product_name": product.name,
                "size": product.size,
                "quantity": product.quantity
              })
          .toList()
    };

    request.body = json.encode(requestBody);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print(responseBody);
        return true;
      } else {
        print(response.reasonPhrase);
        return false;
      }
    } catch (e) {
      print('Error saving token: $e');
      return false;
    }
  }

  Future<bool> editToken(Token token) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://galactics.co.in/shyamtiles_updated/api/edit_token'));

    // For single product edit (current implementation)
    var requestBody = {
      "token_id": token.tokenNumber,
      "customer_name": token.name,
      "date": token.date,
      "vendor_id": AppUser.sharedInstance.id,
      "product_id": token.products.isNotEmpty ? token.products.first.id : null,
      "product_name": token.products.isNotEmpty ? token.products.first.name : "",
      "size": token.products.isNotEmpty ? token.products.first.size : "",
      "quantity": token.products.isNotEmpty ? token.products.first.quantity : 0
    };

    print('Edit Token API Request - URL: ${request.url}');
    print('Edit Token API Request - Body: ${json.encode(requestBody)}');

    request.body = json.encode(requestBody);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      print('Edit Token API Response - Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Edit Token API Response - Body: $responseBody');
        var jsonResponse = json.decode(responseBody);
        
        if (jsonResponse['status'] == "success" || jsonResponse['status'] == true) {
          return true;
        } else {
          print('Edit Token API Error: ${jsonResponse['message']}');
          return false;
        }
      } else {
        print('Edit Token API Error: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print('Error editing token: $e');
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
                          itemCount: tokens.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: UniqueKey(),
                              background: slideLeftBackground(),
                              secondaryBackground: slideLeftBackground(),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  return await _showConfirmationDialog(
                                      context,
                                      'delete',
                                      int.parse(tokens[index].tokenNumber));
                                } else {
                                  return await _showConfirmationDialog(
                                      context, 'edit');
                                }
                              },
                              child: TokenCard(
                                name: tokens[index].name,
                                tokenNumber: tokens[index].tokenNumber,
                                date: tokens[index].date,
                                products: tokens[index].products,
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
      [int? tokenId]) {
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
                } else if (action == 'edit') {
                  // Find the token to edit
                  Token? tokenToEdit = tokens.firstWhere(
                    (token) => token.tokenNumber == tokenId.toString(),
                    orElse: () => throw Exception('Token not found'),
                  );
                  _showEditTokenBottomSheet(context, tokenToEdit);
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

  void _showEditTokenBottomSheet(BuildContext context, Token tokenToEdit) {
    final TextEditingController nameController = TextEditingController(text: tokenToEdit.name);
    final TextEditingController dateController = TextEditingController(text: tokenToEdit.date);

    // For single product edit, take the first product
    Product productToEdit = tokenToEdit.products.isNotEmpty ? tokenToEdit.products.first : Product(id: '', name: '', size: '', quantity: 0);

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
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: DraggableScrollableSheet(
                  initialChildSize: 1.0,
                  minChildSize: 0.5,
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
                                          "Edit Token",
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
                                                dateController.text = pickedDate
                                                    .toString()
                                                    .split(' ')[0];
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
                                    ),
                                    const SizedBox(height: 16),
                                    // Product details (single product for now)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            value: productToEdit.name.isNotEmpty
                                                ? productToEdit.name
                                                : null,
                                            decoration: InputDecoration(
                                              labelText: 'Select Product',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            items: productNames
                                                .map((name) =>
                                                    DropdownMenuItem(
                                                      value: name,
                                                      child: Text(name),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              setModalState(() {
                                                productToEdit.name = value ?? '';
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // Open QR scanner for token selection
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => QRViewExample(isForTokenSelection: true),
                                                ),
                                              );
                                              
                                              if (result != null) {
                                                setModalState(() {
                                                  // Create a new Product instance with updated data
                                                  productToEdit = Product(
                                                    id: result['id'] ?? productToEdit.id,
                                                    name: result['name'] ?? productToEdit.name,
                                                    size: result['size'] ?? productToEdit.size,
                                                    quantity: int.tryParse(result['quantity']?.toString() ?? '1') ?? productToEdit.quantity,
                                                  );
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: const Icon(Icons.qr_code_scanner, size: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            value: productToEdit.size.isNotEmpty
                                                ? productToEdit.size
                                                : null,
                                            decoration: InputDecoration(
                                              labelText: 'Size',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            items: [
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
                                                productToEdit.size = value ?? '';
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            keyboardType:
                                                TextInputType.number,
                                            controller: TextEditingController(text: productToEdit.quantity.toString()),
                                            decoration: InputDecoration(
                                              labelText: 'Quantity',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setModalState(() {
                                                productToEdit.quantity =
                                                    int.tryParse(value) ?? 0;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              // Open QR scanner for token selection
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => QRViewExample(isForTokenSelection: true),
                                                ),
                                              );
                                              
                                              if (result != null) {
                                                setModalState(() {
                                                  // Create a new Product instance with updated data
                                                  productToEdit = Product(
                                                    id: result['id'] ?? productToEdit.id,
                                                    name: result['name'] ?? productToEdit.name,
                                                    size: result['size'] ?? productToEdit.size,
                                                    quantity: int.tryParse(result['quantity']?.toString() ?? '1') ?? productToEdit.quantity,
                                                  );
                                                });
                                              }
                                            },
                                            icon: const Icon(Icons.qr_code_scanner),
                                            label: const Text('Scan QR'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // Create updated token
                                          Token updatedToken = Token(
                                            name: nameController.text,
                                            tokenNumber: tokenToEdit.tokenNumber,
                                            date: dateController.text,
                                            products: [productToEdit],
                                          );

                                          bool edited = await editToken(updatedToken);

                                          if (edited) {
                                            // Update the token in the list
                                            setState(() {
                                              int index = tokens.indexWhere(
                                                (token) => token.tokenNumber == tokenToEdit.tokenNumber
                                              );
                                              if (index != -1) {
                                                tokens[index] = updatedToken;
                                              }
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Token updated successfully')),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Failed to update token')),
                                            );
                                          }
                                        },
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
                                          "Update Token",
                                          style: GoogleFonts.poppins(
                                              color: Colors.white),
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

  void _showAddTokenBottomSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dateController =
        TextEditingController(text: DateTime.now().toString().split(' ')[0]);

    List<Product> products = [];
    
    // Fetch product names when opening the bottom sheet
    fetchProductNames();

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
                                                dateController.text = pickedDate
                                                    .toString()
                                                    .split(' ')[0];
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
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  value: product.name.isNotEmpty
                                                      ? product.name
                                                      : null,
                                                  decoration: InputDecoration(
                                                    labelText: 'Select Product',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  items: productNames
                                                      .map((name) =>
                                                          DropdownMenuItem(
                                                            value: name,
                                                            child: Text(name),
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      product.name =
                                                          value ?? '';
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    // Open QR scanner for token selection
                                                    final result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => QRViewExample(isForTokenSelection: true),
                                                      ),
                                                    );
                                                    
                                                    if (result != null) {
                                                      setModalState(() {
                                                        product.name = result['name'] ?? product.name;
                                                        product.size = result['size'] ?? product.size;
                                                        product.quantity = int.tryParse(result['quantity']?.toString() ?? '1') ?? product.quantity;
                                                      });
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: Size.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                  ),
                                                  child: const Icon(Icons.qr_code_scanner, size: 16),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: IconButton(
                                                  onPressed: () {
                                                    setModalState(() {
                                                      products.removeWhere((p) =>
                                                          p.id == product.id);
                                                    });
                                                  },
                                                  icon: const Icon(Icons.delete, color: Colors.grey, size: 16),
                                                  style: IconButton.styleFrom(
                                                    backgroundColor: Colors.grey.shade200,
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: Size.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
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
                                                  items: [
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
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
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              // Open QR scanner for token selection
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => QRViewExample(isForTokenSelection: true),
                                                ),
                                              );
                                              
                                              if (result != null) {
                                                setModalState(() {
                                                  products.add(Product(
                                                    id: result['id'] ?? DateTime.now().toString(),
                                                    name: result['name'] ?? '',
                                                    size: result['size'] ?? '',
                                                    quantity: int.tryParse(result['quantity']?.toString() ?? '1') ?? 1,
                                                  ));
                                                });
                                              }
                                            },
                                            icon: const Icon(Icons.qr_code_scanner),
                                            label: const Text('Scan QR'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                                            'Failed to save token')),
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
}

class Token {
  final String name;
  final String tokenNumber;
  final String date;
  final List<Product> products;

  Token({
    required this.name,
    required this.tokenNumber,
    required this.date,
    required this.products,
  });
}

class TokenCard extends StatelessWidget {
  final String name;
  final String tokenNumber;
  final String date;
  final List<Product> products;

  const TokenCard({
    super.key,
    required this.name,
    required this.tokenNumber,
    required this.date,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
