
from django.urls import path
from .views import (
    LoadModelsView,
    SongDetailView,
    LyricsGenerationView,
    SongClassificationView,
    SongRecognitionView,
    LyricsTranslationView,
    get_songs,
)

urlpatterns = [
    path('load-models/', LoadModelsView.as_view(), name='load-models'),
    path('songs/', get_songs, name='get_songs'),
    path('songs/<int:pk>/', SongDetailView.as_view(), name='song-detail'),
    path('lyrics/', LyricsGenerationView.as_view(), name='lyrics-generation'),
    path('lyrics_translation/', LyricsTranslationView.as_view(), name='lyrics-translation'),
    path('song_classification/', SongClassificationView.as_view(), name='song-classification'),
    path('song_Recognition/', SongRecognitionView.as_view(), name='song-recognition'),
]