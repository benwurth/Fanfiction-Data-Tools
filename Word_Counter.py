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

#Initialize wordcount to be a dictionary
wordcount = dict()

#TODO: Add the 100 most common english words to a list and omit them from the word counts (If a flag is used)

#Open the file
fp = open(filename)
#Loop through the lines one by one (so that it doesn't hog memory)
for i, line in enumerate(fp):
	#Prints out a status to the command line
	print("At line "+ "{:,}".format(i), end='\r')
	#Makes all letters lowercase
	line = line.lower()
	#Removes everything that isn't a letter
	line = " ".join(re.findall("[a-zA-Z]+", line))
	#Separates the words into a list
	line = list(re.findall(re.compile('\w+'), line))
	
	#Loops through the list for the current line and checks to see if
	#the current word already has an entry in wordcount. If it does, 
	#it adds one to it. If it doesn't, it adds the word and initializes 
	#it to 1.
	for j in line:
		if j in wordcount:
			wordcount[j] += 1
		else:
			wordcount[j] = 1

#Gets a filename and directory to save to.
savefile = asksaveasfilename()

#Saves the file.
f = open('background_pony_wordcount.csv', 'wb')
f = open(savefile, 'wb')
w = csv.writer(f, wordcount.keys())
for key, value in wordcount.items():
	w.writerow([key, value])
f.close()