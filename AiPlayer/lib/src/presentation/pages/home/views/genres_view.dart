import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:AiPlayer/src/bloc/ai/ai_bloc.dart';
import 'package:AiPlayer/src/core/router/app_router.dart';
import 'package:AiPlayer/src/core/di/service_locator.dart';
import 'package:AiPlayer/src/data/models/custom_song_model.dart';

class GenresView extends StatefulWidget {
  const GenresView({super.key});

  @override
  State<GenresView> createState() => _GenresViewState();
}

class _GenresViewState extends State<GenresView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final audioQuery = sl<OnAudioQuery>();
  final Map<String, List<CustomSongModel>> classifiedGenres = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSongsAndClassify();
  }

  Future<void> _fetchSongsAndClassify() async {
    try {

      List<SongModel> songs = await audioQuery.querySongs();


      songs.removeWhere((song) => (song.duration ?? 0) < 10000);


      final customSongs = songs.map((song) => _mapToCustomSongModel(song)).toList();


      context.read<AIBloc>().add(ClassifySongsByGenreEvent(customSongs));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<AIBloc, AIState>(
      listener: (context, state) {
        if (state is GenresClassified) {
          setState(() {
            classifiedGenres.clear();
            classifiedGenres.addAll(state.classifiedGenres);
            isLoading = false;
          });
        } else if (state is AIError) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: classifiedGenres.length,
          itemBuilder: (context, index) {
            final genre = classifiedGenres.keys.elementAt(index);
            final songs = classifiedGenres[genre]!;

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: FlipAnimation(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRouter.genreRoute,
                      arguments: {
                        'genre': genre,
                        'songs': songs,
                      },
                    );
                  },
                  leading: QueryArtworkWidget(
                    id: songs.first.id,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(10),
                    size: 10000,
                    nullArtworkWidget: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.music_note_outlined,
                      ),
                    ),
                  ),
                  title: Text(
                    genre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${songs.length} song${songs.length == 1 ? '' : 's'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}