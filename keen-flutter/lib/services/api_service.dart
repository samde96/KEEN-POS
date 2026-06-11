import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:keen_pos/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // TODO: Update this to your computer's local IP address (e.g., '192.168.1.100')
  // when running on a physical device.
  static const String _localIP = '192.168.0.100';

  static String get baseUrl {
    if (kIsWeb) return 'https://keen-pos.onrender.com/api';
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Use _localIP for emulator (10.0.2.2) or your machine's IP for physical device
      return 'http://$_localIP:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  late Dio _dio;
  late final Future<SharedPreferences> _prefs;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          await logout();
        }
        return handler.next(error);
      },
    ));

    _prefs = SharedPreferences.getInstance();
  }

  // Auth Methods
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      await saveAuthData(authResponse);
      return authResponse;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data);
      await saveAuthData(authResponse);
      return authResponse;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  Future<void> saveAuthData(AuthResponse authResponse) async {
    final prefs = await _prefs;
    await prefs.setString(tokenKey, authResponse.token);
    await saveUser(authResponse.user);
  }

  Future<void> saveUser(User user) async {
    final prefs = await _prefs;
    await prefs.setString(userKey, _userToJson(user));
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(tokenKey);
  }

  Future<User?> getUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString(userKey);
    if (userJson == null) return null;
    return _userFromJson(userJson);
  }

  Future<User> uploadProfilePhoto(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(
        '/users/profile-photo',
        data: formData,
      );
      
      final user = User.fromJson(response.data);
      await saveUser(user);
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // M-Pesa Settings Methods
  Future<MpesaSettings> getMpesaSettings() async {
    try {
      final response = await _dio.get('/settings/mpesa');
      return MpesaSettings.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MpesaSettings> updateMpesaSettings(MpesaSettings settings) async {
    try {
      final response = await _dio.post('/settings/mpesa', data: settings.toJson());
      return MpesaSettings.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Product Methods
  Future<ProductList> getProducts({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {'page': page, 'size': size},
      );
      return ProductList.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ProductList> searchProducts(String searchTerm, {int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/products/search',
        queryParameters: {
          'searchTerm': searchTerm,
          'page': page,
          'size': size,
        },
      );
      return ProductList.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final response = await _dio.get('/products/$id');
      return Product.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ProductMetadata> getProductMetadata() async {
    try {
      final response = await _dio.get('/products/metadata');
      return ProductMetadata.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post('/products', data: productData);
      return Product.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final response = await _dio.put('/products/$id', data: productData);
      return Product.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('/products/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Order Methods
  Future<OrderList> getUserOrders({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/orders',
        queryParameters: {'page': page, 'size': size},
      );
      return OrderList.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> createOrder({
    required List<Map<String, dynamic>> items,
    required dynamic subtotal,
    required dynamic taxAmount,
    required dynamic discountAmount,
    required dynamic totalAmount,
    required String paymentMethod,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/orders',
        data: {
          'items': items,
          'subtotal': subtotal,
          'taxAmount': taxAmount,
          'discountAmount': discountAmount,
          'totalAmount': totalAmount,
          'paymentMethod': paymentMethod,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );
      return Order.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Dashboard Methods
  Future<DashboardMetrics> getDashboardMetrics() async {
    try {
      final response = await _dio.get('/orders/dashboard/metrics');
      return DashboardMetrics.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SalesReport> getSalesReport(String period) async {
    try {
      final response = await _dio.get(
        '/orders/reports',
        queryParameters: {'period': period},
      );
      return SalesReport.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper Methods
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
        return 'Session expired. Please login again.';
      } else if (error.response?.statusCode == 400) {
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          return data['message'].toString();
        }
        return 'Bad request';
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout. Please try again. (Target: $baseUrl)';
      } else if (error.type == DioExceptionType.connectionError) {
        return 'Cannot connect to the backend ($baseUrl). Make sure it is running and accessible.';
      }
      return error.message ?? 'An error occurred';
    }
    return 'An unexpected error occurred';
  }

  String _userToJson(User user) {
    return '${user.id}|${user.email}|${user.firstName}|${user.lastName}|${user.role}|${user.profilePhotoUrl ?? ''}';
  }

  User _userFromJson(String json) {
    final parts = json.split('|');
    return User(
      id: int.parse(parts[0]),
      email: parts[1],
      firstName: parts[2],
      lastName: parts[3],
      role: parts[4],
      profilePhotoUrl: parts.length > 5 && parts[5].isNotEmpty ? parts[5] : null,
    );
  }
}