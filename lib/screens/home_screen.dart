import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/storage_service.dart';
import 'username_screen.dart';
import 'new_game_screen.dart';
import 'score_screen.dart';
import 'market_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = '';
  int _gold = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final storage = await StorageService.getInstance();
    if (!mounted) return;
    setState(() {
      _username = storage.getUsername() ?? 'Oyuncu';
      _gold = storage.getGold();
      _loading = false;
    });
  }

  Future<void> _changeUsername() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const UsernameScreen(isFirstTime: false),
      ),
    );
    if (result == true) _loadUserData();
  }

  void _onNewGame() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewGameScreen()),
    );
  }

  Future<void> _onScoreboard() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScoreScreen()),
    );
    if (mounted) _loadUserData();
  }

  Future<void> _onMarket() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MarketScreen()),
    );
    if (mounted) _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: _CandyBackground()),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  const Spacer(flex: 1),
                  _buildLogo(),
                  const SizedBox(height: 18),
                  _buildMiniStatusCard(),
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        _buildMenuButton(
                          icon: Icons.play_arrow_rounded,
                          label: 'YENİ OYUN',
                          subtitle: 'Grid seç ve kelime avına başla',
                          colors: const [Color(0xFF00D2A8), Color(0xFF00A884)],
                          onTap: _onNewGame,
                        ),
                        const SizedBox(height: 14),
                        _buildMenuButton(
                          icon: Icons.emoji_events_rounded,
                          label: 'SKOR TABLOSU',
                          subtitle: 'Geçmiş oyunlarını ve rekorlarını gör',
                          colors: const [Color(0xFF7C6BFF), Color(0xFF5A4DE8)],
                          onTap: _onScoreboard,
                        ),
                        const SizedBox(height: 14),
                        _buildMenuButton(
                          icon: Icons.shopping_bag_rounded,
                          label: 'MARKET',
                          subtitle: 'Jokerlerini satın al ve güçlen',
                          colors: const [Color(0xFFFF6B8A), Color(0xFFFF4757)],
                          onTap: _onMarket,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Yazlab II • Word Crush',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _changeUsername,
              child: _GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hoş geldin',
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_rounded, size: 17, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _GoldPill(gold: _gold),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _LogoTile(letter: 'W'),
            _LogoTile(letter: 'O'),
            _LogoTile(letter: 'R'),
            _LogoTile(letter: 'D'),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A7A), Color(0xFFFF4757)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Text(
            'CRUSH',
            style: TextStyle(
              fontSize: 38,
              height: 1,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 5,
              shadows: [
                Shadow(color: Colors.black26, offset: Offset(1.5, 2), blurRadius: 2),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Türkçe kelimeleri patlat, puanı topla!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            shadows: const [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatusCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: _GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _MiniFeature(icon: Icons.swipe_rounded, text: '8 yön'),
            _MiniFeature(icon: Icons.auto_awesome_rounded, text: 'Özel güç'),
            _MiniFeature(icon: Icons.local_fire_department_rounded, text: 'Combo'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.70), width: 2),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.42),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, size: 31, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandyBackground extends StatelessWidget {
  const _CandyBackground();

  @override
  Widget build(BuildContext context) {
    final candies = [
      const _FloatingCandy(left: 24, top: 110, size: 44, color: Color(0xFFFFD93D), icon: Icons.star_rounded),
      const _FloatingCandy(right: 32, top: 155, size: 35, color: Color(0xFFFF6B6B), icon: Icons.favorite_rounded),
      const _FloatingCandy(left: 52, bottom: 170, size: 38, color: Color(0xFF00D2A8), icon: Icons.circle),
      const _FloatingCandy(right: 54, bottom: 220, size: 48, color: Color(0xFF7C6BFF), icon: Icons.auto_awesome_rounded),
      const _FloatingCandy(left: -16, bottom: 330, size: 64, color: Color(0xFF8EC5FC), icon: Icons.bubble_chart_rounded),
    ];

    return Stack(
      children: [
        Positioned(
          left: -80,
          top: -60,
          child: _blurCircle(const Color(0xFFFFFFFF), 180, 0.14),
        ),
        Positioned(
          right: -110,
          bottom: 60,
          child: _blurCircle(const Color(0xFFFFD93D), 220, 0.16),
        ),
        Positioned(
          left: 30,
          bottom: -95,
          child: _blurCircle(const Color(0xFF6C5CE7), 210, 0.18),
        ),
        ...candies,
      ],
    );
  }

  static Widget _blurCircle(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

class _FloatingCandy extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;
  final Color color;
  final IconData icon;

  const _FloatingCandy({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: math.pi / 9,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(size * 0.32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.45), size: size * 0.55),
        ),
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  final String letter;

  const _LogoTile({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF1BD), Color(0xFFFFC46B)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Color(0xFF25538E),
            fontSize: 34,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.white70, offset: Offset(0, 1), blurRadius: 1)],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GoldPill extends StatelessWidget {
  final int gold;

  const _GoldPill({required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.38),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 23),
          const SizedBox(width: 5),
          Text(
            '$gold',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}



