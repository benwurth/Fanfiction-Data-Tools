# This script takes a .csv file with two columns (words and wordcount) and turns them into a wordcloud.

# Require wordcloud (otherwise we can't make a wordcloud!)
require(wordcloud)

# Flag for csv headers.
csvHeaders <- FALSE

# Get the csv file
wordcountFile <- file.choose()

maxWords <- 0

# Ask for the number of words in the wordcloud
print("How many words do you want in the wordcoud?")
while(maxWords < 1 ){
  maxWords <- readline("enter a positive integer: ")
  maxWords <- ifelse(grepl("\\D",maxWords),-1,as.integer(maxWords))
  if(is.na(maxWords)){break}  # breaks when hit enter
} 

# Puts the csv file into a data frame.
if (!csvHeaders) # If there aren't any headers:
{									# "Words" and "Count" are the default header names.
	words.csv <- read.csv(wordcountFile, col.names = c("Words", "Count"), header=FALSE)
} else {									# Headers are turned on
	words.csv <- read.csv(wordcountFile, headers=TRUE)
}

# And now we get our wordcloud!
wordcloud(words.csv[,1], words.csv[,2], max.words=maxWords)