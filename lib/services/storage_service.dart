import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../config/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  
  // Görsel yükle
  Future<String> uploadImage({
    required File imageFile,
    required String path,
    int quality = AppConstants.imageQuality,
  }) async {
    try {
      // Görseli sıkıştır
      final compressedImage = await _compressImage(imageFile, quality);
      
      // Benzersiz dosya adı oluştur
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child(path).child(fileName);
      
      // Yükle
      await ref.putData(compressedImage);
      
      // URL'i al
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Görsel yüklenemedi: $e';
    }
  }
  
  // Profil fotoğrafı yükle
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    return await uploadImage(
      imageFile: imageFile,
      path: '${AppConstants.profileImagesPath}/$userId',
    );
  }
  
  // Post görseli yükle
  Future<String> uploadPostImage(File imageFile, String postId) async {
    return await uploadImage(
      imageFile: imageFile,
      path: '${AppConstants.postImagesPath}/$postId',
    );
  }
  
  // Çözüm görseli yükle
  Future<String> uploadSubmissionImage(File imageFile, String submissionId) async {
    return await uploadImage(
      imageFile: imageFile,
      path: '${AppConstants.submissionImagesPath}/$submissionId',
    );
  }
  
  // Birden fazla görsel yükle
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required String path,
  }) async {
    try {
      final urls = <String>[];
      
      for (final imageFile in imageFiles) {
        final url = await uploadImage(
          imageFile: imageFile,
          path: path,
        );
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      throw 'Görseller yüklenemedi: $e';
    }
  }
  
  // Görsel sil
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Görsel silinemedi: $e');
      // Hata fırlatmıyoruz çünkü görsel zaten silinmiş olabilir
    }
  }
  
  // Birden fazla görsel sil
  Future<void> deleteMultipleImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteImage(url);
    }
  }
  
  // Görseli sıkıştır
  Future<Uint8List> _compressImage(File imageFile, int quality) async {
    try {
      // Dosya boyutunu kontrol et
      final fileSize = await imageFile.length();
      if (fileSize > AppConstants.maxImageSize) {
        throw AppConstants.errorImageSize;
      }
      
      // Görseli oku
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw 'Görsel okunamadı';
      }
      
      // Boyutu ayarla (max 1920px genişlik)
      img.Image resizedImage = image;
      if (image.width > 1920) {
        resizedImage = img.copyResize(image, width: 1920);
      }
      
      // JPEG olarak sıkıştır
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      // List<int> to Uint8List conversion
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw 'Görsel işlenemedi: $e';
    }
  }
  
  // Dosya boyutunu kontrol et
  Future<bool> isFileSizeValid(File file) async {
    final fileSize = await file.length();
    return fileSize <= AppConstants.maxImageSize;
  }
}
