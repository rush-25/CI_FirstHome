import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/provider_model.dart';
import '../../widgets/verification_badge.dart';

class ProviderDetailDialog extends StatelessWidget {
  final ProviderModel provider;
  final Function(ProviderModel provider) onEnquire;

  const ProviderDetailDialog({
    super.key,
    required this.provider,
    required this.onEnquire,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Cover Banner
              Container(
                height: isMobile ? 100 : 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: EdgeInsets.all(isMobile ? 14 : 20),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: isMobile ? 26 : 32,
                      backgroundColor: Colors.white,
                      child: Text(
                        provider.displayName.isNotEmpty ? provider.displayName[0] : 'P',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 20 : 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.gold, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${provider.city}, ${provider.state}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Body content
              Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            provider.categoryName,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        VerificationBadge(status: provider.verificationStatus),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: AppColors.gold, size: 14),
                              SizedBox(width: 4),
                              Text(
                                '4.9 (18 reviews • Demo)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // About
                    const Text('About This Professional', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(
                      provider.description,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                    ),

                    const SizedBox(height: 24),

                    // Service Details Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.email_outlined,
                            label: 'Contact Email',
                            value: provider.contactEmail,
                          ),
                          const Divider(height: 20),
                          _DetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone (Synthetic)',
                            value: provider.phone,
                          ),
                          const Divider(height: 20),
                          _DetailRow(
                            icon: Icons.verified_user_outlined,
                            label: 'KYC Status (Mock)',
                            value: '${provider.verificationStatus} (Simulated)',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onEnquire(provider);
                            },
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('Send an Enquiry'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
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
