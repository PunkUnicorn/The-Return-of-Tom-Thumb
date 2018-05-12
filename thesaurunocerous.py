from __future__ import print_function
import sys
import json
import collections
from nltk.corpus import wordnet

counts = collections.Counter()
ignoredCounts = collections.Counter()

IGNORE_WORDS_THIS_SHORT_OR_LESS = 3 
IGNORE_WORDS_THAT_OCCUR_THIS_OR_LESS = 2
    
def statusMessage(title, hint):
    data = { "Word": title,  "Status": "Message", "Hint": hint }
    print(json.dumps(data))

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
    
for line in sys.stdin:
    words = makeWords(line)   
    ignoredWords = [w for w in words if len(w) <= IGNORE_WORDS_THIS_SHORT_OR_LESS]
    ignoredCounts.update(ignoredWords)
    countingWords = [w for w in words if len(w) > IGNORE_WORDS_THIS_SHORT_OR_LESS]
    counts.update(countingWords)
    
ignoredWordCount = sum(ignoredCounts.values())
significantWordCount = sum(counts.values())
totalWordCount = significantWordCount + ignoredWordCount
statusMessage("Count of words less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters", str( ignoredWordCount ))
statusMessage("Count of words less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS )  + " characters", str( significantWordCount ))
statusMessage("Total number of words", str( totalWordCount ))

uniqueIgnoredWords = list(set(ignoredCounts.keys()))
ignoredHint = ", ".join(uniqueIgnoredWords)

statusMessage("Ignored words (less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters)", ignoredHint)

for word, count in counts.most_common():
    if (count > IGNORE_WORDS_THAT_OCCUR_THIS_OR_LESS):
        hint = "Theasurus here"
        status = "Warning"
        data = { "Word": word, "Status": status, "Hint": "Occurs " + str(count) + " times: " + hint }
        print(json.dumps(data))
