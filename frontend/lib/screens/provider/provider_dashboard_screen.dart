import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/lead_model.dart';
import '../../models/provider_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/directory_provider.dart';
import '../../core/services/api_service.dart';
import '../../widgets/navbar.dart';
import '../../widgets/footer.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/verification_badge.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const ProviderDashboardScreen({super.key, required this.onNavigate});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  ProviderModel? _myProfile;
  List<LeadModel> _myLeads = [];
  bool _isLoading = true;

  // Edit profile form
  final _profileFormKey = GlobalKey<FormState>();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  int? _selectedCategoryId;
  String? _selectedState = 'Lagos';
  String? _selectedCity = 'Ikeja';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated || !auth.isProvider) {
        widget.onNavigate('login');
        return;
      }
      _loadProviderData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadProviderData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _api.getMyProviderProfile();
      final leads = await _api.getMyProviderLeads();

      _myProfile = profile;
      _myLeads = leads;
      _businessNameController.text = profile.displayName;
      _emailController.text = profile.contactEmail;
      _descController.text = profile.description;
      _selectedCategoryId = profile.categoryId;
      _selectedState = profile.state;
      _selectedCity = profile.city;
    } catch (_) {
      // Handled cleanly
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBusinessProfile() async {
    if (!_profileFormKey.currentState!.validate() || _myProfile == null) return;
    setState(() => _isLoading = true);
    try {
      final updated = await _api.updateProviderProfile(
        _myProfile!.id,
        displayName: _businessNameController.text.trim(),
        contactEmail: _emailController.text.trim(),
        categoryId: _selectedCategoryId ?? _myProfile!.categoryId,
        state: _selectedState ?? 'Lagos',
        city: _selectedCity ?? 'Ikeja',
        description: _descController.text.trim(),
      );
      _myProfile = updated;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dir = context.watch<DirectoryProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;
    final cities = AppConstants.stateCities[_selectedState] ?? ['General'];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                      // Header
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 700;
                          final infoCol = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _myProfile?.displayName ?? 'Provider Portal',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    '${_myProfile?.categoryName ?? 'Services'} • ${_myProfile?.city ?? ''}, ${_myProfile?.state ?? ''}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                  ),
                                  if (_myProfile != null)
                                    VerificationBadge(status: _myProfile!.verificationStatus, compact: true),
                                ],
                              ),
                            ],
                          );

                          final badge = Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (_myProfile?.isActive ?? true) ? AppColors.statusQualifiedBg : AppColors.verifRejectedBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (_myProfile?.isActive ?? true) ? AppColors.success : AppColors.error,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: (_myProfile?.isActive ?? true) ? AppColors.success : AppColors.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  (_myProfile?.isActive ?? true) ? 'Visible in Directory' : 'Hidden from Directory',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: (_myProfile?.isActive ?? true) ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          );

                          return isNarrow
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    infoCol,
                                    const SizedBox(height: 12),
                                    badge,
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: infoCol),
                                    const SizedBox(width: 16),
                                    badge,
                                  ],
                                );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Metric cards
                      isMobile
                          ? Column(
                              children: [
                                StatCard(
                                  title: 'Incoming Leads',
                                  value: _myLeads.length.toString(),
                                  icon: Icons.mark_email_unread_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'New Requests',
                                  value: _myLeads.where((l) => l.status == 'New').length.toString(),
                                  icon: Icons.fiber_new,
                                  color: AppColors.statusNewText,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'Verification Status',
                                  value: _myProfile?.verificationStatus ?? 'Not Started',
                                  icon: Icons.verified_user_outlined,
                                  color: AppColors.gold,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Incoming Leads',
                                    value: _myLeads.length.toString(),
                                    icon: Icons.mark_email_unread_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'New Requests',
                                    value: _myLeads.where((l) => l.status == 'New').length.toString(),
                                    icon: Icons.fiber_new,
                                    color: AppColors.statusNewText,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Verification Status',
                                    value: _myProfile?.verificationStatus ?? 'Not Started',
                                    icon: Icons.verified_user_outlined,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: 32),

                      // Tabs
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
                            Tab(icon: Icon(Icons.inbox, size: 18), text: 'Incoming Leads'),
                            Tab(icon: Icon(Icons.business_outlined, size: 18), text: 'Business Profile'),
                            Tab(icon: Icon(Icons.shield_outlined, size: 18), text: 'Verification Panel'),
                          ],
                        ),
                      ),

                      // Tab View
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
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildIncomingLeadsTab(),
                                    _buildBusinessProfileTab(dir, cities),
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

  Widget _buildIncomingLeadsTab() {
    final dateFormat = DateFormat('dd MMM yyyy');

    if (_myLeads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('No incoming leads yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Enquiries directed to your business profile or category will appear here.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _myLeads.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final l = _myLeads[i];
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
              child: const Icon(Icons.handyman_outlined, color: AppColors.primary, size: 20),
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
                  'Customer: ${l.customerName} • Contact: ${l.preferredContact} • ${dateFormat.format(l.createdAt.toLocal())}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  l.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBusinessProfileTab(DirectoryProvider dir, List<String> cities) {
    return SingleChildScrollView(
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Business Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Manage how your services appear in the FirstHome Nigeria public directory.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Business Display Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _businessNameController,
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
                      const Text('Contact Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
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
                      const Text('Primary Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedCategoryId,
                        items: dir.categories
                            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCategoryId = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
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
                const Text('Business Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Min 10 characters' : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBusinessProfile,
              child: const Text('Save Business Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationTab(AuthProvider auth) {
    final status = _myProfile?.verificationStatus ?? 'NotStarted';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Demo verification only — no real identity checks.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              VerificationBadge(status: status),
            ],
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
                    'Verified status elevates your visibility in directory searches and awards your profile a verified badge.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Current Status: $status',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            status == 'Verified'
                ? 'Your provider account is verified. A verified badge is publicly shown to customers on the directory.'
                : status == 'Pending'
                    ? 'Your verification application is currently pending administrator review.'
                    : 'Submit your profile for verification to earn a verified trust badge on your listing.',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (status == 'NotStarted' || status == 'Rejected') ...[
            ElevatedButton.icon(
              onPressed: () async {
                final ok = await auth.consentMockVerification();
                if (ok) {
                  await _loadProviderData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification request submitted. Status is now Pending.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.shield_outlined, size: 16),
              label: const Text('Request Verification'),
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
