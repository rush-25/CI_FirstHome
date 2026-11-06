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
import '../../widgets/luxury_interactions.dart';
import 'provider_detail_dialog.dart';

class DirectoryScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const DirectoryScreen({super.key, required this.onNavigate});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dir = context.read<DirectoryProvider>();
      if (dir.categories.isEmpty) dir.loadCategories();
      _searchController.text = dir.searchQuery;
      dir.fetchProviders(page: dir.currentPage);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(ProviderModel p) {
    showDialog(
      context: context,
      builder: (ctx) => ProviderDetailDialog(
        provider: p,
        onEnquire: (prov) => widget.onNavigate('create-lead', args: prov),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dir = context.watch<DirectoryProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;
    final cities = dir.selectedState != null
        ? (AppConstants.stateCities[dir.selectedState!] ?? ['General'])
        : <String>[];

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 82),

                // Directory Hero Section
            Container(
              width: double.infinity,
              color: AppColors.navy,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 48,
                vertical: isMobile ? 50 : 75,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 14, height: 2, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Text(
                            'PROVIDER DIRECTORY',
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
                            fontSize: isMobile ? 32 : 48,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                          children: [
                            const TextSpan(text: 'Find expertise you can '),
                            TextSpan(
                              text: 'trust.',
                              style: GoogleFonts.dmSerifDisplay(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFF2ECE1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Explore verified home professionals serving communities across Nigeria.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFAEB8C2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Directory Content Body
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 18 : 36,
                vertical: 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Directory Filter Bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.navy.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Search field
                            TextField(
                              controller: _searchController,
                              onSubmitted: (v) => dir.setSearchQuery(v),
                              decoration: InputDecoration(
                                hintText: 'Search by provider name, keyword or service...',
                                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.slate),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.arrow_forward, size: 18),
                                  onPressed: () => dir.setSearchQuery(_searchController.text),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Dropdown Filters
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                // Category
                                SizedBox(
                                  width: 220,
                                  child: DropdownButtonFormField<int?>(
                                    isExpanded: true,
                                    value: dir.selectedCategoryId,
                                    decoration: const InputDecoration(
                                      labelText: 'Service category',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    items: [
                                      const DropdownMenuItem(value: null, child: Text('All services')),
                                      ...dir.categories.map(
                                        (c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) => dir.setCategoryFilter(v),
                                  ),
                                ),

                                // State
                                SizedBox(
                                  width: 170,
                                  child: DropdownButtonFormField<String?>(
                                    isExpanded: true,
                                    value: dir.selectedState,
                                    decoration: const InputDecoration(
                                      labelText: 'State',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    items: [
                                      const DropdownMenuItem(value: null, child: Text('All states')),
                                      ...AppConstants.nigerianStates.map(
                                        (s) => DropdownMenuItem(value: s, child: Text(s)),
                                      ),
                                    ],
                                    onChanged: (v) => dir.setLocationFilter(v, null),
                                  ),
                                ),

                                // City
                                if (cities.isNotEmpty)
                                  SizedBox(
                                    width: 170,
                                    child: DropdownButtonFormField<String?>(
                                      isExpanded: true,
                                      value: dir.selectedCity,
                                      decoration: const InputDecoration(
                                        labelText: 'City',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      items: [
                                        const DropdownMenuItem(value: null, child: Text('All cities')),
                                        ...cities.map(
                                          (c) => DropdownMenuItem(value: c, child: Text(c)),
                                        ),
                                      ],
                                      onChanged: (v) => dir.setLocationFilter(dir.selectedState, v),
                                    ),
                                  ),

                                // Reset Filters
                                if (dir.selectedCategoryId != null ||
                                    dir.selectedState != null ||
                                    dir.searchQuery.isNotEmpty)
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      dir.clearFilters();
                                    },
                                    icon: const Icon(Icons.refresh, size: 15),
                                    label: const Text('Reset filters'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 48),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Results Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${dir.totalProviders} trusted providers',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Showing active, verified professionals',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.slate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Loading State
                      if (dir.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(60.0),
                            child: CircularProgressIndicator(color: AppColors.navy),
                          ),
                        )
                      // Empty State
                      else if (dir.providers.isEmpty)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: AppColors.slate),
                                const SizedBox(height: 16),
                                Text(
                                  'No providers found',
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a broader search or choose another service category.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.slate,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    dir.clearFilters();
                                  },
                                  child: const Text('Clear filters'),
                                ),
                              ],
                            ),
                          ),
                        )
                      // Provider Cards Grid
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            int cols = 3;
                            if (constraints.maxWidth < 650) {
                              cols = 1;
                            } else if (constraints.maxWidth < 1000) {
                              cols = 2;
                            }

                            return GridView.builder(
                              itemCount: dir.providers.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio: cols == 1 ? 1.7 : 1.4,
                              ),
                              itemBuilder: (context, index) {
                                final p = dir.providers[index];
                                return _buildProviderCard(p);
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 40),

                      // Pagination Controls
                      if (dir.totalPages > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: dir.currentPage > 1
                                  ? () => dir.fetchProviders(page: dir.currentPage - 1)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(dir.totalPages, (i) {
                              final pageNum = i + 1;
                              final isActive = pageNum == dir.currentPage;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: InkWell(
                                  onTap: () => dir.fetchProviders(page: pageNum),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isActive ? AppColors.navy : Colors.white,
                                      border: Border.all(
                                        color: isActive ? AppColors.navy : AppColors.border,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$pageNum',
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isActive ? Colors.white : AppColors.navy,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: dir.currentPage < dir.totalPages
                                  ? () => dir.fetchProviders(page: dir.currentPage + 1)
                                  : null,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
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

    return LuxuryHoverCard(
      borderRadius: 4,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      onTap: () => _openDetail(p),
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
              Row(
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
            ],
          ),
        ],
      ),
    );
  }
}
