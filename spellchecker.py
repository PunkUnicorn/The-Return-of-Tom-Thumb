#Thank you Steve Barnes, Command Line Spelling Checker
#https://softwarerecs.stackexchange.com/questions/26923/command-line-#spell-check-for-windows

from __future__ import print_function
import sys
import enchant
import json

d = enchant.Dict("en_UK") # or en_UK, de_DE, fr_FR, en_AU on my system
for line in sys.stdin:
    # do lots stripping... then split!
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
    words = words.split() 
    for word in words:
        if not d.check(word):
            hint = ' or '.join(d.suggest(word)[:7])
            data = { "Word": word, "Status": "Failed", "Hint": hint }
            print(json.dumps(data))
