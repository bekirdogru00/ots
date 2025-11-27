import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/post_model.dart';
import '../../models/submission_model.dart';
import '../../widgets/blur_overlay.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _hasSubmitted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
  }

  Future<void> _checkSubmissionStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId != null && authProvider.isStudent) {
      final hasSubmitted = await _databaseService.hasUserSubmitted(
        widget.post.id,
        userId,
      );
      setState(() {
        _hasSubmitted = hasSubmitted;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasSubmitted = true; // Hocalar her zaman görebilir
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isTeacher = authProvider.isTeacher;

    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soru Detayı'),
        actions: [
          if (isTeacher && widget.post.teacherId == authProvider.currentUser?.id)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post içeriği
                  _buildPostContent(),

                  const Divider(height: 32),

                  // Çözümler bölümü
                  _buildSubmissionsSection(authProvider),
                ],
              ),
            ),
      floatingActionButton: !isTeacher && !_hasSubmitted
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  AppRoutes.submission,
                  arguments: widget.post,
                );
                if (result == true) {
                  _checkSubmissionStatus();
                }
              },
              icon: const Icon(Icons.upload),
              label: const Text('Çözüm Gönder'),
            )
          : null,
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoca bilgisi
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: widget.post.teacherImageUrl != null
                    ? CachedNetworkImageProvider(widget.post.teacherImageUrl!)
                    : null,
                child: widget.post.teacherImageUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.teacherName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      timeago.format(widget.post.createdAt, locale: 'tr'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Başlık
          Text(
            widget.post.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 12),

          // Açıklama
          Text(
            widget.post.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          // Deadline
          if (widget.post.deadline != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.post.isDeadlinePassed
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: widget.post.isDeadlinePassed
                        ? AppTheme.errorColor
                        : AppTheme.secondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.post.isDeadlinePassed
                        ? 'Süre doldu'
                        : 'Son tarih: ${_formatDate(widget.post.deadline!)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.post.isDeadlinePassed
                          ? AppTheme.errorColor
                          : AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Görseller
          if (widget.post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.post.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: widget.post.imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error_outline,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmissionsSection(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Çözümler',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.post.submissionCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          StreamBuilder<List<SubmissionModel>>(
            stream: _databaseService.getSubmissions(widget.post.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final submissions = snapshot.data ?? [];

              if (submissions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz çözüm gönderilmemiş',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return BlurOverlay(
                isBlurred: !_hasSubmitted,
                onTap: () async {
                  final result = await Navigator.of(context).pushNamed(
                    AppRoutes.submission,
                    arguments: widget.post,
                  );
                  if (result == true) {
                    _checkSubmissionStatus();
                  }
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    return _buildSubmissionCard(submissions[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(SubmissionModel submission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: submission.studentImageUrl != null
                      ? CachedNetworkImageProvider(submission.studentImageUrl!)
                      : null,
                  child: submission.studentImageUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.studentName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        timeago.format(submission.submittedAt, locale: 'tr'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (submission.hasAiAnalysis)
                  const Icon(
                    Icons.verified,
                    color: AppTheme.secondaryColor,
                  ),
              ],
            ),

            if (submission.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: submission.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: submission.imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soruyu Sil'),
        content: const Text('Bu soruyu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _databaseService.deletePost(widget.post.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Soru silindi')),
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
      }
    }
  }
}
