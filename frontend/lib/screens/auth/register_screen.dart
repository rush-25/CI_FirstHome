import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/directory_provider.dart';
import '../../core/services/api_service.dart';
import '../../widgets/brand_logo.dart';

const String _heroImage =
    'https://images.unsplash.com/photo-1748063578185-3d68121b11ff?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=85&w=2000';

class RegisterScreen extends StatefulWidget {
  final String initialRole; // 'Customer' or 'Provider'
  final Function(String route, {dynamic args}) onNavigate;

  const RegisterScreen({
    super.key,
    this.initialRole = 'Customer',
    required this.onNavigate,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  late String _role; // Customer or Provider

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(
    text: '+234 800 ',
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? _selectedState = 'Lagos';
  String? _selectedCity = 'Ikeja';
  final String _contactPreference = 'Phone';
  int? _selectedCategoryId;
  bool _consent = false;
  bool _obscurePassword = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dir = context.read<DirectoryProvider>();
      if (dir.categories.isEmpty) {
        dir.loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service and Privacy Policy to continue.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    final success = await auth.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _role,
      state: _selectedState,
      city: _selectedCity,
      contactPreference: _contactPreference,
      consent: _consent,
    );

    if (success && mounted) {
      if (_role == 'Provider') {
        try {
          final dir = context.read<DirectoryProvider>();
          final catId = _selectedCategoryId ??
              (dir.categories.isNotEmpty ? dir.categories.first.id : 1);
          await auth.updateProfile(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            state: _selectedState,
            city: _selectedCity,
          );
          final api = ApiService();
          await api.createProviderProfile(
            displayName: _businessNameController.text.trim().isNotEmpty
                ? _businessNameController.text.trim()
                : _nameController.text.trim(),
            contactEmail: _emailController.text.trim(),
            categoryId: catId,
            state: _selectedState ?? 'Lagos',
            city: _selectedCity ?? 'Ikeja',
            description: _descController.text.trim().isNotEmpty
                ? _descController.text.trim()
                : 'Professional ${_businessNameController.text.trim().isNotEmpty ? _businessNameController.text.trim() : _nameController.text.trim()} providing trusted services in ${_selectedState ?? "Nigeria"}.',
          );
          if (mounted) {
            final dirProv = context.read<DirectoryProvider>();
            await dirProv.fetchProviders(page: 1);
          }
        } catch (_) {}
      }

      setState(() {
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dir = context.watch<DirectoryProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final cities = _selectedState != null
        ? (AppConstants.stateCities[_selectedState!] ?? ['Ikeja'])
        : <String>[];

    if (_isSuccess) {
      return Scaffold(
        backgroundColor: AppColors.ivory,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.successBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.check, color: AppColors.success, size: 30),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your account is ready.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to FirstHome. You can now build your profile and start making trusted connections.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.slate,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_role == 'Provider') {
                            widget.onNavigate('provider-dashboard');
                          } else {
                            widget.onNavigate('customer-dashboard');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Open your dashboard',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

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
                      constraints: const BoxConstraints(maxWidth: 480),
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
                                  'JOIN THE NETWORK',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Heading
                            Text(
                              'Create your account.',
                              style: GoogleFonts.manrope(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose your account type and start your journey.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.slate,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Role Segmented Switch
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.ivory,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildRoleTab(
                                      title: 'Customer',
                                      icon: Icons.person_outline,
                                      selected: _role == 'Customer',
                                      onTap: () {
                                        setState(() => _role = 'Customer');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: _buildRoleTab(
                                      title: 'Provider',
                                      icon: Icons.business_outlined,
                                      selected: _role == 'Provider',
                                      onTap: () {
                                        setState(() => _role = 'Provider');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Dynamic Inputs
                            if (_role == 'Provider') ...[
                              _buildFieldLabel('BUSINESS / DISPLAY NAME'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _businessNameController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Haven & Keys Realty',
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Business name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            _buildFieldLabel(_role == 'Provider' ? 'CONTACT PERSON FULL NAME' : 'FULL NAME'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: _role == 'Provider' ? 'Your full name' : 'e.g. Amara Okafor',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Full name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildFieldLabel('PHONE NUMBER'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: '+234 800 000 0000',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().length < 8) {
                                  return 'Valid phone number is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildFieldLabel('EMAIL ADDRESS'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'name@example.com',
                              ),
                              validator: (val) {
                                if (val == null || !val.contains('@')) {
                                  return 'Valid email address is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            if (_role == 'Provider') ...[
                              _buildFieldLabel('SERVICE CATEGORY'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                value: _selectedCategoryId ??
                                    (dir.categories.isNotEmpty ? dir.categories.first.id : null),
                                decoration: const InputDecoration(
                                  hintText: 'Select category',
                                ),
                                items: dir.categories.map((c) {
                                  return DropdownMenuItem<int>(
                                    value: c.id,
                                    child: Text(c.name),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedCategoryId = val);
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // State & City
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel('STATE'),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        value: _selectedState,
                                        decoration: const InputDecoration(),
                                        items: AppConstants.nigerianStates.map((s) {
                                          return DropdownMenuItem(value: s, child: Text(s));
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedState = val;
                                            _selectedCity = (AppConstants.stateCities[val] ?? ['General']).first;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel('CITY'),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        value: cities.contains(_selectedCity) ? _selectedCity : cities.firstOrNull,
                                        decoration: const InputDecoration(),
                                        items: cities.map((c) {
                                          return DropdownMenuItem(value: c, child: Text(c));
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() => _selectedCity = val);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildFieldLabel('PASSWORD'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Create a strong password',
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
                                if (val == null || val.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),

                            // Password Strength Bar
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 3,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    height: 3,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    height: 3,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    height: 3,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Strong password',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Consent Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _consent,
                                    activeColor: AppColors.navy,
                                    onChanged: (v) {
                                      setState(() => _consent = v ?? false);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'I agree to the Terms of Service and Privacy Policy.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.slate,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Provider Mock Note Banner
                            if (_role == 'Provider') ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.ivory,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.shield_outlined,
                                      size: 16,
                                      color: AppColors.gold,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.slate,
                                            height: 1.4,
                                          ),
                                          children: const [
                                            TextSpan(
                                              text: 'Safe mock verification: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.navy,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  'We will never request BVN, NIN or identity documents in this prototype.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

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
                                onPressed: auth.isLoading ? null : _handleRegister,
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
                                            'Create account',
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

                            // Switch to Sign In
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.slate,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => widget.onNavigate('login'),
                                    child: Text(
                                      'Sign in',
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.navy,
      ),
    );
  }

  Widget _buildRoleTab({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.slate,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
