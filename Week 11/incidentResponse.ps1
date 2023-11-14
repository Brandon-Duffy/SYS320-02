# Week 11 - Incident response.

# prompt for the output directory
$outputDir = Read-Host -Prompt 'Enter the location to save the results'

# 1. retrieve running processes
$processes = Get-Process | Select-Object ProcessName, Path
$processes | Export-Csv -Path "$outputDir\processes.csv" -NoTypeInformation

# 2. retrieve registered services. 
$services = Get-WmiObject -Class Win32_Service | Select-Object Name, PathName
$services | Export-Csv -Path "$outputDir\services.csv" -NoTypeInformation

# 3. retrieve TCP network sockets. 
$tcpSockets = Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State
$tcpSockets | Export-Csv -Path "$outputDir\tcpSockets.csv" -NoTypeInformation

# 4. retrieve the user account information
$users = Get-WmiObject -Class Win32_UserAccount | Select-Object Name, FullName, Disabled, PasswordChangeable, PasswordExpires
$users | Export-Csv -Path "$outputDir\userAccounts.csv" -NoTypeInformation

# 5. retrieve network adapter information
$networkAdapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object Description, IPAddress, IPSubnet, DefaultIPGateway
$networkAdapters | Export-Csv -Path "$outputDir\networkAdapterConfiguration.csv" -NoTypeInformation

# 6. four additional cmdlets to gather information. 
# System Event Logs

# Chose this because these logs are a record of significant events on the system like system changes, hardware and driver failures, and other system level notifications. In an investigation, these logs would show events leading up to an incident, like unexpected shutdowns.
Get-EventLog -LogName System -Newest 50 | Export-Csv -Path "$outputDir\systemEvents.csv" -NoTypeInformation

# Security Event Logs

# Chose this because these logs have security related events like account logon events, policy changes, etc. In an investigation, this is useful for detecting potential breaches, unauthorized access attempts, etc. 

Get-EventLog -LogName Security -Newest 50 | Export-Csv -Path "$outputDir\securityEvents.csv" -NoTypeInformation

# Installed Programs

# This shows the installed programs on the system, and in an investigation it would show and program that investigators could determine if they are malicious or not. 

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, InstallDate | Export-Csv -Path "$outputDir\installedPrograms.csv" -NoTypeInformation

# Firewall Rules

# This is useful because it retrievs firewall rules, to include the rule names and status. In an investigation this is useful to understand the networks security potsure which would allow for the analyzing of any malicious traffic on the network. 

Get-NetFirewallRule | Select-Object Name, Enabled, Action, Direction, Profile | Export-Csv -Path "$outputDir\firewallRules.csv" -NoTypeInformation

# Create FileHash of each CSV file and save results to a file
$csvFiles = Get-ChildItem -Path $outputDir -Filter *.csv
foreach ($file in $csvFiles) {
    $hash = Get-FileHash -Path $file.FullName -Algorithm SHA1
    "$($hash.Hash)  $($file.Name)" | Out-File -FilePath "$outputDir\checksums.txt" -Append
}

# compress the results directory
$zipFile = "$outputDir\..\Results.zip"
Compress-Archive -Path $outputDir -DestinationPath $zipFile

# create checksum for the zip file
$zipHash = Get-FileHash -Path $zipFile -Algorithm SHA1
"$($zipHash.Hash)  Results.zip" | Out-File -FilePath "$outputDir\..\ResultsChecksum.txt"
