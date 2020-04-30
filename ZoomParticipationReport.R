# This script's purpose is to take attendance through the Zoom chat by referencing 
# the roster downloaded from myUCLA and reporting predicted (occuring more than 10 times)
# participation words. 
# This was originally made for LS 7C where we ask the students to send in "participation words" in the chat
#  
# This script is meant to be run in a command line prompt (like Terminal for Mac) with Rscript
# in the directory where the files are located.
# Example: cd path_to_zoom_chat_and_roster_files/
#          Rscript ZoomParticipationReport.R
#
# The script needs at least the zoom chat file which is saved by Zoom as "meeting_saved_chat.txt" 
# If only the chat file is provided, it will output a more organized chat report
# If a roster is also provided, it will match chat names with the roster names. This script was made
# to handle roster files from myUCLA downloaded as  "Tab-Separated" (.tsv)
# If more than 10 of the same chats occur, then the script will output a report of those chats 
# (for discussion purposes those might be the participation checks)
# If the Zoom participants file is also provided, the report will also have roster name matching with the Zoom
# participants file.
#       (This file can be found on Zoom account page on the "Reports" tab, click on the number of participants 
#       and an export option should show up)
#
# More important details
# (1) The roster file must be as is, downloaded from myUCLA as .tsv
# (2) The chat file must have "chat" in its file name
# (3) The Zoom participants file must be as is, downloded from Zoom and have "participants" in the file name
# (4) No other files in the current working directory can match these descriptors
#

library(WriteXLS)

concatenate=function(myvect, mysep="")
{
  if(length(myvect)==0) return(myvect)
  if(length(myvect)==1) return(myvect)
  string = ""
  for(item in myvect){
    string = paste(string, item, sep = mysep)
  }
  string = substring(string, first=(nchar(mysep)+1))
  return(string)
}

files <- list.files("./")
if(length(files)<=1) cat("Error: Missing files. There should be 2 files: (1) the roster and (2) the saved chat\n")
roster <- files[grep("tsv", files)]
if(length(roster)>1) cat("Error: There should only be 1 roster file which is a .tsv file")
chat <- files[grep("chat", files)]
if(length(chat)>1) cat("Error: There should only be 1 meeting saved chat file")
zoom_particip <- files[grep("participants_", files)]
if(length(zoom_particip)>1) cat("Error: There should only be 1 Zoom participants file")

reportDuplicateMatching <- function(df, confidence_level){
  if(sum(duplicated(df$Roster_Name))>0){
    for(name in df$Roster_Name[duplicated(df$Roster_Name)]){
      cat(name, " matched multiple chat names at ", confidence_level, ". They are as follows:\n")
      print(df$Chat_Name[df$Roster_Name==name])
    }
  }
  if(sum(duplicated(df$Chat_Name))>0){
    for(name in df$Chat_Name[duplicated(df$Chat_Name)]){
      cat(name, " matched multiple roster names at ", confidence_level, ". They are as follows:\n")
      print(df$Roster_Name[df$Chat_Name==name])
    }
  }
}


