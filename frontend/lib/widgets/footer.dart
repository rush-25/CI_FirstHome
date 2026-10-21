import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class Footer extends StatelessWidget {
  final Function(String route)? onNavigate;

  const Footer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;

              return Column(
                children: [
                  if (isNarrow)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Col 1: Brand
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.gold,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.home_work_rounded, color: AppColors.primaryDark, size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'FirstHome Nigeria',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Connecting Nigerian homeowners and tenants with verified, skilled local service professionals in Lagos, Abuja, Rivers, Kano, and nationwide.',
                              style: TextStyle(color: Color(0xFFC0D2C8), fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Col 2: Discover
                        const Text(
                          'Discover',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _FooterLink(label: 'Find Professionals', onTap: () => onNavigate?.call('directory')),
                        _FooterLink(label: 'Become a Provider', onTap: () => onNavigate?.call('register-provider')),
                        _FooterLink(label: 'Customer Registration', onTap: () => onNavigate?.call('register-customer')),
                        const SizedBox(height: 24),
                        // Col 3: Trust
                        const Text(
                          'Trust & Operations',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _FooterLink(label: 'Admin Portal (Demo)', onTap: () => onNavigate?.call('login')),
                        _FooterLink(label: 'Mock Verification Architecture', onTap: () => onNavigate?.call('home')),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Col 1: Brand
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.gold,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.home_work_rounded, color: AppColors.primaryDark, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'FirstHome Nigeria',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Connecting Nigerian homeowners and tenants with verified, skilled local service professionals in Lagos, Abuja, Rivers, Kano, and nationwide.',
                                style: TextStyle(color: Color(0xFFC0D2C8), fontSize: 13, height: 1.5),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                                ),
                                child: const Text(
                                  'Prototype preview • Stage 1 Architecture Candidate',
                                  style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Col 2: Quick Links
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Discover',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              _FooterLink(label: 'Find Professionals', onTap: () => onNavigate?.call('directory')),
                              _FooterLink(label: 'Become a Provider', onTap: () => onNavigate?.call('register-provider')),
                              _FooterLink(label: 'Customer Registration', onTap: () => onNavigate?.call('register-customer')),
                            ],
                          ),
                        ),
                        // Col 3: Operations & Trust
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trust & Operations',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              _FooterLink(label: 'Admin Portal (Demo)', onTap: () => onNavigate?.call('login')),
                              _FooterLink(label: 'Mock Verification Architecture', onTap: () => onNavigate?.call('home')),
                              _FooterLink(label: 'Privacy & Consent', onTap: () => onNavigate?.call('home')),
                              _FooterLink(label: 'API Swagger Reference', onTap: () => onNavigate?.call('home')),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFF285644)),
                  const SizedBox(height: 16),

                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: const [
                      Text(
                        '© 2026 FirstHome Nigeria. Built for Ceylon Innovation Technical Evaluation.',
                        style: TextStyle(color: Color(0xFF8DA396), fontSize: 12),
                      ),
                      Text(
                        'Confidential • Candidate Submission Copy',
                        style: TextStyle(color: Color(0xFF8DA396), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
