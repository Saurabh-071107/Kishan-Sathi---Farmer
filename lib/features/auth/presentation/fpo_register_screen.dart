import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/auth_service.dart';
import '../../dashboard/dashboard_screen.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/step_indicator.dart';
import 'widgets/verified_badge_card.dart';

class FpoRegisterScreen extends StatefulWidget {
  const FpoRegisterScreen({super.key});

  @override
  State<FpoRegisterScreen> createState() => _FpoRegisterScreenState();
}

class _FpoRegisterScreenState extends State<FpoRegisterScreen> {
  final AuthService _authService = AuthService();
  int _currentStep = 0;

  // Step 1: GSTIN
  final TextEditingController _gstController = TextEditingController();
  bool _isVerifyingGst = false;
  GstinVerificationResult? _gstResult;

  // Step 2: Mobile & OTP
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isOtpVerified = false;

  // Step 3: User ID & PIN
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _hidePin = true;
  bool _hideConfirmPin = true;
  bool _enableBiometrics = true;
  bool _isSubmitting = false;

  final List<String> _stepTitles = [
    'GSTIN Verification',
    'Mobile OTP',
    'Set Credentials',
  ];

  @override
  void dispose() {
    _gstController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _userIdController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  // Action: Verify GSTIN
  Future<void> _verifyGstin() async {
    final gstin = _gstController.text.trim().toUpperCase();
    if (gstin.length != 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GSTIN must be exactly 15 characters (e.g. 27AAAAA0000A1Z5)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifyingGst = true);
    final result = await _authService.verifyGstin(gstin);
    setState(() {
      _isVerifyingGst = false;
      _gstResult = result;
    });

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FPO GSTIN verified successfully on GST Portal!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'GSTIN verification failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Action: Send Mobile OTP
  Future<void> _sendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    final sent = await _authService.sendOtp(mobile);
    setState(() {
      _isSendingOtp = false;
      _otpSent = sent;
    });

    if (sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to authorized FPO mobile! (Use 123456)'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  // Action: Verify OTP
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);
    final verified = await _authService.verifyOtp(_mobileController.text, otp);
    setState(() {
      _isVerifyingOtp = false;
      _isOtpVerified = verified;
    });

    if (verified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number verified successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  // Action: Submit FPO Registration
  Future<void> _submitRegistration() async {
    final userId = _userIdController.text.trim();
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (userId.isEmpty || userId.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID must be at least 3 characters'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (pin.length != 4 || !RegExp(r'^[0-9]{4}$').hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security PIN must be exactly 4 digits'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security PIN and Confirm PIN do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final profile = UserProfile(
      userId: userId,
      pin: pin,
      role: UserRole.fpo,
      fullName: _gstResult?.legalBusinessName ?? 'Registered FPO Entity',
      mobileNumber: _mobileController.text.trim(),
      gstNumber: _gstResult?.gstNumber ?? _gstController.text.trim().toUpperCase(),
      fpoName: _gstResult?.legalBusinessName ?? 'Sahyadri Agro Producer Co. Ltd.',
      biometricEnabled: _enableBiometrics,
    );

    await _authService.registerFpo(profile);

    setState(() => _isSubmitting = false);

    if (mounted) {
      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business_center_rounded, color: AppColors.accentOrange, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'FPO Registered!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome, ${profile.fpoName}!\nYour FPO Account is successfully active.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => DashboardScreen(userProfile: profile),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Go to FPO Dashboard'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'FPO Registration',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Indicator
              StepIndicator(
                currentStep: _currentStep,
                steps: _stepTitles,
              ),
              const SizedBox(height: 24),

              // Dynamic Step Body
              IndexedStack(
                index: _currentStep,
                children: [
                  _buildStep1Gst(),
                  _buildStep2MobileOtp(),
                  _buildStep3Credentials(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 1: GSTIN Verification
  Widget _buildStep1Gst() {
    return Card(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.accentOrange, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 1: FPO GSTIN',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Enter your 15-character FPO GST number',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'FPO GSTIN',
              hint: 'e.g. 27AAAAA0000A1Z5',
              controller: _gstController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 15,
              prefixIcon: const Icon(Icons.domain_verification_rounded, color: AppColors.accentOrange),
            ),
            const SizedBox(height: 16),

            if (_gstResult?.isSuccess == true) ...[
              VerifiedBadgeCard(
                title: _gstResult!.legalBusinessName,
                subtitle: 'GSTIN: ${_gstResult!.gstNumber}',
                extraInfo: '${_gstResult!.constitution} • ${_gstResult!.state}',
                icon: Icons.business_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setState(() => _currentStep = 1);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Proceed to Mobile OTP'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
                onPressed: _isVerifyingGst ? null : _verifyGstin,
                child: _isVerifyingGst
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify FPO GSTIN'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // STEP 2: Mobile & OTP
  Widget _buildStep2MobileOtp() {
    return Card(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_android_rounded, color: AppColors.accentOrange, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 2: Authorized Mobile & OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Verify authorized FPO representative phone',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'Mobile Number',
              hint: '10-digit mobile number',
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              enabled: !_isOtpVerified,
              prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.accentOrange),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),

            if (!_otpSent && !_isOtpVerified)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
                onPressed: _isSendingOtp ? null : _sendOtp,
                child: _isSendingOtp
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send Verification OTP'),
              ),

            if (_otpSent && !_isOtpVerified) ...[
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Enter 6-Digit OTP',
                hint: 'e.g. 123456',
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                prefixIcon: const Icon(Icons.lock_clock_rounded, color: AppColors.accentOrange),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
                onPressed: _isVerifyingOtp ? null : _verifyOtp,
                child: _isVerifyingOtp
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify OTP'),
              ),
            ],

            if (_isOtpVerified) ...[
              const SizedBox(height: 8),
              VerifiedBadgeCard(
                title: '+91 ${_mobileController.text}',
                subtitle: 'FPO Representative Mobile Verified',
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setState(() => _currentStep = 2);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Proceed to Credentials'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // STEP 3: Credentials (User ID & PIN)
  Widget _buildStep3Credentials() {
    return Card(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.security_rounded, color: AppColors.accentOrange, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 3: Create FPO Credentials',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Set your FPO login User ID and 4-digit PIN',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User ID
            CustomTextField(
              label: 'Choose FPO User ID / Username',
              hint: 'e.g. sahyadri_fpo',
              controller: _userIdController,
              prefixIcon: const Icon(Icons.business_rounded, color: AppColors.accentOrange),
            ),
            const SizedBox(height: 16),

            // 4-Digit PIN
            CustomTextField(
              label: 'Set 4-Digit Security PIN',
              hint: '• • • •',
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: _hidePin,
              prefixIcon: const Icon(Icons.password_rounded, color: AppColors.accentOrange),
              suffixIcon: IconButton(
                icon: Icon(_hidePin ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                onPressed: () => setState(() => _hidePin = !_hidePin),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Confirm 4-Digit PIN
            CustomTextField(
              label: 'Confirm 4-Digit Security PIN',
              hint: '• • • •',
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: _hideConfirmPin,
              prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.accentOrange),
              suffixIcon: IconButton(
                icon: Icon(_hideConfirmPin ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                onPressed: () => setState(() => _hideConfirmPin = !_hideConfirmPin),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Fingerprint toggle option
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fingerprint_rounded, color: AppColors.accentOrange, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Fingerprint Login',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Fast FPO biometric authentication',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enableBiometrics,
                    activeThumbColor: AppColors.accentOrange,
                    onChanged: (val) => setState(() => _enableBiometrics = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
              onPressed: _isSubmitting ? null : _submitRegistration,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Complete FPO Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
