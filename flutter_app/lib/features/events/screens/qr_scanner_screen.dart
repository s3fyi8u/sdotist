import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/events_service.dart';
import '../../../core/l10n/app_localizations.dart';

class QRScannerScreen extends StatefulWidget {
  final int eventId;

  const QRScannerScreen({super.key, required this.eventId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final EventsService _eventsService = EventsService();
  bool _isProcessing = false;
  
  // Controller to pause/resume camera
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final registration = await _eventsService.verifyAttendance(widget.eventId, code);
      if (mounted) {
        _showResultDialog(
          success: true,
          message: "${registration.user.name}\n${AppLocalizations.of(context).translate('attendance_verified') ?? 'Verified'}",
        );
      }
    } catch (e) {
      if (mounted) {
         // Check if it's already attended or not registered
         // Simplistic error handling
         String errorMessage = e.toString();
         if (errorMessage.contains("404")) {
           errorMessage = AppLocalizations.of(context).translate('user_not_registered') ?? 'Not Registered';
         } else if (errorMessage.contains("400")) {
           errorMessage = AppLocalizations.of(context).translate('already_attended') ?? 'Already Attended';
         }

        _showResultDialog(
          success: false,
          message: errorMessage,
        );
      }
    }
  }

  void _showResultDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? Colors.green : Colors.red,
          size: 60,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
              });
              // Camera continues scanning automatically for mobile_scanner >= 4.0?
              // Or we might need to reset something. 
              // With DetectionSpeed.noDuplicates it pauses on duplicate.
              // But here we want to scan next person.
            },
            child: Text(AppLocalizations.of(context).translate('close') ?? 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('scan_qr') ?? 'Scan QR')),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}
