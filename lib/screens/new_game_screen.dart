import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'move_selection_screen.dart';


class NewGameScreen extends StatelessWidget {
  const NewGameScreen({super.key});

  void _selectDifficulty(BuildContext context, Difficulty difficulty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MoveSelectionScreen(difficulty: difficulty),
      ),
    );
  }

  String _difficultyTitle(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'KOLAY';
      case Difficulty.medium:
        return 'ORTA';
      case Difficulty.hard:
        return 'ZOR';
    }
  }

  String _gridText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '10 x 10 Grid';
      case Difficulty.medium:
        return '8 x 8 Grid';
      case Difficulty.hard:
        return '6 x 6 Grid';
    }
  }

  String _difficultyDescription(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Geniş alan, daha rahat kelime bulma.';
      case Difficulty.medium:
        return 'Dengeli zorluk ve stratejik seçimler.';
      case Difficulty.hard:
        return 'Küçük grid, az hamle, yüksek dikkat.';
    }
  }

  Color _difficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.hard:
        return AppColors.accent;
    }
  }

  IconData _difficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_very_satisfied_rounded;
      case Difficulty.medium:
        return Icons.psychology_alt_rounded;
      case Difficulty.hard:
        return Icons.local_fire_department_rounded;
    }
  }

  int _movesForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppConstants.movesEasy;
      case Difficulty.medium:
        return AppConstants.movesMedium;
      case Difficulty.hard:
        return AppConstants.movesHard;
    }
  }

  int _gridSizeForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppConstants.gridSizeEasy;
      case Difficulty.medium:
        return AppConstants.gridSizeMedium;
      case Difficulty.hard:
        return AppConstants.gridSizeHard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: _SelectionBackground()),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 10),
                  _buildHeader(),
                  const SizedBox(height: 22),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: [
                        _buildDifficultyCard(context, Difficulty.hard),
                        const SizedBox(height: 16),
                        _buildDifficultyCard(context, Difficulty.medium),
                        const SizedBox(height: 16),
                        _buildDifficultyCard(context, Difficulty.easy),
                      ],
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

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.72), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
            ),
            child: const Text(
              '1 / 2',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.grid_view_rounded, color: AppColors.primary.withValues(alpha: 0.95), size: 42),
              Positioned(
                right: 19,
                top: 20,
                child: Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 17),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'GRID SEÇ',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [
              Shadow(color: AppColors.primaryDark, offset: Offset(2, 3), blurRadius: 5),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Oyun alanını ve zorluk seviyeni belirle',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.93),
            fontWeight: FontWeight.w700,
            shadows: const [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(BuildContext context, Difficulty difficulty) {
    final color = _difficultyColor(difficulty);
    final title = _difficultyTitle(difficulty);
    final gridText = _gridText(difficulty);
    final description = _difficultyDescription(difficulty);
    final moves = _movesForDifficulty(difficulty);
    final gridSize = _gridSizeForDifficulty(difficulty);

    return GestureDetector(
      onTap: () => _selectDifficulty(context, difficulty),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, color.withValues(alpha: 0.09)],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withValues(alpha: 0.82), width: 2.3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.30),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _difficultyBadge(difficulty, color),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Icon(Icons.auto_awesome_rounded, color: color.withValues(alpha: 0.75), size: 17),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gridText,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _miniBadge(Icons.grid_4x4_rounded, '$gridSize x $gridSize', color),
                      _miniBadge(Icons.touch_app_rounded, '$moves Hamle', color),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _difficultyBadge(Difficulty difficulty, Color color) {
    return Container(
      width: 78,
      height: 88,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.65)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.36),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(_difficultyIcon(difficulty), color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _miniBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionBackground extends StatelessWidget {
  const _SelectionBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        _SoftOrb(left: -60, top: 70, size: 180, color: Colors.white),
        _SoftOrb(right: -70, top: 250, size: 200, color: Color(0xFFFFD93D)),
        _SoftOrb(left: 40, bottom: -90, size: 220, color: Color(0xFF6C5CE7)),
        _TinyCandy(left: 28, top: 150, color: Color(0xFFFF6B6B), icon: Icons.favorite_rounded),
        _TinyCandy(right: 32, bottom: 150, color: Color(0xFF00B894), icon: Icons.star_rounded),
      ],
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;
  final Color color;

  const _SoftOrb({this.left, this.right, this.top, this.bottom, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.13),
        ),
      ),
    );
  }
}

class _TinyCandy extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final Color color;
  final IconData icon;

  const _TinyCandy({this.left, this.right, this.top, this.bottom, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: math.pi / 10,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.42), size: 24),
        ),
      ),
    );
  }
}



