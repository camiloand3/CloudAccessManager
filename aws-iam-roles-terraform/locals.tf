data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Default trust: the account root (delegates to IAM permissions in the account).
  trusted_principal_arns = length(var.trusted_principal_arns) > 0 ? var.trusted_principal_arns : [
    "arn:${local.partition}:iam::${local.account_id}:root"
  ]

  # One entry per role. Key = IAM role name.
  roles = {
    "Okta-Developer" = {
      description          = "Engineers: manage Dev-tagged EC2, read S3."
      managed_policy_arns  = []
      create_inline_policy = true
      inline_policy_json   = data.aws_iam_policy_document.developer.json
    }

    "Okta-DataAnalyst" = {
      description          = "Analysts: query curated data with Athena, read one data bucket."
      managed_policy_arns  = []
      create_inline_policy = true
      inline_policy_json   = data.aws_iam_policy_document.data_analyst.json
    }

    "Okta-MLEngineer" = {
      description          = "ML engineers: run SageMaker jobs and endpoints, use the ML bucket."
      managed_policy_arns  = []
      create_inline_policy = true
      inline_policy_json   = data.aws_iam_policy_document.ml_engineer.json
    }

    "Okta-Auditor" = {
      description = "Security and compliance: read-only visibility across services."
      managed_policy_arns = [
        "arn:${local.partition}:iam::aws:policy/SecurityAudit",
        "arn:${local.partition}:iam::aws:policy/job-function/ViewOnlyAccess",
      ]
      create_inline_policy = false
      inline_policy_json   = null
    }
  }
}
