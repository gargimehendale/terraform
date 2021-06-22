# Terraform Assignment by InfraCloud

## Terraform assignment Progress

- Created VPC with 3 private and 3 public subnets.
- Created Internet gateway for public subnets and also route tables and table associations.
- Created NAT gateway so that public access is disabled and only access is allowed via NAT
- Created 2 security groups for ec2 and rds.
- Generated SSH keypair for launching aws instance.
- EC2 instances are launched in 3 different public subnets
- Created subnet group for launching rds.
- Launched the RDS instance with postgresql.
- Used S3 as its backed for remote storage
- Implemented statelock feature for Terraform
