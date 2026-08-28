import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_count_text.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';

class MetricStatCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;

  const MetricStatCard({
    super.key,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extract numerical value and prefix/suffix if present
    final isCurrency = value.contains('₹');
    final cleanNumStr = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final parsedNum = num.tryParse(cleanNumStr);

    return Expanded(
      child: ScaleBounceOnTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF556D5E),
                  letterSpacing: 0.05,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: parsedNum != null
                    ? AnimatedCountText(
                        targetValue: parsedNum,
                        prefix: isCurrency ? '₹ ' : null,
                        formatCurrency: isCurrency,
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 80),
                        curve: Curves.easeOutCubic,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                        ),
                      )
                    : Text(
                        value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
