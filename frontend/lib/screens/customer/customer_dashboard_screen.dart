import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/lead_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lead_provider.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/navbar.dart';
import '../../widgets/footer.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/verification_badge.dart';
import 'create_lead_dialog.dart';
import 'lead_detail_dialog.dart';

class CustomerDashboardScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const CustomerDashboardScreen({super.key, required this.onNavigate});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Profile fields
  final _profileFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedState;
  String? _selectedCity;
  String _contactPref = 'Phone';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedState = user?.state ?? 'Lagos';
    _selectedCity = user?.city ?? 'Ikeja';
    _contactPref = user?.contactPreference ?? 'Phone';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!auth.isAuthenticated || !auth.isCustomer) {
        widget.onNavigate('login');
        return;
      }
      context.read<LeadProvider>().fetchMyLeads(page: 1);
      auth.loadVerificationState();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _openCreateEnquiry() {
    showDialog(
      context: context,
      builder: (ctx) => CreateLeadDialog(
        onNavigate: widget.onNavigate,
      ),
    );
  }

  void _openLeadDetail(LeadModel lead) {
    showDialog(
      context: context,
      builder: (ctx) => LeadDetailDialog(lead: lead),
    );
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      state: _selectedState,
      city: _selectedCity,
      contactPreference: _contactPref,
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final leadProv = context.watch<LeadProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DemoBanner(),
            Navbar(onNavigate: widget.onNavigate),
            Container(
              color: AppColors.background,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 24 : 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Action
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 650;
                          final infoCol = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, ${auth.currentUser?.fullName.split(' ')[0] ?? 'Customer'}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Manage your home service requests and track provider statuses.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          );

                          final actionBtn = ElevatedButton.icon(
                            onPressed: _openCreateEnquiry,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('New Enquiry'),
                          );

                          return isNarrow
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    infoCol,
                                    const SizedBox(height: 12),
                                    actionBtn,
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: infoCol),
                                    const SizedBox(width: 16),
                                    actionBtn,
                                  ],
                                );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Metrics Cards
                      isMobile
                          ? Column(
                              children: [
                                StatCard(
                                  title: 'Total Enquiries',
                                  value: leadProv.totalLeads.toString(),
                                  icon: Icons.list_alt,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'New Requests',
                                  value: leadProv.newCount.toString(),
                                  icon: Icons.fiber_new,
                                  color: AppColors.statusNewText,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'In Progress / Qualified',
                                  value: (leadProv.contactedCount + leadProv.qualifiedCount).toString(),
                                  icon: Icons.pending_actions,
                                  color: AppColors.statusContactedText,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'Resolved / Closed',
                                  value: leadProv.closedCount.toString(),
                                  icon: Icons.check_circle_outline,
                                  color: AppColors.success,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Total Enquiries',
                                    value: leadProv.totalLeads.toString(),
                                    icon: Icons.list_alt,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'New Requests',
                                    value: leadProv.newCount.toString(),
                                    icon: Icons.fiber_new,
                                    color: AppColors.statusNewText,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'In Progress / Qualified',
                                    value: (leadProv.contactedCount + leadProv.qualifiedCount).toString(),
                                    icon: Icons.pending_actions,
                                    color: AppColors.statusContactedText,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Resolved / Closed',
                                    value: leadProv.closedCount.toString(),
                                    icon: Icons.check_circle_outline,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: 32),

                      // Navigation Tabs
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          border: Border(bottom: BorderSide(color: AppColors.border)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          tabs: const [
                            Tab(icon: Icon(Icons.receipt_long, size: 18), text: 'My Enquiries'),
                            Tab(icon: Icon(Icons.person_outline, size: 18), text: 'My Profile'),
                            Tab(icon: Icon(Icons.shield_outlined, size: 18), text: 'Mock KYC Preview'),
                          ],
                        ),
                      ),

                      // Tab Content Box
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                          border: Border(
                            left: BorderSide(color: AppColors.border),
                            right: BorderSide(color: AppColors.border),
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: SizedBox(
                          height: 520,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildMyEnquiriesTab(leadProv, isMobile),
                              _buildProfileTab(auth),
                              _buildVerificationTab(auth),
                            ],
                          ),
                        ),
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
    );
  }

  Widget _buildMyEnquiriesTab(LeadProvider leadProv, bool isMobile) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Column(
      children: [
        // Filter bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (v) => leadProv.setSearchQuery(v),
                decoration: InputDecoration(
                  hintText: 'Search by reference (e.g. FH-2026-0001) or title...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    onPressed: () => leadProv.setSearchQuery(_searchController.text),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<String?>(
                initialValue: leadProv.statusFilter,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Statuses')),
                  ...AppConstants.leadStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (v) => leadProv.setStatusFilter(v),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // List
        Expanded(
          child: leadProv.isLoading
              ? const Center(child: CircularProgressIndicator())
              : leadProv.myLeads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          const Text('No enquiries found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('Submit your first service or housing enquiry above.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _openCreateEnquiry,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Create Enquiry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: leadProv.myLeads.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final l = leadProv.myLeads[i];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.sage,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.build_outlined, color: AppColors.primary, size: 20),
                            ),
                            title: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  l.reference,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
                                ),
                                StatusBadge(status: l.status, compact: true),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(l.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(
                                  '${l.categoryName ?? 'Service'} • Provider: ${l.providerName ?? 'Open Request'} • ${dateFormat.format(l.createdAt.toLocal())}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            trailing: OutlinedButton(
                              onPressed: () => _openLeadDetail(l),
                              child: const Text('View Timeline', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(AuthProvider auth) {
    final cities = AppConstants.stateCities[_selectedState] ?? ['General'];

    return SingleChildScrollView(
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage Customer Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Update your personal and contact details for incoming provider responses.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        validator: (v) => (v == null || v.trim().length < 2) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Phone Number (Synthetic)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        validator: (v) => (v == null || v.trim().length < 7) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('State', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedState,
                        items: AppConstants.nigerianStates
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedState = v;
                            _selectedCity = (AppConstants.stateCities[v] ?? ['General']).first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('City', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: cities.contains(_selectedCity) ? _selectedCity : cities.first,
                        items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _selectedCity = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Preferred Contact Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _contactPref,
                  items: AppConstants.contactMethods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _contactPref = v ?? 'Phone'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _saveProfile,
              child: const Text('Save Profile Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationTab(AuthProvider auth) {
    final vState = auth.verificationState;
    final status = vState?.status ?? 'NotStarted';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              final label = const Text('Identity Verification Preview (MOCK)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
              final badge = VerificationBadge(status: status);

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label,
                        const SizedBox(height: 8),
                        badge,
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        label,
                        badge,
                      ],
                    );
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: const [
                Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Demo verification only — no real identity checks. FirstHome Nigeria never requests or stores actual BVN, NIN, or government identity documents in this prototype.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Current State: $status',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            status == 'Verified'
                ? 'Your simulated customer identity profile is marked Verified. Service providers see this badge on your enquiries.'
                : status == 'Pending'
                    ? 'Your simulated verification request is currently Pending review by an administrator.'
                    : 'Consent to mock KYC simulation to request a simulated verification state.',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (status == 'NotStarted' || status == 'Rejected') ...[
            ElevatedButton.icon(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      final ok = await auth.consentMockVerification();
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mock verification consent submitted! Status is now Pending.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.fingerprint, size: 16),
              label: const Text('Simulate Verification Consent (Mock)'),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.check, size: 16),
              label: Text('Verification $status'),
            ),
          ],
        ],
      ),
    );
  }
}
