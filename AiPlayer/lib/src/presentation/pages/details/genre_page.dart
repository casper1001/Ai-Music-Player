import 'package:flutter/material.dart';
import 'package:AiPlayer/src/core/di/service_locator.dart';
import 'package:AiPlayer/src/core/theme/themes.dart';
import 'package:AiPlayer/src/presentation/widgets/player_bottom_app_bar.dart';
import 'package:AiPlayer/src/presentation/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../data/models/custom_song_model.dart';

class GenrePage extends StatelessWidget {
  final String genre;
  final List<CustomSongModel> songs;

  const GenrePage({
    super.key,
    required this.genre,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(genre),
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            title: Text(song.title),
            subtitle: Text(song.artist),
          );
        },
      ),
    );
  }
}