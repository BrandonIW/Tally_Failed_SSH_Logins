#!/bin/bash

# This program simply uses a regular expression to parse through a file for 
# the contents of "Failed password" and then pulls the IP address from that line
# Then the results are tallied up for the IP addresses

function main () {
	awk -F: '/sshd.*Failed\spassword/ {print $4}' auth.log > Failed_Logins
	total_num=$(wc -l Failed_Logins)
	printf "Total number of failed logins is %s" "$total_num"
}

function tally () {	
	declare -A IP_Array
	while IFS= read -r line; do
		IP_Address=$(echo "$line" | egrep -o "([0-9]{1,3}\\.){3}[0-9]{1,3}")
		if [[ -v IP_Array["$IP_Address"] ]]; then
			((IP_Array["$IP_Address"]++))
		else
			IP_Array["$IP_Address"]=1
		fi

	done < Failed_Logins

	for key in "${!IP_Array[@]}"; do
		printf "IP Address is %s | Failed Login Count is %s" "$key" "${IP_Array["$key"]}" >> Tally_Auth.log
	done


}
main
tally

