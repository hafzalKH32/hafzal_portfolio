import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hafzal K H — Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7EEB5A),
          primary: const Color(0xFF7EEB5A),
          secondary: const Color(0xFF3DB81A),
          surface: const Color(0xFFF5F5F0),
          brightness: Brightness.light,
        ),
        fontFamily: 'DM Sans',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F0),
      ),
      home: const PortfolioPage(),
    );
  }
}

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // For experience line animation
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // Add scroll listener for experience line animation
    _scrollController.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients && _experienceKey.currentContext != null) {
      final RenderBox renderBox = _experienceKey.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero).dy;
      final screenHeight = MediaQuery.of(context).size.height;
      final progress = (screenHeight - position) / screenHeight;
      setState(() {
        _scrollProgress = progress.clamp(0.0, 1.0);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeroSection(),
                const AnimatedTechStrip(),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AboutSection(key: _aboutKey),
                ),
                const ProcessSection(),
                ExperienceSection(expkey: _experienceKey, scrollProgress: _scrollProgress),
                ProjectsSection(key: _projectsKey),
                const AchievementsSection(),
                const EducationSection(),
                ContactSection(key: _contactKey),
                const FooterSection(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NavBar(
              onAboutTap: () => _scrollToSection(_aboutKey),
              onExperienceTap: () => _scrollToSection(_experienceKey),
              onProjectsTap: () => _scrollToSection(_projectsKey),
              onContactTap: () => _scrollToSection(_contactKey),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBar extends StatelessWidget {
  final VoidCallback onAboutTap;
  final VoidCallback onExperienceTap;
  final VoidCallback onProjectsTap;
  final VoidCallback onContactTap;

  const NavBar({
    super.key,
    required this.onAboutTap,
    required this.onExperienceTap,
    required this.onProjectsTap,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F0).withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hafzal K H',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.01,
                  color: Color(0xFF0E0E0E),
                ),
              ),
              if (!isMobile)
                Row(
                  children: [
                    _NavLink('About', onAboutTap),
                    const SizedBox(width: 36),
                    _NavLink('Experience', onExperienceTap),
                    const SizedBox(width: 36),
                    _NavLink('Projects', onProjectsTap),
                    const SizedBox(width: 36),
                    _NavLink('Contact', onContactTap),
                  ],
                ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E0E),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final Uri emailUri = Uri(scheme: 'mailto', path: 'khhafsal32@gmail.com');
                      launchUrl(emailUri);
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Text(
                        '→ Get In Touch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.04,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _NavLink(this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.06,
          color: Color(0xFF888888),
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4FBB2),
            Color(0xFFA8F075),
            Color(0xFFE8FDD8),
            Color(0xFFF5F5F0),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return Stack(
            children: [
              if (!isMobile)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.6,
                        center: Alignment(0.3, 0.4),
                        colors: [Color(0x597EEB5A), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80, bottom: 40),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 24 : 48,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const _HeroBadge(),
                                  const SizedBox(height: 24),
                                  Text(
                                    "Hi, I'm Hafzal",
                                    style: TextStyle(
                                      fontFamily: 'Cormorant Garamond',
                                      fontSize: isMobile ? 48 : 72,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                      letterSpacing: -0.02,
                                      color: const Color(0xFF0E0E0E),
                                    ),
                                  ),
                                  Text(
                                    'Flutter Developer',
                                    style: TextStyle(
                                      fontFamily: 'Cormorant Garamond',
                                      fontSize: isMobile ? 44 : 68,
                                      fontWeight: FontWeight.w400,
                                      height: 1.1,
                                      color: const Color(0xFF2A7A10),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: isMobile ? double.infinity : 500,
                                    ),
                                    child: const Text(
                                      'Passionate about crafting pixel-perfect, cross-platform apps that connect users with value — from mobile to web, Android to iOS.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: Color(0xFF444444),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      _AnimatedButton(
                                        onTap: () {},
                                        isDark: true,
                                        text: 'View My Work →',
                                      ),
                                      _AnimatedButton(
                                        onTap: () {},
                                        isDark: false,
                                        text: "Let's Talk",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isMobile)
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 48),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _AnimatedProfileCard(),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;
  final String text;

  const _AnimatedButton({
    required this.onTap,
    required this.isDark,
    required this.text,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF0E0E0E) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: widget.isDark ? null : Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1.5),
            boxShadow: widget.isDark
                ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: widget.isDark ? 14 : 13),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF0E0E0E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.04,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedProfileCard extends StatefulWidget {
  const _AnimatedProfileCard();

  @override
  State<_AnimatedProfileCard> createState() => _AnimatedProfileCardState();
}

class _AnimatedProfileCardState extends State<_AnimatedProfileCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC8F59A), Color(0xFF7BDB45)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/my_pic.jpeg', // Replace with your image path
                  width: 240,
                  height: 240,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white70,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Hafzal K H',
                            style: TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _HeroBadge extends StatelessWidget {
  const _HeroBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF2A7A10),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2A7A10).withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Available for new opportunities',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2A7A10)),
          ),
        ],
      ),
    );
  }
}

