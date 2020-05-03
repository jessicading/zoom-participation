# Zoom Participation Report
<em>Currently in beta phase. Need more independent testing to assess robustness. Please let me know if it worked for you or whether you'd like any changes :) </em>

This R script is designed to "take attendance" from the Zoom chat or Zoom participants file by referencing the roster downloaded from myUCLA.

If the chat file and roster file are provided, the script will report the roster name and chat name matching result (and missing students), organized chat reports, and if a specific chat occurs more than 10 times, it will be considered a "participation check" and a report for those checks will be made as well.

If a Zoom participants file is also provided, the result will include Zoom participants and roster name matching (and missing students). If only the roster file and Zoom participants file are provided, this will be the only result outputted. 

If only a chat file is provided, the output will be an organized chat in long and wide formats.

### Files 
*** Having all three is not required.<br/>
*** Multiple of each is allowed. This is particularly useful to run multiple sections.
1. <b>Chat file.</b> This is saved from the Zoom room as "meeting_saved_chat.txt".<br/>
2. <b>Roster file.</b> This is the "Tab-Separated" roster downloaded from myUCLA.<br/>
3. <b>Zoom Participants file.</b> This is the "participants_meetingid.csv" [downloaded from your Zoom account page](#downloading-zoom-participants-file).<br/>

To reiterate the text above, possible combinations of files are (1) only <b>Chat file</b>, (2) <b>Chat file</b> and <b>Roster file</b>, (3) <b>Roster file</b> and <b>Zoom Participants file</b>, and (4) <b>Chat file</b>, <b>Roster file</b>, and <b>Zoom Participants file</b>.<br/>
See [additional file information](#important-file-format-informatiom). 

### Install R and WriteXLS
R is needed to run the script. You can install it [here](https://www.r-project.org).<br/>
The script uses the package WriteXLS. You will need to have Perl and certain Perl modules. More information can be found [here](https://github.com/marcschwartz/WriteXLS/blob/master/INSTALL). Once you have Perl and the Perl modules, you can install the WriteXLS package in R using ```install.packages("WriteXLS")```.

You can open R in Terminal (on Mac) by typing ```R``` and return. This should open R and you can start writing R commands.

```R
install.packages("WriteXLS") # install
library(WriteXLS) # check that it was installed
testPerl() # checks that you have the required Perl modules
```

If you have difficulty installing WriteXLS, download ZoomParticipationTxtReport.R and follow the instructions below. Using the WriteXLS package is recommended because it puts all the results in a .xls workbook. 

### Run the script
Download the "ZoomParticipationReport.R" script from this repository. Put your Zoom/roster files in a new directory. (cannot have multiple chat/roster/Zoom participants files)

In Terminal, change your current directory to the directory where the files are located. Then run the R script (make sure to put the path of the script if not in the current directory).

```bash
cd path_to_directory_with_files/
Rscript path_to_script/ZoomParticipationReport.R
```
An example is given in the repository - "Run_ZoomParticipationReport_on_Terminal_Example.txt"

The command line prompt will output some results and all results are saved in the Participation_Results.xls file (or a series of .txt files if you are using ZoomParticipationTxtReport.R).

You can also run this in R by setting your working directory to the path and copy and pasting the commands in the ZoomParticipationReport.R file to the R command prompt.

```R
setwd("path_to_directory_with_files/")
# paste R commands from ZoomParticipationReport.R
```

#### Downloading Zoom participants file
In your Zoom account page, go to the "Reports" tab and then click on "Usage". You will see the number of participants for each meeting as a link. Click on the link and export the results by clicking on the blue "Export" button. You can also choose the participants for a specific time period.

#### Important file format informatiom
Leave files as is (as downloaded from myUCLA, from the Zoom room, and from your Zoom account)! They should already adhere to the requirements listed below.
1. <b>Roster file:</b> Must be a .tsv file. The 8 line header must be there (the script skips those first 8 lines). If multiple roster files are provided, the script will append them and output a new Appended_Roster.tsv file. If you want to use this file for subsequent runs, you will have to add 8 lines to the beginning. You can also manually append rosters but have the 8 line header at the top and delete the header for subsequent appended sections. 
2. <b>Chat file:</b> Must have "chat" or ".txt" in its file name.
3. <b>Zoom participants:</b> Must be a .csv file. 

#### Additional notes
Please report any issues or suggestions in this repository or email me jading@ucla.edu.

The easiest way to match Zoom participants with roster names is to have Zoom participants send their university ID in the chat (privately). This script matches the names based on similarity and does not account for students sending UIDs. The script can be updated to include this functionality.

This script was made specifically for LS 7C where participation checks are made sometimes more than once during the discussion.

If you'd like to sponsor me to build and host a webserver, let me know. :)



