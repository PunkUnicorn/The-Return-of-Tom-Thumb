from __future__ import print_function
import sys
import json
from collections import Counter
from py_thesaurus import Thesaurus


counts = Counter()
for line in sys.stdin:
    words = line.strip().lower().split() 
    counts.update(words)

for needSuggestions in counts.most_common(7)
    new_instance = Thesaurus(word)
    # Get the synonyms according to part of speech
    # Default part of speech is noun
    data = { "Word": needSuggestions, "Status":"Warning", "Hint": new_instance.get_synonym() }
    print(json.dumps(data))


