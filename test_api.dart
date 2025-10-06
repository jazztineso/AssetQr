import 'package:http/http.dart' as http;
import 'dart:convert';

/// Simple test script to check Laravel API connectivity
/// Run this with: dart run test_api.dart
void main() async {
  print('Testing Laravel API Connection...\n');

  final baseUrl = 'http://192.168.5.145:8000/api';
  final testQrCode = 'TEST123'; // Change this to match a QR code in your database

  print('Target URL: $baseUrl/assetData');
  print('Test QR Code: $testQrCode');
  print('Request Body: ${jsonEncode({'qr_code': testQrCode})}\n');

  try {
    final url = Uri.parse('$baseUrl/assetData').replace(queryParameters: {
      'qr_code': testQrCode,
    });

    print('Sending GET request...');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 10));

    print('\n========== RESPONSE ==========');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    print('==============================\n');

    if (response.statusCode == 200) {
      print('✓ SUCCESS! Connection is working!');
      final data = jsonDecode(response.body);
      print('Response data: $data');
    } else {
      print('✗ Got response but status code is ${response.statusCode}');
      print('This might be normal if the QR code doesn\'t exist in your database');
    }
  } catch (e) {
    print('\n✗ ERROR: $e');
    print('\nPossible issues:');
    print('1. Laravel not running');
    print('2. Laravel not accessible at 192.168.5.145:8000');
    print('3. Phone and computer not on same WiFi');
    print('4. Laravel needs to run with: php artisan serve --host=0.0.0.0');
  }
}
