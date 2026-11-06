import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import 'brand_logo.dart';

class Footer extends StatelessWidget {
  final Function(String route)? onNavigate;

  const Footer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Container(
          color: const Color(0xFF0B1521), // Deepest dark midnight
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 48,
            vertical: isMobile ? 48 : 72,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                children: [
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandCol(),
                        const SizedBox(height: 36),
                        _buildLinksCol('Explore', [
                          ('Find Providers', () => onNavigate?.call('directory')),
                          ('Become a Provider', () => onNavigate?.call('register-provider')),
                          ('How It Works', () => onNavigate?.call('home')),
                        ]),
                        const SizedBox(height: 28),
                        _buildLinksCol('Company', [
                          ('About FirstHome', () => onNavigate?.call('home')),
                          ('Contact', () {}),
                          ('Careers', () {}),
                        ]),
                        const SizedBox(height: 28),
                        _buildLinksCol('Legal', [
                          ('Privacy Policy', () {}),
                          ('Terms of Service', () {}),
                          ('Accessibility', () {}),
                        ]),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildBrandCol()),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 2,
                          child: _buildLinksCol('Explore', [
                            ('Find Providers', () => onNavigate?.call('directory')),
                            ('Become a Provider', () => onNavigate?.call('register-provider')),
                            ('How It Works', () => onNavigate?.call('home')),
                          ]),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildLinksCol('Company', [
                            ('About FirstHome', () => onNavigate?.call('home')),
                            ('Contact', () {}),
                            ('Careers', () {}),
                          ]),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildLinksCol('Legal', [
                            ('Privacy Policy', () {}),
                            ('Terms of Service', () {}),
                            ('Accessibility', () {}),
                          ]),
                        ),
                      ],
                    ),
                  const SizedBox(height: 48),
                  const Divider(color: Color(0xFF1E2A38)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '© 2026 FirstHome Nigeria',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8F9AA5),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'Your home journey, simplified.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8F9AA5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrandLogo(
          light: true,
          scale: 1.05,
          onTap: () => onNavigate?.call('home'),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            'A trusted way to find housing and professional service providers across Nigeria.',
            style: GoogleFonts.inter(
              color: const Color(0xFF8F9AA5),
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinksCol(String title, List<(String, VoidCallback)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: item.$2,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                item.$1,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF8F9AA5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
