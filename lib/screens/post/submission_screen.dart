import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../services/ai_service.dart';
import '../../models/post_model.dart';
import '../../models/submission_model.dart';
import '../../widgets/custom_button.dart';

class SubmissionScreen extends StatefulWidget {
  final PostModel post;

  const SubmissionScreen({
    super.key,
    required this.post,
  });

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final AIService _aiService = AIService();
  final ImagePicker _imagePicker = ImagePicker();

  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isAnalyzing = false;

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();

      if (images.length > 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('En fazla 5 görsel seçebilirsiniz'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel seçilemedi: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _submitSolution() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir görsel ekleyin'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Görselleri yükle
      List<String> imageUrls = [];
      for (final image in _selectedImages) {
        final url = await _storageService.uploadImage(
          imageFile: image,
          path: '${AppConstants.submissionImagesPath}/${widget.post.id}',
        );
        imageUrls.add(url);
      }

      // Submission oluştur
      final submission = SubmissionModel(
        id: '',
        postId: widget.post.id,
        studentId: user.id,
        studentName: user.name,
        studentImageUrl: user.profileImageUrl,
        imageUrls: imageUrls,
        submittedAt: DateTime.now(),
      );

      final submissionId = await _databaseService.createSubmission(submission);

      // AI analizi başlat (arka planda)
      _analyzeSubmission(submissionId);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successSubmissionSent),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _analyzeSubmission(String submissionId) async {
    try {
      setState(() => _isAnalyzing = true);

      final analysis = await _aiService.analyzeSubmission(
        questionText: '${widget.post.title}\n\n${widget.post.description}',
        studentAnswer: 'Görsel olarak gönderildi',
      );

      await _databaseService.updateSubmissionAnalysis(
        submissionId,
        analysis['fullAnalysis'] ?? '',
        analysis,
      );
    } catch (e) {
      print('AI analizi yapılamadı: $e');
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çözüm Gönder'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Soru bilgisi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Talimatlar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Önemli Bilgiler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem('Çözümünüzü net bir şekilde fotoğraflayın'),
                _buildInfoItem('En fazla 5 görsel ekleyebilirsiniz'),
                _buildInfoItem('Gönderdikten sonra diğer çözümleri görebilirsiniz'),
                _buildInfoItem('AI analizi otomatik olarak yapılacak'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Görsel seçimi
          Text(
            'Çözüm Görselleri',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          if (_selectedImages.isEmpty)
            InkWell(
              onTap: _pickImages,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Çözüm Fotoğrafı Ekle',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Kamera veya galeriden seçin',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                if (_selectedImages.length < 5)
                  OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add),
                    label: const Text('Daha Fazla Görsel Ekle'),
                  ),
              ],
            ),

          const SizedBox(height: 32),

          // Gönder butonu
          CustomButton(
            text: 'Çözümü Gönder',
            onPressed: _submitSolution,
            isLoading: _isLoading,
            icon: Icons.send,
          ),

          if (_isAnalyzing) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI analizi yapılıyor...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
