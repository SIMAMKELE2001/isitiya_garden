import 'package:flutter/material.dart';
import '../../features/produce/models/produce.dart';

/// Shows availability using an icon, words AND colour, so the status is
/// understandable even without seeing colour (accessibility).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final AvailabilityStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = switch (status) {
      AvailabilityStatus.available =>
        (Icons.check_circle, const Color(0xFF1F6B2B), const Color(0xFFE3F3DC)),
      AvailabilityStatus.low => (
          Icons.warning_amber_rounded,
          const Color(0xFF8A5A00),
          const Color(0xFFFFF1CC)
        ),
      AvailabilityStatus.unavailable =>
        (Icons.cancel, const Color(0xFF7A2B26), const Color(0xFFF7DEDB)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
