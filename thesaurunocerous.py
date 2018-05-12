from __future__ import print_function
import sys
import json
import collections
from nltk.corpus import wordnet

counts = collections.Counter()

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
    words = filter(wrd: len(wrd) > 3, words)
    counts.update(words)

print("total number of words: ", sum(counts.values()))

for word, count in counts.most_common():
    if (count > 3):
        hint = "Theasurus here"
        status = "Ignored" # None, Running, Passed, Failed, Ignored, Skipped, Inconclusive, No
        data = { "Word": word, "Status": status, "Hint": "Occurs " + str(count) + " times" }
        print(json.dumps(data))        

