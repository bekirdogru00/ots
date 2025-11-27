import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../widgets/custom_button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  String? _selectedPlan;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': AppConstants.planMonthly,
      'title': 'Aylık Plan',
      'price': '₺49,99',
      'period': 'ay',
      'features': [
        'Sınırsız soru çözümü',
        'AI destekli analiz',
        'Hoca ile mesajlaşma',
        'Pomodoro timer',
        'Performans takibi',
      ],
    },
    {
      'id': AppConstants.planYearly,
      'title': 'Yıllık Plan',
      'price': '₺399,99',
      'period': 'yıl',
      'discount': '%33 İndirim',
      'features': [
        'Sınırsız soru çözümü',
        'AI destekli analiz',
        'Hoca ile mesajlaşma',
        'Pomodoro timer',
        'Performans takibi',
        'Öncelikli destek',
      ],
      'popular': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlan = AppConstants.planYearly; // Varsayılan olarak yıllık plan
  }

  Future<void> _subscribe() async {
    if (_selectedPlan == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // RevenueCat paketlerini al
      final packages = await _paymentService.getAvailablePackages();

      if (packages.isEmpty) {
        throw 'Abonelik paketleri bulunamadı';
      }

      // İlgili paketi bul
      final package = packages.first; // Demo için ilk paketi kullan

      // Satın alma işlemi
      final success = await _paymentService.purchasePackage(package, user.id);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abonelik başarıyla oluşturuldu!'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        } else {
          throw 'Satın alma işlemi tamamlanamadı';
        }
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

  Future<void> _restorePurchases() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await _paymentService.restorePurchases(user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Abonelik geri yüklendi!'
                  : 'Geri yüklenecek abonelik bulunamadı',
            ),
            backgroundColor: success
                ? AppTheme.secondaryColor
                : AppTheme.errorColor,
          ),
        );

        if (success) {
          Navigator.pop(context);
        }
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Üyelik'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Başlık
          Text(
            'Premium\'a Geçin',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Tüm özelliklere sınırsız erişim',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Mevcut durum
          if (user?.hasActiveSubscription == true) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium Üye',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user?.subscriptionEndDate != null)
                          Text(
                            'Bitiş: ${_formatDate(user!.subscriptionEndDate!)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Planlar
          ...List.generate(_plans.length, (index) {
            final plan = _plans[index];
            final isSelected = _selectedPlan == plan['id'];
            final isPopular = plan['popular'] == true;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlan = plan['id'];
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  plan['title'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                plan['price'],
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '/${plan['period']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected
                                        ? Colors.white70
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (plan['discount'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : AppTheme.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                plan['discount'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.accentColor,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          ...List.generate(
                            (plan['features'] as List).length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.secondaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    plan['features'][i],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isPopular)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Popüler',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Abone ol butonu
          CustomButton(
            text: user?.hasActiveSubscription == true
                ? 'Planı Değiştir'
                : 'Abone Ol',
            onPressed: _subscribe,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 12),

          // Geri yükle butonu
          TextButton(
            onPressed: _restorePurchases,
            child: const Text('Satın Alımları Geri Yükle'),
          ),

          const SizedBox(height: 24),

          // Bilgi
          Text(
            'Abonelik otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
