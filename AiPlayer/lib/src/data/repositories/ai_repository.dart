import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:AiPlayer/src/data/models/custom_song_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AIRepository {
  static const String _baseUrl = 'http://192.168.1.107:8000/api/';// Replace with django backend URL

  Future<void> loadModels() async {
    // Call your Django backend API to load models
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/load-models/'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load models: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load models: $e');
    }
  }


  Future<String> recognizeSong(Uint8List audioData) async {
    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/recognize_mic/'),
      );


      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioData as List<int>,
          filename: 'mic_audio.wav',
        ),
      );


      var response = await request.send();


      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return data['song_name']; // Assuming your API returns a JSON with 'song_name'
      } else {
        throw Exception('Failed to recognize song: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to recognize song: $e');
    }
  }


  CustomSongModel _mapToCustomSongModel(SongModel song) {
    return CustomSongModel(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown',
      album: song.album,
      genre: song.genre,
      filePath: song.data,
      duration: song.duration,
      releaseYear: null,
      bitrate: null,
    );
  }

  Future<Map<String, List<CustomSongModel>>> classifySongsByGenre(List<CustomSongModel> songs) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/song_classification/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'songs': songs.map((song) => song.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, List<CustomSongModel>> classifiedGenres = {};


        data.forEach((genre, songList) {
          classifiedGenres[genre] = (songList as List)
              .map((songJson) => CustomSongModel.fromJson(songJson))
              .toList();
        });

        return classifiedGenres;
      } else {
        throw Exception('Failed to classify songs by genre: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to classify songs by genre: $e');
    }
  }




  Future<String> generateLyrics(SongModel song) async {
    try {

      final customSong = _mapToCustomSongModel(song);

      final response = await http.post(
        Uri.parse('$_baseUrl/lyrics-generation/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'song_id': customSong.id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['lyrics'];
      } else {
        throw Exception('Failed to generate lyrics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate lyrics: $e');
    }
  }

  Future<String> translateLyrics(String lyrics) async {

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/lyrics-translation/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'lyrics': lyrics}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_lyrics'];
      } else {
        throw Exception('Failed to translate lyrics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to translate lyrics: $e');
    }
  }
}