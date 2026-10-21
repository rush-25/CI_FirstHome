import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/navbar.dart';

class LoginScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const LoginScreen({super.key, required this.onNavigate});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      if (auth.isAdmin) {
        widget.onNavigate('admin-dashboard');
      } else if (auth.isProvider) {
        widget.onNavigate('provider-dashboard');
      } else {
        widget.onNavigate('customer-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DemoBanner(),
            Navbar(onNavigate: widget.onNavigate),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 32 : 64),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      // Card
                      Container(
                        padding: EdgeInsets.all(isMobile ? 24 : 36),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.sage,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Welcome Back',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sign in to access your customer, provider, or administrator account.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),

                              const SizedBox(height: 24),

                              if (auth.errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.verifRejectedBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          auth.errorMessage!,
                                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Email
                              const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. adaeze@sample.firsthome.test',
                                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Email is required';
                                  if (!v.contains('@')) return 'Enter a valid email address';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              // Password
                              const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password is required';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: auth.isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text('Sign In'),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  const Text('Don\'t have an account?', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  InkWell(
                                    onTap: () => widget.onNavigate('register-customer'),
                                    child: const Text(
                                      'Register as Customer',
                                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: InkWell(
                                  onTap: () => widget.onNavigate('register-provider'),
                                  child: const Text(
                                    'Register as Service Provider',
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Quick-Fill Demo Accounts Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.sage.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.flash_on, color: AppColors.gold, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Quick Demo Credentials (1-Click Fill)',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _DemoUserButton(
                              role: 'Administrator',
                              label: 'FirstHome Admin (SAMPLE)',
                              email: 'admin@sample.firsthome.test',
                              onTap: () => _fillCredentials('admin@sample.firsthome.test', 'Fh4212091d1df34b1051A1'),
                            ),
                            const SizedBox(height: 8),
                            _DemoUserButton(
                              role: 'Customer',
                              label: 'Adaeze Okafor (Lagos)',
                              email: 'customer01@sample.firsthome.test',
                              onTap: () => _fillCredentials('customer01@sample.firsthome.test', 'Fh9ae89105ef00edd81bA1'),
                            ),
                            const SizedBox(height: 8),
                            _DemoUserButton(
                              role: 'Provider',
                              label: 'Lagos Pipe Masters (Plumbing)',
                              email: 'provider01@sample.firsthome.test',
                              onTap: () => _fillCredentials('provider01@sample.firsthome.test', 'Fh9ae89105ef00edd81bA1'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoUserButton extends StatelessWidget {
  final String role;
  final String label;
  final String email;
  final VoidCallback onTap;

  const _DemoUserButton({
    required this.role,
    required this.label,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.sage,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                role,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const Text(
              'Fill',
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
