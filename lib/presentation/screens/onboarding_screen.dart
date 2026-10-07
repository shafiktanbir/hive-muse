import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Brand Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'HiveMuse',
                            style: TextStyle(
                              color: AppColors.neonLime,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: AppColors.neonLime.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Metallic Green Headphone Artwork Container
                      Center(
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.neonLime.withOpacity(0.2),
                                AppColors.surface.withOpacity(0.0),
                              ],
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Glowing Ring
                              Container(
                                width: 210,
                                height: 210,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.neonLime.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // Headphone Icon Illustration
                              const Icon(
                                Icons.headphones_rounded,
                                size: 140,
                                color: AppColors.neonLime,
                              ),
                              // Sound Wave Accents
                              Positioned(
                                left: 16,
                                child: Icon(Icons.graphic_eq, color: AppColors.neonLime.withOpacity(0.6), size: 24),
                              ),
                              Positioned(
                                right: 16,
                                child: Icon(Icons.graphic_eq, color: AppColors.neonLime.withOpacity(0.6), size: 24),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Title & Subtitle
                      const Text(
                        'Start Your\nSonic Journey',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Dive into a world of music — millions of songs, custom playlists, and every genre you love.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Bottom Action Buttons Row
                      Row(
                        children: [
                          // Primary Action Button "Turn on your music"
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => navProvider.completeOnboarding(),
                              child: Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: AppColors.glassBorder, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.neonLime,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.fast_forward_rounded,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                    const Text(
                                      'Turn on your music',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Headphone Button Icon
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.glassBorder, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.headphones_outlined,
                              color: AppColors.neonLime,
                              size: 24,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
