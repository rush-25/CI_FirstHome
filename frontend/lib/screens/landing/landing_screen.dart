import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/directory_provider.dart';
import '../../models/provider_model.dart';
import '../../widgets/navbar.dart';
import '../../widgets/footer.dart';
import '../../widgets/verification_badge.dart';

const String _heroImage =
    'https://images.unsplash.com/photo-1748063578185-3d68121b11ff?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=85&w=2000';
const String _howImage =
    'https://images.unsplash.com/photo-1706164971309-fb4785fe6ceb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=82&w=1200';

class LandingScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const LandingScreen({super.key, required this.onNavigate});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedState;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dir = context.read<DirectoryProvider>();
      dir.loadCategories();
      dir.fetchProviders(page: 1);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit() {
    final dir = context.read<DirectoryProvider>();
    dir.setLocationFilter(_selectedState, _selectedCity);
    dir.setSearchQuery(_searchController.text.trim());
    widget.onNavigate('directory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 82),
                _buildHero(context),
                _buildTrustStrip(context),
                _buildCategories(context),
                _buildHowItWorks(context),
                _buildFeaturedProviders(context),
                _buildTestimonial(context),
                _buildCta(context),
                Footer(onNavigate: widget.onNavigate),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Navbar(onNavigate: widget.onNavigate),
          ),
        ],
      ),
    );
  }

  // 1. Hero Section
  Widget _buildHero(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isMobile = screenWidth < 900;
    final isSmallMobile = screenWidth < 420;

    // Full screen hero: 100vh minus the 82px Navbar so the hero neatly occupies
    // the entire visible screen above the fold on mobile, tablet, and desktop.
    final minContentHeight = isSmallMobile ? 540.0 : (isMobile ? 580.0 : 640.0);
    final targetHeroHeight = math.max(screenHeight - 82.0, minContentHeight);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: targetHeroHeight),
      color: AppColors.navy,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.network(
              _heroImage,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(color: AppColors.navy),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A1420).withValues(alpha: 0.65),
                    const Color(0xFF0A1420).withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallMobile ? 18 : (isMobile ? 24 : 40),
              vertical: isSmallMobile ? 24 : (isMobile ? 32 : 48),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1140),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 2,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "NIGERIA'S TRUSTED HOME SERVICES NETWORK",
                            style: GoogleFonts.manrope(
                              color: AppColors.gold,
                              fontSize: isSmallMobile ? 9.5 : 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: isSmallMobile ? 1.0 : 1.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallMobile ? 12 : 18),

                    // Display Title
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: isSmallMobile
                              ? 32.0
                              : (screenWidth < 600
                                  ? 38.0
                                  : (screenWidth < 900 ? 46.0 : 62.0)),
                          color: Colors.white,
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                        children: [
                          const TextSpan(text: 'Find the right people.\n'),
                          TextSpan(
                            text: 'Build your next chapter.',
                            style: GoogleFonts.dmSerifDisplay(
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFF0EAE1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallMobile ? 24 : 32),

                    // Actions
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: () => widget.onNavigate('directory'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.navy,
                            minimumSize: Size(isSmallMobile ? 140 : 160, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Find a provider',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => widget.onNavigate('register-customer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54, width: 1.2),
                            minimumSize: Size(isSmallMobile ? 115 : 130, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          child: Text(
                            'Get started',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallMobile ? 24 : (isMobile ? 32 : 48)),

                    // Unified Search Panel
                    _buildSearchPanel(context, isMobile),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hero Search Panel
  Widget _buildSearchPanel(BuildContext context, bool isMobile) {
    final cities = _selectedState != null
        ? (AppConstants.stateCities[_selectedState!] ?? ['General'])
        : <String>[];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: isMobile
          ? Column(
              children: [
                TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _onSearchSubmit(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: AppColors.slate, size: 20),
                    hintText: 'What do you need? (e.g. Interior designer)',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                const Divider(height: 1),
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  hint: const Text('Select State'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  items: AppConstants.nigerianStates.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedState = val;
                      _selectedCity = null;
                    });
                  },
                ),
                if (_selectedState != null && cities.isNotEmpty) ...[
                  const Divider(height: 1),
                  DropdownButtonFormField<String>(
                    value: cities.contains(_selectedCity) ? _selectedCity : null,
                    hint: const Text('Select City (Optional)'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    items: cities.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCity = val);
                    },
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _onSearchSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Search',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // Need input
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WHAT DO YOU NEED?',
                          style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.slate,
                          ),
                        ),
                        TextField(
                          controller: _searchController,
                          onSubmitted: (_) => _onSearchSubmit(),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Interior designer, Architect',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 42, color: AppColors.border),

                // State
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATE',
                          style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.slate,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedState,
                          isDense: true,
                          hint: Text('All states', style: GoogleFonts.inter(fontSize: 13)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                          ),
                          items: AppConstants.nigerianStates.map((s) {
                            return DropdownMenuItem(value: s, child: Text(s));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedState = val;
                              _selectedCity = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 42, color: AppColors.border),

                // City
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CITY',
                          style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.slate,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: cities.contains(_selectedCity) ? _selectedCity : null,
                          isDense: true,
                          hint: Text('Select city', style: GoogleFonts.inter(fontSize: 13)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                          ),
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
                ),

                // Search Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _onSearchSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Search',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // 2. Trust Strip
  Widget _buildTrustStrip(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: isMobile
              ? Column(
                  children: [
                    Text(
                      'Built around what matters most',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 20,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildTrustPill(Icons.shield_outlined, 'Vetted professionals'),
                        _buildTrustPill(Icons.check_circle_outline, 'Quality connections'),
                        _buildTrustPill(Icons.access_time, 'Faster responses'),
                        _buildTrustPill(Icons.headset_mic_outlined, 'Human support'),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Built around what matters most',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        _buildTrustPill(Icons.shield_outlined, 'Vetted professionals'),
                        const SizedBox(width: 24),
                        _buildTrustPill(Icons.check_circle_outline, 'Quality connections'),
                        const SizedBox(width: 24),
                        _buildTrustPill(Icons.access_time, 'Faster responses'),
                        const SizedBox(width: 24),
                        _buildTrustPill(Icons.headset_mic_outlined, 'Human support'),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTrustPill(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 7),
        Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }

  // 3. Categories Grid
  Widget _buildCategories(BuildContext context) {
    final dir = context.watch<DirectoryProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    final defaultCategories = [
      ('01', 'Real Estate Agents', 'Find the right property with local experts.', Icons.business_outlined),
      ('02', 'Property Management', 'Protect and manage your investment.', Icons.home_outlined),
      ('03', 'Home Construction', 'Build with trusted project partners.', Icons.construction_outlined),
      ('04', 'Interior Design', 'Create a space that feels like yours.', Icons.auto_awesome_outlined),
      ('05', 'Mortgage Advisory', 'Make confident financial decisions.', Icons.account_balance_outlined),
      ('06', 'Home Maintenance', 'Keep your home working beautifully.', Icons.build_circle_outlined),
    ];

    return Container(
      width: double.infinity,
      color: AppColors.ivory,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 60 : 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Heading
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 14, height: 2, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Text(
                            'SERVICES FOR EVERY STAGE',
                            style: GoogleFonts.manrope(
                              color: AppColors.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: isMobile ? 26 : 38,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                            letterSpacing: -0.6,
                            height: 1.2,
                          ),
                          children: [
                            const TextSpan(text: 'Everything your home needs,\n'),
                            TextSpan(
                              text: 'all in one place.',
                              style: GoogleFonts.dmSerifDisplay(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isMobile)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Text(
                        'From finding your first property to making it feel like home, discover professionals you can trust.',
                        style: GoogleFonts.inter(
                          color: AppColors.slate,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 48),

              // Categories Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 3;
                  if (constraints.maxWidth < 650) {
                    crossAxisCount = 1;
                  } else if (constraints.maxWidth < 950) {
                    crossAxisCount = 2;
                  }

                  return GridView.builder(
                    itemCount: dir.categories.isNotEmpty
                        ? dir.categories.length
                        : defaultCategories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.9,
                    ),
                    itemBuilder: (context, index) {
                      final title = dir.categories.isNotEmpty
                          ? dir.categories[index].name
                          : defaultCategories[index].$2;
                      final desc = index < defaultCategories.length
                          ? defaultCategories[index].$3
                          : 'Trusted home and professional service providers.';
                      final icon = index < defaultCategories.length
                          ? defaultCategories[index].$4
                          : Icons.home_repair_service_outlined;
                      final numStr = '0${index + 1}';

                      return InkWell(
                        onTap: () {
                          if (dir.categories.isNotEmpty) {
                            dir.setCategoryFilter(dir.categories[index].id);
                          }
                          widget.onNavigate('directory');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.navy.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    numStr,
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  Icon(icon, size: 22, color: AppColors.navy),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    desc,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.slate,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    color: AppColors.ivory,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.arrow_forward, size: 13, color: AppColors.navy),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. How It Works Section
  Widget _buildHowItWorks(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 960;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 60 : 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHowImage(),
                    const SizedBox(height: 40),
                    _buildHowCopy(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: _buildHowImage()),
                    const SizedBox(width: 60),
                    Expanded(flex: 6, child: _buildHowCopy()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHowImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AspectRatio(
            aspectRatio: 1.15,
            child: Image.network(
              _howImage,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(color: AppColors.navy),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.gold, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quality, verified',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        'Providers are reviewed before going live.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 2, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              'A SIMPLER WAY FORWARD',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            style: GoogleFonts.manrope(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              letterSpacing: -0.6,
              height: 1.25,
            ),
            children: [
              const TextSpan(text: 'From search to connection,\n'),
              TextSpan(
                text: 'we make it effortless.',
                style: GoogleFonts.dmSerifDisplay(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'FirstHome brings clarity to one of life\'s most important journeys. Tell us what you need and connect with the right professional.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.slate,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),

        _buildStepItem(
          '01',
          'Tell us what you need',
          'Create a clear enquiry in just a few thoughtful steps.',
        ),
        const SizedBox(height: 20),
        _buildStepItem(
          '02',
          'Discover trusted providers',
          'Explore relevant experts in your city and compare with confidence.',
        ),
        const SizedBox(height: 20),
        _buildStepItem(
          '03',
          'Start the conversation',
          'Connect directly and manage every enquiry from one place.',
        ),
      ],
    );
  }

  Widget _buildStepItem(String number, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.ivory,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.slate,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Featured Providers
  Widget _buildFeaturedProviders(BuildContext context) {
    final dir = context.watch<DirectoryProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;
    final providers = dir.providers.take(3).toList();

    return Container(
      width: double.infinity,
      color: AppColors.ivory,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 60 : 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 14, height: 2, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Text(
                            'FEATURED PROFESSIONALS',
                            style: GoogleFonts.manrope(
                              color: AppColors.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: isMobile ? 26 : 38,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                            letterSpacing: -0.6,
                            height: 1.2,
                          ),
                          children: [
                            const TextSpan(text: 'Trusted expertise,\n'),
                            TextSpan(
                              text: 'close to home.',
                              style: GoogleFonts.dmSerifDisplay(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isMobile)
                    OutlinedButton(
                      onPressed: () => widget.onNavigate('directory'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.navy, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Explore all providers',
                            style: GoogleFonts.manrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 48),

              // Providers Grid
              if (providers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'Loading trusted providers...',
                    style: GoogleFonts.inter(color: AppColors.slate),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth < 700 ? 1 : 3;

                    return GridView.builder(
                      itemCount: providers.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: cols == 1 ? 1.7 : 1.4,
                      ),
                      itemBuilder: (context, index) {
                        final p = providers[index];
                        return _buildProviderCard(p);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard(ProviderModel p) {
    final initials = p.displayName.isNotEmpty
        ? p.displayName
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase()
        : 'PR';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.ivory,
                  border: Border.all(color: AppColors.border),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
              VerificationBadge(
                status: p.verificationStatus,
                compact: true,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                p.categoryName ?? 'Home Professional',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p.description.isNotEmpty
                    ? p.description
                    : 'Providing quality, reliable residential services across Nigeria.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.slate,
                  height: 1.4,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.slate),
                  const SizedBox(width: 4),
                  Text(
                    '${p.city ?? "Lagos"}, ${p.state ?? ""}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => widget.onNavigate('provider-detail', args: p),
                child: Row(
                  children: [
                    Text(
                      'View profile',
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 12, color: AppColors.navy),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. Testimonial Section
  Widget _buildTestimonial(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Text(
                '“',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 72,
                  color: AppColors.gold,
                  height: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'FirstHome gave us the clarity to move forward. We found a wonderful architect, understood every next step, and never felt overwhelmed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 24,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'AO',
                        style: GoogleFonts.manrope(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amara Okafor',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'First-time homeowner · Lagos',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8F9AA5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 7. CTA Section
  Widget _buildCta(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      width: double.infinity,
      color: const Color(0xFF142436), // Deep midnight blue accent
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 70,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCtaCopy(),
                    const SizedBox(height: 24),
                    _buildCtaButton(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildCtaCopy()),
                    const SizedBox(width: 40),
                    _buildCtaButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCtaCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 2, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              'YOUR NEXT CHAPTER STARTS HERE',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: GoogleFonts.manrope(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
            children: [
              const TextSpan(text: 'Make your next move\n'),
              TextSpan(
                text: 'with confidence.',
                style: GoogleFonts.dmSerifDisplay(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join thousands of Nigerians finding trusted professionals for the homes they love.',
          style: GoogleFonts.inter(
            color: const Color(0xFFC8D1D9),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButton() {
    return ElevatedButton(
      onPressed: () => widget.onNavigate('register-customer'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        minimumSize: const Size(200, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Create your free account',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}
