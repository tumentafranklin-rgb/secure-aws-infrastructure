terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================================
# VARIABLES
# ============================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "secure-aws-infrastructure"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

# ============================================================
# DATA
# ============================================================

data "aws_caller_identity" "current" {}

# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# PUBLIC SUBNET
# ============================================================

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
    Tier        = "Public"
  }
}

# ============================================================
# PRIVATE SUBNET
# ============================================================

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.project_name}-private-subnet"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
    Tier        = "Private"
  }
}

# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# PUBLIC ROUTE TABLE
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-route-table"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
    Tier        = "Public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ============================================================
# PRIVATE ROUTE TABLE
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-private-route-table"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
    Tier        = "Private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ============================================================
# WEB SECURITY GROUP
# ============================================================

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for public web resources"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from the Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from the Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-web-sg"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
    Tier        = "Public"
  }
}

# ============================================================
# BACKEND SECURITY GROUP
# ============================================================

resource "aws_security_group" "backend" {
  name        = "${var.project_name}-backend-sg"
  description = "Security group for private backend resources"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-backend-sg"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
    Tier        = "Private"
  }
}

# ============================================================
# IAM ROLE FOR EC2
# ============================================================

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# S3 READ-ONLY IAM POLICY
# ============================================================

resource "aws_iam_policy" "s3_read_only" {
  name        = "${var.project_name}-s3-read-only"
  description = "Allow read-only access to the project S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::${var.project_name}-secure-data",
          "arn:aws:s3:::${var.project_name}-secure-data/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-s3-read-only"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}

# ============================================================
# SSM
# ============================================================

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ============================================================
# INSTANCE PROFILE
# ============================================================

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "${var.project_name}-ec2-profile"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# KMS
# ============================================================

resource "aws_kms_key" "s3" {
  description             = "KMS key for secure AWS infrastructure S3 bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-s3-kms-key"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

# ============================================================
# SECURE S3 BUCKET
# ============================================================

resource "aws_s3_bucket" "secure_data" {
  bucket = "${var.project_name}-secure-data"

  tags = {
    Name        = "${var.project_name}-secure-data"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "secure_data" {
  bucket = aws_s3_bucket.secure_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "secure_data" {
  bucket = aws_s3_bucket.secure_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_data" {
  bucket = aws_s3_bucket.secure_data.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "secure_data" {
  bucket = aws_s3_bucket.secure_data.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "secure_data" {
  bucket = aws_s3_bucket.secure_data.id

  depends_on = [
    aws_s3_bucket_public_access_block.secure_data
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.secure_data.arn,
          "${aws_s3_bucket.secure_data.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# ============================================================
# CLOUDTRAIL LOG BUCKET
# ============================================================
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_name}-cloudtrail-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "${var.project_name}-cloudtrail-logs"
    Project = var.project_name
  }
}

resource "aws_s3_bucket_request_payment_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  payer  = "BucketOwner"
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    bucket_key_enabled       = true
    blocked_encryption_types = ["SSE-C"]

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================================
# CLOUDTRAIL BUCKET POLICY
# ============================================================

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  depends_on = [
    aws_s3_bucket_public_access_block.cloudtrail_logs
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn

        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${var.project_name}-trail"
          }
        }
      },

      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"

        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${var.project_name}-trail"
            "s3:x-amz-acl"  = "bucket-owner-full-control"
          }
        }
      },

      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.cloudtrail_logs.arn,
          "${aws_s3_bucket.cloudtrail_logs.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# ============================================================
# CLOUDTRAIL
# ============================================================

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs
  ]

  tags = {
    Name    = "${var.project_name}-trail"
    Project = var.project_name
  }
}

# ============================================================
# GUARDDUTY
# ============================================================
#
# TEMPORARILY DISABLED.
#
# Your AWS account previously returned:
#
# SubscriptionRequiredException:
# The AWS Access Key Id needs a subscription for the service.
#
# We will enable GuardDuty after the service is activated.
#
# resource "aws_guardduty_detector" "main" {
#   enable = true
#
#   tags = {
#     Name        = "${var.project_name}-guardduty"
#     Project     = var.project_name
#     Environment = "security-lab"
#     ManagedBy   = "Terraform"
#   }
# }

