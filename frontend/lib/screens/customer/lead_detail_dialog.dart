import 'package:flutter/material.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lead.reference,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        StatusBadge(status: lead.status),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                lead.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // Overview grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _InfoRow(label: 'Enquiry Type', value: lead.enquiryType),
                    const Divider(height: 16),
                    _InfoRow(label: 'Service Category', value: lead.categoryName ?? 'General'),
                    const Divider(height: 16),
                    _InfoRow(
                      label: 'Assigned Provider',
                      value: lead.providerName != null && lead.providerName!.isNotEmpty
                          ? lead.providerName!
                          : 'Open Pool / Unassigned',
                    ),
                    const Divider(height: 16),
                    _InfoRow(label: 'Location', value: '${lead.city}, ${lead.state}'),
                    const Divider(height: 16),
                    _InfoRow(label: 'Preferred Contact', value: lead.preferredContact),
                    const Divider(height: 16),
                    _InfoRow(label: 'Submitted Date', value: dateFormat.format(lead.createdAt.toLocal())),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text('Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  lead.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
                ),
              ),

              const SizedBox(height: 24),

              // Status History Timeline
              Row(
                children: const [
                  Icon(Icons.history, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Audit & Status History',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (lead.history.isEmpty)
                const Text('No status transitions recorded.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
              else
                Column(
                  children: List.generate(lead.history.length, (i) {
                    final h = lead.history[i];
                    final isLast = i == lead.history.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isLast ? AppColors.primary : AppColors.sage,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isLast ? Icons.check : Icons.circle,
                                size: 12,
                                color: isLast ? Colors.white : AppColors.primary,
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 36,
                                color: AppColors.border,
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    StatusBadge(status: h.newStatus, compact: true),
                                    const SizedBox(width: 8),
                                    Text(
                                      h.oldStatus != null
                                          ? 'Changed from ${h.oldStatus}'
                                          : 'Initial creation',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'By ${h.changedByName} • ${dateFormat.format(h.changedAt.toLocal())}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close Details'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
