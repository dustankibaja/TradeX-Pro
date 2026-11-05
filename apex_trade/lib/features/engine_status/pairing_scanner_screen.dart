import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_theme.dart';
import 'pairing_credentials.dart';

/// Local camera decoding only. No QR values are logged, uploaded or shown.
class PairingScannerScreen extends StatefulWidget {
  const PairingScannerScreen({super.key});

  @override
  State<PairingScannerScreen> createState() => _PairingScannerScreenState();
}

class _PairingScannerScreenState extends State<PairingScannerScreen> {
  bool _handled = false;
  String? _error;

  void _onDetect(BarcodeCapture scan) {
    if (_handled || scan.barcodes.isEmpty) return;
    final raw = scan.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (raw == null) return;
    try {
      final parsed = PairingCredentials.fromQr(raw);
      _handled = true;
      if (mounted) Navigator.of(context).pop(parsed);
    } on FormatException {
      if (mounted) {
        setState(() => _error =
            'That is not a valid private Emtifize QR. '
            'Scan the QR shown on your Windows PC.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        title: const Text('Scan Windows pairing QR'),
      ),
      body: SafeArea(child: Column(children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Open the private QR on your Windows PC and point your '
            'phone camera at it. Never share a screenshot of this QR.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.text2, height: 1.5),
          ),
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
        )),
        if (_error != null) Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text(_error!,
            style: const TextStyle(color: AppColors.amber)),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Text('Camera access is used for scanning only.',
            style: TextStyle(color: AppColors.text3)),
        ),
      ])),
    );
  }
}
