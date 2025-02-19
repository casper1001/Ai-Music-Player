import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:AiPlayer/src/app.dart';
import 'package:AiPlayer/src/bloc/favorites/favorites_bloc.dart';
import 'package:AiPlayer/src/bloc/home/home_bloc.dart';
import 'package:AiPlayer/src/bloc/player/player_bloc.dart';
import 'package:AiPlayer/src/bloc/playlists/playlists_cubit.dart';
import 'package:AiPlayer/src/bloc/recents/recents_bloc.dart';
import 'package:AiPlayer/src/bloc/scan/scan_cubit.dart';
import 'package:AiPlayer/src/bloc/search/search_bloc.dart';
import 'package:AiPlayer/src/bloc/song/song_bloc.dart';
import 'package:AiPlayer/src/bloc/theme/theme_bloc.dart';
import 'package:AiPlayer/src/core/di/service_locator.dart';
import 'package:AiPlayer/src/data/repositories/player_repository.dart';
import 'package:AiPlayer/src/data/services/hive_box.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();


  init();


  if (!await Permission.mediaLibrary.isGranted) {
    await Permission.mediaLibrary.request();
  }


  await Hive.initFlutter();
  await Hive.openBox(HiveBox.boxName);


  await sl<MusicPlayer>().init();


  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<HomeBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<ThemeBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<SongBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<FavoritesBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<PlayerBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<RecentsBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<SearchBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<ScanCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<PlaylistsCubit>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
