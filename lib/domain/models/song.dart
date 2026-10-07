import 'dart:typed_data';

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String audioUrl;
  final Duration duration;
  final String coverUrl;
  final String category;
  final bool isFavorite;
  final bool isLocalFile;
  final Uint8List? bytes;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.audioUrl,
    required this.duration,
    required this.coverUrl,
    required this.category,
    this.isFavorite = false,
    this.isLocalFile = false,
    this.bytes,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? audioUrl,
    Duration? duration,
    String? coverUrl,
    String? category,
    bool? isFavorite,
    bool? isLocalFile,
    Uint8List? bytes,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      coverUrl: coverUrl ?? this.coverUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocalFile: isLocalFile ?? this.isLocalFile,
      bytes: bytes ?? this.bytes,
    );
  }
}
