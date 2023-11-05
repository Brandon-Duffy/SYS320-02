function select_service_status() {
    do {
        cls
        # Prompt the user for the service status to view or quit.
        $serviceStatus = Read-Host -Prompt "Enter 'all' to view all services, 'stopped' for only stopped services, 'running' for running services, or 'q' to quit the program"

        # Check if the user wants to quit.
        if ($serviceStatus -eq 'q') {
            Write-Host "Exiting the program..."
            return
        }
        # DID NOT USE THE TIP
        # Define valid inputs
        $validInputs = @('all', 'stopped', 'running')

        # Check that the user specified only 'all', 'stopped', or 'running' as a value
        if ($serviceStatus -in $validInputs) {
            # Call the function to display the services based on the user's choice
            display_services -status $serviceStatus
        } else {
            Write-Host -BackgroundColor Red -ForegroundColor White "Invalid input, please enter 'all', 'stopped', or 'running'."
            Start-Sleep -Seconds 2
        }
    } while ($serviceStatus -notin $validInputs)
}

function display_services() {
    param([string]$status)

    cls

    switch ($status) {
        'all' {
            $services = Get-Service
            break
        }
        'stopped' {
            $services = Get-Service | Where-Object { $_.Status -eq 'Stopped' }
            break
        }
        'running' {
            $services = Get-Service | Where-Object { $_.Status -eq 'Running' }
            break
        }
    }

    # display the services
    $services | Format-Table -Property DisplayName, Status

    # pause the screen and wait until the user is ready to proceed.
    Read-Host -Prompt "Press Enter when you are done"
}

# call the function. 
select_service_status
