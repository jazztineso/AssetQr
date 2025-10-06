import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'providers/asset_provider.dart';
import 'asset_details.dart';
import 'services/api_service.dart';
import 'models/asset.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture, BuildContext context) async {
    if (_isProcessing) return;

    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() {
      _isProcessing = true;
    });

    final qrCode = barcode.rawValue!;
    final assetProvider = Provider.of<AssetProvider>(context, listen: false);

    controller.stop();

    // Extract asset_id or property_code from QR code if it's JSON
    String searchValue = qrCode;

    print('\n========== PROCESSING QR CODE ==========');
    print('Raw QR Code: $qrCode');
    print('QR Code Type: ${qrCode.runtimeType}');

    try {
      final qrData = jsonDecode(qrCode) as Map<String, dynamic>;
      print('✓ QR code is valid JSON');
      print('QR JSON data: $qrData');
      print('Available keys: ${qrData.keys.toList()}');

      // Laravel searches: asset_id, property_code, and qr_code_data
      // Use property_code as it's more specific and unique
      final propertyCode = qrData['property_code'] as String?;
      final assetId = qrData['asset_id'];

      print('property_code from QR: $propertyCode');
      print('asset_id from QR: $assetId');

      // Prioritize property_code as it's unique and more reliable
      searchValue = propertyCode ??
                   qrData['propertyCode'] as String? ??
                   assetId?.toString() ??
                   qrCode;

      print('✓ Extracted search value: "$searchValue"');
      print('This will be sent to Laravel as: /api/assetData?qr_code=$searchValue');
    } catch (e, stackTrace) {
      // QR code is not JSON, use as-is
      print('✗ JSON parsing failed: $e');
      print('Stack trace: $stackTrace');
      print('Using raw QR code value: $qrCode');
    }
    print('========================================\n');

    // Show what we extracted (for debugging)
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Extracted value: $searchValue'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );

    await Future.delayed(Duration(seconds: 2));

    // Show loading indicator
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
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
            Text('Fetching asset data from API...'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 30),
      ),
    );

    // Fetch asset data from API using the extracted search value
    final result = await ApiService.fetchAssetData(searchValue);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    print('\n========== QR SCANNER RESULT ==========');
    print('Search value sent to API: $searchValue');
    print('Result: $result');
    print('Success: ${result['success']}');
    print('Data: ${result['data']}');
    print('Message: ${result['message']}');
    print('======================================\n');

    if (result['success'] == true && result['data'] != null) {
      // Parse asset from result
      final Asset fetchedAsset = Asset.fromJson(result['data']);

      // Asset found from API, save it to database
      try {
        await assetProvider.addAsset(fetchedAsset);

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Asset saved successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate to asset details page
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetDetails(asset: fetchedAsset),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        // Error saving to database
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Error saving asset: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        await Future.delayed(Duration(seconds: 2));
        controller.start();
        setState(() {
          _isProcessing = false;
        });
      }
    } else {
      // Asset not found in API
      if (!mounted) return;

      final errorMessage = result['message'] ?? 'Asset not found in API: $qrCode';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(errorMessage),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      await Future.delayed(Duration(seconds: 3));
      controller.start();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text("Scan QR Code"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_off),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner View
          MobileScanner(
            controller: controller,
            onDetect: (barcodeCapture) => _onDetect(barcodeCapture, context),
          ),

          // Overlay with scanning frame
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Card(
                color: Colors.black.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                      SizedBox(height: 12),
                      Text(
                        "Position QR code within the frame",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "The scanner will automatically detect the code",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Calculate frame dimensions
    final frameSize = size.width * 0.7;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;
    final right = left + frameSize;
    final bottom = top + frameSize;

    // Draw dark overlay
    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final innerRect = Rect.fromLTRB(left, top, right, bottom);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(outerRect),
        Path()..addRect(innerRect),
      ),
      backgroundPaint,
    );

    // Draw frame corners
    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Top-right corner
    canvas.drawLine(Offset(right, top), Offset(right - cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLength), cornerPaint);

    // Bottom-left corner
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), cornerPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - cornerLength), cornerPaint);

    // Bottom-right corner
    canvas.drawLine(Offset(right, bottom), Offset(right - cornerLength, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
