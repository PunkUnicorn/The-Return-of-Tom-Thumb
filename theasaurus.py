from __future__ import print_function
import sys
import collections
from nltk.corpus import wordnet

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
    words = words.lower()
    words = words.split()     
    return words

def getTheasaurusHint(word):
    synonyms = []
    antonyms = []
    for syn in wordnet.synsets(word):
        for l in syn.lemmas():
            synonyms.append(l.name())
    return ", ".join( set(synonyms) )
    

# START
first=True
words=[]
for line in sys.stdin:
    lineWords = makeWords(line)   
    words.append(lineWords)

for word in words:
    writer = csv.writer(sys.stdout, delimiter=',', quotechar='\"', quoting=csv.QUOTE_MINIMAL)
    if (first == True):
        writer.writerow([ 'Word' ] + [ 'theasaurus' ])
        first=False
    hint = getTheasaurusHint
    writer.writerow([ word ] + [ hint ])

sys.stdout.flush()
