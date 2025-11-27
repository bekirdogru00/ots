import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;
  
  // Kullanıcı durumu stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Kullanıcı bilgilerini al
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;
      
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Kullanıcı bilgileri alınamadı: $e');
      return null;
    }
  }
  
  // Email ile kayıt ol
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    String? teacherId,
  }) async {
    try {
      // Firebase Auth ile kullanıcı oluştur
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) throw Exception('Kullanıcı oluşturulamadı');
      
      // Kullanıcı bilgilerini Firestore'a kaydet
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        role: role,
        teacherId: teacherId,
        createdAt: DateTime.now(),
        subscriptionStatus: false,
      );
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Kayıt sırasında bir hata oluştu: $e';
    }
  }
  
  // Email ile giriş yap
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) throw Exception('Giriş yapılamadı');
      
      // Kullanıcı dokümanını kontrol et
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        // Eğer kullanıcı dokümanı yoksa oluştur (eski kullanıcılar için)
        final userModel = UserModel(
          id: user.uid,
          email: email,
          name: user.displayName ?? email.split('@')[0],
          role: 'student', // Varsayılan rol
          createdAt: DateTime.now(),
          subscriptionStatus: false,
        );
        
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toFirestore());
        
        return userModel;
      }
      
      // Son görülme zamanını güncelle
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
      
      return await getCurrentUserData();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Giriş sırasında bir hata oluştu: $e';
    }
  }
  
  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Çıkış yapılırken bir hata oluştu: $e';
    }
  }
  
  // Şifre sıfırlama emaili gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Şifre sıfırlama emaili gönderilemedi: $e';
    }
  }
  
  // Şifre değiştir
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw 'Kullanıcı oturumu bulunamadı';
      }
      
      // Önce mevcut şifre ile yeniden kimlik doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Yeni şifreyi ayarla
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Şifre değiştirilemedi: $e';
    }
  }
  
  // Profil güncelle
  Future<void> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw 'Kullanıcı oturumu bulunamadı';
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      
      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update(updates);
      }
    } catch (e) {
      throw 'Profil güncellenemedi: $e';
    }
  }
  
  // Hesabı sil
  Future<void> deleteAccount(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw 'Kullanıcı oturumu bulunamadı';
      }
      
      // Önce yeniden kimlik doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Firestore'dan kullanıcı verilerini sil
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();
      
      // Auth'dan kullanıcıyı sil
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Hesap silinemedi: $e';
    }
  }
  
  // Firebase Auth hatalarını işle
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf. Daha güçlü bir şifre seçin.';
      case 'email-already-in-use':
        return 'Bu email adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz email adresi.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda kullanılamıyor.';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}
