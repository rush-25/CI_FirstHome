import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/lead_model.dart';
import '../../widgets/status_badge.dart';

class LeadDetailDialog extends StatelessWidget {
  final LeadModel lead;

  const LeadDetailDialog({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.ivory,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            lead.reference,
                            style: GoogleFonts.manrope(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        StatusBadge(status: lead.status),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.slate),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                lead.title,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 16),

              // Overview Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.ivory,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _InfoRow(label: 'Enquiry Type', value: lead.enquiryType),
                    const Divider(height: 16),
                    _InfoRow(
                      label: 'Service Category',
                      value: lead.categoryName ?? 'General',
                    ),
                    const Divider(height: 16),
                    _InfoRow(
                      label: 'Assigned Provider',
                      value: lead.providerName != null && lead.providerName!.isNotEmpty
                          ? lead.providerName!
                          : 'Open Pool / Unassigned',
                    ),
                    const Divider(height: 16),
                    _InfoRow(
                      label: 'Location',
                      value: '${lead.city}, ${lead.state}',
                    ),
                    const Divider(height: 16),
                    _InfoRow(
                      label: 'Preferred Contact',
                      value: lead.preferredContact,
                    ),
                    const Divider(height: 16),
                    _InfoRow(
                      label: 'Submitted Date',
                      value: dateFormat.format(lead.createdAt.toLocal()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'DESCRIPTION',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: AppColors.slate,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  lead.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.navy,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.slate,
            fontSize: 12.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}
