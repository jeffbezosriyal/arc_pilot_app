import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add this import

import '../../../models/job.dart';

/// A bottom sheet widget to display a QR code for a given job.
class QrCodeSheet extends StatelessWidget {
  final Job job;

  const QrCodeSheet({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final String qrData = 'https://app.weldops.com/share/job${job.id}';

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Header
          _buildSheetHeader(context),
          const SizedBox(height: 32.0),
          // QR Code Image
          Center(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
              ),
            ),
          ),
          const SizedBox(height: 32.0),
          // Job Information Box
          _buildInfoBox(context),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  /// Builds the header section of the bottom sheet.
  Widget _buildSheetHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: const Icon(Icons.qr_code_2_sharp, color: Colors.white, size: 24.0),
            ),
            const SizedBox(width: 12.0),
            Text(
              'QR Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// Builds the informational text box at the bottom.
  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            job.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Scan this code to access the memory information.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}

