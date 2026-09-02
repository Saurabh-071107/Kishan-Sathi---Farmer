import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

enum CropThumbnailType {
  wheat,
  rice,
  tomatoes,
  potatoes,
  chanaDal,
}

class CropThumbnailArt extends StatelessWidget {
  final CropThumbnailType type;
  final double size;

  const CropThumbnailArt({
    super.key,
    required this.type,
    this.size = 76,
  });

  String _getAssetPath() {
    switch (type) {
      case CropThumbnailType.wheat:
        return AppAssets.realWheat;
      case CropThumbnailType.rice:
        return AppAssets.realRice;
      case CropThumbnailType.tomatoes:
        return AppAssets.realTomatoes;
      case CropThumbnailType.potatoes:
        return AppAssets.realPotatoes;
      case CropThumbnailType.chanaDal:
        return AppAssets.realChanaDal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size,
        height: size,
        color: _getBgColor(),
        child: Image.asset(
          _getAssetPath(),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => CustomPaint(
            size: Size(size, size),
            painter: _CropThumbnailPainter(type),
          ),
        ),
      ),
    );
  }

  Color _getBgColor() {
    switch (type) {
      case CropThumbnailType.wheat:
        return const Color(0xFFC8A165);
      case CropThumbnailType.rice:
        return const Color(0xFFFAF6EB);
      case CropThumbnailType.tomatoes:
        return const Color(0xFF2E4A35);
      case CropThumbnailType.potatoes:
        return const Color(0xFF8D6E63);
      case CropThumbnailType.chanaDal:
        return const Color(0xFFF9E4B7);
    }
  }
}

class _CropThumbnailPainter extends CustomPainter {
  final CropThumbnailType type;

  _CropThumbnailPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case CropThumbnailType.wheat:
        _drawWheatField(canvas, w, h);
        break;
      case CropThumbnailType.tomatoes:
        _drawTomatoes(canvas, w, h);
        break;
      case CropThumbnailType.potatoes:
        _drawPotatoes(canvas, w, h);
        break;
      case CropThumbnailType.chanaDal:
        _drawChanaDal(canvas, w, h);
        break;
      case CropThumbnailType.rice:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void _drawWheatField(Canvas canvas, double w, double h) {
    // Golden field gradient background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8D6E40), Color(0xFFCBA052), Color(0xFFDFC285)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Wheat bundle glow
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.35, glowPaint);

    // Wheat stalks
    final stemPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.5, h * 0.9), Offset(w * 0.5, h * 0.25), stemPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.8), Offset(w * 0.32, h * 0.35), stemPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.8), Offset(w * 0.68, h * 0.35), stemPaint);

    // Grains
    final grainGold = Paint()..color = const Color(0xFFFFE082);
    final grainDark = Paint()..color = const Color(0xFFC67D0A);

    for (int i = 0; i < 4; i++) {
      final y = h * (0.28 + i * 0.12);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.42, y), width: w * 0.16, height: h * 0.09), grainDark);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.42, y), width: w * 0.13, height: h * 0.07), grainGold);

      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.58, y), width: w * 0.16, height: h * 0.09), grainDark);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.58, y), width: w * 0.13, height: h * 0.07), grainGold);
    }
  }

  void _drawTomatoes(Canvas canvas, double w, double h) {
    // Farm ground
    final bgPaint = Paint()..color = const Color(0xFF334A34);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Green leaves
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawCircle(Offset(w * 0.3, h * 0.3), w * 0.2, leafPaint);
    canvas.drawCircle(Offset(w * 0.7, h * 0.35), w * 0.2, leafPaint);

    // Big Center Tomato
    final redShadow = Paint()..color = const Color(0xFFB71C1C);
    final redMain = Paint()..color = const Color(0xFFE53935);
    final redLight = Paint()..color = const Color(0xFFFF8A80);

    // Tomato 1 (Left bottom)
    canvas.drawCircle(Offset(w * 0.32, h * 0.65), w * 0.25, redShadow);
    canvas.drawCircle(Offset(w * 0.30, h * 0.63), w * 0.24, redMain);
    canvas.drawCircle(Offset(w * 0.24, h * 0.56), w * 0.06, redLight);

    // Tomato 2 (Right bottom)
    canvas.drawCircle(Offset(w * 0.68, h * 0.65), w * 0.25, redShadow);
    canvas.drawCircle(Offset(w * 0.66, h * 0.63), w * 0.24, redMain);
    canvas.drawCircle(Offset(w * 0.60, h * 0.56), w * 0.06, redLight);

    // Tomato 3 (Center Top)
    canvas.drawCircle(Offset(w * 0.50, h * 0.44), w * 0.28, redShadow);
    canvas.drawCircle(Offset(w * 0.48, h * 0.42), w * 0.27, redMain);
    canvas.drawCircle(Offset(w * 0.42, h * 0.34), w * 0.08, redLight);

    // Green star stems
    final stemPaint = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawCircle(Offset(w * 0.48, h * 0.32), 4, stemPaint);
  }

  void _drawPotatoes(Canvas canvas, double w, double h) {
    // Woven basket base
    final bgPaint = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final potatoBase = Paint()..color = const Color(0xFFD4A373);
    final potatoDark = Paint()..color = const Color(0xFFA67C52);
    final potatoLight = Paint()..color = const Color(0xFFE9C49A);

    // Potatoes in basket
    final potatoList = [
      Offset(w * 0.30, h * 0.35),
      Offset(w * 0.70, h * 0.35),
      Offset(w * 0.50, h * 0.40),
      Offset(w * 0.25, h * 0.68),
      Offset(w * 0.52, h * 0.72),
      Offset(w * 0.78, h * 0.68),
    ];

    for (final pt in potatoList) {
      canvas.drawCircle(pt, w * 0.18, potatoDark);
      canvas.drawCircle(Offset(pt.dx - 1.5, pt.dy - 1.5), w * 0.17, potatoBase);
      canvas.drawCircle(Offset(pt.dx - 4, pt.dy - 4), w * 0.06, potatoLight);
    }
  }

  void _drawChanaDal(Canvas canvas, double w, double h) {
    // Texture background
    final bgPaint = Paint()..color = const Color(0xFFF7D99E);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final dalMain = Paint()..color = const Color(0xFFE5A93C);
    final dalLight = Paint()..color = const Color(0xFFF9C86A);
    final dalShadow = Paint()..color = const Color(0xFFC78B23);

    for (double x = 8; x < w; x += 12) {
      for (double y = 8; y < h; y += 12) {
        final offset = (y.toInt() % 24 == 0) ? 6.0 : 0.0;
        final center = Offset(x + offset, y);
        canvas.drawCircle(center, 4.5, dalShadow);
        canvas.drawCircle(Offset(center.dx - 0.5, center.dy - 0.5), 4.0, dalMain);
        canvas.drawCircle(Offset(center.dx - 1.2, center.dy - 1.2), 1.5, dalLight);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
