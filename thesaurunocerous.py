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
    words = filter(lambda wrd: len(wrd) > IGNORE_WORDS_THIS_SHORT_OR_LESS, words)
    ignoredWords = filter(lambda wrd: len(wrd) <= IGNORE_WORDS_THIS_SHORT_OR_LESS, words)
    counts.update(words)
    ignoredCounts.update(ignoredWords)
   
totalWordCount = sum(counts.values())
totalWordCount += sum(ignoredCounts.values())
statusMessage("Total number of words", str( totalWordCount ))

uniqueIgnoredWords = list(set(ignoredWords))
ignoredHint = ", ".join(ignoredCounts)
statusMessage("Occurance of words less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters long", ignoredHint)

for word, count in counts.most_common():
    hint = "Theasurus here"
    status = "Warning"
    data = { "Word": word, "Status": status, "Hint": "Occurs " + str(count) + " times: " + hint }
    print(json.dumps(data))
