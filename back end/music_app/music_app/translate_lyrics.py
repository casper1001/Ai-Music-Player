
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import MarianMTModel, MarianTokenizer
from transformers import T5ForConditionalGeneration, T5Tokenizer

app = FastAPI()

tokenizer = T5Tokenizer.from_pretrained("t5-small")
model = T5Tokenizer.from_pretrained("t5-small")

class TranslationRequest(BaseModel):
    text: str
    src_lang: str = "en"
    tgt_lang: str = "ar"

def translate_text_offline(text, src_lang="en", tgt_lang="ar"):
    translated = model.generate(**tokenizer(text, return_tensors="pt", padding=True))
    return tokenizer.decode(translated[0], skip_special_tokens=True)

@app.post("/translate/")
def translate(request: TranslationRequest):
    if not request.text:
        raise HTTPException(status_code=400, detail="No text provided")
    translation = translate_text_offline(request.text, request.src_lang, request.tgt_lang)
    return {"translation": translation}
