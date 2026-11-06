import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/navbar.dart';
import '../../widgets/footer.dart';

const String _aboutHeroImg =
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=85&w=1600';

class AboutScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const AboutScreen({super.key, required this.onNavigate});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 82),
                _buildHero(isMobile),
                _buildMetricsStrip(isMobile),
                _buildMissionStory(isMobile),
                _buildPillars(isMobile),
                _buildCoverageSection(isMobile),
                _buildCta(isMobile),
                Footer(onNavigate: widget.onNavigate),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Navbar(onNavigate: widget.onNavigate),
          ),
        ],
      ),
    );
  }

  // 1. Hero
  Widget _buildHero(bool isMobile) {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _aboutHeroImg,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(color: AppColors.navy),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A1420).withValues(alpha: 0.70),
                    const Color(0xFF0A1420).withValues(alpha: 0.94),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 48,
              vertical: isMobile ? 60 : 100,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 14, height: 2, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Text(
                          'OUR MISSION & PURPOSE',
                          style: GoogleFonts.manrope(
                            color: AppColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: isMobile ? 36 : 56,
                          color: Colors.white,
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                        children: [
                          const TextSpan(text: 'Building trust into every\n'),
                          TextSpan(
                            text: 'Nigerian home.',
                            style: GoogleFonts.dmSerifDisplay(
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFF0EAE1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Text(
                        'FirstHome Nigeria solves the trust deficit in residential and commercial services by uniting verified artisans with homeowners through structured, auditable matching.',
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          color: const Color(0xFFC8D1D9),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Metrics Strip
  Widget _buildMetricsStrip(bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth < 650 ? 2 : 4;

              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: cols == 2 ? 1.8 : 2.0,
                children: [
                  _buildMetricItem('10+', 'Nigerian States', 'Lagos, Abuja, Rivers, Kano & more'),
                  _buildMetricItem('9+', 'Trade Categories', 'Plumbing, Electrical, HVAC, Carpentry...'),
                  _buildMetricItem('100%', 'Verified Pipeline', 'Rigorous identity & trade vetting'),
                  _buildMetricItem('Real-Time', 'Audit Trails', 'Immutable status transition logs'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String val, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          val,
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.slate,
          ),
        ),
      ],
    );
  }

  // 3. Mission Story
  Widget _buildMissionStory(bool isMobile) {
    return Container(
      width: double.infinity,
      color: AppColors.ivory,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 50 : 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoryLeft(),
                    const SizedBox(height: 36),
                    _buildStoryRight(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildStoryLeft()),
                    const SizedBox(width: 60),
                    Expanded(flex: 6, child: _buildStoryRight()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStoryLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 2, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              'THE NIGERIAN CONTEXT',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Solving the informal market disconnect.',
          style: GoogleFonts.manrope(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
            letterSpacing: -0.5,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'For decades, homeowners in Lagos, Abuja, Port Harcourt, and across the federation have relied on informal referrals to find plumbers, electricians, carpenters, and technicians.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.slate,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This opaque system left homeowners exposed to abandoned projects, substandard work, and unpredictable billing, while genuine, skilled artisans struggled for steady visibility.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.slate,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildStoryRight() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The FirstHome Standard',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We architected FirstHome to bring structured certainty to home care. By validating providers before listing and recording every job under a unique tracking code (FH-YYYY-XXXX), we ensure total auditability.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.slate,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.shield_outlined, color: AppColors.success, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accountability Guaranteed',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.navy,
                      ),
                    ),
                    Text(
                      'Direct verification, transparent milestones, and zero platform interference.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Pillars
  Widget _buildPillars(bool isMobile) {
    final pillars = [
      (
        'Radical Transparency',
        'No hidden costs, no anonymous providers. All provider details, verification statuses, and project milestones are recorded in immutable logs.',
        Icons.visibility_outlined,
      ),
      (
        'Quality Artisanship',
        'We actively celebrate and elevate skilled Nigerian craftsmanship, giving honest technicians the respect and visibility they deserve.',
        Icons.verified_outlined,
      ),
      (
        'Localized Expertise',
        'Designed specifically for Nigerian metropolitan realities — power fluctuations, municipal zoning, borehole plumbing, and tropical HVAC demands.',
        Icons.location_city_outlined,
      ),
      (
        'Customer Protection',
        'From enquiry submission to completion confirmation, our structured lead workflow ensures homeowners never feel stranded.',
        Icons.security_outlined,
      ),
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 50 : 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 14, height: 2, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    'OUR GUIDING VALUES',
                    style: GoogleFonts.manrope(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Built on values that matter to homeowners.',
                style: GoogleFonts.manrope(
                  fontSize: isMobile ? 26 : 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 36),

              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth < 650 ? 1 : (constraints.maxWidth < 1000 ? 2 : 4);

                  return GridView.builder(
                    itemCount: pillars.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: cols == 1 ? 2.5 : 1.1,
                    ),
                    itemBuilder: (context, i) {
                      final p = pillars[i];
                      return Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.ivory,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(p.$3, size: 26, color: AppColors.gold),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.$1,
                                  style: GoogleFonts.manrope(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p.$2,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: AppColors.slate,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Coverage Section
  Widget _buildCoverageSection(bool isMobile) {
    final hubs = [
      ('Lagos State', 'Ikeja, Lekki, Victoria Island, Yaba, Ikoyi, Surulere'),
      ('Abuja (FCT)', 'Wuse, Garki, Maitama, Asokoro, Gwarinpa, Jabi'),
      ('Rivers State', 'Port Harcourt, Obio-Akpor, Eleme, Bonny'),
      ('Kano State', 'Nasarawa, Fagge, Dala, Kano Municipal'),
      ('Oyo State', 'Ibadan, Ogbomosho, Oyo'),
      ('Enugu State', 'Independence Layout, GRA, New Haven, Trans-Ekulu'),
    ];

    return Container(
      width: double.infinity,
      color: AppColors.ivory,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 50 : 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 14, height: 2, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    'REGIONAL COVERAGE',
                    style: GoogleFonts.manrope(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Serving major hubs across the nation.',
                style: GoogleFonts.manrope(
                  fontSize: isMobile ? 26 : 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),

              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth < 700 ? 1 : (constraints.maxWidth < 1000 ? 2 : 3);

                  return GridView.builder(
                    itemCount: hubs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: cols == 1 ? 3.0 : 2.0,
                    ),
                    itemBuilder: (context, i) {
                      final h = hubs[i];
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.gold),
                                const SizedBox(width: 6),
                                Text(
                                  h.$1,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              h.$2,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.slate,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 6. Bottom CTA
  Widget _buildCta(bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF142436),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 70,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to experience the new standard?',
                      style: GoogleFonts.manrope(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connect with vetted professionals or apply to join Nigeria’s premier artisan network.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFFC8D1D9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () => widget.onNavigate('directory'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.navy,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Browse providers',
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 15),
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

