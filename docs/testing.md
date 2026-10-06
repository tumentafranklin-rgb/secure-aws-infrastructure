# Testing and Validation

## Purpose

This document records validation performed after deploying the Secure AWS Infrastructure environment with Terraform.

## Terraform Validation

Terraform configuration was validated successfully using:

```bash
terraform fmt
terraform validate
```

The Terraform configuration completed validation successfully.

## EC2 and Systems Manager

The EC2 instance was verified through AWS Systems Manager.

Validation confirmed:

- SSM agent online
- EC2 instance reachable through Session Manager
- Ubuntu platform detected

SSH was not required for management.

## Web Server Validation

The EC2 instance was checked through Systems Manager.

Nginx was verified as running.

The server was listening on TCP port 80.

A local HTTP request returned HTTP 200 OK.

The public web endpoint also returned HTTP 200 OK.

## Network Validation

The VPC was verified with CIDR `10.0.0.0/16`.

The public subnet was verified with CIDR `10.0.1.0/24` and public IP assignment enabled.

The private subnet was verified with CIDR `10.0.2.0/24` and public IP assignment disabled.

The web security group was verified to allow HTTP 80 and HTTPS 443.

SSH port 22 was not exposed.

The backend security group was verified to have no inbound rules.

## IAM Validation

The EC2 IAM role was inspected and confirmed to use:

- AmazonSSMManagedInstanceCore
- Custom S3 read-only policy

The custom S3 policy permits only the required read operations for the secure project bucket.

## S3 and KMS Validation

The secure S3 bucket was verified to use AWS KMS encryption.

S3 Bucket Key was enabled.

S3 versioning was enabled.

S3 Block Public Access was enabled.

The KMS key was verified with automatic rotation enabled.

## CloudTrail Validation

CloudTrail was verified to be actively logging.

The trail was configured for multi-region activity and global service events.

Log file validation was enabled.

CloudTrail logs were delivered to the dedicated CloudTrail S3 bucket.

## GuardDuty Validation

GuardDuty was evaluated during the project validation process.

The AWS account returned a `SubscriptionRequiredException` when querying the GuardDuty detector.

This was documented as an account/service limitation rather than repeatedly retrying the command.

## Security Validation Summary

| Control | Result |
|---|---|
| Terraform validation | PASS |
| SSM connectivity | PASS |
| Nginx service | PASS |
| HTTP response | PASS |
| Network segmentation | PASS |
| Security group validation | PASS |
| IAM least privilege configuration | PASS |
| S3 encryption | PASS |
| KMS rotation | PASS |
| CloudTrail logging | PASS |
| GuardDuty | Account/service limitation |
