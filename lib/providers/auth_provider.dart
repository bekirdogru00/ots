import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final PaymentService _paymentService = PaymentService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isStudent => _currentUser?.isStudent ?? false;
  bool get isTeacher => _currentUser?.isTeacher ?? false;
  
  // Auth durumunu dinle
  void initializeAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await loadCurrentUser();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }
  
  // Mevcut kullanıcıyı yükle
  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      print('Kullanıcı yüklenemedi: $e');
    }
  }
  
  // Kayıt ol
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? teacherId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _currentUser = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
        teacherId: teacherId,
      );
      
      // RevenueCat'i başlat
      if (_currentUser != null) {
        await _paymentService.initialize(_currentUser!.id);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Giriş yap
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _currentUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      // RevenueCat'i başlat
      if (_currentUser != null) {
        await _paymentService.initialize(_currentUser!.id);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await _paymentService.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Şifre sıfırlama
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _authService.sendPasswordResetEmail(email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Profil güncelle
  Future<bool> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _authService.updateProfile(
        name: name,
        profileImageUrl: profileImageUrl,
      );
      
      await loadCurrentUser();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
