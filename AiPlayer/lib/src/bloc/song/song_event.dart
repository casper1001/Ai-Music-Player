part of 'song_bloc.dart';

@immutable
sealed class SongEvent {}


class ToggleFavorite extends SongEvent {
  final String songId;

  ToggleFavorite(this.songId);
}


class AddToRecentlyPlayed extends SongEvent {
  final String songId;

  AddToRecentlyPlayed(this.songId);
}
