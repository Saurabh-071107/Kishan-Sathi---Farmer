import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// Production backend on Railway. Override at build time if needed:
  /// --dart-define=API_BASE_URL=https://your-custom-url.up.railway.app/api
  static const String _productionBaseUrl =
      'https://kishan-sathi-backend-production.up.railway.app/api';

  static const String configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _productionBaseUrl,
  );

  static final List<String> _candidateBaseUrls = [
    configuredBaseUrl,
    _productionBaseUrl,
    'http://localhost:3000/api',
    'http://10.0.2.2:3000/api',
    'http://192.168.107.214:3000/api',
    'http://192.168.46.23:3000/api',
    'http://127.0.0.1:3000/api',
  ];

  String _activeBaseUrl = configuredBaseUrl;
  String? _token;
  Map<String, dynamic>? _user;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => _activeBaseUrl;

  void setAuthData(String token, Map<String, dynamic> user) {
    _token = token;
    _user = user;
  }

  void logout() {
    _token = null;
    _user = null;
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }



  Future<http.Response> _executeWithFallback(Future<http.Response> Function(String base) requestFn) async {
    // Primary URL gets 10s (Railway HTTPS may have cold-start latency)
    try {
      final res = await requestFn(_activeBaseUrl).timeout(const Duration(milliseconds: 10000));
      return res;
    } catch (_) {
      for (final candidate in _candidateBaseUrls) {
        if (candidate == _activeBaseUrl) continue;
        // HTTPS candidates get 8s; local candidates get 3s
        final isHttps = candidate.startsWith('https://');
        final timeout = isHttps ? const Duration(milliseconds: 8000) : const Duration(milliseconds: 3000);
        try {
          final res = await requestFn(candidate).timeout(timeout);
          _activeBaseUrl = candidate;
          return res;
        } catch (_) {
          continue;
        }
      }
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
    final response = await _executeWithFallback(
      (base) => http.get(Uri.parse('$base$endpoint'), headers: _headers),
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await _executeWithFallback(
      (base) => http.post(
        Uri.parse('$base$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      ),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await _executeWithFallback(
      (base) => http.put(
        Uri.parse('$base$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      ),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        return decoded['data'] ?? decoded;
      }
      throw Exception(decoded['message'] ?? 'API Error');
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  // --- Specific Endpoints for Farmer ---

  Future<dynamic> login(String mobile, String pin) async {
    final res = await post('/auth/login', {'mobile': mobile, 'pin': pin});
    if (res['token'] != null) {
      setAuthData(res['token'], res['user']);
    }
    return res;
  }

  Future<dynamic> register(Map<String, dynamic> payload) async {
    final res = await post('/auth/register', payload);
    if (res['token'] != null) {
      setAuthData(res['token'], res['user']);
    }
    return res;
  }

  Future<List<dynamic>> getNearbyWarehouses([String? district]) async {
    try {
      final query = (district != null && district.isNotEmpty) ? '?district=$district' : '';
      final res = await get('/warehouses$query');
      if (res is List) return res;
      if (res is Map && res['data'] is List) return res['data'] as List<dynamic>;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getMyProduce() async {
    try {
      final farmerId = _user?['id'];
      final endpoint = farmerId != null ? '/produce?farmer_id=$farmerId' : '/produce';
      final res = await get(endpoint);
      if (res is List) return res;
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<dynamic> addProduce(Map<String, dynamic> produceData) async {
    return await post('/produce', produceData);
  }

  Future<List<dynamic>> getNotifications() async {
    try {
      final res = await get('/notifications');
      if (res is List) return res;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<dynamic> getFarmerDashboardStats() async {
    try {
      final farmerId = _user?['id'] ?? _user?['username'] ?? _user?['mobile'] ?? 'farmer_demo';
      final res = await get('/farmers/$farmerId/dashboard');
      if (res is Map<String, dynamic> && res.isNotEmpty) {
        return res;
      }
    } catch (_) {}
    try {
      final res = await get('/farmers/farmer_demo/dashboard');
      if (res is Map<String, dynamic> && res.isNotEmpty) {
        return res;
      }
    } catch (_) {}
    return {
      'totalRevenue': '₹ 0',
      'totalSold': '0.00 MT',
      'pendingVerification': '0.00 MT',
      'activeOrders': 0,
      'newOrders': 0,
      'processingOrders': 0,
      'completedOrders': 0,
    };
  }

  Future<List<dynamic>> getFarmerOrders() async {
    try {
      final farmerId = _user?['id'] ?? _user?['username'] ?? _user?['mobile'];
      if (farmerId != null) {
        final res = await get('/farmers/$farmerId/orders');
        if (res is List && res.isNotEmpty) return res;
      }
      final demoRes = await get('/farmers/farmer_demo/orders');
      if (demoRes is List && demoRes.isNotEmpty) return demoRes;

      final res = await get('/orders');
      if (res is List) return res;
      return [];
    } catch (_) {
      return [];
    }
  }


  Future<List<dynamic>> getBroadcastDemands({String? district, String? cropName, String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (district != null && district.isNotEmpty) queryParams['district'] = district;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (cropName != null && cropName.isNotEmpty) queryParams['crop_name'] = cropName;
      final farmerId = _user?['id'];
      if (farmerId != null) queryParams['farmer_id'] = farmerId.toString();
      final queryString = queryParams.isNotEmpty ? '?${Uri(queryParameters: queryParams).query}' : '';
      final res = await get('/orders/broadcasts$queryString');
      if (res is List) return res;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<dynamic> acceptBroadcastDemand(String broadcastId, {String? produceId}) async {
    return await post('/orders/broadcasts/$broadcastId/accept', {
      if (produceId != null) 'produce_id': produceId,
    });
  }

  Future<dynamic> createWarehouseOrder({
    required String warehouseId,
    String? produceId,
    required String productName,
    required double quantityKg,
    required double pricePerKg,
    required String district,
    String? notes,
  }) {
    return post('/orders', {
      'type': 'farmer_to_warehouse',
      'to_id': warehouseId,
      if (produceId != null) 'produce_id': produceId,
      'items': [{'name': productName, 'qty': quantityKg, 'unit': 'kg', 'price': pricePerKg}],
      'total_amount': quantityKg * pricePerKg,
      'district': district,
      if (notes != null) 'notes': notes,
    });
  }

  Map<String, dynamic>? get currentUser => _user;

  Future<dynamic> getPriceSlots({String? cropName, String? grade}) async {
    final queryParams = <String, String>{};
    if (cropName != null) queryParams['crop_name'] = cropName;
    if (grade != null) queryParams['grade'] = grade;
    final queryString = queryParams.isNotEmpty ? '?${Uri(queryParameters: queryParams).query}' : '';
    return await get('/produce/price-slots$queryString');
  }

  Future<List<dynamic>> getMandiRates() async {
    try {
      final res = await get('/consumers/mandi-rates');
      if (res is List) return res;
      if (res is Map && res['data'] is List) return res['data'] as List<dynamic>;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<dynamic> getWalletData({String? farmerId}) async {
    final fId = farmerId ?? _user?['id'] ?? _user?['username'] ?? _user?['mobile'] ?? 'farmer_demo';
    return await get('/farmers/$fId/wallet');
  }

  Future<dynamic> withdrawFunds({required double amount, String? bankName, String? accountNo}) async {
    final fId = _user?['id'] ?? _user?['username'] ?? _user?['mobile'] ?? 'farmer_demo';
    return await post('/farmers/$fId/withdraw', {
      'amount': amount,
      'bank_name': bankName ?? (_user?['bank_name'] ?? 'Primary Bank Account'),
      'account_no': accountNo ?? (_user?['account_no'] ?? 'Primary Account'),
    });
  }

  Future<dynamic> getSalesReport({String? farmerId}) async {
    final fId = farmerId ?? _user?['id'] ?? _user?['username'] ?? _user?['mobile'] ?? 'farmer_demo';
    return await get('/farmers/$fId/sales-report');
  }

  Future<dynamic> markNotificationRead(String id) async {
    return await put('/notifications/$id/read', {});
  }

  Future<dynamic> markAllNotificationsRead() async {
    return await put('/notifications/read-all', {});
  }
}
