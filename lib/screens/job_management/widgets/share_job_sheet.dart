import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/job.dart';
import '../../../utils/snackbar_utils.dart';
import 'qr_code_sheet.dart';

/// A bottom sheet for sharing a specific job's details.
class ShareJobSheet extends StatelessWidget {
  final Job job;

  const ShareJobSheet({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final String shareLink = 'https://app.weldops.com/share/job${job.id ?? ''}';

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
          _buildDragHandle(),
          const SizedBox(height: 16.0),
          _buildSheetHeader(context),
          const SizedBox(height: 24.0),
          Text(
            job.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            shareLink,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24.0),
          _buildMainActionButtons(context, shareLink),
          const Divider(color: Colors.white24, height: 32),
          _buildSocialShareIcons(context, shareLink),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 35.0,
        height: 4.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.0),
        ),
      ),
    );
  }

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
              child: const Icon(Icons.share, color: Colors.white, size: 24.0),
            ),
            const SizedBox(width: 12.0),
            const Text(
              'Share Job',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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

  Widget _buildMainActionButtons(BuildContext context, String link) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.copy,
          label: 'Copy link',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: link));
            showSuccessSnackBar(context, 'Link copied to clipboard!');
          },
        ),
        _ActionButton(
          icon: Icons.qr_code_2_sharp,
          label: 'QR Code',
          onPressed: () {
            // First, close the current share menu
            Navigator.pop(context);
            // Then, show the new QR code pop-up
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => QrCodeSheet(job: job),
            );
          },
        ),
        _ActionButton(
          icon: Icons.upload_file,
          label: 'Export File',
          onPressed: () {
            showInfoSnackBar(context, 'Export feature coming soon!');
          },
        ),
      ],
    );
  }

  Widget _buildSocialShareIcons(BuildContext context, String link) {
    // In a real app, you would use a package like `url_launcher`
    void launchURL(String appName) {
      showInfoSnackBar(context, 'Sharing via $appName not implemented.');
    }

    // Using generic icons to represent the brands
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            onPressed: () => launchURL('WhatsApp'),
            icon:
            const Icon(Icons.message, color: Colors.green, size: 30)),
        IconButton(
            onPressed: () => launchURL('Messages'),
            icon: const Icon(Icons.sms, color: Colors.blue, size: 30)),
        IconButton(
            onPressed: () => launchURL('Telegram'),
            icon: const Icon(Icons.telegram,
                color: Colors.lightBlue, size: 30)),
        IconButton(
            onPressed: () => launchURL('Gmail'),
            icon:
            const Icon(Icons.mail, color: Colors.redAccent, size: 30)),
        IconButton(
            onPressed: () => launchURL('Instagram'),
            icon: const Icon(Icons.camera_alt,
                color: Colors.purpleAccent, size: 30)),
        IconButton(
            onPressed: () => launchURL('LinkedIn'),
            icon: const Icon(Icons.work,
                color: Colors.blueAccent, size: 30)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton(
      {required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(0.0),
            border: Border.all(
              color: Colors.grey.shade700, // Choose your desired border color
              width: 1.0,                  // Set the thickness of the border
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
