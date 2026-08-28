import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'Last 3 Months', 'This Year'];

  final Map<String, Map<String, dynamic>> _timelineData = {
    'This Week': {
      'totalSales': '₹ 6,240',
      'totalOrders': '5',
      'totalProduce': '4',
      'growth': '+8.5% this week',
      'isUp': true,
      'yLabels': ['₹6K', '₹4.5K', '₹3K', '₹1.5K'],
      'xLabels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'points': [0.75, 0.58, 0.42, 0.68, 0.35, 0.22, 0.12],
      'topCrops': [
        {
          'name': 'Wheat (Local Quality)',
          'volume': '120 Kg sold • 2 orders',
          'amount': '₹ 3,360',
          'asset': AppAssets.realWheat,
          'color': Color(0xFFE8F5E9),
          'textColor': Color(0xFF136A36),
        },
        {
          'name': 'Tomatoes (Fresh Farm)',
          'volume': '80 Kg sold • 2 orders',
          'amount': '₹ 1,600',
          'asset': AppAssets.realTomatoes,
          'color': Color(0xFFFFF0E0),
          'textColor': Color(0xFFE65100),
        },
        {
          'name': 'Potatoes (Grade A)',
          'volume': '60 Kg sold • 1 order',
          'amount': '₹ 900',
          'asset': AppAssets.realPotatoes,
          'color': Color(0xFFFFF8E1),
          'textColor': Color(0xFFF57F17),
        },
        {
          'name': 'Chana Dal (Organic)',
          'volume': '5 Kg sold • 1 order',
          'amount': '₹ 380',
          'asset': AppAssets.realChanaDal,
          'color': Color(0xFFE8F5E9),
          'textColor': Color(0xFF136A36),
        },
      ],
    },
    'This Month': {
      'totalSales': '₹ 25,680',
      'totalOrders': '18',
      'totalProduce': '12',
      'growth': '+14.8% growth',
      'isUp': true,
      'yLabels': ['₹20K', '₹15K', '₹10K', '₹5K'],
      'xLabels': ['1 May', '8 May', '15 May', '22 May', '31 May'],
      'points': [0.72, 0.52, 0.62, 0.44, 0.50, 0.30, 0.40, 0.16],
      'topCrops': [
        {
          'name': 'Wheat (Local Quality)',
          'volume': '450 Kg sold • 8 orders',
          'amount': '₹ 12,600',
          'asset': AppAssets.realWheat,
          'color': Color(0xFFE8F5E9),
          'textColor': Color(0xFF136A36),
        },
        {
          'name': 'Tomatoes (Fresh Farm)',
          'volume': '300 Kg sold • 6 orders',
          'amount': '₹ 6,000',
          'asset': AppAssets.realTomatoes,
          'color': Color(0xFFFFF0E0),
          'textColor': Color(0xFFE65100),
        },
        {
          'name': 'Potatoes (Grade A)',
          'volume': '320 Kg sold • 4 orders',
          'amount': '₹ 4,800',
          'asset': AppAssets.realPotatoes,
          'color': Color(0xFFFFF8E1),
          'textColor': Color(0xFFF57F17),
        },
        {
          'name': 'Chana Dal (Organic)',
          'volume': '40 Kg sold • 2 orders',
          'amount': '₹ 2,800',
          'asset': AppAssets.realChanaDal,
          'color': Color(0xFFE8F5E9),
          'textColor': Color(0xFF136A36),
        },
      ],
    },
    'Last 3 Months': {
      'totalSales': '₹ 78,500',
      'totalOrders': '54',
      'totalProduce': '28',
      'growth': '+22.3% vs prev qtr',
      'isUp': true,
      'yLabels': ['₹60K', '₹45K', '₹30K', '₹15K'],
      'xLabels': ['March', 'April', 'May', 'June'],
      'points': [0.85, 0.65, 0.70, 0.45, 0.35, 0.20, 0.12],
      'topCrops': [
        {
          'name': 'Wheat (Local Quality)',
          'volume': '1,450 Kg sold • 24 orders',
          'amount': '₹ 40,600',
          'asset': AppAssets.realWheat,
          'color': Color(0xFFE8F5E9),
          'textColor': Color(0xFF136A36),
        },
        {
          'name': 'Tomatoes (Fresh Farm)',
          'volume': '850 Kg sold • 16 orders',
          'amount': '₹ 17,000',
          'asset': AppAssets.realTomatoes,
          'color': Color(0xFFFFF0E0),
          'textColor': Color(0xFFE65100),
        },
        {
          'name': 'Potatoes (Grade A)',
          'volume': '780 Kg sold • 10 orders',
          'amount': '₹ 11,700',
          'asset': AppAssets.realPotatoes,
          'color': Color(0xFFFFF8E1),
          'textColor': Color(0xFFF57F17),
        },
        {
          'name': 'Chana Dal (Organic)',
          'volume': '120 Kg sold • 6 orders',
          'amount': '₹ 8,400',
          'asset': AppAssets.realChanaDal,
          'color': Color(0xFFE8F5E9),
          'textColor': Color(0xFF136A36),
        },
      ],
    },
    'This Year': {
      'totalSales': '₹ 2,85,000',
      'totalOrders': '192',
      'totalProduce': '64',
      'growth': '+36.4% annual growth',
      'isUp': true,
      'yLabels': ['₹2.5L', '₹1.8L', '₹1.2L', '₹60K'],
      'xLabels': ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'],
      'points': [0.88, 0.74, 0.60, 0.48, 0.38, 0.22, 0.10],
      'topCrops': [
        {
          'name': 'Wheat (Local Quality)',
          'volume': '5,200 Kg sold • 82 orders',
          'amount': '₹ 1,45,600',
          'asset': AppAssets.realWheat,
          'color': Color(0xFFE8F5E9),
          'textColor': Color(0xFF136A36),
        },
        {
          'name': 'Tomatoes (Fresh Farm)',
          'volume': '2,800 Kg sold • 52 orders',
          'amount': '₹ 56,000',
          'asset': AppAssets.realTomatoes,
          'color': Color(0xFFFFF0E0),
          'textColor': Color(0xFFE65100),
        },
        {
          'name': 'Potatoes (Grade A)',
          'volume': '2,200 Kg sold • 36 orders',
          'amount': '₹ 33,000',
          'asset': AppAssets.realPotatoes,
          'color': Color(0xFFFFF8E1),
          'textColor': Color(0xFFF57F17),
        },
        {
          'name': 'Chana Dal (Organic)',
          'volume': '500 Kg sold • 22 orders',
          'amount': '₹ 35,000',
          'asset': AppAssets.realChanaDal,
          'color': Color(0xFFE8F5E9),
          'textColor': Color(0xFF136A36),
        },
      ],
    },
  };

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$_selectedPeriod Sales & APMC Mandi Report (PDF) downloaded!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final currentData = _timelineData[_selectedPeriod] ?? _timelineData['This Month']!;
    final List<Map<String, dynamic>> topCrops = currentData['topCrops'] as List<Map<String, dynamic>>;
    final List<double> points = currentData['points'] as List<double>;
    final List<String> yLabels = currentData['yLabels'] as List<String>;
    final List<String> xLabels = currentData['xLabels'] as List<String>;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF142B1D), size: 24),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: Text(
          'Sales Report',
          style: GoogleFonts.poppins(
            color: const Color(0xFF142B1D),
            fontSize: 18.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================= 1. TIMELINE SELECTOR PILLS =================
                  AppFadeSlideAnimation(
                    delay: Duration.zero,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                      ),
                      child: Row(
                        children: _periods.map((period) {
                          final isSelected = _selectedPeriod == period;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = period),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF136A36) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    period == 'This Week'
                                        ? '1W'
                                        : period == 'This Month'
                                            ? '1M'
                                            : period == 'Last 3 Months'
                                                ? '3M'
                                                : '1Y',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFF657E70),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= 2. TOP METRIC CARDS (3-COLUMN ROW) =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 60),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Total Sales',
                            value: currentData['totalSales'] as String,
                            isGreen: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Total Orders',
                            value: currentData['totalOrders'] as String,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Total Produce',
                            value: currentData['totalProduce'] as String,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ================= 3. SALES TREND CHART CARD =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Sales Trend'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.025),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Trend Subhead
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Revenue Over Time',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF6B8374),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF136A36)),
                                        const SizedBox(width: 4),
                                        Text(
                                          currentData['growth'] as String,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF136A36),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Dynamic Custom Painted Curved Chart
                              SizedBox(
                                height: 160,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: _DynamicSalesChartPainter(
                                    normalizedPoints: points,
                                    yLabels: yLabels,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // X-Axis Date Labels
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: xLabels.map((l) => _buildAxisLabel(l)).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ================= 4. TOP PERFORMING CROPS =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Top Performing Crops'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.025),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: topCrops.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              indent: 72,
                              endIndent: 16,
                              color: Color(0xFFF0F4F1),
                            ),
                            itemBuilder: (context, index) {
                              final crop = topCrops[index];
                              final cropName = langProvider.translateProduce(crop['name'] as String);

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    // Left Crop Real Photo Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.asset(
                                        crop['asset'] as String,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 48,
                                          height: 48,
                                          color: crop['color'] as Color,
                                          child: Icon(Icons.grass_rounded, color: crop['textColor'] as Color, size: 22),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Crop Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cropName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF162E1F),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            crop['volume'] as String,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF7E9486),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Revenue
                                    Text(
                                      crop['amount'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF136A36),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ================= 5. EXPORT / DOWNLOAD REPORT CTA =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 240),
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _exportReport,
                        icon: const Icon(Icons.file_download_outlined, color: Color(0xFF136A36), size: 20),
                        label: Text(
                          'Download Tax & Mandi Statement (PDF)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF136A36),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF136A36), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF162E1E),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildMetricCard({required String label, required String value, bool isGreen = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF758A7E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isGreen ? const Color(0xFF136A36) : const Color(0xFF162E1F),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF8B9E92),
      ),
    );
  }
}

