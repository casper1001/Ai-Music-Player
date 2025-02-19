import 'package:hive/hive.dart';
import 'package:AiPlayer/src/core/di/service_locator.dart';
import 'package:AiPlayer/src/data/services/hive_box.dart';
import 'package:on_audio_query/on_audio_query.dart';

class HomeRepository {
  final OnAudioQuery _audioQuery = sl<OnAudioQuery>();
  final Box<dynamic> _box = Hive.box(HiveBox.boxName);

  Future<List<SongModel>> getSongs() async {

    var songs = await _audioQuery.querySongs(
      sortType: SongSortType.values[_box.get(
        HiveBox.songSortTypeKey,
        defaultValue: SongSortType.TITLE.index,
      )],
      orderType: OrderType.values[_box.get(
        HiveBox.songOrderTypeKey,
        defaultValue: OrderType.ASC_OR_SMALLER.index,
      )],
    );


    songs.removeWhere((song) {
      return (song.duration ?? 0) <
              _box.get(HiveBox.minSongDurationKey, defaultValue: 0) * 1000 ||
          (song.size) <
              _box.get(HiveBox.minSongSizeKey, defaultValue: 0) * 1024;
    });

    return songs;
  }

  Future<List<ArtistModel>> getArtists() async {
    return await _audioQuery.queryArtists();
  }

  Future<List<AlbumModel>> getAlbums() async {
    return await _audioQuery.queryAlbums();
  }

  Future<List<GenreModel>> getGenres() async {
    return await _audioQuery.queryGenres();
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    return await _audioQuery.queryPlaylists();
  }

  Future<void> sortSongs(int songSortType, int orderType) async {
    await _box.put(HiveBox.songSortTypeKey, songSortType);
    await _box.put(HiveBox.songOrderTypeKey, orderType);
  }
}
