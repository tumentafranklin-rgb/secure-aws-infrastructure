# Security Validation Evidence

**Project:** Secure AWS Infrastructure

**Author:** Franklin Tumenta

**Platform:** Amazon Web Services (AWS)

**Infrastructure as Code:** Terraform

## Purpose

This document records security controls validated against the live AWS environment using AWS CLI.

The goal is to provide evidence that the security controls described in the Terraform configuration are actually implemented in AWS.

## Validation Areas

- S3 encryption with AWS KMS
- KMS automatic key rotation
- S3 public access protection
- S3 HTTPS-only access
- CloudTrail logging
- CloudTrail log-file validation
- CloudTrail log storage encryption
- EC2 IMDSv2 enforcement
- IAM instance profile
- AWS Systems Manager connectivity
- Security Group network controls

---

## 1. S3 KMS Encryption

The secure data S3 bucket uses AWS KMS for server-side encryption.

**Bucket:** `secure-aws-infrastructure-secure-data`

**AWS CLI validation:**

```text
SSEAlgorithm    aws:kms
KMSMasterKeyID  arn:aws:kms:us-east-1:126309364316:key/368168ee-a8d9-41d0-a77b-490ee41a93ff
```

**Result:** Verified. The bucket is encrypted using the customer-managed KMS key.

---

## 2. KMS Automatic Key Rotation

The customer-managed KMS key has automatic annual key rotation enabled.

**AWS CLI validation:**

```text
KeyRotationEnabled   True
RotationPeriodInDays 365
```

**Result:** Verified. Automatic KMS key rotation is enabled with a 365-day rotation period.

---

## 3. S3 Public Access Protection

Public access is blocked on the secure data S3 bucket.

**AWS CLI validation:**

```text
BlockPublicAcls        True
BlockPublicPolicy      True
IgnorePublicAcls       True
RestrictPublicBuckets  True
```

**Result:** Verified. All four S3 Public Access Block controls are enabled.

---

## 4. S3 Versioning

Versioning is enabled on the secure data S3 bucket to help protect against accidental deletion or overwriting of objects.

**AWS CLI validation:**

```text
Status: Enabled
```

**Result:** Verified. S3 bucket versioning is enabled.

---

## 5. S3 HTTPS-Only Access

The secure data S3 bucket explicitly denies requests that do not use secure transport.

**AWS CLI validation:**

```text
Sid: DenyInsecureTransport
Effect: Deny
Condition: aws:SecureTransport = false
Action: s3:*
```

**Result:** Verified. Insecure transport is explicitly denied by the S3 bucket policy.

---

## 6. CloudTrail Logging

The CloudTrail trail is actively logging API activity and successfully delivering log files.

**Trail:** `secure-aws-infrastructure-trail`

**AWS CLI validation:**

```text
IsLogging                          True
LatestDeliveryAttemptSucceeded     2026-10-06T22:41:41Z
LatestDeliveryTime                 2026-10-06T18:41:41.833000-04:00
TimeLoggingStarted                 2026-10-05T00:37:20Z
```

**Result:** Verified. CloudTrail is actively logging and the latest delivery attempt succeeded.

---

## 7. CloudTrail Log-File Validation

CloudTrail log-file validation is enabled to help detect modification or deletion of delivered log files.

**AWS CLI validation:**

```text
LogFileValidationEnabled  true
IsMultiRegionTrail        true
IncludeGlobalServiceEvents true
RecursiveLogging          true
```

**Result:** Verified. CloudTrail log-file validation is enabled on the multi-region trail.

---

## 8. CloudTrail Log Storage Encryption

CloudTrail log files are stored in a dedicated S3 bucket encrypted with the customer-managed AWS KMS key.

**Bucket:** `secure-aws-infrastructure-cloudtrail-126309364316`

**AWS CLI validation:**

```text
SSEAlgorithm    aws:kms
KMSMasterKeyID  arn:aws:kms:us-east-1:126309364316:key/368168ee-a8d9-41d0-a77b-490ee41a93ff
```

**Result:** Verified. CloudTrail log storage uses AWS KMS encryption.

---

## 9. EC2 IMDSv2 Enforcement

The EC2 instance requires Instance Metadata Service Version 2 (IMDSv2).

**Instance:** `i-028193a3d35a63527`

**AWS CLI validation:**

```text
HttpEndpoint              enabled
HttpPutResponseHopLimit   2
HttpTokens                required
```

**Result:** Verified. IMDSv2 is required for the EC2 instance.

---

## 10. EC2 IAM Instance Profile

The EC2 instance uses a dedicated IAM instance profile for controlled access to AWS services.

**Instance:** `i-028193a3d35a63527`

**AWS CLI validation:**

```text
InstanceProfile: secure-aws-infrastructure-ec2-profile
InstanceProfileId: AIPAR22E76JOMKGJDDJSY
```

**Result:** Verified. The EC2 instance is associated with the dedicated IAM instance profile.

---

## 11. AWS Systems Manager Connectivity

AWS Systems Manager provides secure administrative connectivity to the EC2 instance without requiring public SSH access.

**AWS CLI validation:**

```text
InstanceId    i-028193a3d35a63527
PingStatus    Online
Platform      Ubuntu
AgentVersion  3.3.4793.0
```

**Result:** Verified. The EC2 instance is online and connected to AWS Systems Manager.

---

## 12. Security Group Network Controls

The EC2 web security group allows public web traffic while keeping SSH port 22 closed to the Internet.

**Security Group:** `sg-0eb935978463ce5b7`

**AWS CLI validation:**

```text
TCP 80   0.0.0.0/0   Allow HTTP from the Internet
TCP 443  0.0.0.0/0   Allow HTTPS from the Internet
TCP 22   Not present  SSH is not publicly exposed
```

**Result:** Verified. HTTP and HTTPS are publicly accessible while SSH port 22 is not exposed.
