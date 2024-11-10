#!/bin/bash

# Fetch the EC2 public IP from Terraform output
EC2_IP=$(terraform output -raw ec2_public_ip)

# Check if EC2 IP was successfully fetched
if [ -z "$EC2_IP" ]; then
  echo "Failed to fetch EC2 IP address. Exiting."
  exit 1
fi

# Update the inventory.ini file with the new IP
echo "Updating inventory.ini with the new EC2 IP: $EC2_IP"
echo "[web]" > inventory.ini
echo "$EC2_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/MyNewKeyPair2.pem" >> inventory.ini

echo "inventory.ini updated successfully."
