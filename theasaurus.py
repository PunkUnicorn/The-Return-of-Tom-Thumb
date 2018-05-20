from __future__ import print_function
import sys
import json
import collections
import csv
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

def getSynonymHint(word):
    synonyms = []
    antonyms = []
    for syn in wordnet.synsets(word):
        for l in syn.lemmas():
            synonyms.append(l.name())
    return ", ".join( set(synonyms) )
    
# START
words=[]
for line in sys.stdin:
    lineWords = makeWords(line)
    for word in lineWords:
        words.append(word)

first=True
for word in words:
    writer = csv.writer(sys.stdout, delimiter=',', quotechar='\"', quoting=csv.QUOTE_MINIMAL)
    if (first == True):
        writer.writerow([ 'Word' ] + [ 'Synonyms' ])
        first=False
    hint = getSynonymHint(word)
    writer.writerow([ word ] + [ hint ])

sys.stdout.flush()
