from __future__ import print_function
import sys
import json
import collections
from nltk.corpus import wordnet

counts = collections.Counter()
for line in sys.stdin:
    words = line.strip().lower().split() 
    counts.update(words)

print("total number of words: ", sum(counts.values()))
for wordOccurance in counts.most_common():
    hint = "Theasurus here"
    data = { "Word": wordOccurance, "Status": "Warning", "Hint": hint }
    print(json.dumps(data))

