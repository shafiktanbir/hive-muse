import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/playlist_provider.dart';
import '../widgets/floating_bottom_nav.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'player_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final audioProvider = Provider.of<AudioPlayerProvider>(context);
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    final currentSong = audioProvider.currentSong;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Active Screen Tab View
          IndexedStack(
            index: navProvider.currentIndex,
            children: _screens,
          ),

          // Mini Player Bar (Floating above Bottom Nav)
          if (currentSong != null && !navProvider.isPlayerExpanded)
            Positioned(
              left: 20,
              right: 20,
              bottom: 94,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => navProvider.expandPlayer(),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.neonLime, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonLime.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Song Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          currentSong.coverUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40,
                            height: 40,
                            color: AppColors.cardBg,
                            child: const Icon(Icons.music_note, color: AppColors.neonLime, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Song Title & Artist
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              currentSong.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Play/Pause Mini Toggle Button
                      IconButton(
                        icon: Icon(
                          audioProvider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: AppColors.neonLime,
                          size: 36,
                        ),
                        onPressed: () => audioProvider.togglePlayPause(),
                      ),

                      // Next Track Button
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.textPrimary,
                          size: 26,
                        ),
                        onPressed: () {
                          final next = playlistProvider.getNextSong(currentSong);
                          audioProvider.playSong(next);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating Bottom Navigation Bar
          if (!navProvider.isPlayerExpanded)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingBottomNav(
                currentIndex: navProvider.currentIndex,
                onTap: (index) => navProvider.setIndex(index),
              ),
            ),

          // Fullscreen Interactive Player Screen Animated Overlay
          if (navProvider.isPlayerExpanded)
            const Positioned.fill(
              child: PlayerScreen(),
            ),
        ],
      ),
    );
  }
}
