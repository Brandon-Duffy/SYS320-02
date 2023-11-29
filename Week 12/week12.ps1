# Login to a remote SSH server
Import-Module Posh-SSH
New-SSHSession -ComputerName '192.168.50.24' -Credential (Get-Credential champuser)

<#
while ($true) {

# Add a prompt to run commands

$the_cmd = read-host -Prompt "please enter a command"

# Run command on remote SSH server

Invoke-SSHCommand -index 0 $the_cmd).Output


}
#>

Set-SCPFile -ComputerName '192.168.50.24' -Credential (Get-credential champuser) `
-RemotePath '/home/Desktop' -LocalFile 'C:\Users\champuser\Desktop\cat.jpg' -Verbose