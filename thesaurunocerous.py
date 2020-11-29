from __future__ import print_function
import sys
import json
import collections
from nltk.corpus import wordnet

IGNORE_WORDS_THIS_SHORT_OR_LESS = 2
IGNORE_WORDS_THAT_OCCUR_THIS_OR_LESS = 3
IGNORE_WORDS_THAT_OCCUR_THIS_OR_MORE = 300
    
def makeWords(line):
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
    return words

# START
first=True
sys.stdout.write(" { \"Results\":[")
counts = collections.Counter()
ignoredCounts = collections.Counter()    
for line in sys.stdin:
    # Get and count the words
    words = makeWords(line)   
    ignoredWords = [w for w in words if len(w) <= IGNORE_WORDS_THIS_SHORT_OR_LESS]
    ignoredCounts.update(ignoredWords)
    countingWords = [w for w in words if len(w) > IGNORE_WORDS_THIS_SHORT_OR_LESS]
    counts.update(countingWords)

def statusMessage(title, hint, first, occurs):
    data = { "Word": title,  "Status": "Information", "Occurs": occurs, "Hint": hint, "Length": len(title) }
    if (first == False):
        sys.stdout.write(",")
    else:
        first=False
    json.dump(data, sys.stdout)
    return first
    
def percentageOf(whatsMyPercent, total):
    if (total == 0):
        return ""
    percentage = round((float(whatsMyPercent) / float(total)) * float(100), 3)
    return str(percentage) + "%"

# Find word totals, including sub-totals for included and excluded words. Also a list of discounted words
ignoredWordCount = sum(ignoredCounts.values())
significantWordCount = sum(counts.values())
totalWordCount = significantWordCount + ignoredWordCount
first = statusMessage("Count of words " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters long or less", str( ignoredWordCount ) + " " + percentageOf(ignoredWordCount, totalWordCount), first, ignoredWordCount)
first = statusMessage("Count of words more than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS )  + " characters", str( significantWordCount ) + " " + percentageOf(significantWordCount, totalWordCount), first, significantWordCount)
first = statusMessage("Total number of words", str( totalWordCount ), first, totalWordCount)
uniqueIgnoredWords = list(set(ignoredCounts.keys()))
ignoredHint = ", ".join(uniqueIgnoredWords)
zippedHint = zip(uniqueIgnoredWords, ignoredCounts.values())
littleBits = [] # Important ==> https://www.youtube.com/watch?v=Gj4-E5Hs3Kc
uniqueIgnoredWordCount = 0
for word, count in zippedHint:
    littleBits.append(word + "(" + str(count) + ") " + percentageOf(count, totalWordCount))
    uniqueIgnoredWordCount += 1    
first = statusMessage("Ignored words (less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters)", ", ".join(littleBits), first, uniqueIgnoredWordCount)

def getTheasaurusHint(word):
    synonyms = []
    antonyms = []
    for syn in wordnet.synsets(word):
        for l in syn.lemmas():
            synonyms.append(l.name())
    return ", ".join( set(synonyms) )
    
# Call out the main offenders and suggest alternatives
for word, count in counts.most_common():
    if (count > IGNORE_WORDS_THAT_OCCUR_THIS_OR_LESS):
        if (count < IGNORE_WORDS_THAT_OCCUR_THIS_OR_MORE):
            hint = percentageOf(count, totalWordCount)
            hint += " " + getTheasaurusHint(word);
            data = { "Word": word, "Status": "Warning", "Occurs": count, "Hint": "Occurs " + str(count) + " times " + hint, "Length": len(word) }
            if (first == False):
                sys.stdout.write(",")
            else:
                first=False
            json.dump(data, sys.stdout)
sys.stdout.write("]}")
sys.stdout.flush()
