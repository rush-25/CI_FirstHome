import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/directory_provider.dart';
import 'brand_logo.dart';
import 'luxury_interactions.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  final Function(String route)? onNavigate;

  const Navbar({super.key, this.onNavigate});

  @override
  Size get preferredSize => const Size.fromHeight(82);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool _mobileMenuOpen = false;
  bool _mobileSearchOpen = false;
  int? _selectedCategoryId;
  String? _selectedState;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dir = context.read<DirectoryProvider>();
      if (dir.categories.isEmpty) {
        dir.loadCategories();
      }
    });
  }

  void _submitSearch() {
    final dir = context.read<DirectoryProvider>();
    dir.setCategoryFilter(_selectedCategoryId);
    dir.setLocationFilter(_selectedState, _selectedCity);
    setState(() {
      _mobileSearchOpen = false;
    });
    widget.onNavigate?.call('directory');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dir = context.watch<DirectoryProvider>();

    final categoriesList = dir.categories.isNotEmpty
        ? dir.categories.map((c) => (c.id, c.name)).toList()
        : const [
            (1, 'Real Estate Agents'),
            (2, 'Property Management'),
            (3, 'Home Construction'),
            (4, 'Interior Design'),
            (5, 'Mortgage Advisory'),
            (6, 'Home Maintenance'),
            (7, 'Air Conditioning & HVAC'),
            (8, 'Appliance Repairs'),
            (9, 'Carpentry'),
            (10, 'Electrical Services'),
            (11, 'Home Cleaning'),
            (12, 'Painting'),
            (13, 'Plumbing'),
            (14, 'Solar & Inverter Installation'),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.90), // Frosted translucent white
                    border: const Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 36),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      // Brand Logo
                      BrandLogo(
                        onTap: () {
                          if (_mobileMenuOpen) {
                            setState(() => _mobileMenuOpen = false);
                          }
                          widget.onNavigate?.call('home');
                        },
                      ),

                      // Desktop Navigation Links
                      if (!isMobile)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildNavLink('Home', () => widget.onNavigate?.call('home')),
                            const SizedBox(width: 28),
                            _buildNavLink('Find Providers', () => widget.onNavigate?.call('directory')),
                            const SizedBox(width: 28),
                            _buildNavLink('How It Works', () => widget.onNavigate?.call('how-it-works')),
                            const SizedBox(width: 28),
                            _buildNavLink('About', () => widget.onNavigate?.call('about')),
                          ],
                        ),

                      // Actions (Right)
                      if (!isMobile)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!auth.isAuthenticated) ...[
                              TextButton(
                                onPressed: () => widget.onNavigate?.call('login'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF445365),
                                  textStyle: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                child: const Text('Sign in'),
                              ),
                              const SizedBox(width: 14),
                              ElevatedButton(
                                onPressed: () => widget.onNavigate?.call('register-provider'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.navy,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 44),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                child: Text(
                                  'Become a Provider',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ] else ...[
                              TextButton(
                                onPressed: () {
                                  if (auth.isAdmin) {
                                    widget.onNavigate?.call('admin-dashboard');
                                  } else if (auth.isProvider) {
                                    widget.onNavigate?.call('provider-dashboard');
                                  } else {
                                    widget.onNavigate?.call('customer-dashboard');
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.navy,
                                  textStyle: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          (auth.currentUser?.fullName.isNotEmpty == true
                                                  ? auth.currentUser!.fullName[0]
                                                  : 'U')
                                              .toUpperCase(),
                                          style: GoogleFonts.manrope(
                                            color: AppColors.navy,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Dashboard'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () async {
                                  await auth.logout();
                                  widget.onNavigate?.call('home');
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 38),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  side: const BorderSide(color: AppColors.border),
                                ),
                                child: Text(
                                  'Sign out',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.slate,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _mobileSearchOpen ? Icons.close : Icons.search,
                                color: _mobileSearchOpen ? AppColors.gold : AppColors.navy,
                                size: 24,
                              ),
                              tooltip: 'Search providers',
                              onPressed: () {
                                setState(() {
                                  if (!_mobileSearchOpen) {
                                    _mobileMenuOpen = false;
                                  }
                                  _mobileSearchOpen = !_mobileSearchOpen;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                _mobileMenuOpen ? Icons.close : Icons.menu,
                                color: AppColors.navy,
                                size: 24,
                              ),
                              tooltip: 'Menu',
                              onPressed: () {
                                setState(() {
                                  if (!_mobileMenuOpen) {
                                    _mobileSearchOpen = false;
                                  }
                                  _mobileMenuOpen = !_mobileMenuOpen;
                                });
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Mobile Menu Dropdown with Backdrop Blur
        if (isMobile && _mobileMenuOpen)
          SizedBox(
            height: MediaQuery.of(context).size.height - 82,
            child: Stack(
              children: [
                // Blurred backdrop overlay covering the rest of the screen
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _mobileMenuOpen = false);
                    },
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          color: const Color(0x660A1420), // deep navy frosted scrim
                        ),
                      ),
                    ),
                  ),
                ),

                // Dropdown content with frosted blur
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: StaggeredFadeSlide(
                    durationMs: 250,
                    slideDistance: -12.0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            border: const Border(
                              bottom: BorderSide(color: AppColors.border),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMobileNavItem('Home', () {
                                setState(() => _mobileMenuOpen = false);
                                widget.onNavigate?.call('home');
                              }),
                              _buildMobileNavItem('Find Providers', () {
                                setState(() => _mobileMenuOpen = false);
                                widget.onNavigate?.call('directory');
                              }),
                              _buildMobileNavItem('How It Works', () {
                                setState(() => _mobileMenuOpen = false);
                                widget.onNavigate?.call('how-it-works');
                              }),
                              _buildMobileNavItem('About', () {
                                setState(() => _mobileMenuOpen = false);
                                widget.onNavigate?.call('about');
                              }),
                              const Divider(height: 24),
                              if (!auth.isAuthenticated) ...[
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() => _mobileMenuOpen = false);
                                    widget.onNavigate?.call('login');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 46),
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  child: const Text('Sign in'),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() => _mobileMenuOpen = false);
                                    widget.onNavigate?.call('register-provider');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.navy,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 46),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  child: const Text('Become a Provider'),
                                ),
                              ] else ...[
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() => _mobileMenuOpen = false);
                                    if (auth.isAdmin) {
                                      widget.onNavigate?.call('admin-dashboard');
                                    } else if (auth.isProvider) {
                                      widget.onNavigate?.call('provider-dashboard');
                                    } else {
                                      widget.onNavigate?.call('customer-dashboard');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.navy,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 46),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  child: const Text('Go to Dashboard'),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton(
                                  onPressed: () async {
                                    setState(() => _mobileMenuOpen = false);
                                    await auth.logout();
                                    widget.onNavigate?.call('home');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 46),
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign out',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate,
                                    ),
                                  ),
                                ),
                              ],
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
        // Mobile Search Dropdown with Backdrop Blur
        if (isMobile && _mobileSearchOpen)
          SizedBox(
            height: MediaQuery.of(context).size.height - 82,
            child: Stack(
              children: [
                // Blurred backdrop overlay covering the rest of the screen
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _mobileSearchOpen = false);
                    },
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          color: const Color(0x660A1420), // deep navy frosted scrim
                        ),
                      ),
                    ),
                  ),
                ),

                // Dropdown search content with frosted blur
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: StaggeredFadeSlide(
                    durationMs: 250,
                    slideDistance: -12.0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.96),
                            border: const Border(
                              bottom: BorderSide(color: AppColors.border),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'SEARCH PROVIDERS',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: AppColors.slate,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _mobileSearchOpen = false),
                                    child: const Icon(Icons.close, size: 20, color: AppColors.slate),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Service Category Dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.ivory,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int?>(
                                    value: _selectedCategoryId,
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.slate),
                                    hint: const Row(
                                      children: [
                                        Icon(Icons.search, size: 18, color: AppColors.slate),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Select Service / Category',
                                            style: TextStyle(fontSize: 13, color: AppColors.slate),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Row(
                                          children: [
                                            Icon(Icons.category_outlined, size: 18, color: AppColors.slate),
                                            SizedBox(width: 8),
                                            Text(
                                              'All Services / Categories',
                                              style: TextStyle(fontSize: 13, color: AppColors.slate),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ...categoriesList.map((c) {
                                        return DropdownMenuItem<int?>(
                                          value: c.$1,
                                          child: Text(
                                            c.$2,
                                            style: const TextStyle(fontSize: 13, color: AppColors.navy),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedCategoryId = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // State Dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.ivory,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedState,
                                    isExpanded: true,
                                    hint: const Text(
                                      'Select State',
                                      style: TextStyle(fontSize: 13, color: AppColors.slate),
                                    ),
                                    items: AppConstants.nigerianStates.map((s) {
                                      return DropdownMenuItem(
                                        value: s,
                                        child: Text(s, style: const TextStyle(fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedState = val;
                                        _selectedCity = null;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              // City Dropdown (when state selected)
                              if (_selectedState != null &&
                                  (AppConstants.stateCities[_selectedState!] ?? []).isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.ivory,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: (AppConstants.stateCities[_selectedState!] ?? [])
                                              .contains(_selectedCity)
                                          ? _selectedCity
                                          : null,
                                      isExpanded: true,
                                      hint: const Text(
                                        'Select City (Optional)',
                                        style: TextStyle(fontSize: 13, color: AppColors.slate),
                                      ),
                                      items: (AppConstants.stateCities[_selectedState!] ?? []).map((c) {
                                        return DropdownMenuItem(
                                          value: c,
                                          child: Text(c, style: const TextStyle(fontSize: 13)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() => _selectedCity = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Search Button
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _submitSearch,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.navy,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.search, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Search',
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
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
                ),
              ],
            ),
          ),
      ],
    );
      },
    );
  }

  Widget _buildNavLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF445365),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }
}
