#Thank you Steve Barnes, Command Line Spelling Checker
#https://softwarerecs.stackexchange.com/questions/26923/command-line-#spell-check-for-windows

from __future__ import print_function
import sys
import enchant 
import json

ignorewords = []
with open("spellchecker.exceptions.txt") as fp:  
    for cnt, line in enumerate(fp):
        if (line[:1] == '#'):
            continue;
        ignorewords.append(line)

sys.stdin.flush();
sys.stdout.write("{ \"Results\":[")
first=True
d = enchant.Dict("en_UK") # or en_US, de_DE, fr_FR, en_AU on my system
for line in sys.stdin:
    words = line.replace('\"', '')
    words = words.replace('*', '')
    words = words.replace('#', '')
    words = words.replace(';', '')
    words = words.replace(':', '')
    words = words.replace(',', '')
    words = words.replace('?', '')
    words = words.replace('.', '')
    words = words.replace('\\', '')
    words = words.replace('/', '')
    words = words.replace('!', '')
    words = words.replace(')', '')
    words = words.replace('(', '')
    words = words.split() 
    for word in words:
        ignoreIt = False
        for ignoreWord in ignoreWords:
            if ignoreWord == word:
                ignoreIt = True
                break
        if ignoreIt:
            continue;
        # if any(word in s for s in ignorewords):
        #     print('ignore ', word)
        #     continue            
        if not d.check(word):
            hint = ' or '.join(d.suggest(word)[:7])
            data = { 'Word': word, 'Status': 'Failed', 'Hint': hint }
            if (first == False):
                sys.stdout.write(",")
            else:
                first=False
            json.dump(data, sys.stdout)
sys.stdout.write("]}")
sys.stdout.flush()