matchRosterChatName <- function(roster_people = roster_people, chat_people = chat_people){
  missing_in_chat <- c()
  matched_names <- data.frame(stringsAsFactors = FALSE)
  one_name_match <- data.frame(stringsAsFactors = FALSE)
  grep_match <- data.frame(stringsAsFactors = FALSE)
  for(name in roster_people){
    vector_name = unlist(strsplit(name, split = " "))
    present <- unlist(sapply(X = chat_people, FUN = function(x){
      y <- x
      y <- unlist(strsplit(y, split = " "))
      if(length(intersect(y, vector_name))>=2){
        return(TRUE)
      }
      else{
        return(FALSE)
      }
    }))
    if(sum(present)==0){
      second_try <- unlist(sapply(X = chat_people, FUN = function(x){
        y <- x
        y <- unlist(strsplit(y, split = " "))
        if(length(intersect(y, vector_name))>=1){
          return(TRUE)
        }
        else{
          return(FALSE)
        }
      }))
    }
    else{
      matched_names <- rbind(matched_names,
                             data.frame("Roster_Name"=name,
                                        "Chat_Name"=chat_people[present],
                                        "Confidence"="high", 
                                        stringsAsFactors = FALSE))
      next
    }
    if(sum(second_try)==0){
      third_try <- lapply(X = vector_name, FUN = function(x){
        return(grepl(x, chat_people))
      })
      third_try_vect <- sapply(X = vector_name, FUN = function(x){
        return(grepl(x, chat_people))
      })
      if(sum(third_try_vect)==0){
        missing_in_chat <- c(missing_in_chat, name)
      }
      else{
        grep_matched_names <- unlist(lapply(third_try, function(x){return(chat_people[x])}))
        grep_matched_names = unique(grep_matched_names)
        for(grepname in grep_matched_names){
          grep_match <- rbind(grep_match,
                              data.frame("Roster_Name"=name,
                                         "Chat_Name"=grepname,
                                         "Confidence"="very low",
                                         stringsAsFactors = FALSE))
        }
      }
    }
    else{
      if(sum(second_try)==1){
        one_name_match <- rbind(one_name_match,
                                data.frame("Roster_Name"=name,
                                           "Chat_Name"=chat_people[second_try],
                                           "Confidence"="low",
                                           stringsAsFactors = FALSE))
      }
      else{
        # cat("Warning: ", name, " matched multiple chat names at low confidence:\n")
        # print(chat_people[second_try])
        for(chatname in chat_people[second_try]){
          one_name_match <- rbind(one_name_match,
                                  data.frame("Roster_Name"=name,
                                             "Chat_Name"=chatname,
                                             "Confidence"="low",
                                             stringsAsFactors = FALSE))
        }
      }
    }
  }

  one_name_match_final <- one_name_match[!(one_name_match$Chat_Name %in% matched_names$Chat_Name),]
  toBeMatched <- setdiff(one_name_match$Roster_Name, one_name_match_final$Roster_Name)
  
  for(name in toBeMatched){
    vector_name = unlist(strsplit(name, split = " "))
    third_try <- lapply(X = vector_name, FUN = function(x){
      return(grepl(x, chat_people))
    })
    third_try_vect <- sapply(X = vector_name, FUN = function(x){
      return(grepl(x, chat_people))
    })
    if(sum(third_try_vect)==0){
      missing_in_chat <- c(missing_in_chat, name)
    }
    else{
      grep_matched_names <- unlist(lapply(third_try, function(x){return(chat_people[x])}))
      grep_matched_names = unique(grep_matched_names)
      for(grepname in grep_matched_names){
        grep_match <- rbind(grep_match,
                            data.frame("Roster_Name"=name,
                                       "Chat_Name"=grepname,
                                       "Confidence"="very low",
                                       stringsAsFactors = FALSE))
      }
    }
  }
  
  grep_match_final <- grep_match[!(grep_match$Chat_Name %in% matched_names$Chat_Name),]
  toBeMatched <- setdiff(grep_match$Roster_Name, grep_match_final$Roster_Name)
  
  missing_in_chat <- c(missing_in_chat, toBeMatched)
  
  all_matched <- rbind(matched_names, one_name_match_final, grep_match_final)
  
  cat("\nNow Reporting whether there were duplicate matchings...\n")
  cat("(If none appear, none were detected)\n")
  reportDuplicateMatching(df = matched_names, confidence_level = "high confidence")
  reportDuplicateMatching(df = one_name_match_final, confidence_level = "low confidence")
  reportDuplicateMatching(df = grep_match_final, confidence_level = "very low confidence")
  cat("\n")
  
  
  return(list("MatchingResult"=all_matched, "Missing"=missing_in_chat))
}

