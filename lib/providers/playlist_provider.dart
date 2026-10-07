import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/song.dart';
import '../domain/models/category.dart';

class PlaylistProvider extends ChangeNotifier {
  static const String _favStorageKey = 'hive_muse_favorites';

  List<Song> _allSongs = [];
  final List<Song> _userUploadedSongs = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  Set<String> _favoriteIds = {};

  final List<MusicCategory> _categories = const [
    MusicCategory(id: 'All', name: 'All', icon: Icons.music_note),
    MusicCategory(id: 'Party', name: 'Party', icon: Icons.nightlife),
    MusicCategory(id: 'Blues', name: 'Blues', icon: Icons.waves),
    MusicCategory(id: 'Sad', name: 'Sad', icon: Icons.cloud),
    MusicCategory(id: 'Hip Hop', name: 'Hip Hop', icon: Icons.graphic_eq),
    MusicCategory(id: 'Lofi', name: 'Lofi', icon: Icons.headphones),
  ];

  List<MusicCategory> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  PlaylistProvider() {
    _initDemoSongs();
    _loadFavorites();
  }

  void _initDemoSongs() {
    _allSongs = [
      const Song(
        id: '1',
        title: 'Jazz Concert',
        artist: 'The Weeknd',
        album: 'Acoustic Sessions',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        duration: Duration(minutes: 3, seconds: 18),
        coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop&q=80',
        category: 'Blues',
      ),
      const Song(
        id: '2',
        title: 'Festival Anthem',
        artist: 'Music Beats',
        album: 'Live Performance',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        duration: Duration(minutes: 4, seconds: 12),
        coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&auto=format&fit=crop&q=80',
        category: 'Party',
      ),
      const Song(
        id: '3',
        title: 'Performance Wave',
        artist: 'Harmony Wave',
        album: 'Sonic Horizons',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        duration: Duration(minutes: 3, seconds: 45),
        coverUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&auto=format&fit=crop&q=80',
        category: 'Hip Hop',
      ),
      const Song(
        id: '4',
        title: 'Top Songs Global',
        artist: 'Drake ft. Future',
        album: 'Chart Toppers',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        duration: Duration(minutes: 3, seconds: 50),
        coverUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=600&auto=format&fit=crop&q=80',
        category: 'Hip Hop',
      ),
      const Song(
        id: '5',
        title: 'Midnight Chill',
        artist: 'Charki XCX',
        album: 'Club Classics',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        duration: Duration(minutes: 2, seconds: 58),
        coverUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80',
        category: 'Lofi',
      ),
      const Song(
        id: '6',
        title: 'Rainy Night Melancholy',
        artist: 'Acoustic Soul',
        album: 'Silent Beats',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        duration: Duration(minutes: 4, seconds: 05),
        coverUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=600&auto=format&fit=crop&q=80',
        category: 'Sad',
      ),
      const Song(
        id: '7',
        title: 'Cyberpunk Grooves',
        artist: 'Neon Synthetics',
        album: 'Future City',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        duration: Duration(minutes: 3, seconds: 33),
        coverUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=600&auto=format&fit=crop&q=80',
        category: 'Party',
      ),
    ];
    notifyListeners();
  }

  List<Song> get allSongs => [..._allSongs, ..._userUploadedSongs];

  List<Song> get filteredSongs {
    return allSongs.where((song) {
      final matchesCategory = (_selectedCategory == 'All') || (song.category == _selectedCategory);
      final matchesSearch = song.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          song.artist.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).map((s) => s.copyWith(isFavorite: _favoriteIds.contains(s.id))).toList();
  }

  List<Song> get favoriteSongs {
    return allSongs
        .where((song) => _favoriteIds.contains(song.id))
        .map((s) => s.copyWith(isFavorite: true))
        .toList();
  }

  List<Song> get popularSongs => filteredSongs.take(4).toList();
  List<Song> get newCollections => filteredSongs.skip(2).toList();

  void selectCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleFavorite(String songId) async {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
    } else {
      _favoriteIds.add(songId);
    }
    notifyListeners();
    _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_favStorageKey);
      if (saved != null) {
        _favoriteIds = saved.toSet();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favStorageKey, _favoriteIds.toList());
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  Future<bool> pickAndAddCustomMp3() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final newSong = Song(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          title: file.name.replaceAll('.mp3', '').replaceAll('.wav', ''),
          artist: 'Local Track',
          album: 'My Uploads',
          audioUrl: file.name,
          duration: const Duration(minutes: 3, seconds: 30),
          coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&auto=format&fit=crop&q=80',
          category: 'Party',
          isLocalFile: true,
          bytes: file.bytes,
        );
        _userUploadedSongs.add(newSong);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error picking MP3 file: $e');
    }
    return false;
  }

  Song getNextSong(Song currentSong) {
    final list = filteredSongs;
    if (list.isEmpty) return currentSong;
    final index = list.indexWhere((s) => s.id == currentSong.id);
    if (index == -1 || index == list.length - 1) {
      return list.first;
    }
    return list[index + 1];
  }

  Song getPreviousSong(Song currentSong) {
    final list = filteredSongs;
    if (list.isEmpty) return currentSong;
    final index = list.indexWhere((s) => s.id == currentSong.id);
    if (index <= 0) {
      return list.last;
    }
    return list[index - 1];
  }

  Song getRandomSong() {
    final list = filteredSongs;
    if (list.isEmpty) return _allSongs.first;
    final random = Random();
    return list[random.nextInt(list.length)];
  }
}
