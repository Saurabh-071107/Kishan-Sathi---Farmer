import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import 'biometric_service.dart';

class AadhaarVerificationResult {
  final bool isSuccess;
  final String fullName;
  final String state;
  final String maskedAadhaar;
  final String? errorMessage;

  AadhaarVerificationResult({
    required this.isSuccess,
    required this.fullName,
    required this.state,
    required this.maskedAadhaar,
    this.errorMessage,
  });
}

class FarmerIdVerificationResult {
  final bool isSuccess;
  final String farmerId;
  final String category;
  final String district;
  final String? errorMessage;

  FarmerIdVerificationResult({
    required this.isSuccess,
    required this.farmerId,
    required this.category,
    required this.district,
    this.errorMessage,
  });
}

class GstinVerificationResult {
  final bool isSuccess;
  final String gstNumber;
  final String legalBusinessName;
  final String constitution;
  final String state;
  final String? errorMessage;

  GstinVerificationResult({
    required this.isSuccess,
    required this.gstNumber,
    required this.legalBusinessName,
    required this.constitution,
    required this.state,
    this.errorMessage,
  });
}

class AuthService {
  static const String _usersKeyPrefix = 'registered_user_';
  static const String _currentUserKey = 'current_logged_in_user';
  static const String _lastFarmerUserIdKey = 'last_farmer_user_id';
  static const String _lastFpoUserIdKey = 'last_fpo_user_id';

  final BiometricService _biometricService = BiometricService();

  // 1. Aadhaar eKYC Verification
  Future<AadhaarVerificationResult> verifyAadhaar(String aadhaar) async {
    final clean = aadhaar.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 12 || !RegExp(r'^[0-9]{12}$').hasMatch(clean)) {
      return AadhaarVerificationResult(
        isSuccess: false,
        fullName: '',
        state: '',
        maskedAadhaar: '',
        errorMessage: 'Please enter a valid 12-digit Aadhaar number',
      );
    }

    // Simulate UIDAI verification delay
    await Future.delayed(const Duration(milliseconds: 900));

