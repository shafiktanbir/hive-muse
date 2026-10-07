import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/navigation_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final audioProvider = Provider.of<AudioPlayerProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    final favs = playlistProvider.favoriteSongs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Favorites',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      '${favs.length} Songs',
                      style: const TextStyle(
                        color: AppColors.neonLime,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (favs.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No favorites added yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the heart icon on any song to save it here',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: favs.length,
                    itemBuilder: (context, index) {
                      final song = favs[index];
                      final isPlaying = (audioProvider.currentSong?.id == song.id && audioProvider.isPlaying);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: AppColors.cardBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isPlaying ? AppColors.neonLime : AppColors.glassBorder,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                          onTap: () {
                            audioProvider.playSong(song);
                            navProvider.expandPlayer();
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              song.coverUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                color: AppColors.surface,
                                child: const Icon(Icons.music_note, color: AppColors.neonLime),
                              ),
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: TextStyle(
                              color: isPlaying ? AppColors.neonLime : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            song.artist,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: AppColors.neonLime,
                              size: 20,
                            ),
                            onPressed: () => playlistProvider.toggleFavorite(song.id),
                          ),
                        ),
                      ),
                    );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
