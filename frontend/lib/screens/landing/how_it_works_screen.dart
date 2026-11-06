import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/navbar.dart';
import '../../widgets/footer.dart';

class HowItWorksScreen extends StatefulWidget {
  final Function(String route, {dynamic args}) onNavigate;

  const HowItWorksScreen({super.key, required this.onNavigate});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  // 0 = For Homeowners, 1 = For Service Providers
  int _activeTab = 0;

  // FAQ expanded tracking
  final Set<int> _expandedFaqs = {0};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Navbar(onNavigate: widget.onNavigate),
            _buildHero(isMobile),
            _buildPathwaySelector(isMobile),
            if (_activeTab == 0)
              _buildHomeownerPathway(isMobile)
            else
              _buildProviderPathway(isMobile),
            _buildTrustStandards(isMobile),
            _buildFaqSection(isMobile),
            _buildCta(isMobile),
            Footer(onNavigate: widget.onNavigate),
          ],
        ),
      ),
    );
  }

  // 1. Hero Section
  Widget _buildHero(bool isMobile) {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 55 : 85,
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
                    'TRANSPARENT & VERIFIED PROCESS',
                    style: GoogleFonts.manrope(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.manrope(
                    fontSize: isMobile ? 32 : 50,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                  children: [
                    const TextSpan(text: 'How FirstHome works for '),
                    TextSpan(
                      text: 'you.',
                      style: GoogleFonts.dmSerifDisplay(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFF2ECE1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'Bridging trust between Nigerian homeowners and certified local artisans. Simple, structured, and auditable from enquiry to completion.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFFAEB8C2),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Pathway Selector (Homeowners vs Providers)
  Widget _buildPathwaySelector(bool isMobile) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.ivory,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 0),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? AppColors.navy : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_outlined,
                            size: 17,
                            color: _activeTab == 0 ? Colors.white : AppColors.slate,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'For Homeowners',
                            style: GoogleFonts.manrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _activeTab == 0 ? Colors.white : AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 1),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? AppColors.navy : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 17,
                            color: _activeTab == 1 ? Colors.white : AppColors.slate,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'For Service Providers',
                            style: GoogleFonts.manrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _activeTab == 1 ? Colors.white : AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 3A. Homeowner Steps
  Widget _buildHomeownerPathway(bool isMobile) {
    final steps = [
      (
        '01',
        'Explore Verified Experts',
        'Browse our curated directory of certified Nigerian technicians by state, city, and specialty (Plumbing, Electrical, HVAC, Carpentry, Painting, etc.). View portfolios, coverage, and verification status.',
        Icons.search_rounded,
      ),
      (
        '02',
        'Create a Structured Request',
        'Submit your project details or service enquiry with clear scope and timing. You receive a unique tracking reference code (e.g. FH-2026-XXXX) for end-to-end auditability.',
        Icons.assignment_outlined,
      ),
      (
        '03',
        'Direct Match & Transparent Communication',
        'Connect directly with vetted local providers. Discuss work details, confirm site visits, and negotiate quotes with confidence without anonymous intermediaries.',
        Icons.chat_bubble_outline,
      ),
      (
        '04',
        'Track Progress & Confirm Quality',
        'Follow your job from "New" to "Contacted", "Qualified", and "Closed" in your Customer Dashboard. Benefit from verified artisan standards and dedicated human support.',
        Icons.verified_outlined,
      ),
    ];

    return _buildStepsContainer(
      eyebrow: 'YOUR HOME JOURNEY',
      title: 'Four thoughtful steps to a solved problem.',
      subtitle: 'From a burst pipe in Lekki to whole-house rewiring in Maitama, FirstHome simplifies every step of hiring trustworthy local help.',
      steps: steps,
      isMobile: isMobile,
      buttonLabel: 'Find a provider now',
      onButtonClick: () => widget.onNavigate('directory'),
    );
  }

  // 3B. Provider Steps
  Widget _buildProviderPathway(bool isMobile) {
    final steps = [
      (
        '01',
        'Register Your Business',
        'Create your provider profile with business name, trade specialty, cities served, and contact channels. Free to sign up and configure.',
        Icons.app_registration_rounded,
      ),
      (
        '02',
        'Verification & Trust Badge',
        'Our operations team reviews provider credentials and trade history. Earn the Verified Shield badge that builds instant customer credibility.',
        Icons.shield_outlined,
      ),
      (
        '03',
        'Receive Qualified Local Leads',
        'Get connected directly with genuine homeowners and tenants looking for your exact skills in your coverage area.',
        Icons.mark_email_read_outlined,
      ),
      (
        '04',
        'Build Reputation & Grow',
        'Update lead milestones, deliver quality craftsmanship, and expand your residential or commercial client base with zero predatory commissions.',
        Icons.trending_up_rounded,
      ),
    ];

    return _buildStepsContainer(
      eyebrow: 'GROW YOUR BUSINESS',
      title: 'A trusted acquisition platform for quality artisans.',
      subtitle: 'Stand out from informal markets. Join verified professionals building real sustainable businesses across Nigeria.',
      steps: steps,
      isMobile: isMobile,
      buttonLabel: 'Become a verified provider',
      onButtonClick: () => widget.onNavigate('register-provider'),
    );
  }

  Widget _buildStepsContainer({
    required String eyebrow,
    required String title,
    required String subtitle,
    required List<(String, String, String, IconData)> steps,
    required bool isMobile,
    required String buttonLabel,
    required VoidCallback onButtonClick,
  }) {
    return Container(
      width: double.infinity,
      color: AppColors.ivory,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
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
                    eyebrow,
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
                title,
                style: GoogleFonts.manrope(
                  fontSize: isMobile ? 26 : 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.slate,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Steps Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth < 650 ? 1 : (constraints.maxWidth < 1050 ? 2 : 4);

                  return GridView.builder(
                    itemCount: steps.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: cols == 1 ? 2.1 : (cols == 2 ? 1.4 : 0.95),
                    ),
                    itemBuilder: (context, i) {
                      final s = steps[i];
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.navy.withValues(alpha: 0.02),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  s.$1,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.gold,
                                  ),
                                ),
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.ivory,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Center(
                                    child: Icon(s.$4, color: AppColors.navy, size: 20),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.$2,
                                  style: GoogleFonts.manrope(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.$3,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: AppColors.slate,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 2,
                              width: 32,
                              color: AppColors.gold.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: onButtonClick,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonLabel,
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Trust & Verification Standards
  Widget _buildTrustStandards(bool isMobile) {
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
                    'OUR VETTING STANDARD',
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
                'What does "Verified" mean on FirstHome?',
                style: GoogleFonts.manrope(
                  fontSize: isMobile ? 26 : 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We never compromise on accountability. Here is how our three-tier review pipeline operates:',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate),
              ),
              const SizedBox(height: 36),

              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth < 750 ? 1 : 3;

                  return GridView.count(
                    crossAxisCount: cols,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 20,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: cols == 1 ? 2.5 : 1.3,
                    children: [
                      _buildStandardCard(
                        '1. Identity & Business Checks',
                        'Verification of business legitimacy, registered contacts, physical trade location, and direct representative identity.',
                        Icons.fingerprint_rounded,
                      ),
                      _buildStandardCard(
                        '2. Trade Track Record',
                        'Hands-on portfolio evaluation, quality checks of past residential deliverables, and customer reference endorsements.',
                        Icons.handyman_outlined,
                      ),
                      _buildStandardCard(
                        '3. Service Level Agreement',
                        'Commitment to honest diagnostic assessments, upfront transparent quotes, and professional code of conduct.',
                        Icons.handshake_outlined,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.gold),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.slate,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // 5. FAQ Section
  Widget _buildFaqSection(bool isMobile) {
    final faqs = [
      (
        'Is FirstHome free to use for homeowners?',
        'Yes, completely free. Homeowners can search the directory, compare providers, and create structured enquiries with tracking codes at zero cost.',
      ),
      (
        'How are providers on the platform vetted?',
        'Providers undergo a verification audit assessing identity, business registration, service history, and past customer references before receiving the Verified badge.',
      ),
      (
        'Which Nigerian locations are currently covered?',
        'We currently serve major metropolitan areas in Lagos, Abuja FCT, Rivers (Port Harcourt), Kano, Oyo (Ibadan), Enugu, Akwa Ibom, Delta, Kaduna, and Ogun states.',
      ),
      (
        'How do payments and quotes work?',
        'FirstHome facilitates direct transparent matchmaking. You discuss pricing and scope directly with the verified artisan with no hidden markups or surprise fees.',
      ),
      (
        'What should I do if an issue arises with a job?',
        'Every enquiry produces an immutable audit reference number (e.g. FH-2026-XXXX). You can submit dispute tickets or contact our human support team directly.',
      ),
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
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 14, height: 2, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    'FREQUENTLY ASKED QUESTIONS',
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
                'Everything you need to know.',
                style: GoogleFonts.manrope(
                  fontSize: isMobile ? 26 : 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),

              ...List.generate(faqs.length, (i) {
                final isExpanded = _expandedFaqs.contains(i);
                final item = faqs[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: isExpanded,
                    shape: const Border(),
                    title: Text(
                      item.$1,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                        child: Text(
                          item.$2,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.slate,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // 6. Bottom Call to Action
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
                      'Ready to experience reliable service?',
                      style: GoogleFonts.manrope(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Join thousands of Nigerian homeowners building with clarity and confidence.',
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
                      'Find a provider',
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

