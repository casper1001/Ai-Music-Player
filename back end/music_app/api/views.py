import os
import sqlite3
import numpy as np
import requests
import tensorflow as tf
import librosa
import math
import logging
import tempfile
from scipy import stats
from transformers import MarianTokenizer, MarianMTModel
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from pathlib import Path
from dejavu import Dejavu
from dejavu.recognize import FileRecognizer
import torchaudio
import whisper
from demucs.pretrained import get_model
from rest_framework.decorators import api_view
import json

from api.fingerprints import extract_mfcc, initialize_db, recognize_song
from .models import Song
from .serializers import SongSerializer
from transformers import T5ForConditionalGeneration, T5Tokenizer
from .audio_service import extract_features, extract_vocals, transcribe_audio

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load Dejavu configuration
CONFIG_PATH = os.path.join(settings.BASE_DIR, "dejavu.cnf")
if not os.path.exists(CONFIG_PATH):
    raise FileNotFoundError(f"Dejavu configuration file not found at {CONFIG_PATH}")

with open(CONFIG_PATH) as f:
    config = json.load(f)

# Initialize Dejavu
djv = Dejavu(config)

# Load Genre Classification Model
MODEL_PATH = os.path.join(settings.BASE_DIR, "music_app", "models", "model_cnn3.h5")
if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"Model file not found at {MODEL_PATH}")

model_cnn3 = tf.keras.models.load_model(MODEL_PATH)

# Genre List
GENRES = ["blues", "classical", "country", "disco", "hiphop", "jazz", "metal", "pop", "reggae", "rock"]



# API: Load Models
class LoadModelsView(APIView):
    def post(self, request):
        try:
            global model_cnn3, demucs_model, whisper_model, tokenizer, translation_model
            model_cnn3 = tf.keras.models.load_model(MODEL_PATH)
            demucs_model = get_model("htdemucs").cpu()
            whisper_model = whisper.load_model("base")
            tokenizer = T5Tokenizer.from_pretrained("t5-small")
            translation_model = T5ForConditionalGeneration.from_pretrained("t5-small")

            return Response({"message": "All models loaded successfully"}, status=status.HTTP_200_OK)
        except Exception as e:
            logger.error(f"Error loading models: {e}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# API: Get List of Songs
@api_view(['GET'])
def get_songs(request):
    try:
        songs = Song.objects.all()
        serializer = SongSerializer(songs, many=True)
        return Response(serializer.data)
    except Exception as e:
        logger.error(f"Error fetching songs: {e}")
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# API: Get Song Details
class SongDetailView(APIView):
    def get(self, request, pk):
        try:
            song = Song.objects.get(pk=pk)
            serializer = SongSerializer(song)
            return Response(serializer.data)
        except Song.DoesNotExist:
            return Response({"error": "Song not found"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            logger.error(f"Error fetching song details: {e}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)




# API: Lyrics Generation
class LyricsGenerationView(APIView):
    def post(self, request):
        audio_file = request.FILES.get('audio')
        if not audio_file:
            return Response({"error": "No audio file provided"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_file:
                for chunk in audio_file.chunks():
                    temp_file.write(chunk)
                temp_file_path = temp_file.name

            vocals_path = extract_vocals(temp_file_path, "output_stems")
            print(f"Extracted vocals file path: {vocals_path}")
            if not os.path.exists(vocals_path):
             raise Exception(f"Extracted vocals file not found: {vocals_path}")
            lyrics = transcribe_audio(vocals_path)

            return Response({"lyrics": lyrics}, status=status.HTTP_200_OK)
        except Exception as e:
            logger.error(f"Error generating lyrics: {e}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        finally:
            if os.path.exists(temp_file_path):
                os.remove(temp_file_path)
                
                
                
# API: song Recognize
class SongRecognitionView(APIView):
    def post(self, request):
        audio_file = request.FILES.get('audio')
        if not audio_file:
            logger.error("No audio file provided in the request")
            return Response({"error": "No audio file provided"}, status=status.HTTP_400_BAD_REQUEST)

        temp_file_path = None
        try:
            # Create a temporary file to store the uploaded audio
            with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_file:
                for chunk in audio_file.chunks():
                    temp_file.write(chunk)
                temp_file_path = temp_file.name

            logger.info(f"Processing audio file: {temp_file_path}")

            # Extract MFCC features from the uploaded audio
            fingerprint = extract_mfcc(temp_file_path)
            if fingerprint is None:
                logger.error("Failed to extract MFCC features from the audio file")
                return Response({"error": "Failed to process audio file"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            # Recognize the song using the fingerprint
            conn = initialize_db()
            song_name = recognize_song(conn, fingerprint)
            conn.close()

            if song_name:
                logger.info(f"Song recognized: {song_name}")
                return Response({
                    "song_name": song_name,
                    "artist": "Unknown",  
                    "album": "Unknown",
                }, status=status.HTTP_200_OK)
            else:
                logger.warning("Song not found in the database")
                return Response({"error": "Song not found"}, status=status.HTTP_404_NOT_FOUND)

        except Exception as e:
            logger.error(f"Error identifying song: {e}", exc_info=True)
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        finally:
            # Ensure the temporary file is deleted after processing
            if temp_file_path and os.path.exists(temp_file_path):
                try:
                    os.remove(temp_file_path)
                    logger.info(f"Temporary file {temp_file_path} deleted")
                except Exception as e:
                    logger.error(f"Error deleting temporary file {temp_file_path}: {e}")
                
                
                
# API: Song Genre Classification
class SongClassificationView(APIView):
    def post(self, request):
        audio_files = request.FILES.getlist('audio_files')
        if not audio_files:
            return Response({"error": "No audio files provided"}, status=status.HTTP_400_BAD_REQUEST)

        results = []
        for audio_file in audio_files:
            temp_file_path = f"temp_{audio_file.name}.wav"
            with open(temp_file_path, 'wb') as f:
                for chunk in audio_file.chunks():
                    f.write(chunk)

            try:
                features, _ = extract_features(temp_file_path)
                if features is None:
                    results.append({"file_name": audio_file.name, "error": "Failed to extract features"})
                    continue

                prediction = model_cnn3.predict(features)
                predicted_class = np.argmax(prediction, axis=1)
                final_class_index = int(stats.mode(predicted_class, axis=None).mode)
                final_genre = GENRES[final_class_index]

                results.append({"file_name": audio_file.name, "predicted_genre": final_genre})
            except Exception as e:
                results.append({"file_name": audio_file.name, "error": str(e)})
            finally:
                if os.path.exists(temp_file_path):
                    os.remove(temp_file_path)

        return Response(results, status=status.HTTP_200_OK)




# API: Lyrics Translation
class LyricsTranslationView(APIView):
    def post(self, request):
        text = request.data.get("text", "")
        src_lang = request.data.get("src_lang", "en")
        tgt_lang = request.data.get("tgt_lang", "ar")

        if not text:
            return Response({"error": "No text provided"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            response = requests.post("http://127.0.0.1:8000/translate", json={"text": text, "src_lang": src_lang, "tgt_lang": tgt_lang}, timeout=10)
            response.raise_for_status()
            return Response({"translated_text": response.json().get("translation", "Translation failed")})
        except requests.exceptions.RequestException as e:
            logger.error(f"Translation service error: {e}")
            return Response({"error": f"Translation service error: {str(e)}"}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        

    