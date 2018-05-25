import sys
from gtts import gTTS
import io

# START
saveFilename = 'audio.mp3'
debugFilename = ''
if len(sys.argv) > 2: # -o <output filename.mp3>
    saveFilename = str(sys.argv[2])
if len(sys.argv) > 3: # -d <debug filename.txt>
    debugFilename = str(sys.argv[4])    
    
with io.BytesIO() as f:
    for line in sys.stdin:
        if (line is None):
            continue;
            
        if (len(line) == 0):
            continue;
            
        word = '  ' + ' '.join(line.split()) + '  '
        if len(debugFilename) > 0:
            with open(debugFilename, 'a') as debugFile:
                debugFile.write(word)
                
        tts = gTTS(text=word + '\n', lang='nl-NL') #https://cloud.google.com/speech-to-text/docs/languages  en-GB
        try: 
            tts.write_to_fp(f)
        except:
            continue;            
    #end for line in sys.stdin
    
    f.flush()
    f.seek(0)
    stuff = bytes(f.read())
    with open(saveFilename, 'wb') as save:
        save.write(stuff)
        save.flush()
