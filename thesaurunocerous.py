from __future__ import print_function
import sys
import json
import collections
from nltk.corpus import wordnet

counts = collections.Counter()
ignoredCounts = collections.Counter()

IGNORE_WORDS_THIS_SHORT_OR_LESS = 3 

def statusMessage(title, hint):
    data = { "Word": title,  "Status": "Message", "Hint": hint }
    print(json.dumps(data))

for line in sys.stdin:
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
    
    print(words)
    
    words = list(filter(lambda wrd: len(wrd) > IGNORE_WORDS_THIS_SHORT_OR_LESS, words))
    ignoredWords = list(filter(lambda wrd: len(wrd) <= IGNORE_WORDS_THIS_SHORT_OR_LESS, words))
    counts.update(words)
    
    ignoredCounts.update(ignoredWords)
    print(ignoredCounts)

ignoredWordCount = sum(ignoredCounts.values())
significantWordCount = sum(counts.values())
statusMessage("Words less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ), str( ignoredWordCount ))
statusMessage("Words more than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ), str( significantWordCount ))

totalWordCount = significantWordCount + ignoredWordCount
statusMessage("Total number of words", str( totalWordCount ))

uniqueIgnoredWords = list(set(ignoredWords))
print(uniqueIgnoredWords)
ignoredHint = ", ".join(uniqueIgnoredWords)
statusMessage("Words less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters long", ignoredHint)

for word, count in counts.most_common():
    hint = "Theasurus here"
    status = "Warning"
    data = { "Word": word, "Status": status, "Hint": "Occurs " + str(count) + " times: " + hint }
    print(json.dumps(data))
