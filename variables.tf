variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2" # Change to your desired region
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances. Ensure it's compatible with the chosen region and instance type (e.g., Ubuntu 20.04 LTS HVM SSD for us-east-1)."
  type        = string
  # IMPORTANT: Replace this with a valid AMI ID for your chosen region.
  default     = "ami-0c9e02800c9ee0a5b" # Golden AMI ubuntu 2025-10-15
}

variable "instance_type" {
  description = "The type of EC2 instance to launch. Recommend t2.medium or t3.small for K3s."
  type        = string
  default     = "t2.xlarge" # Changed from t2.micro for better K3s performance
}

variable "instance_count" {
  description = "The number of EC2 instances to create."
  type        = number
  default     = 1 # Changed to 1 for a single-node K3s cluster
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "key_pair_name" {
  description = "The name of the AWS Key Pair to use for SSH access to the instances."
  type        = string
  # IMPORTANT: Replace "my-ssh-key" with the actual name of your existing AWS Key Pair.
  # You can create one in the EC2 console under "Key Pairs".
  default     = "my-ssh-key"
}