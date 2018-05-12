from __future__ import print_function
import sys
import json
import collections
from nltk.corpus import wordnet

counts = collections.Counter()

for line in sys.stdin:
    words = line.strip().lower().split() 
    counts.update(words)
    
print(counts.most_common(37))


