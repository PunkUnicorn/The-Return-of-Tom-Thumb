from __future__ import print_function
import sys
import json
import collections
from py_thesaurus import Thesaurus

counts = collections.Counter()

for line in sys.stdin:
    words = line.strip().lower().split() 
    counts.update(words)

for needSuggestions in counts.most_common(7)
    new_instance = Thesaurus(needSuggestions)
    data = { "Word": needSuggestions, "Status":"Warning", "Hint": new_instance.get_synonym() }
    print(json.dumps(data))


