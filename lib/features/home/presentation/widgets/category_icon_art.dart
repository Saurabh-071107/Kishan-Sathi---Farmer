import 'package:flutter/material.dart';

enum CategoryType {
  grains,
  fruits,
  vegetables,
  pulses,
}

class CategoryIconArt extends StatelessWidget {
  final CategoryType type;
  final double size;

  const CategoryIconArt({
    super.key,
    required this.type,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBgColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.72, size * 0.72),
          painter: _CategoryPainter(type),
        ),
      ),
    );
  }

  Color _getBgColor() {
    switch (type) {
      case CategoryType.grains:
        return const Color(0xFFFFF8E7);
      case CategoryType.fruits:
        return const Color(0xFFFFF4E0);
      case CategoryType.vegetables:
        return const Color(0xFFEAF5EC);
      case CategoryType.pulses:
        return const Color(0xFFFFF9E6);
    }
  }
}

class _CategoryPainter extends CustomPainter {
  final CategoryType type;

  _CategoryPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case CategoryType.grains:
        _drawGrains(canvas, w, h);
        break;
      case CategoryType.fruits:
        _drawFruits(canvas, w, h);
        break;
      case CategoryType.vegetables:
        _drawVegetables(canvas, w, h);
        break;
      case CategoryType.pulses:
        _drawPulses(canvas, w, h);
        break;
    }
  }

  void _drawGrains(Canvas canvas, double w, double h) {
    // Golden wheat stalks with grains
    final stemPaint = Paint()
      ..color = const Color(0xFFD48B17)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final grainGold = Paint()..color = const Color(0xFFF5A623);
    final grainDark = Paint()..color = const Color(0xFFC77800);
    final grainLight = Paint()..color = const Color(0xFFFFD166);

    // Stems
    canvas.drawLine(Offset(w * 0.5, h * 0.95), Offset(w * 0.5, h * 0.2), stemPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.8), Offset(w * 0.28, h * 0.35), stemPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.8), Offset(w * 0.72, h * 0.35), stemPaint);

    // Grains on central stem
    for (int i = 0; i < 4; i++) {
      final y = h * (0.22 + i * 0.14);
      // Left grain
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.40, y), width: w * 0.16, height: h * 0.10),
        grainDark,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.40, y), width: w * 0.14, height: h * 0.08),
        grainGold,
      );
      canvas.drawCircle(Offset(w * 0.38, y - 1), 1.5, grainLight);

      // Right grain
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.60, y), width: w * 0.16, height: h * 0.10),
        grainDark,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.60, y), width: w * 0.14, height: h * 0.08),
        grainGold,
      );
      canvas.drawCircle(Offset(w * 0.58, y - 1), 1.5, grainLight);
    }

    // Top spikelet
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.14), width: w * 0.12, height: h * 0.14),
      grainGold,
    );
  }

  void _drawFruits(Canvas canvas, double w, double h) {
    // Golden pumpkin / ripe mango
    final orangeDeep = Paint()..color = const Color(0xFFE65100);
    final orangeMain = Paint()..color = const Color(0xFFFB8C00);
    final orangeLight = Paint()..color = const Color(0xFFFFB74D);

    // Pumpkin body ridges
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.32, h * 0.56), width: w * 0.36, height: h * 0.55),
      orangeDeep,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.68, h * 0.56), width: w * 0.36, height: h * 0.55),
      orangeDeep,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.54), width: w * 0.46, height: h * 0.62),
      orangeMain,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.44, h * 0.52), width: w * 0.22, height: h * 0.46),
      orangeLight,
    );

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.24), Offset(w * 0.53, h * 0.14), stemPaint);

    // Leaf
    final leafPaint = Paint()..color = const Color(0xFF43A047);
    final leafPath = Path();
    leafPath.moveTo(w * 0.52, h * 0.20);
    leafPath.quadraticBezierTo(w * 0.66, h * 0.14, w * 0.68, h * 0.22);
    leafPath.quadraticBezierTo(w * 0.58, h * 0.26, w * 0.52, h * 0.20);
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);
  }

  void _drawVegetables(Canvas canvas, double w, double h) {
    // Red tomato + Green cabbage/lettuce
    final greenDark = Paint()..color = const Color(0xFF2E7D32);
    final greenMid = Paint()..color = const Color(0xFF4CAF50);
    final greenLight = Paint()..color = const Color(0xFF81C784);

    final redTomato = Paint()..color = const Color(0xFFD32F2F);
    final redLight = Paint()..color = const Color(0xFFEF5350);

    // Leafy background
    canvas.drawCircle(Offset(w * 0.50, h * 0.38), w * 0.28, greenDark);
    canvas.drawCircle(Offset(w * 0.42, h * 0.34), w * 0.22, greenMid);
    canvas.drawCircle(Offset(w * 0.58, h * 0.34), w * 0.20, greenLight);

    // Tomato in front
    canvas.drawCircle(Offset(w * 0.40, h * 0.62), w * 0.24, const Color(0xFFB71C1C).asPaint());
    canvas.drawCircle(Offset(w * 0.38, h * 0.60), w * 0.22, redTomato);
    canvas.drawCircle(Offset(w * 0.33, h * 0.54), w * 0.06, redLight);

    // Tomato stem crown
    final crownPaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(Offset(w * 0.38, h * 0.44), 3.5, crownPaint);

    // Eggplant / Carrot on the right
    final carrotPaint = Paint()..color = const Color(0xFFFF6D00);
    final path = Path();
    path.moveTo(w * 0.58, h * 0.48);
    path.lineTo(w * 0.72, h * 0.54);
    path.lineTo(w * 0.62, h * 0.78);
    path.close();
    canvas.drawPath(path, carrotPaint);
  }

  void _drawPulses(Canvas canvas, double w, double h) {
    // Ceramic bowl filled with golden lentils/chickpeas
    final bowlRim = Paint()..color = const Color(0xFF8D6E63);
    final bowlBase = Paint()..color = const Color(0xFFD7CCC8);
    final dalGold = Paint()..color = const Color(0xFFFBC02D);
    final dalShadow = Paint()..color = const Color(0xFFF57F17);

    // Bowl
    final bowlPath = Path();
    bowlPath.moveTo(w * 0.16, h * 0.50);
    bowlPath.quadraticBezierTo(w * 0.18, h * 0.88, w * 0.50, h * 0.88);
    bowlPath.quadraticBezierTo(w * 0.82, h * 0.88, w * 0.84, h * 0.50);
    bowlPath.close();
    canvas.drawPath(bowlPath, bowlBase);

    // Bowl Top Oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.68, height: h * 0.30),
      bowlRim,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.64, height: h * 0.26),
      dalShadow,
    );

    // Lentil grains inside bowl
    final grainPositions = [
      Offset(w * 0.38, h * 0.48),
      Offset(w * 0.50, h * 0.46),
      Offset(w * 0.62, h * 0.48),
      Offset(w * 0.44, h * 0.52),
      Offset(w * 0.56, h * 0.52),
      Offset(w * 0.50, h * 0.42),
      Offset(w * 0.34, h * 0.50),
      Offset(w * 0.66, h * 0.50),
    ];

    for (final pt in grainPositions) {
      canvas.drawCircle(pt, w * 0.05, dalGold);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on Color {
  Paint asPaint() => Paint()..color = this;
}