class AnimatedTechStrip extends StatefulWidget {
  const AnimatedTechStrip({super.key});

  @override
  State<AnimatedTechStrip> createState() => _AnimatedTechStripState();
}

class _AnimatedTechStripState extends State<AnimatedTechStrip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;
  final List<String> items = [
    'Flutter', 'Dart', 'BLoC', 'GetX', 'Firebase', 'gRPC', 'REST APIs', 'Figma',
    'Android', 'iOS', 'Web', 'Git', 'Agile',
  ];
  late int itemCount;

  @override
  void initState() {
    super.initState();
    itemCount = items.length * 3; // Triple the items for seamless looping
    _scrollController = ScrollController();
    _controller = AnimationController(
      duration: const Duration(seconds: 30), // Slower for smoother movement
      vsync: this,
    );

    // Add listener to reset position when reaching the end
    _controller.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _controller.value * maxScroll;

        if (currentScroll >= maxScroll) {
          // Reset animation when reaching the end
          _controller.value = 0.0;
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentScroll);
        }
      }
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E0E0E),
      height: 60,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                controller: _scrollController,
                child: Row(
                  children: List.generate(itemCount, (index) {
                    final item = items[index % items.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          const Text(
                            '◆',
                            style: TextStyle(color: Color(0xFF7EEB5A), fontSize: 8),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item,
                            style: const TextStyle(
                              fontFamily: 'Space Mono',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                              letterSpacing: 0.12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('About Me'),
              const SizedBox(height: 20),
              if (isMobile)
                const Column(
                  children: [
                    _AboutLeftColumn(),
                    SizedBox(height: 60),
                    _SkillsGrid(),
                  ],
                )
              else
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _AboutLeftColumn()),
                    SizedBox(width: 60),
                    Expanded(child: _SkillsGrid()),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AboutLeftColumn extends StatelessWidget {
  const _AboutLeftColumn();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Focus is on blending clean architecture with pixel-perfect craft',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontSize: 60,
            fontWeight: FontWeight.w600,
            height: 1.1,
            letterSpacing: -0.02,
            color: Color(0xFF0E0E0E),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'I\'m a Flutter Developer with 2+ years of hands-on experience building high-performance, cross-platform mobile and web apps using Flutter and Dart.\n\n'
              'I specialize in rapid MVP development, seamless API integrations, and clean architecture — delivering production-ready applications that scale. From fintech to sports to SaaS, I\'ve shipped real products used by real users.',
          style: TextStyle(fontSize: 16, height: 1.8, color: Color(0xFF555555)),
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Chip(text: 'Flutter & Dart', isGreen: true),
            _Chip(text: 'BLoC / GetX', isGreen: false),
            _Chip(text: 'Firebase', isGreen: false),
            _Chip(text: 'gRPC', isGreen: false),
            _Chip(text: 'Figma', isGreen: false),
            _Chip(text: 'Clean Architecture', isGreen: false, isOutline: true),
            _Chip(text: 'Agile / MVP', isGreen: false, isOutline: true),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool isGreen;
  final bool isOutline;
  const _Chip({required this.text, this.isGreen = false, this.isOutline = false});

  @override
  Widget build(BuildContext context) {
    if (isOutline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 1.5),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0E0E0E))),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xFF7EEB5A) : const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isGreen ? const Color(0xFF0E0E0E) : Colors.white,
        ),
      ),
    );
  }
}

