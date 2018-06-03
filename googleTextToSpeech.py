import sys
from gtts import gTTS
import io

def makeLines(chunk):
    lines = chunk.split('\n')
    return lines

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
languageCode='en-GB'  #https://cloud.google.com/speech-to-text/docs/languages  en-US, es-US, fr-FR?, nl-NL?, X-de-DE
if len(sys.argv) > 2: # -o <output filename.mp3>
    saveFilename = str(sys.argv[2])
if len(sys.argv) > 4: # -d <debug filename.txt>
    debugFilename = str(sys.argv[4])    
if len(sys.argv) > 6: # -l <language code e.g. en-GB>
    languageCode = str(sys.argv[6])    
    
tts_pause = gTTS(text=' \n ', lang=languageCode)

with io.BytesIO() as f:
    for chunk in sys.stdin:
        if (chunk is None):
            continue;            
        if (len(chunk) == 0):
            continue;
        if (chunk[:2] == '!['): # ugly hack - ignore markdown images
            continue;
        lines = makeLines(chunk)
        for line in lines:
            words = makeWords(line)
            if len(words) == 0:
                continue;
            ttsInput = '\n ' + ' '.join(words) + '\n '
            if len(debugFilename) > 0:
                with open(debugFilename, 'a') as debugFile:
                    debugFile.write(ttsInput)
                
            tts = gTTS(text=ttsInput, lang=languageCode)
            try: 
                tts.write_to_fp(f)
                tts_pause.write_to_fp(fp)
            except:
                continue;
        #end for line in lines
    #end for line in sys.stdin
    
    f.flush()
    f.seek(0)
    stuff = bytes(f.read())
    with open(saveFilename, 'wb') as save:
        save.write(stuff)
        save.flush()
