import os
import torchaudio
from demucs.apply import apply_model
from demucs.pretrained import get_model
from demucs.audio import AudioFile
from fastapi import FastAPI, HTTPException

app = FastAPI()

def extract_vocals(file_path, output_dir):
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Input file not found: {file_path}")

    output_path = os.path.join(output_dir, f"{os.path.splitext(os.path.basename(file_path))[0]}_vocals.wav")
    model = get_model("htdemucs")
    model.cpu()
    audio_file = AudioFile(file_path)
    wav = audio_file.read(streams=0, samplerate=model.samplerate, channels=model.audio_channels)
    sources = apply_model(model, wav[None], shifts=1, split=True, overlap=0.25, progress=True)[0]
    vocal_index = model.sources.index("vocals")
    vocals = sources[vocal_index]
    torchaudio.save(output_path, vocals.cpu(), sample_rate=model.samplerate)
    return output_path

@app.post("/extract_vocals/")
async def extract_vocals_api(file_path: str):
    try:
        output_directory = "output_vocals"
        os.makedirs(output_directory, exist_ok=True)
        vocal_file = extract_vocals(file_path, output_directory)
        return {"vocal_file": vocal_file}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
