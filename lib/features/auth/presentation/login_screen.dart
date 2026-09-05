import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/auth_service.dart';
import '../../dashboard/dashboard_screen.dart';
import 'farmer_register_screen.dart';
import 'fpo_register_screen.dart';
import 'widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  final UserRole initialRole;

  const LoginScreen({super.key, this.initialRole = UserRole.farmer});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  late UserRole _selectedRole;

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _hidePin = true;
  bool _isLoading = false;
  bool _isBiometricLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loginWithPin() async {
    final userId = _userIdController.text.trim();
    final pin = _pinController.text.trim();

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your User ID'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your 4-digit Security PIN'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final profile = await _authService.loginWithUserIdAndPin(
      userId: userId,
      pin: pin,
      role: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (profile != null && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(userProfile: profile),
        ),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid User ID or PIN for ${_selectedRole.displayName}. (Tip: Use registered account or demo / 1234)',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _loginWithFingerprint() async {
    setState(() => _isBiometricLoading = true);

    final profile = await _authService.loginWithBiometrics(_selectedRole);

    setState(() => _isBiometricLoading = false);

    if (profile != null && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(userProfile: profile),
        ),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric verification cancelled or unavailable on device.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _navigateToRegister() {
    if (_selectedRole == UserRole.farmer) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FarmerRegisterScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FpoRegisterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFarmer = _selectedRole == UserRole.farmer;
    final primaryColor = isFarmer ? AppColors.primary : AppColors.accentOrange;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Login to Platform',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / Top Icon
              Center(
                child: Image.asset(
                  AppAssets.appLogo,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.agriculture_rounded,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Sign in to access your agricultural dashboard',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Role Segmented Switch
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = UserRole.farmer),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isFarmer ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isFarmer
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: isFarmer ? AppColors.primary : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Farmer',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: isFarmer ? FontWeight.bold : FontWeight.w500,
                                  color: isFarmer ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = UserRole.fpo),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isFarmer ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !isFarmer
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.groups_rounded,
                                size: 18,
                                color: !isFarmer ? AppColors.accentOrange : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'FPO',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: !isFarmer ? FontWeight.bold : FontWeight.w500,
                                  color: !isFarmer ? AppColors.accentOrange : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Login Form Card
              Card(
                elevation: 1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // User ID Field
                    CustomTextField(
                      label: isFarmer ? 'Farmer User ID' : 'FPO User ID',
                      hint: 'Enter registered User ID or 10-digit Mobile',
                      controller: _userIdController,
                      prefixIcon: Icon(
                        isFarmer ? Icons.person_pin_rounded : Icons.business_rounded,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Security PIN Field
                    CustomTextField(
                      label: '4-Digit Security PIN',
                      hint: '• • • •',
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: _hidePin,
                      prefixIcon: Icon(Icons.password_rounded, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(_hidePin ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                        onPressed: () => setState(() => _hidePin = !_hidePin),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 20),

                    // Login with PIN Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shadowColor: primaryColor.withValues(alpha: 0.4),
                      ),
                      onPressed: _isLoading ? null : _loginWithPin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Login with User ID & PIN'),
                    ),
                    const SizedBox(height: 18),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR QUICK LOGIN',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Fingerprint Biometric Login Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isBiometricLoading ? null : _loginWithFingerprint,
                      icon: _isBiometricLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.fingerprint_rounded, size: 24),
                      label: Text(
                        'Login using Fingerprint',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
              const SizedBox(height: 24),

              // Register Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToRegister,
                    child: Text(
                      isFarmer ? 'Register as Farmer' : 'Register as FPO',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        decoration: TextDecoration.underline,
                        decorationColor: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
