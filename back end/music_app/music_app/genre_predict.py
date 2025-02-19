from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
import os
import librosa
import numpy as np
import tensorflow as tf
from keras import load_model

from scipy import stats
import math

app = FastAPI()

model_path = "model_cnn3.h5"
model_cnn3 = load_model(model_path)

genres = [
    "blues", "classical", "country", "disco", "hiphop",
    "jazz", "metal", "pop", "reggae", "rock",
]

class GenreRequest(BaseModel):
    file_path: str

def load_audio_file(file_path, target_sr=22050):
    ext = os.path.splitext(file_path)[-1].lower()
    if ext in [".mp3", ".m4a"]:
        return librosa.load(file_path, sr=target_sr)
    elif ext == ".wav":
        return librosa.load(file_path, sr=target_sr)
    else:
        raise ValueError("Unsupported file format. Supported formats: WAV, MP3, M4A.")

def extract_features(file_path, fs=22050, n_mfcc=13, n_fft=2048, hop_length=512, segment_length=3):
    audio, sample_rate = load_audio_file(file_path, target_sr=fs)
    segment_length_samples = int(fs * segment_length)
    num_segments = len(audio) // segment_length_samples
    num_segments = max(num_segments, 1)
    features = []
    for seg in range(num_segments):
        start_sample = seg * segment_length_samples
        end_sample = start_sample + segment_length_samples
        mfcc = librosa.feature.mfcc(
            y=audio[start_sample:end_sample], sr=sample_rate, n_fft=n_fft, hop_length=hop_length, n_mfcc=n_mfcc
        ).T
        features.append(mfcc)
    features = np.array(features)
    return features.reshape(features.shape[0], features.shape[1], features.shape[2], 1)

@app.post("/predict_genre/")
async def predict_genre(request: GenreRequest):
    file_path = request.file_path
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    features = extract_features(file_path)
    prediction = model_cnn3.predict(features)
    predicted_class = np.argmax(prediction, axis=1)
    mode_result = stats.mode(predicted_class, axis=None)
    final_class_index = int(mode_result.mode[0])
    final_genre = genres[final_class_index]
    return {"predicted_genre": final_genre}
