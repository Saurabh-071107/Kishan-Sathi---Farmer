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

class FarmerRegisterScreen extends StatefulWidget {
  const FarmerRegisterScreen({super.key});

  @override
  State<FarmerRegisterScreen> createState() => _FarmerRegisterScreenState();
}

class _FarmerRegisterScreenState extends State<FarmerRegisterScreen> {
  final AuthService _authService = AuthService();
  int _currentStep = 0;

  // Step 1: Aadhaar
  final TextEditingController _aadhaarController = TextEditingController();
  bool _isVerifyingAadhaar = false;
  AadhaarVerificationResult? _aadhaarResult;

  // Step 2: Farmer ID
  final TextEditingController _farmerIdController = TextEditingController();
  bool _isVerifyingFarmerId = false;
  FarmerIdVerificationResult? _farmerIdResult;

  // Step 3: Mobile & OTP
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isOtpVerified = false;

  // Step 4: User ID & PIN
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _hidePin = true;
  bool _hideConfirmPin = true;
  bool _enableBiometrics = true;
  bool _isSubmitting = false;

  final List<String> _stepTitles = [
    'Aadhaar Verification',
    'Farmer ID Verification',
    'Mobile OTP',
    'Set Credentials',
  ];

  @override
  void dispose() {
    _aadhaarController.dispose();
    _farmerIdController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _userIdController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  // Action: Verify Aadhaar
  Future<void> _verifyAadhaar() async {
    final aadhaar = _aadhaarController.text.trim();
    if (aadhaar.replaceAll(' ', '').length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 12-digit Aadhaar number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifyingAadhaar = true);
    final result = await _authService.verifyAadhaar(aadhaar);
    setState(() {
      _isVerifyingAadhaar = false;
      _aadhaarResult = result;
    });

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aadhaar verified successfully via UIDAI e-KYC!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Aadhaar verification failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Action: Verify Farmer ID
  Future<void> _verifyFarmerId() async {
    final fid = _farmerIdController.text.trim();
    if (fid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Farmer ID / PM-KISAN ID'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifyingFarmerId = true);
    final result = await _authService.verifyFarmerId(fid);
    setState(() {
      _isVerifyingFarmerId = false;
      _farmerIdResult = result;
    });

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farmer ID verified successfully in state registry!'),
            backgroundColor: AppColors.success,
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
          content: Text('OTP sent to your mobile number! (Use 123456)'),
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

  // Action: Submit Farmer Registration
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
      role: UserRole.farmer,
      fullName: _aadhaarResult?.fullName ?? 'Verified Farmer',
      mobileNumber: _mobileController.text.trim(),
      aadhaarNumber: _aadhaarResult?.maskedAadhaar ?? 'XXXX XXXX 8941',
      farmerId: _farmerIdResult?.farmerId ?? _farmerIdController.text.trim(),
      biometricEnabled: _enableBiometrics,
    );

    try {
      await _authService.registerFarmer(profile);

      setState(() => _isSubmitting = false);

      if (mounted) {
        FocusScope.of(context).unfocus();
        // Show success dialog and navigate to Dashboard
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
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'Registration Successful!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome, ${profile.fullName}!\nYour Farmer Account is ready.',
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
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => DashboardScreen(userProfile: profile),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Dashboard'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Farmer Registration',
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
                  _buildStep1Aadhaar(),
                  _buildStep2FarmerId(),
                  _buildStep3MobileOtp(),
                  _buildStep4Credentials(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 1: Aadhaar
  Widget _buildStep1Aadhaar() {
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
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.credit_card_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 1: Aadhaar e-KYC',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Enter your 12-digit Aadhaar number',
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
            label: 'Aadhaar Card Number',
            hint: 'e.g. 1234 5678 9012',
            controller: _aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 14,
            prefixIcon: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _AadhaarInputFormatter(),
            ],
          ),
          const SizedBox(height: 16),

          if (_aadhaarResult?.isSuccess == true) ...[
            VerifiedBadgeCard(
              title: _aadhaarResult!.fullName,
              subtitle: 'Aadhaar: ${_aadhaarResult!.maskedAadhaar}',
              extraInfo: 'State: ${_aadhaarResult!.state}',
              icon: Icons.verified_user_rounded,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => _currentStep = 1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Proceed to Farmer ID'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: _isVerifyingAadhaar ? null : _verifyAadhaar,
              child: _isVerifyingAadhaar
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Verify Aadhaar'),
            ),
          ],
        ],
      ),
    ),
  );
}

  // STEP 2: Farmer ID
  Widget _buildStep2FarmerId() {
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
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.badge_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 2: Farmer ID / PM-KISAN',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Enter your state or central Farmer ID',
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
              label: 'Farmer ID / PM-KISAN Beneficiary ID',
              hint: 'e.g. FID-2026-MH90',
              controller: _farmerIdController,
              textCapitalization: TextCapitalization.characters,
              prefixIcon: const Icon(Icons.agriculture_rounded, color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            if (_farmerIdResult?.isSuccess == true) ...[
              VerifiedBadgeCard(
                title: 'Farmer ID: ${_farmerIdResult!.farmerId}',
                subtitle: _farmerIdResult!.category,
                extraInfo: 'Location: ${_farmerIdResult!.district}',
                icon: Icons.eco_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: const Row(
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
                onPressed: _isVerifyingFarmerId ? null : _verifyFarmerId,
                child: _isVerifyingFarmerId
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify Farmer ID'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // STEP 3: Mobile & OTP
  Widget _buildStep3MobileOtp() {
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
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_android_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 3: Mobile Number & OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Verify your registered phone number',
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
              prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),

            if (!_otpSent && !_isOtpVerified)
              ElevatedButton(
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
                prefixIcon: const Icon(Icons.lock_clock_rounded, color: AppColors.primary),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
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
                subtitle: 'Mobile Number Verified via OTP',
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setState(() => _currentStep = 3);
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

  // STEP 4: Credentials (User ID & PIN)
  Widget _buildStep4Credentials() {
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
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 4: Create Credentials',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Set your login User ID and 4-digit PIN',
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
              label: 'Choose User ID / Username',
              hint: 'e.g. ramesh_patil',
              controller: _userIdController,
              prefixIcon: const Icon(Icons.person_pin_rounded, color: AppColors.primary),
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
              prefixIcon: const Icon(Icons.password_rounded, color: AppColors.primary),
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
              prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
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
                  const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 26),
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
                          'Login quickly with biometric scan',
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
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _enableBiometrics = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRegistration,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Complete Farmer Registration'),
            ),
          ],
        ),
      ),
    );
  }
}

// Formatter for Aadhaar formatting "1234 5678 9012"
class _AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length && nonZeroIndex < 12) {
        buffer.write(' ');
      }
    }
    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
