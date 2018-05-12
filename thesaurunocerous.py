from __future__ import print_function
import sys
import json
import collections
from nltk.corpus import stopwords, lin_thesaurus as thes
from nltk.corpus import wordnet

#lin theasurus
#http://nullege.com/codes/show/src%40n%40l%40nltk-2.0.4%40nltk%40corpus%40reader%40lin.py/135/nltk.corpus.lin_thesaurus/python

counts = collections.Counter()
ignoredCounts = collections.Counter()

IGNORE_WORDS_THIS_SHORT_OR_LESS = 3 
IGNORE_WORDS_THAT_OCCUR_THIS_OR_LESS = 2
    
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
    
for line in sys.stdin:
    words = makeWords(line)   
    ignoredWords = [w for w in words if len(w) <= IGNORE_WORDS_THIS_SHORT_OR_LESS]
    ignoredCounts.update(ignoredWords)
    countingWords = [w for w in words if len(w) > IGNORE_WORDS_THIS_SHORT_OR_LESS]
    counts.update(countingWords)

def statusMessage(title, hint):
    data = { "Word": title,  "Status": "Message", "Hint": hint }
    print(json.dumps(data))
    
ignoredWordCount = sum(ignoredCounts.values())
significantWordCount = sum(counts.values())
totalWordCount = significantWordCount + ignoredWordCount
statusMessage("Count of words " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters long or less", str( ignoredWordCount ))
statusMessage("Count of words more than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS )  + " characters", str( significantWordCount ))
statusMessage("Total number of words", str( totalWordCount ))

uniqueIgnoredWords = list(set(ignoredCounts.keys()))
ignoredHint = ", ".join(uniqueIgnoredWords)

zippedHint = zip(uniqueIgnoredWords, ignoredCounts.values())
statusMessage("Ignored words (less than " + str( IGNORE_WORDS_THIS_SHORT_OR_LESS ) + " characters)", zippedHint)

def getTheasaurusHint(word):
    synonyms = []
    antonyms = []

    for syn in wordnet.synsets(word):
        for l in syn.lemmas():
            synonyms.append(l.name())
            #if l.antonyms():
            #    antonyms.append(l.antonyms()[0].name())

    #print(set(synonyms))
    #print(set(antonyms))
    
    #theasurusHint = thes.synonyms(word)
    #return ", ".join(str(wordList) for dictName, wordList in theasurusHint)
    return ", ".join( str(set(synonyms)) )
    
for word, count in counts.most_common():
    if (count > IGNORE_WORDS_THAT_OCCUR_THIS_OR_LESS):
        hint = getTheasaurusHint(word)
        status = "Warning"
        data = { "Word": word, "Status": status, "Hint": "Occurs " + str(count) + " times: " + hint }
        print(json.dumps(data))
