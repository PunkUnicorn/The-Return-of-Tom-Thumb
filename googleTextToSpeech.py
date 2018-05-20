import sys
from gtts import gTTS
import io

# START
with io.BytesIO() as f:
    for line in sys.stdin:
        if (line is None):
            continue;
        if (len(line) == 0):
            continue;
        word = ' '.join(line.split())
        tts = gTTS(text=word + '\n', lang='en-GB')
        try: 
            tts.write_to_fp(f)
        except:
            continue;

    f.flush()
    f.seek(0)
    stuff = bytes(f.read())
    with open('The-Return-of-Tom-Thumb.mp3', 'wb') as save:
        save.write(stuff)
        save.flush()
