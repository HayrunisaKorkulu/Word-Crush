import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/joker.dart';
import '../services/storage_service.dart';


class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  StorageService? _storage;
  int _gold = 0;
  Map<String, int> _ownedJokers = {};
  bool _loading = true;
  String? _justBoughtType;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _storage = await StorageService.getInstance();
    if (!mounted) return;
    setState(() {
      _gold = _storage!.getGold();
      _ownedJokers = _storage!.getOwnedJokers();
      _loading = false;
    });
  }

  Future<void> _buy(Joker joker) async {
    if (_gold < joker.goldCost) {
      _showSnack(
        'Yeterli altının yok!',
        AppColors.error,
        Icons.error_outline_rounded,
      );
      return;
    }

    await _storage!.spendGold(joker.goldCost);
    await _storage!.addJoker(joker.type.name);

    if (!mounted) return;
    setState(() {
      _gold = _storage!.getGold();
      _ownedJokers = _storage!.getOwnedJokers();
      _justBoughtType = joker.type.name;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_justBoughtType == joker.type.name) {
        setState(() => _justBoughtType = null);
      }
    });

    _showSnack(
      '${joker.name} satın alındı!',
      AppColors.success,
      Icons.check_circle_rounded,
    );
  }

  void _showSnack(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        duration: const Duration(milliseconds: 1450),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.all(12),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              const _CandyBackgroundDecor(),
              _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Column(
                      children: [
                        _buildTopBar(),
                        _buildHero(),
                        Expanded(child: _buildJokerList()),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          _goldPill(),
        ],
      ),
    );
  }

  Widget _goldPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.38),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            color: Colors.white,
            size: 21,
          ),
          const SizedBox(width: 6),
          Text(
            '$_gold',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.70),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: AppColors.accent,
              size: 43,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'MARKET',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: AppColors.primaryDark,
                  offset: Offset(2, 3),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Jokerlerini güçlendir, oyunda avantaj kazan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJokerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      itemCount: JokerCatalog.all.length,
      itemBuilder: (context, index) {
        final joker = JokerCatalog.all[index];
        final ownedCount = _ownedJokers[joker.type.name] ?? 0;
        final canAfford = _gold >= joker.goldCost;
        final justBought = _justBoughtType == joker.type.name;
        return _buildJokerCard(joker, ownedCount, canAfford, justBought);
      },
    );
  }

  Widget _buildJokerCard(
    Joker joker,
    int ownedCount,
    bool canAfford,
    bool justBought,
  ) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      scale: justBought ? 1.025 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.98),
              joker.color.withValues(alpha: canAfford ? 0.20 : 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: justBought
                ? Colors.white
                : joker.color.withValues(alpha: canAfford ? 0.55 : 0.22),
            width: justBought ? 3 : 1.7,
          ),
          boxShadow: [
            BoxShadow(
              color: joker.color.withValues(alpha: canAfford ? 0.30 : 0.12),
              blurRadius: justBought ? 24 : 16,
              spreadRadius: justBought ? 2 : 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -24,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: joker.color.withValues(alpha: 0.08),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _boosterIcon(joker, canAfford, justBought),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              joker.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _ownedBadge(ownedCount),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        joker.description,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 9),
                      _detailChip(
                        icon: Icons.flag_rounded,
                        title: 'Amaç',
                        value: joker.usagePurpose,
                        color: joker.color,
                      ),
                      const SizedBox(height: 6),
                      _detailChip(
                        icon: Icons.touch_app_rounded,
                        title: 'Kullanım',
                        value: joker.usageHow,
                        color: joker.color,
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          _priceBadge(joker.goldCost),
                          const Spacer(),
                          _buyButton(joker, canAfford),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _boosterIcon(Joker joker, bool canAfford, bool justBought) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.40),
          radius: 0.95,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            joker.color.withValues(alpha: canAfford ? 0.92 : 0.35),
            joker.color.withValues(alpha: canAfford ? 0.72 : 0.20),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.92),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: joker.color.withValues(alpha: canAfford ? 0.45 : 0.18),
            blurRadius: justBought ? 22 : 14,
            spreadRadius: justBought ? 2 : 0,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 13,
            top: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
          Image.asset(
            joker.assetPath,
            width: justBought ? 52 : 48,
            height: justBought ? 52 : 48,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                joker.fallbackIcon,
                color: Colors.white,
                size: justBought ? 42 : 38,
              );
            },
          ),
          if (justBought)
            Positioned(
              right: 7,
              top: 6,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withValues(alpha: 0.98),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _ownedBadge(int ownedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D2A8), Color(0xFF00A884)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'x$ownedCount',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _detailChip({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.18,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(color: color, fontWeight: FontWeight.w900),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBadge(int price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.32),
            const Color(0xFFFFC46B).withValues(alpha: 0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            color: Color(0xFFFF9F43),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$price',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: Color(0xFFE17055),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buyButton(Joker joker, bool canAfford) {
    return SizedBox(
      height: 39,
      child: ElevatedButton(
        onPressed: canAfford ? () => _buy(joker) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canAfford ? joker.color : Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: canAfford ? 7 : 0,
          shadowColor: joker.color.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          canAfford ? 'SATIN AL' : 'YETERSİZ',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class _CandyBackgroundDecor extends StatelessWidget {
  const _CandyBackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: 105,
              right: -35,
              child: _blob(AppColors.secondary, 112),
            ),
            Positioned(
              top: 310,
              left: -45,
              child: _blob(AppColors.accent, 128),
            ),
            Positioned(
              bottom: 80,
              right: -55,
              child: _blob(AppColors.success, 140),
            ),
            Positioned(
              top: 205,
              right: 38,
              child: _candy(AppColors.accent, Icons.favorite_rounded),
            ),
            Positioned(
              bottom: 195,
              left: 34,
              child: _candy(AppColors.secondary, Icons.star_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
    );
  }

  Widget _candy(Color color, IconData icon) {
    return Transform.rotate(
      angle: -0.30,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.42),
          size: 25,
        ),
      ),
    );
  }
}

