class Validators {
  // Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }
  
  // Password validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    
    return null;
  }
  
  // Name validator
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'İsim gerekli';
    }
    
    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalı';
    }
    
    return null;
  }
  
  // Required field validator
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Bu alan'} gerekli';
    }
    
    return null;
  }
  
  // Phone validator (Türkiye)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }
    
    // Türkiye telefon formatı: 05XX XXX XX XX
    final phoneRegex = RegExp(r'^05\d{9}$');
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Geçerli bir telefon numarası girin (05XX XXX XX XX)';
    }
    
    return null;
  }
  
  // Confirm password validator
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }
}
