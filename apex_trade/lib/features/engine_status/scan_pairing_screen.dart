import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_theme.dart';
import 'saved_pairing.dart';

/// Scans the QR displayed LOCALLY by the Windows MT5 bridge.
/// No server/cloud scanning; payload is validated before returning.
class ScanPairingScreen extends StatefulWidget {
  const ScanPairingScreen({super.key});

  @override
  State<ScanPairingScreen> createState() => _ScanPairingScreenState();
}

class _ScanPairingScreenState extends State<ScanPairingScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _finished = false;
  String? _error;

  void _onDetect(BarcodeCapture capture) {
    if (_finished) return;
    final raw = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (raw == null) return;
    try {
      final pairing = SavedPairing.fromQr(raw);
      _finished = true;
      Navigator.pop(context, pairing);
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'This is not an Emtifize pairing QR.');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg0,
    appBar: AppBar(
      title: const Text('Scan Windows QR'),
      backgroundColor: AppColors.bg0,
    ),
    body: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(22),
            child: Text(
              'On your Windows PC, start the Emtifize bridge. '
              'Scan the private pairing QR shown there. '
              'Never share or photograph that QR.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text2),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                errorBuilder: (context, error) => Center(
                  child: Text(
                    'Camera unavailable. Allow camera permission or use '
                    'manual pairing instead.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.red),
                  ),
                ),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.amber)),
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Private pairing only · DEMO signal controls',
              style: TextStyle(color: AppColors.text3)),
          ),
        ],
      ),
    ),
  );
}
