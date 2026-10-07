# Lab buckets referenced by the DataAnalyst and MLEngineer policies.
# Names include the account ID so they are globally unique without any input.

locals {
  buckets = {
    analytics_data = "${var.project}-analytics-data-${local.account_id}"
    athena_results = "${var.project}-athena-results-${local.account_id}"
    ml_artifacts   = "${var.project}-ml-artifacts-${local.account_id}"
  }
}

resource "aws_s3_bucket" "lab" {
  for_each = local.buckets

  bucket        = each.value
  force_destroy = var.force_destroy_buckets
}

resource "aws_s3_bucket_public_access_block" "lab" {
  for_each = aws_s3_bucket.lab

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lab" {
  for_each = aws_s3_bucket.lab

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
