import 'package:flutter/material.dart';

/// Custom vector icon siluet karakter Rick Sanchez untuk tema Rick & Morty.
class RickSilhouetteIcon extends StatelessWidget {
  final double size;
  final Color color;

  const RickSilhouetteIcon({
    super.key,
    this.size = 24,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RickSilhouettePainter(color: color),
      ),
    );
  }
}

class _RickSilhouettePainter extends CustomPainter {
  final Color color;

  const _RickSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 24.0;
    final sy = size.height / 24.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Siluet rambut runcing khas Rick + kepala + kerah jas lab di bagian bahu
    final path = Path()
      // Mulai dari bahu kiri bawah
      ..moveTo(4.5 * sx, 21.5 * sy)
      ..lineTo(6.2 * sx, 16.5 * sy)
      ..lineTo(8.5 * sx, 15.2 * sy)
      // Sisi kiri kepala & rambut runcing
      ..lineTo(7.0 * sx, 13.0 * sy)
      ..lineTo(4.2 * sx, 11.4 * sy)
      ..lineTo(6.8 * sx, 9.6 * sy)
      ..lineTo(4.6 * sx, 6.4 * sy)
      ..lineTo(8.1 * sx, 6.6 * sy)
      ..lineTo(7.8 * sx, 3.0 * sy)
      ..lineTo(10.8 * sx, 4.9 * sy)
      ..lineTo(12.2 * sx, 1.8 * sy)
      ..lineTo(13.8 * sx, 4.9 * sy)
      ..lineTo(16.8 * sx, 3.2 * sy)
      ..lineTo(16.2 * sx, 6.6 * sy)
      ..lineTo(19.8 * sx, 6.4 * sy)
      ..lineTo(17.4 * sx, 9.6 * sy)
      ..lineTo(19.8 * sx, 11.4 * sy)
      ..lineTo(17.0 * sx, 13.0 * sy)
      // Sisi kanan dagu & bahu kanan
      ..lineTo(15.5 * sx, 15.2 * sy)
      ..lineTo(17.8 * sx, 16.5 * sy)
      ..lineTo(19.5 * sx, 21.5 * sy)
      ..close();

    canvas.drawPath(path, paint);

    // Detail ekspresi kacamata/mata & kerah jas lab halus (negatif space)
    final cutoutPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15 * sx
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Garis alis menyatu khas Rick (unibrow)
    canvas.drawLine(
      Offset(9.3 * sx, 10.1 * sy),
      Offset(14.7 * sx, 10.1 * sy),
      cutoutPaint,
    );

    // Dua mata bulat kecil
    final eyePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(10.3 * sx, 11.6 * sy), 1.05 * sx, eyePaint);
    canvas.drawCircle(Offset(13.7 * sx, 11.6 * sy), 1.05 * sx, eyePaint);

    // Garis kerah jas lab V-neck
    final collarPath = Path()
      ..moveTo(9.4 * sx, 16.2 * sy)
      ..lineTo(12.0 * sx, 19.6 * sy)
      ..lineTo(14.6 * sx, 16.2 * sy);
    canvas.drawPath(collarPath, cutoutPaint);
  }

  @override
  bool shouldRepaint(covariant _RickSilhouettePainter oldDelegate) =>
      oldDelegate.color != color;
}
