# Secure AWS Infrastructure with Terraform

## Overview

This project demonstrates the design and deployment of a secure AWS infrastructure environment using Terraform.

The goal is to apply cloud security principles such as:

- Network segmentation
- IAM least privilege
- Secure Systems Manager access
- Encryption at rest with AWS KMS
- S3 security controls
- CloudTrail centralized logging
- Infrastructure as Code
- Security validation and evidence collection

The infrastructure was deployed in AWS `us-east-1`.

---

# Architecture

The environment uses a two-tier VPC architecture.

```text
                         INTERNET
                            |
                       HTTP / HTTPS
                         80 / 443
                            |
                            v
                  +-------------------+
                  |  Internet Gateway |
                  +---------+---------+
                            |
                            v
              +---------------------------+
              |        VPC                 |
              |       10.0.0.0/16          |
              |                            |
              |  +----------------------+  |
              |  |   Public Subnet      |  |
              |  |   10.0.1.0/24        |  |
              |  |                      |  |
              |  |   EC2 Web Server     |  |
              |  |   Nginx              |  |
              |  +----------+-----------+  |
              |             |              |
              |             | IAM / SSM    |
              |             v              |
              |  +----------------------+  |
              |  |   Private Subnet     |  |
              |  |   10.0.2.0/24         |  |
              |  |                      |  |
              |  | Backend Resources    |  |
              |  +----------------------+  |
              +---------------------------+

                       AWS Services
                            |
              +-------------+-------------+
              |             |             |
              v             v             v
             S3            KMS        CloudTrail
              |             |             |
              |             |             v
              |             |       CloudTrail S3
              |             |          Bucket
              v             v
        Secure Data     Encryption
          Bucket
```

### Detailed Architecture Diagram

See the full Mermaid architecture diagram: [Architecture Diagram](diagrams/architecture.md)

## Security Evidence

The deployed environment was validated after Terraform provisioning. The following controls were tested and confirmed:

| Control | Evidence | Result |
|---|---|---|
| Terraform configuration | `terraform fmt` and `terraform validate` completed successfully | PASS |
| EC2 management | AWS Systems Manager Session Manager reported the instance as `Online` | PASS |
| Web server | Nginx was running and listening on TCP port 80 | PASS |
| HTTP service | Public HTTP endpoint returned `HTTP 200 OK` | PASS |
| Network segmentation | Public and private subnets were deployed with separate route tables | PASS |
| Web security group | HTTP 80 and HTTPS 443 allowed; SSH 22 not exposed | PASS |
| Backend security group | No inbound rules configured | PASS |
| IAM | EC2 role limited to SSM and project S3 read-only access | PASS |
| S3 encryption | Secure bucket encrypted with customer-managed AWS KMS key | PASS |
| S3 protection | Versioning and Block Public Access enabled | PASS |
| KMS | Automatic key rotation enabled | PASS |
| CloudTrail | Multi-region logging and log file validation enabled | PASS |
| Secure transport | Secure S3 bucket denies insecure transport | PASS |
| GuardDuty | Account returned `SubscriptionRequiredException` | LIMITATION |

These results provide evidence that the implemented security controls were not only configured in Terraform but also validated after deployment.
