import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep; // 0-indexed
  final List<String> steps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepBefore = index ~/ 2;
              final isPassed = currentStep > stepBefore;
              return Expanded(
                child: Container(
                  height: 3,
                  color: isPassed ? AppColors.primary : AppColors.border,
                ),
              );
            } else {
              final stepIndex = index ~/ 2;
              final isCompleted = currentStep > stepIndex;
              final isCurrent = currentStep == stepIndex;

              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.primary
                      : (isCurrent ? AppColors.primaryLight : Colors.white),
                  border: Border.all(
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : Text(
                          '${stepIndex + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        Text(
          steps[currentStep],
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
