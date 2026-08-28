import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import 'category_icon_art.dart';

class CategoryCard extends StatelessWidget {
  final CategoryType type;
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.type,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  String _getAssetPath() {
    switch (type) {
      case CategoryType.grains:
        return AppAssets.catGrains;
      case CategoryType.fruits:
        return AppAssets.catFruits;
      case CategoryType.vegetables:
        return AppAssets.catVegetables;
      case CategoryType.pulses:
        return AppAssets.catPulses;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF1F8F3) : const Color(0xFFFAF8F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? const Color(0xFF136A36) : const Color(0xFFEAE8DD),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _getAssetPath(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => CategoryIconArt(type: type, size: 52),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF136A36) : const Color(0xFF263A2D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
