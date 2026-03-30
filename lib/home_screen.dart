import 'package:uje/constants/constants.dart';
import 'package:uje/proxy_vote.dart';
import 'package:uje/services.dart';
import 'package:uje/shareholder_vote_page.dart';
import 'package:flutter/material.dart';
import 'package:uje/Register_Screen.dart';
import 'package:flutter/services.dart';
import 'update_checker.dart';
import 'proxy_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final UpdateChecker _updateChecker = UpdateChecker();
  late AnimationController _animController;
  late AnimationController _pulseController;
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>> _cardSlides;
  late Animation<double> _headerFade;
  late Animation<double> _pulseAnim;

  // ── CRDB Brand Palette ──────────────────────────────────
  static const Color crdbGreen       = Color(0xFF3AAA35);   // Primary CRDB green
  static const Color crdbDarkGreen   = Color(0xFF1E7A1A);   // Deep forest green
  static const Color crdbMidGreen    = Color(0xFF2D9128);   // Mid-tone green
  static const Color crdbLightGreen  = Color(0xFF57C752);   // Highlight green
  static const Color crdbBackground  = Color(0xFFF2FAF2);   // Soft green-white
  static const Color crdbSurface     = Color(0xFFFFFFFF);   // Pure white
  static const Color crdbDivider     = Color(0xFFD4EDDA);   // Soft green divider
  static const Color crdbTextDark    = Color(0xFF0D2B0C);   // Near-black green text

  @override
  void initState() {
    super.initState();
    getBanks(context);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _cardFades = List.generate(4, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(
            0.3 + i * 0.1,
            0.7 + i * 0.1,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _cardSlides = List.generate(4, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(
            0.3 + i * 0.1,
            0.7 + i * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: crdbSurface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: crdbDarkGreen.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Color(0xFFD32F2F), size: 26),
              ),
              const SizedBox(height: 20),
              const Text(
                'Exit App',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: crdbDarkGreen,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to exit?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                            color: Colors.grey[300]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () =>
                          Future.delayed(const Duration(milliseconds: 300),
                                  () async {
                                await _updateChecker.checkForUpdates();
                                SystemChannels.platform
                                    .invokeMethod('SystemNavigator.pop');
                              }),
                      child: const Text('Exit',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (popped) => _onWillPop(),
      child: Scaffold(
        backgroundColor: crdbBackground,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Immersive Header ─────────────────────────
            SliverAppBar(
              expandedHeight: 260,
              floating: false,
              pinned: true,
              stretch: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: _HeaderBackground(
                  pulseAnim: _pulseAnim,
                  headerFade: _headerFade,
                ),
              ),
              title: FadeTransition(
                opacity: _headerFade,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.PNG',
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'CRDB BANK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: crdbDarkGreen,
            ),

            // ── Welcome Banner ───────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [crdbDarkGreen, crdbMidGreen],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: crdbDarkGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Welcome to AGM Portal',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5)),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Service Grid ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // — Shareholder Section —
                    _SectionHeader(
                      label: 'SHAREHOLDER SERVICES',
                      icon: Icons.people_alt_rounded,
                      color: crdbDarkGreen,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FadeTransition(
                            opacity: _cardFades[0],
                            child: SlideTransition(
                              position: _cardSlides[0],
                              child: _ServiceCard(
                                icon: Icons.how_to_reg_rounded,
                                label: 'Shareholder\nRegistration',
                                description: 'Register as a member',
                                accentColor: crdbDarkGreen,
                                gradientColors: const [
                                  Color(0xFF1E7A1A),
                                  Color(0xFF2D9128),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  _pageRoute(const RegisterScreen()),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: FadeTransition(
                            opacity: _cardFades[1],
                            child: SlideTransition(
                              position: _cardSlides[1],
                              child: _ServiceCard(
                                icon: Icons.how_to_vote_rounded,
                                label: 'Shareholder\nVoting',
                                description: 'Cast your vote',
                                accentColor: crdbDarkGreen,
                                gradientColors: const [
                                  Color(0xFF2D9128),
                                  Color(0xFF3AAA35),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  _pageRoute(const ShareholderVotePage()),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // — Proxy Section —
                    _SectionHeader(
                      label: 'PROXY SERVICES',
                      icon: Icons.manage_accounts_rounded,
                      color: crdbMidGreen,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FadeTransition(
                            opacity: _cardFades[2],
                            child: SlideTransition(
                              position: _cardSlides[2],
                              child: _ServiceCard(
                                icon: Icons.person_add_alt_1_rounded,
                                label: 'Proxy\nRegistration',
                                description: 'Add a proxy member',
                                accentColor: crdbMidGreen,
                                gradientColors: const [
                                  Color(0xFF3AAA35),
                                  Color(0xFF57C752),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  _pageRoute(ProxyPage()),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: FadeTransition(
                            opacity: _cardFades[3],
                            child: SlideTransition(
                              position: _cardSlides[3],
                              child: _ServiceCard(
                                icon: Icons.ballot_rounded,
                                label: 'Proxy\nVoting',
                                description: 'Vote on behalf',
                                accentColor: crdbMidGreen,
                                gradientColors: const [
                                  Color(0xFF57C752),
                                  Color(0xFF7DD978),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  _pageRoute(ProxyVotePage()),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // — Footer —
                    Divider(color: crdbDivider, thickness: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copyright_rounded,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          '${DateTime.now().year} CRDB Bank Plc',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'The bank that listens',
                        style: TextStyle(
                          fontSize: 10,
                          color: crdbGreen.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PageRouteBuilder _pageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

// ── Decorative Header Background ─────────────────────────
class _HeaderBackground extends StatelessWidget {
  final Animation<double> pulseAnim;
  final Animation<double> headerFade;

  const _HeaderBackground({
    required this.pulseAnim,
    required this.headerFade,
  });

  // CRDB colors referenced locally
  static const Color crdbDarkGreen  = Color(0xFF1E7A1A);
  static const Color crdbGreen      = Color(0xFF3AAA35);
  static const Color crdbLightGreen = Color(0xFF57C752);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D4A0A),   // Very dark green
            Color(0xFF1E7A1A),   // Dark CRDB green
            Color(0xFF3AAA35),   // Primary CRDB green
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative pulsing ring — white tint
          Positioned(
            top: -40,
            right: -40,
            child: AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, __) => Opacity(
                opacity: 0.07,
                child: Transform.scale(
                  scale: pulseAnim.value,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Soft glow blob top-right
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, __) => Opacity(
                opacity: 0.09,
                child: Transform.scale(
                  scale: 1.1 - (pulseAnim.value - 0.85) * 0.3,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom-left soft circle
          Positioned(
            bottom: -20,
            left: -30,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // CRDB green stripe accent at bottom — replaces gold line
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Three horizontal stripes (CRDB brand mark motif) — bottom right
          Positioned(
            bottom: 30,
            right: 20,
            child: Opacity(
              opacity: 0.12,
              child: Column(
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Container(
                    width: 40 - i * 6.0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),
          ),
          // Logo & text
          SafeArea(
            child: FadeTransition(
              opacity: headerFade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo with animated ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: pulseAnim,
                        builder: (_, __) => Opacity(
                          opacity: (pulseAnim.value - 0.85) * 2,
                          child: Container(
                            width: 98,
                            height: 98,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                        child: Image.asset(
                          'assets/images/logo.PNG',
                          width: 140,
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CRDB BANK PLC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 1,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'The bank that listens',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 1,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.4), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Service Card ──────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color accentColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.accentColor,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 148,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _pressed
                ? []
                : [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Gradient background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.gradientColors,
                      ),
                    ),
                  ),
                ),
                // Subtle circle overlay top-right
                Positioned(
                  top: -20,
                  right: -20,
                  child: Opacity(
                    opacity: 0.08,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Subtle circle overlay bottom-left
                Positioned(
                  bottom: -30,
                  left: -15,
                  child: Opacity(
                    opacity: 0.05,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // CRDB stripe motif — bottom right corner
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Opacity(
                    opacity: 0.15,
                    child: Column(
                      children: List.generate(3, (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Container(
                          width: 20 - i * 4.0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      )),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon in frosted rounded square
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.28),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            widget.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.70),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 13,
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
      ),
    );
  }
}