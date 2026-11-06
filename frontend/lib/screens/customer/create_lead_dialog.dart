import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      categoryId: _selectedCategoryId,
      providerId: _selectedProviderId,
      state: _selectedState ?? 'Lagos',
      city: _selectedCity ?? 'Ikeja',
      preferredContact: _preferredContact,
    );

    if (lead != null && mounted) {
      Navigator.of(context).pop();
      _showSuccessDialog(lead.reference);
    }
  }

  void _showSuccessDialog(String reference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Enquiry Submitted',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your enquiry has been successfully created and forwarded.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.ivory,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reference code:',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate),
                  ),
                  Text(
                    reference,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
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
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
                              'NEW ENQUIRY',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tell us what you need.',
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.slate, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit a structured request directly to verified professionals across Nigeria.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.slate,
                  ),
                ),
                const SizedBox(height: 20),

                if (widget.preselectedProvider != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.ivory,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.business_outlined, color: AppColors.gold, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DIRECT ENQUIRY TO',
                                style: GoogleFonts.manrope(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: AppColors.slate,
                                ),
                              ),
                              Text(
                                widget.preselectedProvider!.displayName,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Enquiry Type & Category
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('ENQUIRY TYPE'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _enquiryType,
                            decoration: const InputDecoration(),
                            items: AppConstants.enquiryTypes.map((t) {
                              return DropdownMenuItem(value: t, child: Text(t));
                            }).toList(),
                            onChanged: (v) => setState(() => _enquiryType = v ?? 'Service request'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('SERVICE CATEGORY'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: _selectedCategoryId ??
                                (dir.categories.isNotEmpty ? dir.categories.first.id : null),
                            decoration: const InputDecoration(),
                            items: dir.categories.map((c) {
                              return DropdownMenuItem(value: c.id, child: Text(c.name));
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedCategoryId = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                _buildFieldLabel('ENQUIRY TITLE'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Repair kitchen pipe leak and install mixer tap',
                  ),
                  validator: (v) => (v == null || v.trim().length < 5)
                      ? 'Title must be at least 5 characters'
                      : null,
                ),
                const SizedBox(height: 16),

                // Description
                _buildFieldLabel('DESCRIPTION OF WORK'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe your requirements, timing, and specific home needs in detail...',
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Description must be at least 10 characters'
                      : null,
                ),
                const SizedBox(height: 16),

                // Location
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('STATE'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedState,
                            decoration: const InputDecoration(),
                            items: AppConstants.nigerianStates.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s));
                            }).toList(),
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
                          _buildFieldLabel('CITY'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: cities.contains(_selectedCity) ? _selectedCity : cities.first,
                            decoration: const InputDecoration(),
                            items: cities.map((c) {
                              return DropdownMenuItem(value: c, child: Text(c));
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedCity = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Preferred Contact Method
                _buildFieldLabel('PREFERRED CONTACT METHOD'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _preferredContact,
                  decoration: const InputDecoration(),
                  items: AppConstants.contactMethods.map((m) {
                    return DropdownMenuItem(value: m, child: Text(m));
                  }).toList(),
                  onChanged: (v) => setState(() => _preferredContact = v ?? 'Phone'),
                ),
                const SizedBox(height: 28),

                // Actions
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
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Submit enquiry'),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 15),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.manrope(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.navy,
      ),
    );
  }
}
