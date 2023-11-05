function select_log() {
    
    cls

    # List all the event logs
    $theLogs = Get-EventLog -list | select Log
    $TheLogs | Out-Host

    # Initialize the array to store the logs
    $arrLog = @()

    foreach ($tempLog in $theLogs) {

        # Add each log to the array
        # note, these are stored in the array as a hashtable in the format:
        # @{Log=LOGNAME}
        $arrLog += $tempLog
    }

    # Test to be sure our array is being populated
    write-host $arrLog[0]

    # Prompt the user for the log to view or quit.
    $readLog = read-host -Prompt "please enter a log from the list above or 'q' to quit the program"

    # check if the user wants to quit.
    if ($readLog -match "^[qQ]$") {

        # stop executing the program and close the script
        break

    }

    log_check -logToSearch $readLog

} # ends the select_log()


function log_check() {

    # String the user types in within the select_log function
    Param([string]$logToSearch)

    # format the user input.
    # example: @{Log=glassbottle}
    $theLog = "^@{Log=" + $logToSearch + "}$"

    # search the array for the exact hashtable string
    if ($arrLog -match $theLog){

        write-host -BackgroundColor Green -ForegroundColor white "Please wait, it may take a few moments to retrieve the log entries"
        sleep 2

        # call the function to view the log. 
        view_log -logToSearch $logToSearch

    } else {
        write-host -BackgroundColor red -ForegroundColor white "the log specified doesnt exist"
        sleep 2
        select_log

    }

}


function view_log() {

    cls

    # Get the logs 
    Get-EventLog -Log $logToSearch -Newest 10 -after "1/18/2020"

    # pause the screen and wait until the user is ready to proceed.
    read-host -Prompt "press enter when you are done"

    # go back to select_log
    select_log

} # ends the view_log()

# run the select_log as the first function
select_log



