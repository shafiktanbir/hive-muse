import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_muse/providers/audio_player_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async {
        return 1;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async {
        return 1;
      },
    );
  });

  group('AudioPlayerProvider Tests', () {
    late AudioPlayerProvider provider;

    setUp(() {
      provider = AudioPlayerProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state values', () {
      expect(provider.currentSong, isNull);
      expect(provider.isPlaying, isFalse);
      expect(provider.volume, equals(1.0));
      expect(provider.isShuffle, isFalse);
      expect(provider.repeatMode, equals(AudioRepeatMode.off));
    });

    test('toggleShuffle updates shuffle state', () {
      provider.toggleShuffle();
      expect(provider.isShuffle, isTrue);
      provider.toggleShuffle();
      expect(provider.isShuffle, isFalse);
    });

    test('toggleRepeat cycles through repeat modes', () {
      expect(provider.repeatMode, equals(AudioRepeatMode.off));

      provider.toggleRepeat();
      expect(provider.repeatMode, equals(AudioRepeatMode.repeatAll));

      provider.toggleRepeat();
      expect(provider.repeatMode, equals(AudioRepeatMode.repeatOne));

      provider.toggleRepeat();
      expect(provider.repeatMode, equals(AudioRepeatMode.off));
    });

    test('setVolume clamps volume between 0.0 and 1.0', () async {
      await provider.setVolume(1.5);
      expect(provider.volume, equals(1.0));

      await provider.setVolume(-0.5);
      expect(provider.volume, equals(0.0));

      await provider.setVolume(0.7);
      expect(provider.volume, equals(0.7));
    });
  });
}
