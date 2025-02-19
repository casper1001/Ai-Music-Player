class CustomSongModel {
  final int id;
  final String title;
  final String artist;
  final String? album;
  final String? genre;
  final String filePath;
  final int? duration;
  final int? releaseYear;
  final int? bitrate;

  CustomSongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.genre,
    required this.filePath,
    this.duration,
    this.releaseYear,
    this.bitrate,
  });

  // Convert CustomSongModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'genre': genre,
      'file_path': filePath,
      'duration': duration,
      'release_year': releaseYear,
      'bitrate': bitrate,
    };
  }


  factory CustomSongModel.fromJson(Map<String, dynamic> json) {
    return CustomSongModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      genre: json['genre'],
      filePath: json['file_path'],
      duration: json['duration'],
      releaseYear: json['release_year'],
      bitrate: json['bitrate'],
    );
  }
}