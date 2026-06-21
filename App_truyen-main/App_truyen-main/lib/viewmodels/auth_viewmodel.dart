// lib/viewmodels/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthViewModel with ChangeNotifier {
  User? _currentUser;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  AuthViewModel() {
    // Tự động tải thông tin người dùng hiện tại nếu có phiên đăng nhập cũ
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    final token = await ApiService.getToken();
    if (token != null) {
      final user = await ApiService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await ApiService.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Đăng nhập thất bại';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _errorMessage = null;
    notifyListeners();

    // Validate email format in frontend as well
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    if (!emailRegex.hasMatch(email)) {
      _errorMessage = 'Email đăng ký phải là tài khoản Gmail hợp lệ (VD: example@gmail.com)';
      notifyListeners();
      return false;
    }

    try {
      final user = await ApiService.register(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Đăng ký thất bại';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> socialLogin(String email, String provider) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.socialLogin(email, provider);
      if (result != null) {
        _currentUser = result['user'] as User;
        notifyListeners();
        return result;
      }
      _errorMessage = 'Đăng nhập nhanh thất bại';
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateDisplayName(String name) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await ApiService.updateDisplayName(name);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Cập nhật tên thất bại';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> becomeCreator() async {
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await ApiService.becomeCreator();
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Không thể đăng ký làm tác giả';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.clearSession();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}