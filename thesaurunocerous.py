from __future__ import print_function
import sys
import json
import collections
from nltk.corpus import wordnet

IGNORE_WORDS_THIS_SHORT_OR_LESS = 2
IGNORE_WORDS_THAT_OCCUR_THIS_OR_LESS = 4
    
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

# START
first=True
sys.stdout.write(" { \"Results\":[")
counts = collections.Counter()
ignoredCounts = collections.Counter()    
for line in sys.stdin:
    words = makeWords(line)   
    ignoredWords = [w for w in words if len(w) <= IGNORE_WORDS_THIS_SHORT_OR_LESS]
    ignoredCounts.update(ignoredWords)
    countingWords = [w for w in words if len(w) > IGNORE_WORDS_THIS_SHORT_OR_LESS]
    counts.update(countingWords)

def statusMessage(title, hint, first):
    data = { "Word": title,  "Status": "Information", "IHasOccurs": False, "Occurs": 0, "Hint": hint }
    if (first == False):
        sys.stdout.write(",")
    else:
        first=False
    json.dump(data, sys.stdout)
    return first
    
ignoredWordCount = sum(ignoredCounts.values())
significantWordCount = sum(counts.values())
totalWordCount = significantWordCount + ignoredWordCount
first = statusMessage("Count of words " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters long or less", str( ignoredWordCount ), first)
first = statusMessage("Count of words more than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS )  + " characters", str( significantWordCount ), first)
first = statusMessage("Total number of words", str( totalWordCount ), first)
uniqueIgnoredWords = list(set(ignoredCounts.keys()))
ignoredHint = ", ".join(uniqueIgnoredWords)
zippedHint = zip(uniqueIgnoredWords, ignoredCounts.values())
littleBits = [] # Important ==> https://www.youtube.com/watch?v=Gj4-E5Hs3Kc
for word, count in zippedHint:
    littleBits.append(word + "(" + str(count) + ")")
first = statusMessage("Ignored words (less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters)", ", ".join(littleBits), first)

def getTheasaurusHint(word):
    synonyms = []
    antonyms = []
    for syn in wordnet.synsets(word):
        for l in syn.lemmas():
            synonyms.append(l.name())
    return ", ".join( set(synonyms) )
    
for word, count in counts.most_common():
    if (count > IGNORE_WORDS_THAT_OCCUR_THIS_OR_LESS):
        hint = getTheasaurusHint(word)
        data = { "Word": word, "Status": "Warning", "IHasOccurs": True, "Occurs": count, "Hint": "Occurs " + str(count) + " times. Suggestions: " + hint }
        if (first == False):
            sys.stdout.write(",")
        else:
            first=False
        json.dump(data, sys.stdout)
sys.stdout.write("]}")
sys.stdout.flush()
