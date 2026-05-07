import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/game_settings.dart';
import '../models/joker.dart';
import '../services/dictionary_service.dart';
import '../services/game_state.dart';
import '../widgets/grid_widget.dart';
import '../widgets/joker_bar.dart';


class GameScreen extends StatefulWidget {
  final GameSettings settings;

  const GameScreen({super.key, required this.settings});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState? _gameState;
  bool _loading = true;

  Timer? _powerEffectTimer;
  Timer? _wordEffectTimer;
  List<PowerEffect> _activePowerEffects = [];
  List<EffectCell> _activeWordEffects = [];
  List<EffectCell> _activeJokerEffects = [];
  JokerAnimationEvent? _activeJokerOverlay;
  int? _lastPlayedJokerActionId;
  bool _playingJokerAnimation = false;
  bool _showCenterJoker = false;
  String? _lastShownAttemptKey;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    final dict = DictionaryService.instance;
    if (!dict.isLoaded) {
      await dict.load();
    }

    if (!mounted) return;

    setState(() {
      _gameState = GameState(
        settings: widget.settings,
        dictionary: dict,
      );
      _loading = false;
    });

    _gameState!.addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    if (mounted) setState(() {});

    final gs = _gameState;
    if (gs == null) return;

    _maybePlayJokerAnimation(gs);

    final attempt = gs.lastAttempt;
    if (attempt == null || attempt.word.isEmpty) return;

    final attemptKey =
        '${attempt.word}_${attempt.isValid}_${attempt.points}_${attempt.comboCount}_${attempt.powerEarned}_${attempt.powerEffects.length}_${gs.movesLeft}_${gs.score}';

