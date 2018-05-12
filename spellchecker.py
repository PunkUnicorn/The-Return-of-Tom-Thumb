#Thank you Steve Barnes, Command Line Spelling Checker
#https://softwarerecs.stackexchange.com/questions/26923/command-line-#spell-check-for-windows

from __future__ import print_function
import sys
import enchant
    
d = enchant.Dict("en_UK") # or en_UK, de_DE, fr_FR, en_AU on my system
print(__doc__)
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
        word = word..strip()
        if not d.check(word):
            print(word, '!Failed!', ' or '.join(d.suggest(word)[:7]))
