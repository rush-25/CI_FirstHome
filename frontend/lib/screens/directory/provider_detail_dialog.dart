import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final initials = provider.displayName.isNotEmpty
        ? provider.displayName
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase()
        : 'PR';

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.gold, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.manrope(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
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
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.gold,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.city ?? "Lagos"}, ${provider.state ?? ""}',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFC8D1D9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.ivory,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            provider.categoryName ?? 'Home Professional',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        VerificationBadge(
                          status: provider.verificationStatus,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'ABOUT THE PROVIDER',
                      style: GoogleFonts.manrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.description.isNotEmpty
                          ? provider.description
                          : 'Providing quality, reliable residential services across Nigeria.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: AppColors.navy,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'LOCATION & COVERAGE',
                      style: GoogleFonts.manrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.ivory,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.map_outlined, color: AppColors.slate, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Serving ${provider.city ?? "Lagos"} and surrounding areas in ${provider.state ?? "Nigeria"}',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Back to search'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onEnquire(provider);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Send enquiry'),
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
            ],
          ),
        ),
      ),
    );
  }
}
