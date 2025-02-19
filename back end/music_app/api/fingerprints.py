import os
import sqlite3
from venv import logger
import numpy as np
import librosa
from pydub import AudioSegment

# Database setup
def initialize_db(db_path='songs.db'):
    if os.path.exists(db_path):
        os.remove(db_path)  
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS songs
                 (id INTEGER PRIMARY KEY, name TEXT, fingerprint BLOB)''')
    conn.commit()
    return conn

# Convert MP3 to WAV using pydub
def convert_to_wav(audio_path):
    if audio_path.endswith(".mp3"):
        audio = AudioSegment.from_mp3(audio_path)
        wav_path = audio_path.replace(".mp3", ".wav")
        audio.export(wav_path, format="wav")
        return wav_path
    return audio_path

# Extract MFCC features
def extract_mfcc(audio_path, n_mfcc=13):
    try:
        # Convert MP3 to WAV if necessary
        audio_path = convert_to_wav(audio_path)

        # Load audio file
        y, sr = librosa.load(audio_path, sr=22050)

        # Extract MFCC features
        mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=n_mfcc)
        fingerprint = np.mean(mfcc, axis=1).astype(np.float64)  

        # Log the fingerprint size
        logger.debug(f"Extracted fingerprint size: {fingerprint.size} elements")
        return fingerprint
    except Exception as e:
        logger.error(f"Error processing {audio_path}: {e}")
        return None

# Save fingerprint to database
def save_fingerprint(conn, song_name, fingerprint):
    c = conn.cursor()
    fingerprint_bytes = fingerprint.tobytes()
    logger.debug(f"Fingerprint size before saving: {len(fingerprint_bytes)} bytes")
    c.execute("INSERT INTO songs (name, fingerprint) VALUES (?, ?)",
              (song_name, fingerprint_bytes))
    conn.commit()   

# Recognize song by comparing fingerprints
def recognize_song(conn, input_fingerprint):
    c = conn.cursor()
    c.execute("SELECT id, name, fingerprint FROM songs")
    songs = c.fetchall()

    best_match = None
    min_distance = float('inf')

    for song in songs:
        fingerprint_bytes = song[2]
        logger.debug(f"Retrieved fingerprint size: {len(fingerprint_bytes)} bytes")
        try:
            
            if len(fingerprint_bytes) % 8 != 0:
                logger.error(f"Invalid fingerprint size for song {song[1]}: {len(fingerprint_bytes)} bytes")
                continue

            stored_fingerprint = np.frombuffer(fingerprint_bytes, dtype=np.float64)
            distance = np.linalg.norm(input_fingerprint - stored_fingerprint)

            if distance < min_distance:
                min_distance = distance
                best_match = song[1]
        except Exception as e:
            logger.error(f"Error processing fingerprint for song {song[1]}: {e}")

    return best_match

# Main function to generate fingerprints
def generate_fingerprints(song_directory, db_path='songs.db'):
    conn = initialize_db(db_path)

    for song_file in os.listdir(song_directory):
        if song_file.endswith(".mp3") or song_file.endswith(".wav"):
            song_path = os.path.join(song_directory, song_file)
            fingerprint = extract_mfcc(song_path)

            if fingerprint is not None:
                save_fingerprint(conn, song_file, fingerprint)
                print(f"Fingerprinted: {song_file}")
            else:
                print(f"Skipping invalid file: {song_file}")

    conn.close()
    

# Main function to recognize a song
def recognize_audio(audio_path, db_path='songs.db'):
    conn = initialize_db(db_path)
    fingerprint = extract_mfcc(audio_path)

    if fingerprint is not None:
        song_name = recognize_song(conn, fingerprint)
        conn.close()
        return song_name
    else:
        conn.close()
        return None

if __name__ == "__main__":
    # Generate fingerprints for all songs in the directory
    generate_fingerprints("C:\\Users\\Administrator\\Desktop\\songs")

    # Recognize a song
    recognized_song = recognize_audio("path/to/recorded_audio.wav")
    if recognized_song:
        print(f"Recognized Song: {recognized_song}")
    else:
        print("No match found.")
        
        
        