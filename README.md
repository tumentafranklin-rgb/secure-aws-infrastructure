# Secure AWS Infrastructure

**Author:** Franklin Tumenta

**AWS Cloud Security | Terraform | Infrastructure as Code**

---

## Project Overview

This project demonstrates the design, deployment, and security validation of a secure AWS infrastructure environment using Terraform.

The objective is to apply practical cloud security principles including:

- Network segmentation
- IAM least privilege
- Secure administrative access
- Encryption at rest
- Encryption in transit
- Centralized logging
- Infrastructure as Code
- EC2 hardening
- S3 security controls
- Security validation using AWS CLI

The infrastructure is deployed in AWS `us-east-1`.

---

## Architecture

The environment uses a two-tier VPC architecture with public and private network segments.

```text
                         Internet
                            |
                    +-------+-------+
                    |               |
                  HTTP            HTTPS
                 TCP/80          TCP/443
                    |               |
                    +-------+-------+
                            |
                     Public Subnet
                            |
                       EC2 Web Tier
                            |
                    +-------+-------+
                    |               |
              Private Subnet     S3
                    |               |
                 Backend       Secure Data
                    |               |
                    +-------+-------+
                            |
                           KMS
                            |
                    Customer-Managed
                       Encryption

---

## AWS Services

| Service | Purpose |
|---|---|
| Amazon VPC | Network isolation and segmentation |
| Amazon EC2 | Web workload |
| IAM | Identity and access control |
| Amazon S3 | Secure data and CloudTrail log storage |
| AWS KMS | Encryption key management |
| AWS CloudTrail | API activity logging |
| AWS Systems Manager | Secure EC2 administration |
| Security Groups | Network access control |
| Terraform | Infrastructure as Code |

---

## Security Controls

### Network Security

- VPC-based network isolation
- Public and private subnet separation
- HTTP port 80 exposed for public web traffic
- HTTPS port 443 exposed for public web traffic
- SSH port 22 is not exposed to the Internet

### IAM Security

- EC2 uses a dedicated IAM instance profile
- EC2 uses a dedicated IAM role
- `AmazonSSMManagedInstanceCore` provides Systems Manager access
- EC2 has a dedicated S3 read-only policy
- No administrator policy is attached to the EC2 role

### S3 Security

- S3 public access blocked
- S3 versioning enabled
- Secure data bucket encrypted with AWS KMS
- CloudTrail log bucket encrypted with AWS KMS
- Insecure transport explicitly denied

### KMS Security

- Customer-managed KMS key
- Automatic key rotation enabled
- 365-day rotation period
- KMS used for S3 encryption
- 30-day KMS key deletion waiting period

### CloudTrail Security

- Multi-region CloudTrail enabled
- CloudTrail logging enabled
- Log-file validation enabled
- CloudTrail logs stored in a dedicated S3 bucket
- CloudTrail log storage encrypted with AWS KMS

### EC2 Security

- IMDSv2 required
- Systems Manager agent online
- Systems Manager used for administrative access
- SSH is not publicly exposed

---

## Security Validation

Security controls were validated directly against the live AWS environment using AWS CLI rather than relying only on Terraform configuration.

Verified controls include:

- S3 KMS encryption
- CloudTrail log storage KMS encryption
- KMS automatic key rotation
- S3 public access blocking
- S3 versioning
- S3 HTTPS-only access
- CloudTrail logging
- CloudTrail log-file validation
- EC2 IMDSv2 enforcement
- EC2 IAM instance profile
- Systems Manager connectivity
- Security group inbound rules

### Example Validation Commands

```bash
aws s3api get-bucket-encryption
aws kms get-key-rotation-status
aws cloudtrail get-trail-status
aws ssm describe-instance-information
aws ec2 describe-instances
aws ec2 describe-security-groups
```

---

## Key Security Decisions

### No Public SSH Access

SSH port 22 is not exposed through the public web security group.

AWS Systems Manager provides administrative access to the EC2 instance instead.

### Customer-Managed Encryption

S3 data and CloudTrail log storage use a customer-managed AWS KMS key with automatic rotation.

### Defense in Depth

```text
Network Security
       +
IAM
       +
Encryption
       +
Logging
       +
Host Hardening
       +
Secure Administration
```
### Infrastructure as Code
Terraform is used to create and manage the infrastructure so that security controls are reproducible and auditable.

---

## Security Verification Results

| Security Control | Result |
|---|---|
| VPC and subnet architecture | Verified |
| Public/private subnet separation | Verified |
| Public web ports 80/443 | Verified |
| Public SSH port 22 | Not exposed |
| IAM EC2 instance profile | Verified |
| S3 read-only IAM policy | Verified |
| Systems Manager policy | Verified |
| Systems Manager instance status | Online |
| S3 public access block | Verified |
| S3 versioning | Verified |
| S3 KMS encryption | Verified |
| CloudTrail log storage KMS encryption | Verified |
| KMS key rotation | Enabled |
| CloudTrail logging | Enabled |
| CloudTrail log validation | Enabled |
| S3 HTTPS-only policy | Verified |
| EC2 IMDSv2 | Required |

---

## Terraform Structure

The infrastructure is managed using Terraform.

Key resources include:

```text
VPC
├── Public Subnet
├── Private Subnet
├── Internet Gateway
├── Route Tables
└── Security Groups

IAM
├── EC2 Role
├── Instance Profile
└── S3 Read-Only Policy

S3
├── Secure Data Bucket
└── CloudTrail Log Bucket

KMS
├── Customer-Managed Key
└── KMS Alias

CloudTrail
└── Multi-Region Trail

EC2
└── Web Instance
```

---

## Lessons Learned

1. Security configuration should be verified against the live AWS environment.
2. Encryption at rest does not replace access control.
3. Public access should be minimized wherever possible.
4. Administrative interfaces should not unnecessarily be exposed to the Internet.
5. Infrastructure as Code provides repeatability and auditability.
6. Security controls should be tested rather than assumed.
7. Security decisions should be based on evidence.

---

## Author

**Franklin Tumenta**

AWS Cloud | DevOps | Cloud Security | Infrastructure as Code
