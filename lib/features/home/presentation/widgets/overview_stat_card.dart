import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_count_text.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';

enum OverviewCardType {
  newOrders,
  inProcessing,
  completed,
}

class OverviewStatCard extends StatelessWidget {
  final OverviewCardType type;
  final String title;
  final String count;
  final VoidCallback? onTap;

  const OverviewStatCard({
    super.key,
    required this.type,
    required this.title,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parsedCount = num.tryParse(count) ?? 0;

    return Expanded(
      child: ScaleBounceOnTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4EBE6), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLottieIcon(),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2A3D31),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedCountText(
                targetValue: parsedCount,
                duration: const Duration(milliseconds: 300),
                delay: Duration.zero,
                curve: Curves.easeOutCubic,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLottieIcon() {
    String assetPath;
    IconData fallbackIcon;
    Color fallbackBg;

    switch (type) {
      case OverviewCardType.newOrders:
        assetPath = 'assets/animations/packaging_for_delivery.json';
        fallbackIcon = Icons.inventory_2_outlined;
        fallbackBg = const Color(0xFFFFF3E0);
        break;
      case OverviewCardType.inProcessing:
        assetPath = 'assets/animations/clock_time.json';
        fallbackIcon = Icons.timer_outlined;
        fallbackBg = const Color(0xFFE1F5FE);
        break;
      case OverviewCardType.completed:
        assetPath = 'assets/animations/success.json';
        fallbackIcon = Icons.check_circle_outline_rounded;
        fallbackBg = const Color(0xFFE8F5E9);
        break;
    }

    final bool isTesting = WidgetsBinding.instance.runtimeType.toString().contains('TestWidgets');

    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fallbackBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Lottie.asset(
        assetPath,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        repeat: !isTesting,
        animate: true,
        errorBuilder: (context, error, stackTrace) => Icon(
          fallbackIcon,
          size: 28,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
