import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/directory_provider.dart';
import '../../models/provider_model.dart';
import '../../widgets/navbar.dart';
import '../../widgets/footer.dart';
import '../../widgets/verification_badge.dart';
import 'provider_detail_dialog.dart';

class DirectoryScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const DirectoryScreen({super.key, required this.onNavigate});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Navbar(onNavigate: widget.onNavigate),
            Container(
              color: AppColors.background,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 32 : 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 650;
                          final titleCol = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Find the Right Professional',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Showing ${dir.totalProviders} active verified service providers across Nigeria',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          );

                          final resetBtn = (dir.selectedCategoryId != null ||
                                  dir.selectedState != null ||
                                  dir.searchQuery.isNotEmpty)
                              ? OutlinedButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    dir.clearFilters();
                                  },
                                  icon: const Icon(Icons.clear_all, size: 16),
                                  label: const Text('Reset Filters'),
                                )
                              : null;

                          return isNarrow
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    titleCol,
                                    if (resetBtn != null) ...[
                                      const SizedBox(height: 12),
                                      resetBtn,
                                    ],
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: titleCol),
                                    if (resetBtn != null) ...[
                                      const SizedBox(width: 16),
                                      resetBtn,
                                    ],
                                  ],
                                );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Filters Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            // Row 1: Search keyword
                            TextField(
                              controller: _searchController,
                              onSubmitted: (v) => dir.setSearchQuery(v),
                              decoration: InputDecoration(
                                hintText: 'Search by provider name, specialty, or description...',
                                prefixIcon: const Icon(Icons.search, size: 20),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.arrow_forward, size: 18),
                                  onPressed: () => dir.setSearchQuery(_searchController.text),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Row 2: Category, State, City, Sort
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                // Category
                                SizedBox(
                                  width: 220,
                                  child: DropdownButtonFormField<int?>(
                                    isExpanded: true,
                                    initialValue: dir.selectedCategoryId,
                                    decoration: const InputDecoration(
                                      labelText: 'Service Category',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    items: [
                                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                                      ...dir.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))),
                                    ],
                                    onChanged: (v) => dir.setCategoryFilter(v),
                                  ),
                                ),
                                // State
                                SizedBox(
                                  width: 180,
                                  child: DropdownButtonFormField<String?>(
                                    isExpanded: true,
                                    initialValue: dir.selectedState,
                                    decoration: const InputDecoration(
                                      labelText: 'State',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    items: [
                                      const DropdownMenuItem(value: null, child: Text('All States')),
                                      ...AppConstants.nigerianStates.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))),
                                    ],
                                    onChanged: (v) => dir.setLocationFilter(v, null),
                                  ),
                                ),
                                // City
                                if (cities.isNotEmpty) ...[
                                  SizedBox(
                                    width: 180,
                                    child: DropdownButtonFormField<String?>(
                                      isExpanded: true,
                                      initialValue: dir.selectedCity,
                                      decoration: const InputDecoration(
                                        labelText: 'City / District',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                      items: [
                                        const DropdownMenuItem(value: null, child: Text('All Cities')),
                                        ...cities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                                      ],
                                      onChanged: (v) => dir.setLocationFilter(dir.selectedState, v),
                                    ),
                                  ),
                                ],
                                // Sort
                                SizedBox(
                                  width: 170,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: dir.sortBy,
                                    decoration: const InputDecoration(
                                      labelText: 'Sort By',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'name', child: Text('Name (A-Z)')),
                                      DropdownMenuItem(value: 'newest', child: Text('Newest Joined')),
                                    ],
                                    onChanged: (v) => dir.setSortBy(v ?? 'name'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Providers Grid / Empty State
                      if (dir.isLoading) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(60),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ] else if (dir.providers.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(60),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
                              const SizedBox(height: 16),
                              const Text(
                                'No matching service providers found',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try clearing your filters or choosing another Nigerian state or service category.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  dir.clearFilters();
                                },
                                child: const Text('Reset All Filters'),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            // Max 4 cards per row; fixed card height avoids empty space.
                            int cols;
                            if (width < 600) {
                              cols = 1;
                            } else if (width < 900) {
                              cols = 2;
                            } else if (width < 1250) {
                              cols = 3;
                            } else {
                              cols = 4;
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                mainAxisExtent: 240,
                              ),
                              itemCount: dir.providers.length,
                              itemBuilder: (ctx, i) {
                                final p = dir.providers[i];
                                return _buildProviderCard(p);
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Pagination
                        if (dir.totalPages > 1) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: dir.currentPage > 1
                                    ? () => dir.fetchProviders(page: dir.currentPage - 1)
                                    : null,
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: const Text('Previous'),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Page ${dir.currentPage} of ${dir.totalPages}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton.icon(
                                onPressed: dir.currentPage < dir.totalPages
                                    ? () => dir.fetchProviders(page: dir.currentPage + 1)
                                    : null,
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Footer(onNavigate: widget.onNavigate),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(ProviderModel p) {
    return Container(
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
                radius: 22,
                backgroundColor: AppColors.sage,
                child: Text(
                  p.displayName.isNotEmpty ? p.displayName[0] : 'P',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              p.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openDetail(p),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Profile', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onNavigate('create-lead', args: p),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Enquire', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
