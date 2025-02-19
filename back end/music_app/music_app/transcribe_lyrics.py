import os
import whisper
from fastapi import FastAPI, HTTPException

app = FastAPI()

def transcribe_audio(audio_path, output_path):
    model = whisper.load_model("base")
    result = model.transcribe(audio_path)
    with open(output_path, "w") as f:
        f.write(result["text"])
    return output_path

@app.post("/transcribe_lyrics/")
async def transcribe_lyrics_api(vocal_file_path: str):
    try:
        output_directory = "output_lyrics"
        os.makedirs(output_directory, exist_ok=True)
        output_lyrics_file = os.path.join(output_directory, f"{os.path.splitext(os.path.basename(vocal_file_path))[0]}_lyrics.txt")
        transcribe_audio(vocal_file_path, output_lyrics_file)
        return {"lyrics_file": output_lyrics_file}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
