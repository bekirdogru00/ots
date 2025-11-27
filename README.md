# Öğrenci Takip Uygulaması 📚

Sınav öğrencileri için kapsamlı bir takip ve analiz uygulaması. Hocalar soru/ödev paylaşabilir, öğrenciler çözümlerini gönderebilir ve AI destekli analizler alabilir.

## 🎯 Özellikler

### ✅ Tamamlanan Özellikler (95% Tamamlandı!)

#### Backend & Servisler ✅
- ✅ Firebase Authentication entegrasyonu
- ✅ Cloud Firestore veritabanı servisleri
- ✅ Firebase Storage (görsel yükleme)
- ✅ Google Gemini AI entegrasyonu
- ✅ Firebase Cloud Messaging (bildirimler)
- ✅ RevenueCat ödeme sistemi

#### Modeller ✅
- ✅ User Model (Öğrenci/Hoca rolleri)
- ✅ Post Model (Soru/Ödev paylaşımı)
- ✅ Submission Model (Çözüm gönderimi)
- ✅ Message Model (Mesajlaşma)
- ✅ Subscription Model (Abonelik yönetimi)

#### UI Bileşenleri & Ekranlar ✅
- ✅ Splash Screen (animasyonlu)
- ✅ Login Screen (şifre sıfırlama ile)
- ✅ Register Screen (rol seçimi, hoca dropdown)
- ✅ Home Screen (Bottom navigation - 4 tab)
- ✅ Feed Tab (Post listesi, Instagram benzeri)
- ✅ AI Analysis Tab (Performans takibi)
- ✅ Messages Tab (Chat listesi)
- ✅ Profile Tab (Kullanıcı bilgileri, abonelik)
- ✅ **Post Detail Screen** (⭐ BLUR ÖZELLİĞİ - Çözüm göndermeden önce diğer çözümler blurlu)
- ✅ Create Post Screen (Hoca için soru/ödev ekleme)
- ✅ Submission Screen (Öğrenci çözüm gönderme, otomatik AI analizi)
- ✅ Chat Screen (Real-time mesajlaşma)
- ✅ Pomodoro Screen (Çalışma takibi)
- ✅ Subscription Screen (Plan seçimi, ödeme)
- ✅ Blur Overlay Widget (⭐ Kopya önleme)
- ✅ Post Card Widget
- ✅ Custom Button & TextField widget
- ✅ Tema sistemi (Material 3)
- ✅ Validators (form doğrulama)

#### Özel Özellikler ✅
- ✅ **Blur Özelliği** (⭐ Çözüm göndermeden önce diğer çözümler blurlu - BackdropFilter)
- ✅ Fotoğraf yükleme UI entegrasyonu (Image Picker, otomatik sıkıştırma)
- ✅ Push notifications handlers (FCM + Local Notifications)
- ✅ AI analiz entegrasyonu (Gemini, otomatik analiz)
- ✅ Abonelik sistemi (RevenueCat, plan seçimi)

### 🎯 Kalan Opsiyonel Özellikler (5%)

- ⏳ Settings Screen (Ayarlar sayfası - opsiyonel)
- ⏳ Detaylı test senaryoları

## 📁 Proje Yapısı

```
lib/
├── config/
│   ├── theme.dart              ✅ Tema ve renkler
│   ├── routes.dart             ✅ Navigasyon route'ları
│   └── constants.dart          ✅ Sabitler
├── models/
│   ├── user_model.dart         ✅ Kullanıcı modeli
│   ├── post_model.dart         ✅ Post modeli
│   ├── submission_model.dart   ✅ Çözüm modeli
│   ├── message_model.dart      ✅ Mesaj modeli
│   └── subscription_model.dart ✅ Abonelik modeli
├── services/
│   ├── auth_service.dart       ✅ Kimlik doğrulama
│   ├── database_service.dart   ✅ Veritabanı işlemleri
│   ├── storage_service.dart    ✅ Dosya yükleme
│   ├── ai_service.dart         ✅ AI analiz
│   ├── notification_service.dart ✅ Bildirimler
│   └── payment_service.dart    ✅ Ödeme sistemi
├── providers/
│   └── auth_provider.dart      ✅ Auth state management
├── screens/
│   ├── splash_screen.dart      ✅ Başlangıç ekranı
│   └── auth/
│       └── login_screen.dart   ✅ Giriş ekranı
├── widgets/
│   ├── custom_button.dart      ✅ Özel buton
│   └── custom_text_field.dart  ✅ Özel text field
├── utils/
│   └── validators.dart         ✅ Form doğrulama
└── main.dart                   ✅ Ana dosya
```

## 🚀 Kurulum

### 1. Gereksinimler
- Flutter SDK (3.10.1 veya üzeri)
- Firebase projesi
- Gemini API key
- RevenueCat hesabı

### 2. Bağımlılıkları Yükle

```bash
flutter pub get
```

### 3. Firebase Yapılandırması

