import os
import json
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from dejavu import Dejavu
from dejavu.recognize import FileRecognizer

# Load Dejavu configuration
CONFIG_PATH = "dejavu.cnf"
if not os.path.exists(CONFIG_PATH):
    raise FileNotFoundError(f"Dejavu configuration file not found: {CONFIG_PATH}")

with open(CONFIG_PATH) as f:
    config = json.load(f)

# Initialize Dejavu
djv = Dejavu(config)

# Initialize Flask app
app = Flask(__name__)

# Allowed file extensions for audio files
ALLOWED_EXTENSIONS = {'mp3', 'flac', 'wav'}
UPLOAD_FOLDER = "uploads"

# Ensure the uploads folder exists
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Check if file has an allowed extension
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Endpoint to recognize song from uploaded audio file
@app.route('/recognize', methods=['POST'])
def recognize_song():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part in request'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file type. Allowed types: mp3, flac, wav'}), 400

    try:
        filename = secure_filename(file.filename)
        temp_file_path = os.path.join(UPLOAD_FOLDER, filename)
        file.save(temp_file_path)  # Save the file temporarily

        # Recognize the song from the file
        recognizer = FileRecognizer(djv)
        result = recognizer.recognize(temp_file_path)

        # Clean up the file after processing
        os.remove(temp_file_path)

        if result:
            return jsonify({
                'song_name': result.get("song_name", "Unknown"),
                'artist': result.get("artist_name", "Unknown"),
                'album': result.get("album_name", "Unknown"),
                'song_id': result.get("song_id", "N/A")
            })
        else:
            return jsonify({'error': 'Song not recognized'}), 404

    except Exception as e:
        return jsonify({'error': f'Error during song recognition: {str(e)}'}), 500

# Run Flask app
if __name__ == "__main__":
    app.run(debug=True)
