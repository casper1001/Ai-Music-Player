from django.db import models
from django.urls import reverse
from django.utils import timezone

class SongManager(models.Manager):
    def get_songs_by_genre(self, genre):
        return self.filter(genre=genre)

    def get_songs_by_artist(self, artist):
        return self.filter(artist=artist)

class Song(models.Model):
    title = models.CharField(max_length=255, db_index=True)
    artist = models.CharField(max_length=255, db_index=True)
    album = models.CharField(max_length=255, null=True, blank=True)
    genre = models.CharField(max_length=255, null=True, blank=True, db_index=True)
    file_path = models.FileField(upload_to='songs/')
    fingerprint = models.BinaryField(null=True, blank=True)
    duration = models.IntegerField(null=True, blank=True)
    release_year = models.IntegerField(null=True, blank=True)
    bitrate = models.IntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(default=timezone.now)  

    objects = SongManager()

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['title', 'artist', 'album'],
                name='unique_song'
            )
        ]

    def __str__(self):
        return f"{self.title} by {self.artist}"

    def get_absolute_url(self):
        return reverse('song-detail', args=[str(self.id)])