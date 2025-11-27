import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';

class JoinClassroomScreen extends StatefulWidget {
  const JoinClassroomScreen({super.key});

  @override
  State<JoinClassroomScreen> createState() => _JoinClassroomScreenState();
}

class _JoinClassroomScreenState extends State<JoinClassroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinClassroom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _databaseService.joinClassroom(
        _codeController.text.trim().toUpperCase(),
        user.id,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sınıfa başarıyla katıldınız!'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sınıfa Katıl')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // İllüstrasyon
            Container(
              padding: const EdgeInsets.all(32),
              child: const Icon(
                Icons.group_add,
                size: 120,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            // Bilgilendirme
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                        'Nasıl Katılırım?',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Öğretmeninizden 6 haneli sınıf kodunu alın\n'
                    '• Kodu aşağıdaki alana girin\n'
                    '• "Katıl" butonuna tıklayın',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Kod Girişi
            Text('Sınıf Kodu', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                hintText: 'ABC123',
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen sınıf kodunu girin';
                }
                if (value.trim().length != 6) {
                  return 'Sınıf kodu 6 haneli olmalıdır';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Katıl Butonu
            CustomButton(
              text: 'Sınıfa Katıl',
              onPressed: _joinClassroom,
              isLoading: _isLoading,
              icon: Icons.login,
            ),
          ],
        ),
      ),
    );
  }
}
