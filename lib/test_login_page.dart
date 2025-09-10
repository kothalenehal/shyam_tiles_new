import 'package:flutter/material.dart';
import 'vendor_test.dart';

class TestLoginPage extends StatefulWidget {
  const TestLoginPage({Key? key}) : super(key: key);

  @override
  _TestLoginPageState createState() => _TestLoginPageState();
}

class _TestLoginPageState extends State<TestLoginPage> {
  String _testResults = "";
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Login Test'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isTesting ? null : _runTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isTesting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Test All Credentials',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isTesting ? null : _testContactData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Test Contact Data API',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'No tests run yet...' : _testResults,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isTesting = true;
      _testResults = "";
    });

    try {
      // Capture console output
      final results = await _captureOutput(() async {
        await VendorTest.testAllCredentials();
      });

      setState(() {
        _testResults = results;
      });
    } catch (e) {
      setState(() {
        _testResults = "Error running tests: $e";
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testContactData() async {
    setState(() {
      _isTesting = true;
      _testResults = "";
    });

    try {
      final results = await _captureOutput(() async {
        await VendorTest.testContactData();
      });

      setState(() {
        _testResults = results;
      });
    } catch (e) {
      setState(() {
        _testResults = "Error testing contact data: $e";
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<String> _captureOutput(Function testFunction) async {
    // This is a simplified version - in a real app you'd want to capture console output
    // For now, we'll just run the test and return a message
    await testFunction();
    return "Tests completed. Check the console output for detailed results.\n\n"
           "If all tests failed, you need to:\n"
           "1. Check with your backend team for valid vendor credentials\n"
           "2. Verify the vendor table structure in the database\n"
           "3. Ensure the login API is working correctly";
  }
}


