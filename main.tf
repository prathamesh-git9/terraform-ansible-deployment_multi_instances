provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic-${timestamp()}"
  description = "Allow inbound HTTP traffic on port 80 and SSH on port 22"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic-${timestamp()}"
  }
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_key_pair" "existing_key" {
  key_name = "MyNewKeyPair2"
}

resource "aws_instance" "web" {
  count = var.instance_count
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_web_traffic.name]
  key_name      = data.aws_key_pair.existing_key.key_name

  tags = {
    Name = "web-instance-ubuntu-${count.index}"
  }
}

output "ec2_public_ips" {
  value = [for instance in aws_instance.web : instance.public_ip]
}

variable "instance_count" {
  description = "Number of instances to create"
  default     = 1
}
