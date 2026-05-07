import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/joker.dart';
import '../services/game_state.dart';
import '../services/storage_service.dart';


class JokerBar extends StatefulWidget {
  final GameState gameState;

  const JokerBar({
    super.key,
    required this.gameState,
  });

  @override
  State<JokerBar> createState() => _JokerBarState();
}

class _JokerBarState extends State<JokerBar> {
  StorageService? _storage;
  Map<String, int> _ownedJokers = {};
  bool _loading = true;
  JokerType? _pendingConsumeJoker;

  @override
  void initState() {
    super.initState();
    _loadJokers();
    widget.gameState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onStateChanged);
    super.dispose();
  }

  Future<void> _loadJokers() async {
    _storage = await StorageService.getInstance();

    if (!mounted) return;

    setState(() {
      _ownedJokers = _storage!.getOwnedJokers();
      _loading = false;
    });
  }

  void _onStateChanged() {
    if (widget.gameState.jokerJustConsumed) {
      _consumeLastUsedJoker();
      widget.gameState.clearJokerConsumed();
    }

    if (mounted) setState(() {});
  }

  Future<void> _consumeLastUsedJoker() async {
    if (_pendingConsumeJoker == null) return;

    await _storage!.useJoker(_pendingConsumeJoker!.name);
    _ownedJokers = _storage!.getOwnedJokers();
    _pendingConsumeJoker = null;

    if (mounted) setState(() {});
  }

  Future<void> _onJokerTap(Joker joker) async {
    final ownedCount = _ownedJokers[joker.type.name] ?? 0;

    if (ownedCount <= 0) {
      _showSnack(
        '${joker.name} yok! Marketten satın al.',
        AppColors.error,
        Icons.lock_rounded,
      );
      return;
    }

    if (widget.gameState.activeJoker == joker.type) {
      widget.gameState.cancelJoker();
      _pendingConsumeJoker = null;

      if (mounted) setState(() {});

      _showSnack(
        '${joker.name} iptal edildi',
        AppColors.textSecondary,
        Icons.close_rounded,
      );
      return;
    }

    if (widget.gameState.activeJoker != null) {
      widget.gameState.cancelJoker();
      _pendingConsumeJoker = null;
    }

    if (_needsTarget(joker.type)) {
      _pendingConsumeJoker = joker.type;
      widget.gameState.activateJoker(joker.type);

      if (mounted) setState(() {});

      _showSnack(
        '${joker.name}: ${_targetHint(joker.type)}',
        joker.color,
        Icons.touch_app_rounded,
      );
      return;
    }

    _pendingConsumeJoker = joker.type;
    widget.gameState.activateJoker(joker.type);

    if (mounted) setState(() {});

    _showSnack(
      '${joker.name} hazırlanıyor!',
      joker.color,
      Icons.auto_awesome_rounded,
    );
  }

  bool _needsTarget(JokerType type) {
    return type == JokerType.lollipop ||
        type == JokerType.wheel ||
        type == JokerType.swap;
  }

  String _targetHint(JokerType type) {
    switch (type) {
      case JokerType.lollipop:
        return 'Yok edeceğin harfe dokun';
      case JokerType.wheel:
        return 'Bir harfe dokun (satır+sütun)';
      case JokerType.swap:
        return '2 komşu harfe dokun';
      case JokerType.fish:
      case JokerType.shuffle:
      case JokerType.party:
        return '';
    }
  }

  void _showSnack(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 110),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
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
    if (_loading) {
      return const SizedBox(height: 108);
    }

    return Container(
      height: 108,
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.30),
            Colors.white.withValues(alpha: 0.14),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.42),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: JokerCatalog.all.map((joker) {
          final count = _ownedJokers[joker.type.name] ?? 0;
          final isActive = widget.gameState.activeJoker == joker.type;
          final isOwned = count > 0;

          return Expanded(
            child: _buildBoosterButton(
              joker: joker,
              count: count,
              isActive: isActive,
              isOwned: isOwned,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBoosterButton({
    required Joker joker,
    required int count,
    required bool isActive,
    required bool isOwned,
  }) {
    return GestureDetector(
      onTap: () => _onJokerTap(joker),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 210),
        curve: Curves.easeOutBack,
        scale: isActive ? 1.12 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _boosterCircle(
                joker: joker,
                count: count,
                isActive: isActive,
                isOwned: isOwned,
              ),
              const SizedBox(height: 5),
              Text(
                _shortName(joker.type),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isOwned
                      ? Colors.white.withValues(alpha: 0.96)
                      : Colors.white.withValues(alpha: 0.66),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 2,
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

  Widget _boosterCircle({
    required Joker joker,
    required int count,
    required bool isActive,
    required bool isOwned,
  }) {
    final baseColor = isOwned ? joker.color : Colors.blueGrey.shade300;

    return SizedBox(
      width: 62,
      height: 62,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: isActive ? 62 : 58,
            height: isActive ? 62 : 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isOwned
                    ? [
                        const Color(0xFF65F0B7),
                        const Color(0xFF16B9A7),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.38),
                        Colors.blueGrey.withValues(alpha: 0.34),
                      ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isOwned ? 0.92 : 0.45),
                width: isActive ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isOwned
                      ? const Color(0xFF16B9A7).withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.10),
                  blurRadius: isActive ? 18 : 10,
                  spreadRadius: isActive ? 2 : 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),

          
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: isActive ? 50 : 46,
            height: isActive ? 50 : 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.45),
                radius: 0.95,
                colors: [
                  Colors.white.withValues(alpha: isOwned ? 0.98 : 0.50),
                  baseColor.withValues(alpha: isOwned ? 0.92 : 0.46),
                  baseColor.withValues(alpha: isOwned ? 0.68 : 0.30),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.90),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: isOwned ? 0.42 : 0.12),
                  blurRadius: isActive ? 15 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 8,
                  top: 7,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.50),
                    ),
                  ),
                ),
                Opacity(
                  opacity: isOwned ? 1.0 : 0.52,
                  child: Image.asset(
                    joker.assetPath,
                    width: isActive ? 38 : 34,
                    height: isActive ? 38 : 34,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        joker.fallbackIcon,
                        color: Colors.white,
                        size: isActive ? 30 : 27,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        
          if (isActive)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.95),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: joker.color.withValues(alpha: 0.65),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          
          if (!isOwned)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.16),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),

          
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 25),
              height: 25,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isOwned ? const Color(0xFFE94BC8) : Colors.grey.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),

          
          if (isActive)
            Positioned(
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: joker.color.withValues(alpha: 0.35),
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Text(
                  'AKTİF',
                  style: TextStyle(
                    color: joker.color,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _shortName(JokerType type) {
    switch (type) {
      case JokerType.fish:
        return 'Balık';
      case JokerType.wheel:
        return 'Teker';
      case JokerType.lollipop:
        return 'Loli';
      case JokerType.swap:
        return 'Swap';
      case JokerType.shuffle:
        return 'Mix';
      case JokerType.party:
        return 'Parti';
    }
  }
}