/// Dynamic Custom Painter that updates curve and labels based on timeline
class _DynamicSalesChartPainter extends CustomPainter {
  final List<double> normalizedPoints;
  final List<String> yLabels;

  _DynamicSalesChartPainter({
    required this.normalizedPoints,
    required this.yLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw horizontal dotted grid lines with Y labels
    final gridPaint = Paint()
      ..color = const Color(0xFFEDF2EE)
      ..strokeWidth = 1;

    final yStep = size.height / (yLabels.isEmpty ? 4 : yLabels.length);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < yLabels.length; i++) {
      final y = i * yStep;
      canvas.drawLine(Offset(38, y), Offset(size.width, y), gridPaint);

      textPainter.text = TextSpan(
        text: yLabels[i],
        style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9EABA2), fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // Chart Area
    final chartLeft = 40.0;
    final chartWidth = size.width - chartLeft;

    if (normalizedPoints.isEmpty) return;

    final points = <Offset>[];
    final stepX = chartWidth / (normalizedPoints.length - 1);

    for (int i = 0; i < normalizedPoints.length; i++) {
      final x = chartLeft + i * stepX;
      final y = size.height * normalizedPoints[i].clamp(0.08, 0.92);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // 2. Draw gradient fill below curve
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(points.first.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x33136A36),
          Color(0x05136A36),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // 3. Draw smooth curve line
    final linePaint = Paint()
      ..color = const Color(0xFF136A36)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // 4. Draw data point dots
    final dotFillPaint = Paint()..color = const Color(0xFF136A36);
    final dotCenterPaint = Paint()..color = Colors.white;

    for (final p in points) {
      canvas.drawCircle(p, 3.5, dotFillPaint);
      canvas.drawCircle(p, 1.8, dotCenterPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicSalesChartPainter oldDelegate) {
    return oldDelegate.normalizedPoints != normalizedPoints || oldDelegate.yLabels != yLabels;
  }
}
