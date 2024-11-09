provider "aws" {
  region = "eu-west-1"
}

# Define a security group allowing HTTP traffic on port 80 and SSH traffic on port 22
resource "aws_security_group" "allow_web_traffic" {
  count       = 1  # You can adjust this number to create multiple security groups.
  name        = "allow_web_traffic-${timestamp()}"  # Use timestamp to force new name
  description = "Allow inbound HTTP traffic on port 80 and SSH on port 22"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world. You can limit this to specific IPs if needed.
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world. You can limit this to specific IPs if needed.
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

# Data source to fetch the latest Amazon Linux AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source to fetch an existing key pair from your AWS account
data "aws_key_pair" "existing_key" {
  key_name = "MyNewKeyPair2"  # Replace with your existing key pair name
}

# Define the EC2 instance and attach the security group, and specify the key pair
resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_web_traffic[0].name]  # Attach the security group here
  key_name      = data.aws_key_pair.existing_key.key_name  # Use existing key pair

  tags = {
    Name = "web-instance"
  }

  # Add other necessary configurations like key_name, etc.
}

# Output the EC2 instance's public IP
output "instance_ip" {
  value = aws_instance.web.public_ip
}
