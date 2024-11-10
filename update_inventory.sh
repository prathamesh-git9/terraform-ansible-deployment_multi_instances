#!/bin/bash

# Get the new EC2 instance IP address from Terraform output
EC2_IP=$(terraform output -raw public_ip)

# Update the inventory.ini file with the new IP address
echo "[web]" > inventory.ini
echo "$EC2_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/MyNewKeyPair2.pem" >> inventory.ini

# Verify that the inventory.ini file was updated
cat inventory.ini

