import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shyam_tiles/model/appProducts.dart';
import 'product_details.dart';

class QRViewExample extends StatefulWidget {
  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool isScanning = false; // Flag to manage scanning state
  bool hasScanned = false; // New flag to track if a scan has been processed

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrController?.pauseCamera();
    }
    qrController?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          if (isScanning)
            Center(
              child: CircularProgressIndicator(), // Show loading indicator
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrController = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      if (!hasScanned && !isScanning) {
        setState(() {
          isScanning = true;
          hasScanned = true; // Set this to true immediately
        });

        final url = scanData.code.toString();
        print("QR code scanned: $url");

        final productId = _extractProductIdFromUrl(url);

        if (productId != null) {
          print("Extracted Product ID: $productId");
          await _fetchProductDetails(productId);
        } else {
          print("Invalid URL format: $url");
          _resetScanState();
        }
      }
    });
  }

  void _resetScanState() {
    setState(() {
      isScanning = false;
      hasScanned = false;
    });
  }

  String? _extractProductIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      print("URL Path Segments: $segments");
      print("Segments Length: ${segments.length}");

      // Case 1: [..., 'view', <product_id>]
      if (segments.length >= 2 &&
          segments[segments.length - 2] == 'view' &&
          int.tryParse(segments.last) != null) {
        String productId = segments.last;
        print("Product ID found (view): $productId");
        return productId;
      }

      // Case 2: [..., 'api', 'product', <product_id>]
      else if (segments.length >= 3 &&
          segments[segments.length - 3] == 'api' &&
          segments[segments.length - 2] == 'product' &&
          int.tryParse(segments.last) != null) {
        String productId = segments.last;
        print("Product ID found (api/product): $productId");
        return productId;
      } else {
        print("Expected URL structure not found");
      }
    } catch (e) {
      print("Error parsing URL: $e");
    }
    return null;
  }

  // String? _extractProductIdFromUrl(String url) {
  //   try {
  //     final uri = Uri.parse(url);
  //     final segments = uri.pathSegments;

  //     print("URL Path Segments: $segments");
  //     print("Segments Length: ${segments.length}");
  //     print("Second to Last Segment: ${segments[segments.length - 2]}");

  //     // Ensure there are at least four segments and the second to last segment is 'product'
  //     if (segments.length >= 4 && segments[segments.length - 2] == 'product') {
  //       print("this is correct ${segments.last}");
  //       return segments.last; // Return the last segment as the product ID
  //     } else {
  //       print("Condition not met. Segments: $segments");
  //     }
  //   } catch (e) {
  //     print("Error parsing URL: $e");
  //   }
  //   return null;
  // }

  Future<void> _fetchProductDetails(String productId) async {
    try {
      final product = AppProducts();
      print("Fetching product details for ID: $productId");

      final response = await product.getProductById(productId);

      print("_fetchProductDetails received response:");
      print("Status: ${response.status}");
      print("StatusMessage: ${response.statusMessage}");
      print("ErrorMessage: ${response.errorMessage}");
      print("Body: ${response.body}");

      if (response.status && response.body != null) {
        Map<String, dynamic> productData = response.body;
        print("Product data: $productData");
        product.dictToObject(productData);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(product),
          ),
        ).then((_) =>
            _resetScanState()); // Reset state when returning from ProductDetails
      } else {
        String errorMsg = response.statusMessage ?? "Unknown error";
        String detailedError =
            response.errorMessage ?? "No detailed error message";
        print(
            "Failed to fetch product details. Message: $errorMsg, Details: $detailedError");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to load product details: $errorMsg\n$detailedError")),
        );
        _resetScanState();
      }
    } catch (e, stackTrace) {
      print("Error fetching product details: $e");
      print("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
      _resetScanState();
    } finally {
      setState(() {
        isScanning = false;
      });
    }
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }
}
