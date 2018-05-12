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
    counts.update(words)

print("total number of words: ", sum(counts.values()))

for word, count in counts.most_common():
    if (count > 2):
        hint = "Theasurus here"
        data = { "Word": word, "Status": "Warning", "Hint": "Occurs " + count + " times" }
        print(json.dumps(data))
    else if (count):

