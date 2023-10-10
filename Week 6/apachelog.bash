#!/bin/bash

# ask the user to enter a log file
read -p "Please enter an apache log file: " tFile

# Check if the apache log file exists
if [[ ! -f ${tFile} ]]; then
    echo "The file doesn't exist."
    exit 1
fi

# Parsing the apache log for unique IP addresses, print only first field and remove the duplicates
# using awk to take the first field (IP address) from the file and then sort it. 
IP_LIST=$(awk '{print $1}' "$tFile" | sort -n | uniq)

# Loop through the log file and IPTables rules for each IP
for IP in $IP_LIST; do
    # Add a rule to block the IP.
    iptables -A INPUT -s $IP -j DROP
    if [ $? -eq 0 ]; then
        echo "IPTables rule added successfully for IP: $IP"
        RULES_ADDED=$((RULES_ADDED + 1))
    else
        echo "Failed to add IPTables rule for IP: $IP"
    fi
done

echo "--------------------------------------------"
echo "Total IPs parsed from log: $TOTAL_IPS"
echo "Total IPTables rules added successfully: $RULES_ADDED"
# this compares the successfully added rules. 
if [ $TOTAL_IPS -eq $RULES_ADDED ]; then
    echo "All IPTables rules were created successfully"
else
    echo "Some IPTables rules were not created"
fi

exit 0
