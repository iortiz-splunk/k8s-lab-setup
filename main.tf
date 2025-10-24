# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Removed: Data source to get the latest Ubuntu AMI
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["099720109477"] # Canonical's owner ID for Ubuntu AMIs
# }

# Create a new VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "terraform-vpc"
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.region}a" # Example AZ, consider making this dynamic or a variable
  map_public_ip_on_launch = true # Instances launched in this subnet will automatically get a public IP
  tags = {
    Name = "terraform-public-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "terraform-internet-gateway"
  }
}

# Create a Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0" # Route all outbound traffic to the Internet Gateway
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "terraform-public-route-table"
  }
}

# Associate the Route Table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a Security Group for the EC2 instances
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  name   = "terraform-ec2-security-group"
  description = "Allow SSH and HTTP/HTTPS inbound traffic"

  # Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For production, restrict this to specific IPs
    description = "Allow SSH from anywhere"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For production, restrict this to specific IPs
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For production, restrict this to specific IPs
    description = "Allow HTTPS from anywhere"
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-ec2-sg"
  }
}

# Create 'x' amount of EC2 instances
resource "aws_instance" "web_server" {
  count                  = var.instance_count
  ami                    = var.ami_id # Now using the variable for AMI ID
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_pair_name

  # Read the installation script and pass it to user_data
  user_data = file("${path.module}/install_k8s.sh")

  tags = {
    Name    = "k8s-node-${count.index}"
    Project = "TerraformK8s"
  }
}