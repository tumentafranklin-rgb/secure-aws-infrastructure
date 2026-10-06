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