if(length(roster)==1 & length(chat)==0 & length(zoom_particip)==1){
  cat("\nRoster file and Zoom participants file provided. Now running name matching...\n")
  cat("There may be many duplicate matchings because students will have slightly different name across zoom sessions.\n")
  zoom_particip <- read.delim(zoom_particip, header = TRUE, stringsAsFactors = FALSE, sep = ",")
  roster <- read.delim(roster, skip=8, stringsAsFactors = FALSE)
  roster$Name <- tolower(roster$Name)
  roster$Name <- gsub(",","", roster$Name)
  
  roster_people <- unique(roster$Name)

  chat_people = tolower(unique(zoom_particip$Name..Original.Name.))
  chat_people = chat_people[!grepl("\\[la\\]", chat_people)]
  
  cat("There are ", length(roster_people)," students.\n")
  cat("There are ", length(chat_people)," unique 'names' in the Zoom participants file.\n")
  
  matching_result <- matchRosterChatName(roster_people = roster_people, chat_people = chat_people)
  cat("The following students were not detected in the Zoom participants file.\n")
  print(matching_result[["Missing"]])
  matchings <- matching_result[["MatchingResult"]]
  matchings <- matchings[order(matchings$Roster_Name),]
  write.table(matchings, "Roster_Match_Zoom_Participants.txt", row.names = FALSE, quote = FALSE, sep = "\t")
  write.table(data.frame("Missing_Students"=matching_result[["Missing"]]), 
              "Missing_Roster_In_Zoom_Participants.txt", row.names = FALSE, quote = FALSE, sep = "\t")
  
  cat("\nReport done. Possible LAs are taken out.\n")
  
  rm(list=ls())
  
} else{

chat <- read.delim(chat, quote = "", stringsAsFactors = FALSE, header = FALSE)

colnames(chat) <- c("Time","All")

chat$Content <- sapply(chat$All, FUN = function(x){return(unlist(strsplit(x,split = " : "))[2])})

private_chat <- chat[grepl("Privately", chat$All),]
private_chat$Individual <- sapply(private_chat$All, FUN = function(x){return(unlist(strsplit(x,split = " to "))[1])})

chat <- chat[!grepl("Privately", chat$All),]
chat$Individual <- sapply(chat$All, FUN = function(x){return(unlist(strsplit(x,split = " : "))[1])})

chat <- rbind(chat, private_chat)
chat$Type <- ifelse(grepl("(Privately)",chat$All), "Private", "To everyone")

chat$Individual <- gsub(" From ","", chat$Individual)

chat = chat[order(chat$Time),]
chat <- chat[,c("Time","Individual","Type","Content","All")]

if(length(roster)==1){
  #lowercase all content and names
  chat$Content <- tolower(chat$Content)
  chat$Individual <- tolower(chat$Individual)
  
  roster <- read.delim(roster, skip=8, stringsAsFactors = FALSE)
  roster$Name <- tolower(roster$Name)
  roster$Name <- gsub(",","", roster$Name)
  
  chat_people <- unique(chat$Individual)
  roster_people <- unique(roster$Name)
  
  
  cat("There are ", length(roster_people)," students.\n")
  cat("There are ", length(chat_people)," participants in the chat.\n")
  
  matching_result <- matchRosterChatName(roster_people = roster_people, chat_people = chat_people)
  missing_in_chat <- matching_result[["Missing"]]
  all_matched <- matching_result[["MatchingResult"]]
  matched_names <- matching_result[["HiConfMatch"]]
  
  if(length(missing_in_chat)>0){
    cat("The following students were not matched with any chat names:\n")
    print(missing_in_chat)
    cat("These students did not attend or their chat name was not matched to their roster name. Please check chat names to see if the latter was the case.\n\n")
  }
  if(length(setdiff(unique(chat$Individual), unique(all_matched$Chat_Name)))>0){ 
    cat("The following chat names were not matched with anyone on the roster:\n")
    print(setdiff(unique(chat$Individual), unique(all_matched$Chat_Name)))
    cat("\n")
  }
  if(length(missing_in_chat)==0){ 
    cat("All students were matched with a chat name! Though, please check the Roster_Name_Chat_Name_Matching file, 
      especially for low and very low confidence matching for proper matching.\n\n")
  }
  
  long_chat=data.frame("Time"=chat$Time)
  long_chat$Chat_Name <- chat$Individual
  long_chat$Roster_Name <- sapply(long_chat$Chat_Name, function(x){
    if(x %in% all_matched$Chat_Name) return(concatenate(all_matched$Roster_Name[all_matched$Chat_Name==x], mysep = " OR "))
    else{
      return("no roster match")
    }
  })
  long_chat$Type <- ifelse(grepl("(Privately)",chat$All), "Private", "To everyone")
  long_chat$Chat_Content <- chat$Content
  
  time_ordered_chat <- long_chat[order(long_chat$Time),]
  
  name_ordered_chat <- long_chat[order(long_chat$Roster_Name),]
  
  
  
  ##### Detects whether there are "participation words" #####
  
  possible_participation_chats <- c()
  for(c in unique(chat$Content)){
    if(sum(chat$Content %in% c)>10){
      possible_participation_chats <- c(possible_participation_chats, c)
    }
  }
  
  if(length(possible_participation_chats>0)){
    ParticipationResultsByRoster <- data.frame(stringsAsFactors = FALSE)
    Individuals_missing = c()
    indices = c()
    for(word in possible_participation_chats){
      participating = unique(long_chat$Roster_Name[long_chat$Chat_Content==word | grepl(word,long_chat$Chat_Content)])
      indices = c(indices, which(long_chat$Chat_Content==word | grepl(word,long_chat$Chat_Content)))
      if(grepl(" ",word)){
        word_vect <- unlist(strsplit(word, split = " "))
        for(w in word_vect){
          participating = c(participating,
                            unique(long_chat$Roster_Name[grepl(w,long_chat$Chat_Content)]))
          indices = c(indices, which(grepl(w,long_chat$Chat_Content)))
        }
      }
      participating = unique(participating)
      not_participating = setdiff(unique(long_chat$Roster_Name), participating)
      not_participating = not_participating[!grepl("\\[la\\]", not_participating)]
      ParticipationResultsByRoster <- rbind(ParticipationResultsByRoster,
                                            data.frame("Chat"=word, 
                                                       "Participants"=concatenate(participating, mysep = ", "),
                                                       "Missing_Participants"=concatenate(not_participating, mysep = ", "),
                                                       stringsAsFactors = FALSE))
      Individuals_missing = c(Individuals_missing, not_participating)
    }
    
    ChatsFromRosterNonParticipants <- data.frame(stringsAsFactors = FALSE)
    for(i in Individuals_missing){
      ChatsFromRosterNonParticipants = rbind(ChatsFromRosterNonParticipants,
                                             long_chat[long_chat$Roster_Name==i,])
    }
    
    ChatsFromRosterNonParticipants <- ChatsFromRosterNonParticipants[!(ChatsFromRosterNonParticipants$Chat_Content %in% possible_participation_chats),]
    ChatsFromRosterNonParticipants <- ChatsFromRosterNonParticipants[!(grepl("\\[la\\]", ChatsFromRosterNonParticipants$Chat_Name)),]
    
    ParticipationResultsByChatName <- data.frame(stringsAsFactors = FALSE)
    Individuals_missing = c()
    for(word in possible_participation_chats){
      participating = unique(long_chat$Chat_Name[long_chat$Chat_Content==word | grepl(word,long_chat$Chat_Content)])
      indices = c(indices, which(long_chat$Chat_Content==word | grepl(word,long_chat$Chat_Content)))
      if(grepl(" ",word)){
        word_vect <- unlist(strsplit(word, split = " "))
        for(w in word_vect){
          participating = c(participating,
                            unique(long_chat$Chat_Name[grepl(w,long_chat$Chat_Content)]))
          indices = c(indices, which(grepl(w,long_chat$Chat_Content)))
        }
      }
      participating = unique(participating)
      not_participating = setdiff(unique(long_chat$Chat_Name), participating)
      not_participating = not_participating[!grepl("\\[la\\]", not_participating)]
      ParticipationResultsByChatName <- rbind(ParticipationResultsByChatName,
                                              data.frame("Chat"=word, 
                                                         "Participants"=concatenate(participating, mysep = ", "),
                                                         "Missing_Participants"=concatenate(not_participating, mysep = ", "),
                                                         stringsAsFactors = FALSE))
      Individuals_missing = c(Individuals_missing, not_participating)
    }
    
    ChatsFromChatNameNonParticipants <- data.frame(stringsAsFactors = FALSE)
    for(i in Individuals_missing){
      ChatsFromChatNameNonParticipants = rbind(ChatsFromChatNameNonParticipants,
                                               long_chat[long_chat$Chat_Name==i,])
    }
    
    ChatsFromChatNameNonParticipants <- ChatsFromChatNameNonParticipants[!(ChatsFromChatNameNonParticipants$Chat_Content %in% possible_participation_chats),]
    ChatsFromChatNameNonParticipants <- ChatsFromChatNameNonParticipants[!(grepl("\\[la\\]", ChatsFromChatNameNonParticipants$Chat_Name)),]
    
    indices = unique(indices)
    participation_chats <- long_chat[indices,]
    participation_chats <- participation_chats[nchar(participation_chats$Chat_Content)<30,]
    
    ParticipationWordResults <- data.frame("Roster_Name"=unique(long_chat$Roster_Name[long_chat$Roster_Name!="no roster match"]))
    ParticipationWordResults$Words <- sapply(ParticipationWordResults$Roster_Name, function(x){
      return(concatenate(participation_chats$Chat_Content[participation_chats$Roster_Name==x], mysep = ", "))
    })
    ParticipationWordResults$Number <- sapply(ParticipationWordResults$Roster_Name, function(x){
      return(length(participation_chats$Chat_Content[participation_chats$Roster_Name==x]))
    })
    ParticipationWordResults$Sent_all_words <- ifelse(ParticipationWordResults$Number>=length(possible_participation_chats), "Yes","No")
    ParticipationWordResults = rbind(ParticipationWordResults, 
                                     data.frame("Roster_Name"=missing_in_chat,
                                                "Words"="Did not match any chat name, possibly not attending student",
                                                "Number"="",
                                                "Sent_all_words"=""))
    ParticipationWordResults = ParticipationWordResults[order(ParticipationWordResults$Roster_Name),]
    cat("There were ", length(possible_participation_chats),"predicted participation words.\n")
    print(possible_participation_chats)
    for(wd in possible_participation_chats){
      cat("For the ", wd, "participation check, the students on the roster who missed it were:\n")
      students <- ParticipationResultsByRoster$Missing_Participants[ParticipationResultsByRoster$Chat==wd]
      students <- unlist(strsplit(students, split = ", "))
      students <- students[!grepl("no roster match", students)]
      print(students)
    }
    cat("These students may have misspelled the participation word. Check the 'Chats NonParticipat Roster' result. Missing students are not included here.\n\n")
  }
  
  wide_chat <- data.frame("Chat_Name"=unique(long_chat$Chat_Name))
  wide_chat$Roster_Name <- sapply(wide_chat$Chat_Name, function(x){
    return(concatenate(unique(long_chat$Roster_Name[long_chat$Chat_Name==x]), mysep = " OR "))
  })
  wide_chat$Time <- sapply(wide_chat$Chat_Name, function(x){
    return(concatenate(long_chat$Time[long_chat$Chat_Name==x], mysep = ", "))
  })
  wide_chat$Chat_Content <- sapply(wide_chat$Chat_Name, function(x){
    return(concatenate(long_chat$Chat_Content[long_chat$Chat_Name==x], mysep = ", "))
  })
  
  result <- list()
  
  if(length(missing_in_chat)>0){
    result[["Missing Students"]] <- rbind(data.frame("Missing_Students"=missing_in_chat),
                                          data.frame("Missing_Students"="Reminder: some student names from the roster may not have matched to a chat name. Please check the chat names for a possible match. In addition, please review the matched roster and chat names because a chat name may have mistakenly been matched to someone on the roster."))
  } else {result[["Missing Students"]] <- data.frame("Missing_Students"="None! Remember some chat names may be inappropriately matched with a roster name")}
  
  
  if(length(setdiff(unique(chat$Individual), unique(all_matched$Chat_Name)))>0){ 
    result[["ChatNames No Match to Roster"]] <- data.frame("Chat_Name"=c(setdiff(unique(chat$Individual), 
                                                                                 unique(all_matched$Chat_Name)),
                                                                         "Reminder: Check if these chat names may be one of your missing roster students"))
  }
  
  if(length(possible_participation_chats)>0){
    result[["Participation results"]] <- ParticipationWordResults
    ChatsFromRosterNonParticipants <- rbind(ChatsFromRosterNonParticipants,
                                            data.frame("Time"="This file exists to see if the student did put the participation word but misspelled it, for example.",
                                                       "Chat_Name"="",
                                                       "Roster_Name"="",
                                                       "Type"="",
                                                       "Chat_Content"="", stringsAsFactors = FALSE))
    result[["Chats NonParticipat Roster"]] <- ChatsFromRosterNonParticipants
  }
  result[["RosterName ChatName Matching"]] <- all_matched
  result[["All chat long"]] <- time_ordered_chat
  result[["All chat long roster order"]] <- name_ordered_chat
  result[["All chat wide"]] <- wide_chat
  
  if(length(possible_participation_chats)>0){
    result[["Participation chat"]] <- participation_chats
    result[["Partic result by word Roster"]] <- ParticipationResultsByRoster
    result[["Partic result by word ChatName"]] <- ParticipationResultsByChatName
    result[["Chats NonParticipat ChatNames"]] <- ChatsFromChatNameNonParticipants
  } else cat("There were no predicted participation checks in which the same word was prompted.\n")
  
  if(length(zoom_particip)==1){
    zoom_particip <- read.delim(zoom_particip, header = TRUE, stringsAsFactors = FALSE, sep = ",")
    cat("Zoom participants file present. Now making results for this file...\n")
    cat("There may be many duplicate matchings because students will have slightly different name across zoom sessions...\n")
    chat_people = tolower(unique(zoom_particip$Name..Original.Name.))
    chat_people = chat_people[!grepl("\\[la\\]", chat_people)]
    matching_result <- matchRosterChatName(roster_people = roster_people, chat_people = chat_people)
    cat("The following students were not detected in the Zoom participants file.\n")
    print(matching_result[["Missing"]])
    matchings <- matching_result[["MatchingResult"]]
    matchings <- matchings[order(matchings$Roster_Name),]
    result[["Roster_Match_Zoom_Particip"]] <- matching_result[["MatchingResult"]]
    result[["Roster_Missing_Zoom_Particip"]] <- data.frame("Missing_Students"=matching_result[["Missing"]])
  }
  
  
  WriteXLS(result, "Participation_Results.xls", SheetNames = names(result))
  cat("\nReport done. Saved in 'Participation_Results.xls' in current working directory.\n")
} else{
  cat("Roster not detected. Assuming that user just wants a chat report. Outputting chat report in long and wide format.\n")
  cat("...\n")
  chat$All <- NULL
  write.table(chat,"Chat_Report_Long.txt", row.names = FALSE, quote = FALSE, sep = "\t")
  wide_chat <- data.frame("Chat_Name"=unique(chat$Chat_Name))
  wide_chat$Time <- sapply(wide_chat$Chat_Name, function(x){
    return(concatenate(chat$Time[chat$Chat_Name==x], mysep = ", "))
  })
  wide_chat$Chat_Content <- sapply(wide_chat$Chat_Name, function(x){
    return(concatenate(chat$Chat_Content[chat$Chat_Name==x], mysep = ", "))
  })
  write.table(chat,"Chat_Report_Wide.txt", row.names = FALSE, quote = FALSE, sep = "\t")
  cat("Done. Saved in current working directory.\n")
}

rm(list=ls())
}





