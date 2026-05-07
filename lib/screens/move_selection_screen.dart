import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/game_settings.dart';
import 'game_screen.dart';


class MoveSelectionScreen extends StatefulWidget {
  final Difficulty difficulty;

  const MoveSelectionScreen({
    super.key,
    required this.difficulty,
  });

  @override
  State<MoveSelectionScreen> createState() => _MoveSelectionScreenState();
}

class _MoveSelectionScreenState extends State<MoveSelectionScreen> {
  late GameSettings _baseSettings;
  late int _selectedMoves;

  static const List<int> _moveOptions = [15, 20, 25];

  @override
  void initState() {
    super.initState();
    _baseSettings = GameSettings.fromDifficulty(widget.difficulty);
    _selectedMoves = _baseSettings.totalMoves;
  }

  String get _difficultyName {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return 'Kolay Seviye';
      case Difficulty.medium:
        return 'Orta Seviye';
      case Difficulty.hard:
        return 'Zor Seviye';
    }
  }

  Color get _difficultyColor {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.hard:
        return AppColors.accent;
    }
  }

  IconData get _difficultyIcon {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_very_satisfied_rounded;
      case Difficulty.medium:
        return Icons.psychology_alt_rounded;
      case Difficulty.hard:
        return Icons.local_fire_department_rounded;
    }
  }

  String get _description {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return 'Geniş grid ile rahat kelime avı.';
      case Difficulty.medium:
        return 'Dengeli grid ile stratejik oyun.';
      case Difficulty.hard:
        return 'Küçük grid, yüksek dikkat, hızlı karar.';
    }
  }

  String _moveLabel(int moves) {
    if (moves == AppConstants.movesEasy) return 'Kolay Level';
    if (moves == AppConstants.movesMedium) return 'Orta Level';
    if (moves == AppConstants.movesHard) return 'Zor Level';
    return 'Level';
  }

  Color _moveColor(int moves) {
    if (moves == AppConstants.movesEasy) return AppColors.success;
    if (moves == AppConstants.movesMedium) return AppColors.warning;
    return AppColors.accent;
  }

  void _startGame() {
    final settings = _baseSettings.copyWith(totalMoves: _selectedMoves);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GameScreen(settings: settings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _difficultyColor;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              const _CandyBackgroundDecor(),
              Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
                      child: Column(
                        children: [
                          _buildHeaderCard(color),
                          const SizedBox(height: 20),
                          _buildTitle(),
                          const SizedBox(height: 14),
                          ..._moveOptions.map(_buildMoveOption),
                          const SizedBox(height: 20),
                          _buildInfoPanel(),
                          const SizedBox(height: 22),
                          _buildStartButton(color),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          _stepPill(),
        ],
      ),
    );
  }

  Widget _stepPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.23),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Text(
        '2 / 2',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.62)],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.38),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(_difficultyIcon, color: Colors.white, size: 42),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _difficultyName.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_baseSettings.gridSizeText} Grid',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'HAMLE SEÇ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            shadows: [
              Shadow(color: AppColors.primaryDark, offset: Offset(2, 3), blurRadius: 5),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Doğru veya hatalı her kelime denemesi 1 hamle götürür.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.93),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMoveOption(int moves) {
    final selected = _selectedMoves == moves;
    final color = _moveColor(moves);
    final recommended = moves == _baseSettings.totalMoves;

    return GestureDetector(
      onTap: () => setState(() => _selectedMoves = moves),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutBack,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        transform: Matrix4.identity()..scale(selected ? 1.015 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [Colors.white, color.withValues(alpha: 0.18)]
                : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.88)],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.9),
            width: selected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? color.withValues(alpha: 0.38) : Colors.black.withValues(alpha: 0.08),
              blurRadius: selected ? 18 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selected
                      ? [color, color.withValues(alpha: 0.62)]
                      : [color.withValues(alpha: 0.18), color.withValues(alpha: 0.08)],
                ),
                shape: BoxShape.circle,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '$moves',
                  style: TextStyle(
                    color: selected ? Colors.white : color,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    shadows: selected
                        ? const [Shadow(color: Colors.black26, offset: Offset(1, 2), blurRadius: 2)]
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _moveLabel(moves),
                    style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$moves hamle hakkı ile oyuna başla',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (recommended) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Bu grid için önerilen',
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? color : AppColors.textLight,
              size: 31,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Row(
      children: [
        Expanded(child: _infoBox(icon: Icons.grid_4x4_rounded, label: 'GRID', value: _baseSettings.gridSizeText)),
        const SizedBox(width: 10),
        Expanded(child: _infoBox(icon: Icons.touch_app_rounded, label: 'SEÇİLEN', value: '$_selectedMoves')),
        const SizedBox(width: 10),
        Expanded(child: _infoBox(icon: Icons.star_rounded, label: 'HEDEF', value: 'Yüksek Puan')),
      ],
    );
  }

  Widget _infoBox({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 1),
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 3),
          Text(value, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildStartButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: color.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 34),
            const SizedBox(width: 10),
            Text(
              '$_selectedMoves HAMLE İLE BAŞLA',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.1),
            ),
          ],
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 12, offset: const Offset(0, 5))],
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
            Positioned(top: 88, right: -28, child: _blob(AppColors.secondary, 96)),
            Positioned(top: 260, left: -38, child: _blob(AppColors.accent, 108)),
            Positioned(bottom: 90, right: -44, child: _blob(AppColors.success, 124)),
          ],
        ),
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.16)),
    );
  }
}