# ============================================================
# EC2 WEB SERVER
# ============================================================

resource "aws_instance" "web" {
  ami           = "ami-0045d7fc2ad003464"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              set -euxo pipefail

              exec > >(tee /var/log/secure-aws-bootstrap.log | logger -t secure-aws-bootstrap -s 2>/dev/console) 2>&1

              echo "=========================================="
              echo "Starting Secure AWS Infrastructure bootstrap"
              echo "=========================================="

              apt-get update -y

              apt-get install -y nginx snapd

              systemctl enable --now snapd.socket || true

              sleep 10

              if ! snap list amazon-ssm-agent >/dev/null 2>&1; then
                snap install amazon-ssm-agent --classic
              fi

              systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
              systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service

              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html lang="en">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Secure AWS Infrastructure</title>

                <style>
                  body {
                    font-family: Arial, sans-serif;
                    background: #f4f6f8;
                    margin: 0;
                    padding: 60px;
                  }

                  .container {
                    max-width: 800px;
                    margin: auto;
                    background: white;
                    padding: 40px;
                    border-radius: 12px;
                    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                  }

                  h1 {
                    color: #1f2937;
                  }

                  p {
                    color: #4b5563;
                    line-height: 1.6;
                  }

                  .status {
                    display: inline-block;
                    padding: 10px 16px;
                    border-radius: 6px;
                    background: #dcfce7;
                    color: #166534;
                    font-weight: bold;
                  }
                </style>
              </head>

              <body>
                <div class="container">
                  <h1>Secure AWS Infrastructure</h1>

                  <p class="status">
                    Nginx is running successfully.
                  </p>

                  <p>
                    This EC2 web server is managed using Terraform.
                  </p>

                  <p>
                    Security controls include IAM least privilege,
                    Systems Manager, encrypted storage, CloudTrail,
                    and protected S3 storage.
                  </p>
                </div>
              </body>
              </html>
              HTML

              systemctl enable nginx
              systemctl restart nginx

              systemctl is-active --quiet nginx
              systemctl is-active --quiet snap.amazon-ssm-agent.amazon-ssm-agent

              echo "=========================================="
              echo "Bootstrap completed successfully"
              echo "=========================================="
              EOF

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name        = "${var.project_name}-web-server"
      Project     = var.project_name
      Environment = "security-lab"
      ManagedBy   = "Terraform"
      Role        = "Web"
    }
  }

  tags = {
    Name        = "${var.project_name}-web-server"
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
    Role        = "Web"
  }
}

# ============================================================
# OUTPUTS
# ============================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "web_security_group_id" {
  description = "Web security group ID"
  value       = aws_security_group.web.id
}

output "backend_security_group_id" {
  description = "Backend security group ID"
  value       = aws_security_group.backend.id
}

output "ec2_role_name" {
  description = "EC2 IAM role name"
  value       = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "s3_read_only_policy_arn" {
  description = "S3 read-only IAM policy ARN"
  value       = aws_iam_policy.s3_read_only.arn
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.s3.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.s3.arn
}

output "kms_alias" {
  description = "KMS alias"
  value       = aws_kms_alias.s3.name
}

output "s3_bucket_name" {
  description = "Secure S3 bucket name"
  value       = aws_s3_bucket.secure_data.id
}

output "s3_bucket_arn" {
  description = "Secure S3 bucket ARN"
  value       = aws_s3_bucket.secure_data.arn
}

output "cloudtrail_name" {
  description = "CloudTrail trail name"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_log_bucket" {
  description = "CloudTrail log bucket"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "web_instance_id" {
  description = "EC2 web server instance ID"
  value       = aws_instance.web.id
}

output "web_public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.web.public_ip
}

output "web_public_dns" {
  description = "EC2 public DNS name"
  value       = aws_instance.web.public_dns
}
