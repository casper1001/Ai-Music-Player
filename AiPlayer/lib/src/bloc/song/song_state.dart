part of 'song_bloc.dart';

@immutable
sealed class SongState {}

final class PlayerInitial extends SongState {}


final class ToggleFavoriteInProgress extends SongState {}

final class ToggleFavoriteSuccess extends SongState {}

final class ToggleFavoriteFailure extends SongState {}


final class AddToRecentlyPlayedInProgress extends SongState {}

final class AddToRecentlyPlayedSuccess extends SongState {}

final class AddToRecentlyPlayedError extends SongState {}
