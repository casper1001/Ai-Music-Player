import os
import librosa
import numpy as np
import torchaudio
from scipy import stats
from pathlib import Path
from demucs.pretrained import get_model
from demucs.apply import apply_model
from demucs.audio import AudioFile
import whisper

def load_audio_file(file_path, target_sr=22050):
    """Load an audio file using librosa."""
    try:
        audio, sr = librosa.load(file_path, sr=target_sr)
        return audio, sr
    except Exception as e:
        raise ValueError(f"Error loading audio file: {e}")

def extract_features(file_path, fs=22050, n_mfcc=13, segment_length=3):
    """Extract MFCC features from an audio file."""
    try:
        audio, sample_rate = librosa.load(file_path, sr=fs)
        segment_length_samples = int(fs * segment_length)
        num_segments = max(len(audio) // segment_length_samples, 1)

        mfccs_per_segment = 130
        features = []

        for seg in range(num_segments):
            start_sample = seg * segment_length_samples
            end_sample = start_sample + segment_length_samples

            if end_sample <= len(audio):
                mfcc = librosa.feature.mfcc(
                    y=audio[start_sample:end_sample], sr=sample_rate, n_mfcc=n_mfcc
                ).T

                if len(mfcc) < mfccs_per_segment:
                    mfcc = np.pad(mfcc, ((0, mfccs_per_segment - len(mfcc)), (0, 0)), mode="constant")
                else:
                    mfcc = mfcc[:mfccs_per_segment, :]

                features.append(mfcc)

        features = np.array(features)
        return features.reshape(features.shape[0], features.shape[1], features.shape[2], 1), sample_rate
    except Exception as e:
        raise ValueError(f"Error extracting features: {e}")

def extract_vocals(file_path, output_dir):
    """Extract vocals from an audio file using Demucs."""
    try:
        model = get_model("htdemucs")
        model.cpu()

        audio_file = AudioFile(file_path)
        wav = audio_file.read(streams=0, samplerate=model.samplerate, channels=model.audio_channels)

        sources = apply_model(model, wav[None], shifts=1, split=True, overlap=0.25, progress=True)[0]

        vocal_index = model.sources.index("vocals")
        vocals = sources[vocal_index]
        output_path = os.path.join(output_dir, f"{Path(file_path).stem}_vocals.wav")
        torchaudio.save(output_path, vocals.cpu(), sample_rate=model.samplerate)

        return output_path
    except Exception as e:
        raise ValueError(f"Error extracting vocals: {e}")

def transcribe_audio(audio_path):
    """Transcribe audio using Whisper."""
    try:
        model = whisper.load_model("base")
        result = model.transcribe(audio_path)
        return result["text"]
    except Exception as e:
        raise ValueError(f"Error transcribing audio: {e}")