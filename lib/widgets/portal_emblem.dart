import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'rick_silhouette_icon.dart';

class PortalEmblem extends StatelessWidget {
  final double size;
  final IconData? icon;

  const PortalEmblem({
    super.key,
    this.size = 76,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.portalGreen.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _PortalRingPainter(),
            ),
          ),
          Container(
            width: size * 0.64,
            height: size * 0.64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.spaceTealDark,
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      color: AppColors.portalGreen,
                      size: size * 0.3,
                    )
                  : RickSilhouetteIcon(
                      size: size * 0.36,
                      color: AppColors.portalGreen,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFECFCCB),
          AppColors.portalGreen,
          AppColors.portalCyan,
        ],
        stops: [0.3, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bgPaint);

    final swirlPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.032
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.45);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.84),
      0.35,
      math.pi * 0.68,
      false,
      swirlPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.84),
      3.5,
      math.pi * 0.62,
      false,
      swirlPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
