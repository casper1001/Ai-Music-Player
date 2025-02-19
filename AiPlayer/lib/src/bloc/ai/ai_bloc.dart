import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:AiPlayer/src/data/repositories/ai_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:AiPlayer/src/data/models/custom_song_model.dart';


abstract class AIEvent {}

class LoadModelsEvent extends AIEvent {}

class RecognizeSongEvent extends AIEvent {
  final List<double> audioData;
  RecognizeSongEvent(this.audioData);
}

class ClassifySongsByGenreEvent extends AIEvent {
  final List<CustomSongModel> songs;
  ClassifySongsByGenreEvent(this.songs);
}

class GenerateLyricsEvent extends AIEvent {
  final CustomSongModel song;
  GenerateLyricsEvent(this.song);
}

class TranslateLyricsEvent extends AIEvent {
  final String lyrics;
  TranslateLyricsEvent(this.lyrics);
}

// States
abstract class AIState {}

class AIModelsLoading extends AIState {}

class AIModelsLoaded extends AIState {}

class SongRecognized extends AIState {
  final String songTitle;
  SongRecognized(this.songTitle);
}

class GenresClassified extends AIState {
  final Map<String, List<CustomSongModel>> classifiedGenres;
  GenresClassified(this.classifiedGenres);
}

class LyricsGenerated extends AIState {
  final String lyrics;
  LyricsGenerated(this.lyrics);
}

class LyricsTranslated extends AIState {
  final String translatedLyrics;
  LyricsTranslated(this.translatedLyrics);
}

class AIError extends AIState {
  final String message;
  AIError(this.message);
}

// Bloc
class AIBloc extends Bloc<AIEvent, AIState> {
  final AIRepository aiRepository;

  AIBloc(this.aiRepository) : super(AIModelsLoading()) {
    on<LoadModelsEvent>(_onLoadModels);
    on<RecognizeSongEvent>(_onRecognizeSong);
    on<ClassifySongsByGenreEvent>(_onClassifySongsByGenre);
    on<GenerateLyricsEvent>(_onGenerateLyrics);
    on<TranslateLyricsEvent>(_onTranslateLyrics);
  }

  void _onLoadModels(LoadModelsEvent event, Emitter<AIState> emit) async {
    try {
      await aiRepository.loadModels();
      emit(AIModelsLoaded());
    } catch (e) {
      emit(AIError('Failed to load models: $e'));
    }
  }

  void _onRecognizeSong(RecognizeSongEvent event, Emitter<AIState> emit) async {
    try {
      final uri = Uri.parse('http://192.168.1.107:8000/api/song_identification/');
      var songTitle = await aiRepository.recognizeSong(event.audioData as Uint8List);
      emit(SongRecognized(songTitle));
    } catch (e) {
      emit(AIError('Failed to recognize song: $e'));
    }
  }

  void _onClassifySongsByGenre(ClassifySongsByGenreEvent event, Emitter<AIState> emit) async {
    try {


      var classifiedGenres = await aiRepository.classifySongsByGenre(event.songs);
      emit(GenresClassified(classifiedGenres));
    } catch (e) {
      emit(AIError('Failed to classify songs by genre: $e'));
    }
  }

  void _onGenerateLyrics(GenerateLyricsEvent event, Emitter<AIState> emit) async {
    try {

      final lyrics = await aiRepository.generateLyrics(event.song as SongModel);
      emit(LyricsGenerated(lyrics));
    } catch (e) {
      emit(AIError('Failed to generate lyrics: $e'));
    }
  }

  void _onTranslateLyrics(TranslateLyricsEvent event, Emitter<AIState> emit) async {
    try {

      final translatedLyrics = await aiRepository.translateLyrics(event.lyrics);
      emit(LyricsTranslated(translatedLyrics));
    } catch (e) {
      emit(AIError('Failed to translate lyrics: $e'));
    }
  }
}