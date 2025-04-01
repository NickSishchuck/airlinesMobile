import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:airline_app/models/user.dart';
import 'package:airline_app/services/api_service.dart';

class AuthService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Add cache timestamp
  DateTime? _lastUserFetchTime;

  // Cache duration (5 minutes)
  static const cacheDurationMinutes = 5;

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    try {
      // Only fetch user data if we don't have it or cache has expired
      if (_currentUser == null || _isCacheExpired()) {
        await getCurrentUser();
      }
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Helper method to check if cache has expired
  bool _isCacheExpired() {
    if (_lastUserFetchTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastUserFetchTime!).inMinutes;
    return difference >= cacheDurationMinutes;
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      await _storage.write(key: 'token', value: response['token']);
      _currentUser = User.fromJson(response['data']);
      _lastUserFetchTime = DateTime.now(); // Update cache timestamp
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginWithPhone(String phone, String password) async {
    try {
      final response = await _apiService.post('/auth/loginWithPhone', {
        'phone': phone,
        'password': password,
      });

      await _storage.write(key: 'token', value: response['token']);
      _currentUser = User.fromJson(response['data']);
      _lastUserFetchTime = DateTime.now(); // Update cache timestamp
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithEmail(
      String name,
      String email,
      String password,
      ) async {
    try {
      final response = await _apiService.post('/auth/registerEmail', {
        'name': name,
        'email': email,
        'password': password,
        'role': "passenger",
      });

      await _storage.write(key: 'token', value: response['token']);
      _currentUser = User.fromJson(response['data']);
      _lastUserFetchTime = DateTime.now(); // Update cache timestamp
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithPhone(
      String name,
      String phone,
      String password,
      ) async {
    try {
      final response = await _apiService.post('/auth/register.phone', {
        'name': name,
        'phone': phone,
        'password': password,
        'role': "passenger",
      });

      await _storage.write(key: 'token', value: response['token']);
      _currentUser = User.fromJson(response['data']);
      _lastUserFetchTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getCurrentUser() async {
    try {
      print("Attempting to get current user...");
      final response = await _apiService.get('/auth/me');
      print("Response from /auth/me: $response");
      _currentUser = User.fromJson(response['data']);
      print("Current user set: ${_currentUser?.userId}");
      notifyListeners();
    } catch (e) {
      print("Error getting current user: $e");
      rethrow;
    }
  }
  //TODO change the debug variant into a normal one

  // Future<void> getCurrentUser() async {
  //   try {
  //     final response = await _apiService.get('/auth/me');
  //     _currentUser = User.fromJson(response['data']);
  //     _lastUserFetchTime = DateTime.now();
  //     notifyListeners();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Method to force refresh user data if needed
  Future<void> refreshCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      _currentUser = User.fromJson(response['data']);
      _lastUserFetchTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.put('/auth/updatepassword', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.get('/auth/logout');
    } catch (e) {
      // Ignore errors during logout, we still want to clear local storage
    }

    await _storage.delete(key: 'token');
    _currentUser = null;
    _lastUserFetchTime = null; // Clear cache timestamp
    notifyListeners();
  }
}