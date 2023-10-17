﻿#Storyline: Review the security Event log

#User input

#Directory to save files:
$myDir = "C:\Users\champuser\Desktop\"

#List all the available windows event logs
Get-EventLog -List

#Create a prompt to allow user to select the log to view
$readLog = Read-Host -Prompt "Please select a log to review from the list above"

# Create a prompt for the user to specify a keyword or phrase to search on
$searchKeyword = Read-Host -Prompt "Please enter a keyword or phrase to search within the logs"


#Print the results for the log
Get-EventLog -LogName $readLog | where {$_.Message -ilike "*$searchKeyword*" } | Export-Csv -NoTypeInformation -Path "$myDir\securityLogs.csv"

# Task: create a prompt that allows the user to specify a keyword or phrase to search on
# Find a string from your event logs to search on. 


