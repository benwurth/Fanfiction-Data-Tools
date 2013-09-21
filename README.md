Fanfiction-Data-Tools
=====================
A suite of tools for collecting, organizing, and visually displaying data from fanfiction websites.

Project created by Ben Wurth  
ben.wurth@gmail.com  
On Skype at benwurth


Documentation
-------------
Not a lot of documentation so far. You can find out what most tools do by either looking at the comments in the code or by looking at their entries in the Wiki on GitHub.


Word_Counter.py
---------------
Word_Counter.py can be found under `Fanfiction-Data-Tools/Wordcount`. Run Word_Counter.py in the terminal with `python Word_Counter.py`. Alternately, you can use the Python Launcher to run the script.

Word_Counter.py will ask you for a text file to parse and then it will begin counting. After it's done, it will ask you for a location to save the CSV file it's produced. After it's written the CSV, you can use it with other tools to produce visualizations.


wordcountToWordcloud.r
----------------------
wordcountToWordcloud.r takes one of the CSV files produced by Word_Counter.py and produces a wordcloud visualization.

In order to use wordcountToWordcloud.r you need to have downloaded and installed R from [r-project.org](http://www.r-project.org/).

Once you've opened up the R Console, change the working directory to `Fanfiction-Data-Tools/Wordcount`. You can do this in one of two ways:

If you prefer to use the GUI, you can go to `Misc -> Change Working Directory...` in the file menu. You can also use the keyboard shortcut `⌘D`. 

You can change the directory in the console by using `setwd(...)`.

After you've set the working directory, you can run the script by typing `source("wordcountToWordcloud.r");` Then enter the number of words you want in your wordcloud as an integer. R will then output a wordcloud. 

Saving the wordcloud to an image file or PDF file is not currently supported, but it is planned to be implemented soon.

TODO
----

###Scatterplot_v01.pde
- [ ] Add a control panel
- [ ] Add support to the axis for logarithmic scaling
- [ ] Export the scatterplot image as a PDF
- [ ] Add support for Unicode characters
- [ ] Switch over from MySQL to CSV

###Word_Counter.py
- [ ] Add the option to filter out the 100 most-used words in the english language

###wordCountToWordCloud.r
- [ ] Export the wordcloud to PDF format

###Miscellaneous
- [ ] Move databaser.py to repo