    if (_lastShownAttemptKey == attemptKey) return;
    _lastShownAttemptKey = attemptKey;

    
    _showAttemptFeedback(attempt);

    
    _showWordCellEffect(attempt);

    
    _showPowerCellEffect(attempt);
  }

  void _maybePlayJokerAnimation(GameState gs) {
    final action = gs.pendingJokerAction;
    if (action == null) return;
    if (_playingJokerAnimation) return;
    if (_lastPlayedJokerActionId == action.id) return;

    _lastPlayedJokerActionId = action.id;
    _playJokerAnimation(action);
  }

  Future<void> _playJokerAnimation(JokerAnimationEvent action) async {
    _playingJokerAnimation = true;

    if (!mounted) return;
    setState(() {
      _activeJokerOverlay = action;
      _activeJokerEffects = [];
      _showCenterJoker = true;
    });

    
    await Future.delayed(_centerStageDuration(action.type));
    if (!mounted) return;

    
    setState(() {
      _showCenterJoker = false;
      _activeJokerEffects = action.affectedCells;
    });

    
    await Future.delayed(_jokerImpactDelay(action.type));
    if (!mounted) return;

    
    _gameState?.executePendingJokerAction(action.id);

    await Future.delayed(_jokerAfterImpactDelay(action.type));
    if (!mounted) return;

    setState(() {
      _activeJokerOverlay = null;
      _activeJokerEffects = [];
      _showCenterJoker = false;
    });

    _playingJokerAnimation = false;
  }

  Duration _centerStageDuration(JokerType type) {
    switch (type) {
      case JokerType.fish:
        return const Duration(milliseconds: 880);
      case JokerType.wheel:
      case JokerType.shuffle:
        return const Duration(milliseconds: 820);
      case JokerType.lollipop:
      case JokerType.swap:
        return const Duration(milliseconds: 760);
      case JokerType.party:
        return const Duration(milliseconds: 920);
    }
  }

  Duration _jokerImpactDelay(JokerType type) {
    switch (type) {
      case JokerType.fish:
        return const Duration(milliseconds: 1650);
      case JokerType.lollipop:
        return const Duration(milliseconds: 1050);
      case JokerType.swap:
        return const Duration(milliseconds: 560);
      case JokerType.wheel:
        return const Duration(milliseconds: 360);
      case JokerType.shuffle:
        return const Duration(milliseconds: 460);
      case JokerType.party:
        return const Duration(milliseconds: 520);
    }
  }

  Duration _jokerAfterImpactDelay(JokerType type) {
    switch (type) {
      case JokerType.fish:
        return const Duration(milliseconds: 650);
      case JokerType.lollipop:
        return const Duration(milliseconds: 650);
      case JokerType.swap:
        return const Duration(milliseconds: 430);
      case JokerType.wheel:
        return const Duration(milliseconds: 520);
      case JokerType.shuffle:
        return const Duration(milliseconds: 520);
      case JokerType.party:
        return const Duration(milliseconds: 620);
    }
  }

  void _showAttemptFeedback(WordAttempt attempt) {
    if (!mounted) return;

    
    if (attempt.word.length < AppConstants.minWordLength) {
      return;
    }

    if (attempt.isValid) {
      ScaffoldMessenger.of(context).clearSnackBars();

      final hasCombo = attempt.subwords.isNotEmpty;
      final powerEarned = attempt.powerEarned != SpecialPower.none;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              hasCombo ? const Color(0xFFFF8A00) : AppColors.success,
          duration: Duration(seconds: hasCombo || powerEarned ? 3 : 2),
          behavior: SnackBarBehavior.floating,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasCombo
                        ? Icons.local_fire_department_rounded
                        : Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      attempt.word,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '+${attempt.points}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              if (hasCombo) ...[
                const SizedBox(height: 7),
                Text(
                  'Combo x${attempt.comboCount} • ${attempt.subwords.join(", ")}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.96),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (powerEarned) ...[
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Özel güç oluştu: ${_powerName(attempt.powerEarned)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.96),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          content: Row(
            children: [
              const Icon(Icons.cancel_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"${attempt.word}" sözlükte yok',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showWordCellEffect(WordAttempt attempt) {
    _wordEffectTimer?.cancel();

    if (!attempt.hasWordExplosion) {
      setState(() {
        _activeWordEffects = [];
      });
      return;
    }

    setState(() {
      _activeWordEffects = attempt.wordCells;
    });

    _wordEffectTimer = Timer(const Duration(milliseconds: 620), () {
      if (!mounted) return;
      setState(() {
        _activeWordEffects = [];
      });
    });
  }

  void _showPowerCellEffect(WordAttempt attempt) {
    _powerEffectTimer?.cancel();

    if (!attempt.hasTriggeredPower) {
      setState(() {
        _activePowerEffects = [];
      });
      return;
    }

    setState(() {
      _activePowerEffects = attempt.powerEffects;
    });

    _powerEffectTimer = Timer(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      setState(() {
        _activePowerEffects = [];
      });
    });
  }

  
  String _powerName(SpecialPower power) {
    switch (power) {
      case SpecialPower.rowClear:
        return 'Satır Temizleme';
      case SpecialPower.bomb:
        return 'Alan Patlatma';
      case SpecialPower.columnClear:
        return 'Sütun Temizleme';
      case SpecialPower.mega:
        return 'Mega Patlatma';
      case SpecialPower.none:
        return '';
    }
  }

  IconData _powerIcon(SpecialPower power) {
    switch (power) {
      case SpecialPower.rowClear:
        return Icons.horizontal_rule_rounded;
      case SpecialPower.bomb:
        return Icons.bubble_chart_rounded;
      case SpecialPower.columnClear:
        return Icons.vertical_align_center_rounded;
      case SpecialPower.mega:
        return Icons.auto_awesome_rounded;
      case SpecialPower.none:
        return Icons.star_rounded;
    }
  }

  Color _powerColor(SpecialPower power) {
    switch (power) {
      case SpecialPower.rowClear:
        return const Color(0xFF00B894);
      case SpecialPower.bomb:
        return const Color(0xFFFF6B6B);
      case SpecialPower.columnClear:
        return const Color(0xFF0984E3);
      case SpecialPower.mega:
        return const Color(0xFF9B5DE5);
      case SpecialPower.none:
        return AppColors.primary;
    }
  }


  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Çıkmak istiyor musun?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Mevcut sonucun skor tablosuna kaydedilecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hayır'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Evet, çık'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleBackPress() async {
    final shouldExit = await _confirmExit();
    if (!mounted) return;
    if (shouldExit) {
      _gameState?.endGame();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _powerEffectTimer?.cancel();
    _wordEffectTimer?.cancel();
    _gameState?.removeListener(_onGameStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _gameState == null) {
      return Scaffold(
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Sözlük yükleniyor...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final gs = _gameState!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildTopBar(gs),
                    const SizedBox(height: 8),
                    _buildStatsRow(gs),
                    const SizedBox(height: 12),
                    _buildCurrentWordBar(gs),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              children: [
                                GridWidget(gameState: gs),
                                _buildPowerEffectLayer(gs),
                                _buildJokerEffectLayer(gs),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!gs.isGameOver) JokerBar(gameState: gs),
                    if (gs.isGameOver) _buildGameOverBanner(gs),
                  ],
                ),
                _buildJokerCenterOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(GameState gs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBackPress,
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.30),
              ),
            ),
            child: Text(
              gs.settings.gridSizeText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.5,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 46),
        ],
      ),
    );
  }

  Widget _buildStatsRow(GameState gs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              icon: Icons.star_rounded,
              label: 'PUAN',
              value: '${gs.score}',
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _statCard(
              icon: Icons.touch_app_rounded,
              label: 'HAMLE',
              value: '${gs.movesLeft}',
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _statCard(
              icon: Icons.text_fields_rounded,
              label: 'BULUNAN',
              value: '${gs.wordsFound}',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _statCard(
              icon: Icons.search_rounded,
              label: 'OLASI',
              value: '${gs.possibleWordCount}',
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWordBar(GameState gs) {
    final word = gs.currentWord;
    final isEmpty = word.isEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: isEmpty ? null : AppColors.buttonGradient,
        color: isEmpty ? Colors.white.withValues(alpha: 0.38) : null,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: isEmpty ? 0.18 : 0.45),
          width: 1.2,
        ),
        boxShadow: isEmpty
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Center(
        child: Text(
          isEmpty ? 'Harfleri sürükle...' : word,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isEmpty ? 22 : 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: const [
              Shadow(
                color: Colors.black12,
                offset: Offset(1, 2),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJokerCenterOverlay() {
    final action = _activeJokerOverlay;
    if (action == null || !_showCenterJoker) {
      return const SizedBox.shrink();
    }

    final joker = JokerCatalog.getByType(action.type);
    final color = joker.color;

    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(action.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: _centerStageDuration(action.type),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final appear = value < 0.25 ? value / 0.25 : 1.0;
            final pulse = 1.0 + 0.12 * sin(value * pi * 6);
            final rotate = _jokerRotation(action.type, value);
            final shake = _jokerShake(action.type, value);

            return Stack(
              children: [
                Container(color: Colors.black.withValues(alpha: 0.20 * appear)),
                Center(
                  child: Transform.translate(
                    offset: Offset(shake, 0),
                    child: Transform.rotate(
                      angle: rotate,
                      child: Transform.scale(
                        scale: (0.55 + appear * 0.70) * pulse,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.98),
                                color.withValues(alpha: 0.86),
                                color.withValues(alpha: 0.62),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.95),
                              width: 5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.70),
                                blurRadius: 34,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.60),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: 25,
                                top: 22,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Image.asset(
                                joker.assetPath,
                                width: 106,
                                height: 106,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    joker.fallbackIcon,
                                    color: Colors.white,
                                    size: 82,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(1, 3),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              if (action.type == JokerType.party && value > 0.52)
                                ..._confetti(value, color),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (value > 0.70)
                  Center(
                    child: Transform.scale(
                      scale: (value - 0.70) * 4,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: (1 - value) * 2.2),
                            width: 7,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _jokerRotation(JokerType type, double value) {
    switch (type) {
      case JokerType.wheel:
      case JokerType.shuffle:
        return value * pi * 5.5;
      case JokerType.lollipop:
        return sin(value * pi * 7) * 0.18;
      case JokerType.swap:
        return sin(value * pi * 8) * 0.12;
      case JokerType.party:
        return sin(value * pi * 5) * 0.10;
      case JokerType.fish:
        return sin(value * pi * 4) * 0.15;
    }
  }

  double _jokerShake(JokerType type, double value) {
    switch (type) {
      case JokerType.lollipop:
      case JokerType.swap:
        return sin(value * pi * 12) * 5;
      case JokerType.fish:
        return sin(value * pi * 5) * 10;
      case JokerType.wheel:
      case JokerType.shuffle:
      case JokerType.party:
        return 0;
    }
  }

  List<Widget> _confetti(double value, Color color) {
    final pieces = <Widget>[];
    final colors = [
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.primary,
      Colors.white,
      color,
    ];

    for (int i = 0; i < 14; i++) {
      final angle = (2 * pi / 14) * i;
      final dist = 38 + (value - 0.52) * 105;
      pieces.add(
        Transform.translate(
          offset: Offset(cos(angle) * dist, sin(angle) * dist),
          child: Transform.rotate(
            angle: angle + value * pi,
            child: Container(
              width: 8,
              height: 15,
              decoration: BoxDecoration(
                color: colors[i % colors.length].withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      );
    }

    return pieces;
  }

  Widget _buildJokerEffectLayer(GameState gs) {
    if (_activeJokerEffects.isEmpty || _activeJokerOverlay == null) {
      return const SizedBox.shrink();
    }

    final action = _activeJokerOverlay!;
    final joker = JokerCatalog.getByType(action.type);
    final color = joker.color;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = gs.settings.gridSize;
          final cellSize = constraints.maxWidth / size;

          if (action.type == JokerType.fish) {
            return _buildFishTravelLayer(
              action: action,
              joker: joker,
              color: color,
              cellSize: cellSize,
              boardSize: constraints.maxWidth,
            );
          }

          if (action.type == JokerType.lollipop) {
            return _buildLollipopTravelHitLayer(
              action: action,
              joker: joker,
              color: color,
              cellSize: cellSize,
              boardSize: constraints.maxWidth,
            );
          }

          return Stack(
            children: _activeJokerEffects.map((cell) {
              return Positioned(
                left: cell.col * cellSize,
                top: cell.row * cellSize,
                width: cellSize,
                height: cellSize,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 760),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    final opacity = (1.0 - value).clamp(0.0, 1.0);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.70 + value * 1.45,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.22 * opacity),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.86 * opacity),
                                  blurRadius: 26,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.75 + value * 0.35,
                          child: Icon(
                            _jokerEffectIcon(action.type),
                            color: Colors.white.withValues(alpha: 0.95 * opacity),
                            size: cellSize * 0.42,
                            shadows: [Shadow(color: color, blurRadius: 14)],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildFishTravelLayer({
    required JokerAnimationEvent action,
    required Joker joker,
    required Color color,
    required double cellSize,
    required double boardSize,
  }) {
    final start = Offset(
      boardSize / 2 - cellSize / 2,
      boardSize / 2 - cellSize / 2,
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey('fish_${action.id}'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1850),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        return Stack(
          children: [
            for (int i = 0; i < action.affectedCells.length; i++)
              _buildSingleFishTravel(
                joker: joker,
                color: color,
                cell: action.affectedCells[i],
                index: i,
                total: action.affectedCells.length,
                value: value,
                start: start,
                cellSize: cellSize,
              ),
          ],
        );
      },
    );
  }

  Widget _buildSingleFishTravel({
    required Joker joker,
    required Color color,
    required EffectCell cell,
    required int index,
    required int total,
    required double value,
    required Offset start,
    required double cellSize,
  }) {
    final target = Offset(cell.col * cellSize, cell.row * cellSize);

    final segment = 1.0 / total.clamp(1, 20);
    final begin = index * segment * 0.82;
    final end = (begin + segment * 1.35).clamp(0.0, 1.0);

    final raw = ((value - begin) / (end - begin)).clamp(0.0, 1.0);
    final t = Curves.easeInOutCubic.transform(raw);

    final arcHeight = -cellSize * 0.85 * sin(t * pi);

    final current = Offset(
      start.dx + (target.dx - start.dx) * t,
      start.dy + (target.dy - start.dy) * t + arcHeight,
    );

    final splashOpacity = raw > 0.68 ? ((1.0 - raw) / 0.32).clamp(0.0, 1.0) : 0.0;
    final fishOpacity = raw <= 0.0 || raw >= 1.0 ? 0.0 : 1.0;

    return Stack(
      children: [
        
        Positioned(
          left: current.dx,
          top: current.dy,
          width: cellSize,
          height: cellSize,
          child: Opacity(
            opacity: fishOpacity,
            child: Transform.rotate(
              angle: sin(value * pi * 8 + index) * 0.18,
              child: Transform.scale(
                scale: 1.15 + sin(value * pi * 6) * 0.08,
                child: Image.asset(
                  joker.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      joker.fallbackIcon,
                      color: Colors.white,
                      size: cellSize * 0.75,
                      shadows: [
                        Shadow(color: color, blurRadius: 12),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        
        if (fishOpacity > 0)
          Positioned(
            left: current.dx + cellSize * 0.10,
            top: current.dy + cellSize * 0.72,
            child: Row(
              children: [
                _bubble(color, cellSize * 0.10, value),
                SizedBox(width: cellSize * 0.04),
                _bubble(color, cellSize * 0.07, value + 0.2),
                SizedBox(width: cellSize * 0.04),
                _bubble(color, cellSize * 0.05, value + 0.4),
              ],
            ),
          ),

        
        Positioned(
          left: target.dx,
          top: target.dy,
          width: cellSize,
          height: cellSize,
          child: Opacity(
            opacity: splashOpacity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: 0.8 + raw * 1.3,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.24),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.85),
                          blurRadius: 24,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white.withValues(alpha: 0.95),
                  size: cellSize * 0.50,
                  shadows: [Shadow(color: color, blurRadius: 14)],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubble(Color color, double size, double value) {
    return Transform.translate(
      offset: Offset(0, -sin(value * pi * 2) * 5),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.70),
          border: Border.all(
            color: color.withValues(alpha: 0.65),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildLollipopTravelHitLayer({
    required JokerAnimationEvent action,
    required Joker joker,
    required Color color,
    required double cellSize,
    required double boardSize,
  }) {
    final cell = action.affectedCells.isNotEmpty
        ? action.affectedCells.first
        : const EffectCell(row: 0, col: 0);

    final start = Offset(
      boardSize / 2 - cellSize * 1.05,
      boardSize / 2 - cellSize * 1.05,
    );

    final target = Offset(
      cell.col * cellSize - cellSize * 0.15,
      cell.row * cellSize - cellSize * 0.95,
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey('lollipop_travel_${action.id}'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1250),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        final travelT = value < 0.70 ? value / 0.70 : 1.0;
        final hitT =
            value >= 0.70 ? ((value - 0.70) / 0.30).clamp(0.0, 1.0) : 0.0;

        final easedTravel = Curves.easeInOutCubic.transform(travelT);

        final current = Offset(
          start.dx + (target.dx - start.dx) * easedTravel,
          start.dy + (target.dy - start.dy) * easedTravel,
        );

        final scale = 1.55 - easedTravel * 0.45;
        final hitOffset = hitT > 0 ? sin(hitT * pi) * cellSize * 0.38 : 0.0;
        final flashOpacity = hitT > 0.05 ? (1.0 - hitT).clamp(0.0, 1.0) : 0.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: cell.col * cellSize,
              top: cell.row * cellSize,
              width: cellSize,
              height: cellSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 0.92 + value * 0.18,
                    child: Container(
                      margin: EdgeInsets.all(cellSize * 0.04),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(cellSize * 0.24),
                        border: Border.all(
                          color: color.withValues(alpha: 0.90),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.60),
                            blurRadius: 18,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hitT > 0.04)
                    Transform.scale(
                      scale: 0.65 + hitT * 1.55,
                      child: Opacity(
                        opacity: flashOpacity,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.45),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.95),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (hitT > 0.08)
                    Opacity(
                      opacity: flashOpacity,
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: cellSize * 0.75,
                        shadows: [Shadow(color: color, blurRadius: 14)],
                      ),
                    ),
                ],
              ),
            ),

            Positioned(
              left: current.dx,
              top: current.dy + hitOffset,
              width: cellSize * 2.15,
              height: cellSize * 2.15,
              child: Transform.rotate(
                angle: -0.55 + sin(value * pi * 5) * 0.18,
                child: Transform.scale(
                  scale: scale,
                  child: Image.asset(
                    joker.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        joker.fallbackIcon,
                        color: Colors.white,
                        size: cellSize * 1.30,
                        shadows: [Shadow(color: color, blurRadius: 14)],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _jokerEffectIcon(JokerType type) {
    switch (type) {
      case JokerType.fish:
        return Icons.water_drop_rounded;
      case JokerType.wheel:
        return Icons.add_circle_outline_rounded;
      case JokerType.lollipop:
        return Icons.star_rounded;
      case JokerType.swap:
        return Icons.swap_horiz_rounded;
      case JokerType.shuffle:
        return Icons.cyclone_rounded;
      case JokerType.party:
        return Icons.celebration_rounded;
    }
  }

  Widget _buildPowerEffectLayer(GameState gs) {
    if (_activePowerEffects.isEmpty && _activeWordEffects.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = gs.settings.gridSize;
          final cellSize = constraints.maxWidth / size;

          return Stack(
            children: [
              ..._activeWordEffects.map((cell) {
                return Positioned(
                  left: cell.col * cellSize,
                  top: cell.row * cellSize,
                  width: cellSize,
                  height: cellSize,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 560),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      final opacity = (1.0 - value).clamp(0.0, 1.0);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: 0.65 + value * 1.40,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.30 * opacity),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD93D).withValues(alpha: 0.95 * opacity),
                                    blurRadius: 26,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.70 + value * 0.55,
                            child: Icon(
                              Icons.star_rounded,
                              color: Colors.white.withValues(alpha: 0.95 * opacity),
                              size: cellSize * 0.48,
                              shadows: const [
                                Shadow(
                                  color: Color(0xFFFF8A00),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }),
              for (final effect in _activePowerEffects)
                ...effect.cells.map((cell) {
                  final color = _powerColor(effect.power);

                  return Positioned(
                    left: cell.col * cellSize,
                    top: cell.row * cellSize,
                    width: cellSize,
                    height: cellSize,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 850),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        final flashOpacity = value < 0.45
                            ? 0.90
                            : (1.0 - value).clamp(0.0, 1.0);

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: 0.55 + value * 1.35,
                              child: Container(
                                margin: EdgeInsets.all(cellSize * 0.02),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(
                                    alpha: 0.24 * flashOpacity,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(
                                        alpha: 0.80 * flashOpacity,
                                      ),
                                      blurRadius: 24,
                                      spreadRadius: 9,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.82 + value * 0.20,
                              child: Container(
                                margin: EdgeInsets.all(cellSize * 0.07),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(
                                        alpha: 0.82 * flashOpacity,
                                      ),
                                      color.withValues(
                                        alpha: 0.72 * flashOpacity,
                                      ),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(cellSize * 0.22),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: 0.96 * flashOpacity,
                                    ),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(
                                        alpha: 0.95 * flashOpacity,
                                      ),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (value < 0.7)
                              Icon(
                                _powerIcon(effect.power),
                                color: Colors.white.withValues(
                                  alpha: 0.96 * flashOpacity,
                                ),
                                size: cellSize * (0.28 + value * 0.18),
                                shadows: [
                                  Shadow(
                                    color: color,
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameOverBanner(GameState gs) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events,
              color: AppColors.secondary, size: 48),
          const SizedBox(height: 8),
          const Text(
            'OYUN BİTTİ',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toplam Puan: ${gs.score}\n'
            'Bulunan Kelime: ${gs.wordsFound}\n'
            'En Uzun Kelime: ${gs.longestWord.isEmpty ? "-" : gs.longestWord}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ana Ekrana Dön'),
          ),
        ],
      ),
    );
  }
}


