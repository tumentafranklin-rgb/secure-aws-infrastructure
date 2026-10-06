# Security Controls

## 1. Network Segmentation

The environment uses a two-tier VPC architecture:

- VPC CIDR: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24`
- Private subnet: `10.0.2.0/24`
- Internet Gateway attached to the VPC
- Separate public and private route tables

The public subnet is intended for resources that require controlled internet-facing access. The private subnet is designed for internal resources that should not be directly exposed to the internet.

## 2. Security Groups

### Web Security Group

The web security group allows:

- TCP 80 (HTTP) from the internet
- TCP 443 (HTTPS) from the internet

Outbound traffic is allowed.

SSH port 22 is intentionally not exposed.

### Backend Security Group

The backend security group has no inbound rules.

This provides a stronger default-deny posture for private backend resources.

## 3. IAM Least Privilege

The EC2 instance uses an IAM role instead of storing AWS credentials on the server.

The role has:

- AmazonSSMManagedInstanceCore
- A custom S3 read-only policy

The custom S3 policy allows only:

- `s3:GetObject`
- `s3:GetObjectVersion`
- `s3:ListBucket`

The permissions are restricted to the project's secure S3 bucket.

This follows the principle of least privilege by avoiding broad administrative permissions.

## 4. AWS Systems Manager

AWS Systems Manager Session Manager is used as the management path for the EC2 instance.

SSH access is not required.

This eliminates the need to expose TCP port 22 to the internet and avoids managing SSH keys for the instance.

The EC2 instance was verified as online through Systems Manager.

## 5. S3 Data Protection

The secure S3 bucket uses multiple security controls:

- Versioning enabled
- S3 Block Public Access enabled
- Bucket ownership controls enabled
- Server-side encryption using AWS KMS
- S3 Bucket Key enabled
- HTTPS-only access enforced

The bucket policy denies requests that do not use secure transport.

## 6. AWS KMS

A customer-managed AWS KMS key is used to encrypt the secure S3 bucket.

KMS key rotation is enabled.

The KMS key is dedicated to the project's S3 encryption requirements.

## 7. CloudTrail

AWS CloudTrail is enabled for the environment.

The trail is configured for:

- Multi-region logging
- Global service events
- Log file validation
- S3-based log storage

CloudTrail logs are stored in a dedicated S3 bucket.

The CloudTrail log bucket also uses:

- Block Public Access
- Bucket ownership controls
- Versioning
- Server-side encryption
- HTTPS-only transport enforcement

## 8. EC2 Instance Security

The web server runs on an Ubuntu EC2 instance.

Security controls include:

- IMDSv2 required
- Encrypted root EBS volume
- Dedicated IAM instance role
- No SSH ingress
- Nginx running only as the required web service

The instance is deployed in the public subnet because it provides the internet-facing web service.

## 9. GuardDuty

GuardDuty was evaluated as part of the security architecture.

During validation, the AWS account returned:

`SubscriptionRequiredException`

for the GuardDuty detector query.

This indicates that GuardDuty requires account/service enablement before detector information can be retrieved.

The limitation is documented rather than repeatedly retrying the service.

## 10. Validation Performed

The deployed environment was validated using AWS CLI, Terraform, Systems Manager, and HTTP testing.

Validation included:

- Terraform configuration validation
- Terraform deployment
- EC2 Systems Manager connectivity
- Nginx service status
- HTTP response testing
- Port 80 listener verification
- VPC and subnet configuration
- Security group rules
- IAM role and policy inspection
- S3 encryption verification
- S3 versioning verification
- S3 public access block verification
- KMS key rotation verification
- CloudTrail logging verification

## 11. Security Design Principles

The project follows these security principles:

1. Least privilege
2. Network segmentation
3. Default-deny inbound access where possible
4. Encryption at rest
5. Secure transport
6. Centralized audit logging
7. No direct SSH requirement
8. Infrastructure as Code
9. Continuous validation
10. Explicit documentation of security limitations

## 12. Known Limitation

The current environment uses HTTP for the demonstration web server.

Although the security group permits TCP 443, HTTPS certificate configuration was not part of the current deployment.

For a production deployment, HTTPS should be implemented using a trusted certificate and HTTP-to-HTTPS redirection.
