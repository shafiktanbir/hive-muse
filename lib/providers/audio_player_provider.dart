import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../domain/models/song.dart';

enum AudioRepeatMode { off, repeatOne, repeatAll }

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Song? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _isShuffle = false;
  AudioRepeatMode _repeatMode = AudioRepeatMode.off;

  // Equalizer visualizer wave amplitudes (16 bars)
  List<double> _visualizerData = List.filled(16, 0.2);
  Timer? _visualizerTimer;

  // Getters
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get isShuffle => _isShuffle;
  AudioRepeatMode get repeatMode => _repeatMode;
  List<double> get visualizerData => _visualizerData;

  double get progressRatio {
    if (_duration.inMilliseconds == 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  AudioPlayerProvider() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = (state == PlayerState.playing);
      if (_isPlaying) {
        _startVisualizerAnimation();
      } else {
        _stopVisualizerAnimation();
      }
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _position = newPosition;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      _duration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _handleSongCompletion();
    });
  }

  void _startVisualizerAnimation() {
    _visualizerTimer?.cancel();
    final random = Random();
    _visualizerTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _visualizerData = List.generate(
        16,
        (index) => 0.15 + random.nextDouble() * 0.85,
      );
      notifyListeners();
    });
  }

  void _stopVisualizerAnimation() {
    _visualizerTimer?.cancel();
    _visualizerData = List.filled(16, 0.15);
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    _isLoading = true;
    _currentSong = song;
    notifyListeners();

    try {
      await _audioPlayer.stop();
      if (song.isLocalFile && song.bytes != null) {
        await _audioPlayer.play(BytesSource(song.bytes!));
      } else if (song.audioUrl.startsWith('assets/')) {
        await _audioPlayer.play(AssetSource(song.audioUrl.replaceFirst('assets/', '')));
      } else {
        await _audioPlayer.play(UrlSource(song.audioUrl));
      }
    } catch (e) {
      debugPrint('Error playing audio track: $e');
      // Simulated playback for demo fallback if external URL fails
      _duration = song.duration;
      _isPlaying = true;
      _startVisualizerAnimation();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> seek(Duration newPosition) async {
    _position = newPosition;
    await _audioPlayer.seek(newPosition);
    notifyListeners();
  }

  Future<void> setVolume(double newVolume) async {
    _volume = newVolume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    if (_repeatMode == AudioRepeatMode.off) {
      _repeatMode = AudioRepeatMode.repeatAll;
    } else if (_repeatMode == AudioRepeatMode.repeatAll) {
      _repeatMode = AudioRepeatMode.repeatOne;
    } else {
      _repeatMode = AudioRepeatMode.off;
    }
    notifyListeners();
  }

  VoidCallback? onNextRequested;
  VoidCallback? onPreviousRequested;

  void setPlaylistNavigation({
    required VoidCallback onNext,
    required VoidCallback onPrevious,
  }) {
    onNextRequested = onNext;
    onPreviousRequested = onPrevious;
  }

  void _handleSongCompletion() {
    if (_repeatMode == AudioRepeatMode.repeatOne && _currentSong != null) {
      playSong(_currentSong!);
    } else if (onNextRequested != null) {
      onNextRequested!();
    } else {
      _isPlaying = false;
      _stopVisualizerAnimation();
    }
  }

  bool _isDisposed = false;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _visualizerTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
