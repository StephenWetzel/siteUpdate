Site Update by Stephen Wetzel January 11th 2013
checks for updates to websites
downloads source of web page and extracts a user specified portion
runs diff on that source every time it's ran to check for updates
if an update is found it dumps it to stdout
run with cron, and redirect stdout to email 

put sites in the /sites/ directory
one text file per site
line one is the url
line two is the starting text (can be left blank to start at begining of file)
line three is the ending text (can be left blank)
following lines are ignored
