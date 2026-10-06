# Security Evidence

## Purpose

This document records how the major security controls in the Secure AWS Infrastructure project were implemented and validated.

## 1. VPC Network Segmentation

**Implementation**

- VPC CIDR: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24`
- Private subnet: `10.0.2.0/24`
- Separate public and private route tables
- Public IP assignment enabled only for the public subnet

**Validation**

AWS CLI inspection confirmed the VPC and subnet configuration, including public IP assignment behavior.

**Security meaning**

The architecture separates internet-facing resources from resources intended for private placement.

## 2. Web Security Group

**Implementation**

- TCP 80 allowed for HTTP
- TCP 443 allowed for HTTPS
- TCP 22 (SSH) is not exposed
- Outbound traffic is allowed

**Validation**

The deployed web security group was inspected and confirmed to contain HTTP and HTTPS ingress without SSH ingress.

**Security meaning**

The web tier exposes only the application ports required for the demonstration and does not expose SSH to the internet.

## 3. Backend Security Group

**Implementation**

- No inbound rules are configured.

**Validation**

The backend security group was inspected and confirmed to have no inbound rules.

**Security meaning**

The backend tier follows a default-deny inbound posture.

## 4. IAM Least Privilege

**Implementation**

The EC2 instance uses an IAM role with:

- `AmazonSSMManagedInstanceCore`
- Custom S3 read-only access for the project bucket

The custom S3 policy allows only:

- `s3:GetObject`
- `s3:GetObjectVersion`
- `s3:ListBucket`

**Validation**

The IAM role and attached policies were inspected. The S3 policy was confirmed to contain only the required read operations for the project bucket.

**Security meaning**

The EC2 workload does not require broad administrative AWS permissions.

## 5. Systems Manager Instead of SSH

**Implementation**

AWS Systems Manager Session Manager is used for administrative access to the EC2 instance.

**Validation**

SSM reported the EC2 instance as `Online`, and a Session Manager connection was successfully used to validate the server.

**Security meaning**

Administrative access does not require an exposed SSH port or stored SSH credentials on the instance.

## 6. S3 Data Protection

**Implementation**

The secure S3 bucket uses:

- AWS KMS encryption
- S3 Bucket Key
- Versioning
- S3 Block Public Access
- Bucket ownership controls
- HTTPS-only transport enforcement

**Validation**

AWS CLI inspection confirmed KMS encryption, Bucket Key, versioning, and Block Public Access. The bucket policy was also inspected and confirmed to deny insecure transport.

**Security meaning**

Sensitive data stored in the bucket has encryption, versioning, public-access protection, and transport-security controls.

## 7. KMS Protection

**Implementation**

A customer-managed KMS key is used for the secure S3 bucket.

**Validation**

The KMS key was inspected and automatic key rotation was confirmed as enabled.

**Security meaning**

The project demonstrates customer-controlled encryption keys with automatic rotation.

## 8. CloudTrail Logging

**Implementation**

CloudTrail is configured for:

- Multi-region activity
- Global service events
- Log file validation

Logs are delivered to a dedicated protected S3 bucket.

**Validation**

CloudTrail was inspected and confirmed to be actively logging with successful recent delivery information.

**Security meaning**

AWS API activity can be centrally recorded for security investigation and auditing.

## 9. EC2 Hardening

**Implementation**

- Ubuntu EC2 instance
- IMDSv2 required
- Encrypted gp3 root volume
- Root volume configured for deletion when the instance is terminated
- IAM instance profile attached
- No SSH key required

**Validation**

The deployed EC2 instance was inspected through AWS Systems Manager. Nginx was confirmed running and listening on TCP port 80.

**Security meaning**

The workload uses AWS-native identity and management controls while reducing unnecessary administrative exposure.

## 10. Secure Transport

**Implementation**

The secure S3 bucket has a bucket policy that denies requests when `aws:SecureTransport` is `false`.

**Validation**

The bucket policy was inspected and the explicit insecure-transport deny statement was confirmed.

**Security meaning**

The protected S3 bucket requires encrypted transport for access.

## 11. GuardDuty Limitation

**Observed result**

The AWS account returned `SubscriptionRequiredException` when the GuardDuty detector was queried.

**Security meaning**

GuardDuty was not represented as an active detection control in this project. Its availability must be confirmed and enabled at the account level before relying on it operationally.

## Evidence Summary

| Control | Validation | Result |
|---|---|---|
| VPC segmentation | AWS CLI inspection | PASS |
| Web security group | AWS CLI inspection | PASS |
| Backend security group | AWS CLI inspection | PASS |
| IAM least privilege | IAM policy inspection | PASS |
| Systems Manager | SSM status and Session Manager | PASS |
| S3 protection | S3/KMS inspection | PASS |
| KMS rotation | KMS inspection | PASS |
| CloudTrail | Trail status inspection | PASS |
| EC2 hardening | EC2/SSM inspection | PASS |
| Secure transport | S3 bucket policy inspection | PASS |
| GuardDuty | Account query | LIMITATION |

The evidence in this document reflects controls that were actually implemented and validated during the project. No control is marked as active when the AWS account did not support or confirm it.
