import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/directory_provider.dart';
import '../../core/services/api_service.dart';
import '../../widgets/navbar.dart';

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
  final _formKey = GlobalKey<FormState>();

  late String _role; // Customer or Provider

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: '+234 800 ');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? _selectedState = 'Lagos';
  String? _selectedCity = 'Ikeja';
  String _contactPreference = 'Phone';
  int? _selectedCategoryId;
  bool _consent = false;
  bool _obscurePassword = true;

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
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the consent terms to continue.'),
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
        // Now create provider profile record
        try {
          final dir = context.read<DirectoryProvider>();
          final catId = _selectedCategoryId ?? (dir.categories.isNotEmpty ? dir.categories.first.id : 1);
          await auth.updateProfile(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            state: _selectedState,
            city: _selectedCity,
          );
          // Persist ProviderProfile to real database
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
                : 'Professional ${_nameController.text.trim()} providing trusted services in $_selectedState.',
          );
          if (mounted) {
            final dirProv = context.read<DirectoryProvider>();
            await dirProv.fetchProviders(page: 1);
            widget.onNavigate('provider-dashboard');
          }
        } catch (_) {
          if (mounted) widget.onNavigate('provider-dashboard');
        }
      } else {
        widget.onNavigate('customer-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dir = context.watch<DirectoryProvider>();
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cities = AppConstants.stateCities[_selectedState] ?? ['General'];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Navbar(onNavigate: widget.onNavigate),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 24 : 64),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 20 : 40),
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
                          // Role Switcher Tabs
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _role = 'Customer'),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _role == 'Customer' ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: _role == 'Customer'
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.05),
                                                  blurRadius: 4,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 16,
                                            color: _role == 'Customer' ? AppColors.primary : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'Customer Account',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: _role == 'Customer' ? AppColors.primary : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _role = 'Provider'),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _role == 'Provider' ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: _role == 'Provider'
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.05),
                                                  blurRadius: 4,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.business_outlined,
                                            size: 16,
                                            color: _role == 'Provider' ? AppColors.primary : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'Provider Account',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: _role == 'Provider' ? AppColors.primary : AppColors.textSecondary,
                                              ),
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

                          const SizedBox(height: 24),

                          Text(
                            _role == 'Customer' ? 'Create Customer Account' : 'Join as a Service Provider',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _role == 'Customer'
                                ? 'Register to submit service enquiries and track vetted Nigerian home professionals.'
                                : 'List your services in the FirstHome directory and receive direct customer requests.',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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

                          // Full Name
                          const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Babatunde Lawal',
                              prefixIcon: Icon(Icons.person_outline, size: 18),
                            ),
                            validator: (v) => (v == null || v.trim().length < 2) ? 'Full name is required (min 2 chars)' : null,
                          ),

                          if (_role == 'Provider') ...[
                            const SizedBox(height: 16),
                            const Text('Business / Trade Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _businessNameController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Lawal Electrical & Inverter Works',
                                prefixIcon: Icon(Icons.business_outlined, size: 18),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().length < 2) ? 'Business name is required' : null,
                            ),
                            const SizedBox(height: 16),
                            const Text('Primary Service Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              initialValue: _selectedCategoryId ?? (dir.categories.isNotEmpty ? dir.categories.first.id : null),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.category_outlined, size: 18),
                              ),
                              items: dir.categories
                                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedCategoryId = v),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Email
                          const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'e.g. user@sample.firsthome.test',
                              prefixIcon: Icon(Icons.email_outlined, size: 18),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!v.contains('@')) return 'Enter a valid email address';
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Phone
                          const Text('Phone Number (Synthetic)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '+234 800 000 0000',
                              prefixIcon: Icon(Icons.phone_outlined, size: 18),
                            ),
                            validator: (v) => (v == null || v.trim().length < 7) ? 'Enter a valid phone number' : null,
                          ),

                          const SizedBox(height: 16),

                          // Location (State and City)
                          if (isMobile) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Nigerian State', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedState,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.map_outlined, size: 18),
                                  ),
                                  items: AppConstants.nigerianStates
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      _selectedState = v;
                                      final newCities = AppConstants.stateCities[v] ?? ['General'];
                                      _selectedCity = newCities.first;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('City / District', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: cities.contains(_selectedCity) ? _selectedCity : cities.first,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.location_city_outlined, size: 18),
                                  ),
                                  items: cities
                                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedCity = v),
                                ),
                              ],
                            ),
                          ] else
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Nigerian State', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        initialValue: _selectedState,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.map_outlined, size: 18),
                                        ),
                                        items: AppConstants.nigerianStates
                                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                            .toList(),
                                        onChanged: (v) {
                                          setState(() {
                                            _selectedState = v;
                                            final newCities = AppConstants.stateCities[v] ?? ['General'];
                                            _selectedCity = newCities.first;
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
                                      const Text('City / District', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        initialValue: cities.contains(_selectedCity) ? _selectedCity : cities.first,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.location_city_outlined, size: 18),
                                        ),
                                        items: cities
                                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                            .toList(),
                                        onChanged: (v) => setState(() => _selectedCity = v),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          if (_role == 'Customer') ...[
                            const SizedBox(height: 16),
                            const Text('Preferred Contact Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _contactPreference,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.contact_phone_outlined, size: 18),
                              ),
                              items: AppConstants.contactMethods
                                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                  .toList(),
                              onChanged: (v) => setState(() => _contactPreference = v ?? 'Phone'),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Password
                          const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Min 8 chars, 1 uppercase, 1 digit',
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
                              if (v == null || v.length < 8) return 'Password must be at least 8 characters';
                              if (!v.contains(RegExp(r'[A-Z]'))) return 'Must include at least one uppercase letter';
                              if (!v.contains(RegExp(r'[0-9]'))) return 'Must include at least one digit';
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Confirm Password
                          const Text('Confirm Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscurePassword,
                            decoration: const InputDecoration(
                              hintText: 'Re-enter your password',
                              prefixIcon: Icon(Icons.lock_outline, size: 18),
                            ),
                            validator: (v) {
                              if (v != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Synthetic Consent Checkbox
                          Material(
                            color: Colors.transparent,
                            child: CheckboxListTile(
                              value: _consent,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (v) => setState(() => _consent = v ?? false),
                              title: const Text(
                                'I understand this is a demonstration environment using synthetic data. I consent to FirstHome Nigeria storing my profile details for service matchmaking. (No real BVN/NIN collected).',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text('Complete Registration ($_role)'),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Center(
                            child: InkWell(
                              onTap: () => widget.onNavigate('login'),
                              child: const Text(
                                'Already have an account? Sign In',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
