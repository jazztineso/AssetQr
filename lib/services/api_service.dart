import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asset.dart';

class ApiService {
  // Laravel API base URL
  // Using local network IP for testing on physical device
  // Computer IP: 192.168.5.145 (make sure phone and computer are on same WiFi)
  static const String baseUrl = 'http://192.168.5.145:8000/api';

  /// Fetch asset data from Laravel API by scanning QR code
  static Future<Map<String, dynamic>> fetchAssetData(String qrCode) async {
    print('\n========== LARAVEL API REQUEST ==========');
    print('QR Code Scanned: "$qrCode"');
    print('QR Code Length: ${qrCode.length}');
    print('Base URL: $baseUrl');
    print('Full URL: $baseUrl/assetData');
    print('Request Time: ${DateTime.now()}');

    try {
      // Using GET method with query parameter (as Laravel expects)
      final url = Uri.parse('$baseUrl/assetData').replace(queryParameters: {
        'qr_code': qrCode,
      });

      print('\n--- GET Request Details ---');
      print('URL: $url');
      print('Method: GET');
      print('Query Parameter: qr_code=$qrCode');
      print('Sending request...');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          print('✗ Request timeout after 15 seconds');
          throw Exception('Request timeout - Laravel server not responding');
        },
      );

      print('\n========== LARAVEL API RESPONSE ==========');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('Response Body Length: ${response.body.length}');
      print('Response Time: ${DateTime.now()}');

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          print('✓ JSON decoded successfully');
          print('Response Type: ${jsonData.runtimeType}');

          // Laravel usually returns: { "data": {...} } or { "success": true, "data": {...} }
          final assetData = _extractAssetDataFromLaravel(jsonData);

          if (assetData != null) {
            print('✓ Asset data extracted successfully');
            print('Asset data keys: ${assetData.keys.toList()}');
            print('Asset ID: ${assetData['id'] ?? assetData['asset_id']}');
            print('Asset Name: ${assetData['name']}');
            print('Full asset data: $assetData');

            return {
              'success': true,
              'data': assetData,
              'message': 'Asset found successfully',
            };
          } else {
            print('✗ Could not extract asset data from response');
            print('Response structure: ${jsonData.toString()}');
            print('JSON keys: ${jsonData is Map ? jsonData.keys.toList() : 'Not a map'}');

            return {
              'success': false,
              'data': null,
              'message': 'Invalid response format. Expected asset data but got: ${jsonData.runtimeType}',
            };
          }
        } catch (e) {
          print('✗ JSON parsing error: $e');
          print('Raw response: ${response.body}');

          return {
            'success': false,
            'data': null,
            'message': 'Failed to parse Laravel API response: $e',
          };
        }
      } else if (response.statusCode == 404) {
        print('✗ Asset not found (404)');

        // Try to get error message from Laravel
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? 'Asset not found';

          return {
            'success': false,
            'data': null,
            'message': message,
          };
        } catch (e) {
          return {
            'success': false,
            'data': null,
            'message': 'Asset not found in database',
          };
        }
      } else if (response.statusCode == 500) {
        print('✗ Laravel server error (500)');
        print('This usually means there\'s an error in your Laravel controller');

        try {
          final errorData = jsonDecode(response.body);
          print('Error details: $errorData');
        } catch (e) {
          print('Could not parse error response');
        }

        return {
          'success': false,
          'data': null,
          'message': 'Laravel server error. Check your Laravel logs.',
        };
      } else if (response.statusCode == 422) {
        print('✗ Validation error (422)');

        try {
          final errorData = jsonDecode(response.body);
          print('Validation errors: $errorData');

          return {
            'success': false,
            'data': null,
            'message': 'Validation failed: ${errorData['message'] ?? 'Invalid data'}',
          };
        } catch (e) {
          return {
            'success': false,
            'data': null,
            'message': 'Validation failed',
          };
        }
      } else {
        print('✗ Unexpected status code: ${response.statusCode}');
        print('Response: ${response.body}');

        return {
          'success': false,
          'data': null,
          'message': 'Unexpected response from Laravel API (${response.statusCode})',
        };
      }
    } catch (e) {
      print('\n========== REQUEST FAILED ==========');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');

      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('No address associated with hostname')) {
        return {
          'success': false,
          'data': null,
          'message': 'Cannot reach Laravel server. Check IP address: $baseUrl',
        };
      } else if (e.toString().contains('timeout')) {
        return {
          'success': false,
          'data': null,
          'message': 'Laravel server timeout. Is your server running?',
        };
      } else if (e.toString().contains('Connection refused')) {
        return {
          'success': false,
          'data': null,
          'message': 'Connection refused. Is Laravel running on port 8000?',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': 'Network error: $e',
        };
      }
    }
  }

  /// Extract asset data from Laravel response formats
  /// Laravel typically returns: { "data": {...} } or { "success": true, "data": {...} }
  static Map<String, dynamic>? _extractAssetDataFromLaravel(dynamic jsonData) {
    print('\n--- Extracting Asset Data ---');
    print('jsonData type: ${jsonData.runtimeType}');
    print('jsonData is Map: ${jsonData is Map<String, dynamic>}');
    if (jsonData is Map) {
      print('Keys in response: ${jsonData.keys.toList()}');
    }

    if (jsonData == null) {
      print('✗ jsonData is null');
      return null;
    }

    // Format 1: Laravel Resource - { "data": {...} }
    if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
      print('✓ Found "data" key in response');
      final data = jsonData['data'];
      print('data type: ${data.runtimeType}');
      print('data is Map: ${data is Map<String, dynamic>}');

      if (data is Map<String, dynamic>) {
        print('Keys in data: ${data.keys.toList()}');
        print('data contains id: ${data.containsKey('id')}');

        if (data.containsKey('id')) {
          print('✓ Format detected: Laravel Resource (data wrapper)');
          return data;
        } else {
          print('✗ data does not contain "id" key');
        }
      }

      // Sometimes data is an array with single item
      if (data is List && data.isNotEmpty) {
        final first = data[0];
        if (first is Map<String, dynamic> && first.containsKey('id')) {
          print('Format detected: Laravel Resource Collection (data array)');
          return first;
        }
      }
    }

    // Format 2: Direct object - { "id": "...", "name": "...", ... }
    if (jsonData is Map<String, dynamic> && jsonData.containsKey('id')) {
      print('Format detected: Direct JSON object');
      return jsonData;
    }

    // Format 3: Custom Laravel response - { "success": true, "data": {...} }
    if (jsonData is Map<String, dynamic> &&
        jsonData.containsKey('success') &&
        jsonData.containsKey('data')) {
      final data = jsonData['data'];
      if (data is Map<String, dynamic> && data.containsKey('id')) {
        print('Format detected: Custom Laravel response');
        return data;
      }
    }

    // Format 4: Array - [{ "id": "...", ... }]
    if (jsonData is List && jsonData.isNotEmpty) {
      final first = jsonData[0];
      if (first is Map<String, dynamic> && first.containsKey('id')) {
        print('Format detected: JSON array (using first item)');
        return first;
      }
    }

    print('✗ Unknown response format');
    print('Available keys: ${jsonData is Map ? (jsonData as Map).keys : "Not a map"}');
    return null;
  }
}
