import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/device_hardware_service.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';
import '../../auth/presentation/welcome_screen.dart';
import '../../reports/presentation/sales_report_screen.dart';

class ProfileTab extends StatefulWidget {
  final UserProfile? userProfile;

  const ProfileTab({super.key, this.userProfile});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  XFile? _customAvatarFile;
  String _gpsCoordinates = '23.2032° N, 77.0844° E (Ashta, Sehore)';
  bool _isLocating = false;

  Future<void> _logout(BuildContext context, LanguageProvider langProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(langProvider.translate('logout_confirm_title'), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          langProvider.translate('logout_confirm_desc'),
          style: GoogleFonts.poppins(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(langProvider.translate('cancel'), style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(langProvider.translate('log_out'), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await AuthService().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  void _changeProfilePhoto(LanguageProvider langProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Text(langProvider.translate('update_profile_photo'), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: Text(langProvider.translate('take_camera_photo'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('Capture new photo with device camera', style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await DeviceHardwareService().captureFromCamera();
                if (file != null) {
                  setState(() => _customAvatarFile = file);
                }
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.photo_library_rounded, color: AppColors.accentOrange),
              ),
              title: Text(langProvider.translate('choose_gallery'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('Select saved portrait photo', style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await DeviceHardwareService().pickFromGallery();
                if (file != null) {
                  setState(() => _customAvatarFile = file);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openLanguagePicker(BuildContext context, LanguageProvider langProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              langProvider.translate('select_language'),
              style: GoogleFonts.poppins(fontSize: 17.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...AppLanguage.values.map((lang) {
              final isSelected = langProvider.currentLanguage == lang;
              return ListTile(
                title: Text(
                  lang.displayName,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : const Color(0xFF1B2F22),
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                onTap: () {
                  langProvider.setLanguage(lang);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showHelpSheet(LanguageProvider langProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Text(langProvider.translate('help_support'), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
              ),
              title: Text('Kisan Call Center (24x7 Toll Free)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5)),
              subtitle: Text('1800-180-1551 (${langProvider.translate('tap_to_call')})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary)),
              trailing: const Icon(Icons.call_rounded, color: AppColors.primary),
              onTap: () {
                Navigator.pop(ctx);
                DeviceHardwareService().launchPhoneDialer('18001801551');
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accentOrange),
              ),
              title: Text('WhatsApp Krishi Mitra Assistant', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5)),
              subtitle: Text('+91 98260 00000 (${langProvider.translate('tap_to_call')})', style: GoogleFonts.poppins(fontSize: 12)),
              trailing: const Icon(Icons.call_rounded, color: AppColors.accentOrange),
              onTap: () {
                Navigator.pop(ctx);
                DeviceHardwareService().launchPhoneDialer('+919826000000');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressDialog(LanguageProvider langProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Text(langProvider.translate('address_farm_loc'), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 20),
              _buildDialogRow('Village', langProvider.translate('val_village')),
              _buildDialogRow('District & State', langProvider.translate('val_district_state')),
              _buildDialogRow('Nearest Mandi', langProvider.translate('val_nearest_mandi')),
              _buildDialogRow('GPS Location', _gpsCoordinates),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLocating
                    ? null
                    : () async {
                        setSheetState(() => _isLocating = true);
                        final pos = await DeviceHardwareService().getCurrentLocation();
                        setSheetState(() {
                          _isLocating = false;
                          if (pos != null) {
                            _gpsCoordinates = '${pos.latitude.toStringAsFixed(4)}° N, ${pos.longitude.toStringAsFixed(4)}° E';
                          }
                        });
                        setState(() {});
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: _isLocating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location_rounded, size: 18),
                label: Text(
                  _isLocating ? 'Detecting via GPS Hardware...' : langProvider.translate('detect_gps_btn'),
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B8374))),
          Flexible(
            child: Text(
              val,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: const Color(0xFF162D1F)),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, List<Map<String, String>> details) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            ...details.map((d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(d['label']!, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B8374))),
                      Text(d['val']!, style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: const Color(0xFF162D1F))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final name = widget.userProfile?.fullName.isNotEmpty == true
        ? widget.userProfile!.fullName
        : langProvider.translate('farmer_name');
    final mobile = widget.userProfile?.mobileNumber.isNotEmpty == true
        ? widget.userProfile!.mobileNumber
        : '+91 98765 43210';
    final farmerId = widget.userProfile?.farmerId ?? 'MP-SEH-894102';

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
          langProvider.translate('my_profile'),
          style: GoogleFonts.poppins(
            color: const Color(0xFF142B1D),
            fontSize: 18.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================= 1. HERO FARMER PROFILE CARD =================
                  AppFadeSlideAnimation(
                    delay: Duration.zero,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left: Farmer Avatar with camera change button
                          GestureDetector(
                            onTap: () => _changeProfilePhoto(langProvider),
                            child: Stack(
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF136A36), width: 2.2),
                                  ),
                                  child: ClipOval(
                                    child: _customAvatarFile != null
                                        ? (kIsWeb
                                            ? Image.network(_customAvatarFile!.path, width: 68, height: 68, fit: BoxFit.cover)
                                            : Image.file(File(_customAvatarFile!.path), width: 68, height: 68, fit: BoxFit.cover))
                                        : Image.asset(
                                            AppAssets.realFarmerAvatar,
                                            width: 68,
                                            height: 68,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: const Color(0xFFE8F5E9),
                                              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 36),
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF136A36),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right: Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF162E1F),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  mobile.startsWith('+91') ? mobile : '+91 $mobile',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF556F5E),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF136A36)),
                                    const SizedBox(width: 4),
                                    Text(
                                      langProvider.translate('default_location'),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF758A7E),
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
                  ),
                  const SizedBox(height: 14),

                  // ================= 2. ACCOUNT INFORMATION CARD =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 60),
                    child: Container(
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
                        children: [
                          _buildProfileMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: langProvider.translate('personal_info'),
                            onTap: () => _showInfoDialog(langProvider.translate('personal_info'), [
                              {'label': 'Full Name', 'val': name},
                              {'label': 'Farmer ID', 'val': farmerId},
                              {'label': 'Aadhaar Status', 'val': langProvider.translate('val_aadhaar_status')},
                              {'label': 'Total Land', 'val': langProvider.translate('val_total_land_loc')},
                            ]),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0F4F1)),

                          _buildProfileMenuItem(
                            icon: Icons.account_balance_outlined,
                            title: langProvider.translate('bank_details'),
                            onTap: () => _showInfoDialog('${langProvider.translate('bank_details')} (DBT Enabled)', [
                              {'label': 'Bank Name', 'val': langProvider.translate('val_bank_sbi')},
                              {'label': 'Account No.', 'val': '•••• •••• 8941'},
                              {'label': 'IFSC Code', 'val': 'SBIN0001234'},
                              {'label': 'PM-KISAN Status', 'val': langProvider.translate('val_pm_kisan_status')},
                            ]),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0F4F1)),

                          _buildProfileMenuItem(
                            icon: Icons.location_on_outlined,
                            title: langProvider.translate('address_farm_loc'),
                            onTap: () => _showAddressDialog(langProvider),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0F4F1)),

                          _buildProfileMenuItem(
                            icon: Icons.insights_rounded,
                            title: langProvider.translate('sales_mandi_reports'),
                            trailingText: '₹ 25,680',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SalesReportScreen()),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0F4F1)),

                          _buildProfileMenuItem(
                            icon: Icons.translate_rounded,
                            title: langProvider.translate('language'),
                            trailingText: langProvider.currentLanguage.displayName,
                            onTap: () => _openLanguagePicker(context, langProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= 3. FARM & CROP REGISTRATION CARD =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 120),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  langProvider.translate('agri_land_insurance'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF162E1F),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  langProvider.translate('kharif_rabi_badge'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF136A36),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          _buildFarmDetailRow(
                            langProvider.translate('registered_land'),
                            langProvider.translate('val_registered_land'),
                          ),
                          _buildFarmDetailRow(
                            langProvider.translate('kcc'),
                            langProvider.translate('val_kcc_limit'),
                          ),
                          _buildFarmDetailRow(
                            langProvider.translate('crop_insurance'),
                            langProvider.translate('val_crop_insurance'),
                          ),
                          _buildFarmDetailRow(
                            langProvider.translate('primary_crops'),
                            langProvider.translate('val_primary_crops'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= 4. SUPPORT & LOGOUT CARD =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 180),
                    child: Container(
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
                        children: [
                          _buildProfileMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: langProvider.translate('help_support'),
                            onTap: () => _showHelpSheet(langProvider),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0F4F1)),

                          _buildProfileMenuItem(
                            icon: Icons.logout_rounded,
                            title: langProvider.translate('log_out'),
                            iconColor: const Color(0xFFE53935),
                            textColor: const Color(0xFFE53935),
                            onTap: () => _logout(context, langProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ================= 5. GOVT INITIATIVE & VERSION FOOTER =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 240),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            langProvider.translate('govt_footer_1'),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8C9E93),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            langProvider.translate('govt_footer_2'),
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: const Color(0xFFABC0B2),
                            ),
                          ),
                        ],
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

  Widget _buildFarmDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF758A7E)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              val,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF162D1F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    String? trailingText,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? const Color(0xFF162D1F), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? const Color(0xFF162D1F),
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B8374),
                  ),
                ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9EABA2), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
