import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/provider_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/directory_provider.dart';
import '../../providers/lead_provider.dart';

class CreateLeadDialog extends StatefulWidget {
  final ProviderModel? preselectedProvider;
  final Function(String route, {dynamic args}) onNavigate;

  const CreateLeadDialog({
    super.key,
    this.preselectedProvider,
    required this.onNavigate,
  });

  @override
  State<CreateLeadDialog> createState() => _CreateLeadDialogState();
}

class _CreateLeadDialogState extends State<CreateLeadDialog> {
  final _formKey = GlobalKey<FormState>();

  String _enquiryType = 'Service request';
  int? _selectedCategoryId;
  int? _selectedProviderId;
  String? _selectedState;
  String? _selectedCity;
  String _preferredContact = 'Phone';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final dir = context.read<DirectoryProvider>();

    if (widget.preselectedProvider != null) {
      _selectedProviderId = widget.preselectedProvider!.id;
      _selectedCategoryId = widget.preselectedProvider!.categoryId;
      _selectedState = widget.preselectedProvider!.state;
      _selectedCity = widget.preselectedProvider!.city;
    } else {
      _selectedState = auth.currentUser?.state ?? 'Lagos';
      _selectedCity = auth.currentUser?.city ?? 'Ikeja';
      if (dir.categories.isNotEmpty) {
        _selectedCategoryId = dir.categories.first.id;
      }
    }

    if (auth.currentUser?.contactPreference != null) {
      _preferredContact = auth.currentUser!.contactPreference!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      Navigator.of(context).pop();
      widget.onNavigate('login');
      return;
    }

    final leadProv = context.read<LeadProvider>();
    final lead = await leadProv.createLead(
      enquiryType: _enquiryType,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      state: _selectedState ?? 'Lagos',
      city: _selectedCity ?? 'Ikeja',
      preferredContact: _preferredContact,
      categoryId: _selectedCategoryId,
      providerId: _selectedProviderId,
    );

    if (lead != null && mounted) {
      Navigator.of(context).pop();
      _showSuccessDialog(lead.reference);
    }
  }

  void _showSuccessDialog(String reference) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text('Enquiry Submitted', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your enquiry has been successfully registered and recorded in the database.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sage,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Reference Code:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(
                    reference,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can track real-time status transitions under "My Enquiries" on your dashboard.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onNavigate('customer-dashboard');
            },
            child: const Text('View in My Enquiries'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dir = context.watch<DirectoryProvider>();
    final leadProv = context.watch<LeadProvider>();
    final cities = AppConstants.stateCities[_selectedState] ?? ['General'];

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 520;

            final enquiryTypeField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enquiry Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _enquiryType,
                  items: AppConstants.enquiryTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _enquiryType = v ?? 'Service request'),
                ),
              ],
            );

            final categoryField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Service Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _selectedCategoryId ?? (dir.categories.isNotEmpty ? dir.categories.first.id : null),
                  items: dir.categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
              ],
            );

            final stateField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('State', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedState,
                  items: AppConstants.nigerianStates
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
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
            );

            final cityField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('City / District', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: cities.contains(_selectedCity) ? _selectedCity : cities.first,
                  items: cities
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCity = v),
                ),
              ],
            );

            return SingleChildScrollView(
              padding: EdgeInsets.all(isNarrow ? 18 : 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.sage,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Flexible(
                                child: Text(
                                  'Create New Enquiry',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Submit a structured service request or housing enquiry directly to providers.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),

                    const SizedBox(height: 20),

                    if (widget.preselectedProvider != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.sage.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.business, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Direct Enquiry To:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  Text(
                                    widget.preselectedProvider!.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Enquiry Type & Category
                    if (isNarrow) ...[
                      enquiryTypeField,
                      const SizedBox(height: 14),
                      categoryField,
                    ] else ...[
                      Row(
                        children: [
                          Expanded(child: enquiryTypeField),
                          const SizedBox(width: 12),
                          Expanded(child: categoryField),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Title
                    const Text('Enquiry Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Repair kitchen pipe leak and install mixer tap',
                        prefixIcon: Icon(Icons.title, size: 18),
                      ),
                      validator: (v) => (v == null || v.trim().length < 5) ? 'Title must be at least 5 characters' : null,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    const Text('Description of Work', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe your requirements, timing, and specific home needs in detail...',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().length < 10) ? 'Description must be at least 10 characters' : null,
                    ),

                    const SizedBox(height: 16),

                    // Location
                    if (isNarrow) ...[
                      stateField,
                      const SizedBox(height: 14),
                      cityField,
                    ] else ...[
                      Row(
                        children: [
                          Expanded(child: stateField),
                          const SizedBox(width: 12),
                          Expanded(child: cityField),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Preferred Contact Method
                    const Text('Preferred Contact Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _preferredContact,
                      items: AppConstants.contactMethods
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => _preferredContact = v ?? 'Phone'),
                    ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: leadProv.isLoading ? null : _submit,
                        child: leadProv.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Submit Enquiry'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  ),
);
}
}
