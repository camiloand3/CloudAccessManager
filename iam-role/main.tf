terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Trust policy: WHO can assume this role (here, the EC2 service)
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 2. The role itself
resource "aws_iam_role" "example" {
  name               = "my-example-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    ManagedBy = "Terraform"
  }
}

# 3. Permissions: WHAT the role can do (here, read-only S3 via an AWS managed policy)
resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

output "role_arn" {
  value = aws_iam_role.example.arn
}