    final last4 = clean.substring(8);
    return AadhaarVerificationResult(
      isSuccess: true,
      fullName: 'Rameshwar Kisan Patil',
      state: 'Maharashtra',
      maskedAadhaar: 'XXXX XXXX $last4',
    );
  }

  // 2. Farmer ID (PM-KISAN / State Registry) Verification
  Future<FarmerIdVerificationResult> verifyFarmerId(String farmerId) async {
    final clean = farmerId.trim().toUpperCase();
    if (clean.length < 6) {
      return FarmerIdVerificationResult(
        isSuccess: false,
        farmerId: clean,
        category: '',
        district: '',
        errorMessage: 'Farmer ID must be at least 6 characters',
      );
    }

    // Simulate verification
    await Future.delayed(const Duration(milliseconds: 800));

    return FarmerIdVerificationResult(
      isSuccess: true,
      farmerId: clean,
      category: 'Small & Marginal Farmer (PM-KISAN Verified)',
      district: 'Nashik, Maharashtra',
    );
  }

  // 3. FPO GSTIN Verification
  Future<GstinVerificationResult> verifyGstin(String gstin) async {
    final clean = gstin.trim().toUpperCase().replaceAll(' ', '');
    // GSTIN format: 2 digits state + 10 chars PAN + 1 char entity + 'Z' + 1 check digit
    final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');

    if (clean.length != 15 || !gstRegex.hasMatch(clean)) {
      return GstinVerificationResult(
        isSuccess: false,
        gstNumber: clean,
        legalBusinessName: '',
        constitution: '',
        state: '',
        errorMessage: 'Invalid GSTIN format (e.g. 27AAAAA0000A1Z5)',
      );
    }

    // Simulate GST portal verification
    await Future.delayed(const Duration(milliseconds: 900));

    return GstinVerificationResult(
      isSuccess: true,
      gstNumber: clean,
      legalBusinessName: 'Sahyadri Agro Farmer Producer Company Ltd.',
      constitution: 'Farmer Producer Organization (FPO)',
      state: 'Maharashtra',
    );
  }

  // 4. Mobile OTP Verification (Simulated SMS Gateway)
  Future<bool> sendOtp(String mobileNumber) async {
    final clean = mobileNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 10) return false;
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> verifyOtp(String mobileNumber, String enteredOtp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Accepts test OTP "123456" or any 6-digit number in mock environment
    return enteredOtp.length == 6;
  }

  // 5. Register Farmer
  Future<bool> registerFarmer(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_usersKeyPrefix${profile.userId.toLowerCase()}';
    await prefs.setString(key, profile.toJson());
    await prefs.setString(_lastFarmerUserIdKey, profile.userId);
    await prefs.setString(_currentUserKey, profile.toJson());
    return true;
  }

  // 6. Register FPO
  Future<bool> registerFpo(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_usersKeyPrefix${profile.userId.toLowerCase()}';
    await prefs.setString(key, profile.toJson());
    await prefs.setString(_lastFpoUserIdKey, profile.userId);
    await prefs.setString(_currentUserKey, profile.toJson());
    return true;
  }

  // 7. Login with User ID and PIN
  Future<UserProfile?> loginWithUserIdAndPin({
    required String userId,
    required String pin,
    required UserRole role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_usersKeyPrefix${userId.trim().toLowerCase()}';
    final userJson = prefs.getString(key);

    if (userJson != null) {
      final profile = UserProfile.fromJson(userJson);
      if (profile.role == role && profile.pin == pin.trim()) {
        await prefs.setString(_currentUserKey, profile.toJson());
        return profile;
      }
    }

    // Default Fallback Demo user for instant testing if no user created yet
    if (userId.trim().toLowerCase() == 'demo' && pin.trim() == '1234') {
      final demoProfile = UserProfile(
        userId: 'demo',
        pin: '1234',
        role: role,
        fullName: role == UserRole.farmer ? 'Rameshwar Patil' : 'Bharat Agro Producer Co.',
        mobileNumber: '9876543210',
        aadhaarNumber: role == UserRole.farmer ? 'XXXX XXXX 8941' : null,
        farmerId: role == UserRole.farmer ? 'FID-2026-MH90' : null,
        gstNumber: role == UserRole.fpo ? '27AABCS1429B1ZB' : null,
        fpoName: role == UserRole.fpo ? 'Bharat Agro Producer Co. Ltd.' : null,
      );
      await prefs.setString(_currentUserKey, demoProfile.toJson());
      return demoProfile;
    }

    return null;
  }

  // 8. Login with Biometrics
  Future<UserProfile?> loginWithBiometrics(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUserIdKey = role == UserRole.farmer ? _lastFarmerUserIdKey : _lastFpoUserIdKey;
    final lastUserId = prefs.getString(lastUserIdKey);

    UserProfile? candidateUser;
    if (lastUserId != null) {
      final userJson = prefs.getString('$_usersKeyPrefix${lastUserId.toLowerCase()}');
      if (userJson != null) {
        candidateUser = UserProfile.fromJson(userJson);
      }
    }

    // If no previous user, create or use demo candidate
    candidateUser ??= UserProfile(
      userId: role == UserRole.farmer ? 'farmer_demo' : 'fpo_demo',
      pin: '1234',
      role: role,
      fullName: role == UserRole.farmer ? 'Rameshwar Patil (Farmer)' : 'Sahyadri Agro Producer Co.',
      mobileNumber: '9876543210',
      aadhaarNumber: role == UserRole.farmer ? 'XXXX XXXX 4589' : null,
      farmerId: role == UserRole.farmer ? 'FID-MH-5521' : null,
      gstNumber: role == UserRole.fpo ? '27AAAAA0000A1Z5' : null,
      fpoName: role == UserRole.fpo ? 'Sahyadri Agro Producer Co. Ltd.' : null,
    );

    // Prompt biometric scan
    final isAuthed = await _biometricService.authenticate(
      reason: 'Scan your fingerprint to log in as ${role.displayName}',
    );

    if (isAuthed) {
      await prefs.setString(_currentUserKey, candidateUser.toJson());
      return candidateUser;
    }

    return null;
  }

  // Current session
  Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_currentUserKey);
    if (jsonStr == null) return null;
    try {
      return UserProfile.fromJson(jsonStr);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
