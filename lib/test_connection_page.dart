import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestConnectionPage extends StatefulWidget {
  const TestConnectionPage({super.key});

  @override
  State<TestConnectionPage> createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  String _status = 'Not tested';
  String _details = '';
  bool _testing = false;

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _status = 'Testing...';
      _details = '';
    });

    try {
      // Test 1: Basic connectivity
      final baseUrl = 'http://192.168.5.145:8000';

      setState(() {
        _details = 'Step 1: Testing basic connectivity to $baseUrl\n';
      });

      // Try to connect to Laravel server root
      final rootResponse = await http.get(
        Uri.parse(baseUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 5));

      setState(() {
        _details += '✓ Server reachable! Status: ${rootResponse.statusCode}\n\n';
      });

      // Test 2: API endpoint
      setState(() {
        _details += 'Step 2: Testing API endpoint\n';
      });

      final apiUrl = Uri.parse('$baseUrl/api/assetData').replace(queryParameters: {
        'qr_code': 'TEST_CONNECTION',
      });

      setState(() {
        _details += 'URL: $apiUrl\n';
      });

      final apiResponse = await http.get(
        apiUrl,
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 5));

      setState(() {
        _details += '✓ API endpoint responded! Status: ${apiResponse.statusCode}\n';
        _details += 'Response: ${apiResponse.body}\n\n';
      });

      if (apiResponse.statusCode == 200 || apiResponse.statusCode == 404) {
        setState(() {
          _status = '✅ SUCCESS! API is connected!';
          _details += '\nYour API is working correctly!\n';
          _details += '404 is OK - it just means the test QR code doesn\'t exist in your database.\n';
          _details += '\nYou can now scan real QR codes!';
        });
      } else {
        setState(() {
          _status = '⚠️ API responded but with unexpected status';
          _details += '\nGot status ${apiResponse.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ CONNECTION FAILED';
        _details += '\nError: $e\n\n';
        _details += 'Troubleshooting:\n';
        _details += '1. Is Laravel running with: php artisan serve --host=0.0.0.0 --port=8000\n';
        _details += '2. Are phone and computer on same WiFi?\n';
        _details += '3. Computer IP: 192.168.5.145\n';
        _details += '4. Windows Firewall blocking port 8000?\n';
      });
    } finally {
      setState(() {
        _testing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test API Connection'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('API URL: http://192.168.5.145:8000/api/assetData'),
                    SizedBox(height: 4),
                    Text('Computer IP: 192.168.5.145'),
                    SizedBox(height: 4),
                    Text('Port: 8000'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testing ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: _testing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Testing...'),
                      ],
                    )
                  : Text('Test Connection', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
            Text(
              'Status:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _status,
              style: TextStyle(
                fontSize: 18,
                color: _status.contains('SUCCESS')
                    ? Colors.green
                    : _status.contains('FAILED')
                        ? Colors.red
                        : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Details:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _details.isEmpty ? 'Press "Test Connection" to start' : _details,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
