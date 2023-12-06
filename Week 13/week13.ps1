# Array of websites with threat intel
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules','https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

# Loop through the URLs for the rules list
foreach ($u in $drop_urls) {
    # Correctly extract the file name
    $temp = $u.split("/")
    $file_name = $temp[-1]

    if (Test-Path $file_name) {
        
        continue

     } else {
        # Download the rules list
        Invoke-WebRequest -Uri $u -OutFile $file_name
    }
}

# Array containing the file name

$input_paths = @('.\compromised-ips.txt','.\emerging-botcc.rules')

# Extract the IP addresses

$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP addresses to the temporary IP list

select-string -Path $input_paths -Pattern $regex_drop | `
ForEach-Object { $_.Matches } | `
ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath "ips-bad.tmp"

# Get the IP addresses discovered, loop through and replace the beginning of the line with the IPTables syntax
# After the IP addresses, add the remaining IPTables syntax and save the results to a file.
# iptables -A INPUT -s 108.191.2.72 -j DROP

(Get-Content -Path ".\ips-bad.tmp") | % `
{ $_ -replace "^","iptables -A INPUT -s " -replace "$", " -j DROP" } | `
Out-File -FilePath "iptables.bash"

# Use a switch statement to create an IPTables and Windows firewall ruleset with the assignment from class that blocks the IPs.
$firewallType = 'Windows' # Change this to 'IPTables' to generate IPTables rules

switch ($firewallType) {
    "Windows" {
        # Create Windows Firewall rules
        $windowsCommands = @()
        Get-Content -Path ".\ips-bad.tmp" | ForEach-Object {
            $windowsCommands += "New-NetFirewallRule -DisplayName 'Block $_' -Direction Inbound -Action Block -RemoteAddress $_"
        }
        # Write the commands to a PowerShell script file
        $windowsCommands | Out-File -FilePath "windows-firewall.ps1"
    }
    "IPTables" {
        # Create IPTables rules
        $iptablesCommands = @()
        Get-Content -Path ".\ips-bad.tmp" | ForEach-Object {
            $iptablesCommands += "iptables -A INPUT -s $_ -j DROP"
        }
        # Write the commands to a file
        $iptablesCommands | Out-File -FilePath "iptables-rules.sh"
    }
    Default {
        Write-Host "Unsupported firewall type. Please set \$firewallType to either 'Windows' or 'IPTables'."
    }
}
