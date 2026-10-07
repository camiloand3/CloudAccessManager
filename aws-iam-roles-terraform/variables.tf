variable "aws_region" {
  description = "AWS region (IAM is global, but a region is still required)."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name. Used in tags and bucket names."
  type        = string
  default     = "iam-roles-lab"
}

variable "environment" {
  description = "Environment name used in tags."
  type        = string
  default     = "lab"
}

variable "trusted_principal_arns" {
  description = "Who can assume the roles. Empty = any principal in this account that has sts:AssumeRole permission."
  type        = list(string)
  default     = []
}

variable "require_mfa" {
  description = "Require MFA to assume the roles."
  type        = bool
  default     = false
}

variable "max_session_duration" {
  description = "Session length in seconds for all roles."
  type        = number
  default     = 3600
}

variable "force_destroy_buckets" {
  description = "Allow terraform destroy to delete non-empty lab buckets."
  type        = bool
  default     = true
}
