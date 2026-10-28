import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/directory_provider.dart';
import '../../models/provider_model.dart';
import '../../widgets/navbar.dart';
import '../../widgets/footer.dart';
import '../../widgets/verification_badge.dart';

class LandingScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const LandingScreen({super.key, required this.onNavigate});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedState;

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
    dir.setLocationFilter(_selectedState, null);
    dir.setSearchQuery(_searchController.text);
    widget.onNavigate('directory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Navbar(onNavigate: widget.onNavigate),
            _buildHero(context),
            _buildCategories(context),
            _buildHowItWorks(context),
            _buildFeaturedProviders(context),
            Footer(onNavigate: widget.onNavigate),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isMobile ? 48 : 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Nigeria\'s Trusted Home Services Network',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Headline
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 32 : 52,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  AppConstants.appSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Search Box
              Container(
                constraints: const BoxConstraints(maxWidth: 820),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: isMobile
                    ? Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'What service do you need? (e.g. Plumber, AC repair)',
                              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                              border: InputBorder.none,
                            ),
                          ),
                          const Divider(),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedState,
                            decoration: const InputDecoration(
                              hintText: 'Select State',
                              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                              border: InputBorder.none,
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All States')),
                              ...AppConstants.nigerianStates.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                            ],
                            onChanged: (v) => setState(() => _selectedState = v),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onSearchSubmit,
                              child: const Text('Find a Professional'),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: (_) => _onSearchSubmit(),
                              decoration: const InputDecoration(
                                hintText: 'What service do you need? (e.g. Plumber, AC repair)',
                                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(width: 1, height: 36, color: AppColors.border),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedState,
                                hint: const Row(
                                  children: [
                                    SizedBox(width: 12),
                                    Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 20),
                                    SizedBox(width: 8),
                                    Text('All States', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                  ],
                                ),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: Text('All States'),
                                    ),
                                  ),
                                  ...AppConstants.nigerianStates.map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Text(s),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (v) => setState(() => _selectedState = v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _onSearchSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                            ),
                            child: const Text('Find a Professional'),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // Trust note
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildFeatureChip('Direct enquiries'),
                  _buildFeatureChip('Transparent lead tracking'),
                  _buildFeatureChip('Verified professionals'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    final dir = context.watch<DirectoryProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    final categoryIcons = <String, IconData>{
      'plumbing': Icons.plumbing,
      'electrical-services': Icons.electric_bolt,
      'home-cleaning': Icons.cleaning_services,
      'carpentry': Icons.handyman,
      'painting': Icons.format_paint,
      'air-conditioning-and-hvac': Icons.ac_unit,
      'appliance-repairs': Icons.home_repair_service,
      'moving-services': Icons.local_shipping,
      'home-maintenance': Icons.build,
    };

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 48 : 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Home Services',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select a category to discover available service providers.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => widget.onNavigate('directory'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View All'),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Popular Home Services',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Select a category to discover available service providers.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () => widget.onNavigate('directory'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View All'),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isMobile ? 1.05 : 1.15,
                ),
                itemCount: dir.categories.length,
                itemBuilder: (ctx, i) {
                  final cat = dir.categories[i];
                  final icon = categoryIcons[cat.slug] ?? Icons.home_repair_service;

                  return InkWell(
                    onTap: () {
                      dir.setCategoryFilter(cat.id);
                      widget.onNavigate('directory');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.sage,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(height: 10),
                          Flexible(
                            child: Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    final steps = [
      {
        'num': '01',
        'title': 'Find a Professional',
        'desc': 'Search local providers across Lagos, Abuja, and other states filtered by category, location, and ratings.',
        'icon': Icons.search,
      },
      {
        'num': '02',
        'title': 'Send an Enquiry',
        'desc': 'Submit a structured service or housing enquiry with your location and contact preference (Phone, WhatsApp, Email).',
        'icon': Icons.send_rounded,
      },
      {
        'num': '03',
        'title': 'Track Your Request',
        'desc': 'Receive a unique reference number (e.g. FH-2026-0001) and follow real-time status updates through resolution.',
        'icon': Icons.track_changes_rounded,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 850;

        return Container(
          color: AppColors.background,
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 16 : 24,
            vertical: isNarrow ? 36 : 64,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Text(
                    'How FirstHome Works',
                    style: TextStyle(
                      fontSize: isNarrow ? 24 : 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Transparent, reliable connection between homeowners and vetted providers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 36),
                  isNarrow
                      ? Column(
                          children: steps.map((s) => _buildStepCard(s, isNarrow: true)).toList(),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: steps
                              .map(
                                (s) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: _buildStepCard(s, isNarrow: false),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepCard(Map<String, dynamic> s, {bool isNarrow = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isNarrow ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(s['icon'] as IconData, color: AppColors.primary, size: 22),
              ),
              Text(
                s['num'] as String,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            s['title'] as String,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s['desc'] as String,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProviders(BuildContext context) {
    final dir = context.watch<DirectoryProvider>();
    final featured = dir.providers.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 850;

        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 16 : 24,
            vertical: isNarrow ? 36 : 64,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNarrow)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Featured Service Professionals',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Verified providers active in your state with proven customer track records.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => widget.onNavigate('directory'),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Browse All Providers'),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Featured Service Professionals',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Verified providers active in your state with proven customer track records.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: () => widget.onNavigate('directory'),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Browse All Providers'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  if (dir.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (featured.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No providers found in this category.'),
                      ),
                    )
                  else
                    isNarrow
                        ? Column(
                            children: featured.map((p) => _buildProviderCard(p)).toList(),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: featured
                                .map(
                                  (p) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: _buildProviderCard(p),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProviderCard(ProviderModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.sage,
                child: Text(
                  p.displayName.isNotEmpty ? p.displayName[0] : 'P',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${p.city}, ${p.state}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.categoryName,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              VerificationBadge(status: p.verificationStatus, compact: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            p.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onNavigate('provider-detail', args: p),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('View Profile', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onNavigate('create-lead', args: p),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Enquire', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
