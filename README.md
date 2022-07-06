# actogram-gift
Use the script ‘apple-actogram-gift.R’ in this github repository to make an actogram based on Apple health data step counts. See more information here: https://laurakervezee.net/actogram-gift-using-iphone-step-count/

Make the following changes:
- In Line 20, change ‘XYZ’ to the name of the person.
- In line 25-26, specify the desired start & end dates (depending on the availability of the data). I used one year of data to create the actogram, which looked good, but you can also play around with shorter or longer durations and see what the result looks like.
- Line 28: specify the time zone in which the data was collected. A list of abbreviations can be found here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations  
- Line 31: specify the location of the export.xml file, so R knows where to find it (or use an R project file).

Make sure the required packages (line 15-17) are installed. Otherwise, first run install.packages(c("tidyverse", "lubridate", "XML")).

Run the entire script. The actogram is saved as a PDF and PNG in your working directory.