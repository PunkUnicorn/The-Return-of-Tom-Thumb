#Thank you Steve Barnes, Command Line Spelling Checker
#https://softwarerecs.stackexchange.com/questions/26923/command-line-#spell-check-for-windows

from __future__ import print_function
import sys
import enchant 
#import json
import csv

def makeWords(line):
    words = line.replace('\"', '')
    words = words.replace('*', '')
    words = words.replace('#', '')
    words = words.replace(';', '')
    words = words.replace(':', '')
    words = words.replace(',', '')
    words = words.replace('?', '')
    words = words.replace('.', '')
    # words = words.replace('\'', '')
    words = words.replace('\\', '')
    words = words.replace('/', '')
    words = words.replace('!', '')
    words = words.replace(')', '')
    words = words.replace('(', '')
    #words = words.lower()
    words = words.split()     
    return words

ignoreWords = []
with open("spellchecker.exceptions.txt") as fp:  
    for cnt, line in enumerate(fp):
        if (line[:1] == '#'):
            continue;
        for ignoreWord in makeWords(line):
            ignoreWords.append(ignoreWord)

#sys.stdout.write("{ \"Results\":[")
first=True
d = enchant.Dict("en_UK") # or en_US, de_DE, fr_FR, en_AU on my system
for line in sys.stdin:
    words = makeWords(line)
    for word in words:
        ignoreIt = False
        if (word[0] == '['):
          ignoreIt = True

        for ignoreWord in ignoreWords:
            if ignoreWord == word:
                ignoreIt = True
                break
            
        if ignoreIt:
            continue;

        if not d.check(word):
            hint = ' or '.join(d.suggest(word)[:7])
            writer = csv.writer(sys.stdout, delimiter=',', quotechar='\"', quoting=csv.QUOTE_MINIMAL)
            if (first == True):
                writer.writerow([ 'Word' ] + [ 'Hint' ])
                first=False
            writer.writerow([ word ] + [ hint ])

            #data = { 'Word': word, 'Status': 'Failed', 'Hint': hint }
            #if (first == False):
            #    sys.stdout.write(",")
            #else:
            #    first=False
            #json.dump(data, sys.stdout)

#sys.stdout.write("]}")
sys.stdout.flush()
