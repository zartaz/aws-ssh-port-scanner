#!/bin/bash

# Fetch EC2 instances, their IDs, and Public IPs
instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' --output text)

# Initialize open.txt
echo "" > open.txt

# IP validation regex
ip_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

# Loop through instances and check port 22
IFS=$'\n'  # set loop delimiter
for instance in $instances; do
    instance_id=$(echo $instance | awk '{print $1}')
    ip=$(echo $instance | awk '{print $2}' | tr -d ' ')  # Remove trailing spaces

    if [[ ! -z "$ip" && $ip =~ $ip_regex ]]; then  # Only check if IP exists and is valid
        echo "Scanning $instance_id ($ip)"
        nc -zv -w1 $ip 22 && echo "$instance_id ($ip) is open on port 22" >> open.txt
    fi
done
