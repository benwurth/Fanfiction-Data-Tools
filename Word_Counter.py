from __future__ import print_function
import os
import re
import csv
from Tkinter import Tk
from tkFileDialog import askopenfilename
from tkFileDialog import asksaveasfilename

Tk().withdraw() #Stops the full GUI from loading
filename = askopenfilename() #Show an Open Dialog
#filename = "/Users/feanor93/Documents/Coding/fimfic_data/background_pony.txt"

wordcount = dict()

fp = open(filename)
for i, line in enumerate(fp):
	print("At line "+ "{:,}".format(i), end='\r')
	line = line.lower()
	line = " ".join(re.findall("[a-zA-Z]+", line))
	line = list(re.findall(re.compile('\w+'), line))
	
	for j in line:
		if j in wordcount:
			wordcount[j] += 1
		else:
			wordcount[j] = 1

#print[wordcount]

#print(line)

savefile = asksaveasfilename()

f = open('background_pony_wordcount.csv', 'wb')
f = open(savefile, 'wb')
w = csv.writer(f, wordcount.keys())
for key, value in wordcount.items():
	w.writerow([key, value])
f.close()