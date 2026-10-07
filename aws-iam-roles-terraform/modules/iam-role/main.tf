# Trust policy: WHO may become this role.
data "aws_iam_policy_document" "trust" {
  statement {
    sid     = "AllowAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.trusted_principal_arns
    }

    dynamic "condition" {
      for_each = var.require_mfa ? [1] : []
      content {
        test     = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values   = ["true"]
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = var.name
  description          = var.description
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  max_session_duration = var.max_session_duration

  tags = var.tags
}

# Permissions policy: WHAT the role can do (managed policies).
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Permissions policy: WHAT the role can do (custom inline policy).
resource "aws_iam_role_policy" "inline" {
  count = var.create_inline_policy ? 1 : 0

  name   = "${var.name}-permissions"
  role   = aws_iam_role.this.id
  policy = var.inline_policy_json
}
