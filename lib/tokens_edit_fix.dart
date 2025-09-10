// Add these methods to your _TokenScreenState class in tokens.dart

// 1. Add this method after the refreshTokens() method:

// Edit product in token using the backend API
Future<Map<String, dynamic>> editProductInToken({
  required String tokenId,
  required Map<String, dynamic> oldProduct,
  required Map<String, dynamic> newProduct,
}) async {
  try {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=427siah4dsn3kuq14sveq9kejok1ub57'
    };

    var request = http.Request(
      'POST',
      Uri.parse('https://galactics.co.in/shyamtiles_updated/apis/token/edit-product'),
    );
    
    request.body = json.encode({
      'token_id': tokenId,
      'old_product': oldProduct,
      'new_product': newProduct,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseBody);

    return {
      'success': response.statusCode == 200 && jsonResponse['status'] == 'success',
      'data': jsonResponse,
      'statusCode': response.statusCode,
    };
  } catch (e) {
    print('Error editing product: $e');
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}

// 2. Replace the _showConfirmationDialog method with this:

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
              } else if (action == 'edit' && tokenId != null) {
                // Find the token to edit
                Token? tokenToEdit;
                for (var token in tokens) {
                  if (token.tokenNumber == tokenId.toString()) {
                    tokenToEdit = token;
                    break;
                  }
                }
                if (tokenToEdit != null) {
                  _showEditTokenBottomSheet(context, tokenToEdit);
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

// 3. Add these two new methods:

void _showEditTokenBottomSheet(BuildContext context, Token token) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: token.products.length,
                itemBuilder: (context, index) {
                  final product = token.products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Image.asset(
                        "images/shyamtiles.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product.name),
                      subtitle: Text('Size: ${product.size}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Qty: ${product.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditQuantityDialog(context, token, product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showEditQuantityDialog(BuildContext context, Token token, Product product) {
  final TextEditingController quantityController = TextEditingController(
    text: product.quantity.toString(),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Quantity - ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product: ${product.name}'),
            Text('Size: ${product.size}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              quantityController.dispose();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newQuantity = int.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity > 0) {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Call edit API
                final result = await editProductInToken(
                  tokenId: token.tokenNumber,
                  oldProduct: {
                    'product_name': product.name,
                    'size': product.size,
                    'quantity': product.quantity,
                  },
                  newProduct: {
                    'product_name': product.name,
                    'size': product.size,
                    'quantity': newQuantity,
                  },
                );

                // Close loading dialog
                Navigator.of(context).pop();

                // Close edit dialog
                quantityController.dispose();
                Navigator.of(context).pop();

                if (result['success']) {
                  // Refresh tokens
                  await fetchTokens();
                  
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  // Show error message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${result['data']['message'] ?? 'Failed to update product'}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}
