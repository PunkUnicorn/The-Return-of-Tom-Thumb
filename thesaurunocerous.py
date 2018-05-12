from __future__ import print_function
import sys
import json
import collections
from nltk.corpus import wordnet

counts = collections.Counter()

IGNORE_WORDS_THIS_SHORT_OR_LESS = 3 

def statusNone(word, hint):
    data = { "Word": word,  "Status": "None", "Hint": hint }
    print(argstrs)

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
    excludedWords = list(filter(lambda wrd: len(wrd) <= IGNORE_WORDS_THIS_SHORT_OR_LESS, words))
    counts.update(words)
   
totalWordCount = sum(counts.values())
totalWordCount += len(excludedWords)
statusNone("Count" + str( totalWordCount ))

ignoreCounts = collections.Counter(excludedWords)
statusNone("Occurance of words less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters long", ignoreCounts)


for word, count in counts.most_common():
    hint = "Theasurus here"
    status = "Ignored" # None, Running, Passed, Failed, Ignored, Skipped, Inconclusive, No
    data = { "Word": word, "Status": status, "Hint": "Occurs " + str(count) + " times" }
    print(json.dumps(data))
