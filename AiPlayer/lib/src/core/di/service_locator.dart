import 'package:get_it/get_it.dart';
import 'package:AiPlayer/src/bloc/playlists/playlists_cubit.dart';
import 'package:AiPlayer/src/bloc/favorites/favorites_bloc.dart';
import 'package:AiPlayer/src/bloc/home/home_bloc.dart';
import 'package:AiPlayer/src/bloc/player/player_bloc.dart';
import 'package:AiPlayer/src/bloc/recents/recents_bloc.dart';
import 'package:AiPlayer/src/bloc/scan/scan_cubit.dart';
import 'package:AiPlayer/src/bloc/search/search_bloc.dart';
import 'package:AiPlayer/src/bloc/song/song_bloc.dart';
import 'package:AiPlayer/src/bloc/theme/theme_bloc.dart';
import 'package:AiPlayer/src/bloc/ai/ai_bloc.dart';
import 'package:AiPlayer/src/data/repositories/favorites_repository.dart';
import 'package:AiPlayer/src/data/repositories/home_repository.dart';
import 'package:AiPlayer/src/data/repositories/player_repository.dart';
import 'package:AiPlayer/src/data/repositories/recents_repository.dart';
import 'package:AiPlayer/src/data/repositories/search_repository.dart';
import 'package:AiPlayer/src/data/repositories/song_repository.dart';
import 'package:AiPlayer/src/data/repositories/theme_repository.dart';
import 'package:AiPlayer/src/data/repositories/ai_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

final sl = GetIt.instance;

void init() {
  // Bloc
  sl.registerFactory(() => ThemeBloc(repository: sl()));
  sl.registerFactory(() => HomeBloc(repository: sl()));
  sl.registerFactory(() => PlayerBloc(repository: sl()));
  sl.registerFactory(() => SongBloc(repository: sl()));
  sl.registerFactory(() => FavoritesBloc(repository: sl()));
  sl.registerFactory(() => RecentsBloc(repository: sl()));
  sl.registerFactory(() => SearchBloc(repository: sl()));
  sl.registerFactory(() => AIBloc(sl()));


  sl.registerFactory(() => ScanCubit());
  sl.registerFactory(() => PlaylistsCubit());


  sl.registerLazySingleton(() => ThemeRepository());
  sl.registerLazySingleton(() => HomeRepository());
  sl.registerLazySingleton<MusicPlayer>(
        () => JustAudioPlayer(),
  );
  sl.registerLazySingleton(() => SongRepository());
  sl.registerLazySingleton(() => FavoritesRepository());
  sl.registerLazySingleton(() => RecentsRepository());
  sl.registerLazySingleton(() => SearchRepository());
  sl.registerLazySingleton(() => AIRepository());


  sl.registerLazySingleton(() => OnAudioQuery());
}