import 'package:flutter/material.dart';

/// A rich, responsive custom illustration of a rustic wooden crate overflowing
/// with freshly harvested farm produce (cabbage, carrots, tomatoes, corn, squash).
class HarvestCrateArt extends StatelessWidget {
  final double width;
  final double height;

  const HarvestCrateArt({
    super.key,
    this.width = 160,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _HarvestCratePainter(),
      ),
    );
  }
}

class _HarvestCratePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw soft ground ambient shadow under the crate
    final groundShadowPaint = Paint()
      ..color = const Color(0xFF1E3A20).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.90),
        width: w * 0.85,
        height: h * 0.22,
      ),
      groundShadowPaint,
    );

    // ================= VEGETABLES & PRODUCE (BEHIND CRATE) =================

    // 1. Lush Green Cabbages & Leafy Tops (Backdrop)
    _drawLeafyCabbageBackdrop(canvas, w, h);

    // 2. Fresh Carrots & Radishes (Tucked on left side)
    _drawCarrots(canvas, w, h);

    // 3. Golden Corn & Squash / Pumpkins (Center-Left)
    _drawGoldenSquashAndCorn(canvas, w, h);

    // 4. Vibrant Red Tomatoes (Center)
    _drawTomatoes(canvas, w, h);

    // 5. Crisp Front Cabbage & Lettuce Leaves
    _drawFrontLettuce(canvas, w, h);

    // ================= WOODEN CRATE =================
    _drawWoodenCrate(canvas, w, h);

    // 6. Overhanging Harvest Leaves & Garlic/Onion accents in front of crate slat
    _drawFrontAccents(canvas, w, h);
  }

  void _drawLeafyCabbageBackdrop(Canvas canvas, double w, double h) {
    final leafGreenDark = Paint()..color = const Color(0xFF2E7D32);
    final leafGreenMid = Paint()..color = const Color(0xFF43A047);
    final leafGreenLight = Paint()..color = const Color(0xFF7CB342);
    final leafGreenBright = Paint()..color = const Color(0xFF8BC34A);

    // Big backdrop leafy cluster top right
    canvas.drawCircle(Offset(w * 0.72, h * 0.32), w * 0.22, leafGreenDark);
    canvas.drawCircle(Offset(w * 0.60, h * 0.26), w * 0.18, leafGreenMid);
    canvas.drawCircle(Offset(w * 0.80, h * 0.38), w * 0.16, leafGreenMid);
    canvas.drawCircle(Offset(w * 0.68, h * 0.22), w * 0.14, leafGreenLight);
    canvas.drawCircle(Offset(w * 0.54, h * 0.34), w * 0.15, leafGreenDark);

    // Subtle leaf vein lines / ruffled edges
    final veinPaint = Paint()
      ..color = const Color(0xFFAED581).withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final leafPath = Path();
    leafPath.moveTo(w * 0.65, h * 0.30);
    leafPath.quadraticBezierTo(w * 0.72, h * 0.20, w * 0.78, h * 0.16);
    canvas.drawPath(leafPath, veinPaint);

    final leafPath2 = Path();
    leafPath2.moveTo(w * 0.56, h * 0.28);
    leafPath2.quadraticBezierTo(w * 0.60, h * 0.18, w * 0.64, h * 0.14);
    canvas.drawPath(leafPath2, veinPaint);

    // Texture dots on leaves
    canvas.drawCircle(Offset(w * 0.75, h * 0.24), 3, leafGreenBright);
    canvas.drawCircle(Offset(w * 0.62, h * 0.20), 2.5, leafGreenBright);
  }

  void _drawCarrots(Canvas canvas, double w, double h) {
    final carrotOrange = Paint()..color = const Color(0xFFFF6F00);
    final carrotDeep = Paint()..color = const Color(0xFFE65100);
    final carrotHighlight = Paint()..color = const Color(0xFFFFA726);

    // Carrot 1
    final pathCarrot1 = Path();
    pathCarrot1.moveTo(w * 0.24, h * 0.44);
    pathCarrot1.lineTo(w * 0.32, h * 0.38);
    pathCarrot1.lineTo(w * 0.18, h * 0.54);
    pathCarrot1.close();
    canvas.drawPath(pathCarrot1, carrotOrange);

    // Carrot 2
    final pathCarrot2 = Path();
    pathCarrot2.moveTo(w * 0.28, h * 0.48);
    pathCarrot2.lineTo(w * 0.36, h * 0.42);
    pathCarrot2.lineTo(w * 0.22, h * 0.58);
    pathCarrot2.close();
    canvas.drawPath(pathCarrot2, carrotDeep);

    // Carrot tip highlight
    canvas.drawCircle(Offset(w * 0.31, h * 0.41), 3.5, carrotHighlight);

    // Carrot leafy greens
    final carrotGreen = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.33, h * 0.38), Offset(w * 0.38, h * 0.30), carrotGreen);
    canvas.drawLine(Offset(w * 0.35, h * 0.40), Offset(w * 0.42, h * 0.33), carrotGreen);
  }

  void _drawGoldenSquashAndCorn(Canvas canvas, double w, double h) {
    // Golden Yellow Squash / Pumpkin
    final goldMain = Paint()..color = const Color(0xFFFFB300);
    final goldDeep = Paint()..color = const Color(0xFFFFA000);
    final goldLight = Paint()..color = const Color(0xFFFFE082);

    // Squash base & segments
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.78, h * 0.48), width: w * 0.22, height: h * 0.24),
      goldDeep,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.76, h * 0.48), width: w * 0.18, height: h * 0.22),
      goldMain,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.74, h * 0.46), width: w * 0.12, height: h * 0.18),
      goldLight,
    );

    // Squash Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.78, h * 0.38), Offset(w * 0.79, h * 0.34), stemPaint);
  }

  void _drawTomatoes(Canvas canvas, double w, double h) {
    final tomatoRed = Paint()..color = const Color(0xFFD32F2F);
    final tomatoLight = Paint()..color = const Color(0xFFEF5350);
    final tomatoShadow = Paint()..color = const Color(0xFFB71C1C);

    // Tomato 1 (Left-Center)
    canvas.drawCircle(Offset(w * 0.36, h * 0.52), w * 0.08, tomatoShadow);
    canvas.drawCircle(Offset(w * 0.35, h * 0.51), w * 0.075, tomatoRed);
    canvas.drawCircle(Offset(w * 0.33, h * 0.49), w * 0.025, tomatoLight);

    // Tomato 2 (Center)
    canvas.drawCircle(Offset(w * 0.46, h * 0.54), w * 0.085, tomatoShadow);
    canvas.drawCircle(Offset(w * 0.45, h * 0.53), w * 0.08, tomatoRed);
    canvas.drawCircle(Offset(w * 0.43, h * 0.51), w * 0.028, tomatoLight);

    // Tomato green star crowns
    final crownGreen = Paint()..color = const Color(0xFF4CAF50);
    _drawStarCrown(canvas, Offset(w * 0.35, h * 0.46), 4, crownGreen);
    _drawStarCrown(canvas, Offset(w * 0.45, h * 0.48), 5, crownGreen);
  }

  void _drawStarCrown(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.6, center.dy + size * 0.5);
    path.lineTo(center.dx - size * 0.6, center.dy + size * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawFrontLettuce(Canvas canvas, double w, double h) {
    final leafPaint = Paint()..color = const Color(0xFF66BB6A);
    final leafLight = Paint()..color = const Color(0xFF9CCC65);

    canvas.drawCircle(Offset(w * 0.58, h * 0.52), w * 0.10, leafPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.50), w * 0.08, leafLight);
  }

  void _drawWoodenCrate(Canvas canvas, double w, double h) {
    // Slanted 3D wooden crate perspective
    // Slat wood colors
    final woodFrontLight = const Color(0xFFD7A15C);
    final woodFrontBase = const Color(0xFFC68A45);
    final woodFrontDark = const Color(0xFF9E6527);
    final woodSideDark = const Color(0xFF8D531B);
    final woodCornerPost = const Color(0xFFB57835);
    final nailColor = const Color(0xFF42280E);

    final crateTopY = h * 0.54;
    final crateBottomY = h * 0.84;
    final crateLeftX = w * 0.12;
    final crateRightX = w * 0.88;

    // Corner Posts
    final postWidth = w * 0.06;

    // Slat 1 (Top Slat)
    _drawCrateSlat(
      canvas,
      Rect.fromLTRB(crateLeftX, crateTopY, crateRightX, crateTopY + (crateBottomY - crateTopY) * 0.42),
      woodFrontBase,
      woodFrontLight,
      woodFrontDark,
    );

    // Slat 2 (Bottom Slat)
    _drawCrateSlat(
      canvas,
      Rect.fromLTRB(crateLeftX, crateTopY + (crateBottomY - crateTopY) * 0.54, crateRightX, crateBottomY),
      woodFrontBase,
      woodFrontLight,
      woodFrontDark,
    );

    // Left Corner Vertical Post
    _drawVerticalPost(
      canvas,
      Rect.fromLTRB(crateLeftX, crateTopY - 2, crateLeftX + postWidth, crateBottomY + 2),
      woodCornerPost,
      woodSideDark,
    );

    // Middle Vertical Post
    _drawVerticalPost(
      canvas,
      Rect.fromLTRB(w * 0.48, crateTopY - 2, w * 0.48 + postWidth, crateBottomY + 2),
      woodCornerPost,
      woodSideDark,
    );

    // Right Corner Vertical Post
    _drawVerticalPost(
      canvas,
      Rect.fromLTRB(crateRightX - postWidth, crateTopY - 2, crateRightX, crateBottomY + 2),
      woodCornerPost,
      woodSideDark,
    );

    // Metal Nails / Fasteners on the posts
    final nailPaint = Paint()..color = nailColor;
    final nailHighlight = Paint()..color = const Color(0xFF7A4B1A);

    final nailPositions = [
      Offset(crateLeftX + postWidth * 0.5, crateTopY + 5),
      Offset(crateLeftX + postWidth * 0.5, crateBottomY - 5),
      Offset(w * 0.48 + postWidth * 0.5, crateTopY + 5),
      Offset(w * 0.48 + postWidth * 0.5, crateBottomY - 5),
      Offset(crateRightX - postWidth * 0.5, crateTopY + 5),
      Offset(crateRightX - postWidth * 0.5, crateBottomY - 5),
    ];

    for (final pos in nailPositions) {
      canvas.drawCircle(pos, 2.0, nailPaint);
      canvas.drawCircle(Offset(pos.dx - 0.5, pos.dy - 0.5), 0.8, nailHighlight);
    }
  }

  void _drawCrateSlat(Canvas canvas, Rect rect, Color base, Color light, Color dark) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));

    // Base slat
    final slatPaint = Paint()..color = base;
    canvas.drawRRect(rrect, slatPaint);

    // Top highlight edge
    final topHighlightPaint = Paint()
      ..color = light
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(rect.left + 2, rect.top + 1),
      Offset(rect.right - 2, rect.top + 1),
      topHighlightPaint,
    );

    // Bottom shadow edge
    final botShadowPaint = Paint()
      ..color = dark
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(rect.left + 2, rect.bottom - 1),
      Offset(rect.right - 2, rect.bottom - 1),
      botShadowPaint,
    );

    // Subtle wood grain lines
    final grainPaint = Paint()
      ..color = dark.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final grainY = rect.top + rect.height * 0.45;
    canvas.drawLine(Offset(rect.left + 8, grainY), Offset(rect.right - 8, grainY), grainPaint);
  }

  void _drawVerticalPost(Canvas canvas, Rect rect, Color faceColor, Color shadowColor) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
    final postPaint = Paint()..color = faceColor;
    canvas.drawRRect(rrect, postPaint);

    // Shadow line on the right side of the post
    final shadowPaint = Paint()
      ..color = shadowColor
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(rect.right - 0.6, rect.top),
      Offset(rect.right - 0.6, rect.bottom),
      shadowPaint,
    );
  }

  void _drawFrontAccents(Canvas canvas, double w, double h) {
    // Golden onion/potato resting near the bottom right outside the crate
    final onionBase = Paint()..color = const Color(0xFFFBC02D);
    final onionShadow = Paint()..color = const Color(0xFFF57F17);

    canvas.drawCircle(Offset(w * 0.82, h * 0.85), w * 0.055, onionShadow);
    canvas.drawCircle(Offset(w * 0.81, h * 0.84), w * 0.05, onionBase);

    // Tiny overhanging green leaf in front of the top wooden slat
    final overhangLeaf = Paint()..color = const Color(0xFF43A047);
    final path = Path();
    path.moveTo(w * 0.52, h * 0.54);
    path.quadraticBezierTo(w * 0.55, h * 0.64, w * 0.58, h * 0.62);
    path.quadraticBezierTo(w * 0.56, h * 0.54, w * 0.52, h * 0.54);
    path.close();
    canvas.drawPath(path, overhangLeaf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
