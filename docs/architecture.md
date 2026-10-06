# Architecture

## Overview

This project deploys a security-focused AWS environment using Terraform.
## Network Architecture

The environment uses one VPC:

- VPC CIDR: `10.0.0.0/16`

The VPC contains two subnets:

### Public Subnet

- CIDR: `10.0.1.0/24`
- Internet Gateway connectivity
- Public route table
- Used by the internet-facing EC2 web server
- Public IP assigned to the EC2 instance

### Private Subnet

- CIDR: `10.0.2.0/24`
- Private route table
- No public IP assignment
- Intended for backend/private resources

## Traffic Flow

Internet traffic reaches the public EC2 web server through:

```text
Internet
   |
   v
Internet Gateway
   |
   v
Public Route Table
   |
   v
Public Subnet
   |
   v
Web Security Group
   |
   v
EC2 Web Server
   |
   v
Nginx
```

Private resources are separated from direct internet exposure:

```text
Private Resources
       |
       v
Private Subnet
       |
       v
Private Route Table
```

## Security Groups

### Web Security Group

The web security group permits:

- TCP 80 (HTTP) from the internet
- TCP 443 (HTTPS) from the internet

Port 22 (SSH) is not exposed.

### Backend Security Group

The backend security group has no inbound rules.

This establishes a default-deny inbound posture for backend resources.

## Identity and Management Access

The EC2 instance uses an IAM instance role instead of storing AWS credentials on the server.

The role provides:

- AWS Systems Manager access
- Read-only access to the project secure S3 bucket

The S3 permissions are limited to the required read operations.

AWS Systems Manager Session Manager provides administrative access to the EC2 instance.

SSH is not required, and TCP port 22 is not exposed through the web security group.

## Data Protection

The secure S3 bucket uses multiple security controls:

- AWS KMS encryption
- S3 Bucket Key
- Versioning
- S3 Block Public Access
- Bucket ownership controls
- HTTPS-only access

A customer-managed AWS KMS key is used to encrypt the secure S3 bucket.

KMS key rotation is enabled.

## Logging and Monitoring

AWS CloudTrail records API activity and stores logs in a dedicated S3 bucket.

CloudTrail is configured for:

- Multi-region events
- Global service events
- Log file validation

The CloudTrail log bucket uses:

- S3 Block Public Access
- Bucket ownership controls
- Versioning
- Server-side encryption
- HTTPS-only transport enforcement

GuardDuty was evaluated but could not be queried because the AWS account returned a `SubscriptionRequiredException`.

## Infrastructure as Code

Terraform manages the AWS infrastructure.

The Terraform configuration provisions and manages:

- VPC
- Public and private subnets
- Route tables
- Internet Gateway
- Security groups
- IAM roles and policies
- EC2 instance
- S3 buckets
- KMS key and alias
- CloudTrail

Infrastructure is defined as code so the environment can be reviewed, validated, and reproduced.

## Design Goals

The architecture is designed around:

- Least privilege
- Network segmentation
- Encryption at rest
- Secure transport
- Centralized logging
- Reduced management exposure
- Reproducible infrastructure
- Infrastructure as Code
