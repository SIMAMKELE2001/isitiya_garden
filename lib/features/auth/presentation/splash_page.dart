import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';

/// First screen: a stormy farmland scene, the name and a loading bar.
/// (A photograph of children in gumboots can replace the painted scene later.)
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B2428), Color(0xFF4A5A5C), Color(0xFF8B9A92)],
              ),
            ),
          ),
          CustomPaint(painter: _LandscapePainter()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const AppLogo(size: 72),
                  const SizedBox(height: 16),
                  Text(
                    'isitiyaGarden',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Growing local. Connecting communities.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 28),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 2400),
                    builder: (context, value, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 4,
                        color: AppColors.gold,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark rain clouds.
    final cloud = Paint()..color = const Color(0xFF2A3538);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.2, h * 0.13), width: w * 0.9, height: h * 0.12),
        cloud);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.8, h * 0.10), width: w * 0.9, height: h * 0.13),
        cloud);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.22), width: w * 1.1, height: h * 0.10),
        Paint()..color = const Color(0xFF5D6D6E).withValues(alpha: 0.7));

    // Rolling hills.
    final far = Path()
      ..moveTo(0, h * 0.50)
      ..quadraticBezierTo(w * 0.3, h * 0.42, w * 0.6, h * 0.48)
      ..quadraticBezierTo(w * 0.85, h * 0.52, w, h * 0.45)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF4C6B3D));

    final near = Path()
      ..moveTo(0, h * 0.58)
      ..quadraticBezierTo(w * 0.35, h * 0.52, w * 0.65, h * 0.57)
      ..quadraticBezierTo(w * 0.85, h * 0.60, w, h * 0.56)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(near, Paint()..color = const Color(0xFF3B5A2F));

    // Crop rows.
    final rows = Paint()
      ..color = const Color(0xFF2C4724)
      ..strokeWidth = 3;
    for (var i = 0; i < 6; i++) {
      final y = h * (0.64 + i * 0.05);
      canvas.drawLine(Offset(0, y + 30), Offset(w, y - 20), rows);
    }

    // Wet earth at the bottom, darkening for the text.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.68, w, h * 0.32),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xD90B1A10)],
        ).createShader(Rect.fromLTWH(0, h * 0.68, w, h * 0.32)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
