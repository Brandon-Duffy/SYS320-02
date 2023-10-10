#!/bin/bash

# Prompt the user for the apache log file path
read -p "Please enter an apache log file: " tFile

# Check if the entered apache log file exists
if [[ ! -f ${tFile} ]]; then
    echo "The provided file doesn't exist."
    exit 1
fi

# Parse the Apache log for unique IP addresses, extract only the first field, sort, and remove duplicates
IP_LIST=$(awk '{print $1}' "$tFile" | sort -n | uniq)

# Create IPTables rules for each IP
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

if [ $TOTAL_IPS -eq $RULES_ADDED ]; then
    echo "All IPTables rules were created successfully."
else
    echo "Some IPTables rules were not created. Check above for details."
fi

exit 0
