import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Kaydedilmiş bilgileri yükle
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  // Bilgileri kaydet veya sil
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Beni hatırla seçeneğini kaydet
    await _saveCredentials();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Giriş başarısız'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Başlık
                Text(
                  'Hoş Geldiniz!',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  'Hesabınıza giriş yapın',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'E-posta',
                  hint: 'ornek@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                
                const SizedBox(height: 20),
                
                // Şifre
                CustomTextField(
                  controller: _passwordController,
                  label: 'Şifre',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: Validators.password,
                ),
                
                const SizedBox(height: 10),
                
                // Beni Hatırla
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                    const Text('Beni Hatırla'),
                    const Spacer(),
                    // Şifremi unuttum
                    TextButton(
                      onPressed: () {
                        _showResetPasswordDialog();
                      },
                      child: const Text('Şifremi Unuttum'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Giriş butonu
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'Giriş Yap',
                      onPressed: _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Kayıt ol
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hesabınız yok mu?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.register);
                      },
                      child: const Text('Kayıt Olun'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Sıfırlama'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'E-posta adresinizi girin. Size şifre sıfırlama bağlantısı göndereceğiz.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              
              final success = await authProvider.resetPassword(
                emailController.text.trim(),
              );
              
              if (!mounted) return;
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Şifre sıfırlama bağlantısı gönderildi'
                        : authProvider.errorMessage ?? 'Bir hata oluştu',
                  ),
                  backgroundColor: success
                      ? AppTheme.secondaryColor
                      : AppTheme.errorColor,
                ),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
