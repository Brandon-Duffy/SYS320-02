#!/bin/bash

# This script performs local security checks to ensure system compliance with security policies

# Defining a function 'checks' that compares the current setting to the expected value and provides the remediation if they don't match
function checks() {
    if [[ $2 != $3 ]] # If the current value doesn't match the expected value
    then
        echo "The $1 is not compliant. Remediation: $4" # Print the remediation step
    else
        echo "The $1 is compliant. Current Value $3." # Confirm that the setting is compliant
    fi
}

# Checking various system configurations and file permissions against the recommended settings and providing remediation steps where necessary

# Password Policies
# Checking the Password maximum days policy
pmax=$(egrep -i '^PASS_MAX_DAYS' /etc/login.defs  | awk ' { print $2 } ') 
checks "Password max days" "365" "${pmax}" "Modify the PASS_MAX_DAYS value in /etc/login.defs to 365" 

# Checking the minimum days between password changes
pmin=$(egrep -i '^PASS_MIN_DAYS' /etc/login.defs  | awk ' { print $2 } ')
checks "Password Min Days" "14" "${pmin}" "Modify the PASS_MIN_DAYS value in /etc/login.defs to 14"

# Checking the warning age for password expiry
pwarn=$(egrep -i '^PASS_WARN_AGE' /etc/login.defs  | awk ' { print $2 } ')
checks "Password Warn Age" "7" "${pwarn}" "Modify the PASS_WARN_AGE value in /etc/login.defs to 7"

# SSH Configuration
# Checking the SSH UsePAM configuration
chkSSHPAM=$(egrep -i "^UsePAM" /etc/sshd_config | awk ' {print $2 }' )
checks "SSH UsePAM" "yes" "${chkSSHPAM}" "Set UsePAM to yes in /etc/sshd_config"

# Home Directory Permissions
# Check permissions on users' home directory
echo "Checking home directories:"
for eachDir in $(ls -l /home | grep '^d' | awk ' { print $3 } ')
do
    chDir=$(ls -ld /home/${eachDir} | awk ' { print $1 } ' )
    checks "Home directory ${eachDir}" "drwx------" "${chDir}" "Run chmod 700 /home/${eachDir}"
done

# Network Configurations
checks "IP Forwarding" "$(sysctl -n net.ipv4.ip_forward)" "0" "Set net.ipv4.ip_forward to 0 in /etc/sysctl.conf"
checks "ICMP Redirects" "$(sysctl -n net.ipv4.conf.all.accept_redirects)" "0" "Set net.ipv4.conf.all.accept_redirects to 0 in /etc/sysctl.conf"

# File Permissions, stat displays info about the file, -c %a displays file permissions. 
checks "Permissions on /etc/crontab" "$(stat -c %a /etc/crontab)" "600" "Run chmod 600 /etc/crontab"
checks "Permissions on /etc/cron.hourly" "$(stat -c %a /etc/cron.hourly)" "700" "Run chmod 700 /etc/cron.hourly"
checks "Permissions on /etc/cron.daily" "$(stat -c %a /etc/cron.daily)" "700" "Run chmod 700 /etc/cron.daily"
checks "Permissions on /etc/cron.weekly" "$(stat -c %a /etc/cron.weekly)" "700" "Run chmod 700 /etc/cron.weekly"
checks "Permissions on /etc/cron.monthly" "$(stat -c %a /etc/cron.monthly)" "700" "Run chmod 700 /etc/cron.monthly"
checks "Permissions on /etc/passwd" "$(stat -c %a /etc/passwd)" "644" "Run chmod 644 /etc/passwd"
checks "Permissions on /etc/shadow" "$(stat -c %a /etc/shadow)" "000" "Run chmod 000 /etc/shadow"
checks "Permissions on /etc/group" "$(stat -c %a /etc/group)" "644" "Run chmod 644 /etc/group"
checks "Permissions on /etc/gshadow" "$(stat -c %a /etc/gshadow)" "000" "Run chmod 000 /etc/gshadow"
checks "Permissions on /etc/passwd-" "$(stat -c %a /etc/passwd-)" "600" "Run chmod 600 /etc/passwd-"
checks "Permissions on /etc/shadow-" "$(stat -c %a /etc/shadow-)" "600" "Run chmod 600 /etc/shadow-"
checks "Permissions on /etc/group-" "$(stat -c %a /etc/group-)" "600" "Run chmod 600 /etc/group-"
checks "Permissions on /etc/gshadow-" "$(stat -c %a /etc/gshadow-)" "600" "Run chmod 600 /etc/gshadow-"

# Legacy Entries
checks "Legacy '+' entries in /etc/passwd" "$(grep '^+:' /etc/passwd)" "" "Edit /etc/passwd and remove any lines starting with '+'"
checks "Legacy '+' entries in /etc/shadow" "$(grep '^+:' /etc/shadow)" "" "Edit /etc/shadow and remove any lines starting with '+'"
checks "Legacy '+' entries in /etc/group" "$(grep '^+:' /etc/group)" "" "Edit /etc/group and remove any lines starting with '+'"

# UID Checks
checks "UID 0 accounts" "$(awk -F: '($3 == 0) {print $1}' /etc/passwd)" "root" "Remove any UID 0 accounts except root"