class _SkillsGrid extends StatelessWidget {
  const _SkillsGrid();
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _AnimatedSkillBox(icon: '📱', title: 'Cross-Platform', desc: 'Android, iOS, Web & Desktop from a single Dart codebase.', delay: 0),
        _AnimatedSkillBox(icon: '🎨', title: 'UI/UX Design', desc: 'Pixel-perfect layouts in Figma, implemented responsively.', delay: 100),
        _AnimatedSkillBox(icon: '⚡', title: 'Performance', desc: 'Optimized state management, reduced load times, seamless animations.', delay: 200),
        _AnimatedSkillBox(icon: '🔌', title: 'API Integration', desc: 'RESTful APIs, gRPC real-time sync, Firebase Cloud Firestore.', delay: 300),
      ],
    );
  }
}

class _AnimatedSkillBox extends StatefulWidget {
  final String icon;
  final String title;
  final String desc;
  final int delay;

  const _AnimatedSkillBox({
    required this.icon,
    required this.title,
    required this.desc,
    required this.delay,
  });

  @override
  State<_AnimatedSkillBox> createState() => _AnimatedSkillBoxState();
}

class _AnimatedSkillBoxState extends State<_AnimatedSkillBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered ? const Color(0xFF7EEB5A) : Colors.black.withValues(alpha: 0.06),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: const Color(0xFF7EEB5A).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 12),
                Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                Text(widget.desc, style: const TextStyle(fontSize: 12, color: Color(0xFF888888), height: 1.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProcessSection extends StatelessWidget {
  const ProcessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 100),
      color: Colors.white,
      child: Column(
        children: [
          const _SectionLabel('My Process', centered: true),
          const SizedBox(height: 20),
          const Text(
            "Here's how I work",
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 60,
              fontWeight: FontWeight.w600,
              height: 1.1,
              letterSpacing: -0.02,
              color: Color(0xFF0E0E0E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              if (isMobile) {
                return const Column(
                  children: [
                    _AnimatedProcessStep(num: '01', icon: '🔍', title: 'Discover', desc: 'Understanding goals, user problems, and technical constraints through deep research and clear strategy sessions.', delay: 0),
                    _AnimatedProcessStep(num: '02', icon: '🎨', title: 'Design', desc: 'Translating insights into intuitive, beautiful, and functional product experiences in Figma — reviewed before a single line of code.', delay: 200),
                    _AnimatedProcessStep(num: '03', icon: '🚀', title: 'Deliver', desc: 'Testing, refining, and launching the final product with clarity and precision — on time, every time.', delay: 400),
                  ],
                );
              }
              return const Row(
                children: [
                  Expanded(child: _AnimatedProcessStep(num: '01', icon: '🔍', title: 'Discover', desc: 'Understanding goals, user problems, and technical constraints through deep research and clear strategy sessions.', delay: 0)),
                  Expanded(child: _AnimatedProcessStep(num: '02', icon: '🎨', title: 'Design', desc: 'Translating insights into intuitive, beautiful, and functional product experiences in Figma — reviewed before a single line of code.', delay: 200)),
                  Expanded(child: _AnimatedProcessStep(num: '03', icon: '🚀', title: 'Deliver', desc: 'Testing, refining, and launching the final product with clarity and precision — on time, every time.', delay: 400)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnimatedProcessStep extends StatefulWidget {
  final String num;
  final String icon;
  final String title;
  final String desc;
  final int delay;

  const _AnimatedProcessStep({
    required this.num,
    required this.icon,
    required this.title,
    required this.desc,
    required this.delay,
  });

  @override
  State<_AnimatedProcessStep> createState() => _AnimatedProcessStepState();
}

class _AnimatedProcessStepState extends State<_AnimatedProcessStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered ? const Color(0xFF7EEB5A) : Colors.transparent,
                width: _isHovered ? 2 : 0,
              ),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: const Color(0xFF7EEB5A).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.num,
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                const SizedBox(height: 24),
                Text(widget.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 16),
                Text(widget.title, style: const TextStyle(fontFamily: 'Cormorant Garamond', fontSize: 26, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text(widget.desc, style: const TextStyle(fontSize: 14, color: Color(0xFF777777), height: 1.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExperienceSection extends StatefulWidget {
  final GlobalKey expkey;
  final double scrollProgress;

  const ExperienceSection({super.key, required this.expkey, required this.scrollProgress});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  final List<GlobalKey> _itemKeys = [];
  final List<_ExperienceData> _experiences = [];

  @override
  void initState() {
    super.initState();
    _experiences.addAll([
      _ExperienceData(
        period: 'Oct 2025 – Dec 2025',
        role: 'Flutter Developer',
        company: 'Vaavix Technologies Pvt. Ltd, Kozhikode',
        bullets: [
          'Lead developer for educational portals, SaaS platforms, and billing software',
          'Designed and implemented UI for e-commerce websites and educational portals',
          'Applied clean architecture across entire project codebase',
          'Used BLoC state management to enhance app performance and scalability',
        ],
      ),
      _ExperienceData(
        period: 'Oct 2023 – Oct 2025',
        role: 'Software Developer',
        company: 'Thoughtbox Online Services Pvt. Ltd, Ernakulam',
        bullets: [
          'Led development of scalable Flutter apps for Android, iOS, and Web platforms',
          'Integrated advanced gRPC for real-time data sync and secure communication',
          'Contributed to UI/UX decisions in Figma for production client apps',
          'Enhanced app performance by improving state management using BLoC and GetX',
          'Designed reusable custom widgets and UI components for faster team delivery',
          'Recognized for consistent delivery and mentorship of junior developers',
        ],
      ),
      _ExperienceData(
        period: 'Jul 2023 – Oct 2023',
        role: 'Junior Software Trainee',
        company: 'Thoughtbox Online Services Pvt. Ltd, Ernakulam',
        bullets: [
          'Hands-on training in Flutter development, Firebase integration, and UI/UX design',
          'Contributed to internal MVP builds and API testing projects',
          'Recognized for strong learning pace and early project contributions',
        ],
      ),
      _ExperienceData(
        period: 'Oct 2022',
        role: 'IoT Architecture Intern',
        company: 'Keltron, Kaloor, Kochi',
        bullets: [
          'Designed and implemented IoT systems with sensor integration',
          'Microcontroller programming on Raspberry Pi',
          'Built and deployed a mini IoT prototype as the final assessment project',
        ],
      ),
    ]);

    for (int i = 0; i < _experiences.length; i++) {
      _itemKeys.add(GlobalKey());
    }
  }

  int _getActiveIndex() {
    for (int i = 0; i < _itemKeys.length; i++) {
      final RenderBox? renderBox = _itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;
        final itemTop = position.dy;
        final itemBottom = itemTop + renderBox.size.height;

        // Item is in viewport
        if (itemTop < screenHeight * 0.6 && itemBottom > screenHeight * 0.3) {
          return i;
        }
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _getActiveIndex();

    return Container(
      key: widget.expkey,
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 100),
      color: const Color(0xFFF5F5F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Work History'),
          const SizedBox(height: 20),
          const Text(
            "Where I've Built Things",
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 60,
              fontWeight: FontWeight.w600,
              height: 1.1,
              letterSpacing: -0.02,
              color: Color(0xFF0E0E0E),
            ),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Static vertical line background
                  Positioned(
                    left: 15,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE0E0E0),
                    ),
                  ),
                  // Animated tracking line
                  Positioned(
                    left: 15,
                    top: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      width: 2,
                      height: _getLineHeight(activeIndex),
                      color: const Color(0xFF7EEB5A),
                    ),
                  ),
                  // Animated glowing dot that follows the line
                  Positioned(
                    left: 8,
                    top: _getDotPosition(activeIndex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7EEB5A),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7EEB5A).withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 760,
                    child: Column(
                      children: List.generate(_experiences.length, (index) {
                        return _LineTrackingExpItem(
                          key: _itemKeys[index],
                          period: _experiences[index].period,
                          role: _experiences[index].role,
                          company: _experiences[index].company,
                          bullets: _experiences[index].bullets,
                          delay: index * 200,
                          isActive: activeIndex == index,
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  double _getLineHeight(int activeIndex) {
    if (activeIndex < 0) return 0;

    double height = 0;
    for (int i = 0; i <= activeIndex; i++) {
      final RenderBox? renderBox = _itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final relativePosition = position.dy - _getSectionTop();
        height = relativePosition + renderBox.size.height / 2;
      }
    }
    return height;
  }

  double _getDotPosition(int activeIndex) {
    if (activeIndex < 0) return 0;

    final RenderBox? renderBox = _itemKeys[activeIndex].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final relativePosition = position.dy - _getSectionTop();
      return relativePosition + renderBox.size.height / 2 - 8;
    }
    return 0;
  }

  double _getSectionTop() {
    final RenderBox? sectionBox = widget.expkey.currentContext?.findRenderObject() as RenderBox?;
    if (sectionBox != null) {
      return sectionBox.localToGlobal(Offset.zero).dy;
    }
    return 0;
  }
}

class _ExperienceData {
  final String period;
  final String role;
  final String company;
  final List<String> bullets;

  _ExperienceData({
    required this.period,
    required this.role,
    required this.company,
    required this.bullets,
  });
}

class _LineTrackingExpItem extends StatefulWidget {
  final String period;
  final String role;
  final String company;
  final List<String> bullets;
  final int delay;
  final bool isActive;

  const _LineTrackingExpItem({
    super.key,
    required this.period,
    required this.role,
    required this.company,
    required this.bullets,
    required this.delay,
    required this.isActive,
  });

  @override
  State<_LineTrackingExpItem> createState() => _LineTrackingExpItemState();
}

class _LineTrackingExpItemState extends State<_LineTrackingExpItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            padding: const EdgeInsets.only(left: 40, bottom: 48),
            child: Stack(
              children: [
                Positioned(
                  left: -45,
                  top: 4,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: (widget.isActive || _isHovered) ? 14 : 12,
                    height: (widget.isActive || _isHovered) ? 14 : 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7EEB5A),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: (widget.isActive || _isHovered)
                          ? [
                        BoxShadow(
                          color: const Color(0xFF7EEB5A).withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: const Color(0xFF7EEB5A).withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.period,
                      style: TextStyle(
                        fontFamily: 'Space Mono',
                        fontSize: 11,
                        letterSpacing: 0.1,
                        color: widget.isActive ? const Color(0xFF7EEB5A) : const Color(0xFF3DB81A),
                        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.role,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: widget.isActive ? const Color(0xFF0E0E0E) : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.company,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isActive ? const Color(0xFF555555) : const Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.bullets.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                (_isHovered || widget.isActive) ? '→' : '·',
                                style: TextStyle(
                                  color: (_isHovered || widget.isActive)
                                      ? const Color(0xFF7EEB5A)
                                      : const Color(0xFF3DB81A),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                b,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.isActive ? const Color(0xFF444444) : const Color(0xFF555555),
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 100),
      color: const Color(0xFF0E0E0E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Selected Work', color: Color(0xFF7EEB5A)),
          const SizedBox(height: 20),
          const Text(
            'Best Projects',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 60,
              fontWeight: FontWeight.w600,
              height: 1.1,
              letterSpacing: -0.02,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: isMobile ? 1 : 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _ProjectCard(
                    tag: 'Fintech',
                    title: 'Fintech Mobile & Web Apps',
                    desc: 'Built financial apps integrating payment gateways, KYC systems, OTP auth, analytics, and real-time tracking for international money exchange and remittance clients.',
                    chips: ['Flutter', 'gRPC', 'Firebase', 'BLoC'],
                  ),
                  _ProjectCard(
                    tag: 'Sports',
                    title: 'SportsPro',
                    desc: 'Feature-rich sports league app with live scores, team stats, fixtures, and leaderboards. Built with Flutter BLoC architecture with seamless UX across iOS and Android.',
                    chips: ['Flutter', 'BLoC', 'REST API'],
                  ),
                  _ProjectCard(
                    tag: 'Productivity',
                    title: 'Ticket Handling System',
                    desc: 'Manages and tracks user service requests as tickets. Real-time monitoring dashboard with team assignment logic and priority queuing.',
                    chips: ['Flutter', 'Firebase', 'Web'],
                  ),
                  _ProjectCard(
                    tag: 'Finance',
                    title: 'Expense Guard',
                    desc: 'Expense tracking app with categorized insights and budget analytics. Secure authentication and dynamic chart visualizations using Firebase.',
                    chips: ['Flutter', 'Firebase', 'Charts'],
                  ),
                  _ProjectCard(
                    tag: 'Social',
                    title: 'Snap Talk',
                    desc: 'Dynamic cross-platform messaging application built in Flutter with real-time chat functionality and a clean, modern interface.',
                    chips: ['Flutter', 'Firebase', 'GetX'],
                  ),
                  _ProjectCard(
                    tag: 'Lifestyle',
                    title: 'Meals App',
                    desc: 'Recipe discovery app with categorized dishes and interactive step-by-step cooking guides. Clean UI focused on readability and usability.',
                    chips: ['Flutter', 'REST API', 'GetX'],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final String tag;
  final String title;
  final String desc;
  final List<String> chips;
  const _ProjectCard({required this.tag, required this.title, required this.desc, required this.chips});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? const Color(0xFF7EEB5A) : Colors.white.withValues(alpha: 0.06),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: const Color(0xFF7EEB5A).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF7EEB5A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                widget.tag,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.08, color: Color(0xFF7EEB5A)),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.title, style: const TextStyle(fontFamily: 'Cormorant Garamond', fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            Text(widget.desc, style: const TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.7)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.chips.map((chip) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(chip, style: const TextStyle(fontSize: 11, color: Colors.white60)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 100),
      color: Colors.white,
      child: Column(
        children: [
          const _SectionLabel('Recognition'),
          const SizedBox(height: 20),
          const Text(
            'Highlights & Achievements',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 60,
              fontWeight: FontWeight.w600,
              height: 1.1,
              letterSpacing: -0.02,
              color: Color(0xFF0E0E0E),
            ),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: isMobile ? 1 : 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _AchievementCard(icon: '🏆', title: 'Employee of the Month', desc: 'Awarded at Thoughtbox Online Services for exceptional performance, delivering modules ahead of schedule and increasing release velocity.'),
                  _AchievementCard(icon: '🎓', title: 'College Representative', desc: 'Served as College Representative for first-year students at MES College of Engineering and Technology, Ernakulam.'),
                  _AchievementCard(icon: '🤝', title: 'Active NSS Volunteer', desc: 'Dedicated National Service Scheme volunteer, contributing to community service and social impact initiatives.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatefulWidget {
  final String icon;
  final String title;
  final String desc;
  const _AchievementCard({required this.icon, required this.title, required this.desc});

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? const Color(0xFF7EEB5A) : Colors.black.withValues(alpha: 0.05),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: const Color(0xFF7EEB5A).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 20),
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Text(widget.desc, style: const TextStyle(fontSize: 13, color: Color(0xFF777777), height: 1.7)),
          ],
        ),
      ),
    );
  }
}

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 100),
      color: const Color(0xFFF5F5F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Academic Background'),
          const SizedBox(height: 20),
          const Text(
            'Education',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 60,
              fontWeight: FontWeight.w600,
              height: 1.1,
              letterSpacing: -0.02,
              color: Color(0xFF0E0E0E),
            ),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: isMobile ? 1 : 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _EduCard(year: '2019 – 2023', degree: 'B.Tech — Electronics & Communication', school: 'MES College of Engineering and Technology, Ernakulam'),
                  _EduCard(year: '2017 – 2019', degree: 'Higher Secondary — Computer Sciences', school: 'Central Calvathy Fort Kochi'),
                  _EduCard(year: 'Until 2017', degree: 'High School', school: 'Aasia Bai Higher Secondary School, Mattancherry'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EduCard extends StatefulWidget {
  final String year;
  final String degree;
  final String school;
  const _EduCard({required this.year, required this.degree, required this.school});

  @override
  State<_EduCard> createState() => _EduCardState();
}

class _EduCardState extends State<_EduCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? const Color(0xFF7EEB5A) : Colors.black.withValues(alpha: 0.06),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: const Color(0xFF7EEB5A).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.year,
              style: const TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 11,
                letterSpacing: 0.1,
                color: Color(0xFF3DB81A),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.degree, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 6),
            Text(widget.school, style: const TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 100),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4FBB2), Color(0xFFA8F075), Color(0xFF7EEB5A)],
        ),
      ),
      child: Column(
        children: [
          const _SectionLabel('Let\'s Build Together', centered: true, color: Color(0xFF3DB81A)),
          const SizedBox(height: 20),
          const Text(
            'Got a project in mind?\nLet\'s talk.',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 72,
              fontWeight: FontWeight.w600,
              height: 1.1,
              letterSpacing: -0.02,
              color: Color(0xFF0E0E0E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          const Text(
            'I\'m open to freelance work, full-time roles, and interesting collaborations.',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _ContactLink(icon: '✉️', text: 'khhafsal32@gmail.com', isDark: true, onTap: () {
                final Uri emailUri = Uri(scheme: 'mailto', path: 'khhafsal32@gmail.com');
                launchUrl(emailUri);
              }),
              _ContactLink(icon: '🔗', text: 'LinkedIn →', isDark: false, onTap: () {
                final Uri url = Uri.parse('https://linkedin.com/in/hafzal-k-h-061057196');
                launchUrl(url);
              }),
              _ContactLink(icon: '🐙', text: 'GitHub →', isDark: false, onTap: () {
                final Uri url = Uri.parse('https://github.com/hafzalKH32');
                launchUrl(url);
              }),
              _ContactLink(icon: '📞', text: '+91 79028 33425', isDark: false, onTap: () {
                final Uri telUri = Uri(scheme: 'tel', path: '+917902833425');
                launchUrl(telUri);
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactLink extends StatelessWidget {
  final String icon;
  final String text;
  final bool isDark;
  final VoidCallback onTap;
  const _ContactLink({required this.icon, required this.text, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0E0E0E) : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(50),
            border: isDark ? null : Border.all(color: Colors.black.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0E0E0E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 28),
      color: const Color(0xFF0E0E0E),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          if (isMobile) {
            return Column(
              children: [
                const Text(
                  '© 2025 Hafzal K H — Flutter Developer, Mattancherry, Kerala',
                  style: TextStyle(fontSize: 12, fontFamily: 'Space Mono', color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FooterLink(text: 'GitHub', onTap: () {
                      final Uri url = Uri.parse('https://github.com/hafzalKH32');
                      launchUrl(url);
                    }),
                    const Text(' · ', style: TextStyle(color: Colors.white54)),
                    _FooterLink(text: 'LinkedIn', onTap: () {
                      final Uri url = Uri.parse('https://linkedin.com/in/hafzal-k-h-061057196');
                      launchUrl(url);
                    }),
                  ],
                ),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2025 Hafzal K H — Flutter Developer, Mattancherry, Kerala',
                style: TextStyle(fontSize: 12, fontFamily: 'Space Mono', color: Colors.white54),
              ),
              Row(
                children: [
                  _FooterLink(text: 'GitHub', onTap: () {
                    final Uri url = Uri.parse('https://github.com/hafzalKH32');
                    launchUrl(url);
                  }),
                  const Text(' · ', style: TextStyle(color: Colors.white54)),
                  _FooterLink(text: 'LinkedIn', onTap: () {
                    final Uri url = Uri.parse('https://linkedin.com/in/hafzal-k-h-061057196');
                    launchUrl(url);
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontFamily: 'Space Mono', color: Colors.white54),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool centered;
  final Color? color;
  const _SectionLabel(this.text, {this.centered = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        const Text('/', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFCCCCCC))),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Space Mono',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
            color: color ?? const Color(0xFF3DB81A),
          ),
        ),
      ],
    );
  }
}