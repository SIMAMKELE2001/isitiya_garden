import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/phone_utils.dart';
import '../models/produce.dart';

/// Opens the "Contact farmer" bottom sheet (FR25).
/// The app only starts the phone's own Call, WhatsApp or SMS apps. It never
/// handles payment or delivery (SRS acceptance criteria).
Future<void> showContactSheet(
  BuildContext context, {
  required Produce produce,
  String? buyerName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.cream,
    builder: (_) => _ContactSheet(produce: produce, buyerName: buyerName),
  );
}

class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.produce, this.buyerName});

  final Produce produce;
  final String? buyerName;

  String get _message {
    final farmerFirst = produce.farmerName.trim().split(' ').first;
    final signOff = buyerName == null ? '' : ' Regards, $buyerName';
    return 'Molo $farmerFirst, I saw your ${produce.name.toLowerCase()} '
        'on isitiyaGarden. Is it still available?$signOff';
  }

  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open that app. Try another way to contact the farmer.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final phone = produce.farmerPhone;
    final whatsapp = produce.whatsappNumber ?? phone;
    final encoded = Uri.encodeComponent(_message);

    String? intl(String? raw) =>
        raw == null ? null : PhoneUtils.toInternational(raw);

    final callNumber = intl(phone);
    final waNumber = intl(whatsapp);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact ${produce.farmerName}',
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'About: ${produce.name}',
              style: text.bodyLarge?.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            _ContactButton(
              icon: Icons.call,
              label: 'Call',
              detail: phone,
              onTap: callNumber == null
                  ? null
                  : () => _open(context, Uri.parse('tel:+$callNumber')),
            ),
            _ContactButton(
              icon: Icons.chat,
              label: 'WhatsApp',
              detail: whatsapp,
              onTap: waNumber == null
                  ? null
                  : () => _open(
                      context,
                      Uri.parse('https://wa.me/$waNumber?text=$encoded'),
                    ),
            ),
            _ContactButton(
              icon: Icons.sms_outlined,
              label: 'Send an SMS',
              detail: phone,
              onTap: callNumber == null
                  ? null
                  : () => _open(
                      context,
                      Uri.parse('sms:+$callNumber?body=$encoded'),
                    ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F3DC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.forest),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'isitiyaGarden connects you directly. Agree the price and '
                      'pickup with the farmer. Payments and delivery are not '
                      'handled in this app.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.line, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: enabled ? AppColors.forest : AppColors.grey,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        detail ?? 'No number provided',
                        style: const TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
