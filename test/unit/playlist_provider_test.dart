import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_muse/providers/playlist_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlaylistProvider Tests', () {
    late PlaylistProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = PlaylistProvider();
    });

    test('initializes with default demo songs and categories', () {
      expect(provider.categories.length, equals(6));
      expect(provider.allSongs.isNotEmpty, isTrue);
      expect(provider.selectedCategory, equals('All'));
    });

    test('selectCategory updates filtered songs correctly', () {
      provider.selectCategory('Blues');
      expect(provider.selectedCategory, equals('Blues'));
      expect(provider.filteredSongs.every((s) => s.category == 'Blues'), isTrue);
    });

    test('setSearchQuery filters songs by title or artist', () {
      provider.setSearchQuery('Tours');
      expect(provider.filteredSongs.isNotEmpty, isTrue);
      expect(provider.filteredSongs.first.artist, equals('Tours'));
    });

    test('toggleFavorite adds and removes favorite song IDs', () async {
      final songId = provider.allSongs.first.id;
      expect(provider.favoriteSongs.any((s) => s.id == songId), isFalse);

      await provider.toggleFavorite(songId);
      expect(provider.favoriteSongs.any((s) => s.id == songId), isTrue);

      await provider.toggleFavorite(songId);
      expect(provider.favoriteSongs.any((s) => s.id == songId), isFalse);
    });

    test('getNextSong and getPreviousSong navigate circular playlist', () {
      final songs = provider.filteredSongs;
      final first = songs.first;
      final second = songs[1];

      expect(provider.getNextSong(first).id, equals(second.id));
      expect(provider.getPreviousSong(second).id, equals(first.id));
      expect(provider.getPreviousSong(first).id, equals(songs.last.id));
    });
  });
}
