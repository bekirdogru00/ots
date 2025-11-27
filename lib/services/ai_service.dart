import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/constants.dart';

class AIService {
  late final GenerativeModel _model;
  
  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );
  }
  
  // Öğrenci çözümünü analiz et
  Future<Map<String, dynamic>> analyzeSubmission({
    required String questionText,
    required String? studentAnswer,
  }) async {
    try {
      final prompt = '''
Bir öğrencinin sınav sorusuna verdiği cevabı analiz et.

SORU:
$questionText

ÖĞRENCİ CEVABI:
${studentAnswer ?? 'Görsel olarak gönderildi'}

Lütfen aşağıdaki formatta detaylı bir analiz yap:

1. GENEL DEĞERLENDİRME:
   - Cevabın doğruluğu (0-100 puan)
   - Genel yorum

2. GÜÇLÜ YÖNLER:
   - Doğru yapılan kısımlar
   - İyi anlaşılan konular

3. GELİŞTİRİLMESİ GEREKEN YÖNLER:
   - Yanlış veya eksik kısımlar
   - Anlaşılmayan konular
   - Yapılan hatalar

4. ÖNERİLER:
   - Çalışılması gereken konular
   - Kaynak önerileri
   - Pratik yapılması gereken alanlar

5. SONUÇ:
   - Özet değerlendirme
   - Motivasyon mesajı

Yanıtını Türkçe ve öğrenciye hitap eder şekilde yaz.
''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final analysisText = response.text ?? 'Analiz oluşturulamadı';
      
      // Analizi parse et ve yapılandır
      final structuredAnalysis = _parseAnalysis(analysisText);
      
      return {
        'fullAnalysis': analysisText,
        'score': structuredAnalysis['score'] ?? 0,
        'strengths': structuredAnalysis['strengths'] ?? [],
        'weaknesses': structuredAnalysis['weaknesses'] ?? [],
        'recommendations': structuredAnalysis['recommendations'] ?? [],
        'summary': structuredAnalysis['summary'] ?? '',
      };
    } catch (e) {
      throw 'AI analizi yapılamadı: $e';
    }
  }
  
  // Öğrencinin genel performansını analiz et
  Future<Map<String, dynamic>> analyzeStudentPerformance({
    required List<Map<String, dynamic>> submissions,
  }) async {
    try {
      // Submission'ları özetle
      final submissionSummary = submissions.map((s) {
        return 'Konu: ${s['topic'] ?? 'Bilinmiyor'}, Puan: ${s['score'] ?? 0}';
      }).join('\n');
      
      final prompt = '''
Bir öğrencinin son ${submissions.length} çözümünün performans analizi:

ÇÖZÜMLER:
$submissionSummary

Lütfen aşağıdaki formatta bir performans raporu oluştur:

1. GENEL DURUM:
   - Ortalama başarı
   - Genel trend (gelişiyor/durağan/gerileme)

2. GÜÇLÜ KONULAR:
   - İyi performans gösterilen konular

3. ZAYIF KONULAR:
   - Geliştirilmesi gereken konular
   - Sık yapılan hatalar

4. ÖNERİLER:
   - Odaklanılması gereken konular
   - Çalışma stratejileri
   - Kaynak önerileri

5. MOTİVASYON:
   - Teşvik edici mesaj
   - Hedefler

Yanıtını Türkçe ve öğrenciye hitap eder şekilde yaz.
''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return {
        'analysis': response.text ?? 'Analiz oluşturulamadı',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw 'Performans analizi yapılamadı: $e';
    }
  }
  
  // Konu önerisi al
  Future<List<String>> getTopicRecommendations({
    required List<String> weakTopics,
  }) async {
    try {
      final prompt = '''
Bir öğrencinin zayıf olduğu konular:
${weakTopics.join(', ')}

Bu konularda gelişmesi için:
1. Çalışması gereken alt konuları listele
2. Pratik yapması gereken soru tiplerini belirt
3. Kaynak önerilerinde bulun

Her öneriyi kısa ve net şekilde madde madde yaz.
''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final text = response.text ?? '';
      
      // Satırlara böl ve temizle
      final recommendations = text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .toList();
      
      return recommendations;
    } catch (e) {
      return ['Öneriler oluşturulamadı'];
    }
  }
  
  // Soru oluştur (hocalar için)
  Future<String> generateQuestion({
    required String topic,
    required String difficulty,
  }) async {
    try {
      final prompt = '''
Konu: $topic
Zorluk: $difficulty

Bu konu ve zorluk seviyesinde bir sınav sorusu oluştur.
Soru Türkçe olmalı ve öğrencilerin anlayabileceği şekilde net olmalı.
Gerekirse çoktan seçmeli veya açık uçlu soru formatında olabilir.
''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'Soru oluşturulamadı';
    } catch (e) {
      throw 'Soru oluşturulamadı: $e';
    }
  }
  
  // Analiz metnini parse et
  Map<String, dynamic> _parseAnalysis(String analysisText) {
    final result = <String, dynamic>{
      'score': 0,
      'strengths': <String>[],
      'weaknesses': <String>[],
      'recommendations': <String>[],
      'summary': '',
    };
    
    try {
      // Puan çıkar (0-100 arası)
      final scoreRegex = RegExp(r'(\d+)\s*(?:puan|/100)');
      final scoreMatch = scoreRegex.firstMatch(analysisText);
      if (scoreMatch != null) {
        result['score'] = int.tryParse(scoreMatch.group(1) ?? '0') ?? 0;
      }
      
      // Bölümleri ayır
      final sections = analysisText.split(RegExp(r'\d+\.\s+[A-ZÇĞİÖŞÜ\s]+:'));
      
      if (sections.length > 1) {
        // İlk bölüm genel değerlendirme
        result['summary'] = sections[1].trim();
      }
      
      // Diğer bölümleri parse et (basit versiyon)
      // Gerçek uygulamada daha sofistike parsing yapılabilir
      
    } catch (e) {
      print('Analiz parse edilemedi: $e');
    }
    
    return result;
  }
}