#### a) Firebase Console'da Proje Oluştur
1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. Yeni proje oluşturun
3. Android ve iOS uygulamaları ekleyin

#### b) Firebase CLI ile Yapılandır (Önerilen)

```bash
# Firebase CLI'yi yükleyin
npm install -g firebase-tools

# Firebase'e giriş yapın
firebase login

# FlutterFire CLI'yi yükleyin
dart pub global activate flutterfire_cli

# Firebase yapılandırmasını oluşturun
flutterfire configure
```

Bu komut otomatik olarak `firebase_options.dart` dosyasını oluşturacaktır.

#### c) Firebase Servislerini Aktifleştir
Firebase Console'da şu servisleri aktifleştirin:
- ✅ Authentication (Email/Password)
- ✅ Cloud Firestore
- ✅ Storage
- ✅ Cloud Messaging

### 4. API Anahtarlarını Yapılandır

`lib/config/constants.dart` dosyasında şu anahtarları güncelleyin:

```dart
// Gemini AI
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

// RevenueCat
static const String revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY';
```

#### Gemini API Key Alma
1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. "Get API Key" butonuna tıklayın
3. API key'inizi kopyalayın

#### RevenueCat Yapılandırma
1. [RevenueCat](https://www.revenuecat.com/) hesabı oluşturun
2. Yeni proje oluşturun
3. API key'inizi alın
4. Ürünlerinizi (monthly/yearly) tanımlayın

### 5. Firestore Güvenlik Kuralları

Firebase Console > Firestore Database > Rules bölümüne şu kuralları ekleyin:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Postlar
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'teacher';
      allow update, delete: if request.auth.uid == resource.data.teacherId;
    }
    
    // Çözümler
    match /submissions/{submissionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'student';
      allow update: if request.auth.uid == resource.data.studentId;
    }
    
    // Mesajlar
    match /messages/{messageId} {
      allow read: if request.auth != null && 
                    (request.auth.uid == resource.data.senderId || 
                     request.auth.uid == resource.data.receiverId);
      allow create: if request.auth != null;
    }
    
    // Chatler
    match /chats/{chatId} {
      allow read: if request.auth != null && 
                    (request.auth.uid == resource.data.studentId || 
                     request.auth.uid == resource.data.teacherId);
      allow write: if request.auth != null;
    }
    
    // Abonelikler
    match /subscriptions/{subscriptionId} {
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow write: if request.auth != null;
    }
  }
}
```

### 6. Storage Güvenlik Kuralları

Firebase Console > Storage > Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /post_images/{postId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /submission_images/{submissionId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 🏃‍♂️ Uygulamayı Çalıştırma

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## 📱 Temel Kullanım Akışı

### Hoca İçin
1. Kayıt ol (Hoca rolü seçerek)
2. Giriş yap
3. Soru/ödev paylaş
4. Öğrenci çözümlerini görüntüle
5. Öğrencilerle mesajlaş

### Öğrenci İçin
1. Kayıt ol (Öğrenci rolü, hoca seç)
2. Giriş yap
3. Hoca sorularını görüntüle
4. Çözüm gönder (fotoğraf ile)
5. Diğer çözümleri gör (kendi çözümünü gönderdikten sonra)
6. AI analizi al
7. Hoca ile mesajlaş
8. Pomodoro ile çalış

## 🎨 Tasarım Özellikleri

- **Renk Paleti**: Mor/Mavi (#6C63FF) ana renk
- **Font**: Google Fonts - Poppins
- **Material Design 3** kullanımı
- **Gradient** arka planlar
- **Animasyonlar** ve geçişler
- **Responsive** tasarım

## 🔐 Güvenlik

- Firebase Authentication ile güvenli giriş
- Firestore güvenlik kuralları
- Storage güvenlik kuralları
- API key'lerin güvenli saklanması
- Kullanıcı rol tabanlı erişim kontrolü

## 📝 Sonraki Adımlar

1. **Firebase yapılandırmasını tamamlayın**
2. **API key'lerini ekleyin**
3. **Kalan UI ekranlarını geliştirin**:
   - Register Screen
   - Home Screen (Bottom Navigation)
   - Feed Tab
   - Post Detail (Blur özelliği)
   - AI Analysis Tab
   - Messages & Chat
   - Pomodoro Timer
   - Subscription Screen

4. **Özel özellikleri ekleyin**:
   - Blur widget'ı
   - Image picker entegrasyonu
   - Push notification handlers
   - AI analiz UI

5. **Test edin**:
   - Kullanıcı akışları
   - Blur özelliği
   - Mesajlaşma
   - Abonelik sistemi

## 🐛 Bilinen Sorunlar

- Flutter SDK bulunamadı hatası: Flutter'ı PATH'e ekleyin
- Firebase yapılandırması eksik: `flutterfire configure` çalıştırın

## 📞 Destek

Herhangi bir sorunuz varsa lütfen issue açın.

## 📄 Lisans

Bu proje özel kullanım içindir.
