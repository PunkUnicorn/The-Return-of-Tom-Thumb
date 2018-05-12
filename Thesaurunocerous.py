#Thank you Steve Barnes, Command Line Spelling Checker
#https://softwarerecs.stackexchange.com/questions/26923/command-line-#spell-check-for-windows

from __future__ import print_function
import sys
import json
from collections import Counter
from py_thesaurus import Thesaurus

for line in sys.stdin:
    words = line.strip().lower().split() 
    counts.update(words)

for needSuggestions in x.most_common()
    new_instance = Thesaurus(word)
    # Get the synonyms according to part of speech
    # Default part of speech is noun
    data = { "Word": needSuggestions, "Status":"Warning", "Hint": new_instance.get_synonym() }
    print(json.dumps(data))

