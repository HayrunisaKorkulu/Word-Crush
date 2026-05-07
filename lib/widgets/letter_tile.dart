import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/letter_tile_model.dart';

class LetterTileWidget extends StatefulWidget {
  final LetterTile tile;
  final double size;

  const LetterTileWidget({
    super.key,
    required this.tile,
    required this.size,
  });

  @override
  State<LetterTileWidget> createState() => _LetterTileWidgetState();
}

class _LetterTileWidgetState extends State<LetterTileWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    if (_hasPower) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LetterTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_hasPower && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!_hasPower && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _hasPower => widget.tile.power != SpecialPower.none;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final tile = widget.tile;
        final size = widget.size;
        final isSelected = tile.isSelected;
        final hasPower = _hasPower;
        final isExploding = tile.isExploding;

        final pulse = hasPower ? math.sin(_pulseController.value * math.pi) : 0.0;
        final scale = isExploding
            ? 1.20
            : isSelected
                ? 1.10
                : hasPower
                    ? 1.0 + pulse * 0.045
                    : 1.0;

        final glowColor = hasPower
            ? Colors.orange
            : isSelected
                ? AppColors.tileBgSelected
                : Colors.black;

        return AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: tile.isEmpty ? 0.0 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              margin: EdgeInsets.all(size * 0.045),
              decoration: BoxDecoration(
                gradient: _tileGradient(isSelected, hasPower, isExploding),
                borderRadius: BorderRadius.circular(size * 0.18),
                border: Border.all(
                  color: isSelected || hasPower ? Colors.white : AppColors.tileBorder,
                  width: isSelected || hasPower ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(
                      alpha: hasPower
                          ? 0.38 + pulse * 0.30
                          : isSelected
                              ? 0.36
                              : 0.18,
                    ),
                    blurRadius: hasPower ? 12 + pulse * 8 : isSelected ? 12 : 5,
                    spreadRadius: hasPower ? 1.5 + pulse * 1.5 : 0,
                    offset: Offset(0, isSelected ? 6 : 3),
                  ),
                  if (!isSelected && !hasPower)
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.42),
                      blurRadius: 4,
                      offset: const Offset(-1, -2),
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  
                  Positioned(
                    top: size * 0.07,
                    left: size * 0.10,
                    right: size * 0.10,
                    height: size * 0.18,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: hasPower ? 0.55 : 0.48),
                            Colors.white.withValues(alpha: 0.04),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (hasPower)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size * 0.18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22 + pulse * 0.30),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                  Text(
                    tile.letter,
                    style: TextStyle(
                      fontSize: size * 0.50,
                      fontWeight: FontWeight.w900,
                      color: hasPower || isSelected ? Colors.white : AppColors.tileText,
                      shadows: hasPower || isSelected
                          ? const [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 2),
                                blurRadius: 3,
                              ),
                            ]
                          : const [
                              Shadow(
                                color: Colors.white54,
                                offset: Offset(0, 1),
                                blurRadius: 1,
                              ),
                            ],
                    ),
                  ),

                  if (!tile.isEmpty)
                    Positioned(
                      right: size * 0.08,
                      bottom: size * 0.05,
                      child: Text(
                        '${tile.points}',
                        style: TextStyle(
                          fontSize: size * 0.17,
                          fontWeight: FontWeight.w900,
                          color: hasPower || isSelected
                              ? Colors.white.withValues(alpha: 0.96)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),

                  if (hasPower) _buildPowerBadge(tile, size, pulse),

                  if (isExploding)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size * 0.18),
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _tileGradient(bool isSelected, bool hasPower, bool isExploding) {
    if (isExploding) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFFFD93D), Color(0xFFFF6B6B)],
      );
    }

    if (hasPower) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF176), Color(0xFFFFB300), Color(0xFFFF7043)],
      );
    }

    if (isSelected) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFC36B), Color(0xFFFF8A3D)],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFF7C9), Color(0xFFFFD98A)],
    );
  }

  Widget _buildPowerBadge(LetterTile tile, double size, double pulse) {
    return Positioned(
      left: size * 0.035,
      top: size * 0.035,
      child: Container(
        width: size * 0.35,
        height: size * 0.35,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.32 + pulse * 0.28),
              blurRadius: 5 + pulse * 6,
              spreadRadius: pulse,
            ),
          ],
        ),
        child: Center(
          child: Text(
            tile.powerSymbol,
            style: TextStyle(
              fontSize: size * 0.18,
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}



