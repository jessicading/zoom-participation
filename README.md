# Zoom Participation Report
This R script is designed to "take attendance" from the Zoom chat or Zoom participants file by referencing the roster downloaded from myUCLA.

If the chat file and roster file are provided, the script will report the roster name and chat name matching result (and missing students), organized chat reports, and if a specific chat occurs more than 10 times, it will be considered a "participation check" and a report for those checks will be made as well.

If a Zoom participants file is also provided, the result will include Zoom participants and roster name matching (and missing students). If only the roster file and Zoom participants file are provided, this will be the only result outputted. 

If only a chat file is provided, the output will be an organized chat in long and wide formats.

### Files 
1. <b>Chat file.</b> This is saved from the Zoom room as "meeting_saved_chat.txt".<br/>
2. <b>Roster file.</b> This is the "Tab-Separated" roster downloaded from myUCLA.<br/>
3. <b>Zoom Participants file.</b> This is the "participants_meetingid.csv" from your Zoom account page.<br/>

To reiterate the text above, possible combinations of files are (1) only <b>Chat file</b>, (2) <b>Chat file</b> and <b>Roster file</b>, (3) <b>Roster file</b> and <b>Zoom Participations file</b>, and (4) <b>Chat file</b>, <b>Roster file</b>, and <b>Zoom Participants file</b>. 


### Install R and WriteXLS
R is needed to run the script. You can install it [here](https://www.r-project.org).<br/>
The script uses the package WriteXLS. You can download it in R using ```install.packages("WriteXLS")```.

You can open R in Terminal (on Mac) by typing ```R``` and return. This should open R and you can start writing R commands.

```R
install.packages("WriteXLS")
```

If you have difficulty installing WriteXLS, I can send you a version of the script that outputs the result as .txt instead of .xls.

### Run the script
Download the script and put the files in a new directory. (cannot have multiple chat/roster/Zoom participants files)

In Terminal, change current directory to the directory where the files are located. Then run the R script.

```bash
cd path_to_directory_with_files/
Rscript path_to_script/ZoomParticipationReport.R
```
An example is given in the repository - "Run_ZoomParticipationReport_on_Terminal_Example.txt"

The command line prompt will output some results and all results are saved in the Participation_Results.xls file.

#### Downloading Zoom participants file
In your Zoom acount page, go to the "Reports" tab. You will see the number of participants for each meeting as a link. Click on the link and export the results by clicking on the blue "Export" button. You can also choose the participants for a specific time period.


#### Additional notes
Please report any issues or suggestions in this repository or email me jading@ucla.edu.

The easiest way to match Zoom participants with roster names is to have Zoom participants send their university ID in the chat (privately). This script matches the names based on similarity and does not account for students sending UIDs. The script can be updated to include this functionality.

Please leave files as is (as downloaded from myUCLA, from the Zoom room, and from your Zoom account)! You can append rosters from different discussions together but have the 8 line header at the top for the roster file (and delete it for the subsequent appended sections). The script skips those first 8 lines. The chat file should be a .txt file with "chat" in its file name. The roster should be a .tsv file. The Zoom participants file should be a .csv file with "participants_" in its file name.

This script was made specifically for LS 7C where participation checks are made sometimes more than once during the discussion.



