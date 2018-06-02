import sys
from gtts import gTTS
import io

def makeWords(line):
    words = line.replace('\"', '')
    words = words.replace('*', ' * ')
    words = words.replace('#', ' # ')
    words = words.replace(';', ' ; ')
    words = words.replace(':', ' : ')
    words = words.replace(',', ' , ')
    words = words.replace('?', ' ? ')
    words = words.replace('.', ' . ')
    # words = words.replace('\'', '')
    #words = words.replace('\\', ' \\ ')
    #words = words.replace('/', ' / ')
    #words = words.replace('!', '')
    #words = words.replace(')', '')
    #words = words.replace('(', '')
    #words = words.lower()
    words = words.split()     
    return words
    
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
        if (line[:2] == '!['): # ugly hack - ignore markdown images
            continue;
        words = makeWords(line)
        pause = '\n ! \n !\n' # this pause only works if the next line after is not blank, otherwise the TTS speaks the ! ! !
        if len(words) == 0:
            continue;
        ttsInput = pause + ' '.join(words) + '  '
        if len(debugFilename) > 0:
            with open(debugFilename, 'a') as debugFile:
                debugFile.write(ttsInput)
                
        tts = gTTS(text=ttsInput, lang='en-GB') #https://cloud.google.com/speech-to-text/docs/languages  en-GB es-US
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
