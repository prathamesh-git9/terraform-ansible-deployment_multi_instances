#!/bin/bash

# Get the new EC2 instance public IP address from Terraform output
EC2_IP=$(terraform output -raw instance_ip)  # Ensure this matches the output variable name

# Check if the EC2_IP is empty
if [ -z "$EC2_IP" ]; then
  echo "Error: Unable to fetch EC2 IP from Terraform output."
  exit 1
fi

# Update the inventory.ini file with the new IP address
echo "[web]" > inventory.ini
echo "$EC2_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/MyNewKeyPair2.pem" >> inventory.ini

# Verify the content of inventory.ini to ensure the format is correct
cat inventory.ini

