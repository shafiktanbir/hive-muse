import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/navigation_provider.dart';
import '../widgets/circular_player_dial.dart';
import '../widgets/audio_visualizer.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    final song = audioProvider.currentSong ?? playlistProvider.allSongs.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Album Image with Blur Filter & Bokeh Overlay
          Positioned.fill(
            child: Image.network(
              song.coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.surface),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                color: AppColors.background.withOpacity(0.75),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 24),
                        ),
                        onPressed: () => navProvider.collapsePlayer(),
                      ),

                      Column(
                        children: [
                          const Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.album,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // More Options Menu Button
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary, size: 20),
                        ),
                        onPressed: () {
                          _showOptionsModal(context, song, playlistProvider);
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Song Title & Artist Display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      Text(
                        song.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song.artist,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Equalizer Visualizer
                AudioVisualizer(
                  amplitudes: audioProvider.visualizerData,
                  isPlaying: audioProvider.isPlaying,
                ),

                const Spacer(),

                // Signature Circular Rotary Vinyl Dial Control
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0),
                  child: CircularPlayerDial(
                    position: audioProvider.position,
                    duration: audioProvider.duration,
                    isPlaying: audioProvider.isPlaying,
                    isFavorite: song.isFavorite,
                    onPlayPause: () => audioProvider.togglePlayPause(),
                    onFavoriteToggle: () => playlistProvider.toggleFavorite(song.id),
                    onSeek: (newPos) => audioProvider.seek(newPos),
                  ),
                ),

                const Spacer(),

                // Bottom Controls Bar: Shuffle, Prev, Next, Repeat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle Button
                      IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: audioProvider.isShuffle ? AppColors.neonLime : AppColors.textSecondary,
                          size: 24,
                        ),
                        onPressed: () => audioProvider.toggleShuffle(),
                      ),

                      // Previous Track
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          color: AppColors.textPrimary,
                          size: 36,
                        ),
                        onPressed: () {
                          final prev = audioProvider.isShuffle
                              ? playlistProvider.getRandomSong()
                              : playlistProvider.getPreviousSong(song);
                          audioProvider.playSong(prev);
                        },
                      ),

                      // Next Track
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.textPrimary,
                          size: 36,
                        ),
                        onPressed: () {
                          final next = audioProvider.isShuffle
                              ? playlistProvider.getRandomSong()
                              : playlistProvider.getNextSong(song);
                          audioProvider.playSong(next);
                        },
                      ),

                      // Repeat Mode Button
                      IconButton(
                        icon: Icon(
                          audioProvider.repeatMode == AudioRepeatMode.repeatOne
                              ? Icons.repeat_one_rounded
                              : Icons.repeat_rounded,
                          color: audioProvider.repeatMode != AudioRepeatMode.off
                              ? AppColors.neonLime
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                        onPressed: () => audioProvider.toggleRepeat(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsModal(BuildContext context, song, PlaylistProvider playlistProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  song.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.neonLime,
                ),
                title: Text(
                  song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  playlistProvider.toggleFavorite(song.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: AppColors.neonLime),
                title: const Text('Add to Queue', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: AppColors.neonLime),
                title: const Text('Share Song', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
