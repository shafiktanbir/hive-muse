import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';

class CircularPlayerDial extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback onPlayPause;
  final VoidCallback onFavoriteToggle;
  final ValueChanged<Duration> onSeek;

  const CircularPlayerDial({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isFavorite,
    required this.onPlayPause,
    required this.onFavoriteToggle,
    required this.onSeek,
  });

  @override
  State<CircularPlayerDial> createState() => _CircularPlayerDialState();
}

class _CircularPlayerDialState extends State<CircularPlayerDial> {
  bool _isDragging = false;
  double _dragProgress = 0.0;

  double get currentRatio {
    if (_isDragging) return _dragProgress;
    if (widget.duration.inMilliseconds == 0) return 0.0;
    return (widget.position.inMilliseconds / widget.duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void _handlePanUpdate(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    
    // Angle in radians starting from top (-pi/2)
    double angle = atan2(dy, dx) + (pi / 2);
    if (angle < 0) {
      angle += 2 * pi;
    }

    final ratio = (angle / (2 * pi)).clamp(0.0, 1.0);
    setState(() {
      _isDragging = true;
      _dragProgress = ratio;
    });
  }

  void _handlePanEnd() {
    if (!_isDragging) return;
    final newMs = (widget.duration.inMilliseconds * _dragProgress).toInt();
    widget.onSeek(Duration(milliseconds: newMs));
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxWidth);
        return GestureDetector(
          onPanStart: (details) => _handlePanUpdate(details.localPosition, size),
          onPanUpdate: (details) => _handlePanUpdate(details.localPosition, size),
          onPanEnd: (_) => _handlePanEnd(),
          onTapDown: (details) {
            _handlePanUpdate(details.localPosition, size);
            _handlePanEnd();
          },
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxWidth,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom Painter Circular Rotary Dial
                CustomPaint(
                  size: size,
                  painter: _DialPainter(
                    progressRatio: currentRatio,
                    isPlaying: widget.isPlaying,
                  ),
                ),

                // Inner Center Section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Favorite Heart Toggle Button
                    IconButton(
                      icon: Icon(
                        widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: widget.isFavorite ? AppColors.neonLime : AppColors.textSecondary,
                        size: 26,
                      ),
                      onPressed: widget.onFavoriteToggle,
                    ),

                    const SizedBox(height: 4),

                    // Time display
                    Text(
                      '${Formatters.formatDuration(widget.position)} / ${Formatters.formatDuration(widget.duration)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Play / Pause Glowing Neon Button
                    GestureDetector(
                      onTap: widget.onPlayPause,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(
                            color: AppColors.neonLime,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonLime.withOpacity(widget.isPlaying ? 0.6 : 0.25),
                              blurRadius: widget.isPlaying ? 24 : 12,
                              spreadRadius: widget.isPlaying ? 4 : 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: AppColors.neonLime,
                          size: 38,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  final double progressRatio;
  final bool isPlaying;

  _DialPainter({
    required this.progressRatio,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;

    // 1. Background dark track ring
    final trackPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Subtle inner groove ring
    final groovePaint = Paint()
      ..color = AppColors.cardBgLight.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius - 14, groovePaint);

    // 2. Active Neon Lime Progress Arc
    final sweepAngle = 2 * pi * progressRatio;
    final startAngle = -pi / 2;

    final progressPaint = Paint()
      ..color = AppColors.neonLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // 3. Thumb Indicator Dot at active progress tip
    if (sweepAngle > 0) {
      final thumbAngle = startAngle + sweepAngle;
      final thumbCenter = Offset(
        center.dx + radius * cos(thumbAngle),
        center.dy + radius * sin(thumbAngle),
      );

      final thumbGlowPaint = Paint()
        ..color = AppColors.neonLime.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(thumbCenter, 12, thumbGlowPaint);

      final thumbPaint = Paint()..color = Colors.white;
      canvas.drawCircle(thumbCenter, 7, thumbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.progressRatio != progressRatio || oldDelegate.isPlaying != isPlaying;
  }
}
