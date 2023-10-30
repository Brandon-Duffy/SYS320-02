# get-wmiobject -list | where { $_.Name -ilike "win32_[n-z]*" } | sort-object

# Get-wmiobject -Class Win32_Account | get-member


# Task: Grab the network adapter information using the WMI class
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | 
    Where-Object { $_.IPEnabled -eq $true } | 
    Select-Object -Property Description, DHCPServer, DNSServerSearchOrder



# Get the IP address, default gateway, and the DNS servers.

#2 Export the list of running processes

Get-Process | Export-Csv -Path "C:\Users\champuser\Desktop\SYS\running_processes.csv" -NoTypeInformation

Get-Service | Where-Object { $_.Status -eq 'Running' } | Export-Csv -Path "C:\Users\champuser\Desktop\SYS\running_services.csv" -NoTypeInformation

#Calculator script


# Start the calc, PassThru allows to outut process object. 
$calc = Start-Process "calc" -PassThru

# pressing enter allows the script to close the application
Read-Host -Prompt "Press Enter to stop Calculator"


#could not figure out how to stop the calculator without pressing a key in the powershell terminal. 


# stopping the calculator
try {
    # find the calculator
    $calcProcess = Get-Process | Where-Object { $_.MainWindowTitle -like "*calc*" }
    if ($calcProcess) {
        Stop-Process -Id $calcProcess.Id -Force
        Write-Host "calculator process has been stopped."
    } else {
        Write-Host "calculator process not found."
    }
} catch {
    Write-Host "could not stop calculator, is it running?."
}
