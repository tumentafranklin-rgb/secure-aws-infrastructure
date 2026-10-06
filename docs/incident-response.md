# Incident Response

## Purpose

This document defines a basic incident-response approach for the Secure AWS Infrastructure project.

## Incident Response Phases

### 1. Preparation

Maintain infrastructure as code in Terraform.

Maintain centralized AWS API logging through CloudTrail.

Use IAM roles and least-privilege permissions.

Use AWS Systems Manager for administrative access without requiring SSH.

Protect sensitive S3 data with KMS encryption and Block Public Access.

### 2. Detection and Analysis

Use CloudTrail logs to investigate AWS API activity.

Review unexpected changes to IAM, networking, EC2, S3, and KMS resources.

Investigate unexpected security group changes, especially changes that expose administrative ports.

Review unusual access to protected S3 resources.

Use AWS security services such as GuardDuty when enabled and available in the account.

### 3. Containment

If an EC2 instance is suspected of compromise:

1. Restrict network access using security groups.
2. Preserve relevant logs and evidence.
3. Use Systems Manager for controlled administrative access when available.
4. Avoid unnecessary destruction of evidence before investigation is complete.

If IAM credentials or permissions are suspected of compromise:

1. Identify the affected role or credentials.
2. Remove unnecessary permissions.
3. Review CloudTrail activity.
4. Rotate or revoke affected credentials where applicable.

### 4. Eradication

Remove malicious or unauthorized configuration changes.

Rebuild compromised infrastructure from the Terraform configuration when appropriate.

Replace compromised resources rather than relying on manual cleanup when a clean rebuild is safer.

Verify security group, IAM, S3, KMS, and logging configurations after remediation.

### 5. Recovery

Restore services using the known-good Terraform configuration.

Validate the environment before returning systems to normal operation.

Confirm CloudTrail logging, IAM controls, encryption, network controls, and SSM access remain operational.

Monitor the environment after recovery for additional suspicious activity.

### 6. Lessons Learned

Document the incident, affected resources, root cause, security controls that worked, and controls that need improvement.

Update Terraform, documentation, and testing procedures based on lessons learned.

## Project-Specific Security Priorities

The highest priorities for this environment are:

- Protecting IAM credentials and permissions
- Preventing unauthorized public exposure
- Protecting encrypted S3 data
- Maintaining CloudTrail visibility
- Preventing unauthorized administrative access
- Maintaining the ability to rebuild infrastructure from Terraform

## Known Limitation

GuardDuty was evaluated during the project but the AWS account returned a `SubscriptionRequiredException` when the detector was queried. GuardDuty availability should therefore be confirmed and enabled at the account level before relying on it as an active detection control.
