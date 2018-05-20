import sys
from gtts import gTTS

# START
for line in sys.stdin:
    if (line is None):
        continue;
    if (len(line) == 0):
        continue;
    word = ' '.join(line.split())
    tts = gTTS(text=str(word) +' ', lang='en-GB')
    try: 
        dumbFilename = 'The-Return-of-Tom-Thumb-temp.mp3'
        tts.save(dumbFilename)
        with open(dumbFilename, 'rb') as f:
            stuff = bytes(f.read())
            f.flush()
            sys.stdout.buffer.write(stuff)
            sys.stdout.flush()
    except:
        continue;

