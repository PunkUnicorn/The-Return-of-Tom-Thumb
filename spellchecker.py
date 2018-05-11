
"""
Thank you Steve Barnes
https://softwarerecs.stackexchange.com/questions/26923/command-line-spell-check-for-windows
Command Line Spelling Checker
Enter words to check as arguments
"""
from __future__ import print_function
import sys
import enchant

d = enchant.Dict("en_UK") # or en_UK, de_DE, fr_FR, en_AU on my system
print(__doc__)
for line in sys.stdin:
    words = line.split()
    for word in words:
        if d.check(word):
            print(word, 'is OK')
        else:
            print('Suggestions for', word, ':', '\n\t'.join(d.suggest(word)))
