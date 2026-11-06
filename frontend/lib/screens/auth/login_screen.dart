import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand_logo.dart';

const String _heroImage =
    'https://images.unsplash.com/photo-1748063578185-3d68121b11ff?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=85&w=2000';

class LoginScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const LoginScreen({super.key, required this.onNavigate});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _scrollController.dispose();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Visual Panel (Desktop only)
          if (isDesktop)
            Expanded(
              flex: 4,
              child: Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _heroImage,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: AppColors.navy,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF0A1420).withValues(alpha: 0.55),
                            const Color(0xFF0A1420).withValues(alpha: 0.92),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BrandLogo(
                            light: true,
                            onTap: () => widget.onNavigate('home'),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Text(
                              '“The clearest path to trusted home professionals across Nigeria.”',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 32,
                                color: Colors.white,
                                height: 1.35,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          Text(
                            'FIRSTHOME · YOUR HOME JOURNEY, SIMPLIFIED',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.2,
                              color: const Color(0xFFBDC5CC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right Form Panel
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned(
                  top: 24,
                  right: 28,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.navy, size: 22),
                    tooltip: 'Return to home',
                    onPressed: () => widget.onNavigate('home'),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 500 ? 24 : 48,
                      vertical: 48,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isDesktop) ...[
                              BrandLogo(onTap: () => widget.onNavigate('home')),
                              const SizedBox(height: 28),
                            ],

                            // Eyebrow
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 2,
                                  color: AppColors.gold,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'WELCOME BACK',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Heading
                            Text(
                              'Sign in to FirstHome.',
                              style: GoogleFonts.manrope(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your enquiries, connections and profile.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.slate,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Email Field
                            Text(
                              'EMAIL ADDRESS',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'name@example.com',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!val.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Password Field
                            Text(
                              'PASSWORD',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.slate,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: AppColors.navy,
                                        onChanged: (v) {
                                          setState(() => _rememberMe = v ?? false);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Remember me',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.slate,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF9B7538),
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Error Display
                            if (auth.errorMessage != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.errorBg,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.error.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  auth.errorMessage!,
                                  style: GoogleFonts.inter(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.navy,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Sign in',
                                            style: GoogleFonts.manrope(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward, size: 16),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Switch to Register
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'New to FirstHome? ',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.slate,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => widget.onNavigate('register-customer'),
                                    child: Text(
                                      'Create account',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF9B7538),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Quick Fill Demo Credentials
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.ivory,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.flash_on,
                                        size: 15,
                                        color: AppColors.gold,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'PROTOTYPE QUICK LOGIN SHORTCUTS',
                                        style: GoogleFonts.manrope(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          color: AppColors.slate,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildQuickLoginCard(
                                    role: 'Admin',
                                    email: 'admin@sample.firsthome.test',
                                    password: 'Fh4212091d1df34b1051A1',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildQuickLoginCard(
                                    role: 'Customer',
                                    email: 'customer01@sample.firsthome.test',
                                    password: 'Fh9ae89105ef00edd81bA1',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildQuickLoginCard(
                                    role: 'Provider',
                                    email: 'provider01@sample.firsthome.test',
                                    password: 'Fh9ae89105ef00edd81bA1',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLoginCard({
    required String role,
    required String email,
    required String password,
  }) {
    return InkWell(
      onTap: () => _fillCredentials(email, password),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.ivory,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(Icons.flash_on, size: 14, color: AppColors.gold),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        role,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.ivory,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: Text(
                          'Fill credentials',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.slate,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Password: $password',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navy.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.slate),
          ],
        ),
      ),
    );
  }
}
