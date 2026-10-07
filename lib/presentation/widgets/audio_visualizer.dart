import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AudioVisualizer extends StatelessWidget {
  final List<double> amplitudes;
  final bool isPlaying;

  const AudioVisualizer({
    super.key,
    required this.amplitudes,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(amplitudes.length, (index) {
          final heightRatio = isPlaying ? amplitudes[index] : 0.15;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: 3.5,
            height: (heightRatio * 32).clamp(4.0, 32.0),
            decoration: BoxDecoration(
              color: isPlaying ? AppColors.neonLime : AppColors.textMuted,
              borderRadius: BorderRadius.circular(3),
              boxShadow: isPlaying
                  ? [
                      BoxShadow(
                        color: AppColors.neonLime.withOpacity(0.4),
                        blurRadius: 4,
                      )
                    ]
                  : [],
            ),
          );
        }),
      ),
    );
  }
}
