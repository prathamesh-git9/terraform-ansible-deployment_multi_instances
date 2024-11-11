provider "aws" {
  region = "eu-west-1"
}

# Define a security group allowing HTTP traffic on port 80 and SSH traffic on port 22
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic-${timestamp()}"  # Use timestamp to force a new name if recreated
  description = "Allow inbound HTTP traffic on port 80 and SSH on port 22"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world. Adjust if specific IPs are required.
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world. Adjust if specific IPs are required.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic-${timestamp()}"
  }
}

# Data source to fetch the latest Ubuntu AMI for the specified region
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS account for Ubuntu images
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]  # Ubuntu 20.04 LTS
  }
}

# Data source to fetch an existing key pair from your AWS account
data "aws_key_pair" "existing_key" {
  key_name = "MyNewKeyPair2"  # Replace with your existing key pair name
}

# Define the EC2 instance using the Ubuntu AMI and attach the security group and key pair
resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_web_traffic.name]  # Attach the security group here
  key_name      = data.aws_key_pair.existing_key.key_name  # Use existing key pair

  tags = {
    Name = "web-instance-ubuntu"
  }
}

# Output the EC2 instance's public IP
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}
