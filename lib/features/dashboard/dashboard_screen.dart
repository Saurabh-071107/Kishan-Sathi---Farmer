import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_profile.dart';
import '../../core/models/user_role.dart';
import '../../core/services/auth_service.dart';
import '../auth/presentation/welcome_screen.dart';
import '../navigation/main_navigation_screen.dart';

class DashboardScreen extends StatelessWidget {
  final UserProfile userProfile;

  const DashboardScreen({super.key, required this.userProfile});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the user is a farmer, return the complete Farmer Homepage with Floating Navigation Bar
    if (userProfile.role == UserRole.farmer) {
      return MainNavigationScreen(userProfile: userProfile);
    }

    // FPO Dashboard View
    final primaryColor = AppColors.accentOrange;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'FPO Producer Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primaryColor.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.business_center_rounded,
                          color: primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile.fullName,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                userProfile.role.badgeName,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),

                  // Detail Rows
                  _buildDetailRow(
                    'User ID',
                    userProfile.userId,
                    Icons.badge_outlined,
                  ),
                  _buildDetailRow(
                    'Mobile',
                    '+91 ${userProfile.mobileNumber}',
                    Icons.phone_outlined,
                  ),
                  if (userProfile.gstNumber != null)
                    _buildDetailRow(
                      'GSTIN',
                      userProfile.gstNumber!,
                      Icons.domain_verification_rounded,
                    ),
                  if (userProfile.fpoName != null)
                    _buildDetailRow(
                      'FPO Name',
                      userProfile.fpoName!,
                      Icons.corporate_fare_rounded,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Services
            Text(
              'FPO Operations & Procurement',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.3,
              children: [
                _buildServiceCard(
                  'Farmer Produce',
                  'Browse & purchase bulk crops',
                  Icons.storefront_rounded,
                  AppColors.primary,
                ),
                _buildServiceCard(
                  'Active Contracts',
                  'Manage procurement contracts',
                  Icons.assignment_turned_in_rounded,
                  AppColors.accentOrange,
                ),
                _buildServiceCard(
                  'Direct Mandi Rates',
                  'Live wholesale rates & trends',
                  Icons.trending_up_rounded,
                  Colors.teal,
                ),
                _buildServiceCard(
                  'Warehouses & Logistics',
                  'Cold storage & dispatch slots',
                  Icons.warehouse_rounded,
                  Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
