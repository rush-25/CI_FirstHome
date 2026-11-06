import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class Footer extends StatelessWidget {
  final Function(String route)? onNavigate;

  const Footer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 950;
        final paddingH = isNarrow ? 16.0 : 32.0;

        return Container(
          color: AppColors.primaryDark,
          padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                children: [
                  if (isNarrow)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandSection(),
                        const SizedBox(height: 28),
                        _buildDiscoverSection(),
                        const SizedBox(height: 24),
                        _buildTrustSection(),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildBrandSection()),
                        const SizedBox(width: 40),
                        Expanded(flex: 3, child: _buildDiscoverSection()),
                        const SizedBox(width: 32),
                        Expanded(flex: 4, child: _buildTrustSection()),
                      ],
                    ),
                  const SizedBox(height: 36),
                  const Divider(color: Color(0xFF285644)),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: const [
                        Text(
                          '© 2026 FirstHome Nigeria. All rights reserved.',
                          style: TextStyle(
                            color: Color(0xFF8DA396),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Connecting homeowners with trusted local professionals.',
                          style: TextStyle(
                            color: Color(0xFF8DA396),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home_work_rounded,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'FirstHome Nigeria',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Connecting Nigerian homeowners and tenants with verified, skilled local service professionals in Lagos, Abuja, Rivers, Kano, and nationwide.',
          style: TextStyle(color: Color(0xFFC0D2C8), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'Verified Home Services Network',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discover',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _FooterLink(
          label: 'Find Professionals',
          onTap: () => onNavigate?.call('directory'),
        ),
        _FooterLink(
          label: 'Become a Provider',
          onTap: () => onNavigate?.call('register-provider'),
        ),
        _FooterLink(
          label: 'Customer Registration',
          onTap: () => onNavigate?.call('register-customer'),
        ),
      ],
    );
  }

  Widget _buildTrustSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trust & Operations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _FooterLink(
          label: 'Admin Portal',
          onTap: () => onNavigate?.call('login'),
        ),
        _FooterLink(
          label: 'Trust & Safety',
          onTap: () => onNavigate?.call('home'),
        ),
        _FooterLink(
          label: 'Privacy & Consent',
          onTap: () => onNavigate?.call('home'),
        ),
        _FooterLink(
          label: 'API Reference',
          onTap: () => onNavigate?.call('home'),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFFC0D2C8), fontSize: 13),
        ),
      ),
    );
  }
}
