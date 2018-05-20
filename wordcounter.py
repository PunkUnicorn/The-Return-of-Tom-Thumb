# Take a stream of words from stdin and output to stdout a csv of word counts

from __future__ import print_function
import sys
import collections
import csv
    
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

def roundPercentage(roundMe):
    return round(roundMe, 5)

def percentageOf(whatsMyPercent, total):
    if (total == 0):
        return roundPercentage(0)
    unroundedPercentage = (float(whatsMyPercent) / float(total)) * float(100)
    percentage = roundPercentage(unroundedPercentage)
    return percentage

# START
counts = collections.Counter()
for line in sys.stdin:
    words = makeWords(line)   
    counts.update(words)

totalWordCount = sum(counts.values())    
first=True
for word, count in counts.most_common():
    percent = percentageOf(count, totalWordCount)
    writer = csv.writer(sys.stdout, delimiter=',', quotechar='\"', quoting=csv.QUOTE_MINIMAL)
    if (first == True):
        writer.writerow([ 'Word' ] + [ 'Length' ] + [ 'Count' ] + [ 'Percent' ])
        first=False
    writer.writerow([ word ] + [len(word)] + [ count ] + [ percent ])

sys.stdout.flush()
