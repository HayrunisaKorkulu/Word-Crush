import 'package:flutter/material.dart';
import '../models/letter_tile_model.dart';
import '../services/game_state.dart';
import 'letter_tile.dart';


class GridWidget extends StatefulWidget {
  final GameState gameState;
  final VoidCallback? onWordCompleted;

  const GridWidget({
    super.key,
    required this.gameState,
    this.onWordCompleted,
  });

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  double _tileSize = 0;
  Offset? _lastProcessedPosition;

  ({int row, int col})? _positionToCell(Offset position) {
    if (_tileSize == 0) return null;

    final size = widget.gameState.settings.gridSize;
    final col = (position.dx / _tileSize).floor();
    final row = (position.dy / _tileSize).floor();

    if (row < 0 || row >= size || col < 0 || col >= size) return null;

    final centerX = col * _tileSize + _tileSize / 2;
    final centerY = row * _tileSize + _tileSize / 2;
    final dx = (position.dx - centerX).abs();
    final dy = (position.dy - centerY).abs();

    final threshold = _tileSize * 0.43;
    if (dx > threshold || dy > threshold) return null;

    return (row: row, col: col);
  }

  void _selectCell(int row, int col) {
    final tile = widget.gameState.tileAt(row, col);
    if (tile != null) {
      widget.gameState.selectTile(tile);
    }
  }

  void _handlePan(Offset position) {
    final currentCell = _positionToCell(position);
    if (currentCell == null) return;

    if (widget.gameState.activeJoker != null) {
      final tile = widget.gameState.tileAt(currentCell.row, currentCell.col);
      if (tile != null && _lastProcessedPosition == null) {
        widget.gameState.selectJokerTarget(tile);
        _lastProcessedPosition = position;
      }
      return;
    }

    if (_lastProcessedPosition == null) {
      _selectCell(currentCell.row, currentCell.col);
      _lastProcessedPosition = position;
      return;
    }

    _scanLineBetween(_lastProcessedPosition!, position);
    _lastProcessedPosition = position;
  }

  void _scanLineBetween(Offset start, Offset end) {
    final distance = (end - start).distance;
    if (distance == 0) return;

    final stepCount = (distance / (_tileSize / 3)).ceil();
    if (stepCount == 0) return;

    int? lastRow;
    int? lastCol;

    for (int i = 0; i <= stepCount; i++) {
      final t = i / stepCount;
      final point = Offset(
        start.dx + (end.dx - start.dx) * t,
        start.dy + (end.dy - start.dy) * t,
      );

      final cell = _positionToCell(point);
      if (cell != null) {
        if (cell.row != lastRow || cell.col != lastCol) {
          _selectCell(cell.row, cell.col);
          lastRow = cell.row;
          lastCol = cell.col;
        }
      }
    }
  }

  void _handlePanEnd() {
    _lastProcessedPosition = null;
    if (widget.gameState.activeJoker == null) {
      widget.gameState.finalizeSelection();
      widget.onWordCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = constraints.maxWidth;
        _tileSize = gridSize / widget.gameState.settings.gridSize;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            _lastProcessedPosition = null;
            _handlePan(details.localPosition);
          },
          onPanUpdate: (details) => _handlePan(details.localPosition),
          onPanEnd: (_) => _handlePanEnd(),
          onPanCancel: () => _handlePanEnd(),
          onTapDown: (details) {
            _lastProcessedPosition = null;
            _handlePan(details.localPosition);
          },
          onTapUp: (_) => _handlePanEnd(),
          onTapCancel: () => _handlePanEnd(),
          child: SizedBox(
            width: gridSize,
            height: gridSize,
            child: Stack(
              children: [
                
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.26),
                        Colors.white.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),

                
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.2,
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                if (widget.gameState.selectedTiles.length >= 2)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConnectionLinePainter(
                        tiles: widget.gameState.selectedTiles,
                        tileSize: _tileSize,
                      ),
                    ),
                  ),

                Column(
                  children: List.generate(
                    widget.gameState.settings.gridSize,
                    (r) => Expanded(
                      child: Row(
                        children: List.generate(
                          widget.gameState.settings.gridSize,
                          (c) {
                            final tile = widget.gameState.grid[r][c];
                            return Expanded(
                              child: SizedBox(
                                height: _tileSize,
                                child: LetterTileWidget(
                                  tile: tile,
                                  size: _tileSize,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConnectionLinePainter extends CustomPainter {
  final List<LetterTile> tiles;
  final double tileSize;

  _ConnectionLinePainter({required this.tiles, required this.tileSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (tiles.length < 2) return;

    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final mainPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF176), Color(0xFFFF8A00)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final firstCenter = _centerOf(tiles.first);
    path.moveTo(firstCenter.dx, firstCenter.dy);

    for (int i = 1; i < tiles.length; i++) {
      final c = _centerOf(tiles[i]);
      path.lineTo(c.dx, c.dy);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, mainPaint);
  }

  Offset _centerOf(LetterTile tile) {
    return Offset(
      tile.col * tileSize + tileSize / 2,
      tile.row * tileSize + tileSize / 2,
    );
  }

  @override
  bool shouldRepaint(covariant _ConnectionLinePainter oldDelegate) {
    return tiles != oldDelegate.tiles || tileSize != oldDelegate.tileSize;
  }
}




