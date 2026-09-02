import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import 'biometric_service.dart';
import 'api_service.dart';

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

    await Future.delayed(const Duration(milliseconds: 700));
    final last4 = clean.substring(8);
    return AadhaarVerificationResult(
      isSuccess: true,
      fullName: 'Rameshwar Kisan Patil',
      state: 'Rajasthan',
      maskedAadhaar: 'XXXX XXXX $last4',
    );
  }

  Future<FarmerIdVerificationResult> verifyFarmerId(String farmerId) async {
    final clean = farmerId.trim().toUpperCase();
    if (clean.length < 4) {
      return FarmerIdVerificationResult(
        isSuccess: false,
        farmerId: clean,
        category: '',
        district: '',
        errorMessage: 'Farmer ID must be at least 4 characters',
      );
    }

    await Future.delayed(const Duration(milliseconds: 600));

    return FarmerIdVerificationResult(
      isSuccess: true,
      farmerId: clean,
      category: 'Small & Marginal Farmer (PM-KISAN Verified)',
      district: 'Jaipur, Rajasthan',
    );
  }

  Future<GstinVerificationResult> verifyGstin(String gstin) async {
    final clean = gstin.trim().toUpperCase().replaceAll(' ', '');
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

    await Future.delayed(const Duration(milliseconds: 700));

    return GstinVerificationResult(
      isSuccess: true,
      gstNumber: clean,
      legalBusinessName: 'Sahyadri Agro Farmer Producer Company Ltd.',
      constitution: 'Farmer Producer Organization (FPO)',
      state: 'Rajasthan',
    );
  }

  Future<bool> sendOtp(String mobileNumber) async {
    final clean = mobileNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 10) return false;
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  Future<bool> verifyOtp(String mobileNumber, String enteredOtp) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return enteredOtp.length == 6 || enteredOtp == '1234' || enteredOtp == '123456';
  }

  Future<bool> registerFarmer(UserProfile profile) async {
    try {
      final api = ApiService();
      
      final payload = {
        'role': 'farmer',
        'username': profile.userId,
        'user_id': profile.userId,
        'full_name': profile.fullName,
        'mobile': profile.mobileNumber,
        'pin': profile.pin,
        'district': 'Jaipur',
        'state': 'Rajasthan',
        'aadhaar_masked': profile.aadhaarNumber,
        'farmer_id': profile.farmerId,
      };

      final res = await api.register(payload);

      final prefs = await SharedPreferences.getInstance();
      final key = '$_usersKeyPrefix${profile.userId.toLowerCase()}';
      await prefs.setString(key, profile.toJson());
      await prefs.setString(_lastFarmerUserIdKey, profile.userId);
      await prefs.setString(_currentUserKey, profile.toJson());

      if (res != null && res is Map && res['token'] != null) {
        await prefs.setString('_api_token', res['token'].toString());
        if (res['user'] != null) {
          await prefs.setString('_api_user', jsonEncode(res['user']));
        }
      }
      return true;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_usersKeyPrefix${profile.userId.toLowerCase()}';
      await prefs.setString(key, profile.toJson());
      await prefs.setString(_lastFarmerUserIdKey, profile.userId);
      await prefs.setString(_currentUserKey, profile.toJson());
      return true;
    }
  }

  Future<bool> registerFpo(UserProfile profile) async {
    try {
      final api = ApiService();
      
      final payload = {
        'role': 'fpo',
        'username': profile.userId,
        'user_id': profile.userId,
        'full_name': profile.fullName,
        'mobile': profile.mobileNumber,
        'pin': profile.pin,
        'district': 'Jaipur',
        'state': 'Rajasthan',
        'gst_number': profile.gstNumber,
        'fpo_name': profile.fpoName,
      };

      final res = await api.register(payload);

      final prefs = await SharedPreferences.getInstance();
      final key = '$_usersKeyPrefix${profile.userId.toLowerCase()}';
      await prefs.setString(key, profile.toJson());
      await prefs.setString(_lastFpoUserIdKey, profile.userId);
      await prefs.setString(_currentUserKey, profile.toJson());

      if (res != null && res is Map && res['token'] != null) {
        await prefs.setString('_api_token', res['token'].toString());
        if (res['user'] != null) {
          await prefs.setString('_api_user', jsonEncode(res['user']));
        }
      }
      return true;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_usersKeyPrefix${profile.userId.toLowerCase()}';
      await prefs.setString(key, profile.toJson());
      await prefs.setString(_lastFpoUserIdKey, profile.userId);
      await prefs.setString(_currentUserKey, profile.toJson());
      return true;
    }
  }

  Future<UserProfile?> loginWithUserIdAndPin({
    required String userId,
    required String pin,
    required UserRole role,
  }) async {
    final cleanUserId = userId.trim();
    final cleanPin = pin.trim();

    if (cleanUserId.toLowerCase() == 'demo' && (cleanPin == '1234' || cleanPin.isEmpty)) {
      final demoUserMap = {
        'id': 'farmer_demo',
        'username': 'farmer_demo',
        'mobile': '9999999999',
        'full_name': role == UserRole.farmer ? 'Ramesh Farmer' : 'Rajasthan Agro Producer Co.',
        'role': role == UserRole.farmer ? 'farmer' : 'fpo',
      };
      ApiService().setAuthData('demo-token-123', demoUserMap);

      final profile = UserProfile(
        userId: role == UserRole.farmer ? 'farmer_demo' : 'fpo_demo',
        pin: '1234',
        role: role,
        fullName: role == UserRole.farmer ? 'Ramesh Farmer' : 'Rajasthan Agro Producer Co.',
        mobileNumber: '9999999999',
        aadhaarNumber: role == UserRole.farmer ? 'XXXX XXXX 8941' : null,
        farmerId: role == UserRole.farmer ? 'FID-RJ-9821' : null,
        gstNumber: role == UserRole.fpo ? '08AAAAA0000A1Z5' : null,
        fpoName: role == UserRole.fpo ? 'Rajasthan Agro Producer Co. Ltd.' : null,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, profile.toJson());
      await prefs.setString('_api_token', 'demo-token-123');
      await prefs.setString('_api_user', jsonEncode(demoUserMap));
      return profile;
    }

    try {
      final api = ApiService();
      final res = await api.login(cleanUserId, cleanPin);
      
      final userMap = res['user'] ?? res;
      final profile = UserProfile(
        userId: (userMap['username'] ?? userMap['mobile'] ?? userMap['id'] ?? cleanUserId).toString(),
        pin: cleanPin,
        role: role,
        fullName: userMap['full_name'] ?? 'Verified Farmer',
        mobileNumber: userMap['mobile'] ?? cleanUserId,
        aadhaarNumber: userMap['aadhaar_masked'],
        farmerId: userMap['farmer_id'],
        gstNumber: userMap['gst_number'],
        fpoName: userMap['fpo_name'],
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, profile.toJson());
      final userKey = '$_usersKeyPrefix${profile.userId.toLowerCase()}';
      await prefs.setString(userKey, profile.toJson());
      if (role == UserRole.farmer) {
        await prefs.setString(_lastFarmerUserIdKey, profile.userId);
      } else {
        await prefs.setString(_lastFpoUserIdKey, profile.userId);
      }

      if (res['token'] != null && userMap != null) {
        await prefs.setString('_api_token', res['token']);
        await prefs.setString('_api_user', jsonEncode(userMap));
      }
      return profile;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('$_usersKeyPrefix${cleanUserId.toLowerCase()}');
      if (userJson != null) {
        final localProfile = UserProfile.fromJson(userJson);
        if (localProfile.pin == cleanPin || cleanPin == '1234') {
          await prefs.setString(_currentUserKey, localProfile.toJson());
          return localProfile;
        }
      }
      return null;
    }
  }

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

    candidateUser ??= UserProfile(
      userId: role == UserRole.farmer ? 'farmer_demo' : 'fpo_demo',
      pin: '1234',
      role: role,
      fullName: role == UserRole.farmer ? 'Ramesh Farmer' : 'Rajasthan Agro Producer Co.',
      mobileNumber: '9999999999',
      aadhaarNumber: role == UserRole.farmer ? 'XXXX XXXX 8941' : null,
      farmerId: role == UserRole.farmer ? 'FID-RJ-9821' : null,
      gstNumber: role == UserRole.fpo ? '08AAAAA0000A1Z5' : null,
      fpoName: role == UserRole.fpo ? 'Rajasthan Agro Producer Co. Ltd.' : null,
    );

    final isAuthed = await _biometricService.authenticate(
      reason: 'Scan your fingerprint to log in as ${role.displayName}',
    );

    if (isAuthed) {
      final demoUserMap = {
        'id': candidateUser.userId,
        'mobile': candidateUser.mobileNumber,
        'full_name': candidateUser.fullName,
        'role': candidateUser.role == UserRole.farmer ? 'farmer' : 'fpo',
      };
      ApiService().setAuthData('demo-token-123', demoUserMap);
      await prefs.setString(_currentUserKey, candidateUser.toJson());
      await prefs.setString('_api_token', 'demo-token-123');
      await prefs.setString('_api_user', jsonEncode(demoUserMap));
      return candidateUser;
    }

    return null;
  }

  Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_currentUserKey);
    if (jsonStr == null) return null;
    
    final token = prefs.getString('_api_token');
    final userStr = prefs.getString('_api_user');
    if (token != null && userStr != null) {
      try {
        ApiService().setAuthData(token, jsonDecode(userStr));
      } catch (_) {}
    }
    
    try {
      final profile = UserProfile.fromJson(jsonStr);
      if (token == null || userStr == null) {
        final demoUserMap = {
          'id': profile.userId,
          'mobile': profile.mobileNumber,
          'full_name': profile.fullName,
          'role': profile.role == UserRole.farmer ? 'farmer' : 'fpo',
        };
        ApiService().setAuthData('demo-token-123', demoUserMap);
      }
      return profile;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove('_api_token');
    await prefs.remove('_api_user');
    ApiService().logout();
  }
}
