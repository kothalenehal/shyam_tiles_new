import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shyam_tiles/model/user.dart';

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
        'GET', Uri.parse('http://16.171.177.96/index.php/api/token/get'));
    request.body = json.encode({
      "vendor_id": "226" // Make sure this matches the correct vendor ID
    });
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);

        if (jsonResponse['status'] == "success") {
          List<Token> fetchedTokens = [];
          for (var tokenData in jsonResponse['data']) {
            fetchedTokens.add(Token(
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
            ));
          }

          setState(() {
            tokens = fetchedTokens;
            isLoading = false;
          });
        } else {
          print('Failed to fetch tokens: ${jsonResponse['message']}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch tokens: ${response.reasonPhrase}');
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
      Uri.parse('http://16.171.177.96/index.php/api/delete_token'),
    );
    request.body = json.encode({
      "token_id": tokenId,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      if (jsonResponse['status'] == true) {
        // Token deleted successfully
        setState(() {
          tokens
              .removeWhere((token) => token.tokenNumber == tokenId.toString());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete token')),
        );
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> fetchProductNames() async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=hf8j8cr99f4lnftihourp6bqktqd22ji'
    };
    var request = http.Request(
        'POST', Uri.parse('http://16.171.177.96/index.php/api/product_names'));

    // Add location to the request body
    request.body = json.encode({"location": AppUser.sharedInstance.location});

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        if (jsonResponse['status'] == true) {
          setState(() {
            productNames = List<String>.from(jsonResponse['data']
                .where((item) =>
                    item['locations'] == AppUser.sharedInstance.location)
                .map((item) => item['name']));
          });
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<bool> saveToken(Token token) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('http://16.171.177.96/index.php/api/token/store'));

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

  void _showAddTokenBottomSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dateController =
        TextEditingController(text: DateTime.now().toString().split(' ')[0]);

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
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  setModalState(() {
                                                    products.removeWhere((p) =>
                                                        p.id == product.id);
                                                  });
                                                },
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
