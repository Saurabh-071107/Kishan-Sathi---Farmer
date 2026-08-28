import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_role.dart';
import 'login_screen.dart';
import 'widgets/registration_bottom_sheet.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _onFarmerLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(initialRole: UserRole.farmer),
      ),
    );
  }

  void _onFpoLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(initialRole: UserRole.fpo),
      ),
    );
  }

  void _onRegister(BuildContext context) {
    RegistrationBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // Calculate dynamic bottom card height so farmer and background tuck seamlessly underneath
    final isShortScreen = screenHeight < 700;
    final bottomCardEstimatedHeight = isShortScreen ? 285.0 : 315.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Farm Scene (extends from top all the way behind the bottom card)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: bottomCardEstimatedHeight - 70,
            child: Image.asset(
              AppAssets.welcomeBg,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFD4EAD6), Color(0xFFE8F5E9)],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Subtle soft gradient overlay on background for pristine header readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.35,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.90),
                    Colors.white.withValues(alpha: 0.60),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // 3. Farmer Illustration (tucked seamlessly behind the bottom card)
          Positioned(
            top: isShortScreen ? 110 : screenHeight * 0.16,
            left: 0,
            right: 0,
            bottom: bottomCardEstimatedHeight - 40,
            child: Image.asset(
              AppAssets.farmer,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),

          // 4. Foreground Content: Header at top & Curved Action Card at bottom
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 6),

                // Top National Emblem
                Image.asset(
                  AppAssets.nationalEmblem,
                  height: isShortScreen ? 40 : 46,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(height: 46),
                ),
                const SizedBox(height: 4),

                // App Brand / Logo & Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Logo
                      Image.asset(
                        AppAssets.appLogo,
                        height: isShortScreen ? 38 : 44,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Kisan Sathi',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.eco_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 4),

                      // English Tagline
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          children: const [
                            TextSpan(text: 'Sell your produce, '),
                            TextSpan(
                              text: 'grow',
                              style: TextStyle(
                                color: AppColors.accentOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' your income'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom Action Card (Overlaps the bottom of the farmer and field)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(
                    screenWidth > 400 ? 28 : 20,
                    26,
                    screenWidth > 400 ? 28 : 20,
                    mediaQuery.padding.bottom > 0 ? mediaQuery.padding.bottom + 14 : 26,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Button 1: Login as Farmer
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _onFarmerLogin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_rounded, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'Login as Farmer',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Button 2: Login as FPO
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () => _onFpoLogin(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            backgroundColor: AppColors.surfaceSoftGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.groups_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Login as FPO',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _onRegister(context),
                            child: Text(
                              'Register',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Government Initiative Footer Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppAssets.nationalEmblem,
                            height: 18,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.verified_rounded, size: 14, color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'An Initiative of Government of India',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
