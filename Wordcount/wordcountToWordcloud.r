# This script takes a .csv file with two columns (words and wordcount) and turns them into a wordcloud.

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

print(maxWords)