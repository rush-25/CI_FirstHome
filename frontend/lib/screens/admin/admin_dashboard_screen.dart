import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/lead_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/navbar.dart';
import '../../widgets/footer.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/verification_badge.dart';
import '../customer/lead_detail_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const AdminDashboardScreen({super.key, required this.onNavigate});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _leadSearchController = TextEditingController();
  final TextEditingController _customerSearchController = TextEditingController();
  final TextEditingController _providerSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated || !auth.isAdmin) {
        widget.onNavigate('login');
        return;
      }
      final admin = context.read<AdminProvider>();
      admin.fetchSummary();
      admin.fetchLeads(page: 1);
      admin.fetchCustomers(page: 1);
      admin.fetchProviders(page: 1);
      admin.fetchVerificationEvents(page: 1);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _leadSearchController.dispose();
    _customerSearchController.dispose();
    _providerSearchController.dispose();
    super.dispose();
  }

  void _openStatusChangeModal(LeadModel lead) {
    String? selectedNewStatus;
    final validNextStatuses = <String>[];

    switch (lead.status) {
      case 'New':
        validNextStatuses.addAll(['Contacted', 'Closed']);
        break;
      case 'Contacted':
        validNextStatuses.addAll(['Qualified', 'Closed']);
        break;
      case 'Qualified':
        validNextStatuses.add('Closed');
        break;
      case 'Closed':
      default:
        break;
    }

    if (validNextStatuses.isEmpty) {
      ScquiryDialog(
        context: context,
        title: 'Lead Already Closed',
        message: 'This lead is already closed and has reached its final state.',
      );
      return;
    }

    selectedNewStatus = validNextStatuses.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Change Lead Status: ${lead.reference}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status: ${lead.status}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              const Text('Select New Valid Status:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedNewStatus,
                items: validNextStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setModalState(() => selectedNewStatus = v),
              ),
              const SizedBox(height: 16),
              const Text(
                'A status change will automatically append an entry to the LeadStatusHistory audit log with your admin timestamp.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                if (selectedNewStatus != null) {
                  final admin = context.read<AdminProvider>();
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await admin.updateLeadStatus(lead.id, selectedNewStatus!);
                  if (ok && mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Lead status updated to $selectedNewStatus!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              child: const Text('Confirm Change'),
            ),
          ],
        ),
      ),
    );
  }

  void _openMockVerificationModal(int userId, String name, String currentStatus) {
    String selectedStatus = currentStatus == 'Verified' ? 'Rejected' : 'Verified';
    final noteController = TextEditingController(text: 'Admin simulated verification (MOCK).');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.shield_outlined, color: AppColors.gold),
              SizedBox(width: 8),
              Text('Simulate Mock Verification'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target User: $name (ID #$userId)',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text('Current Status: $currentStatus', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const Text('Select Simulated Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending (Mock)')),
                  DropdownMenuItem(value: 'Verified', child: Text('Verified (Mock)')),
                  DropdownMenuItem(value: 'Rejected', child: Text('Rejected (Mock)')),
                ],
                onChanged: (v) => setModalState(() => selectedStatus = v ?? 'Verified'),
              ),
              const SizedBox(height: 12),
              const Text('Audit Note:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(hintText: 'Enter reason or note...'),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Simulation only. No real BVN/NIN verification is triggered.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final admin = context.read<AdminProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final ok = await admin.simulateMockVerification(
                  userId,
                  selectedStatus,
                  noteController.text.trim(),
                );
                if (ok && mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Mock verification updated to $selectedStatus for $name!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Save Verification'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;
    final summary = admin.summary;

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
                      // Header
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 700;
                          final infoCol = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'FirstHome Operations Dashboard',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Database-driven metrics, lead status orchestration, and simulated KYC management.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          );

                          final refreshBtn = OutlinedButton.icon(
                            onPressed: () {
                              admin.fetchSummary();
                              admin.fetchLeads();
                              admin.fetchCustomers();
                              admin.fetchProviders();
                              admin.fetchVerificationEvents();
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh Data'),
                          );

                          return isNarrow
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    infoCol,
                                    const SizedBox(height: 12),
                                    refreshBtn,
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: infoCol),
                                    const SizedBox(width: 16),
                                    refreshBtn,
                                  ],
                                );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Metrics Cards computed live from database
                      isMobile
                          ? Column(
                              children: [
                                StatCard(
                                  title: 'Total Customers',
                                  value: summary?.totalCustomers.toString() ?? '10',
                                  icon: Icons.people_outline,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'Total Providers',
                                  value: '${summary?.activeProviders ?? 8} / ${summary?.totalProviders ?? 8}',
                                  icon: Icons.business_outlined,
                                  subtitle: 'Active in directory',
                                  color: AppColors.gold,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'Total Leads Generated',
                                  value: summary?.totalLeads.toString() ?? '15',
                                  icon: Icons.receipt_long_outlined,
                                  color: AppColors.statusNewText,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'Qualified / Closed',
                                  value: '${(summary?.leadsByStatus['Qualified'] ?? 0) + (summary?.leadsByStatus['Closed'] ?? 0)}',
                                  icon: Icons.check_circle_outline,
                                  color: AppColors.success,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Total Customers',
                                    value: summary?.totalCustomers.toString() ?? '10',
                                    icon: Icons.people_outline,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Total Providers',
                                    value: '${summary?.activeProviders ?? 8} / ${summary?.totalProviders ?? 8}',
                                    icon: Icons.business_outlined,
                                    subtitle: 'Active in directory',
                                    color: AppColors.gold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Total Leads Generated',
                                    value: summary?.totalLeads.toString() ?? '15',
                                    icon: Icons.receipt_long_outlined,
                                    color: AppColors.statusNewText,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Qualified / Closed',
                                    value: '${(summary?.leadsByStatus['Qualified'] ?? 0) + (summary?.leadsByStatus['Closed'] ?? 0)}',
                                    icon: Icons.check_circle_outline,
                                    color: AppColors.success,
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
                            Tab(icon: Icon(Icons.receipt_long, size: 18), text: 'Leads Management'),
                            Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Customers'),
                            Tab(icon: Icon(Icons.business_outlined, size: 18), text: 'Providers Directory'),
                            Tab(icon: Icon(Icons.shield_outlined, size: 18), text: 'Mock KYC Events'),
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
                          height: 560,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLeadsTab(admin, isMobile),
                              _buildCustomersTab(admin),
                              _buildProvidersTab(admin),
                              _buildVerificationEventsTab(admin),
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

  Widget _buildLeadsTab(AdminProvider admin, bool isMobile) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Column(
      children: [
        // Controls
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _leadSearchController,
                onSubmitted: (v) => admin.searchLeads(v),
                decoration: InputDecoration(
                  hintText: 'Search by reference, customer name, title...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    onPressed: () => admin.searchLeads(_leadSearchController.text),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<String?>(
                initialValue: admin.leadStatusFilter,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Statuses')),
                  ...AppConstants.leadStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (v) => admin.filterLeadsByStatus(v),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Expanded(
          child: admin.isLoading
              ? const Center(child: CircularProgressIndicator())
              : admin.leads.isEmpty
                  ? const Center(child: Text('No leads match the specified criteria.'))
                  : ListView.separated(
                      itemCount: admin.leads.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final l = admin.leads[i];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                                Text('•  ${l.categoryName ?? 'Category'}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(l.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(
                                  'Customer: ${l.customerName} (${l.customerEmail}) • Provider: ${l.providerName ?? 'Unassigned'} • ${dateFormat.format(l.createdAt.toLocal())}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (c) => LeadDetailDialog(lead: l),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  child: const Text('History', style: TextStyle(fontSize: 11)),
                                ),
                                ElevatedButton(
                                  onPressed: () => _openStatusChangeModal(l),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  child: const Text('Change Status', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCustomersTab(AdminProvider admin) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Column(
      children: [
        TextField(
          controller: _customerSearchController,
          onSubmitted: (v) => admin.searchCustomers(v),
          decoration: InputDecoration(
            hintText: 'Search customer name or email...',
            prefixIcon: const Icon(Icons.search, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward, size: 16),
              onPressed: () => admin.searchCustomers(_customerSearchController.text),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: admin.customers.isEmpty
              ? const Center(child: Text('No customers found.'))
              : ListView.separated(
                  itemCount: admin.customers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final c = admin.customers[i];
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.sage,
                          child: Text(c.fullName.isNotEmpty ? c.fullName[0] : 'C', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            VerificationBadge(status: c.verificationStatus, compact: true),
                          ],
                        ),
                        subtitle: Text(
                          '${c.email} • ${c.phone} • Location: ${c.city ?? ''}, ${c.state ?? ''} • Enquiries: ${c.leadCount} • Joined ${dateFormat.format(c.createdAt.toLocal())}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () => _openMockVerificationModal(c.id, c.fullName, c.verificationStatus),
                          child: const Text('Simulate KYC', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProvidersTab(AdminProvider admin) {
    return Column(
      children: [
        TextField(
          controller: _providerSearchController,
          onSubmitted: (v) => admin.searchProviders(v),
          decoration: InputDecoration(
            hintText: 'Search provider name, owner, or email...',
            prefixIcon: const Icon(Icons.search, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward, size: 16),
              onPressed: () => admin.searchProviders(_providerSearchController.text),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: admin.providers.isEmpty
              ? const Center(child: Text('No providers found.'))
              : ListView.separated(
                  itemCount: admin.providers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = admin.providers[i];
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.sage,
                          child: Text(p.displayName.isNotEmpty ? p.displayName[0] : 'P', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            VerificationBadge(status: p.verificationStatus, compact: true),
                          ],
                        ),
                        subtitle: Text(
                          'Owner: ${p.ownerName} • ${p.categoryName} • ${p.city}, ${p.state} • ${p.email}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Active switch
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  p.isActive ? 'Active' : 'Hidden',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: p.isActive ? AppColors.success : AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: p.isActive,
                                  activeThumbColor: AppColors.success,
                                  onChanged: (val) => admin.toggleProviderActive(p.id, p.isActive),
                                ),
                              ],
                            ),
                            OutlinedButton(
                              onPressed: () => _openMockVerificationModal(p.userId, p.displayName, p.verificationStatus),
                              child: const Text('Simulate KYC', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVerificationEventsTab(AdminProvider admin) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 550;
            final labelText = const Text(
              'Simulated Verification Audit Log',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            );
            final mockBadge = Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sage,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('MOCK Engine • No Real BVN/NIN', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
            );

            return isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      labelText,
                      const SizedBox(height: 6),
                      mockBadge,
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      labelText,
                      mockBadge,
                    ],
                  );
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: admin.verificationEvents.isEmpty
              ? const Center(child: Text('No verification audit events recorded.'))
              : ListView.separated(
                  itemCount: admin.verificationEvents.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final ev = admin.verificationEvents[i];
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.history, color: AppColors.primary, size: 20),
                        ),
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              ev.simulatedReference,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary),
                            ),
                            VerificationBadge(status: ev.status, compact: true),
                            Text('Target: ${ev.userName} (${ev.userRole})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        subtitle: Text(
                          'Note: ${ev.note ?? 'None'} • Timestamp: ${dateFormat.format(ev.createdAt.toLocal())}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class ScquiryDialog extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String message;

  const ScquiryDialog({super.key, required this.context, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
