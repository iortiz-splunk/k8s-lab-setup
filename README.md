# k8s-lab-setup
Repository to assist in the creation of a demo/lab k8s environment for field solution engineers 

## Prerequisites

Before using this Terraform configuration, ensure you have the following:

1. **AWS Account**:
   - Ensure you have the necessary IAM permissions to create VPCs, Subnets, EC2 instances, Security Groups, and Internet Gateways.
2. **AWS CLI**:
   - Installed and configured. Instructions are provided below.
3. **Terraform Installed**:
   - Install Terraform on your system. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).
4. **PEM Key**:
   - Ensure you have an existing PEM key in your AWS account for SSH access. If you don’t have one, instructions are provided below to create one.
5. **AMI ID**:
   - Obtain the AMI ID for the region you are deploying in. Ensure the AMI is compatible with the selected instance types.
---

## Usage
``` bash
https://github.com/iortiz-splunk/k8s-lab-setup.git
cd k8s-lab-setup
```

### Update terraform.tfvars 
Create a file named 'terraform.tfvars and update the below variables

- `instance_count` = Number of EC2 instances with K3s installed
- `instance_type` = EC2 instance type
- `region`= AWS region for deployment (e.g., `us-east-1`)
- `ami_id`= AMI ID for EC2 instances 
- `pem_key_name`= Name of the PEM key for SSH access, do not add `.pem`

  