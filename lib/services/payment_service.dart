import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/constants.dart';
import '../models/subscription_model.dart';
import 'database_service.dart';

class PaymentService {
  final DatabaseService _databaseService = DatabaseService();
  
  // RevenueCat başlat
  Future<void> initialize(String userId) async {
    try {
      await Purchases.configure(
        PurchasesConfiguration(AppConstants.revenueCatApiKey)
          ..appUserID = userId,
      );
      
      print('RevenueCat başlatıldı');
    } catch (e) {
      print('RevenueCat başlatılamadı: $e');
    }
  }
  
  // Mevcut paketleri getir
  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      
      if (offerings.current == null) {
        return [];
      }
      
      return offerings.current!.availablePackages;
    } catch (e) {
      print('Paketler getirilemedi: $e');
      return [];
    }
  }
  
  // Satın alma yap
  Future<bool> purchasePackage(Package package, String userId) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      
      // Satın alma başarılı mı kontrol et
      if (purchaserInfo.entitlements.all['premium']?.isActive ?? false) {
        // Firestore'a abonelik kaydı oluştur
        await _createSubscriptionRecord(
          userId: userId,
          purchaserInfo: purchaserInfo,
          packageIdentifier: package.identifier,
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Satın alma hatası: $e');
      return false;
    }
  }
  
  // Aboneliği geri yükle
  Future<bool> restorePurchases(String userId) async {
    try {
      final purchaserInfo = await Purchases.restorePurchases();
      
      if (purchaserInfo.entitlements.all['premium']?.isActive ?? false) {
        // Firestore'a abonelik kaydı oluştur
        await _createSubscriptionRecord(
          userId: userId,
          purchaserInfo: purchaserInfo,
          packageIdentifier: 'restored',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Geri yükleme hatası: $e');
      return false;
    }
  }
  
  // Abonelik durumunu kontrol et
  Future<bool> checkSubscriptionStatus() async {
    try {
      final purchaserInfo = await Purchases.getCustomerInfo();
      return purchaserInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      print('Abonelik durumu kontrol edilemedi: $e');
      return false;
    }
  }
  
  // Abonelik bilgilerini al
  Future<Map<String, dynamic>?> getSubscriptionInfo() async {
    try {
      final purchaserInfo = await Purchases.getCustomerInfo();
      final entitlement = purchaserInfo.entitlements.all['premium'];
      
      if (entitlement == null || !entitlement.isActive) {
        return null;
      }
      
      return {
        'isActive': entitlement.isActive,
        'willRenew': entitlement.willRenew,
        'periodType': entitlement.periodType,
        'expirationDate': entitlement.expirationDate,
        'productIdentifier': entitlement.productIdentifier,
      };
    } catch (e) {
      print('Abonelik bilgileri alınamadı: $e');
      return null;
    }
  }
  
  // Firestore'a abonelik kaydı oluştur
  Future<void> _createSubscriptionRecord({
    required String userId,
    required CustomerInfo purchaserInfo,
    required String packageIdentifier,
  }) async {
    try {
      final entitlement = purchaserInfo.entitlements.all['premium'];
      if (entitlement == null) return;
      
      final now = DateTime.now();
      final expirationDate = entitlement.expirationDate != null
          ? DateTime.parse(entitlement.expirationDate!)
          : now.add(const Duration(days: 30)); // Default 30 gün
      
      // Plan tipini belirle
      String plan = AppConstants.planMonthly;
      if (packageIdentifier.toLowerCase().contains('year')) {
        plan = AppConstants.planYearly;
      }
      
      final subscription = SubscriptionModel(
        id: '', // Firestore otomatik oluşturacak
        userId: userId,
        plan: plan,
        startDate: now,
        endDate: expirationDate,
        isActive: true,
        autoRenew: entitlement.willRenew,
        amount: 0.0, // RevenueCat'ten fiyat bilgisi alınabilir
        transactionId: purchaserInfo.originalAppUserId,
      );
      
      await _databaseService.createSubscription(subscription);
    } catch (e) {
      print('Abonelik kaydı oluşturulamadı: $e');
    }
  }
  
  // Aboneliği yönet (Platform store'a yönlendir)
  // Not: RevenueCat'in showManagementUI metodu yoktur.
  // Kullanıcılar iOS App Store veya Google Play Store üzerinden
  // aboneliklerini yönetmelidir.
  Future<void> manageSubscription() async {
    // Platform-specific subscription management
    // iOS: Settings > Apple ID > Subscriptions
    // Android: Google Play Store > Subscriptions
    print('Kullanıcı platform store üzerinden aboneliğini yönetmelidir');
  }
  
  // Kullanıcı ID'sini ayarla
  Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      print('Kullanıcı ID ayarlanamadı: $e');
    }
  }
  
  // Çıkış yap
  Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      print('RevenueCat çıkış hatası: $e');
    }
  }
}
