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
counts = collections.Counter()
ignoredCounts = collections.Counter()    
for line in sys.stdin:
    words = makeWords(line)   
    ignoredWords = [w for w in words if len(w) <= IGNORE_WORDS_THIS_SHORT_OR_LESS]
    ignoredCounts.update(ignoredWords)
    countingWords = [w for w in words if len(w) > IGNORE_WORDS_THIS_SHORT_OR_LESS]
    counts.update(countingWords)

def statusMessage(title, hint):
    data = { "Word": title,  "Status": "Message", "Hint": hint }
    print(json.dumps(data))
    
ignoredWordCount = sum(ignoredCounts.values())
significantWordCount = sum(counts.values())
totalWordCount = significantWordCount + ignoredWordCount
statusMessage("Count of words " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters long or less", str( ignoredWordCount ))
statusMessage("Count of words more than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS )  + " characters", str( significantWordCount ))
statusMessage("Total number of words", str( totalWordCount ))
uniqueIgnoredWords = list(set(ignoredCounts.keys()))
ignoredHint = ", ".join(uniqueIgnoredWords)
zippedHint = zip(uniqueIgnoredWords, ignoredCounts.values())

littleBits = [] # https://www.youtube.com/watch?v=Gj4-E5Hs3Kc
for word, count in zippedHint:
    littleBits.append(word + "(" + str(count) + ")")
        
statusMessage("Ignored words (less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters)", ", ".join(littleBits)) #zippedHint)

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
        data = { "Word": word, "Status": "Warning", "Hint": "Occurs " + str(count) + " times. Suggestions: " + hint }
        print(json.dumps(data))
